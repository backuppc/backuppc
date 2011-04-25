#============================================================= -*-perl-*-
#
# BackupPC::Attrib package
#
# DESCRIPTION
#
#   This library defines a BackupPC::Attrib class for maintaining
#   file attribute data.  One object instance stores attributes for
#   all the files in a single directory.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2001-2009  Craig Barratt
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
# Version 3.2.1, released 24 Apr 2011.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

package BackupPC::Attrib;

use strict;

use Carp;
use File::Path;
use BackupPC::FileZIO;
use Encode qw/from_to/;
require Exporter;

use vars qw( @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );

#
# These must match the file types used by tar
#
use constant BPC_FTYPE_FILE     => 0;
use constant BPC_FTYPE_HARDLINK => 1;
use constant BPC_FTYPE_SYMLINK  => 2;
use constant BPC_FTYPE_CHARDEV  => 3;
use constant BPC_FTYPE_BLOCKDEV => 4;
use constant BPC_FTYPE_DIR      => 5;
use constant BPC_FTYPE_FIFO     => 6;
use constant BPC_FTYPE_SOCKET   => 8;
use constant BPC_FTYPE_UNKNOWN  => 9;
use constant BPC_FTYPE_DELETED  => 10;

my @FILE_TYPES = qw(
                  BPC_FTYPE_FILE
		  BPC_FTYPE_HARDLINK
                  BPC_FTYPE_SYMLINK
                  BPC_FTYPE_CHARDEV
                  BPC_FTYPE_BLOCKDEV
                  BPC_FTYPE_DIR
                  BPC_FTYPE_FIFO
                  BPC_FTYPE_SOCKET
                  BPC_FTYPE_UNKNOWN
		  BPC_FTYPE_DELETED
             );

#
# The indexes in this list must match the numbers above
#
my @FileType2Text = (
    "file",
    "hardlink",
    "symlink",
    "chardev",
    "blockdev",
    "dir",
    "fifo",
    "?",
    "socket",
    "?",
    "deleted",
);

#
# Type of attribute file.  This is saved as a magic number at the
# start of the file.  Later there might be other types.
#
use constant BPC_ATTRIB_TYPE_UNIX => 0x17555555;

my @ATTRIB_TYPES = qw(
                  BPC_ATTRIB_TYPE_UNIX
             );

@ISA = qw(Exporter);

@EXPORT    = qw( );

@EXPORT_OK = (
                  @FILE_TYPES,
                  @ATTRIB_TYPES,
             );

%EXPORT_TAGS = (
    'all'    => [ @EXPORT_OK ],
);

#
# These fields are packed using the "w" pack format (variable length
# base 128). We use two values to store up to 64 bit size: sizeDiv4GB
# is size / 4GB and sizeMod4GB is size % 4GB (although perl can
# only represent around 2^52, the size of an IEEE double mantissa).
#
my @FldsUnixW = qw(type mode uid gid sizeDiv4GB sizeMod4GB);

#
# These fields are packed using the "N" pack format (32 bit integer)
#
my @FldsUnixN = qw(mtime);

sub new
{
    my($class, $options) = @_;

    my $self = bless {
	type  => BPC_ATTRIB_TYPE_UNIX,
	%$options,
	files => { },
    }, $class;
    return $self;
}

sub set
{
    my($a, $fileName, $attrib) = @_;

    if ( !defined($attrib) ) {
	delete($a->{files}{$fileName});
    } else {
	$a->{files}{$fileName} = $attrib;
    }
}

sub get
{
    my($a, $fileName) = @_;
    return $a->{files}{$fileName} if ( defined($fileName) );
    return $a->{files};
}

sub fileType2Text
{
    my($a, $type) = @_;
    return "?" if ( $type < 0 || $type >= @FileType2Text );
    return $FileType2Text[$type];
}

sub fileCount
{
    my($a) = @_;

    return scalar(keys(%{$a->{files}}));
}

sub delete
{
    my($a, $fileName) = @_;
    if ( defined($fileName) ) {
        delete($a->{files}{$fileName});
    } else {
        $a->{files} = { };
    }
}

#
# Given the directory, return the full path of the attribute file.
#
sub fileName
{
    my($a, $dir, $file) = @_;

    $file = "attrib" if ( !defined($file) );
    return "$dir/$file";
}

