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

package BackupPC::Xfer::Archive;

use strict;
use base qw(BackupPC::Xfer::Protocol);

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

1;
