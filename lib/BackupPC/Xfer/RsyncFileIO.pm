#============================================================= -*-perl-*-
#
# Rsync package
#
# DESCRIPTION
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2002-2015  Craig Barratt
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

package BackupPC::Xfer::RsyncFileIO;

use strict;
use File::Path;
use Encode qw/from_to/;
use BackupPC::Attrib qw(:all);
use BackupPC::View;
use BackupPC::Xfer::RsyncDigest qw(:all);
use BackupPC::PoolWrite;

use constant S_HLINK_TARGET => 0400000;    # this file is hardlink target
use constant S_IFMT         => 0170000;	   # type of file
use constant S_IFDIR        => 0040000;    # directory
use constant S_IFCHR        => 0020000;    # character special
use constant S_IFBLK        => 0060000;    # block special
use constant S_IFREG        => 0100000;    # regular
use constant S_IFLNK        => 0120000;    # symbolic link
use constant S_IFSOCK       => 0140000;    # socket
use constant S_IFIFO        => 0010000;    # fifo

use vars qw( $RsyncLibOK );

BEGIN {
    eval "use File::RsyncP::Digest";
    if ( $@ ) {
        #
        # Rsync module doesn't exist.
        #
        $RsyncLibOK = 0;
    } else {
        $RsyncLibOK = 1;
    }
};

sub new
{
    my($class, $options) = @_;

    return if ( !$RsyncLibOK );
    $options ||= {};
    my $fio = bless {
        blockSize    => 700,
        logLevel     => 0,
        digest       => File::RsyncP::Digest->new(),
        checksumSeed => 0,
	attrib	     => {},
	logHandler   => \&logHandler,
	stats        => {
	    errorCnt          => 0,
	    TotalFileCnt      => 0,
	    TotalFileSize     => 0,
	    ExistFileCnt      => 0,
	    ExistFileSize     => 0,
	    ExistFileCompSize => 0,
	},
	%$options,
    }, $class;

    $fio->{digest}->protocol($fio->{protocol_version});
    $fio->{shareM}   = $fio->{bpc}->fileNameEltMangle($fio->{share});
    $fio->{outDir}   = "$fio->{xfer}{outDir}/new/";
    $fio->{outDirSh} = "$fio->{outDir}/$fio->{shareM}/";
    $fio->{view}     = BackupPC::View->new($fio->{bpc}, $fio->{client},
					 $fio->{backups});
    $fio->{full}     = $fio->{xfer}{type} eq "full" ? 1 : 0;
    $fio->{newFilesFH} = $fio->{xfer}{newFilesFH};
    $fio->{partialNum} = undef if ( !$fio->{full} );
    return $fio;
}

#
# We publish our version to File::RsyncP.  This is so File::RsyncP
# can provide backward compatibility to older FileIO code.
#
# Versions:
#
#   undef or 1:  protocol version 26, no hardlinks
#   2:           protocol version 28, supports hardlinks
#
sub version
{
    return 2;
}

sub blockSize
{
    my($fio, $value) = @_;

    $fio->{blockSize} = $value if ( defined($value) );
    return $fio->{blockSize};
}

sub protocol_version
{
    my($fio, $value) = @_;

    if ( defined($value) ) {
        $fio->{protocol_version} = $value;
        $fio->{digest}->protocol($fio->{protocol_version});
    }
    return $fio->{protocol_version};
}

sub preserve_hard_links
{
    my($fio, $value) = @_;

    $fio->{preserve_hard_links} = $value if ( defined($value) );
    return $fio->{preserve_hard_links};
}

sub logHandlerSet
{
    my($fio, $sub) = @_;
    $fio->{logHandler} = $sub;
    BackupPC::Xfer::RsyncDigest->logHandlerSet($sub);
}

#
# Setup rsync checksum computation for the given file.
#
sub csumStart
{
    my($fio, $f, $needMD4, $defBlkSize, $phase) = @_;

    $defBlkSize ||= $fio->{blockSize};
    my $attr = $fio->attribGet($f, 1);
    $fio->{file} = $f;
    $fio->csumEnd if ( defined($fio->{csum}) );
    return -1 if ( $attr->{type} != BPC_FTYPE_FILE );

    #
    # Rsync uses short checksums on the first phase.  If the whole-file
    # checksum fails, then the file is repeated with full checksums.
    # So on phase 2 we verify the checksums if they are cached.
    #
    if ( ($phase > 0 || rand(1) < $fio->{cacheCheckProb})
            && $attr->{compress}
            && $fio->{checksumSeed} == RSYNC_CSUMSEED_CACHE ) {
        my($err, $d, $blkSize) = BackupPC::Xfer::RsyncDigest->digestStart(
                                     $attr->{fullPath}, $attr->{size}, 0,
                                     $defBlkSize, $fio->{checksumSeed},
                                     0, $attr->{compress}, 0,
                                     $fio->{protocol_version});
        if ( $err ) {
            $fio->log("Can't get rsync digests from $attr->{fullPath}"
                    . " (err=$err, name=$f->{name})");
            $fio->{stats}{errorCnt}++;
            return -1;
        }
        my($isCached, $isInvalid) = $d->isCached;
        if ( $fio->{logLevel} >= 5 ) {
            $fio->log("$attr->{fullPath} verify; cached = $isCached,"
                    . " invalid = $isInvalid, phase = $phase");
        }
        if ( $isCached || $isInvalid ) {
            my $ret = BackupPC::Xfer::RsyncDigest->digestAdd(
                            $attr->{fullPath}, $blkSize,
                            $fio->{checksumSeed}, 1,        # verify
                            $fio->{protocol_version}
                        );
            if ( $ret != 1 ) {
                $fio->log("Bad cached digest for $attr->{fullPath} ($ret);"
                        . " fixed");
                $fio->{stats}{errorCnt}++;
            } else {
                $fio->log("$f->{name}: verified cached digest")
                                    if ( $fio->{logLevel} >= 2 );
            }
        }
        $d->digestEnd;
    }
    (my $err, $fio->{csum}, my $blkSize)
         = BackupPC::Xfer::RsyncDigest->digestStart($attr->{fullPath},
			 $attr->{size}, 0, $defBlkSize, $fio->{checksumSeed},
			 $needMD4, $attr->{compress}, 1, $fio->{protocol_version});
    if ( $err ) {
        $fio->log("Can't get rsync digests from $attr->{fullPath}"
                . " (err=$err, name=$f->{name})");
	$fio->{stats}{errorCnt}++;
        return -1;
    }
    if ( $fio->{logLevel} >= 5 ) {
        my($isCached, $invalid) = $fio->{csum}->isCached;
        $fio->log("$attr->{fullPath} cache = $isCached,"
                . " invalid = $invalid, phase = $phase");
    }
    return $blkSize;
}

