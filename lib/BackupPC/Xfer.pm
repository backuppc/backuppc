#============================================================= -*-perl-*-
#
# BackupPC::Xfer package
#
# DESCRIPTION
#
#   This library defines a Factory for invoking transfer protocols in
#   a polymorphic manner.  This libary allows for easier expansion of
#   supported protocols.
#
# AUTHOR
#   Paul Mantz  <pcmantz@zmanda.com>
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


package BackupPC::Xfer;

use strict;
use Encode qw/from_to encode/;

use BackupPC::Xfer::Archive;
use BackupPC::Xfer::Ftp;
use BackupPC::Xfer::Protocol;
use BackupPC::Xfer::Rsync;
use BackupPC::Xfer::Smb;
use BackupPC::Xfer::Tar;

use vars qw( $errStr );

sub create
{
    my($protocol, $bpc, $args) = @_;
    my $xfer;

    $errStr = undef;

    if ( $protocol eq 'archive' ) {

        $xfer = BackupPC::Xfer::Archive->new( $bpc, $args );
        $errStr = BackupPC::Xfer::Archive::errStr() if ( !defined($xfer) );
        return $xfer;

    } elsif ( $protocol eq 'ftp' ) {

        #$xfer = BackupPC::Xfer::Ftp->new( $bpc, $args );
        #$errStr = BackupPC::Xfer::Ftp::errStr() if ( !defined($xfer) );

        $errStr = "FTP not implemented in 4.x";
        return $xfer;

    } elsif ( $protocol eq 'rsync' || $protocol eq 'rsyncd' ) {

        $xfer = BackupPC::Xfer::Rsync->new( $bpc, $args );
        $errStr = BackupPC::Xfer::Rsync::errStr() if ( !defined($xfer) );
        return $xfer;

    } elsif ( $protocol eq 'smb' ) {

        $xfer = BackupPC::Xfer::Smb->new( $bpc, $args );
        $errStr = BackupPC::Xfer::Smb::errStr() if ( !defined($xfer) );
        return $xfer;

    } elsif ( $protocol eq 'tar' ) {

        $xfer = BackupPC::Xfer::Tar->new( $bpc, $args );
        $errStr = BackupPC::Xfer::Tar::errStr() if ( !defined($xfer) );
        return $xfer;

    } elsif ( $protocol eq 'protocol') {

        $xfer = BackupPC::Xfer::Protocol->new( $bpc, $args );
        $errStr = BackupPC::Xfer::Protocol::errStr() if ( !defined($xfer) );
        return $xfer;

    } else {

	$xfer = undef;
        $errStr = "$protocol is not a supported protocol.";
	return $xfer;
    }
}

#
# getShareNames() loads the correct shares dependent on the
# transfer type.
#
sub getShareNames
{
    my($conf) = @_;
    my $ShareNames;

    if ( $conf->{XferMethod} eq "tar" ) {
        $ShareNames = $conf->{TarShareName};

    } elsif ( $conf->{XferMethod} eq "ftp" ) {
        $ShareNames = $conf->{FtpShareName};

    } elsif ( $conf->{XferMethod} eq "rsync" || $conf->{XferMethod} eq "rsyncd" ) {
        $ShareNames = $conf->{RsyncShareName};

    } elsif ( $conf->{XferMethod} eq "smb" ) {
        $ShareNames = $conf->{SmbShareName};

    } else {
        #
        # default to smb shares
        #
        $ShareNames = $conf->{SmbShareName};
    }

    $ShareNames = [$ShareNames] unless ref($ShareNames) eq "ARRAY";
    return $ShareNames;
}


sub getRestoreCmd
{
    my($conf) = @_;
    my $restoreCmd;

    if ( $conf->{XferMethod} eq "archive" ) {
        $restoreCmd = undef;

    } elsif ( $conf->{XferMethod} eq "ftp" ) {
        $restoreCmd = undef;

    } elsif ( $conf->{XferMethod} eq "rsync"
           || $conf->{XferMethod} eq "rsyncd" ) {
        $restoreCmd = $conf->{RsyncRestoreArgs};

    } elsif ( $conf->{XferMethod} eq "tar" ) {
        $restoreCmd = $conf->{TarClientRestoreCmd};

    } elsif ( $conf->{XferMethod} eq "smb" ) {
        $restoreCmd = $conf->{SmbClientRestoreCmd};

    } else {

        #
        # protocol unrecognized
        #
        $restoreCmd = undef;
    }
    return $restoreCmd;
}


sub restoreEnabled
{
    my($conf) = @_;
    my $restoreCmd;

    if ( $conf->{XferMethod} eq "archive" ) {
        return;

    } elsif ( $conf->{XferMethod} eq "ftp" ) {
        return;

    } elsif ( $conf->{XferMethod} eq "rsync"
           || $conf->{XferMethod} eq "rsyncd"
           || $conf->{XferMethod} eq "tar"
           || $conf->{XferMethod} eq "smb" ) {
        $restoreCmd = getRestoreCmd( $conf );
        return !!(
            ref $restoreCmd eq "ARRAY"
            ? @$restoreCmd
            : $restoreCmd ne ""
        );

    } else {
        return;
    }
}


sub errStr
{
    return $errStr;
}

1;
