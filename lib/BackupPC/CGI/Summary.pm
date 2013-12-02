#============================================================= -*-perl-*-
#
# BackupPC::CGI::Summary package
#
# DESCRIPTION
#
#   This module implements the Summary action for the CGI interface.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2003-2013  Craig Barratt
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#========================================================================
#
# Version 4.0.0alpha3, released 1 Dec 2013.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

package BackupPC::CGI::Summary;

use strict;
use BackupPC::CGI::Lib qw(:all);

sub action
{
    my($fullTot, $fullSizeTot, $incrTot, $incrSizeTot, $str,
       $strNone, $strGood, $hostCntGood, $hostCntNone);

    $hostCntGood = $hostCntNone = 0;
    GetStatusInfo("hosts info");
    my $Privileged = CheckPermission();

    foreach my $host ( GetUserHosts(1) ) {
        my($fullDur, $incrCnt, $incrAge, $fullSize, $fullRate, $reasonHilite,
           $lastAge, $tempState, $tempReason, $lastXferErrors);
	my($shortErr);
        my @Backups = $bpc->BackupInfoRead($host);
        my $fullCnt = $incrCnt = 0;
        my $fullAge = $incrAge = $lastAge = -1;

        $bpc->ConfigRead($host);
        %Conf = $bpc->Conf();

        next if ( $Conf{XferMethod} eq "archive" );
        next if ( !$Privileged && !CheckPermission($host) );

        for ( my $i = 0 ; $i < @Backups ; $i++ ) {
            if ( $Backups[$i]{type} eq "full" ) {
                $fullCnt++;
                if ( $fullAge < 0 || $Backups[$i]{startTime} > $fullAge ) {
                    $fullAge  = $Backups[$i]{startTime};
                    $fullSize = $Backups[$i]{size} / (1024 * 1024);
                    $fullDur  = $Backups[$i]{endTime} - $Backups[$i]{startTime};
                }
                $fullSizeTot += $Backups[$i]{size} / (1024 * 1024);
            } else {
                $incrCnt++;
                if ( $incrAge < 0 || $Backups[$i]{startTime} > $incrAge ) {
                    $incrAge = $Backups[$i]{startTime};
                }
                $incrSizeTot += $Backups[$i]{size} / (1024 * 1024);
            }
        }
        if ( $fullAge > $incrAge && $fullAge >= 0 )  {
            $lastAge = $fullAge;
        } else {
            $lastAge = $incrAge;
        }
        if ( $lastAge < 0 ) {
            $lastAge = "";
        } else {
            $lastAge = sprintf("%.1f", (time - $lastAge) / (24 * 3600));
        }
        if ( $fullAge < 0 ) {
            $fullAge = "";
            $fullRate = "";
        } else {
            $fullAge = sprintf("%.1f", (time - $fullAge) / (24 * 3600));
            $fullRate = sprintf("%.2f",
                                $fullSize / ($fullDur <= 0 ? 1 : $fullDur));
        }
        if ( $incrAge < 0 ) {
            $incrAge = "";
        } else {
            $incrAge = sprintf("%.1f", (time - $incrAge) / (24 * 3600));
        }
        $fullTot += $fullCnt;
        $incrTot += $incrCnt;
        $fullSize = sprintf("%.2f", $fullSize / 1024);
	$incrAge = "&nbsp;" if ( $incrAge eq "" );
        $lastXferErrors = $Backups[@Backups-1]{xferErrs} if ( @Backups );
	$reasonHilite = $Conf{CgiStatusHilightColor}{$Status{$host}{reason}}
		      || $Conf{CgiStatusHilightColor}{$Status{$host}{state}};
	if ( $Conf{BackupsDisable} == 1 ) {
            if ( $Status{$host}{state} ne "Status_backup_in_progress"
                    && $Status{$host}{state} ne "Status_restore_in_progress" ) {
                $reasonHilite = $Conf{CgiStatusHilightColor}{Disabled_OnlyManualBackups};
                $tempState = "Disabled_OnlyManualBackups";
                $tempReason = "";
            } else {
                $tempState = $Status{$host}{state};
                $tempReason = $Status{$host}{reason};
            }
	} elsif ($Conf{BackupsDisable} == 2 ) {
	    $reasonHilite = $Conf{CgiStatusHilightColor}{Disabled_AllBackupsDisabled};
	    $tempState = "Disabled_AllBackupsDisabled";
	    $tempReason = "";
	} else {
	    $tempState = $Status{$host}{state};
	    $tempReason = $Status{$host}{reason};
	}
	$reasonHilite = " bgcolor=\"$reasonHilite\"" if ( $reasonHilite ne "" );
        if ( $tempState ne "Status_backup_in_progress"
		&& $tempState ne "Status_restore_in_progress"
		&& $Conf{BackupsDisable} == 0
		&& $Status{$host}{error} ne "" ) {
	    ($shortErr = $Status{$host}{error}) =~ s/(.{48}).*/$1.../;
	    $shortErr = " ($shortErr)";
	}

        $str = <<EOF;
<tr$reasonHilite><td class="border">${HostLink($host)}</td>
    <td align="center" class="border"> ${UserLink(defined($Hosts->{$host})
				    ? $Hosts->{$host}{user} : "")} </td>
    <td align="center" class="border">$fullCnt</td>
    <td align="center" class="border">$fullAge</td>
    <td align="center" class="border">$fullSize</td>
    <td align="center" class="border">$fullRate</td>
    <td align="center" class="border">$incrCnt</td>
    <td align="center" class="border">$incrAge</td>
    <td align="center" class="border">$lastAge</td> 
    <td align="center" class="border">$Lang->{$tempState}</td>
    <td align="center" class="border">$lastXferErrors</td> 
    <td class="border">$Lang->{$tempReason}$shortErr</td></tr>
EOF
        if ( @Backups == 0 ) {
            $hostCntNone++;
            $strNone .= $str;
        } else {
            $hostCntGood++;
            $strGood .= $str;
        }
    }
    $fullSizeTot = sprintf("%.2f", $fullSizeTot / 1024);
    $incrSizeTot = sprintf("%.2f", $incrSizeTot / 1024);
    my $now      = timeStamp2(time);
    my $DUlastTime   = timeStamp2($Info{DUlastValueTime});
    my $DUmaxTime    = timeStamp2($Info{DUDailyMaxTime});

    my $content = eval ("qq{$Lang->{BackupPC_Summary}}");
    Header($Lang->{BackupPC__Server_Summary}, $content);
    Trailer();
}

1;