sub csumGet
{
    my($fio, $num, $csumLen, $blockSize) = @_;
    my($fileData);

    $num     ||= 100;
    $csumLen ||= 16;
    return if ( !defined($fio->{csum}) );
    return $fio->{csum}->digestGet($num, $csumLen);
}

sub csumEnd
{
    my($fio) = @_;

    return if ( !defined($fio->{csum}) );
    return $fio->{csum}->digestEnd();
}

sub readStart
{
    my($fio, $f) = @_;

    my $attr = $fio->attribGet($f, 1);
    $fio->{file} = $f;
    $fio->readEnd if ( defined($fio->{fh}) );
    if ( !defined($fio->{fh} = BackupPC::FileZIO->open($attr->{fullPath},
                                           0,
                                           $attr->{compress})) ) {
        $fio->log("Can't open $attr->{fullPath} (name=$f->{name})");
	$fio->{stats}{errorCnt}++;
        return;
    }
    $fio->log("$f->{name}: opened for read") if ( $fio->{logLevel} >= 4 );
}

sub read
{
    my($fio, $num) = @_;
    my $fileData;

    $num ||= 32768;
    return if ( !defined($fio->{fh}) );
    if ( $fio->{fh}->read(\$fileData, $num) <= 0 ) {
        return $fio->readEnd;
    }
    $fio->log(sprintf("read returns %d bytes", length($fileData)))
				if ( $fio->{logLevel} >= 8 );
    return \$fileData;
}

sub readEnd
{
    my($fio) = @_;

    return if ( !defined($fio->{fh}) );
    $fio->{fh}->close;
    $fio->log("closing $fio->{file}{name})") if ( $fio->{logLevel} >= 8 );
    delete($fio->{fh});
    return;
}

sub checksumSeed
{
    my($fio, $checksumSeed) = @_;

    $fio->{checksumSeed} = $checksumSeed;
    $fio->log("Checksum caching enabled (checksumSeed = $checksumSeed)")
        if ( $fio->{logLevel} >= 1 && $checksumSeed == RSYNC_CSUMSEED_CACHE );
    $fio->log("Checksum seed is $checksumSeed")
        if ( $fio->{logLevel} >= 2 && $checksumSeed != RSYNC_CSUMSEED_CACHE );
}

sub dirs
{
    my($fio, $localDir, $remoteDir) = @_;

    $fio->{localDir}  = $localDir;
    $fio->{remoteDir} = $remoteDir;
}

sub viewCacheDir
{
    my($fio, $share, $dir) = @_;
    my $shareM;

    #$fio->log("viewCacheDir($share, $dir)");
    if ( !defined($share) ) {
	$share  = $fio->{share};
	$shareM = $fio->{shareM};
    } else {
	$shareM = $fio->{bpc}->fileNameEltMangle($share);
    }
    $shareM = "$shareM/$dir" if ( $dir ne "" );
    return if ( defined($fio->{viewCache}{$shareM}) );
    #
    # purge old cache entries (ie: those that don't match the
    # first part of $dir).
    #
    foreach my $d ( keys(%{$fio->{viewCache}}) ) {
	delete($fio->{viewCache}{$d}) if ( $shareM !~ m{^\Q$d/} );
    }
    #
    # fetch new directory attributes
    #
    $fio->{viewCache}{$shareM}
		= $fio->{view}->dirAttrib($fio->{viewNum}, $share, $dir);
    #
    # also cache partial backup attrib data too
    #
    if ( defined($fio->{partialNum}) ) {
        foreach my $d ( keys(%{$fio->{partialCache}}) ) {
            delete($fio->{partialCache}{$d}) if ( $shareM !~ m{^\Q$d/} );
        }
        $fio->{partialCache}{$shareM}
                    = $fio->{view}->dirAttrib($fio->{partialNum}, $share, $dir);
    }
}

