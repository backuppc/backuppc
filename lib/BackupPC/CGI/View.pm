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
# Version 2.1.0_CVS, released 8 Feb 2004.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

package BackupPC::CGI::View;

use strict;
use BackupPC::CGI::Lib qw(:all);
use BackupPC::FileZIO;

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

    ErrorExit(eval("qq{$Lang->{Invalid_number__num}}")) if ( $num ne "" && $num !~ /^\d+$/ );
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
    } elsif ( $host ne "" && $type eq "config" ) {
        $file = "$TopDir/pc/$host/config.pl";
        $file = "$TopDir/conf/$host.pl"
                    if ( $host ne "config" && -f "$TopDir/conf/$host.pl"
                                           && !-f $file );
    } elsif ( $type eq "docs" ) {
        $file = "$BinDir/../doc/BackupPC.html";
        if ( open(LOG, $file) ) {
	    binmode(LOG);
            my $content;
            $content .= $_ while ( <LOG> );
            close(LOG);
            Header($Lang->{BackupPC__Documentation}, $content);
            Trailer();
        } else {
            ErrorExit(eval("qq{$Lang->{Unable_to_open__file__configuration_problem}}"));
        }
        return;
    } elsif ( $type eq "config" ) {
        $file = "$TopDir/conf/config.pl";
    } elsif ( $type eq "hosts" ) {
        $file = "$TopDir/conf/hosts";
    } elsif ( $host ne "" ) {
        $file = "$TopDir/pc/$host/LOG$ext";
    } else {
        $file = "$TopDir/log/LOG$ext";
        $linkHosts = 1;
    }
    if ( !$Privileged ) {
        ErrorExit($Lang->{Only_privileged_users_can_view_log_or_config_files});
    }
    if ( !-f $file && -f "$file.z" ) {
        $file .= ".z";
        $compress = 1;
    }
    my $content;
    $content .= eval ("qq{$Lang->{Log_File__file__comment}}");
    if ( defined($fh = BackupPC::FileZIO->open($file, 0, $compress)) ) {
        my $mtimeStr = $bpc->timeStamp((stat($file))[9], 1);

	$content .= ( eval ("qq{$Lang->{Contents_of_log_file}}"));

        $content .= "<pre>";
        if ( $type eq "XferErr" || $type eq "XferErrbad"
				|| $type eq "RestoreErr"
				|| $type eq "ArchiveErr" ) {
	    my $skipped;
            while ( 1 ) {
                $_ = $fh->readLine();
                if ( $_ eq "" ) {
		    $content .= (eval ("qq{$Lang->{skipped__skipped_lines}}"))
						    if ( $skipped );
		    last;
		}
                if ( /smb: \\>/
                        || /^\s*(\d+) \(\s*\d+\.\d kb\/s\) (.*)$/
                        || /^tar: dumped \d+ files/
                        || /^\s*added interface/i
                        || /^\s*restore tar file /i
                        || /^\s*restore directory /i
                        || /^\s*tarmode is now/i
                        || /^\s*Total bytes written/i
                        || /^\s*Domain=/i
                        || /^\s*Getting files newer than/i
                        || /^\s*Output is \/dev\/null/
                        || /^\s*\([\d.,]* kb\/s\) \(average [\d\.]* kb\/s\)$/
                        || /^\s+directory \\/
                        || /^\s*Timezone is/
			|| /^\s*creating lame (up|low)case table/i
                        || /^\.\//
                        || /^  /
			    ) {
		    $skipped++;
		    next;
		}
		$content .= (eval("qq{$Lang->{skipped__skipped_lines}}"))
						     if ( $skipped );
		$skipped = 0;
                $content .= ${EscHTML($_)};
            }
        } elsif ( $linkHosts ) {
            while ( 1 ) {
                $_ = $fh->readLine();
                last if ( $_ eq "" );
                my $s = ${EscHTML($_)};
                $s =~ s/\b([\w-]+)\b/defined($Hosts->{$1})
                                        ? ${HostLink($1)} : $1/eg;
                $content .= $s;
            }
        } elsif ( $type eq "config" ) {
            while ( 1 ) {
                $_ = $fh->readLine();
                last if ( $_ eq "" );
                # remove any passwords and user names
                s/(SmbSharePasswd.*=.*['"]).*(['"])/$1$2/ig;
                s/(SmbShareUserName.*=.*['"]).*(['"])/$1$2/ig;
                s/(RsyncdPasswd.*=.*['"]).*(['"])/$1$2/ig;
                s/(ServerMesgSecret.*=.*['"]).*(['"])/$1$2/ig;
                $content .= ${EscHTML($_)};
            }
        } else {
            while ( 1 ) {
                $_ = $fh->readLine();
                last if ( $_ eq "" );
                $content .= ${EscHTML($_)};
            }
        }
        $fh->close();
    } else {
	$content .= ( eval("qq{$Lang->{_pre___Can_t_open_log_file__file}}"));
    }
    $content .= <<EOF;
</pre>
EOF
    Header(eval("qq{$Lang->{Backup_PC__Log_File__file}}"),
                    $content, !-f "$TopDir/pc/$host/backups" );
    Trailer();
}

1;
