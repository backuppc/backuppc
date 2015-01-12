#============================================================= -*-perl-*-
#
# BackupPC::Xfer::RsyncDigest package
#
# DESCRIPTION
#
#   This library defines a BackupPC::Xfer::RsyncDigest class for computing
#   and caching rsync checksums.
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

package BackupPC::Xfer::RsyncDigest;

use strict;
use BackupPC::FileZIO;

use vars qw( $RsyncLibOK );
use Carp;
use Fcntl;
require Exporter;
use vars qw( @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );

my $Log = \&logHandler;

#
# Magic value for checksum seed.  We only cache block and file digests
# when the checksum seed matches this value.
#
use constant RSYNC_CSUMSEED_CACHE     => 32761;

@ISA = qw(Exporter);

@EXPORT    = qw( );

@EXPORT_OK = qw(
                  RSYNC_CSUMSEED_CACHE
             );

%EXPORT_TAGS = (
    'all'    => [ @EXPORT_OK ],
);

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

sub fileDigestIsCached
{
    my($class, $file) = @_;
    my $data;

    sysopen(my $fh, $file, O_RDONLY) || return -1;
    binmode($fh);
    return -2 if ( sysread($fh, $data, 1) != 1 );
    close($fh);
    return $data eq chr(0xd7) ? 1 : 0;
}

#
# Compute and add rsync block and file digests to the given file.
#
# Empty files don't get cached checksums.
#
# If verify is set then existing cached checksums are checked.
# If verify == 2 then only a verify is done; no fixes are applied.
# 
# Returns 0 on success.  Returns 1 on good verify and 2 on bad verify.
# Returns a variety of negative values on error.
#
sub digestAdd
{
    my($class, $file, $blockSize, $checksumSeed, $verify,
                $protocol_version) = @_;
    my $retValue = 0;

    #
    # Don't cache checksums if the checksumSeed is not RSYNC_CSUMSEED_CACHE
    # or if the file is empty.
    #
    return -100 if ( $checksumSeed != RSYNC_CSUMSEED_CACHE || !-s $file );

    if ( $blockSize == 0 ) {
	&$Log("digestAdd: bad blockSize ($file, $blockSize, $checksumSeed)");
	$blockSize = 2048;
    }
    my $nBlks = int(65536 * 16 / $blockSize) + 1;
    my($data, $blockDigest, $fileDigest);

    return -101 if ( !$RsyncLibOK );

    my $digest = File::RsyncP::Digest->new;
    $digest->protocol($protocol_version)
                        if ( defined($protocol_version) );
    $digest->add(pack("V", $checksumSeed)) if ( $checksumSeed );

    return -102 if ( !defined(my $fh = BackupPC::FileZIO->open($file, 0, 1)) );

    my $fileSize;
    while ( 1 ) {
        $fh->read(\$data, $nBlks * $blockSize);
        $fileSize += length($data);
        last if ( $data eq "" );
        $blockDigest .= $digest->blockDigest($data, $blockSize, 16,
                                             $checksumSeed);
        $digest->add($data);
    }
    $fileDigest = $digest->digest2;
    my $eofPosn = sysseek($fh->{fh}, 0, 1);
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
    sysopen(my $fh2, $file, O_RDWR) || return -103;
    binmode($fh2);
    return -104 if ( sysread($fh2, $data, 1) != 1 );
    if ( $data ne chr(0x78) && $data ne chr(0xd6) && $data ne chr(0xd7) ) {
        &$Log(sprintf("digestAdd: $file has unexpected first char 0x%x",
                             ord($data)));
        return -105;
    }
    return -106 if ( sysseek($fh2, $eofPosn, 0) != $eofPosn );
    if ( $verify ) {
        my $data3;

        #
        # Verify the cached checksums
        #
        return -107 if ( $data ne chr(0xd7) );
        return -108 if ( sysread($fh2, $data3, length($data2) + 1) < 0 );
        if ( $data2 eq $data3 ) {
            return 1;
        }
        #
        # Checksums don't agree - fall through so we rewrite the data
        #
        &$Log(sprintf("digestAdd: %s verify failed; redoing checksums; len = %d,%d; eofPosn = %d, fileSize = %d",
                $file, length($data2), length($data3), $eofPosn, $fileSize));
        #&$Log(sprintf("dataNew  = %s", unpack("H*", $data2)));
        #&$Log(sprintf("dataFile = %s", unpack("H*", $data3)));
        return -109 if ( sysseek($fh2, $eofPosn, 0) != $eofPosn );
        $retValue = 2;
        return $retValue if ( $verify == 2 );
    }
    return -110 if ( syswrite($fh2, $data2) != length($data2) );
    if ( $verify ) {
        #
        # Make sure there is no extraneous data on the end of
        # the file.  Seek to the end and truncate if it doesn't
        # match our expected length.
        #
        return -111 if ( !defined(sysseek($fh2, 0, 2)) );
        if ( sysseek($fh2, 0, 1) != $eofPosn + length($data2) ) {
            if ( !truncate($fh2, $eofPosn + length($data2)) ) {
                &$Log(sprintf("digestAdd: $file truncate from %d to %d failed",
                                sysseek($fh2, 0, 1), $eofPosn + length($data2)));
                return -112;
            } else {
                &$Log(sprintf("digestAdd: %s truncated from %d to %d",
                                $file,
                                sysseek($fh2, 0, 1), $eofPosn + length($data2)));
            }
        }
    }
    return -113 if ( !defined(sysseek($fh2, 0, 0)) );
    return -114 if ( syswrite($fh2, chr(0xd7)) != 1 );
    close($fh2);
    return $retValue;
}

