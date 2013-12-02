#============================================================= -*-perl-*-
#
# BackupPC::Xfer::Tar package
#
# DESCRIPTION
#
#   This library defines a BackupPC::Xfer::Tar class for managing
#   the tar-based transport of backup data from the client.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2001-2013  Craig Barratt
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

package BackupPC::Xfer::Tar;

use strict;
use Encode qw/from_to encode/;
use base qw(BackupPC::Xfer::Protocol);

sub useTar
{
    return 1;
}

sub start
{
    my($t) = @_;
    my $bpc = $t->{bpc};
    my $conf = $t->{conf};
    my(@fileList, $tarClientCmd, $logMsg, $incrDate);
    local(*TAR);

    if ( $t->{type} eq "restore" ) {
	$tarClientCmd = $conf->{TarClientRestoreCmd};
        $logMsg = "restore started below directory $t->{shareName}";
	#
	# restores are considered to work unless we see they fail
	# (opposite to backups...)
	#
	$t->{xferOK} = 1;
    } else {
	#
	# Turn $conf->{BackupFilesOnly} and $conf->{BackupFilesExclude}
	# into a hash of arrays of files, and $conf->{TarShareName}
	# to an array
	#
	$bpc->backupFileConfFix($conf, "TarShareName");

        if ( defined($conf->{BackupFilesExclude}{$t->{shareName}}) ) {
            foreach my $file2 ( @{$conf->{BackupFilesExclude}{$t->{shareName}}} ) {
                my $file = $file2;
                $file = "./$2" if ( $file =~ m{^(\./+|/+)(.*)}s );
                $file = encode($conf->{ClientCharset}, $file)
                            if ( $conf->{ClientCharset} ne "" );
                push(@fileList, "--exclude=$file");
            }
        }
        if ( defined($conf->{BackupFilesOnly}{$t->{shareName}}) ) {
            foreach my $file2 ( @{$conf->{BackupFilesOnly}{$t->{shareName}}} ) {
                my $file = $file2;
                $file = $2 if ( $file =~ m{^(\./+|/+)(.*)}s );
		$file = "./$file";
                $file = encode($conf->{ClientCharset}, $file)
                            if ( $conf->{ClientCharset} ne "" );
                push(@fileList, $file);
            }
        } else {
	    push(@fileList, ".");
        }
	if ( ref($conf->{TarClientCmd}) eq "ARRAY" ) {
	    $tarClientCmd = $conf->{TarClientCmd};
	} else {
	    $tarClientCmd = [split(/ +/, $conf->{TarClientCmd})];
	}
	my $args;
        if ( $t->{type} eq "full" ) {
	    $args = $conf->{TarFullArgs};
            $logMsg = "full backup started for directory $t->{shareName}";
        } else {
            $incrDate = $bpc->timeStamp($t->{incrBaseTime} - 3600, 1);
	    $args = $conf->{TarIncrArgs};
            $logMsg = "incr backup started back to $incrDate"
                    . " (backup #$t->{incrBaseBkupNum}) for directory"
                    . " $t->{shareName}";
        }
	push(@$tarClientCmd, split(/ +/, $args));
    }
    #
    # Merge variables into @tarClientCmd
    #
    my $args = {
        host      => $t->{host},
        hostIP    => $t->{hostIP},
        client    => $t->{client},
        incrDate  => $incrDate,
        shareName => $t->{shareName},
	fileList  => \@fileList,
        tarPath   => $conf->{TarClientPath},
        sshPath   => $conf->{SshPath},
    };
    from_to($args->{shareName}, "utf8", $conf->{ClientCharset})
                            if ( $conf->{ClientCharset} ne "" );
    $tarClientCmd = $bpc->cmdVarSubstitute($tarClientCmd, $args);
    if ( !defined($t->{xferPid} = open(TAR, "-|")) ) {
        $t->{_errStr} = "Can't fork to run tar";
        return;
    }
    $t->{pipeTar} = *TAR;
    if ( !$t->{xferPid} ) {
        #
        # This is the tar child.
        #
        setpgrp 0,0;
        if ( $t->{type} eq "restore" ) {
            #
            # For restores, close the write end of the pipe,
            # clone STDIN to RH
            #
            close($t->{pipeWH});
            close(STDERR);
            open(STDERR, ">&STDOUT");
            close(STDIN);
            open(STDIN, "<&$t->{pipeRH}");
        } else {
            #
            # For backups, close the read end of the pipe,
            # clone STDOUT to WH, and STDERR to STDOUT
            #
            close($t->{pipeRH});
            close(STDERR);
            open(STDERR, ">&STDOUT");
            open(STDOUT, ">&$t->{pipeWH}");
        }
        #
        # Run the tar command
        #
	alarm(0);
	$bpc->cmdExecOrEval($tarClientCmd, $args);
        # should not be reached, but just in case...
        $t->{_errStr} = "Can't exec @$tarClientCmd";
        return;
    }
    my $str = "Running: " . $bpc->execCmd2ShellCmd(@$tarClientCmd) . "\n";
    from_to($str, $conf->{ClientCharset}, "utf8")
                            if ( $conf->{ClientCharset} ne "" );
    $t->{XferLOG}->write(\"Running: @$tarClientCmd\n");
    alarm($conf->{ClientTimeout});
    $t->{_errStr} = undef;
    return $logMsg;
}

