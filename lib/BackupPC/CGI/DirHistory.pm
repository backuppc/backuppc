#============================================================= -*-perl-*-
#
# BackupPC::CGI::DirHistory package
#
# DESCRIPTION
#
#   This module implements the DirHistory action for the CGI interface.
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

package BackupPC::CGI::DirHistory;

use strict;
use BackupPC::CGI::Lib qw(:all);
use BackupPC::View;
use BackupPC::XS qw(:all);
use Encode;

sub action
{
    my $Privileged = CheckPermission($In{host});
    my($i, $dirStr, $fileStr, $attr);
    my $checkBoxCnt = 0;

    if ( !$Privileged ) {
        ErrorExit(eval("qq{$Lang->{Only_privileged_users_can_browse_backup_files}}"));
    }
    my $host   = $In{host};
    my $share  = $In{share};
    my $dir    = $In{dir};
    my $dirURI = $dir;
    my $shareURI = $share;
    $dirURI    =~ s/([^\w.\/-])/uc sprintf("%%%02x", ord($1))/eg;
    $shareURI  =~ s/([^\w.\/-])/uc sprintf("%%%02x", ord($1))/eg;

    ErrorExit($Lang->{Empty_host_name}) if ( $host eq "" );

    my @Backups = $bpc->BackupInfoRead($host);
    my $view = BackupPC::View->new($bpc, $host, \@Backups, {inode => 1});
    my $hist = $view->dirHistory($share, $dir);
    my($backupNumStr, $backupTimeStr, $fileStr);

    $dir = "/$dir" if ( $dir !~ /^\// );

    if ( "/$host/$share/$dir/" =~ m{/\.\./} ) {
        ErrorExit($Lang->{Nice_try__but_you_can_t_put});
    }

    my @backupList = $view->backupList($share, $dir);
    foreach $i ( @backupList ) {
	my $backupTime  = timeStamp2($Backups[$i]{startTime});
	my $num = $Backups[$i]{num};
	$backupNumStr  .= "<td align=center><a href=\"$MyURL?action=browse"
			. "&host=${EscURI($host)}&num=$num&share=$shareURI"
			. "&dir=$dirURI\">$num</a></td>";
	$backupTimeStr .= "<td align=center>$backupTime</td>";
    }

    #
    # For V3 we rely on inodes to identify identical files.
    #
    # For V4 the (fake) inodes might be the same between different versions of
    # a file, so we rely on matching the digests instead.
    #
    # So, if digests are defined, we use those.  Otherwise we used inodes.
    #
    foreach my $f ( sort {uc($a) cmp uc($b)} keys(%$hist) ) {
	my %inode2name;
	my %digest2name;
	my $nameCnt = 0;
	(my $fDisp  = "${EscHTML($f)}") =~ s/ /&nbsp;/g;
        $fDisp      = decode_utf8($fDisp);
	$fileStr   .= "<tr><td align=\"left\"  class=\"histView\">$fDisp</td>";
	my($colSpan, $url, $inode, $type, $digest);
	my $tdClass = ' class="histView"';
	foreach $i ( @backupList ) {
	    my($path);
	    if ( $colSpan > 0 ) {
		#
		# The file is the same if it also size==0 (inode == -1)
		# or if it is a directory and the previous one is (inode == -2)
		# or if the inodes and digests agree and the types are the same.
		#
		if ( defined($hist->{$f}[$i])
		    && $hist->{$f}[$i]{type} == $type
		    && (($hist->{$f}[$i]{size} == 0 && $inode == -1)
		        || ($hist->{$f}[$i]{type} == BPC_FTYPE_DIR && $inode == -2)
		        || (length($hist->{$f}[$i]{digest}) ? $hist->{$f}[$i]{digest} eq $digest
                                                            : $hist->{$f}[$i]{inode} == $inode)) ) {
		    $colSpan++;
		    next;
		}
		#
		# Also handle the case of a sequence of missing files
		#
		if ( !defined($hist->{$f}[$i]) && $inode == -3 ) {
		    $colSpan++;
		    next;
		}
		$fileStr .= "<td align=center colspan=$colSpan$tdClass>"
			  . "$url</td>";
		$colSpan = 0;
		$tdClass = ' class="histView"';
	    }
	    if ( !defined($hist->{$f}[$i]) ) {
		$colSpan = 1;
		$url     = "&nbsp;";
		$inode   = -3;			# special value for missing
		$tdClass = ' class="histViewMis"';
		next;
	    }
            if ( $dir eq "" ) {
                $path = "/$f";
            } else {
                ($path = "$dir/$f") =~ s{//+}{/}g;
            }
	    $path =~ s{^/+}{/};
	    $path =~ s/([^\w.\/-])/uc sprintf("%%%02X", ord($1))/eg;
	    my $num = $hist->{$f}[$i]{backupNum};
	    if ( $hist->{$f}[$i]{type} == BPC_FTYPE_DIR ) {
		$inode = -2;			# special value for dir
		$type  = $hist->{$f}[$i]{type};
		$url   = <<EOF;
<a href="$MyURL?action=dirHistory&host=${EscURI($host)}&share=$shareURI&dir=$path">$Lang->{DirHistory_dirLink}</a>
EOF
	    } else {
                my $thisName;
		$inode  = $hist->{$f}[$i]{inode};
		$digest = $hist->{$f}[$i]{digest};
		$type   = $hist->{$f}[$i]{type};
		#
		# special value for empty file
		#
		$inode = -1 if ( $hist->{$f}[$i]{size} == 0 );
		if ( length($digest) ) {
                    if ( !defined($digest2name{$digest}) ) {
                        $thisName = $digest2name{$digest}
                                  = "$Lang->{DirHistory_fileLink}$nameCnt";
                        $nameCnt++;
                    }
                } else {
                    if ( !defined($inode2name{$inode}) ) {
                        $thisName = $inode2name{$inode}
                                  = "$Lang->{DirHistory_fileLink}$nameCnt";
                        $nameCnt++;
                    }
		}
		$url = <<EOF;
<a href="$MyURL?action=RestoreFile&host=${EscURI($host)}&num=$num&share=$shareURI&dir=$path">$thisName</a>
EOF
	    }
	    $colSpan = 1;
	}
	if ( $colSpan > 0 ) {
	    $fileStr .= "<td align=center colspan=$colSpan$tdClass>$url</td>";
	    $colSpan = 0;
	}
	$fileStr .= "</tr>\n";
    }

    #
    # allow each level of the directory path to be navigated to
    #
    my($thisPath, $dirDisplay);
    my $dirClean = $dir;
    $dirClean =~ s{//+}{/}g;
    $dirClean =~ s{/+$}{};
    my @dirElts = split(/\//, $dirClean);
    @dirElts = ("/") if ( !@dirElts );
    foreach my $d ( @dirElts ) {
        my($thisDir);

        if ( $thisPath eq "" ) {
            $thisDir  = decode_utf8($share);
            $thisPath = "/";
        } else {
            $thisPath .= "/" if ( $thisPath ne "/" );
            $thisPath .= "$d";
            $thisDir = decode_utf8($d);
        }
        my $thisPathURI = $thisPath;
        $thisPathURI =~ s/([^\w.\/-])/uc sprintf("%%%02x", ord($1))/eg;
        $dirDisplay .= "/" if ( $dirDisplay ne "" );
        $dirDisplay .= "<a href=\"$MyURL?action=dirHistory&host=${EscURI($host)}&share=$shareURI&dir=$thisPathURI\">${EscHTML($thisDir)}</a>";
    }
    my $content = eval("qq{$Lang->{DirHistory_for__host}}");
    Header(eval("qq{$Lang->{DirHistory_backup_for__host}}"), $content);
    Trailer();
}

1;
