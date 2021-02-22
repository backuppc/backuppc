#============================================================= -*-perl-*-
#
# BackupPC::CGI::Check package
#
# DESCRIPTION
#
#   This module implements the Check action for the CGI interface.
#
# AUTHOR
#   Heuze Florent  <heuzef@firewall-services.com>
#
#========================================================================
#
# firewall-services.com
# Version 1.0.0, released Feb 2021.
#
# See https://git.fws.fr/fws/BackupPC-Check
#
#========================================================================

package BackupPC::CGI::Check;

use strict;
use lib "/usr/share/BackupPC/lib";
use BackupPC::Lib;
use BackupPC::CGI::Lib qw(:all);
use Statistics::Descriptive;

sub action
{
    # Init
    my($str, $strGood, $header);
    GetStatusInfo("hosts info");
    my $Privileged = CheckPermission();
    my $bpc = BackupPC::Lib->new();

    # Start loop
    foreach my $host ( GetUserHosts(1) ) {
      my($incrAge, $reasonHilite, $frequency, $idBackup, $lastAge, $lastAgeColor, $tempState, $tempReason, $lastXferErrors, $lastXferErrorsColor, $ifErrors, $sizeConsistency, $sizeConsistencyColor);
      my($shortErr);
      my @Backups = $bpc->BackupInfoRead($host);

      $bpc->ConfigRead($host);
      %Conf = $bpc->Conf();

      next if ( $Conf{XferMethod} eq "archive" );
      next if ( !$Privileged && !CheckPermission($host) );

      # Get frequency for this host
      if ( $Conf{IncrPeriod} < $Conf{FullPeriod} ) {
        $frequency = $Conf{IncrPeriod};
      } else {
        $frequency = $Conf{FullPeriod};
      }

      # Get ID of last backup
      my $idBackup = $Backups[@Backups-1]->{num} if ( @Backups );

      # Get age of last backup
      my $lastBackup = ( $Backups[-1]->{type} =~ m/^full|incr$/ ) ? -1 : -2;
      $lastAge = sprintf("%.1f", (time - $Backups[$lastBackup]->{startTime}) / (24 * 3600));

      # Color for age old
      if ( $lastAge < $frequency ) {
        $lastAgeColor = "MediumSeaGreen";
      } else {
        $lastAgeColor = "Tomato";
      }

      # Color and link for errors
      $lastXferErrors = $Backups[@Backups-1]->{xferErrs} if ( @Backups );
      if ( $lastXferErrors == 0 ) {
        $lastXferErrorsColor = "MediumSeaGreen";
        $ifErrors = "";
      } else {
        $lastXferErrorsColor = "Tomato";
        my $browseErrors = "?action=view&type=XferErr&num=$idBackup&host=$host";
        $ifErrors = "| <a href=\"$browseErrors\" target=\"_blank\"><strong>Read me !</strong></a>";
      }

      # Colors statuts of backup
      $reasonHilite = $Conf{CgiStatusHilightColor}{$Status{$host}{reason}} || $Conf{CgiStatusHilightColor}{$Status{$host}{state}};
      $reasonHilite = " bgcolor=\"$reasonHilite\"" if ( $reasonHilite ne "" );

      # Check Size Consistency
      my $new_size = 0;
      my $new_size_avg = 0;
      my $new_size_q1 = 0;
      my $new_size_q3 = 0;
      my $sizes = new Statistics::Descriptive::Full;

      foreach my $backup ( @Backups ) {
        my $idBackup = $Backups[@Backups-1]->{num} if ( @Backups );
        # Skip partial or active backups
        next if ( $backup->{type} !~ m/^full|incr$/ );
        # Push all the sizes in our data set to compute avg sizes
        # Exclude backup N°0 as it'll always have much more new data than normal backups
        $sizes->add_data($backup->{sizeNew}) unless ( $backup->{num} == 0 );

        # Ignore the last backup if it's not full or incr (which means it's either partial or active)
        my $i = ( $Backups[-1]->{type} =~ m/^full|incr$/ ) ? -1 : -2;
        $new_size = $Backups[$i]->{sizeNew};
        $new_size_avg = int $sizes->mean;
        $new_size_q1 = eval { int $sizes->quantile(1) } || 0;
        $new_size_q3 = eval { int $sizes->quantile(3) } || 0;
      }

      # Using a mathematical formula to calculate the consistency of the average size, for new files, on all backups :
      my $toobig = 0;
      my $toosmall = 0;
      my $sizeConsistencyColor = "Tomato";
      my $sizeConsistency = "<strong>ANOMALOUS</strong>";

      # Too big ? If the size is 3 times higher than usual :
      if ( $new_size > ($new_size_q3 + ($new_size_q3 - $new_size_q1) ) * 1.5 and $new_size > $new_size_avg * 3 ) {
        $toobig = 1;
      }

      # Too small ? If the size is 3 times lower than usual :
      if ( $new_size < ($new_size_q1 - ($new_size_q3 - $new_size_q1) ) * 1.5 and $new_size < $new_size_avg / 3 ) {
        $toosmall = 1;
      }

      # Get result, if we don't have enough backup (< 4) we can't calcul a realist average
      if ( not $idBackup > 4) {
        $sizeConsistencyColor = "Gray";
        $sizeConsistency = "Not enough backups";
      }
      elsif ( not $toobig and not $toosmall and not $idBackup < 4) {
        $sizeConsistencyColor = "MediumSeaGreen";
        $sizeConsistency = "Normal";
      }

      # Get URL for explore file
      my $browseFile = "?action=browse&host=$host";

      # Show summary
      $str .= <<EOF;
      <tr$reasonHilite>
        <td class="border"><a href="$browseFile" target="_blank">$host ($idBackup)</a></td>
        <td align="center" class="border" style="color:$lastAgeColor;">$lastAge <em>(Freq: $frequency)</em></td>
        <td align="center" class="border" style="color:$lastXferErrorsColor;">$lastXferErrors $ifErrors</td>
        <td align="center" class="border" style="color:$sizeConsistencyColor;">$sizeConsistency</td>
      </tr>
EOF

    }
    # End loop

    # Time set
    my $now            = timeStamp2(time);
    my $DUmaxTime      = timeStamp2($Info{DUDailyMaxTime});
    my $DUInodemaxTime = timeStamp2($Info{DUInodeDailyMaxTime});

    # Show header
    $header = <<EOF;
    \${h1(qq{BackupPC: Check})}
    <p>This check was generated at <strong>\$now</strong>.</p>

    <p>File system pool size usage (\$DUmaxTime) :</p>
    <div style="background-color:#f1f1f1!important">
      <div style="color:#fff!important;background-color:#2196F3!important; text-align:center; width:\$Info{DUDailyMax}%">\$Info{DUDailyMax}%</div>
    </div>

    <p>File system inode size usage (\$DUInodemaxTime) :</p>
    <div style="background-color:#f1f1f1!important">
      <div style="color:#fff!important;background-color:#2196F3!important; text-align:center; width:\$Info{DUInodeDailyMax}%">\$Info{DUInodeDailyMax}%</div>
    </div>

    \${h2("Backups summary")}

    <table class="sortable" id="host_summary_backups" border cellpadding="3" cellspacing="1">
    <tr class="tableheader">
        <td>Host (Explore files)</td>
        <td>Last backup in days</td>
        <td>Errors</td>
        <td>Size Consistency</td>
    </tr>
    \$str
    </table>
EOF


    my $content = eval ("qq{$header}");
    Header("BackupPC: Check", $content);
    Trailer();
}

1;
