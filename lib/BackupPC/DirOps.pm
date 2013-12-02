#============================================================= -*-perl-*-
#
# BackupPC::DirOps package
#
# DESCRIPTION
#
#   This library defines a BackupPC::DirOps class and a variety of
#   directory utility functions used by BackupPC.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
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

package BackupPC::DirOps;

use strict;

use Fcntl ':mode';
use Cwd;
use Encode qw/from_to encode_utf8/;
use Data::Dumper;
use File::Path;

use BackupPC::XS;
use BackupPC::Storage;

use vars qw( $IODirentOk $IODirentLoaded );
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

require Exporter;
require DynaLoader;

@ISA = qw(Exporter DynaLoader);
@EXPORT_OK = qw( BPC_DT_UNKNOWN
                 BPC_DT_FIFO
                 BPC_DT_CHR
                 BPC_DT_DIR
                 BPC_DT_BLK
                 BPC_DT_REG
                 BPC_DT_LNK
                 BPC_DT_SOCK
               );
@EXPORT = qw( );
%EXPORT_TAGS = ('BPC_DT_ALL' => [@EXPORT, @EXPORT_OK]);

BEGIN {
    eval "use IO::Dirent qw( readdirent DT_DIR );";
    $IODirentLoaded = 1 if ( !$@ );
};

#
# The need to match the constants in IO::Dirent
#
use constant BPC_DT_UNKNOWN =>   0;
use constant BPC_DT_FIFO    =>   1;    ## named pipe (fifo)
use constant BPC_DT_CHR     =>   2;    ## character special
use constant BPC_DT_DIR     =>   4;    ## directory
use constant BPC_DT_BLK     =>   6;    ## block special
use constant BPC_DT_REG     =>   8;    ## regular
use constant BPC_DT_LNK     =>  10;    ## symbolic link
use constant BPC_DT_SOCK    =>  12;    ## socket

#
# Read a directory and return the entries in sorted inode order.
# This relies on the IO::Dirent module being installed.  If not,
# the inode data is empty and the default directory order is
# returned.
#
# The returned data is a list of hashes with entries {name, type, inode, nlink}.
# The returned data includes "." and "..".
#
# $need is a hash of file attributes we need: type, inode, or nlink.
# If set, these parameters are added to the returned hash.
#
# To support browsing pre-3.0.0 backups where the charset encoding
# is typically iso-8859-1, the charsetLegacy option can be set in
# $need to convert the path from utf8 and convert the names to utf8.
#
# If IO::Dirent is successful if will get type and inode for free.
# Otherwise, a stat is done on each file, which is more expensive.
#
sub dirRead
{
    my($bpc, $path, $need) = @_;
    my(@entries, $addInode);

    from_to($path, "utf8", $need->{charsetLegacy})
                        if ( $need->{charsetLegacy} ne "" );
    return if ( !opendir(my $fh, $path) );
    if ( $IODirentLoaded && !$IODirentOk ) {
        #
        # Make sure the IO::Dirent really works - some installs
        # on certain file systems (eg: XFS) don't return a valid type.
        #
        if ( opendir(my $fh, $bpc->{TopDir}) ) {
            my $dt_dir = eval("DT_DIR");
            foreach my $e ( readdirent($fh) ) {
                if ( $e->{name} eq "." && $e->{type} == $dt_dir ) {
                    $IODirentOk = 1;
                    last;
                }
            }
            closedir($fh);
        }
        #
        # if it isn't ok then don't check again.
        #
        $IODirentLoaded = 0 if ( !$IODirentOk );
    }
    if ( $IODirentOk ) {
        @entries = sort({ $a->{inode} <=> $b->{inode} } readdirent($fh));
        map { $_->{type} = 0 + $_->{type} } @entries;   # make type numeric
    } else {
        @entries = map { { name => $_} } readdir($fh);
    }
    closedir($fh);
    if ( defined($need) && %$need > 0 ) {
        for ( my $i = 0 ; $i < @entries ; $i++ ) {
            next if ( (!$need->{inode} || defined($entries[$i]{inode}))
                   && (!$need->{type}  || defined($entries[$i]{type}))
                   && (!$need->{nlink} || defined($entries[$i]{nlink})) );
            my @s = stat("$path/$entries[$i]{name}");
            $entries[$i]{nlink} = $s[3] if ( $need->{nlink} );
            if ( $need->{inode} && !defined($entries[$i]{inode}) ) {
                $addInode = 1;
                $entries[$i]{inode} = $s[1];
            }
            if ( $need->{type} && !defined($entries[$i]{type}) ) {
                my $mode = S_IFMT($s[2]);
                $entries[$i]{type} = BPC_DT_FIFO if ( S_ISFIFO($mode) );
                $entries[$i]{type} = BPC_DT_CHR  if ( S_ISCHR($mode) );
                $entries[$i]{type} = BPC_DT_DIR  if ( S_ISDIR($mode) );
                $entries[$i]{type} = BPC_DT_BLK  if ( S_ISBLK($mode) );
                $entries[$i]{type} = BPC_DT_REG  if ( S_ISREG($mode) );
                $entries[$i]{type} = BPC_DT_LNK  if ( S_ISLNK($mode) );
                $entries[$i]{type} = BPC_DT_SOCK if ( S_ISSOCK($mode) );
            }
        }
    }
    #
    # Sort the entries if inodes were added (the IO::Dirent case already
    # sorted above)
    #
    @entries = sort({ $a->{inode} <=> $b->{inode} } @entries) if ( $addInode );
    #
    # for browing pre-3.0.0 backups, map iso-8859-1 to utf8 if requested
    #
    if ( $need->{charsetLegacy} ne "" ) {
        for ( my $i = 0 ; $i < @entries ; $i++ ) {
            from_to($entries[$i]{name}, $need->{charsetLegacy}, "utf8");
        }
    }
    return \@entries;
}