sub read
{
    my($a, $dir, $file) = @_;
    my($data);

    $file = $a->fileName($dir, $file);
    from_to($file, "utf8", $a->{charsetLegacy})
                    if ( $a->{charsetLegacy} ne "" );
    my $fd = BackupPC::FileZIO->open($file, 0, $a->{compress});
    if ( !$fd ) {
	$a->{_errStr} = "Can't open $file";
	return;
    }
    $fd->read(\$data, 65536);
    if ( length($data) < 4 ) {
	$a->{_errStr} = "Can't read magic number from $file";
	$fd->close;
	return;
    }
    (my $magic, $data) = unpack("N a*", $data);
    if ( $magic != $a->{type} ) {
	$a->{_errStr} = sprintf("Wrong magic number in %s"
                               . " (got 0x%x, expected 0x%x)",
                                   $file, $magic, $a->{type});
	$fd->close;
	return;
    }
    while ( length($data) ) {
	my $newData;
	if ( length($data) < 4 ) {
	    $fd->read(\$newData, 65536);
	    $data .= $newData;
	    if ( length($data) < 4 ) {
		$a->{_errStr} = "Can't read file length from $file";
		$fd->close;
		return;
	    }
	}
	(my $len, $data) = unpack("w a*", $data);
	if ( length($data) < $len ) {
	    $fd->read(\$newData, $len + 65536);
	    $data .= $newData;
	    if ( length($data) < $len ) {
		$a->{_errStr} = "Can't read file name (length $len)"
			   . " from $file";
		$fd->close;
		return;
	    }
	}
	(my $fileName, $data) = unpack("a$len a*", $data);

        from_to($fileName, $a->{charsetLegacy}, "utf8")
                        if ( $a->{charsetLegacy} ne "" );
	my $nFldsW = @FldsUnixW;
	my $nFldsN = @FldsUnixN;
	if ( length($data) < 5 * $nFldsW + 4 * $nFldsN ) {
	    $fd->read(\$newData, 65536);
	    $data .= $newData;
	}
        eval {
           (
               @{$a->{files}{$fileName}}{@FldsUnixW},
               @{$a->{files}{$fileName}}{@FldsUnixN},
               $data
            ) = unpack("w$nFldsW N$nFldsN a*", $data);
        };
        if ( $@ ) {
            $a->{_errStr} = "unpack: Can't read attributes for $fileName from $file ($@)";
            $fd->close;
            return;
        }
        if ( $a->{files}{$fileName}{$FldsUnixN[-1]} eq "" ) {
            $a->{_errStr} = "Can't read attributes for $fileName"
                          . " from $file";
            $fd->close;
            return;
        }
        #
        # Convert the two 32 bit size values into a single size
        #
        $a->{files}{$fileName}{size} = $a->{files}{$fileName}{sizeMod4GB}
                    + $a->{files}{$fileName}{sizeDiv4GB} * 4096 * 1024 * 1024;
    }
    $fd->close;
    $a->{_errStr} = "";
    return 1;
}

sub writeData
{
    my($a) = @_;
    my($data);

    $data = pack("N", BPC_ATTRIB_TYPE_UNIX);
    foreach my $file ( sort(keys(%{$a->{files}})) ) {
	my $nFldsW = @FldsUnixW;
	my $nFldsN = @FldsUnixN;
        #
        # Convert the size into two 32 bit size values.
        #
        $a->{files}{$file}{sizeMod4GB}
                    = $a->{files}{$file}{size} % (4096 * 1024 * 1024);
        $a->{files}{$file}{sizeDiv4GB}
                    = int($a->{files}{$file}{size} / (4096 * 1024 * 1024));
        eval {
            $data .= pack("w a* w$nFldsW N$nFldsN", length($file), $file,
                                   @{$a->{files}{$file}}{@FldsUnixW},
                                   @{$a->{files}{$file}}{@FldsUnixN},
                        );
        };
        if ( $@ ) {
            $a->{_errStr} = "Can't pack attr for $file: " . Dumper($a->{files}{$file});
        }
    }
    return $data;
}

sub write
{
    my($a, $dir, $file) = @_;
    my($data) = $a->writeData;

    $file = $a->fileName($dir, $file);
    if ( !-d $dir ) {
        eval { mkpath($dir, 0, 0777) };
        if ( $@ ) {
            $a->{_errStr} = "Can't create directory $dir";
            return;
        }
    }
    my $fd = BackupPC::FileZIO->open($file, 1, $a->{compress});
    if ( !$fd ) {
	$a->{_errStr} = "Can't open/write to $file";
	return;
    }
    if ( $fd->write(\$data) != length($data) ) {
	$a->{_errStr} = "Can't write to $file";
	$fd->close;
	return;
    }
    $fd->close;
    $a->{_errStr} = "";
    return 1;
}

sub merge
{
    my($a1, $a2) = @_;

    foreach my $f ( keys(%{$a2->{files}}) ) {
	next if ( defined($a1->{files}{$f}) );
	$a1->{files}{$f} = $a2->{files}{$f};
    }
}

sub errStr
{
    my($a) = @_;

    return $a->{_errStr};
}

1;
