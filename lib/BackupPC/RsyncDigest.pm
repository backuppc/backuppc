#============================================================= -*-perl-*-
#
# BackupPC::RsyncDigest package
#
# DESCRIPTION
#
#   This library defines a BackupPC::RsyncDigest class for computing
#   and caching rsync checksums.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2001-2003  Craig Barratt
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
# Version 2.1.0_CVS, released 3 Jul 2003.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

package BackupPC::RsyncDigest;

use strict;

use vars qw( $RsyncLibOK );
use Carp;

BEGIN {
    eval "use File::RsyncP;";
    if ( $@ ) {
        #
        # File::RsyncP doesn't exist.  Define some dummy constant
        # subs so that the code below doesn't barf.
        #
        $RsyncLibOK = 0;
    } else {
        $RsyncLibOK = 1;
    }
};

#
# Return the rsync block size based on the file size.
# We also make sure the block size plus 4 (ie: cheeksumSeed)
# is not a multiple of 64 - otherwise the cached checksums
# will not be the same for protocol versions <= 26 and > 26.
#
sub blockSize
{
    my($class, $fileSize, $defaultBlkSize) = @_;

    my $blkSize = int($fileSize / 10000);
    $blkSize = $defaultBlkSize if ( $blkSize < $defaultBlkSize );
    $blkSize = 16384 if ( $blkSize > 16384 );
    $blkSize += 4 if ( (($blkSize + 4) % 64) == 0 );
    return $blkSize;
}

#
# Compute and add rsync block and file digests to the given file.
#
sub digestAdd
{
    my($class, $file, $blockSize, $checksumSeed) = @_;
    if ( $blockSize == 0 ) {
	print("bogus digestAdd($file, $blockSize, $checksumSeed)\n");
	$blockSize = 2048;
    }
    my $nBlks = int(65536 * 16 / $blockSize) + 1;
    my($data, $blockDigest, $fileDigest);

    return if ( !$RsyncLibOK );

    my $digest = File::RsyncP::Digest->new;
    $digest->add(pack("V", $checksumSeed)) if ( $checksumSeed );

    return -1 if ( !defined(my $fh = BackupPC::FileZIO->open($file, 0, 1)) );
    while ( 1 ) {
        $fh->read(\$data, $nBlks * $blockSize);
        last if ( $data eq "" );
        $blockDigest .= $digest->blockDigest($data, $blockSize, 16,
                                             $checksumSeed);
        $digest->add($data);
    }
    $fileDigest = $digest->digest2;
    my $eofPosn = tell($fh->{fh});
    $fh->close;
    my $rsyncData = $blockDigest . $fileDigest;
    my $metaData  = pack("VVVV", $blockSize,
                                 $checksumSeed,
                                 length($blockDigest) / 20,
                                 0x5fe3c289,                # magic number
                        );
    my $data2 = chr(0xb3) . $rsyncData . $metaData;
#    printf("appending %d+%d bytes to %s at offset %d\n",
#                                            length($rsyncData),
#                                            length($metaData),
#                                            $file,
#                                            $eofPosn);
    open(my $fh2, "+<", $file) || return -2;
    binmode($fh2);
    return -3 if ( sysread($fh2, $data, 1) != 1 );
    if ( $data ne chr(0x78) && $data ne chr(0xd6) ) {
        printf("Unexpected first char 0x%x\n", ord($data));
        return -4;
    }
    return -5 if ( sysseek($fh2, $eofPosn, 0) != $eofPosn );
    return -6 if ( syswrite($fh2, $data2) != length($data2) );
    return -7 if ( !defined(sysseek($fh2, 0, 0)) );
    return -8 if ( syswrite($fh2, chr(0xd6)) != 1 );
    close($fh2);
}

