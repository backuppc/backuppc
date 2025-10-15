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
#   Craig Barratt
#
# COPYRIGHT
#   Copyright (C) 2004-2025  Craig Barratt
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
# 15 Oct 2025, for release with
# Version 4.4.1.
#
# See https://backuppc.github.io/backuppc/
#
#========================================================================

package BackupPC::Storage;

use strict;
use BackupPC::Storage::Text;
use Data::Dumper;

# Configure Data::Dumper for consistent output with Perl 5.38+
$Data::Dumper::Useqq    = 1;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Terse    = 0;

sub new
{
    my $class  = shift;
    my($paths) = @_;
    my $flds   = {
        BackupFields => [qw(
            num type startTime endTime nFiles size nFilesExist sizeExist
            nFilesNew sizeNew xferErrs xferBadFile xferBadShare tarErrs
            compress sizeExistComp sizeNewComp noFill fillFromNum mangle
            xferMethod level charset version inodeLast keep share2path
            comment
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
# Also updates the directory mtime to reflect the backup
# finish time.
#
sub backupInfoWrite
{
    my($class, $pcDir, $bkupNum, $bkupInfo, $force) = @_;
    my $bkupFd;

    return if ( !$force && -f "$pcDir/$bkupNum/backupInfo" );
    my($dump) = Data::Dumper->new([$bkupInfo], [qw(*backupInfo)]);
    $dump->Indent(1);
    $dump->Sortkeys(1);
    $dump->Useqq(1);    # Ensure consistent quoting behavior for Perl 5.38+
    if ( open($bkupFd, ">", "$pcDir/$bkupNum/backupInfo") ) {
        print($bkupFd $dump->Dump);
        close($bkupFd);
    } else {
        print("backupInfoWrite: can't open/create $pcDir/$bkupNum/backupInfo\n");
    }
    utime($bkupInfo->{endTime}, $bkupInfo->{endTime}, "$pcDir/$bkupNum")
      if ( defined($bkupInfo->{endTime}) );
}

1;