sub readOutput
{
    my($t, $FDreadRef, $rout) = @_;
    my $conf = $t->{conf};

    if ( vec($rout, fileno($t->{pipeTar}), 1) ) {
        my $mesg;
        if ( sysread($t->{pipeTar}, $mesg, 8192) <= 0 ) {
            vec($$FDreadRef, fileno($t->{pipeTar}), 1) = 0;
            if ( !close($t->{pipeTar}) && $? != 256 ) {
                #
                # Tar 1.16 uses exit status 1 (256) when some files
                # changed during archive creation.  We allow this
                # as a benign error and consider the archive ok
                #
		$t->{tarOut} .= "Tar exited with error $? ($!) status\n";
		$t->{xferOK} = 0 if ( !$t->{tarBadExitOk} );
	    }
        } else {
            $t->{tarOut} .= $mesg;
        }
    }
    my $logFileThres = $t->{type} eq "restore" ? 1 : 2;
    while ( $t->{tarOut} =~ /(.*?)[\n\r]+(.*)/s ) {
        $_ = $1;
        $t->{tarOut} = $2;
        from_to($_, $conf->{ClientCharset}, "utf8")
                            if ( $conf->{ClientCharset} ne "" );
        #
        # refresh our inactivity alarm
        #
        alarm($conf->{ClientTimeout}) if ( !$t->{abort} );
        $t->{lastOutputLine} = $_ if ( !/^$/ );
        if ( /^Total bytes (written|read): / ) {
            $t->{XferLOG}->write(\"$_\n") if ( $t->{logLevel} >= 1 );
            $t->{xferOK} = 1;
        } elsif ( /^\./ ) {
            $t->{XferLOG}->write(\"$_\n") if ( $t->{logLevel} >= $logFileThres );
            $t->{fileCnt}++;
        } else {
            #
            # Ignore annoying log message on incremental for tar 1.15.x
            #
            if ( !/: file is unchanged; not dumped$/ && !/: socket ignored$/ ) {
                $t->{XferLOG}->write(\"$_\n") if ( $t->{logLevel} >= 0 );
                $t->{xferErrCnt}++;
            }
	    #
	    # If tar encounters a minor error, it will exit with a non-zero
	    # status.  We still consider that ok.  Remember if tar prints
	    # this message indicating a non-fatal error.
	    #
	    $t->{tarBadExitOk} = 1
		    if ( $t->{xferOK} && /Error exit delayed from previous / );
            #
            # Also remember files that had read errors
            #
            if ( /: \.\/(.*): Read error at byte / ) {
                my $badFile = $1;
                push(@{$t->{badFiles}}, {
                        share => $t->{shareName},
                        file  => $badFile
                    });
            }

	}
    }
    return 1;
}

sub setSelectMask
{
    my($t, $FDreadRef) = @_;

    vec($$FDreadRef, fileno($t->{pipeTar}), 1) = 1;
}

1;
