#============================================================= -*-perl-*-
#
# BackupPC::FileZIO package
#
# DESCRIPTION
#
#   This library defines a BackupPC::FileZIO class for doing
#   compressed or normal file I/O.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2001-2015  Craig Barratt
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
# Version 3.3.1, released 11 Jan 2015.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

package BackupPC::FileZIO;

use strict;

use vars qw( $CompZlibOK );
use Carp;
use File::Path;
use File::Copy;
use Encode;

#
# For compressed files we have a to careful about running out of memory
# when we inflate a deflated file. For example, if a 500MB file of all
# zero-bytes is compressed, it will only occupy a few tens of kbytes. If
# we read the compressed file in decent-size chunks, a single inflate
# will try to allocate 500MB. Not a good idea.
#
# Instead, we compress the file in chunks of $CompMaxWrite. If a
# deflated chunk produces less than $CompMaxRead bytes, then we flush
# and continue. This adds a few bytes to the compressed output file, but
# only in extreme cases where the compression ratio is very close to
# 100%. The result is that, provided we read the compressed file in
# chunks of $CompMaxRead or less, the biggest inflated data will be
# $CompMaxWrite.
#
my $CompMaxRead  = 131072;          # 128K
my $CompMaxWrite = 6291456;         # 6MB

#
# We maintain a write buffer for small writes for both compressed and
# uncompressed files.  This is the size of the write buffer.
#
my $WriteBufSize = 65536;

BEGIN {
    eval "use Compress::Zlib;";
    if ( $@ ) {
        #
        # Compress::Zlib doesn't exist.  Define some dummy constant
        # subs so that the code below doesn't barf.
        #
        eval {
            sub Z_OK         { return 0; }
            sub Z_STREAM_END { return 1; }
        };
        $CompZlibOK = 0;
    } else {
        $CompZlibOK = 1;
    }
};

sub open
{
    my($class, $fileName, $write, $compLevel) = @_;
    local(*FH);
    my($fh);

    if ( ref(\$fileName) eq "GLOB" ) {
        $fh = $fileName;
    } else {
        if ( $write ) {
            open(FH, ">", $fileName) || return;
        } else {
            open(FH, "<", $fileName) || return;
        }
	binmode(FH);
        $fh = *FH;
    }
    $compLevel  = 0 if ( !$CompZlibOK );
    my $self = bless {
        fh           => $fh,
        name         => $fileName,
        write        => $write,
        writeZeroCnt => 0,
        compress     => $compLevel,
    }, $class;
    if ( $compLevel ) {
        if ( $write ) {
            $self->{deflate} = $self->myDeflateInit;
        } else {
            $self->{inflate} = $self->myInflateInit;
            $self->{inflateStart} = 1;
        }
    }
    return $self;
}

sub compOk
{
    return $CompZlibOK;
}

#
# Request utf8 strings with readLine interface
#
sub utf8
{
    my($self, $mode) = @_;

    $self->{utf8} = $mode;
}

sub myDeflateInit
{
    my $self = shift;

    return deflateInit(
                -Bufsize => 65536,
                -Level   => $self->{compress},
           );
}

sub myInflateInit
{
    my $self = shift;

    return inflateInit(
                -Bufsize => 65536,
           );
}

