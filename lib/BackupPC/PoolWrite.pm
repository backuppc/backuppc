#============================================================= -*-perl-*-
#
# BackupPC::PoolWrite package
#
# DESCRIPTION
#
#   This library defines a BackupPC::PoolWrite class for writing
#   files to disk that are candidates for pooling.  One instance
#   of this class is used to write each file.  The following steps
#   are executed:
#
#     - As the incoming data arrives, the first 1MB is buffered
#       in memory so the MD5 digest can be computed.
#
#     - A running comparison against all the candidate pool files
#       (ie: those with the same MD5 digest, usually at most a single
#       file) is done as new incoming data arrives.  Up to $MaxFiles
#       simultaneous files can be compared in parallel.  This
#       involves reading and uncompressing one or more pool files.
#
#     - When a pool file no longer matches it is discarded from
#       the search.  If there are more than $MaxFiles candidates, one of
#       the new candidates is added to the search, first checking
#       that it matches up to the current point (this requires
#       re-reading one of the other pool files).
#
#     - When or if no pool files match then the new file is written
#       to disk.  This could occur many MB into the file.  We don't
#       need to buffer all this data in memory since we can copy it
#       from the last matching pool file, up to the point where it
#       fully matched.
#
#     - When all the new data is complete, if a pool file exactly
#       matches then the file is simply created as a hardlink to
#       the pool file.
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

package BackupPC::PoolWrite;

use strict;

use File::Path;
use Digest::MD5;
use BackupPC::FileZIO;

sub new
{
    my($class, $bpc, $fileName, $fileSize, $compress) = @_;

    my $self = bless {
        fileName => $fileName,
        fileSize => $fileSize,
        bpc      => $bpc,
        compress => $compress,
        nWrite   => 0,
        digest   => undef,
        files    => [],
        fileCnt  => -1,
        fhOut    => undef,
        errors   => [],
        data     => "",
        eof      => undef,
    }, $class;

    $self->{hardLinkMax} = $bpc->ConfValue("HardLinkMax");

    #
    # Always unlink any current file in case it is already linked
    #
    unlink($fileName) if ( -f $fileName );
    if ( $fileName =~ m{(.*)/.+} && !-d $1 ) {
        my $newDir = $1;
        eval { mkpath($newDir, 0, 0777) };
        if ( $@ ) {
            push(@{$self->{errors}}, "Unable to create directory $newDir for $self->{fileName}");
        }
    }
    return $self;
}

my $BufSize  = 1048576;  # 1MB or 2^20
my $MaxFiles = 20;       # max number of compare files open at one time