#
# Return rsync checksums for the given file.  We read the cached checksums
# if they exist and the block size and checksum seed match.  Otherwise
# we compute the checksums from the file contents.
#
sub digestStart
{
    my($class, $fileName, $fileSize, $blockSize, $defBlkSize,
       $checksumSeed, $needMD4, $compress, $doCache) = @_;

    return -1 if ( !$RsyncLibOK );

    my $data;

    my $fio = bless {
        name     => $fileName,
        needMD4  => $needMD4,
        digest   => File::RsyncP::Digest->new,
    }, $class;

    if ( $fileSize > 0 && $compress ) {
        open(my $fh, "<", $fileName) || return -2;
        binmode($fh);
        return -3 if ( read($fh, $data, 1) != 1 );
        if ( $data eq chr(0x78) && $doCache && $checksumSeed == 32761 ) {
            #
            # 32761 is the magic number that rsync uses for checksumSeed
            # with the --fixed-csum option.
            #
            # We now add the cached checksum data to the file.  There
            # is a possible race condition here since two BackupPC_dump
            # processes might call this function at the same time
            # on the same file.  But this should be ok since both
            # processes will write the same data, and the order
            # in which they write it doesn't matter.
            #
            close($fh);
            $fio->digestAdd($fileName,
                    $blockSize || $fio->blockSize($fileSize, $defBlkSize),
                    $checksumSeed);
            #
            # now re-open the file and re-read the first byte
            #
            open($fh, "<", $fileName) || return -2;
            binmode($fh);
            return -3 if ( read($fh, $data, 1) != 1 );
        }
        if ( $data eq chr(0xd6) ) {
            #
            # Looks like this file has cached checksums
            # Read the last 48 bytes: that's 2 file MD4s (32 bytes)
            # plus 4 words of meta data
            #
            return -4 if ( !defined(seek($fh, -48, 2)) ); 
            return -5 if ( read($fh, $data, 48) != 48 );
            ($fio->{md4DigestOld},
             $fio->{md4Digest},
             $fio->{blockSize},
             $fio->{checksumSeed},
             $fio->{nBlocks},
             $fio->{magic}) = unpack("a16 a16 V V V V", $data);
            if ( $fio->{magic} == 0x5fe3c289
                    && $fio->{checksumSeed} == $checksumSeed
                    && ($blockSize == 0 || $fio->{blockSize} == $blockSize) ) {
                $fio->{fh}     = $fh;
                $fio->{cached} = 1;
            } else {
                close($fh);
            }
            #
            # position the file at the start of the rsync block checksums
            # (4 (adler) + 16 (md4) bytes each)
            #
            return -6 if ( !defined(seek($fh, -$fio->{nBlocks}*20 - 48, 2)) );
        }
    }
    if ( !$fio->{cached} ) {
        #
        # This file doesn't have cached checksums, or the checksumSeed
        # or blocksize doesn't match.  Open the file and prepare to
        # compute the checksums.
        #
        $blockSize = BackupPC::RsyncDigest->blockSize($fileSize, $defBlkSize)
                                        if ( $blockSize == 0 );
        $fio->{checksumSeed} = $checksumSeed;
        $fio->{blockSize}    = $blockSize;
        $fio->{fh} = BackupPC::FileZIO->open($fileName, 0, $compress);
        return -7 if ( !defined($fio->{fh}) );
        if ( $needMD4) {
            $fio->{csumDigest} = File::RsyncP::Digest->new;
            $fio->{csumDigest}->add(pack("V", $fio->{checksumSeed}));
        }
    }
    return (undef, $fio, $fio->{blockSize});
}

sub digestGet
{
    my($fio, $num, $csumLen) = @_;
    my($fileData);
    my $blockSize = $fio->{blockSize};

    if ( $fio->{cached} ) {
        my $thisNum = $num;
        $thisNum = $fio->{nBlocks} if ( $thisNum > $fio->{nBlocks} );
        read($fio->{fh}, $fileData, 20 * $thisNum);
        $fio->{nBlocks} -= $thisNum;
        if ( $thisNum < $num ) {
            #
            # unexpected shortfall of data; pad with zero digest
            #
            $fileData .= pack("c", 0) x (20 * ($num - $thisNum));
        }
        return $fio->{digest}->blockDigestExtract($fileData, $csumLen);
    } else {
        if ( $fio->{fh}->read(\$fileData, $blockSize * $num) <= 0 ) {
            #
            # unexpected shortfall of data; pad with zeros
            #
            $fileData = pack("c", 0) x ($blockSize * $num);
        }
        $fio->{csumDigest}->add($fileData) if ( $fio->{needMD4} );
        return $fio->{digest}->blockDigest($fileData, $blockSize,
                                           $csumLen, $fio->{checksumSeed});
    }
}

sub digestEnd
{
    my($fio) = @_;
    my($fileData);

    if ( $fio->{cached} ) {
        close($fio->{fh});
        return $fio->{md4DigestOld} if ( $fio->{needMD4} );
    } else {
        #
        # make sure we read the entire file for the file MD4 digest
        #
        if ( $fio->{needMD4} ) {
            my $fileData;
            while ( $fio->{fh}->read(\$fileData, 65536) > 0 ) {
                $fio->{csumDigest}->add($fileData);
            }
        }
        $fio->{fh}->close();
        return $fio->{csumDigest}->digest if ( $fio->{needMD4} );
    }
}

1;
