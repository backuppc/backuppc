#============================================================= -*-perl-*-
#
# BackupPC::CGI::Archive package
#
# DESCRIPTION
#
#   This module implements the Archive action for the CGI interface.
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

package BackupPC::CGI::Archive;

use strict;
use BackupPC::CGI::Lib qw(:all);
use Data::Dumper;

sub action
{
    if ( $In{type} == 0 ) {
        my($fullTot, $fullSizeTot, $incrTot, $incrSizeTot, $str,
        $strNone, $strGood, $hostCntGood, $hostCntNone, $checkBoxCnt,
        $backupnumber);

        $hostCntGood = $hostCntNone = $checkBoxCnt = $fullSizeTot = 0;
        GetStatusInfo("hosts");
        my $Privileged = CheckPermission();

        if ( !$Privileged ) {
            ErrorExit($Lang->{Only_privileged_users_can_archive} );
        }
        foreach my $host ( sort(keys(%Status)) ) {
            my($fullDur, $incrCnt, $fullSize, $fullRate);
            my @Backups = $bpc->BackupInfoRead($host);
            my $fullCnt = $incrCnt = 0;
            for ( my $i = 0 ; $i < @Backups ; $i++ ) {
                if ( $Backups[$i]{type} eq "full" ) {
                    $fullSize = $Backups[$i]{size} / (1024 * 1024);
                    $incrSizeTot = 0;
                } else {
                    $incrSizeTot = $Backups[$i]{size} / (1024 * 1024);
                }
                $backupnumber = $Backups[$i]{num};
            }
            $fullSizeTot += $fullSize + $incrSizeTot;
            $fullSize = sprintf("%.2f", ($fullSize + $incrSizeTot) / 1000);
            $str = <<EOF;
<tr>
<td class="border"><input type="hidden" name="backup$checkBoxCnt" value="$backupnumber"><input type="checkbox" name="fcb$checkBoxCnt" value="$host">&nbsp;${HostLink($host)} </td>
<td align="center" class="border"> ${UserLink($Hosts->{$host}{user})} </td>
<td align="center" class="border"> $fullSize </td>
EOF
            $checkBoxCnt++;
            if ( @Backups == 0 ) {
                $hostCntNone++;
                $strNone .= $str;
            } else {
                $hostCntGood++;
                $strGood .= $str;
            }
        }
        $fullSizeTot = sprintf("%.2f", $fullSizeTot / 1000);
        my $now      = timeStamp2(time);
        my $checkAllHosts = $Lang->{checkAllHosts};
        $strGood .= <<EOF;
<input type="hidden" name="archivehost" value="$In{'archivehost'}">
EOF
        my $content = eval("qq{$Lang->{BackupPC_Archive}}");
        Header(eval("qq{$Lang->{BackupPC__Archive}}"),$content);
        Trailer();
    } else {

        my(@HostList, @BackupList, $HostListStr, $hiddenStr, $pathHdr, $badFileCnt, $reply, $str);

        my $Privileged = CheckPermission();
        my $args = {
            SplitPath    => $bpc->{Conf}{SplitPath},
            ParPath      => $bpc->{Conf}{ParPath},
            CatPath      => $bpc->{Conf}{CatPath},
            GzipPath     => $bpc->{Conf}{GzipPath},
            Bzip2Path    => $bpc->{Conf}{Bzip2Path},
            ArchiveDest  => $bpc->{Conf}{ArchiveDest},
            ArchiveComp  => $bpc->{Conf}{ArchiveComp},
            ArchivePar   => $bpc->{Conf}{ArchivePar},
            ArchiveSplit => $bpc->{Conf}{ArchiveSplit},
            topDir       => $bpc->{TopDir},
        };

        if ( !$Privileged ) {
            ErrorExit($Lang->{Only_privileged_users_can_archive} );
        }
        ServerConnect();

        for ( my $i = 0 ; $i < $In{fcbMax} ; $i++ ) {
            next if ( !defined($In{"fcb$i"}) );
            my $name = $In{"fcb$i"};
            my $backupno = $In{"backup$i"};
            push(@HostList, $name);
            push(@BackupList, $backupno);
            $hiddenStr .= <<EOF;
<input type="hidden" name="fcb$i" value="$In{'fcb' . $i}">
<input type="hidden" name="backup$i" value="$In{'backup' . $i}">
EOF
            $HostListStr .= <<EOF;
<li> ${EscHTML($name)}
EOF
        }
        $hiddenStr .= <<EOF;
<input type="hidden" name="archivehost" value="$In{'archivehost'}">
EOF
        $hiddenStr .= "<input type=\"hidden\" name=\"fcbMax\" value=\"$In{fcbMax}\">\n";
        if ( @HostList == 0 ) {
            ErrorExit($Lang->{You_haven_t_selected_any_hosts});
        }
        my ($ArchiveDest, $ArchiveCompNone, $ArchiveCompGzip, $ArchiveCompBzip2, $ArchivePar, $ArchiveSplit);
        $ArchiveDest       = $bpc->{Conf}{ArchiveDest};
        if ( $bpc->{Conf}{ArchiveComp} eq "none" ) {
            $ArchiveCompNone   = "checked";
        } else {
            $ArchiveCompNone   = "";
        }
        if ( $bpc->{Conf}{ArchiveComp} eq "gzip" ) {
            $ArchiveCompGzip   = "checked";
        } else {
            $ArchiveCompGzip   = "";
        }
        if ( $bpc->{Conf}{ArchiveComp} eq "bzip2" ) {
            $ArchiveCompBzip2  = "checked";
        } else {
            $ArchiveCompBzip2  = "";
        }
        $ArchivePar        = $bpc->{Conf}{ArchivePar};
        $ArchiveSplit      = $bpc->{Conf}{ArchiveSplit};

        if ( $In{type} == 1 ) {
            #
            # Tell the user what options they have
            #

            my $content = eval("qq{$Lang->{BackupPC_Archive2}}");
            Header(eval("qq{$Lang->{BackupPC__Archive}}"),$content);
            Trailer();
        } elsif ( $In{type} == 2 ) {
            my $reqFileName;
            my $archivehost = $1 if ( $In{archivehost} =~ /(.+)/ );
            for ( my $i = 0 ; ; $i++ ) {
                $reqFileName = "archiveReq.$$.$i";
                last if ( !-f "$TopDir/pc/$archivehost/$reqFileName" );
            }
            my $compname;
            if ( $In{compression} == 2 ) { # bzip2 compression
                $compname = $Conf{Bzip2Path};
            } elsif ( $In{compression} == 1 ) { # gzip compression
                $compname = $Conf{GzipPath};
            } else { # No Compression
                $compname = $Conf{CatPath};
            }
            my $compext;
            if ( $In{compression} == 2 ) { # bzip2 compression
                $compext = '.bz2';
            } elsif ( $In{compression} == 1 ) { # gzip compression
                $compext = '.gz';
            } else { # No Compression
                $compext = '.raw';
            }
            my $fullsplitsize = $In{splitsize} . '000000';
            my %ArchiveReq = (
                # parameters for the archive
                archiveloc  => $In{archive_device},
                archtype    => $In{archive_type},
                compression => $compname,
                compext     => $compext,
                parfile     => $In{par},
                splitsize   => $fullsplitsize,
                host        => $archivehost,


                # list of hosts to restore
                HostList    => \@HostList,
                BackupList  => \@BackupList,

                # other info
                user        => $User,
                reqTime     => time,
            );
            my($archive) = Data::Dumper->new(
                            [  \%ArchiveReq],
                            [qw(*ArchiveReq)]);
            $archive->Indent(1);
            if ( open(REQ, ">$TopDir/pc/$archivehost/$reqFileName") ) {
                binmode(REQ);
                print(REQ $archive->Dump);
                close(REQ);
            } else {
                ErrorExit($Lang->{Can_t_open_create} );
            }
        $reply = $bpc->ServerMesg("archive $User $archivehost $reqFileName");

        $str = eval("qq{$Lang->{Archive_requested}}");

            my $content = eval("qq{$Lang->{BackupPC_Archive_Reply_from_server}}");
            Header(eval("qq{$Lang->{BackupPC__Archive}}"),$content);
            Trailer();
        }

    }

}

1;
