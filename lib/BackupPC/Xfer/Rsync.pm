#============================================================= -*-perl-*-
#
# BackupPC::Xfer::Rsync package
#
# DESCRIPTION
#
#   This library defines a BackupPC::Xfer::Rsync class for managing
#   the rsync-based transport of backup data from the client.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2002  Craig Barratt
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
# Version 1.6.0_CVS, released 10 Dec 2002.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

package BackupPC::Xfer::Rsync;

use strict;
use BackupPC::View;
use BackupPC::Xfer::RsyncFileIO;

use vars qw( $RsyncLibOK );

BEGIN {
    eval "use File::RsyncP;";
    if ( $@ ) {
        #
        # Rsync module doesn't exist.
        #
        $RsyncLibOK = 0;
    } else {
        $RsyncLibOK = 1;
    }
};

sub new
{
    my($class, $bpc, $args) = @_;

    return if ( !$RsyncLibOK );
    $args ||= {};
    my $t = bless {
        bpc       => $bpc,
        conf      => { $bpc->Conf },
        host      => "",
        hostIP    => "",
        shareName => "",
        badFiles  => [],
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
    my(@fileList, @rsyncClientCmd, $logMsg, $incrDate);

    if ( $t->{type} eq "restore" ) {
	# TODO
        #push(@rsyncClientCmd, split(/ +/, $c o n f->{RsyncClientRestoreCmd}));
        $logMsg = "restore not supported for $t->{shareName}";
	#
	# restores are considered to work unless we see they fail
	# (opposite to backups...)
	#
	$t->{xferOK} = 1;
    } else {
	#
	# Turn $conf->{BackupFilesOnly} and $conf->{BackupFilesExclude}
	# into a hash of arrays of files.  NOT IMPLEMENTED YET.
	#
	$conf->{RsyncShareName} = [ $conf->{RsyncShareName} ]
			unless ref($conf->{RsyncShareName}) eq "ARRAY";
	foreach my $param qw(BackupFilesOnly BackupFilesExclude) {
	    next if ( !defined($conf->{$param}) );
	    if ( ref($conf->{$param}) eq "ARRAY" ) {
		$conf->{$param} = {
			$conf->{RsyncShareName}[0] => $conf->{$param}
		};
	    } elsif ( ref($conf->{$param}) eq "HASH" ) {
		# do nothing
	    } else {
		$conf->{$param} = {
			$conf->{RsyncShareName}[0] => [ $conf->{$param} ]
		};
	    }
	}
        if ( defined($conf->{BackupFilesExclude}{$t->{shareName}}) ) {
            foreach my $file ( @{$conf->{BackupFilesExclude}{$t->{shareName}}} )
            {
                push(@fileList, "--exclude=$file");
            }
        }
        if ( defined($conf->{BackupFilesOnly}{$t->{shareName}}) ) {
            foreach my $file ( @{$conf->{BackupFilesOnly}{$t->{shareName}}} ) {
                push(@fileList, $file);
            }
        } else {
	    push(@fileList, ".");
        }
	push(@rsyncClientCmd, split(/ +/, $conf->{RsyncClientCmd}));
        if ( $t->{type} eq "full" ) {
            $logMsg = "full backup started for directory $t->{shareName}";
        } else {
            $incrDate = $bpc->timeStampISO($t->{lastFull} - 3600, 1);
            $logMsg = "incr backup started back to $incrDate for directory"
                    . " $t->{shareName}";
        }
	$t->{xferOK} = 0;
    }
    #
    # Merge variables into @rsyncClientCmd
    #
    my $vars = {
        host      => $t->{host},
        hostIP    => $t->{hostIP},
        shareName => $t->{shareName},
        rsyncPath => $conf->{RsyncClientPath},
        sshPath   => $conf->{SshPath},
    };
    my @cmd = @rsyncClientCmd;
    @rsyncClientCmd = ();
    foreach my $arg ( @cmd ) {
	next if ( $arg =~ /^\s*$/ );
	if ( $arg =~ /^\$fileList(\+?)/ ) {
	    my $esc = $1 eq "+";
	    foreach $arg ( @fileList ) {
		$arg = $bpc->shellEscape($arg) if ( $esc );
		push(@rsyncClientCmd, $arg);
	    }
	} elsif ( $arg =~ /^\$argList(\+?)/ ) {
	    my $esc = $1 eq "+";
	    foreach $arg ( (@{$conf->{RsyncArgs}},
			    @{$conf->{RsyncClientArgs}}) ) {
		$arg = $bpc->shellEscape($arg) if ( $esc );
		push(@rsyncClientCmd, $arg);
	    }
	} else {
	    $arg =~ s{\$(\w+)(\+?)}{
		defined($vars->{$1})
		    ? ($2 eq "+" ? $bpc->shellEscape($vars->{$1}) : $vars->{$1})
		    : "\$$1"
	    }eg;
	    push(@rsyncClientCmd, $arg);
	}
    }

    #
    # A full dump is implemented with --ignore-times: this causes all
    # files to be checksummed, even if the attributes are the same.
    # That way all the file contents are checked, but you get all
    # the efficiencies of rsync: only files deltas need to be
    # transferred, even though it is a full dump.
    #
    my $rsyncArgs = $conf->{RsyncArgs};
    $rsyncArgs = [@$rsyncArgs, "--ignore-times"] if ( $t->{type} eq "full" );

    #
    # Create the Rsync object, and tell it to use our own File::RsyncP::FileIO
    # module, which handles all the special BackupPC file storage
    # (compression, mangling, hardlinks, special files, attributes etc).
    #
    $t->{rs} = File::RsyncP->new({
	logLevel   => $conf->{RsyncLogLevel},
	rsyncCmd   => \@rsyncClientCmd,
	rsyncArgs  => $rsyncArgs,
	logHandler => sub {
			  my($str) = @_;
			  $str .= "\n";
			  $t->{XferLOG}->write(\$str);
		      },
	fio        => BackupPC::Xfer::RsyncFileIO->new({
			    xfer       => $t,
			    bpc        => $t->{bpc},
			    conf       => $t->{conf},
			    host       => $t->{host},
			    backups    => $t->{backups},
			    logLevel   => $conf->{RsyncLogLevel},
		      }),
    });

    # TODO: alarm($conf->{SmbClientTimeout});
    delete($t->{_errStr});

    return $logMsg;
}

sub run
{
    my($t) = @_;
    my $rs = $t->{rs};
    my $conf = $t->{conf};

    if ( $t->{XferMethod} eq "rsync" ) {
	#
	# Run rsync command
	#
	$rs->remoteStart(1, $t->{shareName});
    } else {
	#
	# Connect to the rsync server
	#
	if ( defined(my $err = $rs->serverConnect($t->{hostIP},
					     $conf->{RsyncdClientPort})) ) {
	    $t->{hostError} = $err;
	    return;
	}
	if ( defined(my $err = $rs->serverService($t->{shareName},
						 "craig", "xyz123", 0)) ) {
	    $t->{hostError} = $err;
	    return;
	}
	$rs->serverStart(1, ".");
    }
    my $error = $rs->go($t->{shareName});
    $rs->serverClose();

    #
    # TODO: generate sensible stats
    # 
    # $rs->{stats}{totalWritten}
    # $rs->{stats}{totalSize}
    #
    # qw(byteCnt fileCnt xferErrCnt xferBadShareCnt xferBadFileCnt
    #           xferOK hostAbort hostError lastOutputLine)
    #
    my $stats = $rs->statsFinal;
    if ( !defined($error) && defined($stats) ) {
	$t->{xferOK}  = 1;
    } else {
	$t->{xferOK}  = 0;
    }
    $t->{byteCnt} = $stats->{childStats}{TotalFileSize}
		  + $stats->{parentStats}{TotalFileSize};
    $t->{fileCnt} = $stats->{childStats}{TotalFileCnt}
		  + $stats->{parentStats}{TotalFileCnt};
    #
    # TODO: get error count, and call fio to get stats...
    #
    $t->{hostError} = $error if ( defined($error) );

    return (
	0,
	$stats->{childStats}{ExistFileCnt}
	    + $stats->{parentStats}{ExistFileCnt},
	$stats->{childStats}{ExistFileSize}
	    + $stats->{parentStats}{ExistFileSize},
	$stats->{childStats}{ExistFileCompSize}
	    + $stats->{parentStats}{ExistFileCompSize},
	$stats->{childStats}{TotalFileCnt}
	    + $stats->{parentStats}{TotalFileCnt},
	$stats->{childStats}{TotalFileSize}
	    + $stats->{parentStats}{TotalFileSize},
    );
}

#        alarm($conf->{SmbClientTimeout});

sub setSelectMask
{
    my($t, $FDreadRef) = @_;
}

sub errStr
{
    my($t) = @_;

    return $t->{_errStr};
}

sub xferPid
{
    my($t) = @_;

    return -1;
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
