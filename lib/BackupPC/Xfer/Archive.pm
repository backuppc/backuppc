#============================================================= -*-perl-*-
#
# BackupPC::Xfer::Archive package
#
# DESCRIPTION
#
#   This library defines a BackupPC::Xfer::Archive class for managing
#   archives to media.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2001-2007  Craig Barratt
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

package BackupPC::Xfer::Archive;

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
        pipeRH    => undef,
        pipeWH    => undef,
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

sub useArchive
{
    return 1;
}

sub start
{
    return "Archive Started";
}

sub run
{
    my($t) = @_;
    my $bpc = $t->{bpc};
    my $conf = $t->{conf};
    
    my(@HostList, @BackupList, $archiveClientCmd, $archiveClientCmd2, $logMsg);

    $archiveClientCmd = $conf->{ArchiveClientCmd};
    $t->{xferOK} = 1;
    @HostList = $t->{HostList};
    @BackupList = $t->{BackupList};
    my $i = 0;
    my $tarCreatePath = "$conf->{InstallDir}/bin/BackupPC_tarCreate";
    while (${@HostList[0]}[$i]) {
        #
        #   Merge variables into @archiveClientCmd
        #
        my $errStr;
        my $cmdargs = {
            archiveloc    => $t->{archiveloc},
            parfile       => $t->{parfile},
            compression   => $t->{compression},
            compext       => $t->{compext},
            splitsize     => $t->{splitsize},
            host          => ${@HostList[0]}[$i],
            backupnumber  => ${@BackupList[0]}[$i],
            Installdir    => $conf->{InstallDir},
            tarCreatePath => $tarCreatePath,
            splitpath     => $conf->{SplitPath},
            parpath       => $conf->{ParPath},
        };

        $archiveClientCmd2 = $bpc->cmdVarSubstitute($archiveClientCmd,
                                                    $cmdargs);
        $t->{XferLOG}->write(\"Executing: @$archiveClientCmd2\n");

        $bpc->cmdSystemOrEvalLong($archiveClientCmd2,
            sub {
                $errStr = $_[0];
                $t->{XferLOG}->write(\$_[0]);
            }, 0, $t->{pidHandler});
        if ( $? ) {
            ($t->{_errStr} = $errStr) =~ s/[\n\r]+//;
            return;
        }
        $i++;
    }
    $t->{XferLOG}->write(\"Completed Archive\n");
    return "Completed Archive";
}

sub errStr
{
    my($t) = @_;

    return $t->{_errStr};
}

sub abort
{
}

sub xferPid
{
    my($t) = @_;

    return ($t->{xferPid});
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

1;
