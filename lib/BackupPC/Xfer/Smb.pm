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
#   Copyright (C) 2001  Craig Barratt
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
# Version 1.5.0, released 2 Aug 2002.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

package BackupPC::Xfer::Smb;

use strict;

sub new
{
    my($class, $bpc, $args) = @_;

    my $t = bless {
        bpc       => $bpc,
        conf      => { $bpc->Conf },
        host      => "",
        hostIP    => "",
        shareName => "",
        pipeRH    => undef,
        pipeWH    => undef,
        badFiles  => [],
        %$args,
    }, $class;

    return $t;
}

sub start
{
    my($t) = @_;
    my $bpc = $t->{bpc};
    my $conf = $t->{conf};
    my $I_option = $t->{hostIP} eq $t->{host} ? "" : " -I $t->{hostIP}";
    my($fileList, $optX, $smbClientCmd, $logMsg);
    local(*SMB);

    #
    # First propagate the PASSWD setting 
    #
    $ENV{PASSWD} = $conf->{SmbSharePasswd}
                                 if ( defined($conf->{SmbSharePasswd}) );
    if ( !defined($ENV{PASSWD}) ) {
        $t->{_errStr} = "passwd not set for smbclient";
        return;
    }
    if ( $t->{type} eq "restore" ) {
        $smbClientCmd =
              "$conf->{SmbClientPath} '\\\\$t->{host}\\$t->{shareName}'"
            . "$I_option -U '$conf->{SmbShareUserName}' -E -N -d 1"
            . " $conf->{SmbClientArgs}"
            . " -c 'tarmode full' -Tx -";
        $logMsg = "restore started for share $t->{shareName}";
    } else {
	#
	# Turn $conf->{BackupFilesOnly} and $conf->{BackupFilesExclude}
	# into a hash of arrays of files
	#
	$conf->{SmbShareName} = [ $conf->{SmbShareName} ]
			unless ref($conf->{SmbShareName}) eq "ARRAY";
	foreach my $param qw(BackupFilesOnly BackupFilesExclude) {
	    next if ( !defined($conf->{$param}) );
	    if ( ref($conf->{$param}) eq "ARRAY" ) {
		$conf->{$param} = {
			$conf->{SmbShareName}[0] => $conf->{$param}
		};
	    } elsif ( ref($conf->{$param}) eq "HASH" ) {
		# do nothing
	    } else {
		$conf->{$param} = {
			$conf->{SmbShareName}[0] => [ $conf->{$param} ]
		};
	    }
	}
        if ( defined($conf->{BackupFilesOnly}{$t->{shareName}}) ) {
            foreach my $file ( @{$conf->{BackupFilesOnly}{$t->{shareName}}} ) {
                $file =~ s/'/\\'/g;
                $fileList .= "'$file' ";
            }
        } elsif ( defined($conf->{BackupFilesExclude}{$t->{shareName}}) ) {
            foreach my $file ( @{$conf->{BackupFilesExclude}{$t->{shareName}}} )
            {
                $file =~ s/'/\\'/g;
                $fileList .= "'$file' ";
            }
	    #
	    # Allow simple wildcards in exclude list by specifying "r" option.
	    #
            $optX = "rX";
        }
        if ( $t->{type} eq "full" ) {
            $smbClientCmd =
                  "$conf->{SmbClientPath} '\\\\$t->{host}\\$t->{shareName}'"
                . "$I_option -U '$conf->{SmbShareUserName}' -E -N -d 1"
                . " $conf->{SmbClientArgs}"
                . " -c 'tarmode full'"
                . " -Tc$optX - $fileList";
            $logMsg = "full backup started for share $t->{shareName}";
        } else {
            my $timeStampFile = "$t->{outDir}/timeStamp.level0";
            open(LEV0, ">$timeStampFile") && close(LEV0);
            utime($t->{lastFull} - 3600, $t->{lastFull} - 3600, $timeStampFile);
            $smbClientCmd =
                  "$conf->{SmbClientPath} '\\\\$t->{host}\\$t->{shareName}'"
                . "$I_option -U '$conf->{SmbShareUserName}' -E -N -d 1"
                . " $conf->{SmbClientArgs}"
                . " -c 'tarmode full'"
                . " -TcN$optX $timeStampFile - $fileList";
            $logMsg = "incr backup started back to "
                        . $bpc->timeStamp($t->{lastFull} - 3600, 0)
                        . "for share $t->{shareName}";
        }
    }
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
        # exec smbclient.
        #
        exec($smbClientCmd);
        # should not be reached, but just in case...
        $t->{_errStr} = "Can't exec $conf->{SmbClientPath}";
        return;
    }
    $t->{XferLOG}->write(\"Running: $smbClientCmd\n");
    alarm($conf->{SmbClientTimeout});
    $t->{_errStr} = undef;
    return $logMsg;
}

