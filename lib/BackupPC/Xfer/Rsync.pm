#============================================================= -*-perl-*-
#
# BackupPC::Xfer::Rsync package
#
# DESCRIPTION
#
#   This library defines a BackupPC::Xfer::Rsync class for managing
#   the rsync-based transport of backup data from/to the client.
#   After generating the rsync arguments, it calls BackupPC_rsyncBackup
#   or BackupPC_rsyncRestore to actually do the backup or restore.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2002-2013  Craig Barratt
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

package BackupPC::Xfer::Rsync;

use strict;
use BackupPC::View;
use Encode qw/from_to encode/;
use base qw(BackupPC::Xfer::Protocol);
use Errno qw(EINTR);

sub new
{
    my($class, $bpc, $args) = @_;

    my $t = BackupPC::Xfer::Protocol->new($bpc, $args);

    $t->{logSave} = [];
    $t->{logInfo} = {};
    return bless($t, $class);
}

sub start
{
    my($t) = @_;
    my $bpc = $t->{bpc};
    my $conf = $t->{conf};
    my(@fileList, $rsyncArgs, $logMsg, $rsyncCmd);
    my $binDir = $t->{bpc}->BinDir();

    #
    # We add a slash to the share name we pass to rsync
    #
    ($t->{shareNameSlash} = "$t->{shareName}/") =~ s{//+$}{/};

    if ( $t->{type} eq "restore" ) {
	my $remoteDir = "$t->{shareName}/$t->{pathHdrDest}";
	$remoteDir    =~ s{//+}{/}g;
        my $filesFd;
        my $srcList;
        my $srcDir = "/";

        #from_to($remoteDir, "utf8", $conf->{ClientCharset})
        #                            if ( $conf->{ClientCharset} ne "" );
        $rsyncArgs = [@{$conf->{RsyncRestoreArgs}}];

        #
        # Each name in the fileList starts with $t->{pathHdrSrc}.  The
        # default $t->{pathHdrDest} also ends in $t->{pathHdrSrc}, although
        # the user might have changed that.  So we have $t->{pathHdrSrc}
        # appearing twice: in the fileList and in the target directory.
        # We have to remove one or the other.
        #
        # Since the client rsync only tries to create the last directory
        # in $t->{pathHdrDest} (rather than the full path), it will fail
        # if the parent directory doesn't exist.  So, if the last part of
        # $t->{pathHdrDest} matches $t->{pathHdrSrc}, we remove it.
        # Otherwise, we remove $t->{pathHdrSrc} from each of fileList,
        # and it's the user's responsibility to make sure the target
        # directory exists.
        # 

        if ( $remoteDir =~ m{(.*)\Q$t->{pathHdrSrc}\E(/*)$} ) {
            $remoteDir = "$1$2";
            $t->{XferLOG}->write(\"Trimming $t->{pathHdrSrc} from remoteDir -> $remoteDir\n");
        } else {
            for ( my $i = 0 ; $i < @{$t->{fileList}} ; $i++ ) {
                $t->{fileList}[$i] = substr($t->{fileList}[$i], length($t->{pathHdrSrc}));
            }
            $t->{XferLOG}->write(\"Trimming $t->{pathHdrSrc} from filesList\n");
        }

        $t->{filesFrom} = "$conf->{TopDir}/pc/$t->{client}/.rsyncFilesFrom$$";
        if ( open($filesFd, ">", $t->{filesFrom}) ) {
            syswrite($filesFd, join("\n", @{$t->{fileList}}));
            close($filesFd);
            $t->{XferLOG}->write(\"Wrote source file list to $t->{filesFrom}: @{$t->{fileList}}\n");
            $srcList = ["--files-from=$t->{filesFrom}", $srcDir];
        } else {
            $t->{XferLOG}->write(\"Failed to open/create file list $t->{filesFrom}\n");
            $t->{_errStr} = "Failed to open/create file list $t->{filesFrom}";
            return;
        }

        if ( $t->{XferMethod} eq "rsync" ) {
            unshift(@$rsyncArgs, "--rsync-path=$conf->{RsyncClientPath}")
                            if ( $conf->{RsyncClientPath} ne "" );
            unshift(@$rsyncArgs, @{$conf->{RsyncSshArgs}})
                            if ( ref($conf->{RsyncSshArgs}) eq 'ARRAY' );
            push(@$rsyncArgs, @$srcList, "$t->{host}:$remoteDir");
        } else {
            my $pwFd;
            $t->{pwFile} = "$conf->{TopDir}/pc/$t->{client}/.rsyncdpw$$";
            if ( open($pwFd, ">", $t->{pwFile}) ) {
                chmod(0400, $t->{pwFile});
                binmode($pwFd);
                syswrite($pwFd, $conf->{RsyncdPasswd});
                close($pwFd);
                push(@$rsyncArgs, "--password-file=$t->{pwFile}");
            }
            my $shareName = $t->{shareName};
            #from_to($shareName, "utf8", $conf->{ClientCharset})
            #                    if ( $conf->{ClientCharset} ne "" );
            if ( $conf->{RsyncdClientPort} != 873 ) {
                push(@$rsyncArgs, "--port=$conf->{RsyncdClientPort}");
            }
            if ( $conf->{ClientCharset} ne "" ) {
                push(@$rsyncArgs, "--iconv=utf8,$conf->{ClientCharset}");
            }
            push(@$rsyncArgs,
                    @$srcList,
                    "$conf->{RsyncdUserName}\@$t->{host}::$remoteDir");
        }

        #
        # Merge variables into $rsyncArgs
        #
        $rsyncArgs = $bpc->cmdVarSubstitute($rsyncArgs, {
                            host      => $t->{host},
                            hostIP    => $t->{hostIP},
                            client    => $t->{client},
                            confDir   => $conf->{ConfDir},
                            sshPath   => $conf->{SshPath},
                        });
        #
        # create --bpc-bkup-merge list.  This is the list of backups that have to
        # be merged to create the correct "view" of the backup being restore.
        #
        my($srcIdx, $i, $mergeInfo);
        my $mergeIdxList = [];

        for ( $i = 0 ; $i < @{$t->{backups}} ; $i++ ) {
            if ( $t->{backups}[$i]{num} == $t->{bkupSrcNum} ) {
                $srcIdx = $i;
                last;
            }
        }
        if ( !defined($srcIdx) ) {
            $t->{_errStr} = "Can't find backup number $t->{bkupSrcNum} in backups file";
            return;
        }
        if ( $t->{backups}[$srcIdx]{version} < 4 ) {
            #
            # For per-V4 backups, we merge forward from the prior full.
            #
            my $level = $t->{backups}[$srcIdx]{level} + 1;
            for ( $i = $srcIdx ; $level > 0 && $i >= 0 ; $i-- ) {
                next if ( $t->{backups}[$i]{level} >= $level );
                $level = $t->{backups}[$i]{level};
                unshift(@$mergeIdxList, $i);
            }
        } else {
            #
            # For V4+ backups, we merge backward from the following filled backup.
            #
            for ( $i = $srcIdx ; $i < @{$t->{backups}} ; $i++ ) {
                unshift(@$mergeIdxList, $i);
                last if ( !$t->{backups}[$i]{noFill} );
            }
        }
        foreach my $i ( @$mergeIdxList ) {
            $mergeInfo .= "," if ( length($mergeInfo) );
            $mergeInfo .= sprintf("%d/%d/%d", $t->{backups}[$i]{num}, $t->{backups}[$i]{compress}, int($t->{backups}[$i]{version}));
        }

        unshift(@$rsyncArgs,
            '--bpc-top-dir',        $conf->{TopDir},
            '--bpc-host-name',      $t->{bkupSrcHost},
            '--bpc-share-name',     $t->{bkupSrcShare},
            '--bpc-bkup-num',       $t->{backups}[$srcIdx]{num},
            '--bpc-bkup-comp',      $t->{backups}[$srcIdx]{compress},
            '--bpc-bkup-merge',     $mergeInfo,
            '--bpc-log-level',      $conf->{XferLogLevel},
        );

        $logMsg = "restore started below directory $t->{shareName}"
		. " to host $t->{host}";
    } else {
	#
	# Turn $conf->{BackupFilesOnly} and $conf->{BackupFilesExclude}
	# into a hash of arrays of files, and $conf->{RsyncShareName}
	# to an array
	#
	$bpc->backupFileConfFix($conf, "RsyncShareName");

        if ( defined($conf->{BackupFilesOnly}{$t->{shareName}}) ) {
            my(@inc, @exc, %incDone, %excDone);
            foreach my $file2 ( @{$conf->{BackupFilesOnly}{$t->{shareName}}} ) {
                #
                # If the user wants to just include /home/craig, then
                # we need to do create include/exclude pairs at
                # each level:
                #     --include /home --exclude /*
                #     --include /home/craig --exclude /home/*
                #
                # It's more complex if the user wants to include multiple
                # deep paths.  For example, if they want /home/craig and
                # /var/log, then we need this mouthfull:
                #     --include /home --include /var --exclude /*
                #     --include /home/craig --exclude /home/*
                #     --include /var/log --exclude /var/*
                #
                # To make this easier we do all the includes first and all
                # of the excludes at the end (hopefully they commute).
                #
                my $file = $file2;
                $file =~ s{/$}{};
                $file = "/$file";
                $file =~ s{//+}{/}g;
		if ( $file eq "/" ) {
		    #
		    # This is a special case: if the user specifies
		    # "/" then just include it and don't exclude "/*".
		    #
                    push(@inc, $file) if ( !$incDone{$file} );
		    next;
		}
                my $f = "";
                while ( $file =~ m{^/([^/]*)(.*)} ) {
                    my $elt = $1;
                    $file = $2;
                    if ( $file eq "/" ) {
                        #
                        # preserve a tailing slash
                        #
                        $file = "";
                        $elt = "$elt/";
                    }
                    push(@exc, "$f/*") if ( !$excDone{"$f/*"} );
                    $excDone{"$f/*"} = 1;
                    $f = "$f/$elt";
                    push(@inc, $f) if ( !$incDone{$f} );
                    $incDone{$f} = 1;
                }
            }
            foreach my $file ( @inc ) {
                $file = encode($conf->{ClientCharset}, $file)
                            if ( $conf->{ClientCharset} ne "" );
                push(@fileList, "--include=$file");
            }
            foreach my $file ( @exc ) {
                $file = encode($conf->{ClientCharset}, $file)
                            if ( $conf->{ClientCharset} ne "" );
                push(@fileList, "--exclude=$file");
            }
        }
        if ( defined($conf->{BackupFilesExclude}{$t->{shareName}}) ) {
            foreach my $file2 ( @{$conf->{BackupFilesExclude}{$t->{shareName}}} ) {
                #
                # just append additional exclude lists onto the end
                #
                my $file = $file2;
                $file = encode($conf->{ClientCharset}, $file)
                            if ( $conf->{ClientCharset} ne "" );
                push(@fileList, "--exclude=$file");
            }
        }
        #
        # A full dump is implemented with $Conf{RsyncFullArgsExtra},
        # which is normally --checksum.  This causes the client to
        # generate and send a full-file checksum for each file with
        # the file list.  That can be directly compared with the
        # V4 full-file digest.
        #
        # In V3 --ignore-times was used, that causes block checksum
        # to be generated and checked for every file.  That's more
        # conservative, but a lot more effort.
        #
        $rsyncArgs = [@{$conf->{RsyncArgs}}];

        if ( $t->{type} eq "full" ) {
            $logMsg = "full backup started for directory $t->{shareName}";
            if ( ref($conf->{RsyncFullArgsExtra}) eq 'ARRAY' ) {
                push(@$rsyncArgs, @{$conf->{RsyncFullArgsExtra}});
            } else {
                push(@$rsyncArgs, $conf->{RsyncFullArgsExtra});
            }
        } else {
            $logMsg = "incr backup started for directory $t->{shareName}";
        }
        
        #
        # Add any additional rsync args
        #
        push(@$rsyncArgs, @{$conf->{RsyncArgsExtra}})
                    if ( ref($conf->{RsyncArgsExtra}) eq 'ARRAY' );
        if ( $conf->{ClientCharset} ne "" ) {
            push(@$rsyncArgs, "--iconv=utf8,$conf->{ClientCharset}");
        }

        if ( $t->{XferMethod} eq "rsync" ) {
            unshift(@$rsyncArgs, "--rsync-path=$conf->{RsyncClientPath}")
                            if ( $conf->{RsyncClientPath} ne "" );
            unshift(@$rsyncArgs, @{$conf->{RsyncSshArgs}})
                            if ( ref($conf->{RsyncSshArgs}) eq 'ARRAY' );
        } else {
            if ( $conf->{RsyncdClientPort} != 873 ) {
                push(@$rsyncArgs, "--port=$conf->{RsyncdClientPort}");
            }
        }

        #
        # Merge variables into $rsyncArgs
        #
        $rsyncArgs = $bpc->cmdVarSubstitute($rsyncArgs, {
                            host      => $t->{host},
                            hostIP    => $t->{hostIP},
                            client    => $t->{client},
                            confDir   => $conf->{ConfDir},
                            sshPath   => $conf->{SshPath},
                        });

        if ( $t->{XferMethod} eq "rsync" ) {
            my $shareNameSlash = $t->{shareNameSlash};
            #from_to($shareNameSlash, "utf8", $conf->{ClientCharset})
            #                    if ( $conf->{ClientCharset} ne "" );

            push(@$rsyncArgs, @fileList) if ( @fileList );
            push(@$rsyncArgs, "$t->{host}:$shareNameSlash", "/");
        } else {
            my $pwFd;
            $t->{pwFile} = "$conf->{TopDir}/pc/$t->{client}/.rsyncdpw$$";
            if ( open($pwFd, ">", $t->{pwFile}) ) {
                chmod(0400, $t->{pwFile});
                binmode($pwFd);
                syswrite($pwFd, $conf->{RsyncdPasswd});
                close($pwFd);
                push(@$rsyncArgs, "--password-file=$t->{pwFile}");
            }
            my $shareName = $t->{shareName};
            #from_to($shareName, "utf8", $conf->{ClientCharset})
            #                    if ( $conf->{ClientCharset} ne "" );
            push(@$rsyncArgs, @fileList) if ( @fileList );
            push(@$rsyncArgs,
                    "$conf->{RsyncdUserName}\@$t->{host}::$shareName",
                    "/");
        }
        if ( $bpc->{PoolV3} ) {
            unshift(@$rsyncArgs,
                    '--bpc-hardlink-max',  $conf->{HardLinkMax} || 31999,
                    '--bpc-v3pool-used',   $conf->{PoolV3Enabled},
            );
        }
        unshift(@$rsyncArgs,
            '--bpc-top-dir',        $conf->{TopDir},
            '--bpc-host-name',      $t->{client},
            '--bpc-share-name',     $t->{shareName},
            '--bpc-bkup-num',       $t->{backups}[$t->{newBkupIdx}]{num},
            '--bpc-bkup-comp',      $t->{backups}[$t->{newBkupIdx}]{compress},
            '--bpc-bkup-prevnum',   defined($t->{lastBkupIdx}) ? $t->{backups}[$t->{lastBkupIdx}]{num} : -1,
            '--bpc-bkup-prevcomp',  defined($t->{lastBkupIdx}) ? $t->{backups}[$t->{lastBkupIdx}]{compress} : -1,
            '--bpc-bkup-inode0',    $t->{backups}[$t->{newBkupIdx}]{inodeLast} || 1,
            '--bpc-log-level',      $conf->{XferLogLevel},
        );
    }

    #from_to($args->{shareName}, "utf8", $conf->{ClientCharset})
    #                        if ( $conf->{ClientCharset} ne "" );
    if ( $conf->{RsyncBackupPCPath} eq "" || !-x $conf->{RsyncBackupPCPath} ) {
        $t->{_errStr} = "\$Conf{RsyncBackupPCPath} is set to $conf->{RsyncBackupPCPath}, which isn't a valid executable";
        return;
    }
    $rsyncCmd = [$conf->{RsyncBackupPCPath}, @$rsyncArgs];

    my $rsyncFd;
    if ( !defined($t->{xferPid} = open($rsyncFd, "-|")) ) {
        $t->{_errStr} = "Can't fork to run $conf->{RsyncBackupPCPath}";
        return;
    }
    $t->{rsyncFd} = $rsyncFd;
    if ( !$t->{xferPid} ) {
        #
        # This is the rsync child.  We capture both stdout
        # and stderr to put into the XferLOG file.
        #
        setpgrp 0,0;
        close(STDERR);
        open(STDERR, ">&STDOUT");
        #
        # Run the $conf->{RsyncBackupPCPath} command
        #
	alarm(0);
        print("This is the rsync child about to exec $conf->{RsyncBackupPCPath}\n");
	$bpc->cmdExecOrEval($rsyncCmd);
        print("cmdExecOrEval failed $?\n");
        # should not be reached, but just in case...
        $t->{_errStr} = "Can't exec @$rsyncCmd)";
        return;
    }
    my $str = "Running: " . $bpc->execCmd2ShellCmd(@$rsyncCmd) . "\n";
    #from_to($str, $conf->{ClientCharset}, "utf8")
    #                        if ( $conf->{ClientCharset} ne "" );
    $t->{XferLOG}->write(\"Running: @$rsyncCmd\n");
    alarm($conf->{ClientTimeout});
    $t->{_errStr} = undef;
    return $logMsg;
}

sub run
{
    my($t) = @_;
    my $conf = $t->{conf};

    alarm($conf->{ClientTimeout});
    while ( 1 ) {
        my($mesg, $done);
        if ( sysread($t->{rsyncFd}, $mesg, 32768) <= 0 ) {
            next if ( $!{EINTR} );
            if ( !close($t->{rsyncFd}) ) {
                #
                # rsync exits with the RERR_* codes in errcode.h.  Exit codes 23, 24, 25 are minor (ie: some
                # error in transfer, but not fatal).  Other non-zero exit codes are considered failures.
                #
                $t->{lastOutputLine} = $t->{lastErrorLine} if ( defined($t->{lastErrorLine}) );
                my $exitCode = $? >> 8;
                if ( $exitCode == 23 || $exitCode == 24 || $exitCode == 25 ) {
                    $t->{rsyncOut} .= "rsync_bpc exited with benign status $exitCode ($?)\n";
                    $t->{xferOK} = 1;
                    $t->{stats}{xferErrs}++;
                } else {
                    $t->{rsyncOut} .= "rsync_bpc exited with fatal status $exitCode ($?) ($t->{lastOutputLine})\n";
                    $t->{xferOK} = 0;
                    $t->{stats}{xferErrs}++;
                }
	    } else {
		$t->{xferOK} = 1;
            }
            $done = 1;
        } else {
            $t->{rsyncOut} .= $mesg;
        }
        while ( $t->{rsyncOut} =~ /(.*?)[\n\r]+(.*)/s ) {
            $_ = $1;
            $t->{rsyncOut} = $2;
            #
            # refresh our inactivity alarm
            #
            alarm($conf->{ClientTimeout}) if ( !$t->{abort} );
            if ( /^log:\s(recv|del\.|send)\s(.{11})\s.{9}\s*\d+,\s*\d+\s*(\d+)\s(.*)/ ) {
                my $type     = $1;
                my $changes  = $2;
                my $size     = $3;
                my $fileName = $4;
                if ( $changes =~ /^\./ ) {
                    $t->{logInfo}{$fileName}{seqNum} = ++$t->{logInfoSeq};
                    push(@{$t->{logInfo}{$fileName}{status}}, "same");
                }
                if ( $type eq "del." ) {
                    $t->{logInfo}{$fileName}{seqNum} = ++$t->{logInfoSeq};
                    push(@{$t->{logInfo}{$fileName}{status}}, "del");
                }
                s/^log: //;
                push(@{$t->{logSave}},
                        {
                            mesg     => $_,
                            type     => $type,
                            fileName => $fileName,
                        });
                $t->logSaveFlush();
                next;
            }
            if ( /^IOdone:\s(\S*)\s(.*)/ ) {
                my $status   = $1;
                my $fileName = $2;
                $t->{logInfo}{$fileName}{seqNum} = ++$t->{logInfoSeq};
                push(@{$t->{logInfo}{$fileName}{status}}, $status);
                $t->{XferLOG}->write(\"$_\n") if ( $conf->{XferLogLevel} >= 6 );
                $t->logSaveFlush();
                next;
            }
            if ( /^__bpc_progress_fileCnt__ \d+/ ) {
                print("$_\n");
                $t->{XferLOG}->write(\"$_\n") if ( $conf->{XferLogLevel} >= 6 );
                next;
            }
            if ( /^ERROR: / ) {
                if ( /failed verification -- update discarded./ ) {
                    $t->{xferBadFileCnt}++;
                }
                $t->{stats}{xferErrs}++;
            }
            if ( /^IOrename:\s(\d+)\s(.*)/ ) {
                my $oldName = substr($2, 0, $1);
                my $newName = substr($2, $1);
                $t->{logInfo}{$newName} = $t->{logInfo}{$oldName};
                delete($t->{logInfo}{$oldName});
                $t->{XferLOG}->write(\"$_\n") if ( $conf->{XferLogLevel} >= 6 );
                $t->logSaveFlush();
                next;
            }
            if ( /^xferPids (\d+),(\d+)/ ) {
                my $pidHandler = $t->{pidHandler};
                if ( ref($pidHandler) eq 'CODE' ) {
                    &$pidHandler($1, $2);
                } else {
                    $t->{XferLOG}->write(\"$_\n") if ( $conf->{XferLogLevel} >= 4 );
                }
            }
            if ( /^Done(Gen)?: (\d+) errors, (\d+) filesExist, (\d+) sizeExist, (\d+) sizeExistComp, (\d+) filesTotal, (\d+) sizeTotal, (\d+) filesNew, (\d+) sizeNew, (\d+) sizeNewComp, (\d+) inode/ ) {
                $t->{stats}{xferErrs}      += $2;
                $t->{stats}{nFilesExist}   += $3;
                $t->{stats}{sizeExist}     += $4;
                $t->{stats}{sizeExistComp} += $5;
                $t->{stats}{nFilesTotal}   += $6;
                $t->{stats}{sizeTotal}     += $7;
                $t->{stats}{nFilesNew}     += $8;
                $t->{stats}{sizeNew}       += $9;
                $t->{stats}{sizeNewComp}   += $10;
                $t->{stats}{inode}          = $11 if ( $t->{stats}{inode} < $11 );
                $t->{XferLOG}->write(\"$_\n");
                $t->{XferLOG}->write(\"Parsing done: nFilesTotal = $t->{stats}{nFilesTotal}\n")
                                        if ( $conf->{XferLogLevel} >= 3 );
                $t->{fileCnt} = $t->{stats}{nFilesTotal};
                $t->{byteCnt} = $t->{stats}{nFilesTotal};
                next;
            }

#           if ( /: \.\/(.*): Read error at byte / ) {
#                my $badFile = $1;
#                push(@{$t->{badFiles}}, {
#                        share => $t->{shareName},
#                        file  => $badFile
#                    });
#           }
#            from_to($_, $conf->{ClientCharset}, "utf8")
#                                if ( $conf->{ClientCharset} ne "" );
            $t->{lastOutputLine} = $_ if ( !/^\s+$/ && length($_) );
            $t->{lastErrorLine}  = $_ if ( /^rsync_bpc: / || /^rsync error: / );
            $t->{XferLOG}->write(\"$_\n");
        }
        last if ( $done );
    }
    unlink($t->{pwFile})    if ( length($t->{pwFile})    && -f $t->{pwFile} );
    unlink($t->{filesFrom}) if ( length($t->{filesFrom}) && -f $t->{filesFrom} );
    $t->logSaveFlush(1);
    $t->{lastOutputLine} = $t->{lastErrorLine} if ( defined($t->{lastErrorLine}) );

    if ( $t->{type} eq "restore" ) {
        if ( $t->{xferOK} ) {
            return (
                $t->{fileCnt},
                $t->{byteCnt},
                0,
                undef,
            );
        } else {
            return (
                $t->{fileCnt},
                $t->{byteCnt},
                $t->{stats}{xferErrs},
                $t->{lastOutputLine},
            );
        }
    } else {
        $t->{xferErrCnt} = $t->{stats}{xferErrs};
	return (
            $t->{stats}{xferErrs},
            $t->{stats}{nFilesExist},
            $t->{stats}{sizeExist},
            $t->{stats}{sizeExistComp},
            $t->{stats}{nFilesTotal},
            $t->{stats}{sizeTotal},
            $t->{stats}{nFilesNew},
            $t->{stats}{sizeNew},
            $t->{stats}{sizeNewComp},
            $t->{stats}{inode},
	);
    }
}

sub errStr
{
    my($t) = @_;

    return $t->{_errStr};
}

sub xferPid
{
    my($t) = @_;

    return $t->{xferPid};
}

#
#  usage:
#    $t->abort($reason);
#
# Aborts the current job, by sending an INT signal to the first rsync process
# (which in turn kills the receiver child).
#
sub abort
{
    my($t, $reason) = @_;
    my @xferPid = $t->xferPid;

    $t->{abort}       = 1;
    $t->{abortReason} = $reason;
    if ( @xferPid ) {
        kill($t->{bpc}->sigName2num("INT"), $xferPid[0]);
    }
}

sub logSaveFlush
{
    my($t, $all) = @_;
    my $change = 1;
    my $conf = $t->{conf};

    $all = 1 if ( $t->{type} eq "restore" );

    while ( $change && @{$t->{logSave}} ) {
        $change = 0;
        my $fileName = $t->{logSave}[0]{fileName};
        if ( defined($t->{logInfo}{$fileName}) || $all || @{$t->{logSave}} > 200 ) {
            my $mesg = sprintf("    %-6s %s",
                                shift(@{$t->{logInfo}{$fileName}{status}}),
                                $t->{logSave}[0]{mesg});
            delete($t->{logInfo}{$fileName}) if ( !@{$t->{logInfo}{$fileName}{status}} );
            shift(@{$t->{logSave}});
            #from_to($mesg, $conf->{ClientCharset}, "utf8")
            #                    if ( $conf->{ClientCharset} ne "" );
            $t->{lastOutputLine} = $mesg if ( !/^\s+$/ && length($mesg) );
            $t->{XferLOG}->write(\"$mesg\n");
            $change = 1;
        }
    }
    if ( %{$t->{logInfo}} > 2000 ) {
        #
        # prune the fileName logInfo array if it gets too big
        #
        my @info = sort { $t->{logInfo}{$a}{seqNum} <=> $t->{logInfo}{$b}{seqNum} }
                        keys(%{$t->{logInfo}});
        while ( @info > 500 ) {
            my $fileName = shift(@info);
            delete($t->{logInfo}{$fileName});
        }
    }
}

1;
