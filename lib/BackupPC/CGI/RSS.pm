#=============================================================
#
# BackupPC::CGI::RSS package
#
# DESCRIPTION
#
#   This module implements an RSS page for the CGI interface.
#
# AUTHOR
#   Rich Duzenbury (rduz at theduz dot com)
#
# COPYRIGHT
#   Copyright (C) 2005-2013  Rich Duzenbury and Craig Barratt
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

package BackupPC::CGI::RSS;

use strict;
use BackupPC::CGI::Lib qw(:all);
use XML::RSS;

sub action
{
    my $protocol = $ENV{HTTPS} eq "on" ?  'https://' : 'http://';
    my $base_url = $protocol . $ENV{'SERVER_NAME'} . $ENV{SCRIPT_NAME};

    my($fullTot, $fullSizeTot, $incrTot, $incrSizeTot, $str,
       $strNone, $strGood, $hostCntGood, $hostCntNone);

    binmode(STDOUT, ":utf8");

    my $rss = new XML::RSS (version => '0.91',
                            encoding => 'utf-8');

    $rss->channel( title => eval("qq{$Lang->{RSS_Doc_Title}}"),
                   link => $base_url,
                   language => $Conf{Language},
                   description => eval("qq{$Lang->{RSS_Doc_Description}}"),
               );

    $hostCntGood = $hostCntNone = 0;
    GetStatusInfo("hosts");
    my $Privileged = CheckPermission();

    foreach my $host ( GetUserHosts(1) ) {
        my($fullDur, $incrCnt, $incrAge, $fullSize, $fullRate, $reasonHilite);
	my($shortErr);
        my @Backups = $bpc->BackupInfoRead($host);
        my $fullCnt = $incrCnt = 0;
        my $fullAge = $incrAge = -1;

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
	$reasonHilite = $Conf{CgiStatusHilightColor}{$Status{$host}{reason}}
		      || $Conf{CgiStatusHilightColor}{$Status{$host}{state}};
	$reasonHilite = " bgcolor=\"$reasonHilite\"" if ( $reasonHilite ne "" );
        if ( $Status{$host}{state} ne "Status_backup_in_progress"
		&& $Status{$host}{state} ne "Status_restore_in_progress"
		&& $Status{$host}{error} ne "" ) {
	    ($shortErr = $Status{$host}{error}) =~ s/(.{48}).*/$1.../;
	    $shortErr = " ($shortErr)";
	}

        my $host_state = $Lang->{$Status{$host}{state}};
        my $host_last_attempt =  $Lang->{$Status{$host}{reason}} . $shortErr;

        $str = eval("qq{$Lang->{RSS_Host_Summary}}");

        $rss->add_item(title => $host . ', ' . 
                                $host_state . ', ' . 
                                $host_last_attempt,
                       link => $base_url . '?host=' . $host,
                       description => $str);
    }

    $fullSizeTot = sprintf("%.2f", $fullSizeTot / 1024);
    $incrSizeTot = sprintf("%.2f", $incrSizeTot / 1024);
    my $now      = timeStamp2(time);

    print 'Content-type: text/xml', "\r\n\r\n",
          $rss->as_string;

}

1;
