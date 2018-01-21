#============================================================= -*-perl-*-
#
# BackupPC::Xfer::Smb package
#
# DESCRIPTION
#
#   This library defines a BackupPC::Xfer::Smb class for managing
#   the SMB (smbclient) transport of backup data from the client.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2001-2017  Craig Barratt
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
# Version 4.1.4, released 24 Nov 2017.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

package BackupPC::Xfer::Smb;

use strict;
use Encode qw/from_to encode/;
use base qw(BackupPC::Xfer::Protocol);
use Fcntl qw(F_GETFL F_SETFL O_NONBLOCK);
use Errno qw(EWOULDBLOCK);

sub useTar
{
    return 1;
}

sub start
{
    my($t) = @_;
    my $bpc = $t->{bpc};
    my $conf = $t->{conf};
    my $I_option = $t->{hostIP} eq $t->{host} ? [] : ['-I', $t->{hostIP}];
    my(@fileList, $X_option, $smbClientCmd, $logMsg);
    my($timeStampFile);
    local(*SMB);

    #
    # First propagate the PASSWD setting 
    #
    $ENV{PASSWD} = $ENV{BPC_SMB_PASSWD} if ( defined($ENV{BPC_SMB_PASSWD}) );
    $ENV{PASSWD} = $conf->{SmbSharePasswd}
                                 if ( defined($conf->{SmbSharePasswd}) );
    if ( !defined($ENV{PASSWD}) ) {
        $t->{_errStr} = "passwd not set for smbclient";
        return;
    }
    if ( !defined($conf->{SmbClientPath}) || !-x $conf->{SmbClientPath} ) {
        $t->{_errStr} = '$Conf{SmbClientPath} is not a valid executable';
        return;
    }
    if ( $t->{type} eq "restore" ) {
        $smbClientCmd = $conf->{SmbClientRestoreCmd};
        $logMsg = "restore started for share $t->{shareName}";
    } else {
	#
	# Turn $conf->{BackupFilesOnly} and $conf->{BackupFilesExclude}
	# into a hash of arrays of files, and $conf->{SmbShareName}
	# to an array
	#
	$bpc->backupFileConfFix($conf, "SmbShareName");

	$t->{fileIncludeHash} = {};
        if ( defined($conf->{BackupFilesOnly}{$t->{shareName}}) ) {
            foreach my $file ( @{$conf->{BackupFilesOnly}{$t->{shareName}}} ) {
                $file = encode($conf->{ClientCharset}, $file)
                            if ( $conf->{ClientCharset} ne "" );
		push(@fileList, $file);
		$t->{fileIncludeHash}{$file} = 1;
            }
        } elsif ( defined($conf->{BackupFilesExclude}{$t->{shareName}}) ) {
            foreach my $file ( @{$conf->{BackupFilesExclude}{$t->{shareName}}} )
            {
                $file = encode($conf->{ClientCharset}, $file)
                            if ( $conf->{ClientCharset} ne "" );
		push(@fileList, $file);
            }
	    #
	    # Allow simple wildcards in exclude list by specifying "r" option.
	    #
            $X_option = "rX";
        }
        if ( $t->{type} eq "full" ) {
	    $smbClientCmd = $conf->{SmbClientFullCmd};
            $logMsg = "full backup started for share $t->{shareName}";
        } else {
            $timeStampFile = "$t->{outDir}/timeStamp.level0";
            open(LEV0, ">", $timeStampFile) && close(LEV0);
            utime($t->{incrBaseTime} - 3600, $t->{incrBaseTime} - 3600,
                  $timeStampFile);
	    $smbClientCmd = $conf->{SmbClientIncrCmd};
            $logMsg = "incr backup started back to "
                    . $bpc->timeStamp($t->{incrBaseTime} - 3600, 0)
                    . " (backup #$t->{incrBaseBkupNum}) for share"
                    . " $t->{shareName}";
        }
    }
    my $args = {
	smbClientPath => $conf->{SmbClientPath},
	host          => $t->{host},
	hostIP	      => $t->{hostIP},
	client	      => $t->{client},
	shareName     => $t->{shareName},
	userName      => $conf->{SmbShareUserName},
	fileList      => \@fileList,
	I_option      => $I_option,
	X_option      => $X_option,
	timeStampFile => $timeStampFile,
    };
    from_to($args->{shareName}, "utf8", $conf->{ClientCharset})
                            if ( $conf->{ClientCharset} ne "" );
    $smbClientCmd = $bpc->cmdVarSubstitute($smbClientCmd, $args);

    if ( !defined($t->{xferPid} = open(SMB, "-|")) ) {
        $t->{_errStr} = "Can't fork to run smbclient";
        return;
    }
    $t->{pipeSMB} = *SMB;
    if ( !$t->{xferPid} ) {
        #
        # This is the smbclient child.
        #
        setpgrp 0,0;
        if ( $t->{type} eq "restore" ) {
            #
            # For restores close the write end of the pipe,
            # clone STDIN from RH, and STDERR to STDOUT
            #
            close($t->{pipeWH});
            close(STDERR);
            open(STDERR, ">&STDOUT");
            close(STDIN);
            open(STDIN, "<&$t->{pipeRH}");
        } else {
            #
            # For backups close the read end of the pipe,
            # clone STDOUT to WH, STDERR to STDOUT
            #
            close($t->{pipeRH});
            close(STDERR);
            open(STDERR, ">&STDOUT");
            open(STDOUT, ">&$t->{pipeWH}");
        }
        #
        # Run smbclient.
        #
	alarm(0);
        $bpc->cmdExecOrEval($smbClientCmd, $args);
        # should not be reached, but just in case...
        $t->{_errStr} = "Can't exec $conf->{SmbClientPath}";
        return;
    }
    my $str = $bpc->execCmd2ShellCmd(@$smbClientCmd);
    from_to($str, $conf->{ClientCharset}, "utf8")
                            if ( $conf->{ClientCharset} ne "" );
    $t->{XferLOG}->write(\"Running: $str\n");
    alarm($conf->{ClientTimeout});
    $t->{_errStr} = undef;
    #
    # make pipeSMB non-blocking; BackupPC_dump uses select() to see if there
    # is something to read.
    #
    if ( !fcntl($t->{pipeSMB}, F_SETFL, fcntl($t->{pipeSMB}, F_GETFL, 0) | O_NONBLOCK) ) {
        $t->{_errStr} = "can't set pipeSMB to non-blocking";
    }
    return $logMsg;
}