#
# Same as dirRead, but only returns the names (which will be sorted in
# inode order if IO::Dirent is installed)
#
sub dirReadNames
{
    my($bpc, $path, $need) = @_;

    my $entries = BackupPC::DirOps::dirRead($bpc, $path, $need);
    return if ( !defined($entries) );
    my @names = map { $_->{name} } @$entries;
    return \@names;
}

sub find
{
    my($bpc, $param, $dir, $dontDoCwd) = @_;

    my $entries = BackupPC::DirOps::dirRead($bpc, $dir, {inode => 1, type => 1});
    foreach my $f ( @$entries ) {
        next if ( $f->{name} eq ".." || $f->{name} eq "." && $dontDoCwd );
        $param->{wanted}($f->{name}, "$dir/$f->{name}");
        next if ( $f->{type} != BPC_DT_DIR || $f->{name} eq "." );
        BackupPC::DirOps::find($bpc, $param, "$dir/$f->{name}", 1);
    }
}

#
# Stripped down from File::Path.  In particular we don't print
# many warnings and we try three times to delete each directory
# and file -- for some reason the original File::Path rmtree
# didn't always completely remove a directory tree on a NetApp.
#
# This routine updates the reference counts every time it
# encounters an attrib file (unless $compress < 0).
# So you must have called BackupPC::XS::PoolRefCnt::DeltaFileInit()
# first.
#
# The $compress argument has three values:
#  >0   compression is on; reference counts will be updated
#           for every attrib file encountered
#   0   compression is off; reference counts will be updated
#           for every attrib file encountered
#  -1   no reference count updating, except for attrib files
# <-1   no reference count updating
#
# This function restores the original cwd after running.
#
# progressCB is an optional callback that is called once per attrib
# file with an argument giving the count of files that have been deleted
# (ie: the count of files in attrib, not actual disk-based files).
#
sub RmTreeQuiet
{
    my($bpc, $roots, $compress, $progressCB) = @_;

    my($cwd) = Cwd::fastcwd();
    $cwd = $1 if ( $cwd =~ /(.*)/ );
    my $ret = BackupPC::DirOps::RmTreeQuietInner($bpc, $cwd, $roots, $compress, $progressCB);
    chdir($cwd) if ( $cwd );
    return $ret;
}

sub RmTreeQuietInner
{
    my($bpc, $cwd, $roots, $compress, $progressCB) = @_;
    my(@files, $root);

    if ( defined($roots) && length($roots) ) {
        $roots = [$roots] unless ref $roots;
    } else {
        print(STDERR "RmTreeQuietInner: No root path(s) specified\n");
        return 1;
    }
    foreach $root ( @$roots ) {
        my($path, $name);
	$root =~ s{/+$}{};
        if ( $root =~ m{(.*)/(.*)} ) {
            $path = $1;
            $name = $2;
            if ( !-d $path ) {
                print(STDERR "RmTreeQuietInner: $cwd/$path isn't a directory (while removing $root)\n");
                return 1;
            }
            if ( !chdir($path) ) {
                print(STDERR "RmTreeQuietInner: can't chdir to $cwd/$path (while removing $root)\n");
                return 1;
            }
        } else {
            $path = ".";
            $name = $root;
        }

        #
        # If this is an attrib file then we need to open it to
        # update the reference counts
        #
        if ( $compress >= -1 && $name =~ /^attrib/ && -f $name ) {
            my $attr = BackupPC::XS::Attrib::new($compress);
            if ( !$attr->read(".", $name) ) {
                print(STDERR "Can't read attribute file in $cwd/$path/$name: " . $attr->errStr() . "\n");
            }
            my $attrAll = $attr->get();
            my $d = $attr->digest();

            BackupPC::XS::PoolRefCnt::DeltaUpdate($compress, $d, -1) if ( length($d) );
            if ( $compress >= 0 ) {
                foreach my $fileUM ( keys(%$attrAll) ) {
                    my $a = $attrAll->{$fileUM};
                    BackupPC::XS::PoolRefCnt::DeltaUpdate($compress, $a->{digest}, -1)
                                                    if ( length($a->{digest}) );
                }
            }
            &$progressCB(scalar(keys(%$attrAll))) if ( ref($progressCB) eq 'CODE' );
        }
        if ( $compress < -1 && ref($progressCB) eq 'CODE' ) {
            #
            # Do progress counting in the non-ref count case
            #
            &$progressCB(1);
        }

	#
	# Try first to simply unlink the file: this avoids an
	# extra stat for every file.  If it fails (which it
	# will for directories), check if it is a directory and
	# then recurse.
	#
	if ( !unlink($name) ) {
            if ( -d $name ) {
                if ( !chdir($name) ) {
                    print(STDERR "RmTreeQuietInner: can't chdir to $name (while removing $root)\n");
                    return 1;
                }
                my $d = BackupPC::DirOps::dirReadNames($bpc, ".");
		if ( !defined($d) ) {
		    print(STDERR "Can't read $cwd/$path/$name: $!\n");
		} else {
		    @files = grep $_ !~ /^\.{1,2}$/, @$d;
		    BackupPC::DirOps::RmTreeQuietInner($bpc, "$cwd/$name", \@files, $compress, $progressCB);
		    if ( !chdir("..") ) {
                        print(STDERR "RmTreeQuietInner: can't chdir .. (while removing $root)\n");
                        return 1;
                    }
		    rmdir($name) || rmdir($name);
		}
            } else {
                #
                # just try again
                #
                unlink($name) || unlink($name);
            }
        }
    }
    return 0;
}

1;