sub read
{
    my($self, $dataRef, $nRead) = @_;
    my($n);

    return if ( $self->{write} );
    return sysread($self->{fh}, $$dataRef, $nRead) if ( !$self->{compress} );
    while ( !$self->{eof} && $nRead > length($self->{dataOut}) ) {
        if ( !length($self->{dataIn}) ) {
            $n = sysread($self->{fh}, $self->{dataIn}, $CompMaxRead);
            return $n if ( $n < 0 );
            $self->{eof} = 1 if ( $n == 0 );
        }
        if ( $self->{inflateStart} && $self->{dataIn} ne "" ) {
            my $chr = substr($self->{dataIn}, 0, 1);

            $self->{inflateStart} = 0;
            if ( $chr eq chr(0xd6) || $chr eq chr(0xd7) ) {
                #
                # Flag 0xd6 or 0xd7 means this is a compressed file with
                # appended md4 block checksums for rsync.  Change
                # the first byte back to 0x78 and proceed.
                #
                ##print("Got 0xd6/0xd7 block: normal\n");
                substr($self->{dataIn}, 0, 1) = chr(0x78);
            } elsif ( $chr eq chr(0xb3) ) {
                #
                # Flag 0xb3 means this is the start of the rsync
                # block checksums, so consider this as EOF for
                # the compressed file.  Also seek the file so
                # it is positioned at the 0xb3.
                #
                sysseek($self->{fh}, -length($self->{dataIn}), 1);
                $self->{eof} = 1;
                $self->{dataIn} = "";
                ##print("Got 0xb3 block: considering eof\n");
                last;
            } else {
                #
                # normal case: nothing to do
                #
            }
        }
        my($data, $err) = $self->{inflate}->inflate($self->{dataIn});
        $self->{dataOut} .= $data;
        if ( $err == Z_STREAM_END ) {
            #print("R");
            $self->{inflate} = $self->myInflateInit;
            $self->{inflateStart} = 1;
        } elsif ( $err != Z_OK ) {
            $$dataRef = "";
            return -1;
        }
    }
    if ( $nRead >= length($self->{dataOut}) ) {
        $n = length($self->{dataOut});
        $$dataRef = $self->{dataOut};
        $self->{dataOut} = '';
        return $n;
    } else {
        $$dataRef = substr($self->{dataOut}, 0, $nRead);
        $self->{dataOut} = substr($self->{dataOut}, $nRead);
        return $nRead;
    }
}

#
# Provide a line-at-a-time interface.  This splits and buffers the
# lines, you cannot mix calls to read() and readLine().
#
sub readLine
{
    my($self) = @_;
    my $str;

    $self->{readLineBuf} = [] if ( !defined($self->{readLineBuf}) );
    while ( !@{$self->{readLineBuf}} ) {
        $self->read(\$str, $CompMaxRead);
        if ( $str eq "" ) {
            $str = $self->{readLineFrag};
            $self->{readLineFrag} = "";
            $str = decode_utf8($str) if ( $self->{utf8} );
            return $str;
        }
        @{$self->{readLineBuf}} = split(/\n/, $self->{readLineFrag} . $str);
        if ( substr($str, -1, 1) ne "\n" ) {
            $self->{readLineFrag} = pop(@{$self->{readLineBuf}});
        } else {
            $self->{readLineFrag} = "";
        }
    }
    $str = shift(@{$self->{readLineBuf}}) . "\n";
    if ( $self->{utf8} ) {
        my $strUtf8 = decode_utf8($str, 0);
        $strUtf8 = $str if ( length($strUtf8) == 0 );
        return $strUtf8;
    }
    return $str;
}

sub rewind
{
    my($self) = @_;

    return if ( $self->{write} );
    return sysseek($self->{fh}, 0, 0) if ( !$self->{compress} );
    $self->{dataOut} = '';
    $self->{dataIn}  = '';
    $self->{eof}     = 0;
    $self->{inflate} = $self->myInflateInit;
    $self->{inflateStart} = 1;
    return sysseek($self->{fh}, 0, 0);
}

sub writeBuffered
{
    my $self = shift;
    my($data, $force) = @_;

    #
    # Buffer small writes using a buffer size of up to $WriteBufSize.
    #
    if ( $force || length($self->{writeBuf}) + length($data) > $WriteBufSize ) {
        if ( length($self->{writeBuf}) ) {
            my $wrData = $self->{writeBuf} . $data;
            return -1 if ( syswrite($self->{fh}, $wrData) != length($wrData) );
            $self->{writeBuf} = undef;
        } else {
            return if ( length($data) == 0 );
            return -1 if ( syswrite($self->{fh}, $data) != length($data) );
        }
    } else {
        $self->{writeBuf} .= $data;
    }
    return 0;
}