sub readOutput
{
    my($t, $FDreadRef, $rout) = @_;
    my $conf = $t->{conf};

    if ( vec($rout, fileno($t->{pipeSMB}), 1) ) {
        my $mesg;

        $! = 0;
        if ( sysread($t->{pipeSMB}, $mesg, 8192) <= 0 ) {
            if ( $! == EWOULDBLOCK ) {
                $t->{XferLOG}->write(\"readOutput: no bytes read (EWOULDBLOCK); continuing\n");
            } elsif ( eof($t->{pipeSMB}) ) {
                vec($$FDreadRef, fileno($t->{pipeSMB}), 1) = 0;
		my $ok = close($t->{pipeSMB});
                $t->{XferLOG}->write(\"readOutput: sysread returns 0 and got EOF (exit ok = $ok, $!)\n");
                $t->{xferOK} = $ok ? 1 : 0;
                $t->{smbOut} .= "Non-zero exit status from smbclient\n" if ( !$ok );
            }
        } else {
            $t->{smbOut} .= $mesg;
        }
    }
    while ( $t->{smbOut} =~ /(.*?)[\n\r]+(.*)/s ) {
        $_ = $1;
        $t->{smbOut} = $2;
	#
	# ignore the log file time stamps from smbclient introduced
	# in version 3.0.0 - don't even write them to the log file.
	#
	if ( m{^\[\d+/\d+/\d+ +\d+:\d+:\d+.*\] +(client/cli|lib/util_unistr).*\(\d+\)} ) {
            $t->{XferLOG}->write(\"$_\n") if ( $t->{logLevel} >= 5 );
            next;
        }
        #
        # refresh our inactivity alarm
        #
        alarm($conf->{ClientTimeout}) if ( !$t->{abort} );
        $t->{lastOutputLine} = $_ if ( !/^$/ );

        from_to($_, $conf->{ClientCharset}, "utf8")
                            if ( $conf->{ClientCharset} ne "" );
        #
        # This section is highly dependent on the version of smbclient.
        # If you upgrade Samba, make sure that these regexp are still valid.
        #
        # MAKSYM 14082016: The next regex will never match on Samba-4.3, as
        # smbclient doesn't produce output required; keeping it for older Sambas
        if ( /^\s*(-?\d+) \(\s*\d+[.,]\d kb\/s\) (.*)$/ ) {
            my $sambaFileSize = $1;
            my $pcFileName    = $2;
            (my $fileName = $pcFileName) =~ s/\\/\//g;
            $sambaFileSize += 1024 * 1024 * 4096 if ( $sambaFileSize < 0 );
            $fileName =~ s/^\/*//;
            $t->{byteCnt} += $sambaFileSize;
            $t->{fileCnt}++;
            $t->{XferLOG}->write(\"$_\n") if ( $t->{logLevel} >= 2 );
        } elsif ( /restore tar file (.*) of size (\d+) bytes/ ) {
            $t->{byteCnt} += $2;
            $t->{fileCnt}++;
            $t->{XferLOG}->write(\"$_\n") if ( $t->{logLevel} >= 1 );
        } elsif ( /^\s*tar: dumped (\d+) files/) {
            # MAKSYM 14082016: Updating file count to the likely number
            $t->{xferOK} = 1;
            $t->{fileCnt} = $1;
            $t->{XferLOG}->write(\"$_\n") if ( $t->{logLevel} >= 0 );
        } elsif ( /^\s*tar:\d+\s*Total bytes received: (\d+)/) {
            # MAKSYM 14082016: Updating byte count to the likely number
            $t->{xferOK} = 1;
            $t->{byteCnt} = $1;
            $t->{XferLOG}->write(\"$_\n") if ( $t->{logLevel} >= 0 );
        } elsif ( /^\s*tar: restored \d+ files/
                    || /^\s*tar:\d+\s*tar_process done, err = 0/ ) {
            $t->{xferOK} = 1;
            $t->{XferLOG}->write(\"$_\n") if ( $t->{logLevel} >= 0 );
        } elsif ( /^\s*read_socket_with_timeout: timeout read. /i ) {
            $t->{hostAbort} = 1;
            $t->{XferLOG}->write(\"$_\n") if ( $t->{logLevel} >= 0 );
        } elsif ( /^code 0 listing /
                    || /^\s*code 0 opening /
                    || /^\s*abandoning restore/i
                    || /^\s*Error: Looping in FIND_NEXT/i
                    || /^\s*SUCCESS - 0/i
                    || /^\s*Call timed out: server did not respond/i
		    || /^\s*tree connect failed: ERRDOS - ERRnoaccess \(Access denied\.\)/
		    || /^\s*tree connect failed: NT_STATUS_BAD_NETWORK_NAME/
		    || /^\s*NT_STATUS_INSUFF_SERVER_RESOURCES listing /
                 ) {
	    if ( $t->{hostError} eq "" ) {
		$t->{XferLOG}->write(\"This backup will fail because: $_\n");
		$t->{hostError} = $_;
	    }
            $t->{XferLOG}->write(\"$_\n") if ( $t->{logLevel} >= 0 );
        } elsif ( /^\s*NT_STATUS_ACCESS_DENIED listing (.*)/
	       || /^\s*ERRDOS - ERRnoaccess \(Access denied\.\) listing (.*)/ ) {
            $t->{xferErrCnt}++;
	    my $badDir = $1;
	    $badDir =~ s{\\}{/}g;
	    $badDir =~ s{/+}{/}g;
	    $badDir =~ s{/\*$}{};
	    if ( $t->{hostError} eq ""
		    && ($badDir eq "" || $t->{fileIncludeHash}{$badDir}) ) {
		$t->{XferLOG}->write(\"This backup will fail because: $_\n");
		$t->{hostError} ||= $_;
	    }
            $t->{XferLOG}->write(\"$_\n") if ( $t->{logLevel} >= 0 );
        } elsif ( /^\s*directory \\/i ) {
            $t->{XferLOG}->write(\"$_\n") if ( $t->{logLevel} >= 2 );
        } elsif ( /^tar:\d+ Error opening remote file/i ) {
            $t->{xferErrCnt}++;
            $t->{XferLOG}->write(\"XferErr $_\n") if ( $t->{logLevel} >= 1 );
        } elsif ( /smb: \\>/
                || /^\s*tar:\d+/ # MAKSYM 14082016: ignoring 2 more Samba-4.3 specific lines
                || /^\s*WARNING:/i
                || /^\s*added interface/i
                || /^\s*tarmode is now/i
                || /^\s*Total bytes written/i
                || /^\s*Domain=/i
                || /^\([\d\.]* kb\/s\) \(average [\d\.]* kb\/s\)$/i
                || /^\s*Getting files newer than/i
		|| /^\s*restore directory \\/i
                || /^\s*Output is \/dev\/null/i
                || /^\s*Timezone is/i
                || /^\s*tar_re_search set/i
                || /^\s*creating lame (up|low)case table/i
                || /^\s*rlimit_max: increasing rlimit_max/i
                || /^\s*OS=\[/i
                || /^\s*$/
	    ) {
            # ignore these messages
            $t->{XferLOG}->write(\"$_\n") if ( $t->{logLevel} >= 1 );
        } else {
            $t->{xferErrCnt}++;
            $t->{xferBadShareCnt}++ if ( /^ERRDOS - ERRbadshare/ );
            $t->{xferBadFileCnt}++  if ( /^ERRDOS - ERRbadfile/ );
            if ( $t->{xferErrCnt} > 50000 ) {
                $t->logMsg(
                      "Too many smbtar errors ($t->{xferErrCnt})... giving up");
                $t->{hostError} = "Too many smbtar errors ($t->{xferErrCnt})";
                return;
            }
            if ( /^Error reading file (.*)\. Got 0 bytes/ ) {
                #
                # This happens when a Windoze application has
                # locked the file.  This is a particular problem
                # with MS-Outlook.  smbclient has already written
                # the tar header to stdout, so all it can do is to
                # write a dummy file with the correct size, but all
                # zeros. BackupPC_tarExtract stores these
                # zero-content files efficiently as a sparse file,
                # or if compression is on the file will be small
                # anyhow.  After the dump is done we simply delete
                # the file (it is no use) and try to link it to same
                # file in any recent backup.
                #
                my $badFile = $1;
                $badFile =~ s{\\}{/}g;
                $badFile =~ s{^/}{};
                push(@{$t->{badFiles}}, {
			share => $t->{shareName},
			file  => $badFile
		    });
            }
            $t->{XferLOG}->write(\"XferErr $_\n") if ( $t->{logLevel} >= 1 );
        }
    }
    return 1;
}

sub setSelectMask
{
    my($t, $FDreadRef) = @_;

    vec($$FDreadRef, fileno($t->{pipeSMB}), 1) = 1;
}

1;
