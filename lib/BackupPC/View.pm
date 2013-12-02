#============================================================= -*-perl-*-
#
# BackupPC::View package
#
# DESCRIPTION
#
#   This library defines a BackupPC::View class for merging of
#   incremental backups and file attributes.  This provides the
#   caller with a single view of a merged backup, without worrying
#   about which backup contributes which files.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
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

package BackupPC::View;

use strict;

use File::Path;
use BackupPC::Lib;
use BackupPC::XS qw( :all );
use BackupPC::DirOps qw( :BPC_DT_ALL );
use Data::Dumper;
use Encode qw/from_to/;

sub new
{
    my($class, $bpc, $host, $backups, $options) = @_;
    my $m = bless {
        bpc       => $bpc,	# BackupPC::Lib object
        host      => $host,	# host name
        backups   => $backups,	# all backups for this host
	num       => -1,	# backup number
        idx       => -1,	# index into backups for backup
				#   we are viewing
        dirPath   => undef,	# path to current directory
        dirAttr   => undef,	# attributes of current directory
        dirOpts   => $options,  # $options is a hash of file attributes we need:
                                # type, inode, or nlink.  If set, these parameters
                                # are added to the returned hash.
                                # See BackupPC::DirOps::dirRead().
        error     => [],
    }, $class;
    $m->{topDir} = $m->{bpc}->TopDir();
    return $m;
}

#
# Check if a directory exists in the given backup.
# This is only for >= 4.x backups.
#
sub dirExists
{
    my($m, $idx, $share, $dir) = @_;
    my $last = 0;

    #
    # We need to look up up each level until we find an
    # attrib file that exists.
    #
    my $backupNum = $m->{backups}[$idx]{num};
    my $compress  = $m->{backups}[$idx]{compress};
    my $topPath   = "$m->{topDir}/pc/$m->{host}/$backupNum/";
    while ( !$last ) {
        my($file, $p);
        if ( $dir =~ m{(.*)/(.*)} ) {
            #
            # Normal subdirectory or top-level directory
            #
            $dir  = $1;
            $file = $2;
            $p    = $topPath . $m->{bpc}->fileNameEltMangle($share);
            $p   .= $m->{bpc}->fileNameMangle($dir) if ( length($dir) );
        } else {
            #
            # Check that the share exists in this backup;
            # if not then any subdirectory must be empty.
            #
            $p    = $topPath;
            $file = $share;
            $last = 1;
        }
        next if ( !-d $p );
        my $attr = BackupPC::XS::Attrib::new($compress);
        next if ( !-f "$p/attrib" );
        if ( !$attr->read($p) ) {
            push(@{$m->{error}}, "Can't read attribute file in $p: " . $attr->errStr());
            next;
        }
        # TODO!!! check this.
        my $a = $attr->get($file);
        return 0 if ( $a->{type} != BPC_FTYPE_DIR );
        return 1;
    }
    return 1;
}

sub hardLinkGet
{
    my($m, $a, $i) = @_;

    if ( !$m->{attribCache}[$i] ) {
        $m->{attribCache}[$i] = BackupPC::XS::AttribCache::new($m->{host},
                                      $m->{backups}[$i]{num}, "",
                                      $m->{backups}[$i]{compress});
    }
    my $newAttrib = $m->{attribCache}[$i]->getInode($a->{inode});
    return $a if ( !$newAttrib );
    $newAttrib = { %$newAttrib };
    $newAttrib->{name} = $a->{name};
    return $newAttrib;
}