sub write
{
    my($a, $dataRef) = @_;

    return if ( $a->{eof} );
    $a->{data} .= $$dataRef if ( defined($dataRef) );
    return if ( length($a->{data}) < $BufSize && defined($dataRef) );

    #
    # Correct the fileSize if it is wrong (rsync might transfer
    # a file whose length is different to the length sent with the
    # file list if the file changes between the file list sending
    # and the file sending).  Here we only catch the case where
    # we haven't computed the digest (ie: we have written no more
    # than $BufSize).  We catch the big file case below.
    #
    if ( !defined($dataRef) && !defined($a->{digest})
		&& $a->{fileSize} != length($a->{data}) ) {
	#my $newSize = length($a->{data});
	#print("Fixing file size from $a->{fileSize} to $newSize\n");
	$a->{fileSize} = length($a->{data});
    }

    if ( !defined($a->{digest}) && length($a->{data}) > 0 ) {
        #
        # build a list of all the candidate matching files
        #
        my $md5 = Digest::MD5->new;
	$a->{fileSize} = length($a->{data})
			    if ( $a->{fileSize} < length($a->{data}) );
        $a->{digest} = $a->{bpc}->Buffer2MD5($md5, $a->{fileSize}, \$a->{data});
        if ( !defined($a->{base} = $a->{bpc}->MD52Path($a->{digest},
                                                       $a->{compress})) ) {
            push(@{$a->{errors}}, "Unable to get path from '$a->{digest}'"
                                . " for $a->{fileName}");
        } else {
            while ( @{$a->{files}} < $MaxFiles ) {
                my $fh;
                my $fileName = $a->{fileCnt} < 0 ? $a->{base}
                                        : "$a->{base}_$a->{fileCnt}";
                last if ( !-f $fileName );
                #
                # Don't attempt to match pool files that already
                # have too many hardlinks.  Also, don't match pool
                # files with only one link since starting in
                # BackupPC v3.0, BackupPC_nightly could be running
                # in parallel (and removing those files).  This doesn't
                # eliminate all possible race conditions, but just
                # reduces the odds.  Other design steps eliminate
                # the remaining race conditions of linking vs
                # removing.
                #
                if ( (stat(_))[3] >= $a->{hardLinkMax}
                    || (stat(_))[3] <= 1
		    || !defined($fh = BackupPC::FileZIO->open($fileName, 0,
                                                     $a->{compress})) ) {
                    $a->{fileCnt}++;
                    next;
                }
                push(@{$a->{files}}, {
                        name => $fileName,
                        fh   => $fh,
                     });
                $a->{fileCnt}++;
            }
        }
        #
        # if there are no candidate files then we must write
        # the new file to disk
        #
        if ( !@{$a->{files}} ) {
            $a->{fhOut} = BackupPC::FileZIO->open($a->{fileName},
                                              1, $a->{compress});
            if ( !defined($a->{fhOut}) ) {
                push(@{$a->{errors}}, "Unable to open $a->{fileName}"
                                    . " for writing");
            }
        }
    }
    my $dataLen = length($a->{data});
    if ( !defined($a->{fhOut}) && length($a->{data}) > 0 ) {
        #
        # See if the new chunk of data continues to match the
        # candidate files.
        #
        for ( my $i = 0 ; $i < @{$a->{files}} ; $i++ ) {
            my($d, $match);
            my $fileName = $a->{fileCnt} < 0 ? $a->{base}
                                             : "$a->{base}_$a->{fileCnt}";
            if ( $dataLen > 0 ) {
                # verify next $dataLen bytes from candidate file
                my $n = $a->{files}[$i]->{fh}->read(\$d, $dataLen);
                next if ( $n == $dataLen && $d eq $a->{data} );
            } else {
                # verify candidate file is at EOF
                my $n = $a->{files}[$i]->{fh}->read(\$d, 100);
                next if ( $n == 0 );
            }
            #print("   File $a->{files}[$i]->{name} doesn't match\n");
            #
            # this candidate file didn't match.  Replace it
            # with a new candidate file.  We have to qualify
            # any new candidate file by making sure that its
            # first $a->{nWrite} bytes match, plus the next $dataLen
            # bytes match $a->{data}.
            #
            while ( -f $fileName ) {
                my $fh;
                if ( (stat(_))[3] >= $a->{hardLinkMax}
		    || !defined($fh = BackupPC::FileZIO->open($fileName, 0,
                                                     $a->{compress})) ) {
                    $a->{fileCnt}++;
                    #print("   Discarding $fileName (open failed)\n");
                    $fileName = "$a->{base}_$a->{fileCnt}";
                    next;
                }
                if ( !$a->{files}[$i]->{fh}->rewind() ) {
                    push(@{$a->{errors}},
                            "Unable to rewind $a->{files}[$i]->{name}"
                          . " for compare");
                }
                $match = $a->filePartialCompare($a->{files}[$i]->{fh}, $fh,
                                          $a->{nWrite}, $dataLen, \$a->{data});
                if ( $match ) {
                    $a->{files}[$i]->{fh}->close();
                    $a->{files}[$i]->{fh} = $fh,
                    $a->{files}[$i]->{name} = $fileName;
                    #print("   Found new candidate $fileName\n");
                    $a->{fileCnt}++;
                    last;
                } else {
                    #print("   Discarding $fileName (no match)\n");
                }
                $fh->close();
                $a->{fileCnt}++;
                $fileName = "$a->{base}_$a->{fileCnt}";
            }
            if ( !$match ) {
                #
                # We couldn't find another candidate file
                #
                if ( @{$a->{files}} == 1 ) {
                    #print("   Exhausted matches, now writing\n");
                    $a->{fhOut} = BackupPC::FileZIO->open($a->{fileName},
                                                    1, $a->{compress});
                    if ( !defined($a->{fhOut}) ) {
                        push(@{$a->{errors}},
                                "Unable to open $a->{fileName}"
                              . " for writing");
                    } else {
                        if ( !$a->{files}[$i]->{fh}->rewind() ) {
                            push(@{$a->{errors}}, 
                                     "Unable to rewind"
                                   . " $a->{files}[$i]->{name} for copy");
                        }
                        $a->filePartialCopy($a->{files}[$i]->{fh}, $a->{fhOut},
                                        $a->{nWrite});
                    }
                }
                $a->{files}[$i]->{fh}->close();
                splice(@{$a->{files}}, $i, 1);
                $i--;
            }
        }
    }
    if ( defined($a->{fhOut}) && $dataLen > 0 ) {
        #
        # if we are in writing mode then just write the data
        #
        my $n = $a->{fhOut}->write(\$a->{data});
        if ( $n != $dataLen ) {
            push(@{$a->{errors}}, "Unable to write $dataLen bytes to"
                                . " $a->{fileName} (got $n)");
        }
    }
    $a->{nWrite} += $dataLen;
    $a->{data} = "";
    return if ( defined($dataRef) );

    #
    # We are at EOF, so finish up
    #
    $a->{eof} = 1;

    #
    # Make sure the fileSize was correct.  See above for comments about
    # rsync.
    #
    if ( $a->{nWrite} != $a->{fileSize} ) {
	#
	# Oops, fileSize was wrong, so our MD5 digest was wrong and our
	# effort to match files likely failed.  This is ugly, but our
	# only choice at this point is to re-write the entire file with
	# the correct length.  We need to rename the file, open it for
	# reading, and then re-write the file with the correct length.
	#

	#print("Doing big file fixup ($a->{fileSize} != $a->{nWrite})\n");

	my($fh, $fileName);
	$a->{fileSize} = $a->{nWrite};

	if ( defined($a->{fhOut}) ) {
	    if ( $a->{fileName} =~ /(.*)\// ) {
		$fileName = $1;
	    } else {
		$fileName = ".";
	    }
	    #
	    # Find a unique target temporary file name
	    #
	    my $i = 0;
	    while ( -f "$fileName/t$$.$i" ) {
		$i++;
	    }
	    $fileName = "$fileName/t$$.$i";
	    $a->{fhOut}->close();
	    if ( !rename($a->{fileName}, $fileName)
	      || !defined($fh = BackupPC::FileZIO->open($fileName, 0,
						 $a->{compress})) ) {
		push(@{$a->{errors}}, "Can't rename $a->{fileName} -> $fileName"
				    . " or open during size fixup");
	    }
	    #print("Using temporary name $fileName\n");
	} elsif ( defined($a->{files}) && defined($a->{files}[0]) ) {
	    #
	    # We haven't written anything yet, so just use the
	    # compare file to copy from.
	    #
	    $fh = $a->{files}[0]->{fh};
	    $fh->rewind;
	    #print("Using compare file $a->{files}[0]->{name}\n");
	}
	if ( defined($fh) ) {
	    my $poolWrite = BackupPC::PoolWrite->new($a->{bpc}, $a->{fileName},
					$a->{fileSize}, $a->{compress});
	    my $nRead = 0;

	    while ( $nRead < $a->{fileSize} ) {
		my $thisRead = $a->{fileSize} - $nRead < $BufSize
		 	     ? $a->{fileSize} - $nRead : $BufSize;
		my $data;
		my $n = $fh->read(\$data, $thisRead);
		if ( $n != $thisRead ) {
		    push(@{$a->{errors}},
				"Unable to read $thisRead bytes during resize"
			       . " from temp $fileName (got $n)");
		    last;
		}
		$poolWrite->write(\$data);
		$nRead += $thisRead;
	    }
	    $fh->close;
	    unlink($fileName) if ( defined($fileName) );
	    if ( @{$a->{errors}} ) {
		$poolWrite->close;
		return (0, $a->{digest}, -s $a->{fileName}, $a->{errors});
	    } else {
		return $poolWrite->close;
	    }
	}
    }

    if ( $a->{fileSize} == 0 ) {
        #
        # Simply create an empty file
        #
        local(*OUT);
        if ( !open(OUT, ">", $a->{fileName}) ) {
            push(@{$a->{errors}}, "Can't open $a->{fileName} for empty"
                                . " output");
        } else {
            close(OUT);
        }
        #
        # Close the compare files
        #
        foreach my $f ( @{$a->{files}} ) {
            $f->{fh}->close();
        }
        return (1, $a->{digest}, -s $a->{fileName}, $a->{errors});
    } elsif ( defined($a->{fhOut}) ) {
        $a->{fhOut}->close();
        #
        # Close the compare files
        #
        foreach my $f ( @{$a->{files}} ) {
            $f->{fh}->close();
        }
        return (0, $a->{digest}, -s $a->{fileName}, $a->{errors});
    } else {
        if ( @{$a->{files}} == 0 ) {
            push(@{$a->{errors}}, "Botch, no matches on $a->{fileName}"
                                . " ($a->{digest})");
        } elsif ( @{$a->{files}} > 1 ) {
	    #
	    # This is no longer a real error because $Conf{HardLinkMax}
	    # could be hit, thereby creating identical pool files
	    #
            #my $str = "Unexpected multiple matches on"
            #       . " $a->{fileName} ($a->{digest})\n";
            #for ( my $i = 0 ; $i < @{$a->{files}} ; $i++ ) {
            #    $str .= "     -> $a->{files}[$i]->{name}\n";
            #}
            #push(@{$a->{errors}}, $str);
        }
        for ( my $i = 0 ; $i < @{$a->{files}} ; $i++ ) {
            if ( link($a->{files}[$i]->{name}, $a->{fileName}) ) {
                #print("  Linked $a->{fileName} to $a->{files}[$i]->{name}\n");
                #
                # Close the compare files
                #
                foreach my $f ( @{$a->{files}} ) {
                    $f->{fh}->close();
                }
                return (1, $a->{digest}, -s $a->{fileName}, $a->{errors});
            }
        }
        #
        # We were unable to link to the pool.  Either we're at the
        # hardlink max, or the pool file got deleted.  Recover by
        # writing the matching file, since we still have an open
        # handle.
        #
        for ( my $i = 0 ; $i < @{$a->{files}} ; $i++ ) {
            if ( !$a->{files}[$i]->{fh}->rewind() ) {
                push(@{$a->{errors}}, 
                         "Unable to rewind $a->{files}[$i]->{name}"
                       . " for copy after link fail");
                next;
            }
            $a->{fhOut} = BackupPC::FileZIO->open($a->{fileName},
                                            1, $a->{compress});
            if ( !defined($a->{fhOut}) ) {
                push(@{$a->{errors}},
                        "Unable to open $a->{fileName}"
                      . " for writing after link fail");
            } else {
                $a->filePartialCopy($a->{files}[$i]->{fh}, $a->{fhOut},
                                    $a->{nWrite});
                $a->{fhOut}->close;
            }
            last;
        }
        #
        # Close the compare files
        #
        foreach my $f ( @{$a->{files}} ) {
            $f->{fh}->close();
        }
        return (0, $a->{digest}, -s $a->{fileName}, $a->{errors});
    }
}

