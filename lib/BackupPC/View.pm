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
#   Copyright (C) 2002  Craig Barratt
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
# Version 2.0.0_CVS, released 18 Jan 2003.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

package BackupPC::View;

use strict;

use File::Path;
use BackupPC::Lib;
use BackupPC::Attrib qw(:all);
use BackupPC::FileZIO;

sub new
{
    my($class, $bpc, $host, $backups) = @_;
    my $m = bless {
        bpc       => $bpc,		# BackupPC::Lib object
        host      => $host,		# host name
        backups   => $backups,		# all backups for this host
	num       => -1,		# backup number
        idx       => -1,		# index into backups for backup
					#   we are viewing
        dirPath   => undef,		# path to current directory
        dirAttr   => undef,		# attributes of current directory
    }, $class;
    for ( my $i = 0 ; $i < @{$m->{backups}} ; $i++ ) {
	next if ( defined($m->{backups}[$i]{level}) );
	$m->{backups}[$i]{level} = $m->{backups}[$i]{type} eq "full" ? 0 : 1;
    }
    $m->{topDir} = $m->{bpc}->TopDir();
    return $m;
}

sub dirCache
{
    my($m, $backupNum, $share, $dir) = @_;
    my($i, $level);

    $dir = "/$dir" if ( $dir !~ m{^/} );
    $dir =~ s{/+$}{};
    return if ( $m->{num} == $backupNum
                && $m->{share} eq $share
                && $m->{dir} eq $dir );
    if ( $m->{num} != $backupNum ) {
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
    $m->{files} = {};
    $level = $m->{backups}[$m->{idx}]{level} + 1;

    #
    # Remember the requested share and dir
    #
    $m->{share} = $share;
    $m->{dir} = $dir;

    #
    # merge backups, starting at the requested one, and working
    # backwards until we get to level 0.
    #
    $m->{mergeNums} = [];
    for ( $i = $m->{idx} ; $level > 0 && $i >= 0 ; $i-- ) {
	#print("Do $i ($m->{backups}[$i]{noFill},$m->{backups}[$i]{level})\n");
	#
	# skip backups with the same or higher level
	#
	next if ( $m->{backups}[$i]{level} >= $level );

	$level = $m->{backups}[$i]{level};
	$backupNum = $m->{backups}[$i]{num};
	push(@{$m->{mergeNums}}, $backupNum);
	my $mangle   = $m->{backups}[$i]{mangle};
	my $compress = $m->{backups}[$i]{compress};
	my $path = "$m->{topDir}/pc/$m->{host}/$backupNum/";
        my $sharePathM;
        if ( $mangle ) {
            $sharePathM = $m->{bpc}->fileNameEltMangle($share)
                        . $m->{bpc}->fileNameMangle($dir);
        } else {
            $sharePathM = $share . $dir;
        }
        $path .= $sharePathM;
	#print("Opening $path\n");
	if ( !opendir(DIR, $path) ) {
            if ( $i == $m->{idx} ) {
                #
                # Oops, directory doesn't exist.
                #
		$m->{files} = undef;
                return;
            }
            next;
        }
        my @dir = readdir(DIR);
        closedir(DIR);
        my $attr;
	if ( $mangle ) {
	    $attr = BackupPC::Attrib->new({ compress => $compress });
	    if ( -f $attr->fileName($path) && !$attr->read($path) ) {
                $m->{error} = "Can't read attribute file in $path";
		$attr = undef;
	    }
	}
        foreach my $file ( @dir ) {
            $file = $1 if ( $file =~ /(.*)/ );
            my $fileUM = $file;
            $fileUM = $m->{bpc}->fileNameUnmangle($fileUM) if ( $mangle );
	    #
	    # skip special files
	    #
            next if ( defined($m->{files}{$fileUM})
		    || $file eq ".."
		    || $file eq "."
		    || $mangle && $file eq "attrib" );
	    #
	    # skip directories in earlier backups (each backup always
	    # has the complete directory tree).
	    #
	    my @s = stat("$path/$file");
	    next if ( $i < $m->{idx} && -d _ );
            if ( defined($attr) && defined(my $a = $attr->get($fileUM)) ) {
                $m->{files}{$fileUM} = $a;
		$attr->set($fileUM, undef);
            } else {
                #
                # Very expensive in the non-attribute case when compresseion
                # is on.  We have to stat the file and read compressed files
                # to determine their size.
                #
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
                    my $f = BackupPC::FileZIO->open("$path/$file",
						    0, $compress);
                    if ( !defined($f) ) {
                        $m->{error} = "Can't open $path/$file";
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
            $m->{files}{$fileUM}{relPath}    = "$dir/$fileUM";
            $m->{files}{$fileUM}{sharePathM} = "$sharePathM/$file";
            $m->{files}{$fileUM}{fullPath}   = "$path/$file";
            $m->{files}{$fileUM}{backupNum}  = $backupNum;
            $m->{files}{$fileUM}{compress}   = $compress;
	    $m->{files}{$fileUM}{nlink}      = $s[3];
	    $m->{files}{$fileUM}{inode}      = $s[1];
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
		$m->{files}{$fileUM}{backupNum}  = $backupNum;
		$m->{files}{$fileUM}{compress}   = $compress;
		$m->{files}{$fileUM}{nlink}      = 0;
		$m->{files}{$fileUM}{inode}      = 0;
	    }
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

#
# Return the attributes of a specific file
#
sub fileAttrib
{
    my($m, $backupNum, $share, $path) = @_;
    my $dir = $path;
    $dir =~ s{(.*)/(.*)}{$1};
    my $file = $2;

    $m->dirCache($backupNum, $share, $dir);
    return $m->{files}{$file};
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

sub mergeNums
{
    my($m) = @_;

    return $m->{mergeNums};
}

sub backupList
{
    my($m, $share, $dir) = @_;
    my($i, @backupList);

    $dir = "/$dir" if ( $dir !~ m{^/} );
    $dir =~ s{/+$}{};

    for ( $i = 0 ; $i < @{$m->{backups}} ; $i++ ) {
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
        next if ( !-d $path );
        push(@backupList, $backupNum);
    }
    return @backupList;
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
    foreach my $file ( keys(%$attr) ) {
        &$callback($attr->{$file}, @callbackArgs);
        next if ( !$depth || $attr->{$file}{type} != BPC_FTYPE_DIR );
        #
        # For depth-first, recurse as we hit each directory
        #
        $m->findRecurse($backupNum, $share, "$path/$file", $depth,
			     $callback, @callbackArgs);
    }
    if ( !$depth ) {
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
