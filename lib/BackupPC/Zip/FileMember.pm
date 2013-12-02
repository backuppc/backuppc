#============================================================= -*-perl-*-
#
# BackupPC::Zip::FileMember
#
# DESCRIPTION
#
#   This library defines a BackupPC::Zip::FileMember class that subclass
#   the Archive::Zip::FileMember class.  This allows BackupPC_zipCreate
#   to create zip files by reading and uncomressing BackupPC's pool
#   files on the fly.  This avoids the need to uncompress the files
#   ahead of time and either store them in memory or on disk.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#   Based on Archive::Zip::FileMember, Copyright (c) 2000 Ned Konz.
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

package BackupPC::Zip::FileMember;
use vars qw( @ISA );
@ISA = qw ( Archive::Zip::FileMember );

BEGIN { use Archive::Zip qw( :CONSTANTS :ERROR_CODES :UTILITY_METHODS ) }

# Given a file name, set up for eventual writing.
sub newFromFileNamed    # BackupPC::Zip::FileMember
{
    my $class    = shift;
    my $fileName = shift;
    my $newName  = shift || $fileName;
    my $size     = shift;
    my $compress = shift;
    return undef unless ( stat($fileName) && -r _ && !-d _ );
    my $self = $class->new(@_);
    $self->fileName($newName);
    $self->{'externalFileName'}  = $fileName;
    $self->{'compressionMethod'} = COMPRESSION_STORED;
    $self->{'compressedSize'} = $self->{'uncompressedSize'} = $size;
    $self->{'fileCompressLevel'} = $compress;
    $self->desiredCompressionMethod( ( $self->compressedSize() > 0 ) 
	    ? COMPRESSION_DEFLATED
	    : COMPRESSION_STORED );
    $self->isTextFile( -T _ );
    return $self;
}

sub rewindData		# BackupPC::Zip::FileMember
{
    my $self = shift;

    my $status = $self->SUPER::rewindData(@_);
    return $status unless $status == AZ_OK;

    return AZ_IO_ERROR unless $self->fh();
    $self->fh()->rewind();
    return AZ_OK;
}

sub fh			# BackupPC::Zip::FileMember
{
    my $self = shift;
    $self->_openFile() if !defined( $self->{'bpcfh'} );
    return $self->{'bpcfh'};
}

# opens my file handle from my file name
sub _openFile		# BackupPC::Zip::FileMember
{
    my $self = shift;
    my ( $fh ) = BackupPC::XS::FileZIO::open($self->externalFileName(), 0,
					 $self->{'fileCompressLevel'});
    if ( !defined($fh) )
    {
        _ioError( "Can't open", $self->externalFileName() );
        return undef;
    }
    $self->{'bpcfh'} = $fh;
    return $fh;
}

# Closes my file handle
sub _closeFile		# BackupPC::Zip::FileMember
{
    my $self = shift;
    $self->{'bpcfh'}->close() if ( defined($self->{'bpcfh'}) );
    $self->{'bpcfh'} = undef;
}

# Make sure I close my file handle
sub endRead		# BackupPC::Zip::FileMember
{
    my $self = shift;
    $self->_closeFile();
    return $self->SUPER::endRead(@_);
}

# Return bytes read. Note that first parameter is a ref to a buffer.
# my $data;
# my ($bytesRead, $status) = $self->readRawChunk( \$data, $chunkSize );
sub _readRawChunk	# BackupPC::Zip::FileMember
{
    my ( $self, $dataRef, $chunkSize ) = @_;
    return ( 0, AZ_OK ) unless $chunkSize;
    my $bytesRead = $self->fh()->read( $dataRef, $chunkSize )
	    or return ( 0, _ioError("reading data") );
    return ( $bytesRead, AZ_OK );
}

sub extractToFileNamed	# BackupPC::Zip::FileMember
{
    die("BackupPC::Zip::FileMember::extractToFileNamed not supported\n");
}

#
# There is a bug in Archive::Zip 1.30 that causes BackupPC_zipCreate
# to fail when compression is on and it is writing to an unseekable
# output file (eg: pipe or socket); see:
#
#    https://rt.cpan.org/Public/Bug/Display.html?id=54827
#
# We overload the bitFlag function here to avoid the bug.
#
sub bitFlag
{
    my $self = shift;

    return $self->{bitFlag};
}
