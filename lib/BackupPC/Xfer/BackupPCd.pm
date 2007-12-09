#============================================================= -*-perl-*-
#
# BackupPC::Xfer::BackupPCd package
#
# DESCRIPTION
#
#   This library defines a BackupPC::Xfer::BackupPCd class for managing
#   the backuppcd-based transport of backup data from the client.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2006-2007  Craig Barratt
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
# Version 3.1.0, released 25 Nov 2007.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

package BackupPC::Xfer::BackupPCd;

use strict;

sub new
{
    my($class, $bpc, $args) = @_;

    $args ||= {};
    my $t = bless {
        bpc       => $bpc,
        conf      => { $bpc->Conf },
        host      => "",
        hostIP    => "",
        shareName => "",
        badFiles  => [],

	#
	# Various stats
	#
        byteCnt         => 0,
	fileCnt         => 0,
	xferErrCnt      => 0,
	xferBadShareCnt => 0,
	xferBadFileCnt  => 0,
	xferOK          => 0,

	#
	# User's args
	#
        %$args,
    }, $class;

    return $t;
}

sub args
{
    my($t, $args) = @_;

    foreach my $arg ( keys(%$args) ) {
	$t->{$arg} = $args->{$arg};
    }
}

sub useTar
{
    return 0;
}

sub start
{
    my($t) = @_;
    my $bpc = $t->{bpc};
    my $conf = $t->{conf};
    my(@fileList, $bpcdCmd, $bpcdArgs, $logMsg, $incrDate,
        $incrFlag, $restoreDir);

    #
    # We add a slash to the share name we pass to bpcd
    #
    ($t->{shareNameSlash} = "$t->{shareName}/") =~ s{//+$}{/};

    if ( $t->{type} eq "restore" ) {
        $bpcdCmd = $conf->{BackupPCdRestoreCmd};
	$restoreDir = "$t->{shareName}/$t->{pathHdrDest}";
	$restoreDir    =~ s{//+}{/}g;
        $logMsg = "restore started below directory $t->{shareName}"
		. " to host $t->{host}";
    } else {
        if ( $t->{type} eq "full" ) {
	    if ( $t->{partialNum} ) {
		$logMsg = "full backup started for directory $t->{shareName};"
		        . " updating partial $t->{partialNum}";
	    } else {
		$logMsg = "full backup started for directory $t->{shareName}";
	    }
            $incrFlag = 0;
        } else {
            #
            # TODO: fix this message - just refer to the backup, not time?
            #
            $incrDate = $bpc->timeStamp($t->{incrBaseTime} - 3600, 1);
            $logMsg = "incr backup started back to $incrDate"
                    . " (backup #$t->{incrBaseBkupNum}) for directory"
                    . " $t->{shareName}";
            $incrFlag = 1;
        }
	$bpcdCmd = $conf->{BackupPCdCmd};
    }

    #
    # Merge variables into $bpcdCmd
    #
    my $args = {
	host           => $t->{host},
	hostIP         => $t->{hostIP},
	client         => $t->{client},
	shareName      => $t->{shareName},
	shareNameSlash => $t->{shareNameSlash},
	restoreDir     => $restoreDir,
	bpcdPath       => $conf->{BackupPCdPath},
	sshPath        => $conf->{SshPath},
	topDir         => $bpc->TopDir(),
        poolDir        => $t->{compress} ? $bpc->{CPoolDir} : $bpc->{PoolDir},
        poolCompress   => $t->{compress} + 0,
	incrFlag       => $incrFlag,
    };
    $bpcdCmd = $bpc->cmdVarSubstitute($bpcdCmd, $args);

    $t->{bpcdCmd} = $bpcdCmd;

    delete($t->{_errStr});

    return $logMsg;
}

sub run
{
    my($t) = @_;
    my $bpc = $t->{bpc};
    my $conf = $t->{conf};
    my($remoteSend, $remoteDir, $remoteDirDaemon);
    my $error;
    my $stats;

    # NO: alarm($conf->{ClientTimeout});

    #
    # Run backupcd command
    #
    my $str = "Running: "
            . $t->{bpc}->execCmd2ShellCmd(@{$t->{bpcdCmd}})
            . "\n";
    $t->{XferLOG}->write(\$str);

    #
    #
    #
    
    $bpc->cmdSystemOrEvalLong($t->{bpcdCmd},
        sub {
            # write stdout to the XferLOG
            my($str) = @_;
            $t->{XferLOG}->write(\$str);
        }, 
        0,                  # also catch stderr
        $t->{pidHandler} 
    );

    #
    # TODO: generate sensible stats by parsing the output of
    # backuppcd.  Get error and fail status.
    #
    if ( !defined($error) && defined($stats) ) {
	$t->{xferOK} = 1;
    } else {
	$t->{xferOK} = 0;
    }
    $t->{xferErrCnt} = $stats->{errorCnt};
    $t->{byteCnt}    = $stats->{TotalFileSize};
    $t->{fileCnt}    = $stats->{TotalFileCnt};
    my $str = "Done: $t->{fileCnt} files, $t->{byteCnt} bytes\n";
    $t->{XferLOG}->write(\$str);

    $t->{hostError} = $error if ( defined($error) );

    if ( $t->{type} eq "restore" ) {
	return (
	    $t->{fileCnt},
	    $t->{byteCnt},
	    0,
	    0
	);
    } else {
	return (
	    0,
	    $stats->{ExistFileCnt},
	    $stats->{ExistFileSize},
	    $stats->{ExistFileCompSize},
	    $stats->{TotalFileCnt},
	    $stats->{TotalFileSize}
	);
    }
}

sub abort
{
    my($t, $reason) = @_;

    # TODO
    return 1;
}

sub errStr
{
    my($t) = @_;

    return $t->{_errStr};
}

sub xferPid
{
    my($t) = @_;

    return ();
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