#
# Finish writing: pass undef dataRef to write so it can do all
# the work.  Returns a 4 element array:
#
#   (existingFlag, digestString, outputFileLength, errorList)
#
sub close
{
    my($a) = @_;

    return $a->write(undef);
}

#
# Abort a pool write
#
sub abort
{
    my($a) = @_;

    if ( defined($a->{fhOut}) ) {
	$a->{fhOut}->close();
	unlink($a->{fileName});
    }
    foreach my $f ( @{$a->{files}} ) {
        $f->{fh}->close();
    }
    $a->{files} = [];
}

#
# Copy $nBytes from files $fhIn to $fhOut.
#
sub filePartialCopy
{
    my($a, $fhIn, $fhOut, $nBytes) = @_;
    my($nRead);

    while ( $nRead < $nBytes ) {
        my $thisRead = $nBytes - $nRead < $BufSize
                            ? $nBytes - $nRead : $BufSize;
        my $data;
        my $n = $fhIn->read(\$data, $thisRead);
        if ( $n != $thisRead ) {
            push(@{$a->{errors}},
                        "Unable to read $thisRead bytes from "
                       . $fhIn->name . " (got $n)");
            return;
        }
        $n = $fhOut->write(\$data, $thisRead);
        if ( $n != $thisRead ) {
            push(@{$a->{errors}},
                        "Unable to write $thisRead bytes to "
                       . $fhOut->name . " (got $n)");
            return;
        }
        $nRead += $thisRead;
    }
}