sub dirCache
{
    my($m, $backupNum, $share, $dir) = @_;
    my($i, $level);

    #print STDERR "dirCache($backupNum, $share, $dir)\n";
    $dir = "/$dir" if ( $dir !~ m{^/} );
    $dir =~ s{/+$}{};
    return if ( $m->{num} == $backupNum
                && $m->{share} eq $share
                && defined($m->{dir})
                && $m->{dir} eq $dir );

    $m->backupNumCache($backupNum) if ( $m->{num} != $backupNum );
    return if ( $m->{idx} < 0 );

    $m->{files} = {};
    $level = $m->{backups}[$m->{idx}]{level} + 1;

    #
    # Remember the requested share and dir
    #
    $m->{share} = $share;
    $m->{dir} = $dir;

    if ( $m->{backups}[$m->{idx}]{version} < 4 ) {
        #
        # Pre-4.x backup: merge backups, starting at the requested one,
        # and working backwards merging each backup of lower level
        # until we finish with a level 0 backup (ie: a full).
        #
        # In pre-4.x backups the full directory tree exists for all
        # backups, even incrementals.
        #
        $m->{mergeNums} = [];
        for ( $i = $m->{idx} ; $level > 0 && $i >= 0 ; $i-- ) {
            #print(STDERR "Do $i ($m->{backups}[$i]{noFill},$m->{backups}[$i]{level})\n");
            #
            # skip backups with the same or higher level
            #
            next if ( $m->{backups}[$i]{level} >= $level );

            $level = $m->{backups}[$i]{level};
            $backupNum = $m->{backups}[$i]{num};
            push(@{$m->{mergeNums}}, $backupNum);
            my $mangle   = $m->{backups}[$i]{mangle};
            my $compress = $m->{backups}[$i]{compress};
            my $path     = "$m->{topDir}/pc/$m->{host}/$backupNum/";
            my $legacyCharset = $m->{backups}[$i]{version} < 3.0;
            my $sharePathM;
            if ( $mangle ) {
                $sharePathM = $m->{bpc}->fileNameEltMangle($share)
                            . $m->{bpc}->fileNameMangle($dir);
            } else {
                $sharePathM = $share . $dir;
            }
            $path .= $sharePathM;
            #print(STDERR "Opening $path (share=$share, mangle=$mangle)\n");

            my $dirOpts      = { %{$m->{dirOpts} || {} } };
            my $attribOpts   = { };
            if ( $legacyCharset ) {
                $dirOpts->{charsetLegacy}
                        = $attribOpts->{charsetLegacy}
                        = $m->{bpc}->{Conf}{ClientCharsetLegacy} || "iso-8859-1";
            }

            my $dirInfo = BackupPC::DirOps::dirRead($m->{bpc}, $path, $dirOpts);
            if ( !defined($dirInfo) ) {
                if ( $i == $m->{idx} ) {
                    #
                    # Oops, directory doesn't exist.
                    #
                    $m->{files} = undef;
                    return;
                }
                next;
            }
            my $attr;
            if ( $mangle ) {
                # TODO: removed charset attribOpts - need to do at this level?
                $attr = BackupPC::XS::Attrib::new($compress);
                if ( !$attr->read($path) ) {
                    push(@{$m->{error}}, "Can't read attribute file in $path\n");
                    $attr = undef;
                }
            }
            foreach my $entry ( @$dirInfo ) {
                my $file = $1 if ( $entry->{name} =~ /(.*)/s );
                my $fileUM = $file;
                $fileUM = $m->{bpc}->fileNameUnmangle($fileUM) if ( $mangle );
                #print(STDERR "Doing $fileUM\n");
                #
                # skip special files
                #
                next if ( defined($m->{files}{$fileUM})
                        || $file eq ".."
                        || $file eq "."
                        || $file eq "backupInfo"
                        || $mangle && $file eq "attrib" );

                if ( defined($attr) && defined(my $a = $attr->get($fileUM)) ) {
                    $m->{files}{$fileUM} = $a;
                    #
                    # skip directories in earlier backups (each backup always
                    # has the complete directory tree).
                    #
                    next if ( $i < $m->{idx} && $a->{type} == BPC_FTYPE_DIR );
                    $attr->delete($fileUM);
                } else {
                    #
                    # Very expensive in the non-attribute case when compresseion
                    # is on.  We have to stat the file and read compressed files
                    # to determine their size.
                    #
                    my $realPath = "$path/$file";

                    from_to($realPath, "utf8", $attribOpts->{charsetLegacy})
                                    if ( $attribOpts->{charsetLegacy} ne "" );

                    my @s = stat($realPath);
                    next if ( $i < $m->{idx} && -d _ );
                    $m->{files}{$fileUM} = {
                        type  => -d _ ? BPC_FTYPE_DIR : BPC_FTYPE_FILE,
                        mode  => $s[2],
                        uid   => $s[4],
                        gid   => $s[5],
                        size  => -f _ ? $s[7] : 0,
                        mtime => $s[9],
                    };
                    if ( $compress && -f _ ) {
                        #
                        # Compute the correct size by reading the whole file
                        #
                        my $f = BackupPC::XS::FileZIO::open($realPath, 0, $compress);
                        if ( !defined($f) ) {
                            push(@{$m->{error}}, "Can't open $realPath");
                        } else {
                            my($data, $size);
                            while ( $f->read(\$data, 65636 * 8) > 0 ) {
                                $size += length($data);
                            }
                            $f->close;
                            $m->{files}{$fileUM}{size} = $size;
                        }
                    }
                }
                ($m->{files}{$fileUM}{relPath}    = "$dir/$fileUM") =~ s{//+}{/}g;
                ($m->{files}{$fileUM}{sharePathM} = "$sharePathM/$file")
                                                                   =~ s{//+}{/}g;
                ($m->{files}{$fileUM}{fullPath}   = "$path/$file") =~ s{//+}{/}g;
                from_to($m->{files}{$fileUM}{fullPath}, "utf8", $attribOpts->{charsetLegacy})
                                    if ( $attribOpts->{charsetLegacy} ne "" );
                $m->{files}{$fileUM}{backupNum}   = $backupNum;
                $m->{files}{$fileUM}{compress}    = $compress;
                $m->{files}{$fileUM}{nlink}       = $entry->{nlink}
                                                        if ( $m->{dirOpts}{nlink} );
                $m->{files}{$fileUM}{inode}       = $entry->{inode}
                                                        if ( $m->{dirOpts}{inode} );
            }
            #
            # Also include deleted files
            #
            if ( defined($attr) ) {
                my $a = $attr->get;
                foreach my $fileUM ( keys(%$a) ) {
                    next if ( $a->{$fileUM}{type} != BPC_FTYPE_DELETED );
                    my $file = $fileUM;
                    $file = $m->{bpc}->fileNameMangle($fileUM) if ( $mangle );
                    $m->{files}{$fileUM}             = $a->{$fileUM};
                    $m->{files}{$fileUM}{relPath}    = "$dir/$fileUM";
                    $m->{files}{$fileUM}{sharePathM} = "$sharePathM/$file";
                    $m->{files}{$fileUM}{fullPath}   = "$path/$file";
                    from_to($m->{files}{$fileUM}{fullPath}, "utf8", $attribOpts->{charsetLegacy})
                                        if ( $attribOpts->{charsetLegacy} ne "" );
                    $m->{files}{$fileUM}{backupNum}  = $backupNum;
                    $m->{files}{$fileUM}{compress}   = $compress;
                    $m->{files}{$fileUM}{nlink}      = 0;
                    $m->{files}{$fileUM}{inode}      = 0;
                }
            }
            #
            # Prune deleted files
            #
            foreach my $file ( keys(%{$m->{files}}) ) {
                next if ( $m->{files}{$file}{type} != BPC_FTYPE_DELETED );
                delete($m->{files}{$file});
            }
        }
    } else {
        #
        # 4.x+ backup: merge backups, starting at the first filled backup
        # at or later than the one we are viewing (most commonly the last)
        # and working backwards until we finish with the requested backup.
        #
        # In 4.x+ backups the full directory tree exists in the last backup.
        # Prior backups might be filled to improve viewing speed.  Non-filled backup
        # trees only have directories where some part of the backup has changed.
        #
        # First find the oldest filled backup at or after idx.
        #
        my $oldestFilled = @{$m->{backups}} - 1;
        for ( $i = $m->{idx} ; $i < @{$m->{backups}} ; $i++ ) {
            next if ( $m->{backups}[$i]{noFill} );
            $oldestFilled = $i;
            last;
        }
        $m->{mergeNums} = [];
        my $hardlinks = {};
        for ( $i = $oldestFilled ; $i >= $m->{idx} ; $i-- ) {
            #print(STDERR "Do $i ($m->{backups}[$i]{noFill},$m->{backups}[$i]{level})\n");

            $backupNum = $m->{backups}[$i]{num};
            push(@{$m->{mergeNums}}, $backupNum);
            my $mangle     = $m->{backups}[$i]{mangle};
            my $compress   = $m->{backups}[$i]{compress};
            my $topPath    = "$m->{topDir}/pc/$m->{host}/$backupNum/";
            my $sharePathM = $m->{bpc}->fileNameEltMangle($share)
                           . $m->{bpc}->fileNameMangle($dir);
            my $path = $topPath . $sharePathM;
            #print(STDERR "Opening $path (share=$share, mangle=$mangle)\n");

            my $dirOpts      = { %{$m->{dirOpts} || {} } };
            my $attribOpts   = { compress => $compress };

            if ( !-d $path && $i == $oldestFilled ) {
                #
                # if this is the last backup then the directory is empty
                #
                #print(STDERR "Path $path isn't a directory\n");
                next;
            }

            my $attr = BackupPC::XS::Attrib::new($compress);
            my $attrAll;
            if ( -f "$path/attrib" ) {
                if ( !$attr->read($path, "attrib") ) {
                    push(@{$m->{error}}, "Can't read attribute file in $path\n");
                } else {
                    #print(STDERR "Got attr\n");
                    $attrAll = $attr->get();
                    foreach my $fileUM ( keys(%$attrAll) ) {
                        my $a = $attrAll->{$fileUM};
                        if ( $a->{type} == BPC_FTYPE_DELETED ) {
                            #print("deleting $fileUM\n");
                            delete($m->{files}{$fileUM});
                            delete($hardlinks->{$fileUM});
                            next;
                        }
                        if ( $a->{nlinks} > 0 ) {
                            $a = $m->hardLinkGet($a, $i);
                            $hardlinks->{$fileUM} = 1;
                        }

                        $m->{files}{$fileUM}               = $a;
                        ($m->{files}{$fileUM}{relPath}     = "$dir/$fileUM") =~ s{//+}{/}g;
                        if ( length($a->{digest}) ) {
                            $m->{files}{$fileUM}{fullPath} = $m->{bpc}->MD52Path($a->{digest},
                                                                                 $compress);
                        } else {
                            $m->{files}{$fileUM}{fullPath} = "/dev/null";
                        }
                        $m->{files}{$fileUM}{backupNum}    = $backupNum;
                        $m->{files}{$fileUM}{compress}     = $compress;
                        $m->{files}{$fileUM}{inode}        = $a->{inode};
                    }
                }
            }

            #
            # Update any inode information specific to this backup
            # for hardlinks in this directory
            #
            foreach my $f ( keys(%$hardlinks) ) {
                next if ( !$m->{files}{$f} || $m->{files}{$f}{backupNum} == $backupNum );
                my $a = $m->hardLinkGet($m->{files}{$f}, $i);
                next if ( $a == $m->{files}{$f} );
                $m->{files}{$f} = { %{$m->{files}{$f}}, %$a };
                if ( length($a->{digest}) ) {
                    $m->{files}{$f}{fullPath} = $m->{bpc}->MD52Path($a->{digest}, $compress);
                }
                $m->{files}{$f}{backupNum}    = $backupNum;
                $m->{files}{$f}{inode}        = $a->{inode};
            }
        }
    }
    #print STDERR "Returning:\n", Dumper($m->{files}) if ( length($dir) );
}

#
# Return list of shares for this backup
#
sub shareList
{
    my($m, $backupNum) = @_;
    my @shareList;

    $m->backupNumCache($backupNum) if ( $m->{num} != $backupNum );
    return if ( $m->{idx} < 0 );

    if ( $m->{backups}[$m->{idx}]{version} < 4 ) {
        my $mangle = $m->{backups}[$m->{idx}]{mangle};
        my $path = "$m->{topDir}/pc/$m->{host}/$backupNum/";
        return if ( !opendir(DIR, $path) );
        my @dir = readdir(DIR);
        closedir(DIR);
        foreach my $file ( @dir ) {
            $file = $1 if ( $file =~ /(.*)/s );
            next if ( $file eq "attrib" && $mangle
                   || $file eq "."
                   || $file eq ".."
                   || $file eq "backupInfo"
                   || $file eq "inode"
                );
            my $fileUM = $file;
            $fileUM = $m->{bpc}->fileNameUnmangle($fileUM) if ( $mangle );
            push(@shareList, $fileUM);
        }
        $m->{dir} = undef;
    } else {
        #
        # For 4.x we use a view with share "" to see the shares
        # for this backup
        #
        $m->dirCache($backupNum, "", "");
        @shareList = sort(keys(%{$m->{files}}));
    }
    return @shareList;
}

sub backupNumCache
{
    my($m, $backupNum) = @_;
    my $i;

    return if ( $m->{num} == $backupNum );
    for ( $i = 0 ; $i < @{$m->{backups}} ; $i++ ) {
        last if ( $m->{backups}[$i]{num} == $backupNum );
    }
    if ( $i >= @{$m->{backups}} ) {
        $m->{idx} = -1;
        return;
    }
    $m->{num} = $backupNum;
    $m->{idx} = $i;
}

#
# Return the attributes of a specific file
#
sub fileAttrib
{
    my($m, $backupNum, $share, $path) = @_;

    #print(STDERR "fileAttrib($backupNum, $share, $path)\n");
    if ( $path =~ s{(.*)/+(.+)}{$1}s ) {
        my $file = $2;
        $m->dirCache($backupNum, $share, $path);
        return $m->{files}{$file};
    } else {
        #print STDERR "Got empty $path\n";
        $m->dirCache($backupNum, "", "");
        my $attr = $m->{files}{$share};
        return if ( !defined($attr) );
        $attr->{relPath} = "/";
        return $attr;
    }
}

#
# Return the contents of a directory
#
sub dirAttrib
{
    my($m, $backupNum, $share, $dir) = @_;

    $m->dirCache($backupNum, $share, $dir);
    return $m->{files};
}

#
# Return a listref of backup numbers that are merged to create this view
#
sub mergeNums
{
    my($m) = @_;

    return $m->{mergeNums};
}

#
# Return a list of backup indexes for which the directory exists
#
sub backupList
{
    my($m, $share, $dir) = @_;
    my($i, @backupList);
    my $exist;

    $dir = "/$dir" if ( $dir !~ m{^/} );
    $dir =~ s{/+$}{};

    for ( $i = @{$m->{backups}} - 1 ; $i >= 0 ; $i-- ) {
	my $backupNum = $m->{backups}[$i]{num};
	my $mangle = $m->{backups}[$i]{mangle};
	my $path   = "$m->{topDir}/pc/$m->{host}/$backupNum/";
        my $sharePathM;
        if ( $mangle ) {
            $sharePathM = $m->{bpc}->fileNameEltMangle($share)
                        . $m->{bpc}->fileNameMangle($dir);
        } else {
            $sharePathM = $share . $dir;
        }
        $path .= $sharePathM;
        if ( $m->{backups}[$i]{version} < 4 ) {
            #
            # For 3.x backups it is easy - the full directory tree
            # exists for every backup
            #
            next if ( !-d $path );
            unshift(@backupList, $i);
        } else {
            if ( $i == @{$m->{backups}} - 1 || !$exist ) {
                #
                # The last backup is complete, so just test whether
                # the directory exists.  Similarly, if the directory
                # doesn't exist in a more recent backup, then we can
                # do the same test.
                #
                if ( -d $path ) {
                    unshift(@backupList, $i);
                    $exist = 1;
                }
                next;
            }
            #
            # We need to check if this directory or a
            # parent has the delete attribute
            #
            if ( $m->dirExists($i, $share, $dir) ) {
                $exist = 1;
                unshift(@backupList, $i);
            }
        }
    }
    return @backupList;
}

#
# Return the history of all backups for a particular directory
#
sub dirHistory
{
    my($m, $share, $dir) = @_;
    my($i, $level);
    my $files = {};
    my $hardlinks = {};

    $dir = "/$dir" if ( $dir !~ m{^/} );
    $dir =~ s{/+$}{};

    #
    # Handle any 3.x backups first.  We merge backups, starting at
    # the first one, and working forward.
    #
    for ( $i = 0 ; $i < @{$m->{backups}} ; $i++ ) {
	$level        = $m->{backups}[$i]{level};
	my $backupNum = $m->{backups}[$i]{num};
	my $mangle    = $m->{backups}[$i]{mangle};
	my $compress  = $m->{backups}[$i]{compress};
	my $path      = "$m->{topDir}/pc/$m->{host}/$backupNum/";
	my $legacyCharset = $m->{backups}[$i]{version} < 3.0;
        my $sharePathM;

        last if ( $m->{backups}[$i]{version} >= 4 );

        if ( $mangle ) {
            $sharePathM = $m->{bpc}->fileNameEltMangle($share)
                        . $m->{bpc}->fileNameMangle($dir);
        } else {
            $sharePathM = $share . $dir;
        }
        $path .= $sharePathM;
	#print(STDERR "Opening $path (share=$share)\n");

        my $dirOpts      = { %{$m->{dirOpts} || {} } };
        my $attribOpts   = { compress => $compress };
        if ( $legacyCharset ) {
            $dirOpts->{charsetLegacy}
                    = $attribOpts->{charsetLegacy}
                    = $m->{bpc}->{Conf}{ClientCharsetLegacy} || "iso-8859-1";
        }

        my $dirInfo = BackupPC::DirOps::dirRead($m->{bpc}, $path, $dirOpts);
	if ( !defined($dirInfo) ) {
	    #
	    # Oops, directory doesn't exist.
	    #
	    next;
        }
        my $attr;
	if ( $mangle ) {
	    $attr = BackupPC::XS::Attrib::new($compress);
	    if ( !$attr->read($path) ) {
                push(@{$m->{error}}, "Can't read attribute file in $path");
		$attr = undef;
	    }
	}
        foreach my $entry ( @$dirInfo ) {
            my $file = $1 if ( $entry->{name} =~ /(.*)/s );
            my $fileUM = $file;
            $fileUM = $m->{bpc}->fileNameUnmangle($fileUM) if ( $mangle );
            #print(STDERR "Doing $fileUM\n");
	    #
	    # skip special files
	    #
            next if (  $file eq ".."
		    || $file eq "."
		    || $mangle && $file eq "attrib"
		    || defined($files->{$fileUM}[$i]) );

            my $realPath = "$path/$file";
            from_to($realPath, "utf8", $attribOpts->{charsetLegacy})
                            if ( $attribOpts->{charsetLegacy} ne "" );
            my @s = stat($realPath);
            if ( defined($attr) && defined(my $a = $attr->get($fileUM)) ) {
                $files->{$fileUM}[$i] = $a;
		$attr->delete($fileUM);
            } else {
                #
                # Very expensive in the non-attribute case when compresseion
                # is on.  We have to stat the file and read compressed files
                # to determine their size.
                #
                $files->{$fileUM}[$i] = {
                    type  => -d _ ? BPC_FTYPE_DIR : BPC_FTYPE_FILE,
                    mode  => $s[2],
                    uid   => $s[4],
                    gid   => $s[5],
                    size  => -f _ ? $s[7] : 0,
                    mtime => $s[9],
                };
                if ( $compress && -f _ ) {
                    #
                    # Compute the correct size by reading the whole file
                    #
                    my $f = BackupPC::XS::FileZIO::open("$realPath", 0, $compress);
                    if ( !defined($f) ) {
                        push(@{$m->{error}}, "Can't open $path/$file");
                    } else {
                        my($data, $size);
                        while ( $f->read(\$data, 65636 * 8) > 0 ) {
                            $size += length($data);
                        }
                        $f->close;
                        $files->{$fileUM}[$i]{size} = $size;
                    }
                }
            }
            ($files->{$fileUM}[$i]{relPath}    = "$dir/$fileUM") =~ s{//+}{/}g;
            ($files->{$fileUM}[$i]{sharePathM} = "$sharePathM/$file")
                                                                =~ s{//+}{/}g;
            ($files->{$fileUM}[$i]{fullPath}   = "$path/$file") =~ s{//+}{/}g;
            $files->{$fileUM}[$i]{backupNum}   = $backupNum;
            $files->{$fileUM}[$i]{compress}    = $compress;
	    $files->{$fileUM}[$i]{nlink}       = $entry->{nlink}
                                                    if ( $m->{dirOpts}{nlink} );
	    $files->{$fileUM}[$i]{inode}       = $entry->{inode}
                                                    if ( $m->{dirOpts}{inode} );
        }

	#
	# Flag deleted files
	#
	if ( defined($attr) ) {
	    my $a = $attr->get;
	    foreach my $fileUM ( keys(%$a) ) {
		next if ( $a->{$fileUM}{type} != BPC_FTYPE_DELETED );
		$files->{$fileUM}[$i]{type} = BPC_FTYPE_DELETED;
	    }
	}

	#
	# Merge old backups.  Don't merge directories from old
	# backups because every backup has an accurate directory
	# tree.
	#
	for ( my $k = $i - 1 ; $level > 0 && $k >= 0 ; $k-- ) {
	    next if ( $m->{backups}[$k]{level} >= $level );
	    $level = $m->{backups}[$k]{level};
	    foreach my $fileUM ( keys(%$files) ) {
		next if ( !defined($files->{$fileUM}[$k])
			|| defined($files->{$fileUM}[$i])
			|| $files->{$fileUM}[$k]{type} == BPC_FTYPE_DIR );
		$files->{$fileUM}[$i] = $files->{$fileUM}[$k];
	    }
	}
    }

    #
    # Remove deleted files
    #
    for ( $i = 0 ; $i < @{$m->{backups}} ; $i++ ) {
        last if ( $m->{backups}[$i]{version} >= 4 );
        foreach my $fileUM ( keys(%$files) ) {
            next if ( !defined($files->{$fileUM}[$i])
                    || $files->{$fileUM}[$i]{type} != BPC_FTYPE_DELETED );
            $files->{$fileUM}[$i] = undef;
        }
    }

    #
    # Now handle any >= 4.x backups.  We merge backups, starting at
    # the last and work backwards.
    #
    # In 4.x+ backups the full directory tree only exists in the
    # last backup.  Prior backups will only have directories where
    # some part of the backup has changed.
    #
    for ( $i = @{$m->{backups}} - 1 ; $i >= 0 ; $i-- ) {
        #print(STDERR "Do $i ($m->{backups}[$i]{noFill},$m->{backups}[$i]{level})\n");

        last if ( $m->{backups}[$i]{version} < 4 );

        if ( $i < @{$m->{backups}} - 1 && $m->{backups}[$i]{noFill} ) {
            #
            # Copy all the file information from $i + 1 to $i
            #
            foreach my $fileUM ( keys(%$files) ) {
                $files->{$fileUM}[$i] = $files->{$fileUM}[$i+1];
            }
        }

        my $backupNum  = $m->{backups}[$i]{num};
        my $mangle     = $m->{backups}[$i]{mangle};
        my $compress   = $m->{backups}[$i]{compress};
        my $topPath    = "$m->{topDir}/pc/$m->{host}/$backupNum/";
        my $sharePathM = $m->{bpc}->fileNameEltMangle($share)
                       . $m->{bpc}->fileNameMangle($dir);
        my $path = $topPath . $sharePathM;
        #print(STDERR "Opening $path (share=$share, mangle=$mangle)\n");

        my $dirOpts      = { %{$m->{dirOpts} || {} } };
        my $attribOpts   = { compress => $compress };

        if ( !-d $path ) {
            #
            # if this is a filled backup then the directory is empty
            #
            next if ( !$m->{backups}[$i]{noFill} );
            #
            # if we have some entries already we need to check that
            # this directory wasn't deleted.  We need to look up
            # up each level until we find an attrib file that exists.
            #
            if ( !$m->dirExists($i, $share, $dir) ) {
                foreach my $fileUM ( keys(%$files) ) {
                    $files->{$fileUM}[$i] = undef;
                }
            }
        }

        my $attr = BackupPC::XS::Attrib::new($compress);
        if ( -f "$path/attrib" ) {
            if ( !$attr->read($path) ) {
                push(@{$m->{error}}, "Can't read attribute file in $path\n");
            } else {
                my $attrAll = $attr->get();
                foreach my $fileUM ( keys(%$attrAll) ) {
                    my $a = $attrAll->{$fileUM};
                    if ( $a->{type} == BPC_FTYPE_DELETED ) {
                        delete($files->{$fileUM}[$i]);
                        delete($hardlinks->{$fileUM});
                        next;
                    }
                    if ( $a->{nlinks} > 0 ) {
                        $a = $m->hardLinkGet($a, $i);
                        $hardlinks->{$fileUM} = 1;
                    }
                    $files->{$fileUM}[$i] = $a;
                    ($files->{$fileUM}[$i]{relPath}     = "$dir/$fileUM") =~ s{//+}{/}g;
                    if ( length($a->{digest}) ) {
                        $files->{$fileUM}[$i]{fullPath} = $m->{bpc}->MD52Path($a->{digest}, $compress);
                    } else {
                        $files->{$fileUM}[$i]{fullPath} = "/dev/null";
                    }
                    $files->{$fileUM}[$i]{backupNum}    = $backupNum;
                    $files->{$fileUM}[$i]{compress}     = $compress;
                    $files->{$fileUM}[$i]{inode}        = $a->{inode};
                }
            }
        }

        #
        # Update any inode information specific to this backup
        # for hardlinks in this directory
        #
        foreach my $f ( keys(%$hardlinks) ) {
            next if ( !$files->{$f}[$i] || $files->{$f}[$i]{backupNum} == $backupNum );
            my $a = $m->hardLinkGet($files->{$f}[$i], $i);
            next if ( $a == $files->{$f}[$i] );
            $files->{$f}[$i] = { %{$files->{$f}[$i]}, %$a };
            if ( length($a->{digest}) ) {
                $files->{$f}[$i]{fullPath} = $m->{bpc}->MD52Path($a->{digest}, $compress);
            }
            $files->{$f}[$i]{backupNum}    = $backupNum;
            $files->{$f}[$i]{inode}        = $a->{inode};
        }
    }

    #print STDERR "Returning:\n", Dumper($files);
    return $files;
}


#
# Do a recursive find starting at the given path (either a file
# or directory).  The callback function $callback is called on each
# file and directory.  The function arguments are the attrs hashref,
# and additional callback arguments.  The search is depth-first if
# depth is set.  Returns -1 if $path does not exist.
#
sub find
{
    my($m, $backupNum, $share, $path, $depth, $callback, @callbackArgs) = @_;

    #print(STDERR "find: got $backupNum, $share, $path\n");
    #
    # First call the callback on the given $path
    #
    my $attr = $m->fileAttrib($backupNum, $share, $path);
    return -1 if ( !defined($attr) );
    &$callback($attr, @callbackArgs);
    return if ( $attr->{type} != BPC_FTYPE_DIR );

    #
    # Now recurse into subdirectories
    #
    $m->findRecurse($backupNum, $share, $path, $depth,
		    $callback, @callbackArgs);
}

#
# Same as find(), except the callback is not called on the current
# $path, only on the contents of $path.  So if $path is a file then
# no callback or recursion occurs.
#
sub findRecurse
{
    my($m, $backupNum, $share, $path, $depth, $callback, @callbackArgs) = @_;

    my $attr = $m->dirAttrib($backupNum, $share, $path);
    return if ( !defined($attr) );
    foreach my $file ( sort(keys(%$attr)) ) {
        &$callback($attr->{$file}, @callbackArgs);
        next if ( $depth <= 0 || $attr->{$file}{type} != BPC_FTYPE_DIR );
        #
        # For depth-first, recurse as we hit each directory
        #
        $m->findRecurse($backupNum, $share, "$path/$file", $depth,
			     $callback, @callbackArgs);
    }
    if ( $depth == 0 ) {
        #
        # For non-depth, recurse directories after we finish current dir
        #
        foreach my $file ( keys(%{$attr}) ) {
            next if ( $attr->{$file}{type} != BPC_FTYPE_DIR );
            $m->findRecurse($backupNum, $share, "$path/$file", $depth,
			    $callback, @callbackArgs);
        }
    }
}

1;