sub write
{
    my($self, $dataRef) = @_;
    my $n = length($$dataRef);

    return if ( !$self->{write} );
    print(STDERR $$dataRef) if ( $self->{writeTeeStderr} );
    return 0 if ( $n == 0 );
    if ( !$self->{compress} ) {
        #
        # If smbclient gets a read error on the client (due to a file lock)
        # it will write a dummy file of zeros.  We detect this so we can
        # store the file efficiently as a sparse file.  writeZeroCnt is
        # the number of consecutive 0 bytes at the start of the file.
        #
        my $skip = 0;
        if ( $self->{writeZeroCnt} >= 0 && $$dataRef =~ /^(\0+)/s ) {
            $skip = length($1);
            $self->{writeZeroCnt} += $skip;
            return $n if ( $skip == $n );
        }
        #
        # We now have some non-zero bytes, so time to seek to the right
        # place and turn off zero-byte detection.
        #
        if ( $self->{writeZeroCnt} > 0 ) {
            sysseek($self->{fh}, $self->{writeZeroCnt}, 0);
            $self->{writeZeroCnt} = -1;
        } elsif ( $self->{writeZeroCnt} == 0 ) {
            $self->{writeZeroCnt} = -1;
        }
        return -1 if ( $self->writeBuffered(substr($$dataRef, $skip)) < 0 );
        return $n;
    }
    for ( my $i = 0 ; $i < $n ; $i += $CompMaxWrite ) {
        my $dataIn  = substr($$dataRef, $i, $CompMaxWrite);
        my $dataOut = $self->{deflate}->deflate($dataIn);
        return -1 if ( $self->writeBuffered($dataOut) < 0 );
        $self->{deflateIn}  += length($dataIn);
        $self->{deflateOut} += length($dataOut);
        if ( $self->{deflateIn} >= $CompMaxWrite ) {
            if ( $self->{deflateOut} < $CompMaxRead ) {
                #
                # Compression is too high: to avoid huge memory requirements
                # on read we need to flush().
                #
                $dataOut = $self->{deflate}->flush();
                #print("F");
                $self->{deflate} = $self->myDeflateInit;
                return -1 if ( $self->writeBuffered($dataOut) < 0 );
            }
            $self->{deflateIn} = $self->{deflateOut} = 0;
        }
    }
    return $n;
}

sub name
{
    my($self) = @_;

    return $self->{name};
}

sub writeTeeStderr
{
    my($self, $param) = @_;

    $self->{writeTeeStderr} = $param if ( defined($param) );
    return $self->{writeTeeStderr};
}

sub close
{
    my($self) = @_;
    my $err = 0;

    if ( $self->{write} && $self->{compress} ) {
        my $data = $self->{deflate}->flush();
        $err = 1 if ( $self->writeBuffered($data) < 0 );
    } elsif ( $self->{write} && !$self->{compress} ) {
        if ( $self->{writeZeroCnt} > 0 ) {
            #
            # We got a file of all zero bytes.  Write a single zero byte
            # at the end of the file.  On most file systems this is an
            # efficient way to store the file.
            #
            $err = 1 if ( sysseek($self->{fh}, $self->{writeZeroCnt} - 1, 0)
                                            != $self->{writeZeroCnt} - 1
                        || syswrite($self->{fh}, "\0") != 1 );
        }
    }
    $self->writeBuffered(undef, 1);
    close($self->{fh});
    return $err ? -1 : 0;
}

#
# If $compress is >0, copy and compress $srcFile putting the output
# in $destFileZ.  Otherwise, copy the file to $destFileNoZ, or do
# nothing if $destFileNoZ is undef.  Finally, if rename is set, then
# the source file is removed.
#
sub compressCopy
{
    my($class, $srcFile, $destFileZ, $destFileNoZ, $compress, $rmSrc) = @_;
    my(@s) = stat($srcFile);
    my $atime = $s[8] =~ /(.*)/ && $1;
    my $mtime = $s[9] =~ /(.*)/ && $1;
    if ( $CompZlibOK && $compress > 0 ) {
        my $fh = BackupPC::FileZIO->open($destFileZ, 1, $compress);
        my $data;
        if ( defined($fh) && open(LOG, "<", $srcFile) ) {
	    binmode(LOG);
            while ( sysread(LOG, $data, 65536) > 0 ) {
                $fh->write(\$data);
            }
            close(LOG);
            $fh->close();
            unlink($srcFile) if ( $rmSrc );
            utime($atime, $mtime, $destFileZ);
            return 1;
        } else {
            $fh->close() if ( defined($fh) );
            return 0;
        }
    }
    return 0 if ( !defined($destFileNoZ) );
    if ( $rmSrc ) {
        return rename($srcFile, $destFileNoZ);
    } else {
        return 0 if ( !copy($srcFile, $destFileNoZ) );
        utime($atime, $mtime, $destFileNoZ);
    }
}

1;
