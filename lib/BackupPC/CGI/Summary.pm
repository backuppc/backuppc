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
#   Copyright (C) 2003  Craig Barratt
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#========================================================================
#
# Version 2.1.0_CVS, released 3 Jul 2003.
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
    GetStatusInfo("hosts");
    my $Privileged = CheckPermission();

    if ( !$Privileged ) {
        ErrorExit($Lang->{Only_privileged_users_can_view_PC_summaries} );
    }
    foreach my $host ( sort(keys(%Status)) ) {
        my($fullDur, $incrCnt, $incrAge, $fullSize, $fullRate, $reasonHilite);
	my($shortErr);
        my @Backups = $bpc->BackupInfoRead($host);
        my $fullCnt = $incrCnt = 0;
        my $fullAge = $incrAge = -1;
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
        $fullSize = sprintf("%.2f", $fullSize / 1000);
	$incrAge = "&nbsp;" if ( $incrAge eq "" );
	$reasonHilite = $Conf{CgiStatusHilightColor}{$Status{$host}{reason}}
		      || $Conf{CgiStatusHilightColor}{$Status{$host}{state}};
	$reasonHilite = " bgcolor=\"$reasonHilite\"" if ( $reasonHilite ne "" );
        if ( $Status{$host}{state} ne "Status_backup_in_progress"
		&& $Status{$host}{state} ne "Status_restore_in_progress"
		&& $Status{$host}{error} ne "" ) {
	    ($shortErr = $Status{$host}{error}) =~ s/(.{48}).*/$1.../;
	    $shortErr = " ($shortErr)";
	}

        $str = <<EOF;
<tr$reasonHilite><td> ${HostLink($host)} </td>
    <td align="center"> ${UserLink(defined($Hosts->{$host})
				    ? $Hosts->{$host}{user} : "")} </td>
    <td align="center"> $fullCnt </td>
    <td align="center"> $fullAge </td>
    <td align="center"> $fullSize </td>
    <td align="center"> $fullRate </td>
    <td align="center"> $incrCnt </td>
    <td align="center"> $incrAge </td>
    <td align="center"> $Lang->{$Status{$host}{state}} </td>
    <td> $Lang->{$Status{$host}{reason}}$shortErr </td></tr>
EOF
        if ( @Backups == 0 ) {
            $hostCntNone++;
            $strNone .= $str;
        } else {
            $hostCntGood++;
            $strGood .= $str;
        }
    }
    $fullSizeTot = sprintf("%.2f", $fullSizeTot / 1000);
    $incrSizeTot = sprintf("%.2f", $incrSizeTot / 1000);
    my $now      = timeStamp2(time);

    Header($Lang->{BackupPC__Server_Summary});
    print eval ("qq{$Lang->{BackupPC_Summary}}");

    Trailer();
}

1;
