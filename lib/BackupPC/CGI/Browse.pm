#============================================================= -*-perl-*-
#
# BackupPC::CGI::Browse package
#
# DESCRIPTION
#
#   This module implements the Browse action for the CGI interface.
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

package BackupPC::CGI::Browse;

use strict;
use BackupPC::CGI::Lib qw(:all);
use BackupPC::View;
use BackupPC::Attrib qw(:all);

sub action
{
    my $Privileged = CheckPermission($In{host});
    my($i, $dirStr, $fileStr, $attr);
    my $checkBoxCnt = 0;

    if ( !$Privileged ) {
        ErrorExit(eval("qq{$Lang->{Only_privileged_users_can_browse_backup_files}}"));
    }
    my $host  = $In{host};
    my $num   = $In{num};
    my $share = $In{share};
    my $dir   = $In{dir};

    ErrorExit($Lang->{Empty_host_name}) if ( $host eq "" );
    #
    # Find the requested backup and the previous filled backup
    #
    my @Backups = $bpc->BackupInfoRead($host);
    for ( $i = 0 ; $i < @Backups ; $i++ ) {
        last if ( $Backups[$i]{num} == $num );
    }
    if ( $i >= @Backups ) {
        ErrorExit("Backup number $num for host ${EscHTML($host)} does"
	        . " not exist.");
    }
    my $backupTime = timeStamp2($Backups[$i]{startTime});
    my $backupAge = sprintf("%.1f", (time - $Backups[$i]{startTime})
                                    / (24 * 3600));
    my $view = BackupPC::View->new($bpc, $host, \@Backups);

    if ( $dir eq "" || $dir eq "." || $dir eq ".." ) {
	$attr = $view->dirAttrib($num, "", "");
	if ( keys(%$attr) > 0 ) {
	    $share = (sort(keys(%$attr)))[0];
	    $dir   = '/';
	} else {
            ErrorExit(eval("qq{$Lang->{Directory___EscHTML}}"));
	}
    }
    $dir = "/$dir" if ( $dir !~ /^\// );
    my $relDir  = $dir;
    my $currDir = undef;

    #
    # Loop up the directory tree until we hit the top.
    #
    my(@DirStrPrev);
    while ( 1 ) {
        my($fLast, $fLastum, @DirStr);

	$attr = $view->dirAttrib($num, $share, $relDir);
        if ( !defined($attr) ) {
            ErrorExit(eval("qq{$Lang->{Can_t_browse_bad_directory_name2}}"));
        }

        my $fileCnt = 0;          # file counter
        $fLast = $dirStr = "";

        #
        # Loop over each of the files in this directory
        #
	foreach my $f ( sort {uc($a) cmp uc($b)} keys(%$attr) ) {
            my($dirOpen, $gotDir, $imgStr, $img, $path);
            my $fURI = $f;                             # URI escaped $f
            my $shareURI = $share;                     # URI escaped $share
	    if ( $relDir eq "" ) {
		$path = "/$f";
	    } else {
		($path = "$relDir/$f") =~ s{//+}{/}g;
	    }
	    if ( $shareURI eq "" ) {
		$shareURI = $f;
		$path  = "/";
	    }
            $path =~ s{^/+}{/};
            $path     =~ s/([^\w.\/-])/uc sprintf("%%%02X", ord($1))/eg;
            $fURI     =~ s/([^\w.\/-])/uc sprintf("%%%02X", ord($1))/eg;
            $shareURI =~ s/([^\w.\/-])/uc sprintf("%%%02X", ord($1))/eg;
            $dirOpen  = 1 if ( defined($currDir) && $f eq $currDir );
            if ( $attr->{$f}{type} == BPC_FTYPE_DIR ) {
                #
                # Display directory if it exists in current backup.
                # First find out if there are subdirs
                #
		my($bold, $unbold, $BGcolor);
		$img |= 1 << 6;
		$img |= 1 << 5 if ( $attr->{$f}{nlink} > 2 );
		if ( $dirOpen ) {
		    $bold = "<b>";
		    $unbold = "</b>";
		    $img |= 1 << 2;
		    $img |= 1 << 3 if ( $attr->{$f}{nlink} > 2 );
		}
		my $imgFileName = sprintf("%07b.gif", $img);
		$imgStr = "<img src=\"$Conf{CgiImageDirURL}/$imgFileName\" align=\"absmiddle\" width=\"9\" height=\"19\" border=\"0\">";
		if ( "$relDir/$f" eq $dir ) {
		    $BGcolor = " bgcolor=\"$Conf{CgiHeaderBgColor}\"";
		} else {
		    $BGcolor = "";
		}
		my $dirName = $f;
		$dirName =~ s/ /&nbsp;/g;
		push(@DirStr, {needTick => 1,
			       tdArgs   => $BGcolor,
			       link     => <<EOF});
<a href="$MyURL?action=browse&host=${EscURI($host)}&num=$num&share=$shareURI&dir=$path">$imgStr</a><a href="$MyURL?action=browse&host=${EscURI($host)}&num=$num&share=$shareURI&dir=$path" style="font-size:13px;font-family:arial;text-decoration:none;line-height:15px">&nbsp;$bold$dirName$unbold</a></td></tr>
EOF
                $fileCnt++;
                $gotDir = 1;
		if ( $dirOpen ) {
		    my($lastTick, $doneLastTick);
		    foreach my $d ( @DirStrPrev ) {
			$lastTick = $d if ( $d->{needTick} );
		    }
		    $doneLastTick = 1 if ( !defined($lastTick) );
		    foreach my $d ( @DirStrPrev ) {
			$img = 0;
			if  ( $d->{needTick} ) {
			    $img |= 1 << 0;
			}
			if ( $d == $lastTick ) {
			    $img |= 1 << 4;
			    $doneLastTick = 1;
			} elsif ( !$doneLastTick ) {
			    $img |= 1 << 3 | 1 << 4;
			}
			my $imgFileName = sprintf("%07b.gif", $img);
			$imgStr = "<img src=\"$Conf{CgiImageDirURL}/$imgFileName\" align=\"absmiddle\" width=\"9\" height=\"19\" border=\"0\">";
			push(@DirStr, {needTick => 0,
				       tdArgs   => $d->{tdArgs},
				       link     => $imgStr . $d->{link}
			});
		    }
		}
            }
            if ( $relDir eq $dir ) {
                #
                # This is the selected directory, so display all the files
                #
                my $attrStr;
                if ( defined($a = $attr->{$f}) ) {
                    my $mtimeStr = $bpc->timeStamp($a->{mtime});
		    # UGH -> fix this
                    my $typeStr  = BackupPC::Attrib::fileType2Text(undef,
								   $a->{type});
                    my $modeStr  = sprintf("0%o", $a->{mode} & 07777);
                    $attrStr .= <<EOF;
    <td align="center">$typeStr</td>
    <td align="center">$modeStr</td>
    <td align="center">$a->{backupNum}</td>
    <td align="right">$a->{size}</td>
    <td align="right">$mtimeStr</td>
</tr>
EOF
                } else {
                    $attrStr .= "<td colspan=\"5\" align=\"center\"> </td>\n";
                }
		(my $fDisp = "${EscHTML($f)}") =~ s/ /&nbsp;/g;
                if ( $gotDir ) {
                    $fileStr .= <<EOF;
<tr bgcolor="#ffffcc"><td><input type="checkbox" name="fcb$checkBoxCnt" value="$path">&nbsp;<a href="$MyURL?action=browse&host=${EscURI($host)}&num=$num&share=$shareURI&dir=$path">$fDisp</a></td>
$attrStr
</tr>
EOF
                } else {
                    $fileStr .= <<EOF;
<tr bgcolor="#ffffcc"><td><input type="checkbox" name="fcb$checkBoxCnt" value="$path">&nbsp;<a href="$MyURL?action=RestoreFile&host=${EscURI($host)}&num=$num&share=$shareURI&dir=$path">$fDisp</a></td>
$attrStr
</tr>
EOF
                }
                $checkBoxCnt++;
            }
        }
	@DirStrPrev = @DirStr;
        last if ( $relDir eq "" && $share eq "" );
        # 
        # Prune the last directory off $relDir, or at the very end
	# do the top-level directory.
        #
	if ( $relDir eq "" || $relDir eq "/" || $relDir !~ /(.*)\/(.*)/ ) {
	    $currDir = $share;
	    $share = "";
	    $relDir = "";
	} else {
	    $relDir  = $1;
	    $currDir = $2;
	}
    }
    $share = $currDir;
    my $dirDisplay = "$share/$dir";
    $dirDisplay =~ s{//+}{/}g;
    $dirDisplay =~ s{/+$}{}g;
    $dirDisplay = "/" if ( $dirDisplay eq "" );
    my $filledBackup;

    if ( (my @mergeNums = @{$view->mergeNums}) > 1 ) {
	shift(@mergeNums);
	my $numF = join(", #", @mergeNums);
        $filledBackup = eval("qq{$Lang->{This_display_is_merged_with_backup}}");
    }
    Header(eval("qq{$Lang->{Browse_backup__num_for__host}}"));

    foreach my $d ( @DirStrPrev ) {
	$dirStr .= "<tr><td$d->{tdArgs}>$d->{link}\n";
    }

    ### hide checkall button if there are no files
    my ($topCheckAll, $checkAll, $fileHeader);
    if ( $fileStr ) {
    	$fileHeader = eval("qq{$Lang->{fileHeader}}");

	$checkAll = $Lang->{checkAll};

    	# and put a checkall box on top if there are at least 20 files
	if ( $checkBoxCnt >= 20 ) {
	    $topCheckAll = $checkAll;
	    $topCheckAll =~ s{allFiles}{allFilestop}g;
	}
    } else {
	$fileStr = eval("qq{$Lang->{The_directory_is_empty}}");
    }
    my @otherDirs;
    my $pathURI  = $dir;
    my $shareURI = $share;
    $pathURI  =~ s/([^\w.\/-])/uc sprintf("%%%02x", ord($1))/eg;
    $shareURI =~ s/([^\w.\/-])/uc sprintf("%%%02x", ord($1))/eg;
    foreach my $i ( $view->backupList($share, $dir) ) {
        push(@otherDirs, "<a href=\"$MyURL?action=browse&host=${EscURI($host)}"
                       . "&num=$i&share=$shareURI&dir=$pathURI\">$i</a>");
    }
    if ( @otherDirs ) {
	my $otherDirs  = join(",\n", @otherDirs);
        $filledBackup .= eval("qq{$Lang->{Visit_this_directory_in_backup}}");
    }
    print (eval("qq{$Lang->{Backup_browse_for__host}}"));
    Trailer();
}

1;