sub readOutput
{
    my($t, $FDreadRef, $rout) = @_;
    my $conf = $t->{conf};

    if ( vec($rout, fileno($t->{pipeSMB}), 1) ) {
        my $mesg;
        if ( sysread($t->{pipeSMB}, $mesg, 8192) <= 0 ) {
            vec($$FDreadRef, fileno($t->{pipeSMB}), 1) = 0;
            close($t->{pipeSMB});
        } else {
            $t->{smbOut} .= $mesg;
        }
    }
    while ( $t->{smbOut} =~ /(.*?)[\n\r]+(.*)/s ) {
        $_ = $1;
        $t->{smbOut} = $2;
        $t->{XferLOG}->write(\"$_\n");
        #
        # refresh our inactivity alarm
        #
        alarm($conf->{SmbClientTimeout});
        $t->{lastOutputLine} = $_ if ( !/^$/ );
        #
        # This section is highly dependent on the version of smbclient.
        # If you upgrade Samba, make sure that these regexp are still valid.
        #
        if ( /^\s*(-?\d+) \(\s*\d+\.\d kb\/s\) (.*)$/ ) {
            my $sambaFileSize = $1;
            my $pcFileName    = $2;
            (my $fileName = $pcFileName) =~ s/\\/\//g;
            $sambaFileSize += 1024 * 1024 * 4096 if ( $sambaFileSize < 0 );
            $fileName =~ s/^\/*//;
            $t->{byteCnt} += $sambaFileSize;
            $t->{fileCnt}++;
        } elsif ( /restore tar file (.*) of size (\d+) bytes/ ) {
            $t->{byteCnt} += $2;
            $t->{fileCnt}++;
        } elsif ( /tar: dumped \d+ files/ ) {
            $t->{xferOK} = 1;
        } elsif ( /^tar: restored \d+ files/ ) {
            $t->{xferOK} = 1;
        } elsif ( /^read_socket_with_timeout: timeout read. /i ) {
            $t->{hostAbort} = 1;
        } elsif ( /^code 0 listing /
                    || /^code 0 opening /
                    || /^abandoning restore/i
                    || /^Error: Looping in FIND_NEXT/i ) {
            $t->{hostError} ||= $_;
        } elsif ( /smb: \\>/
                || /^added interface/i
                || /^tarmode is now/i
                || /^Total bytes written/i
                || /^Domain=/i
                || /^\([\d\.]* kb\/s\) \(average [\d\.]* kb\/s\)$/i
                || /^Getting files newer than/i
                || /^\s+directory \\/i
                || /^Output is \/dev\/null/i
                || /^Timezone is/i ) {
            # ignore these messages
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
                push(@{$t->{badFiles}}, "$t->{shareName}/$badFile");
            }
        }
    }
    return 1;
}

sub setSelectMask
{
    my($t, $FDreadRef) = @_;

    vec($$FDreadRef, fileno($t->{pipeSMB}), 1) = 1;
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

sub logMsg
{
    my($t, $msg) = @_;

    push(@{$t->{_logMsg}}, $msg);
}

sub logMsgGet
{
    my($t) = @_;

    return shift(@{$t->{_logMsg}});
}

#
# Returns a hash ref giving various status information about
# the transfer.
#
sub getStats
{
    my($t) = @_;

    return { map { $_ => $t->{$_} }
            qw(byteCnt fileCnt xferErrCnt xferBadShareCnt xferBadFileCnt
               xferOK hostAbort hostError lastOutputLine)
    };
}

sub getBadFiles
{
    my($t) = @_;

    return @{$t->{badFiles}};
}

1;
