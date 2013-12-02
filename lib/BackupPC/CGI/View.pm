#============================================================= -*-perl-*-
#
# BackupPC::CGI::View package
#
# DESCRIPTION
#
#   This module implements the View action for the CGI interface.
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

package BackupPC::CGI::View;

use strict;
use BackupPC::CGI::Lib qw(:all);
use BackupPC::XS;
use Encode qw/decode_utf8/;

sub action
{
    my $Privileged = CheckPermission($In{host});
    my $compress = 0;
    my $fh;
    my $host = $In{host};
    my $num  = $In{num};
    my $type = $In{type};
    my $linkHosts = 0;
    my($file, $comment);
    my $ext = $num ne "" ? ".$num" : "";

    ErrorExit(eval("qq{$Lang->{Invalid_number__num}}"))
		    if ( $num ne "" && $num !~ /^\d+$/ );
    if ( $type eq "poolUsage" && $Privileged ) {
        $file = "$LogDir/poolUsage$num.png";
        if ( open($fh, "<", $file) ) {
            my $data;
            print "Content-Type: image/png\r\n";
            print "Content-Transfer-Encoding: binary\r\n\r\n";
            while ( sysread($fh, $data, 1024 * 1024) > 0 ) {
                print $data;
            }
            close($fh);
        }
        return;
    }
    if ( $type ne "docs" && !$Privileged ) {
        ErrorExit($Lang->{Only_privileged_users_can_view_log_or_config_files});
    }
    if ( $type eq "XferLOG" ) {
        $file = "$TopDir/pc/$host/SmbLOG$ext";
        $file = "$TopDir/pc/$host/XferLOG$ext" if ( !-f $file && !-f "$file.z");
    } elsif ( $type eq "XferLOGbad" ) {
        $file = "$TopDir/pc/$host/SmbLOG.bad";
        $file = "$TopDir/pc/$host/XferLOG.bad" if ( !-f $file && !-f "$file.z");
    } elsif ( $type eq "XferErrbad" ) {
        $file = "$TopDir/pc/$host/SmbLOG.bad";
        $file = "$TopDir/pc/$host/XferLOG.bad" if ( !-f $file && !-f "$file.z");
        $comment = $Lang->{Extracting_only_Errors};
    } elsif ( $type eq "XferErr" ) {
        $file = "$TopDir/pc/$host/SmbLOG$ext";
        $file = "$TopDir/pc/$host/XferLOG$ext" if ( !-f $file && !-f "$file.z");
        $comment = $Lang->{Extracting_only_Errors};
    } elsif ( $type eq "RestoreLOG" ) {
        $file = "$TopDir/pc/$host/RestoreLOG$ext";
    } elsif ( $type eq "RestoreErr" ) {
        $file = "$TopDir/pc/$host/RestoreLOG$ext";
        $comment = $Lang->{Extracting_only_Errors};
    } elsif ( $type eq "ArchiveLOG" ) {
        $file = "$TopDir/pc/$host/ArchiveLOG$ext";
    } elsif ( $type eq "ArchiveErr" ) {
        $file = "$TopDir/pc/$host/ArchiveLOG$ext";
        $comment = $Lang->{Extracting_only_Errors};
    } elsif ( $type eq "config" ) {
        # Note: only works for Storage::Text
        $file = $bpc->{storage}->ConfigPath($host);
    } elsif ( $type eq "hosts" ) {
        # Note: only works for Storage::Text
        $file = $bpc->ConfDir() . "/hosts";
        $linkHosts = 1;
    } elsif ( $type eq "docs" ) {
        $file = $bpc->InstallDir() . "/share/doc/BackupPC/BackupPC.html";
    } elsif ( $host ne "" ) {
        if ( !defined($In{num}) ) {
            # get the latest LOG file
            $file = ($bpc->sortedPCLogFiles($host))[0];
            $file =~ s/\.z$//;
        } else {
            $file = "$TopDir/pc/$host/LOG$ext";
        }
        $linkHosts = 1;
    } else {
        $file = "$LogDir/LOG$ext";
        $linkHosts = 1;
    }
    if ( !-f $file && -f "$file.z" ) {
        $file .= ".z";
        $compress = 1;
    }
    my($contentPre, $contentSub, $contentPost);
    $contentPre .= eval("qq{$Lang->{Log_File__file__comment}}");
    if ( $file ne ""
            && defined($fh = BackupPC::XS::FileZIO::open($file, 0, $compress)) ) {

        my $mtimeStr = $bpc->timeStamp((stat($file))[9], 1);

	$contentPre .= eval("qq{$Lang->{Contents_of_log_file}}");

        $contentPre .= "<pre>";
        if ( $type eq "XferErr" || $type eq "XferErrbad"
				|| $type eq "RestoreErr"
				|| $type eq "ArchiveErr" ) {
	    $contentSub = sub {
		#
		# Because the content might be large, we use
		# a sub to return the data in 64K chunks.
		#
		my($skipped, $c, $s);
		while ( length($c) < 65536 ) {
		    $s = $fh->readLine();
		    if ( $s eq "" ) {
			$c .= eval("qq{$Lang->{skipped__skipped_lines}}")
							if ( $skipped );
			last;
		    }
		    $s =~ s/[\n\r]+//g;
		    if ( $s =~ /smb: \\>/
			    || $s =~ /^\s*(\d+) \(\s*\d+\.\d kb\/s\) (.*)$/
			    || $s =~ /^tar: dumped \d+ files/
			    || $s =~ /^\s*added interface/i
			    || $s =~ /^\s*restore tar file /i
			    || $s =~ /^\s*restore directory /i
			    || $s =~ /^\s*tarmode is now/i
			    || $s =~ /^\s*Total bytes written/i
			    || $s =~ /^\s*Domain=/i
			    || $s =~ /^\s*Getting files newer than/i
			    || $s =~ /^\s*Output is \/dev\/null/
			    || $s =~ /^\s*\([\d.,]* kb\/s\) \(average [\d\.]* kb\/s\)$/
			    || $s =~ /^\s+directory \\/
			    || $s =~ /^\s*Timezone is/
			    || $s =~ /^\s*creating lame (up|low)case table/i
			    || $s =~ /^\.\//
			    || $s =~ /^  / ) {
			$skipped++;
			next;
		    }
		    $c .= eval("qq{$Lang->{skipped__skipped_lines}}")
							 if ( $skipped );
		    $skipped = 0;
		    $c .= decode_utf8(${EscHTML($s)}) . "\n";
		}
		return $c;
	    };
        } elsif ( $linkHosts ) {
	    #
	    # Because the content might be large, we use
	    # a sub to return the data in 64K chunks.
	    #
	    $contentSub = sub {
		my($c, $s);
		while ( length($c) < 65536 ) {
		    $s = $fh->readLine();
		    last if ( $s eq "" );
		    $s =~ s/[\n\r]+//g;
		    $s = ${EscHTML($s)};
		    $s =~ s/\b([\w-.]+)\b/defined($Hosts->{$1})
					    ? ${HostLink($1)} : $1/eg;
		    $c .= decode_utf8($s) . "\n";
		}
		return $c;
            };
        } elsif ( $type eq "config" ) {
	    #
	    # Because the content might be large, we use
	    # a sub to return the data in 64K chunks.
	    #
	    $contentSub = sub {
		my($c, $s);
		while ( length($c) < 65536 ) {
		    $s = $fh->readLine();
		    last if ( $s eq "" );
		    $s =~ s/[\n\r]+//g;
		    # remove any passwords and user names
		    $s =~ s/(SmbSharePasswd.*=.*['"]).*(['"])/$1****$2/ig;
		    $s =~ s/(SmbShareUserName.*=.*['"]).*(['"])/$1****$2/ig;
		    $s =~ s/(RsyncdPasswd.*=.*['"]).*(['"])/$1****$2/ig;
		    $s =~ s/(ServerMesgSecret.*=.*['"]).*(['"])/$1****$2/ig;
		    $s = ${EscHTML($s)};
		    $s =~ s[(\$Conf\{.*?\})][
			my $c = $1;
			my $s = lc($c);
			$s =~ s{(\W)}{_}g;
			"<a href=\"?action=view&type=docs#item_$s\"><tt>$c</tt></a>"
		    ]eg;
		    $c .= decode_utf8($s) . "\n";
		}
		return $c;
            };
        } elsif ( $type eq "docs" ) {
	    #
	    # Because the content might be large, we use
	    # a sub to return the data in 64K chunks.
	    #
	    $contentSub = sub {
		my($c, $s);
		while ( length($c) < 65536 ) {
		    $s = $fh->readLine();
		    last if ( $s eq "" );
		    $c .= decode_utf8($s);
		}
		return $c;
            };
	    #
	    # Documentation has a different header and no pre or post text,
	    # so just handle it here
	    #
            Header($Lang->{BackupPC__Documentation}, "", 0, $contentSub);
            Trailer();
	    return;
        } else {
	    #
	    # Because the content might be large, we use
	    # a sub to return the data in 64K chunks.
	    #
	    $contentSub = sub {
		my($c, $s);
		while ( length($c) < 65536 ) {
		    $s = $fh->readLine();
		    last if ( $s eq "" );
		    $s =~ s/[\n\r]+//g;
		    $s = ${EscHTML($s)};
		    $c .= decode_utf8($s) . "\n";
		}
		return $c;
            };
        }
    } else {
	if ( $type eq "docs" ) {
	    ErrorExit(eval("qq{$Lang->{Unable_to_open__file__configuration_problem}}"));
	}
	$contentPre .= eval("qq{$Lang->{_pre___Can_t_open_log_file__file}}");
    }
    $contentPost .= "</pre>\n" if ( $type ne "docs" );
    Header(eval("qq{$Lang->{Backup_PC__Log_File__file}}"),
                    $contentPre, !-f "$TopDir/pc/$host/backups",
		    $contentSub, $contentPost);
    Trailer();
    $fh->close() if ( defined($fh) );
}

1;