#
# Return rsync checksums for the given file.  We read the cached checksums
# if they exist and the block size and checksum seed match.  Otherwise
# we compute the checksums from the file contents.
#
# The doCache flag can take three ranges:
#
#  - doCache <  0: don't generate/use cached checksums
#  - doCache == 0: don't generate, but do use cached checksums if available
#  - doCache >  0: generate (if necessary) and use cached checksums
#
# Note: caching is only enabled when compression is on and the
# checksum seed is RSYNC_CSUMSEED_CACHE (32761).
#
# Returns 0 on success.  Returns a variety of negative values on error.
#
sub digestStart
{
    my($class, $fileName, $fileSize, $blockSize, $defBlkSize,
       $checksumSeed, $needMD4, $compress, $doCache, $protocol_version) = @_;

    return -1 if ( !$RsyncLibOK );

    my $data;

    my $dg = bless {
        name     => $fileName,
        needMD4  => $needMD4,
        digest   => File::RsyncP::Digest->new,
        protocol_version => $protocol_version,
    }, $class;

    $dg->{digest}->protocol($dg->{protocol_version})
                        if ( defined($dg->{protocol_version}) );

    if ( $fileSize > 0 && $compress && $doCache >= 0 ) {
        open(my $fh, "<", $fileName) || return -2;
        binmode($fh);
        return -3 if ( sysread($fh, $data, 4096) < 1 );
        my $ret;

        if ( (vec($data, 0, 8) == 0x78 || vec($data, 0, 8) == 0xd6) && $doCache > 0
                     && $checksumSeed == RSYNC_CSUMSEED_CACHE ) {
            #
            # RSYNC_CSUMSEED_CACHE (32761) is the magic number that
            # rsync uses for checksumSeed with the --fixed-csum option.
            #
            # We now add the cached checksum data to the file.  There
            # is a possible race condition here since two BackupPC_dump
            # processes might call this function at the same time
            # on the same file.  But this should be ok since both
            # processes will write the same data, and the order
            # in which they write it doesn't matter.
            #
            close($fh);
            $ret = $dg->digestAdd($fileName,
                            $blockSize
                                || BackupPC::Xfer::RsyncDigest->blockSize(
                                                    $fileSize, $defBlkSize),
                                $checksumSeed, 0, $dg->{protocol_version});
            if ( $ret < 0 ) {
                &$Log("digestAdd($fileName) failed ($ret)");
            }
            #
            # now re-open the file and re-read the first byte
            #
            open($fh, "<", $fileName) || return -4;
            binmode($fh);
            return -5 if ( read($fh, $data, 1) != 1 );
        }
        if ( $ret >= 0 && vec($data, 0, 8) == 0xd7 ) {
            #
            # Looks like this file has cached checksums
            # Read the last 48 bytes: that's 2 file MD4s (32 bytes)
            # plus 4 words of meta data
            #
            my $cacheInfo;
            if ( length($data) >= 4096 ) {
                return -6 if ( !defined(sysseek($fh, -4096, 2)) ); 
                return -7 if ( sysread($fh, $data, 4096) != 4096 );
            }
            $cacheInfo = substr($data, -48);
            ($dg->{md4DigestOld},
             $dg->{md4Digest},
             $dg->{blockSize},
             $dg->{checksumSeed},
             $dg->{nBlocks},
             $dg->{magic}) = unpack("a16 a16 V V V V", $cacheInfo);
            if ( $dg->{magic} == 0x5fe3c289
                    && $dg->{checksumSeed} == $checksumSeed
                    && ($blockSize == 0 || $dg->{blockSize} == $blockSize) ) {
                $dg->{fh}     = $fh;
                $dg->{cached} = 1;
                if ( length($data) >= $dg->{nBlocks} * 20 + 48 ) {
                    #
                    # We have all the data already - just remember it
                    #
                    $dg->{digestData} = substr($data,
                                               length($data) - $dg->{nBlocks} * 20 - 48,
                                               $dg->{nBlocks} * 20);
                } else {
                    #
                    # position the file at the start of the rsync block checksums
                    # (4 (adler) + 16 (md4) bytes each)
                    #
                    return -8
                        if ( !defined(sysseek($fh, -$dg->{nBlocks} * 20 - 48, 2)) );
                }
            } else {
                #
                # cached checksums are not valid, so we close the
                # file and treat it as uncached.
                #
                $dg->{cachedInvalid} = 1;
                close($fh);
            }
        }
    }
    if ( !$dg->{cached} ) {
        #
        # This file doesn't have cached checksums, or the checksumSeed
        # or blocksize doesn't match.  Open the file and prepare to
        # compute the checksums.
        #
        $blockSize
	    = BackupPC::Xfer::RsyncDigest->blockSize($fileSize, $defBlkSize)
				    if ( $blockSize == 0 );
        $dg->{checksumSeed} = $checksumSeed;
        $dg->{blockSize}    = $blockSize;
        $dg->{fh} = BackupPC::FileZIO->open($fileName, 0, $compress);
        return -9 if ( !defined($dg->{fh}) );
        if ( $needMD4) {
            $dg->{csumDigest} = File::RsyncP::Digest->new;
            $dg->{csumDigest}->protocol($dg->{protocol_version})
                                if ( defined($dg->{protocol_version}) );
            $dg->{csumDigest}->add(pack("V", $dg->{checksumSeed}));
        }
    }
    return (undef, $dg, $dg->{blockSize});
}