sub attribGetWhere
{
    my($fio, $f, $noCache, $fname) = @_;
    my($dir, $share, $shareM, $partial, $attr);

    if ( !defined($fname) ) {
        $fname = $f->{name};
        $fname = "$fio->{xfer}{pathHdrSrc}/$fname"
		       if ( defined($fio->{xfer}{pathHdrSrc}) );
    }
    $fname =~ s{//+}{/}g;
    if ( $fname =~ m{(.*)/(.*)}s ) {
	$shareM = $fio->{shareM};
	$dir = $1;
	$fname = $2;
    } elsif ( $fname ne "." ) {
	$shareM = $fio->{shareM};
	$dir = "";
    } else {
	$share = "";
	$shareM = "";
	$dir = "";
	$fname = $fio->{share};
    }
    $shareM .= "/$dir" if ( $dir ne "" );

    if ( $noCache ) {
        $share  = $fio->{share} if ( !defined($share) );
        my $dirAttr = $fio->{view}->dirAttrib($fio->{viewNum}, $share, $dir);
        $attr = $dirAttr->{$fname};
    } else {
        $fio->viewCacheDir($share, $dir);
        if ( defined($attr = $fio->{viewCache}{$shareM}{$fname}) ) {
            $partial = 0;
        } elsif ( defined($attr = $fio->{partialCache}{$shareM}{$fname}) ) {
            $partial = 1;
        } else {
            return;
        }
        if ( $attr->{mode} & S_HLINK_TARGET ) {
            $attr->{hlink_self} = 1;
            $attr->{mode} &= ~S_HLINK_TARGET;
        }
    }
    return ($attr, $partial);
}

sub attribGet
{
    my($fio, $f, $doHardLink) = @_;

    my($attr) = $fio->attribGetWhere($f);
    if ( $doHardLink && $attr->{type} == BPC_FTYPE_HARDLINK ) {
        $fio->log("$attr->{fullPath}: opening for hardlink read"
                . " (name = $f->{name})") if ( $fio->{logLevel} >= 4 );
        my $fh = BackupPC::FileZIO->open($attr->{fullPath}, 0,
                                         $attr->{compress});
        my $target;
        if ( defined($fh) ) {
            $fh->read(\$target,  65536);
            $fh->close;
            $target =~ s/^\.?\/+//;
        } else {
            $fio->log("$attr->{fullPath}: can't open for hardlink read");
            $fio->{stats}{errorCnt}++;
            $attr->{type} = BPC_FTYPE_FILE;
            return $attr;
        }
        $target = "/$target" if ( $target !~ /^\// );
        $fio->log("$attr->{fullPath}: redirecting to $target")
                                    if ( $fio->{logLevel} >= 4 );
        $target =~ s{^/+}{};
        ($attr) = $fio->attribGetWhere($f, 1, $target);
        $fio->log(" ... now got $attr->{fullPath}")
                            if ( $fio->{logLevel} >= 4 );
    }
    return $attr;
}

sub mode2type
{
    my($fio, $f) = @_;
    my $mode = $f->{mode};

    if ( ($mode & S_IFMT) == S_IFREG ) {
        if ( defined($f->{hlink}) && !$f->{hlink_self} ) {
            return BPC_FTYPE_HARDLINK;
        } else {
            return BPC_FTYPE_FILE;
        }
    } elsif ( ($mode & S_IFMT) == S_IFDIR ) {
	return BPC_FTYPE_DIR;
    } elsif ( ($mode & S_IFMT) == S_IFLNK ) {
	return BPC_FTYPE_SYMLINK;
    } elsif ( ($mode & S_IFMT) == S_IFCHR ) {
	return BPC_FTYPE_CHARDEV;
    } elsif ( ($mode & S_IFMT) == S_IFBLK ) {
	return BPC_FTYPE_BLOCKDEV;
    } elsif ( ($mode & S_IFMT) == S_IFIFO ) {
	return BPC_FTYPE_FIFO;
    } elsif ( ($mode & S_IFMT) == S_IFSOCK ) {
	return BPC_FTYPE_SOCKET;
    } else {
	return BPC_FTYPE_UNKNOWN;
    }
}

#
# Set the attributes for a file.  Returns non-zero on error.
#
sub attribSet
{
    my($fio, $f, $placeHolder) = @_;
    my($dir, $file);

    return if ( $placeHolder && $fio->{phase} > 0 );

    if ( $f->{name} =~ m{(.*)/(.*)}s ) {
	$file = $2;
	$dir  = "$fio->{shareM}/" . $1;
    } elsif ( $f->{name} eq "." ) {
	$dir  = "";
	$file = $fio->{share};
    } else {
	$dir  = $fio->{shareM};
	$file = $f->{name};
    }

    if ( $dir ne ""
            && (!defined($fio->{attribLastDir}) || $fio->{attribLastDir} ne $dir) ) {
        #
        # Flush any directories that don't match the first part
        # of the new directory.  Don't flush the top-level directory
        # (ie: $dir eq "") since the "." might get sorted in the middle
        # of other top-level directories or files.
        #
        foreach my $d ( keys(%{$fio->{attrib}}) ) {
            next if ( $d eq "" || "$dir/" =~ m{^\Q$d/} );
            $fio->attribWrite($d);
        }
	$fio->{attribLastDir} = $dir;
    }
    if ( !exists($fio->{attrib}{$dir}) ) {
        $fio->log("attribSet: dir=$dir not found") if ( $fio->{logLevel} >= 4 );
        $fio->{attrib}{$dir} = BackupPC::Attrib->new({
				     compress => $fio->{xfer}{compress},
				});
        my $dirM = $dir;
	$dirM = $1 . "/" . $fio->{bpc}->fileNameMangle($2)
			if ( $dirM =~ m{(.*?)/(.*)}s );
	my $path = $fio->{outDir} . $dirM;
        if ( -f $fio->{attrib}{$dir}->fileName($path) ) {
            if ( !$fio->{attrib}{$dir}->read($path) ) {
                $fio->log(sprintf("Unable to read attribute file %s",
			    $fio->{attrib}{$dir}->fileName($path)));
            } else {
                $fio->log(sprintf("attribRead file %s",
			    $fio->{attrib}{$dir}->fileName($path)))
                                     if ( $fio->{logLevel} >= 4 );
            }
        }
    } else {
        $fio->log("attribSet: dir=$dir exists") if ( $fio->{logLevel} >= 4 );
    }
    $fio->log("attribSet(dir=$dir, file=$file, size=$f->{size}, placeholder=$placeHolder)")
                        if ( $fio->{logLevel} >= 4 );

    my $mode = $f->{mode};

    $mode |= S_HLINK_TARGET if ( $f->{hlink_self} );
    $fio->{attrib}{$dir}->set($file, {
                            type  => $fio->mode2type($f),
                            mode  => $mode,
                            uid   => $f->{uid},
                            gid   => $f->{gid},
                            size  => $placeHolder ? -1 : $f->{size},
                            mtime => $f->{mtime},
                       });
    return;
}

sub attribWrite
{
    my($fio, $d) = @_;
    my($poolWrite);

    if ( !defined($d) ) {
        #
        # flush all entries (in reverse order)
        #
        foreach $d ( sort({$b cmp $a} keys(%{$fio->{attrib}})) ) {
            $fio->attribWrite($d);
        }
        return;
    }
    return if ( !defined($fio->{attrib}{$d}) );

    #
    # Set deleted files in the attributes.  Any file in the view
    # that doesn't have attributes is flagged as deleted for
    # incremental dumps.  All files sent by rsync have attributes
    # temporarily set so we can do deletion detection.  We also
    # prune these temporary attributes.
    #
    if ( $d ne "" ) {
	my $dir;
	my $share;

	$dir = $1 if ( $d =~ m{.+?/(.*)}s );
	$fio->viewCacheDir(undef, $dir);
	##print("attribWrite $d,$dir\n");
	##$Data::Dumper::Indent = 1;
	##$fio->log("attribWrite $d,$dir");
	##$fio->log("viewCacheLogKeys = ", keys(%{$fio->{viewCache}}));
	##$fio->log("attribKeys = ", keys(%{$fio->{attrib}}));
	##print "viewCache = ", Dumper($fio->{attrib});
	##print "attrib = ", Dumper($fio->{attrib});
	if ( defined($fio->{viewCache}{$d}) ) {
	    foreach my $f ( keys(%{$fio->{viewCache}{$d}}) ) {
		my $name = $f;
		$name = "$1/$name" if ( $d =~ m{.*?/(.*)}s );
		if ( defined(my $a = $fio->{attrib}{$d}->get($f)) ) {
		    #
		    # delete temporary attributes (skipped files)
		    #
		    if ( $a->{size} < 0 ) {
			$fio->{attrib}{$d}->set($f, undef);
			$fio->logFileAction("skip", {
				    %{$fio->{viewCache}{$d}{$f}},
				    name => $name,
				}) if ( $fio->{logLevel} >= 2
                                      && $a->{type} == BPC_FTYPE_FILE );
		    }
		} elsif ( $fio->{phase} == 0 && !$fio->{full} ) {
		    ##print("Delete file $f\n");
		    $fio->logFileAction("delete", {
				%{$fio->{viewCache}{$d}{$f}},
				name => $name,
			    }) if ( $fio->{logLevel} >= 1 );
		    $fio->{attrib}{$d}->set($f, {
				    type  => BPC_FTYPE_DELETED,
				    mode  => 0,
				    uid   => 0,
				    gid   => 0,
				    size  => 0,
				    mtime => 0,
			       });
		}
	    }
	}
    }
    if ( $fio->{attrib}{$d}->fileCount || $fio->{phase} > 0 ) {
        my $data = $fio->{attrib}{$d}->writeData;
	my $dirM = $d;

	$dirM = $1 . "/" . $fio->{bpc}->fileNameMangle($2)
			if ( $dirM =~ m{(.*?)/(.*)}s );
        my $fileName = $fio->{attrib}{$d}->fileName("$fio->{outDir}$dirM");
	$fio->log("attribWrite(dir=$d) -> $fileName")
				if ( $fio->{logLevel} >= 4 );
        my $poolWrite = BackupPC::PoolWrite->new($fio->{bpc}, $fileName,
                                     length($data), $fio->{xfer}{compress});
        $poolWrite->write(\$data);
        $fio->processClose($poolWrite, $fio->{attrib}{$d}->fileName($dirM),
                           length($data), 0);
    }
    delete($fio->{attrib}{$d});
}

sub processClose
{
    my($fio, $poolWrite, $fileName, $origSize, $doStats) = @_;
    my($exists, $digest, $outSize, $errs) = $poolWrite->close;

    $fileName =~ s{^/+}{};
    if ( defined($errs) && @$errs ) {
        $fio->log(@$errs);
        $fio->{stats}{errorCnt} += @$errs;
    }
    if ( $doStats ) {
	$fio->{stats}{TotalFileCnt}++;
	$fio->{stats}{TotalFileSize} += $origSize;
    }
    if ( $exists ) {
	if ( $doStats ) {
	    $fio->{stats}{ExistFileCnt}++;
	    $fio->{stats}{ExistFileSize}     += $origSize;
	    $fio->{stats}{ExistFileCompSize} += $outSize;
	}
    } elsif ( $outSize > 0 ) {
        my $fh = $fio->{newFilesFH};
        print($fh "$digest $origSize $fileName\n") if ( defined($fh) );
    }
    return $exists && $origSize > 0;
}

sub statsGet
{
    my($fio) = @_;

    return $fio->{stats};
}

#
# Make a given directory.  Returns non-zero on error.
#
sub makePath
{
    my($fio, $f) = @_;
    my $name = $1 if ( $f->{name} =~ /(.*)/s );
    my $path;

    if ( $name eq "." ) {
	$path = $fio->{outDirSh};
    } else {
	$path = $fio->{outDirSh} . $fio->{bpc}->fileNameMangle($name);
    }
    $fio->logFileAction("create", $f) if ( $fio->{logLevel} >= 1 );
    $fio->log("makePath($path, 0777)") if ( $fio->{logLevel} >= 5 );
    $path = $1 if ( $path =~ /(.*)/s );
    eval { File::Path::mkpath($path, 0, 0777) } if ( !-d $path );
    return $fio->attribSet($f) if ( -d $path );
    $fio->log("Can't create directory $path");
    $fio->{stats}{errorCnt}++;
    return -1;
}

#
# Make a special file.  Returns non-zero on error.
#
sub makeSpecial
{
    my($fio, $f) = @_;
    my $name = $1 if ( $f->{name} =~ /(.*)/s );
    my $fNameM = $fio->{bpc}->fileNameMangle($name);
    my $path = $fio->{outDirSh} . $fNameM;
    my $attr = $fio->attribGet($f);
    my $str = "";
    my $type = $fio->mode2type($f);

    $fio->log("makeSpecial($path, $type, $f->{mode})")
		    if ( $fio->{logLevel} >= 5 );
    if ( $type == BPC_FTYPE_CHARDEV || $type == BPC_FTYPE_BLOCKDEV ) {
	my($major, $minor, $fh, $fileData);

        if ( defined($f->{rdev_major}) ) {
            $major = $f->{rdev_major};
            $minor = $f->{rdev_minor};
        } else {
            $major = $f->{rdev} >> 8;
            $minor = $f->{rdev} & 0xff;
        }
        $str = "$major,$minor";
    } elsif ( ($f->{mode} & S_IFMT) == S_IFLNK ) {
        $str = $f->{link};
    } elsif ( ($f->{mode} & S_IFMT) == S_IFREG ) {
        #
        # this is a hardlink
        #
        if ( !defined($f->{hlink}) ) {
            $fio->log("Error: makeSpecial($path, $type, $f->{mode}) called"
                    . " on a regular non-hardlink file");
            return 1;
        }
        $str  = $f->{hlink};
    }
    #
    # Now see if the file is different, or this is a full, in which
    # case we create the new file.
    #
    my($fh, $fileData);
    if ( $fio->{full}
            || !defined($attr)
            || $attr->{type}       != $type
            || $attr->{mtime}      != $f->{mtime}
            || $attr->{size}       != $f->{size}
            || $attr->{uid}        != $f->{uid}
            || $attr->{gid}        != $f->{gid}
            || $attr->{mode}       != $f->{mode}
            || $attr->{hlink_self} != $f->{hlink_self}
            || !defined($fh = BackupPC::FileZIO->open($attr->{fullPath}, 0,
                                                      $attr->{compress}))
            || $fh->read(\$fileData, length($str) + 1) != length($str)
            || $fileData ne $str ) {
        $fh->close if ( defined($fh) );
        $fh = BackupPC::PoolWrite->new($fio->{bpc}, $path,
                                     length($str), $fio->{xfer}{compress});
	$fh->write(\$str);
	my $exist = $fio->processClose($fh, "$fio->{shareM}/$fNameM",
				       length($str), 1);
	$fio->logFileAction($exist ? "pool" : "create", $f)
			    if ( $fio->{logLevel} >= 1 );
	return $fio->attribSet($f);
    } else {
	$fio->logFileAction("skip", $f) if ( $fio->{logLevel} >= 2 );
    }
    $fh->close if ( defined($fh) );
}

#
# Make a hardlink.  Returns non-zero on error.
# This actually gets called twice for each hardlink.
# Once as the file list is processed, and again at
# the end.  BackupPC does them as it goes (since it is
# just saving the hardlink info and not actually making
# hardlinks).
#
sub makeHardLink
{
    my($fio, $f, $end) = @_;

    return if ( $end );
    return $fio->makeSpecial($f) if ( !$f->{hlink_self} );
}

sub unlink
{
    my($fio, $path) = @_;
    
    $fio->log("Unexpected call BackupPC::Xfer::RsyncFileIO->unlink($path)"); 
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
# Handle one or more log messages
#
sub log
{
    my($fio, @logStr) = @_;

    foreach my $str ( @logStr ) {
        next if ( $str eq "" );
        $fio->{logHandler}($str);
    }
}

#
# Generate a log file message for a completed file
#
sub logFileAction
{
    my($fio, $action, $f) = @_;
    my $owner = "$f->{uid}/$f->{gid}";
    my $type  = (("", "p", "c", "", "d", "", "b", "", "", "", "l", "", "s"))
		    [($f->{mode} & S_IFMT) >> 12];
    my $name = $f->{name};

    if ( ($f->{mode} & S_IFMT) == S_IFLNK ) {
        $name .= " -> $f->{link}";
    } elsif ( ($f->{mode} & S_IFMT) == S_IFREG
            && defined($f->{hlink}) && !$f->{hlink_self} ) {
        $name .= " -> $f->{hlink}";
    }
    $name =~ s/\n/\\n/g;

    $fio->log(sprintf("  %-6s %1s%4o %9s %11.0f %s",
				$action,
				$type,
				$f->{mode} & 07777,
				$owner,
				$f->{size},
                                $name));
}

#
# If there is a partial and we are doing a full, we do an incremental
# against the partial and a full against the rest.  This subroutine
# is how we tell File::RsyncP which files to ignore attributes on
# (ie: against the partial dump we do consider the attributes, but
# otherwise we ignore attributes).
#
sub ignoreAttrOnFile
{
    my($fio, $f) = @_;

    return if ( !defined($fio->{partialNum}) );
    my($attr, $isPartial) = $fio->attribGetWhere($f);
    $fio->log("$f->{name}: just checking attributes from partial")
                                if ( $isPartial && $fio->{logLevel} >= 5 );
    return !$isPartial;
}

#
# This is called by File::RsyncP when a file is skipped because the
# attributes match.
#
sub attrSkippedFile
{
    my($fio, $f, $attr) = @_;

    #
    # Unless this is a partial, this is normal so ignore it.
    #
    return if ( !defined($fio->{partialNum}) );

    $fio->log("$f->{name}: skipped in partial; adding link")
                                    if ( $fio->{logLevel} >= 5 );
    $fio->{rxLocalAttr} = $attr;
    $fio->{rxFile} = $f;
    $fio->{rxSize} = $attr->{size};
    delete($fio->{rxInFd});
    delete($fio->{rxOutFd});
    delete($fio->{rxDigest});
    delete($fio->{rxInData});
    return $fio->fileDeltaRxDone();
}

#
# Start receive of file deltas for a particular file.
#
sub fileDeltaRxStart
{
    my($fio, $f, $cnt, $size, $remainder) = @_;

    $fio->{rxFile}      = $f;           # remote file attributes
    $fio->{rxLocalAttr} = $fio->attribGet($f); # local file attributes
    $fio->{rxBlkCnt}    = $cnt;         # how many blocks we will receive
    $fio->{rxBlkSize}   = $size;        # block size
    $fio->{rxRemainder} = $remainder;   # size of the last block
    $fio->{rxMatchBlk}  = 0;            # current start of match
    $fio->{rxMatchNext} = 0;            # current next block of match
    $fio->{rxSize}      = 0;            # size of received file
    my $rxSize = $cnt > 0 ? ($cnt - 1) * $size + $remainder : 0;
    if ( $fio->{rxFile}{size} != $rxSize ) {
        $fio->{rxMatchBlk} = undef;     # size different, so no file match
        $fio->log("$fio->{rxFile}{name}: size doesn't match"
                  . " ($fio->{rxFile}{size} vs $rxSize)")
                        if ( $fio->{logLevel} >= 5 );
    }
    #
    # If compression was off and now on, or on and now off, then
    # don't do an exact match.
    #
    if ( defined($fio->{rxLocalAttr})
	    && !$fio->{rxLocalAttr}{compress} != !$fio->{xfer}{compress} ) {
        $fio->{rxMatchBlk} = undef;     # compression changed, so no file match
        $fio->log("$fio->{rxFile}{name}: compression changed, so no match"
              . " ($fio->{rxLocalAttr}{compress} vs $fio->{xfer}{compress})")
                    if ( $fio->{logLevel} >= 4 );
    }
    #
    # If the local file is a hardlink then no match
    #
    if ( defined($fio->{rxLocalAttr})
	    && $fio->{rxLocalAttr}{type} == BPC_FTYPE_HARDLINK ) {
        $fio->{rxMatchBlk} = undef;
        $fio->log("$fio->{rxFile}{name}: no match on hardlinks")
                                    if ( $fio->{logLevel} >= 4 );
        my $fCopy;
        # need to copy since hardlink attribGet overwrites the name
        %{$fCopy} = %$f;
        $fio->{rxHLinkAttr} = $fio->attribGet($fCopy, 1); # hardlink attributes
    } else {
        delete($fio->{rxHLinkAttr});
    }
    delete($fio->{rxInFd});
    delete($fio->{rxOutFd});
    delete($fio->{rxDigest});
    delete($fio->{rxInData});
}

#
# Process the next file delta for the current file.  Returns 0 if ok,
# -1 if not.  Must be called with either a block number, $blk, or new data,
# $newData, (not both) defined.
#
sub fileDeltaRxNext
{
    my($fio, $blk, $newData) = @_;

    if ( defined($blk) ) {
        if ( defined($fio->{rxMatchBlk}) && $fio->{rxMatchNext} == $blk ) {
            #
            # got the next block in order; just keep track.
            #
            $fio->{rxMatchNext}++;
            return;
        }
    }
    my $newDataLen = length($newData);
    $fio->log("$fio->{rxFile}{name}: blk=$blk, newData=$newDataLen, rxMatchBlk=$fio->{rxMatchBlk}, rxMatchNext=$fio->{rxMatchNext}")
		    if ( $fio->{logLevel} >= 8 );
    if ( !defined($fio->{rxOutFd}) ) {
	#
	# maybe the file has no changes
	#
	if ( $fio->{rxMatchNext} == $fio->{rxBlkCnt}
		&& !defined($blk) && !defined($newData) ) {
	    #$fio->log("$fio->{rxFile}{name}: file is unchanged");
	    #		    if ( $fio->{logLevel} >= 8 );
	    return;
	}

        #
        # need to open an output file where we will build the
        # new version.
        #
        $fio->{rxFile}{name} =~ /(.*)/s;
	my $rxOutFileRel = "$fio->{shareM}/" . $fio->{bpc}->fileNameMangle($1);
        my $rxOutFile    = $fio->{outDir} . $rxOutFileRel;
        $fio->{rxOutFd}  = BackupPC::PoolWrite->new($fio->{bpc},
					   $rxOutFile, $fio->{rxFile}{size},
                                           $fio->{xfer}{compress});
        $fio->log("$fio->{rxFile}{name}: opening output file $rxOutFile")
                        if ( $fio->{logLevel} >= 9 );
        $fio->{rxOutFile} = $rxOutFile;
        $fio->{rxOutFileRel} = $rxOutFileRel;
        $fio->{rxDigest} = File::RsyncP::Digest->new();
        $fio->{rxDigest}->protocol($fio->{protocol_version});
        $fio->{rxDigest}->add(pack("V", $fio->{checksumSeed}));
    }
    if ( defined($fio->{rxMatchBlk})
                && $fio->{rxMatchBlk} != $fio->{rxMatchNext} ) {
        #
        # Need to copy the sequence of blocks that matched.  If the file
        # is compressed we need to make a copy of the uncompressed file,
        # since the compressed file is not seekable.  Future optimizations
        # could include only creating an uncompressed copy if the matching
        # blocks were not monotonic, and to only do this if there are
        # matching blocks (eg, maybe the entire file is new).
        #
        my $attr = $fio->{rxLocalAttr};
	my $fh;
        if ( !defined($fio->{rxInFd}) && !defined($fio->{rxInData}) ) {
            my $inPath = $attr->{fullPath};
            $inPath = $fio->{rxHLinkAttr}{fullPath}
                            if ( defined($fio->{rxHLinkAttr}) );
            if ( $attr->{compress} ) {
                if ( !defined($fh = BackupPC::FileZIO->open(
                                                   $inPath,
                                                   0,
                                                   $attr->{compress})) ) {
                    $fio->log("Can't open $inPath");
		    $fio->{stats}{errorCnt}++;
                    return -1;
                }
                if ( $attr->{size} < 16 * 1024 * 1024 ) {
                    #
                    # Cache the entire old file if it is less than 16MB
                    #
                    my $data;
                    $fio->{rxInData} = "";
                    while ( $fh->read(\$data, 16 * 1024 * 1024) > 0 ) {
                        $fio->{rxInData} .= $data;
                    }
		    $fio->log("$attr->{fullPath}: cached all $attr->{size}"
			    . " bytes")
				    if ( $fio->{logLevel} >= 9 );
                } else {
                    #
                    # Create and write a temporary output file
                    #
                    unlink("$fio->{outDirSh}RStmp")
                                    if  ( -f "$fio->{outDirSh}RStmp" );
                    if ( open(F, "+>", "$fio->{outDirSh}RStmp") ) {
                        my $data;
			my $byteCnt = 0;
			binmode(F);
                        while ( $fh->read(\$data, 1024 * 1024) > 0 ) {
                            if ( syswrite(F, $data) != length($data) ) {
                                $fio->log(sprintf("Can't write len=%d to %s",
				      length($data) , "$fio->{outDirSh}RStmp"));
                                $fh->close;
				$fio->{stats}{errorCnt}++;
                                return -1;
                            }
			    $byteCnt += length($data);
                        }
                        $fio->{rxInFd} = *F;
                        $fio->{rxInName} = "$fio->{outDirSh}RStmp";
                        sysseek($fio->{rxInFd}, 0, 0);
			$fio->log("$attr->{fullPath}: copied $byteCnt,"
				. "$attr->{size} bytes to $fio->{rxInName}")
					if ( $fio->{logLevel} >= 9 );
                    } else {
                        $fio->log("Unable to open $fio->{outDirSh}RStmp");
                        $fh->close;
			$fio->{stats}{errorCnt}++;
                        return -1;
                    }
                }
                $fh->close;
            } else {
                if ( open(F, "<", $inPath) ) {
		    binmode(F);
                    $fio->{rxInFd} = *F;
                    $fio->{rxInName} = $attr->{fullPath};
                } else {
                    $fio->log("Unable to open $inPath");
		    $fio->{stats}{errorCnt}++;
                    return -1;
                }
            }
        }
	my $lastBlk = $fio->{rxMatchNext} - 1;
        $fio->log("$fio->{rxFile}{name}: writing blocks $fio->{rxMatchBlk}.."
                  . "$lastBlk")
                        if ( $fio->{logLevel} >= 9 );
        my $seekPosn = $fio->{rxMatchBlk} * $fio->{rxBlkSize};
        if ( defined($fio->{rxInFd})
			&& !sysseek($fio->{rxInFd}, $seekPosn, 0) ) {
            $fio->log("Unable to seek $fio->{rxInName} to $seekPosn");
	    $fio->{stats}{errorCnt}++;
            return -1;
        }
        my $cnt = $fio->{rxMatchNext} - $fio->{rxMatchBlk};
        my($thisCnt, $len, $data);
        for ( my $i = 0 ; $i < $cnt ; $i += $thisCnt ) {
            $thisCnt = $cnt - $i;
            $thisCnt = 512 if ( $thisCnt > 512 );
            if ( $fio->{rxMatchBlk} + $i + $thisCnt == $fio->{rxBlkCnt} ) {
                $len = ($thisCnt - 1) * $fio->{rxBlkSize} + $fio->{rxRemainder};
            } else {
                $len = $thisCnt * $fio->{rxBlkSize};
            }
            if ( defined($fio->{rxInData}) ) {
                $data = substr($fio->{rxInData}, $seekPosn, $len);
		$seekPosn += $len;
            } else {
		my $got = sysread($fio->{rxInFd}, $data, $len);
                if ( $got != $len ) {
		    my $inFileSize = -s $fio->{rxInName};
                    $fio->log("Unable to read $len bytes from $fio->{rxInName}"
                            . " got=$got, seekPosn=$seekPosn"
                            . " ($i,$thisCnt,$fio->{rxBlkCnt},$inFileSize"
			    . ",$attr->{size})");
		    $fio->{stats}{errorCnt}++;
                    return -1;
                }
		$seekPosn += $len;
            }
            $fio->{rxOutFd}->write(\$data);
            $fio->{rxDigest}->add($data);
	    $fio->{rxSize} += length($data);
        }
        $fio->{rxMatchBlk} = undef;
    }
    if ( defined($blk) ) {
        #
        # Remember the new block number
        #
        $fio->{rxMatchBlk}  = $blk;
        $fio->{rxMatchNext} = $blk + 1;
    }
    if ( defined($newData) ) {
        #
        # Write the new chunk
        #
        my $len = length($newData);
        $fio->log("$fio->{rxFile}{name}: writing $len bytes new data")
                        if ( $fio->{logLevel} >= 9 );
        $fio->{rxOutFd}->write(\$newData);
        $fio->{rxDigest}->add($newData);
	$fio->{rxSize} += length($newData);
    }
}

#
# Finish up the current receive file.  Returns undef if ok, -1 if not.
# Returns 1 if the md4 digest doesn't match.
#
sub fileDeltaRxDone
{
    my($fio, $md4, $phase) = @_;
    my $name = $1 if ( $fio->{rxFile}{name} =~ /(.*)/s );
    my $ret;

    close($fio->{rxInFd})  if ( defined($fio->{rxInFd}) );
    unlink("$fio->{outDirSh}RStmp") if  ( -f "$fio->{outDirSh}RStmp" );
    $fio->{phase} = $phase;

    #
    # Check the final md4 digest
    #
    if ( defined($md4) ) {
        my $newDigest;
        if ( !defined($fio->{rxDigest}) ) {
            #
            # File was exact match, but we still need to verify the
            # MD4 checksum.  Compute the md4 digest (or fetch the
            # cached one.)
            #
            if ( defined(my $attr = $fio->{rxLocalAttr}) ) {
                #
                # block size doesn't matter: we're only going to
                # fetch the md4 file digest, not the block digests.
                #
                my($err, $csum, $blkSize)
                         = BackupPC::Xfer::RsyncDigest->digestStart(
                                 $attr->{fullPath}, $attr->{size},
                                 0, 2048, $fio->{checksumSeed}, 1,
                                 $attr->{compress}, 1,
                                 $fio->{protocol_version});
                if ( $err ) {
                    $fio->log("Can't open $attr->{fullPath} for MD4"
                            . " check (err=$err, $name)");
                    $fio->{stats}{errorCnt}++;
                } else {
                    if ( $fio->{logLevel} >= 5 ) {
                        my($isCached, $invalid) = $csum->isCached;
                        $fio->log("MD4 $attr->{fullPath} cache = $isCached,"
                                . " invalid = $invalid");
                    }
                    $newDigest = $csum->digestEnd;
                }
                $fio->{rxSize} = $attr->{size};
            } else {
		#
		# Empty file; just create an empty file digest
		#
		$fio->{rxDigest} = File::RsyncP::Digest->new();
                $fio->{rxDigest}->protocol($fio->{protocol_version});
		$fio->{rxDigest}->add(pack("V", $fio->{checksumSeed}));
		$newDigest = $fio->{rxDigest}->digest;
	    }
            $fio->log("$name got exact match") if ( $fio->{logLevel} >= 5 );
        } else {
            $newDigest = $fio->{rxDigest}->digest;
        }
        if ( $fio->{logLevel} >= 3 ) {
            my $md4Str = unpack("H*", $md4);
            my $newStr = unpack("H*", $newDigest);
            $fio->log("$name got digests $md4Str vs $newStr")
        }
        if ( $md4 ne $newDigest ) {
            if ( $phase > 0 ) {
                $fio->log("$name: fatal error: md4 doesn't match on retry;"
                        . " file removed");
                $fio->{stats}{errorCnt}++;
            } else {
                $fio->log("$name: md4 doesn't match: will retry in phase 1;"
                        . " file removed");
            }
            if ( defined($fio->{rxOutFd}) ) {
                $fio->{rxOutFd}->close;
                unlink($fio->{rxOutFile});
            }
            delete($fio->{rxFile});
	    delete($fio->{rxOutFile});
            return 1;
        }
    }

    #
    # One special case is an empty file: if the file size is
    # zero we need to open the output file to create it.
    #
    if ( $fio->{rxSize} == 0 ) {
	my $rxOutFileRel = "$fio->{shareM}/"
			 . $fio->{bpc}->fileNameMangle($name);
        my $rxOutFile    = $fio->{outDir} . $rxOutFileRel;
        $fio->{rxOutFd}  = BackupPC::PoolWrite->new($fio->{bpc},
					   $rxOutFile, $fio->{rxSize},
                                           $fio->{xfer}{compress});
    }
    if ( !defined($fio->{rxOutFd}) ) {
        #
        # No output file, meaning original was an exact match.
        #
        $fio->log("$name: nothing to do")
                        if ( $fio->{logLevel} >= 5 );
        my $attr = $fio->{rxLocalAttr};
        my $f = $fio->{rxFile};
	$fio->logFileAction("same", $f) if ( $fio->{logLevel} >= 1 );
        if ( $fio->{full}
                || $attr->{type}       != $f->{type}
                || $attr->{mtime}      != $f->{mtime}
                || $attr->{size}       != $f->{size}
                || $attr->{uid}        != $f->{uid}
                || $attr->{gid}        != $f->{gid}
                || $attr->{mode}       != $f->{mode}
                || $attr->{hlink_self} != $f->{hlink_self} ) {
            #
            # In the full case, or if the attributes are different,
            # we need to make a link from the previous file and
            # set the attributes.
            #
            my $rxOutFile = $fio->{outDirSh}
                            . $fio->{bpc}->fileNameMangle($name);
            my($exists, $digest, $origSize, $outSize, $errs)
                                = BackupPC::PoolWrite::LinkOrCopy(
                                      $fio->{bpc},
                                      $attr->{fullPath},
                                      $attr->{compress},
                                      $rxOutFile,
                                      $fio->{xfer}{compress});
            #
            # Cumulate the stats
            #
            $fio->{stats}{TotalFileCnt}++;
            $fio->{stats}{TotalFileSize} += $fio->{rxSize};
            $fio->{stats}{ExistFileCnt}++;
            $fio->{stats}{ExistFileSize} += $fio->{rxSize};
            $fio->{stats}{ExistFileCompSize} += -s $rxOutFile;
            $fio->{rxFile}{size} = $fio->{rxSize};
            $ret = $fio->attribSet($fio->{rxFile});
            $fio->log(@$errs) if ( defined($errs) && @$errs );

            if ( !$exists && $outSize > 0 ) {
                #
                # the hard link failed, most likely because the target
                # file has too many links.  We have copied the file
                # instead, so add this to the new file list.
                #
                my $rxOutFileRel = "$fio->{shareM}/"
                                 . $fio->{bpc}->fileNameMangle($name);
                $rxOutFileRel =~ s{^/+}{};
                my $fh = $fio->{newFilesFH};
                print($fh "$digest $origSize $rxOutFileRel\n")
                                                if ( defined($fh) );
            }
        }
    } else {
	my $exist = $fio->processClose($fio->{rxOutFd},
				       $fio->{rxOutFileRel},
				       $fio->{rxSize}, 1);
	$fio->logFileAction($exist ? "pool" : "create", $fio->{rxFile})
			    if ( $fio->{logLevel} >= 1 );
	$fio->{rxFile}{size} = $fio->{rxSize};
	$ret = $fio->attribSet($fio->{rxFile});
    }
    delete($fio->{rxDigest});
    delete($fio->{rxInData});
    delete($fio->{rxFile});
    delete($fio->{rxOutFile});
    return $ret;
}

#
# Callback function for BackupPC::View->find.  Note the order of the
# first two arguments.
#
sub fileListEltSend
{
    my($a, $fio, $fList, $outputFunc) = @_;
    my $name = $a->{relPath};
    my $n = $name;
    my $type = $a->{type};
    my $extraAttribs = {};

    if ( $a->{mode} & S_HLINK_TARGET ) {
        $a->{hlink_self} = 1;
        $a->{mode} &= ~S_HLINK_TARGET;
    }
    $n =~ s/^\Q$fio->{xfer}{pathHdrSrc}//;
    $fio->log("Sending $name (remote=$n) type = $type") if ( $fio->{logLevel} >= 1 );
    if ( $type == BPC_FTYPE_CHARDEV
	    || $type == BPC_FTYPE_BLOCKDEV
	    || $type == BPC_FTYPE_SYMLINK ) {
	my $fh = BackupPC::FileZIO->open($a->{fullPath}, 0, $a->{compress});
	my($str, $rdSize);
	if ( defined($fh) ) {
	    $rdSize = $fh->read(\$str, $a->{size} + 1024);
	    if ( $type == BPC_FTYPE_SYMLINK ) {
		#
		# Reconstruct symbolic link
		#
		$extraAttribs = { link => $str };
		if ( $rdSize != $a->{size} ) {
		    # ERROR
		    $fio->log("$name: can't read exactly $a->{size} bytes");
		    $fio->{stats}{errorCnt}++;
		}
	    } elsif ( $str =~ /(\d*),(\d*)/ ) {
		#
		# Reconstruct char or block special major/minor device num
		#
		# Note: char/block devices have $a->{size} = 0, so we
		# can't do an error check on $rdSize.
		#
		$extraAttribs = {
                    rdev       => $1 * 256 + $2,
                    rdev_major => $1,
                    rdev_minor => $2,
                };
	    } else {
		$fio->log("$name: unexpected special file contents $str");
		$fio->{stats}{errorCnt}++;
	    }
	    $fh->close;
	} else {
	    # ERROR
	    $fio->log("$name: can't open");
	    $fio->{stats}{errorCnt}++;
	}
    } elsif ( $fio->{preserve_hard_links}
            && ($type == BPC_FTYPE_HARDLINK || $type == BPC_FTYPE_FILE)
            && ($type == BPC_FTYPE_HARDLINK
                    || $fio->{protocol_version} < 27
                    || $a->{hlink_self}) ) {
        #
        # Fill in fake inode information so that the remote rsync
        # can correctly create hardlinks.
        #
        $name =~ s/^\.?\/+//;
        my($target, $inode);

        if ( $type == BPC_FTYPE_HARDLINK ) {
            my $fh = BackupPC::FileZIO->open($a->{fullPath}, 0,
                                             $a->{compress});
            if ( defined($fh) ) {
                $fh->read(\$target,  65536);
                $fh->close;
                $target =~ s/^\.?\/+//;
                if ( defined($fio->{hlinkFile2Num}{$target}) ) {
                    $inode = $fio->{hlinkFile2Num}{$target};
                } else {
                    $inode = $fio->{fileListCnt};
                    $fio->{hlinkFile2Num}{$target} = $inode;
                }
            } else {
                $fio->log("$a->{fullPath}: can't open for hardlink");
                $fio->{stats}{errorCnt}++;
            }
        } elsif ( $a->{hlink_self} ) {
            if ( defined($fio->{hlinkFile2Num}{$name}) ) {
                $inode = $fio->{hlinkFile2Num}{$name};
            } else {
                $inode = $fio->{fileListCnt};
                $fio->{hlinkFile2Num}{$name} = $inode;
            }
        }
        $inode = $fio->{fileListCnt} if ( !defined($inode) );
        $fio->log("$name: setting inode to $inode");
        $extraAttribs = {
            %$extraAttribs,
            dev   => 0,
            inode => $inode,
        };
    }
    my $f = {
        name  => $n,
        mode  => $a->{mode} & ~S_HLINK_TARGET,
        uid   => $a->{uid},
        gid   => $a->{gid},
        mtime => $a->{mtime},
        size  => $a->{size},
        %$extraAttribs,
    };
    my $logName = $f->{name};
    from_to($f->{name}, "utf8", $fio->{clientCharset})
                            if ( $fio->{clientCharset} ne "" );
    $fList->encode($f);

    $logName = "$fio->{xfer}{pathHdrDest}/$logName";
    $logName =~ s{//+}{/}g;
    $f->{name} = $logName;
    $fio->logFileAction("restore", $f) if ( $fio->{logLevel} >= 1 );

    &$outputFunc($fList->encodeData);
    #
    # Cumulate stats
    #
    $fio->{fileListCnt}++;
    if ( $type != BPC_FTYPE_DIR ) {
	$fio->{stats}{TotalFileCnt}++;
	$fio->{stats}{TotalFileSize} += $a->{size};
    }
}

sub fileListSend
{
    my($fio, $flist, $outputFunc) = @_;

    #
    # Populate the file list with the files requested by the user.
    # Since some might be directories so we call BackupPC::View::find.
    #
    $fio->log("fileListSend: sending file list: "
	     . join(" ", @{$fio->{fileList}})) if ( $fio->{logLevel} >= 4 );
    $fio->{fileListCnt} = 0;
    $fio->{hlinkFile2Num} = {};
    foreach my $name ( @{$fio->{fileList}} ) {
	$fio->{view}->find($fio->{xfer}{bkupSrcNum},
			   $fio->{xfer}{bkupSrcShare},
			   $name, 1,
			   \&fileListEltSend, $fio, $flist, $outputFunc);
    }
}

sub finish
{
    my($fio, $isChild) = @_;

    #
    # If we are aborting early, remove the last file since
    # it was not complete
    #
    if ( $isChild && defined($fio->{rxFile}) ) {
	unlink("$fio->{outDirSh}RStmp") if  ( -f "$fio->{outDirSh}RStmp" );
	if ( defined($fio->{rxFile}) ) {
	    unlink($fio->{rxOutFile});
	    $fio->log("finish: removing in-process file $fio->{rxFile}{name}");
	}
    }

    #
    # Flush the attributes if this is the child
    #
    $fio->attribWrite(undef) if ( $isChild );
}

#sub is_tainted
#{
#    return ! eval {
#        join('',@_), kill 0;
#        1;
#    };
#}

1;
