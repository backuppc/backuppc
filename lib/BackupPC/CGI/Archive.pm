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

package BackupPC::CGI::Archive;

use strict;
use BackupPC::CGI::Lib qw(:all);
use Data::Dumper;

sub action
{
    my $archHost = $In{host};
    my $Privileged = CheckPermission();

    if ( !$Privileged ) {
	ErrorExit($Lang->{Only_privileged_users_can_archive} );
    }
    if ( $In{type} == 0 ) {
        my($fullTot, $fullSizeTot, $incrTot, $incrSizeTot, $str,
           $strNone, $strGood, $hostCntGood, $hostCntNone, $checkBoxCnt,
           $backupnumber);

        $hostCntGood = $hostCntNone = $checkBoxCnt = $fullSizeTot = 0;
        GetStatusInfo("hosts");

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
            $fullSize = sprintf("%.2f", ($fullSize + $incrSizeTot) / 1024);
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
        $fullSizeTot = sprintf("%.2f", $fullSizeTot / 1024);
        my $now      = timeStamp2(time);
        my $checkAllHosts = $Lang->{checkAllHosts};
        $strGood .= <<EOF;
<input type="hidden" name="archivehost" value="$In{'archivehost'}">
EOF
        my $content = eval("qq{$Lang->{BackupPC_Archive}}");
        Header(eval("qq{$Lang->{BackupPC__Archive}}"), $content, 1);
        Trailer();
    } else {
        my(@HostList, @BackupList, $HostListStr, $hiddenStr, $pathHdr,
           $badFileCnt, $reply, $str);

        #
        # Pick up the archive host's config file
        #
        $bpc->ConfigRead($archHost);
        %Conf = $bpc->Conf();

        my $args = {
            SplitPath    => $Conf{SplitPath},
            ParPath      => $Conf{ParPath},
            CatPath      => $Conf{CatPath},
            GzipPath     => $Conf{GzipPath},
            Bzip2Path    => $Conf{Bzip2Path},
            ArchiveDest  => $Conf{ArchiveDest},
            ArchiveComp  => $Conf{ArchiveComp},
            ArchivePar   => $Conf{ArchivePar},
            ArchiveSplit => $Conf{ArchiveSplit},
            topDir       => $bpc->{TopDir},
        };

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
        my ($ArchiveDest, $ArchiveCompNone, $ArchiveCompGzip,
            $ArchiveCompBzip2, $ArchivePar, $ArchiveSplit);
        $ArchiveDest = $Conf{ArchiveDest};
        if ( $Conf{ArchiveComp} eq "none" ) {
            $ArchiveCompNone   = "checked";
        } else {
            $ArchiveCompNone   = "";
        }
        if ( $Conf{ArchiveComp} eq "gzip" ) {
            $ArchiveCompGzip   = "checked";
        } else {
            $ArchiveCompGzip   = "";
        }
        if ( $Conf{ArchiveComp} eq "bzip2" ) {
            $ArchiveCompBzip2  = "checked";
        } else {
            $ArchiveCompBzip2  = "";
        }
        $ArchivePar   = $Conf{ArchivePar};
        $ArchiveSplit = $Conf{ArchiveSplit};

        if ( $In{type} == 1 ) {
            #
            # Tell the user what options they have
            #
            my $paramStr = "";
            if ( $Conf{ArchiveClientCmd} =~ /\$archiveloc\b/ ) {
                $paramStr .= eval("qq{$Lang->{BackupPC_Archive2_location}}");
            }
            if ( $Conf{ArchiveClientCmd} =~ /\$compression\b/ ) {
                $paramStr .= eval("qq{$Lang->{BackupPC_Archive2_compression}}");
            }
            if ( $Conf{ArchiveClientCmd} =~ /\$parfile\b/
                    && -x $Conf{ParPath} ) {
                $paramStr .= eval("qq{$Lang->{BackupPC_Archive2_parity}}");
            }
            if ( $Conf{ArchiveClientCmd} =~ /\$splitsize\b/
                    && -x $Conf{SplitPath} ) {
                $paramStr .= eval("qq{$Lang->{BackupPC_Archive2_split}}");
            }
            my $content = eval("qq{$Lang->{BackupPC_Archive2}}");
            Header(eval("qq{$Lang->{BackupPC__Archive}}"), $content, 1);
            Trailer();
        } elsif ( $In{type} == 2 ) {
            my $reqFileName;
            my $archivehost = $1 if ( $In{archivehost} =~ /(.+)/ );
            for ( my $i = 0 ; ; $i++ ) {
                $reqFileName = "archiveReq.$$.$i";
                last if ( !-f "$TopDir/pc/$archivehost/$reqFileName" );
            }
            my($compname, $compext);
            if ( $In{compression} == 2 ) {          # bzip2 compression
                $compname = $Conf{Bzip2Path};
                $compext = '.bz2';
            } elsif ( $In{compression} == 1 ) {     # gzip compression
                $compname = $Conf{GzipPath};
                $compext = '.gz';
            } else { # No Compression
                $compname = $Conf{CatPath};
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
	    my $openPath = "$TopDir/pc/$archivehost/$reqFileName";
	    if ( open(REQ, ">", $openPath) ) {
                binmode(REQ);
                print(REQ $archive->Dump);
                close(REQ);
            } else {
                ErrorExit(eval("qq{$Lang->{Can_t_open_create__openPath}}"));
            }
            $reply = $bpc->ServerMesg("archive $User $archivehost $reqFileName");
            $str = eval("qq{$Lang->{Archive_requested}}");

            my $content = eval("qq{$Lang->{BackupPC_Archive_Reply_from_server}}");
            Header(eval("qq{$Lang->{BackupPC__Archive}}"), $content, 1);
            Trailer();
        }
    }
}

1;
