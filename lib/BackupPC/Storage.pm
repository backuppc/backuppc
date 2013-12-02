#============================================================= -*-perl-*-
#
# BackupPC::Storage package
#
# DESCRIPTION
#
#   This library defines a BackupPC::Storage class for reading/writing
#   data like config, host info, backup and restore info.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2004-2013  Craig Barratt
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

package BackupPC::Storage;

use strict;
use BackupPC::Storage::Text;
use Data::Dumper;

sub new
{
    my $class = shift;
    my($paths) = @_;
    my $flds = {
        BackupFields => [qw(
                    num type startTime endTime
                    nFiles size nFilesExist sizeExist nFilesNew sizeNew
                    xferErrs xferBadFile xferBadShare tarErrs
                    compress sizeExistComp sizeNewComp
                    noFill fillFromNum mangle xferMethod level
                    charset version inodeLast
                )],
        RestoreFields => [qw(
                    num startTime endTime result errorMsg nFiles size
                    tarCreateErrs xferErrs
                )],
        ArchiveFields => [qw(
                    num startTime endTime result errorMsg
                )],
    };

    return BackupPC::Storage::Text->new($flds, $paths, @_);
}

#
# Writes per-backup information into the pc/nnn/backupInfo
# file to allow later recovery of the pc/backups file in
# cases when it is corrupted.
#
sub backupInfoWrite
{
    my($class, $pcDir, $bkupNum, $bkupInfo, $force) = @_;
    my $bkupFd;

    return if ( !$force && -f "$pcDir/$bkupNum/backupInfo" );
    my($dump) = Data::Dumper->new(
             [   $bkupInfo],
             [qw(*backupInfo)]);
    $dump->Indent(1);
    if ( open($bkupFd, ">", "$pcDir/$bkupNum/backupInfo") ) {
        print($bkupFd $dump->Dump);
        close($bkupFd);
    } else {
        print("backupInfoWrite: can't open/create $pcDir/$bkupNum/backupInfo\n");
    }
}

1;