sub digestGet
{
    my($dg, $num, $csumLen, $noPad) = @_;
    my($fileData);
    my $blockSize = $dg->{blockSize};

    if ( $dg->{cached} ) {
        my $thisNum = $num;
        $thisNum = $dg->{nBlocks} if ( $thisNum > $dg->{nBlocks} );
        if ( defined($dg->{digestData}) ) {
            $fileData = substr($dg->{digestData}, 0, 20 * $thisNum);
            $dg->{digestData} = substr($dg->{digestData}, 20 * $thisNum);
        } else {
            sysread($dg->{fh}, $fileData, 20 * $thisNum);
        }
        $dg->{nBlocks} -= $thisNum;
        if ( $thisNum < $num && !$noPad) {
            #
            # unexpected shortfall of data; pad with zero digest
            #
            $fileData .= pack("c", 0) x (20 * ($num - $thisNum));
        }
        return $dg->{digest}->blockDigestExtract($fileData, $csumLen);
    } else {
        if ( $dg->{fh}->read(\$fileData, $blockSize * $num) <= 0 ) {
            #
            # unexpected shortfall of data; pad with zeros
            #
            $fileData = pack("c", 0) x ($blockSize * $num) if ( !$noPad );
        }
        $dg->{csumDigest}->add($fileData) if ( $dg->{needMD4} );
        return $dg->{digest}->blockDigest($fileData, $blockSize,
                                           $csumLen, $dg->{checksumSeed});
    }
}

sub digestEnd
{
    my($dg, $skipMD4) = @_;
    my($fileData);

    if ( $dg->{cached} ) {
        close($dg->{fh});
        if ( $dg->{needMD4} ) {
            if ( $dg->{protocol_version} <= 26 ) {
                return $dg->{md4DigestOld};
            } else {
                return $dg->{md4Digest};
            }
        }
    } else {
        #
        # make sure we read the entire file for the file MD4 digest
        #
        if ( $dg->{needMD4} && !$skipMD4 ) {
            my $fileData;
            while ( $dg->{fh}->read(\$fileData, 65536) > 0 ) {
                $dg->{csumDigest}->add($fileData);
            }
        }
        $dg->{fh}->close();
        return $dg->{csumDigest}->digest if ( $dg->{needMD4} );
    }
}

sub isCached
{
    my($dg) = @_;
 
    return wantarray ? ($dg->{cached}, $dg->{cachedInvalid}) : $dg->{cached};
}

sub blockSizeCurr
{
    my($dg) = @_;
 
    return $dg->{blockSize};
}

#
# Default log handler
#
sub logHandler
{
    my($str) = @_;

    print(STDERR $str, "\n");
}

#
# Set log handler to a new subroutine.
#
sub logHandlerSet
{
    my($dg, $sub) = @_;

    $Log = $sub;
}

1;