#
# Compare $nBytes from files $fh0 and $fh1, and also compare additional
# $extra bytes from $fh1 to $$extraData.
#
sub filePartialCompare
{
    my($a, $fh0, $fh1, $nBytes, $extra, $extraData) = @_;
    my($nRead, $n);
    my($data0, $data1);

    while ( $nRead < $nBytes ) {
        my $thisRead = $nBytes - $nRead < $BufSize
                            ? $nBytes - $nRead : $BufSize;
        $n = $fh0->read(\$data0, $thisRead);
        if ( $n != $thisRead ) {
            push(@{$a->{errors}}, "Unable to read $thisRead bytes from "
                                 . $fh0->name . " (got $n)");
            return;
        }
        $n = $fh1->read(\$data1, $thisRead);
        return 0 if ( $n < $thisRead || $data0 ne $data1 );
        $nRead += $thisRead;
    }
    if ( $extra > 0 ) {
        # verify additional bytes
        $n = $fh1->read(\$data1, $extra);
        return 0 if ( $n != $extra || $data1 ne $$extraData );
    } else {
        # verify EOF
        $n = $fh1->read(\$data1, 100);
        return 0 if ( $n != 0 );
    }
    return 1;
}

#
# LinkOrCopy() does a hardlink from oldFile to newFile.
#
# If that fails (because there are too many links on oldFile)
# then oldFile is copied to newFile, and the pool stats are
# returned to be added to the new file list.  That allows
# BackupPC_link to try again, and to create a new pool file
# if necessary.
#
sub LinkOrCopy
{
    my($bpc, $oldFile, $oldFileComp, $newFile, $newFileComp) = @_;
    my($nRead, $data);

    unlink($newFile)  if ( -f $newFile );
    #
    # Try to link if hardlink limit is ok, and compression types
    # are the same
    #
    return (1, undef) if ( (stat($oldFile))[3] < $bpc->{Conf}{HardLinkMax}
                            && !$oldFileComp == !$newFileComp
                            && link($oldFile, $newFile) );
    #
    # There are too many links on oldFile, or compression
    # type if different, so now we have to copy it.
    #
    # We need to compute the file size, which is expensive
    # since we need to read the file twice.  That's probably
    # ok since the hardlink limit is rarely hit.
    #
    my $readFd = BackupPC::FileZIO->open($oldFile, 0, $oldFileComp);
    if ( !defined($readFd) ) {
        return (0, undef, undef, undef, ["LinkOrCopy: can't open $oldFile"]);
    }
    while ( $readFd->read(\$data, $BufSize) > 0 ) {
        $nRead += length($data);
    }
    $readFd->rewind();

    my $poolWrite = BackupPC::PoolWrite->new($bpc, $newFile,
                                             $nRead, $newFileComp);
    while ( $readFd->read(\$data, $BufSize) > 0 ) {
        $poolWrite->write(\$data);
    }
    my($exists, $digest, $outSize, $errs) = $poolWrite->close;

    return ($exists, $digest, $nRead, $outSize, $errs);
}

1;
