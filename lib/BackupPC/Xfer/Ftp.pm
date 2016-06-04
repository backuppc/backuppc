#============================================================= -*-perl-*-
#
# BackupPC::Xfer::Ftp package
#
# DESCRIPTION
#
#   This library defines a BackupPC::Xfer::Ftp class for transferring
#   data from a FTP client.
#
# AUTHOR
#   Paul Mantz <pcmantz@zmanda.com>
#
# COPYRIGHT
#   (C) 2008, Zmanda Inc.
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
# Version 3.2.0beta1, released 24 Jan 2010.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

package BackupPC::Xfer::Ftp;

use strict;

use BackupPC::Lib;
use BackupPC::View;
use BackupPC::DirOps;
use BackupPC::XS qw(:all);

use Encode qw/from_to encode/;
use File::Listing qw/parse_dir/;
use Fcntl ':mode';
use File::Path;
use Data::Dumper;
use base qw(BackupPC::Xfer::Protocol);

use vars qw( $FTPLibOK $FTPLibErr $ARCLibOK );
 
BEGIN {

    $FTPLibOK = 1;
    $ARCLibOK = 0;

    #
    # clear eval error variable
    #
    my @FTPLibs = qw( Net::FTP Net::FTP::RetrHandle );

    foreach my $module ( @FTPLibs ) {

        undef $@;
        eval "use $module;";

        if ( $@ ) {
            $FTPLibOK = 0;
            $FTPLibErr = "module $module doesn't exist: $@";
            last;
        }
    }

    eval "use Net::FTP::AutoReconnect;";
    $ARCLibOK = (defined($@)) ? 1 : 0;
$ARCLibOK = 0;
};

##############################################################################
# Constructor
##############################################################################


#
#   usage:
#     $xfer = new BackupPC::Xfer::Ftp( $bpc, %args );
#
# new() is your default class constructor.  it also calls the
# constructor for Protocol as well.
#
sub new
{
    my ( $class, $bpc, $args ) = @_;
    $args ||= {};

    my $t = BackupPC::Xfer::Protocol->new(
        $bpc,
        {
           ftp   => undef,
           stats => {
               errorCnt          => 0,
               TotalFileCnt      => 0,
               TotalFileSize     => 0,
               ExistFileCnt      => 0,
               ExistFileSize     => 0,
               ExistFileCompSize => 0,
           },
           %$args,
        } );
    return bless( $t, $class );
}


##############################################################################
# Methods
##############################################################################

#
#   usage:
#     $xfer->start();
#
# start() is called to configure and initiate a dump or restore,
# depending on the configured options.
#
sub start
{
    my($t) = @_;

    my $bpc  = $t->{bpc};
    my $conf = $t->{conf};
    my $TopDir = $bpc->TopDir();

    my ( @fileList, $logMsg, $args, $dumpText );

    #
    # initialize the statistics returned by getStats()
    #
    foreach ( qw/byteCnt fileCnt xferErrCnt xferBadShareCnt
                 xferBadFileCnt xferOK hostAbort hostError
                 lastOutputLine/ )
    {
        $t->{$_} = 0;
    }

    #
    # Net::FTP::RetrHandle is necessary.
    #
    if ( !$FTPLibOK ) {
        $t->{_errStr} = "Error: FTP transfer selected but module"
          . " Net::FTP::RetrHandle is not installed.";
        $t->{xferErrCnt}++;
        return;
    }

    #
    # standardize the file include/exclude settings if necessary
    #
    unless ( $t->{type} eq 'restore' ) {
        $bpc->backupFileConfFix( $conf, "FtpShareName" );
	$t->loadInclExclRegexps("FtpShareName");
    }

    #
    # Convert the encoding type of the names if at all possible
    #
    from_to( $args->{shareName}, "utf8", $conf->{ClientCharset} )
                                if ( $conf->{ClientCharset} ne "" );

    #
    # Collect FTP configuration arguments and translate them for
    # passing to the FTP module.
    #
    unless ( $args = $t->getFTPArgs() ) {
        return;
    }

    #
    # Create the Net::FTP::AutoReconnect or Net::FTP object.
    #
    undef $@;
    eval {
        $t->{ftp} = ($ARCLibOK) ? Net::FTP::AutoReconnect->new(%$args)
                                : Net::FTP->new(%$args);
    };
    if ($@) {
        $t->{_errStr} = "Can't open connection to $args->{Host}: $!";
        $t->{xferErrCnt}++;
        return;
    }
    $t->logWrite("Connected to $args->{Host}\n", 2);

    #
    # Log in to the ftp server and set appropriate path information.
    #
    undef $@;
    my $ret;
    eval { $ret = $t->{ftp}->login( $conf->{FtpUserName}, $conf->{FtpPasswd} ); };
    if ( !$ret ) {
        $t->{_errStr} = "Can't login to $args->{Host} ($conf->{FtpUserName}, $conf->{FtpPasswd}): " . $t->{ftp}->message();
        $t->{xferErrCnt}++;
        return;
    }
    $t->logWrite("Login successful to $conf->{FtpUserName}\@$args->{Host}\n", 2);

#    eval { $ret = $t->{ftp}->binary(); };
#    if ( !$ret ) {
#        $t->{_errStr} =
#          "Can't enable binary transfer mode to $args->{Host}: " . $t->{ftp}->message();
#        $t->{xferErrCnt}++;
#        return;
#    }
#    $t->logWrite("Binary command successful\n", 2);

    eval { $ret = $t->{ftp}->cwd( $t->{shareName} ); };
    if ( !$ret ) {
        $t->{_errStr} =
            "Can't change working directory to $t->{shareName}: " . $t->{ftp}->message();
        $t->{xferErrCnt}++;
        return;
    }
    $t->logWrite("Set cwd to $t->{shareName}\n", 2);

    eval { $t->{sharePath} = $t->{ftp}->pwd(); };
    if ( $t->{sharePath} eq "" ) {
        $t->{_errStr} =
            "Can't retrieve full working directory of $t->{shareName}: $!";
        $t->{xferErrCnt}++;
        return;
    }
    $t->logWrite("Pwd returned as $t->{sharePath}\n", 2);

    #
    # log the beginning of action based on type
    #
    if ( $t->{type} eq 'restore' ) {
        $logMsg = "ftp restore for host $t->{host} started on directory "
          . "$t->{shareName}\n";

    } elsif ( $t->{type} eq 'full' ) {
        $logMsg = "ftp full backup for host $t->{host} started on directory "
          . "$t->{shareName}\n";

    } elsif ( $t->{type} eq 'incr' ) {
        $logMsg = "ftp incremental backup for $t->{host} started for directory "
                . "$t->{shareName}\n";
    }
    $t->logWrite($logMsg, 1);

    #
    # call the recursive function based on the type of action
    #
    if ( $t->{type} eq 'restore' ) {

        $t->restore();
        $logMsg = "Restore of $t->{host} "
                . ($t->{xferOK} ? "complete" : "failed");

    } else {
        $t->{compress} = $t->{backups}[$t->{newBkupIdx}]{compress};
        $t->{AttrNew} = BackupPC::XS::AttribCache::new($t->{client}, $t->{newBkupNum}, $t->{shareName},
                                                       $t->{compress});
        $t->{Inode} = $t->{Inode0} = $t->{backups}[$t->{newBkupIdx}]{inodeLast};
        if ( !$t->{inPlace} ) {
            $t->{AttrOld} = BackupPC::XS::AttribCache::new($t->{client}, $t->{lastBkupNum}, $t->{shareName},
                                                           $t->{compress});
        }
        BackupPC::XS::PoolRefCnt::DeltaFileInit("$TopDir/pc/$t->{client}");
        $bpc->flushXSLibMesgs();

        $t->backup();

        $t->{AttrNew}->flush(1);
        $bpc->flushXSLibMesgs();
        if ( $t->{AttrOld} ) {
            $t->{AttrOld}->flush(1);
            $bpc->flushXSLibMesgs();
        }

        $bpc->flushXSLibMesgs();
        BackupPC::XS::PoolRefCnt::DeltaPrint() if ( $t->{logLevel} >= 6 );
        BackupPC::XS::PoolRefCnt::DeltaFileFlush();
        $bpc->flushXSLibMesgs();

        if ( $t->{type} eq 'incr' ) {
            $logMsg = "Incremental backup of $t->{host} "
                    . ($t->{xferOK} ? "complete" : "failed");
        } else {
            $logMsg = "Full backup of $t->{host} "
                    . ($t->{xferOK} ? "complete" : "failed");
        }
    }

    delete $t->{_errStr};
    return $logMsg;
}


#
#
#
sub run
{
    my ($t) = @_;
    my $stats = $t->{stats};

    my ( $tarErrs,      $nFilesExist, $sizeExist,
         $sizeExistCom, $nFilesTotal, $sizeTotal );

    #
    # TODO: replace the $stats array with variables at the top level,
    # ones returned by $getStats.  They should be identical.
    #
    $tarErrs      = 0;
    $nFilesExist  = $stats->{ExistFileCnt};
    $sizeExist    = $stats->{ExistFileSize};
    $sizeExistCom = $stats->{ExistFileCompSize};
    $nFilesTotal  = $stats->{TotalFileCnt};
    $sizeTotal    = $stats->{TotalFileSize};

    if ( $t->{type} eq "restore" ) {
        return ( $t->{fileCnt}, $t->{byteCnt}, 0, 0 );

    } else {
        return ( $tarErrs,      $nFilesExist, $sizeExist,
                 $sizeExistCom, $nFilesTotal, $sizeTotal );
    }
}


#
#   usage:
#     $t->restore();
#
# TODO: finish or scuttle this function.  It is not necessary for a
# release.
#
sub restore
{
    my $t = @_;

    my $bpc = $t->{bpc};
    my $fileList = $t->{fileList};

    my ($path, $fileName, $fileAttr, $fileType );

    #print STDERR "BackupPC::Xfer::Ftp->restore()";

    #
    # Prepare the view object
    #
    $t->{view} = BackupPC::View->new( $bpc, $t->{bkupSrcHost},
                                      $t->{backups} );
    my $view = $t->{view};

  SCAN: foreach my $f ( @$fileList ) {

        #print STDERR "restoring $f...\n";

        $f =~ /(.*)\/([^\/]*)/;
        $path     = $1;
        $fileName = $2;

        $view->dirCache($path);

        $fileAttr = $view->fileAttrib($fileName);
        $fileType = fileType2Text( $fileAttr->{type} );

        if ( $fileType eq "dir") {
            $t->restoreDir($fileName, $fileAttr);

        } elsif ( $fileType eq "file" ) {
            $t->restoreFile($fileName, $fileAttr);

        } elsif ( $fileType eq "symlink" ) {
            #
            # ignore
            #
        } else {
            #
            # ignore
            #
        }
    } # end SCAN
}


sub restoreDir
{
    my ( $t, $dirName, $dirAttr ) = @_;

    my $ftp    = $t->{ftp};
    my $bpc    = $t->{bpc};
    my $conf   = $t->{conf};
    my $view   = $t->{view};
    my $TopDir = $bpc->TopDir();

    my $path    = "$dirAttr->{name}/$dirName";
    my $dirList = $view->dirAttrib( -1, $t->{shareName}, $path );

    my ( $fileName, $fileAttr, $fileType );

    #print STDERR "BackupPC::Xfer::Ftp->restore($dirName)\n";

    #
    # Create the remote directory
    #
    undef $@;
    eval { $ftp->mkdir( $path, 1 ); };
    if ($@) {
        $t->logFileAction( "fail", $dirName, $dirAttr );
        return;
    }

 SCAN: while ( ($fileName, $fileAttr ) = each %$dirList ) {

        $fileType = fileType2Text( $fileAttr->{type} );

        if ( $fileType eq "dir" ) {
            if ( $t->restoreDir( $fileName, $fileAttr ) ) {
                $t->logWrite( "restored: $path/$fileName\n", 5 );
            } else {
                $t->logWrite( "restore failed: $path/$fileName\n", 3 );
            }

        } elsif ( $fileType eq "file" ) {
            $t->restoreFile( $fileName, $fileAttr );

        } elsif ( $fileType eq "hardlink" ) {
            #
            # Hardlinks cannot be restored.  however, if we have the
            # target file in the pool, we can restore that.
            #
            $t->restoreFile( $fileName, $fileAttr );

            next SCAN;

        } elsif ( $fileType eq "symlink" ) {
            #
            # Symlinks cannot be restored
            #
            next SCAN;

        } else {
            #
            # Ignore all other types (devices, doors, etc)
            #
            next SCAN;
        }
    }
}


sub restoreFile
{
    my ($t, $fileName, $fileAttr ) = @_;

    my $conf = $t->{conf};
    my $ftp  = $t->{ftp};

    my $poolFile = $fileAttr->{fullPath};
    my $fileDest = ( $conf->{ClientCharset} ne "" )
                 ? from_to( "$fileAttr->{name}/$fileName",
                            "utf8", $conf->{ClientCharset} )
                 : "$fileAttr->{name}/$fileName";

    #print STDERR "BackupPC::Xfer::Ftp->restoreFile($fileName)\n";

    undef $@;
    eval {
        if ( $ftp->put( $poolFile, $fileDest ) ) {
            $t->logFileAction( "restore", $fileName, $fileAttr );
        } else {
            $t->logFileAction( "fail", $fileName, $fileAttr );
        }
    };
    if ($@) {
        $t->logFileAction( "fail", $fileName, $fileAttr );
    }
}


#
#  usage:
#   $t->backup($path);
#
# $t->backup() is a recursive function that takes a path as an
# argument, and performs a backup on that folder consistent with the
# configuration parameters.  $path is considered rooted at
# $t->{shareName}, so no $ftp->cwd() command is necessary.
#
sub backup
{
    my ($t) =  @_;

    my $ftp    = $t->{ftp};
    my $bpc    = $t->{bpc};
    my $conf   = $t->{conf};
    my $TopDir = $bpc->TopDir();
    my $OutDir = "$TopDir/pc/$t->{client}/new/"
               . $bpc->fileNameEltMangle( $t->{shareName} );

    #
    # Prepare backup folder
    #
    unless ( eval { mkpath( $OutDir, 0, 0755 ); } ) {
        $t->{_errStr} = "can't create OutDir: $OutDir";
        $t->{xferErrCnt}++;
        return;
    }
    $t->logWrite("Created output directory $OutDir\n", 3);

    #
    # determine the filetype of the shareName and back it up
    # appropriately.  For now, assume that $t->{shareName} is a
    # directory.
    #
    my $f = {
              name     => "/",
              type     => BPC_FTYPE_DIR,
              mode     => 0775,
              mtime    => time,
              compress => $t->{compress},
            };
    if ( $t->handleDir($f) ) {

        print("adding top-level attrib for share $t->{shareName}\n") if ( $t->{logLevel} >= 4 );
        my $fNew = {
                    name     => $t->{shareName},
                    type     => BPC_FTYPE_DIR,
                    mode     => 0775,
                    uid      => 0,
                    gid      => 0,
                    size     => 0,
                    mtime    => time(),
                    inode    => $t->{Inode}++,
                    nlinks   => 0,
                    compress => $t->{compress},
               };

        $t->{AttrNew}->set("/", $fNew);

        $t->{xferOK} = 1;
        return 1;

    } else {

        $t->{xferBadShareCnt}++;
        return;
    }
}


####################################################################################
# FTP-specific functions
####################################################################################

#
# This is an encapulation of the logic necessary to grab the arguments
# from %Conf and throw it in a hash pointer to be passed to the
# Net::FTP object.
#
sub getFTPArgs
{
    my ($t)  = @_;
    my $conf = $t->{conf};

    return {
        Host         => $conf->{ClientNameAlias}
                     || $t->{hostIP}
                     || $t->{host},
#        Firewall     => undef,                            # not used
#        FirewallType => undef,                            # not used
#        BlockSize    => $conf->{FtpBlockSize} || 10240,
#        Port         => $conf->{FtpPort}      || 21,
#        Timeout      => defined($conf->{FtpTimeout}) ? $conf->{FtpTimeout} : 120,
        Debug        => $t->{logLevel} >= 5 ? 1 : 0,
        Passive      => (defined($conf->{FtpPassive}) ? $conf->{FtpPassive} : 1),
#        Hash         => undef,                            # do not touch
    };
}

#
#   usage:
#     $dirList = $t->remotels($path);
#
# remotels() returns a reference to a list of hash references that
# describe the contents of each file in the directory of the path
# specified.
#
sub remotels
{
    my ( $t, $name ) = @_;

    my $ftp  = $t->{ftp};
    my $bpc  = $t->{bpc};
    my $conf = $t->{conf};
    my $nameClient = $name;
    my $char2type = {
        'f' => BPC_FTYPE_FILE,
        'd' => BPC_FTYPE_DIR,
        'l' => BPC_FTYPE_SYMLINK,
    };

    my ( $dirContents, $remoteDir, $f );

    from_to( $nameClient, "utf8", $conf->{ClientCharset} )
                            if ( $conf->{ClientCharset} ne "" );
    $remoteDir = [];
    undef $@;
    $t->logWrite("remotels: about to list $name\n", 4);
    eval {
        $dirContents = ($nameClient =~ /^\.?$/ || $nameClient =~ /^\/*$/)
                                ? $ftp->dir() : $ftp->dir("$nameClient/");
    };
    if ( !defined($dirContents) ) {
        $t->{xferErrCnt}++;
        $t->logWrite("remotels: can't retrieve remote directory contents of $name: $!\n", 1);
        return "can't retrieve remote directory contents of $name: $!";
    }
    if ( $t->{logLevel} >= 4 ) {
        my $str = join("\n", @$dirContents);
        $t->logWrite("remotels: got dir() result:\n$str\n", 4);
    }

    foreach my $info ( @{parse_dir($dirContents)} ) {

        next if ( $info->[0] eq "." || $info->[0] eq ".." );

        from_to( $info->[0], $conf->{ClientCharset}, "utf8" )
                                if ( $conf->{ClientCharset} ne "" );

        my $dir = "$name/";
        $dir = "" if ( $name eq "" );
        $dir =~ s{^/+}{};

        $f = {
            name     => "$dir$info->[0]",
            type     => defined($char2type->{$info->[1]}) ? $char2type->{$info->[1]} : BPC_FTYPE_UNKNOWN,
            size     => $info->[2],
            mtime    => $info->[3],
            mode     => $info->[4],
            compress => $t->{compress},
        };

	$f->{fullName} = "$t->{sharePath}/$f->{name}";
	$f->{fullName} =~ s/\/+/\//g;

        $t->logWrite("remotels: adding name $f->{name}, type $f->{type}, size $f->{size}, mode $f->{mode}\n", 4);

        push( @$remoteDir, $f );
    }
    return $remoteDir;
}

#
# handleSymlink() backs up a symlink.
#
# TODO: fix this
#
sub handleSymlink
{
    my ( $t, $f, $OutDir, $attrib ) = @_;

    my $conf = $t->{conf};
    my $ftp  = $t->{ftp};
    my ( $target, $targetDesc );

    my $attribInfo = {
        type  => BPC_FTYPE_SYMLINK,
        mode  => $f->{mode},
        uid   => undef,            # unsupported
        gid   => undef,            # unsupported
        size  => 0,
        mtime => $f->{mtime},
    };

    #
    # If we are following symlinks, back them up as the type of file
    # they point to. Otherwise, backup the symlink.
    #
    if ( $conf->{FtpFollowSymlinks} ) {

        #
        # handle nested symlinks by recurring on the target until a
        # file or directory is found.
        #
        $f->{type} =~ /^l (.*)/;
        $target = $1;

        undef $@;
        eval {
            if ( $targetDesc = $ftp->dir("$target/") ) {
                $t->handleSymDir( $f, $OutDir, $attrib, $targetDesc );

            } elsif ( $targetDesc = $ftp->dir($target) ) {
                if ( $targetDesc->[4] eq 'file' ) {
                    $t->handleSymFile( $f, $OutDir, $attrib );

                } elsif ( $targetDesc->[4] =~ /l (.*)/ ) {
                    $t->logFileAction( "fail", $f->{name}, $attribInfo );
                    return;
                }
            } else {
                $t->( "fail", $f );
                return;
            }
        };
        if ($@) {
            $t->logFileAction( "fail", $f->{name}, $attribInfo );
            return;
        }

    } else {
        #
        # If we are not following symlinks, record them normally.
        #
        $attrib->set( $f->{name}, $attribInfo );
        $t->logFileAction("create", $f->{name}, $attribInfo);
    }
    return 1;
}


sub handleSymDir
{
    my ($t, $fSym, $OutDir, $attrib, $targetDesc) = @_;

    return 1;
 }


sub handleSymFile
{
    my ( $t, $fSym, $OutDir, $attrib, $targetDesc ) = @_;

    my $bpc  = $t->{bpc};
    my $conf = $t->{conf};

    my $f = {
        name  => $fSym->{name},
        type  => $targetDesc->[1],
        size  => $targetDesc->[2],
        mtime => $targetDesc->[3],
        mode  => $targetDesc->[4]
    };

    $f->{name} = $fSym->{name};
    from_to( $f->{name}, $conf->{ClientCharset}, "utf8" )
                            if ( $conf->{ClientCharset} ne "" );

    $f->{fullName} = "$t->{shareName}/$fSym->{name}/$fSym->{name}";
    $f->{fullName} =~ s/\/+/\//g;

    #
    # since FTP servers follow symlinks, we can just do this:
    #
    return $t->handleFile( $f );
}


#
# handleDir() backs up a directory, and initiates a backup of its
# contents.
#
sub handleDir
{
    my ( $t, $f ) = @_;

    my $ftp     = $t->{ftp};
    my $bpc     = $t->{bpc};
    my $conf    = $t->{conf};
    my $stats   = $t->{stats};
    my $AttrNew = $t->{AttrNew};
    my $same    = 0;
    my $a       = $AttrNew->get($f->{name});

    my ( $exists, $digest, $outSize, $errs );
    my ( $poolWrite, $poolFile );
    my ( $localDir, $remoteDir, %expectedFiles );

    $a->{poolPath} = $bpc->MD52Path($a->{digest}, $a->{compress}) if ( length($a->{digest}) );

    my $pathNew = $AttrNew->getFullMangledPath($f->{name});

    if ( -d $pathNew ) {
        $t->logFileAction( "same", $f->{name}, $f );
        $same = 1;
    } else {
        if ( -e $pathNew ) {
            print("Ftp handleDir: $pathNew ($f->{name}) isn't a directory... renaming and recreating\n")
                                         if ( defined($a) && $t->{logLevel} >= 4 );
        } else {
            print("Ftp handleDir: creating directory $pathNew ($f->{name})\n")
                                         if ( defined($a) && $t->{logLevel} >= 3 );
        }
        $t->moveFileToOld($a, $f);
        $t->logFileAction("new", $f) if ( $t->{logLevel} >= 1 );
        #
        # make sure all the parent directories exist and have directory attribs
        #
        $t->pathCreate($pathNew, 1);
        my $name = $f->{name};
        while ( length($name) > 1 ) {
            if ( $name =~ m{/} ) {
                $name =~ s{(.*)/.*}{$1};
            } else {
                $name = "/";
            }
            my $a = $AttrNew->get($name);
            last if ( defined($a) && $a->{type} == BPC_FTYPE_DIR );
            print("Ftp handleDir: adding BPC_FTYPE_DIR attrib entry for $name\n")
                                         if ( $t->{logLevel} >= 3 );
            my $fNew = {
                            name     => $name,
                            type     => BPC_FTYPE_DIR,
                            mode     => $f->{mode},
                            uid      => $f->{uid},
                            gid      => $f->{gid},
                            size     => 0,
                            mtime    => $f->{mtime},
                            inode    => $t->{Inode}++,
                            nlinks   => 0,
                            compress => $t->{compress},
                       };
            $AttrNew->set($name, $fNew);
            $t->moveFileToOld($a, $fNew);
        }
    }

    $t->logWrite("handleDir: name = $f->{name}, pathNew = $pathNew\n", 4);

    $remoteDir = $t->remotels( $f->{name} );

    if ( ref($remoteDir) ne 'ARRAY' ) {
        $t->logWrite("handleDir failed: $remoteDir\n", 1);
        $t->logFileAction( "fail", $f->{name}, $f );
        $t->{xferErrCnt}++;
        return;
    }

    my $all = $AttrNew->getAll($f->{name});
    $bpc->flushXSLibMesgs();
    foreach my $name ( keys(%$all) ) {
        $expectedFiles{$name} = 0;
    }

    #
    # take care of each file in the directory
    #
    foreach my $a ( @{$remoteDir} ) {

        my $fullName = "$t->{shareName}/$a->{name}";
        $fullName =~ s{/+}{/}g;
        next if ( !$t->checkIncludeExclude($fullName) );
        
        #
        # handle based on filetype
        #
        if ( $a->{type} == BPC_FTYPE_FILE ) {

            $t->handleFile($a);

        } elsif ( $a->{type} == BPC_FTYPE_DIR ) {

            $t->handleDir($a);

        } elsif ( $a->{type} == BPC_FTYPE_SYMLINK ) {

            $t->handleSymlink($a);

        } else {

            print("handleDir: unexpected file type $a->{type} for $a->{name})\n");
            $t->{xferBadFileCnt}++;

        }

        #
        # Mark file as seen in expected files hash
        #
        $expectedFiles{$a->{name}}++;

    } # end foreach (@{$remoteDir})

    #
    # If we didn't see a file, move to old.
    #
    foreach my $name ( keys(%$all) ) {
        my $a = $all->{$name};
        next if ( $expectedFiles{$a->{name}} );
        $t->moveFileToOld($a, {name => $a->{name}});
    }

    #
    # Explicit success
    #
    return 1;
}


#
# handleFile() backs up a file.
#
sub handleFile
{
    my ( $t, $f ) = @_;

    my $bpc        = $t->{bpc};
    my $ftp        = $t->{ftp};
    my $view       = $t->{view};
    my $stats      = $t->{stats};

    my ( $poolFile, $poolWrite, $data, $localSize );
    my ( $exists, $digest, $outSize, $errs );
    my ( $oldAttrib );
    local *FTP;

    my $a    = $t->{AttrNew}->get($f->{name});
    my $aOld = $t->{AttrOld}->get($f->{name}) if ( $t->{AttrOld} );
    my $same = 0;

    #
    # If this is an incremental backup and the file exists in a
    # previous backup unchanged, write the attribInfo for the file
    # accordingly.
    #
    if ( $t->{type} eq "incr" ) {
        if (   $a
                && $f->{type}  == $a->{type}
                && $f->{mtime} == $a->{mtime}
                && $f->{size}  == $a->{size}
                && $f->{uid}   == $a->{uid}
                && $f->{gid}   == $a->{gid} ) {
            return 1;
        }
    }

    #
    # If this is a full backup or the file has changed on the host,
    # back it up.
    #
    # TODO: convert back to local charset?
    #
    undef $@;
    eval { tie ( *FTP, 'Net::FTP::RetrHandle', $ftp, "$f->{name}" ); };
    if ( !*FTP || $@ ) {
        $t->logFileAction( "fail", $f->{name}, $f );
        $t->{xferBadFileCnt}++;
        $stats->{errCnt}++;
        return;
    }

    print("PoolWrite->new(name = $f->{name}, compress = $t->{compress})\n")
                                 if ( $t->{logLevel} >= 3 );
    $poolWrite = BackupPC::XS::PoolWrite::new($t->{compress});
    $localSize = 0;

    undef $@;
    eval {
        while (<FTP>) {
            $localSize += length($_);
            $poolWrite->write( \$_ );
        }
    };
    ( $exists, $digest, $outSize, $errs ) = $poolWrite->close();
    $f->{digest} = $digest;

    if ( $a && $a->{digest} eq $digest ) {
        $same = 1 if ( $a->{nlinks} == 0 );
    }
    
    if ( !$same ) {
        $t->moveFileToOld($a, $f);
    }

    if ( $exists ) {
        $stats->{ExistFileCnt}++;
        $stats->{ExistFileCompSize} += $outSize;
        $stats->{ExistFileSize}     += $f->{size};
    } else {
        $stats->{NewFileCnt}++;
        $stats->{NewFileCompSize} += $outSize;
        $stats->{NewFileSize}     += $f->{size};
    }

    if ( !*FTP || $@ || $errs ) {
        $t->logFileAction( "fail", $f->{name}, $f );
        $t->{xferBadFileCnt}++;
        $stats->{errCnt} += scalar @$errs;
        return;
    }

    #
    # this should never happen
    #
    if ( $localSize != $f->{size} ) {
        $t->logFileAction( "fail", $f->{name}, $f );
        $t->logWrite("Size mismatch on $f->{name} ($localSize vs $f->{size})\n", 3);
        $stats->{xferBadFileCnt}++;
        $stats->{errCnt}++;
        return;
    }

    #
    # Update attribs
    #
    $t->attribUpdate($a, $f, $same);

    #
    # Perform logging
    #
    $t->logFileAction( $same ? "same" : $exists ? "pool" : "new", $f->{name}, $f );

    #
    # Cumulate the stats
    #
    $stats->{TotalFileCnt}++;
    $stats->{ExistFileCnt}++;
    $stats->{ExistFileCompSize} += -s $poolFile;
    $stats->{ExistFileSize}     += $f->{size};
    $stats->{TotalFileSize}     += $f->{size};

    $t->{byteCnt} += $localSize;
    $t->{fileCnt}++;
}

#
# Generate a log file message for a completed file.  Taken from
# BackupPC_tarExtract. $f should be an attrib object.
#
sub logFileAction
{
    my ( $t, $action, $name, $attrib ) = @_;

    my $owner = "$attrib->{uid}/$attrib->{gid}";
    my $type = BackupPC::XS::Attrib::fileType2Text($attrib->{type});

    $type = $1 if ( $type =~ /(.)/ );
    $type = "" if ( $type eq "f" );

    $name  = "."   if ( $name  eq "" );
    $owner = "-/-" if ( $owner eq "/" );

    $t->{bpc}->flushXSLibMesgs();

    my $fileAction = sprintf(
        "  %-6s %1s%4o %9s %11.0f %s\n",
        $action, $type, $attrib->{mode} & 07777,
        $owner, $attrib->{size}, $attrib->{name}
    );

    if ( ($t->{stats}{TotalFileCnt} % 20) == 0 ) {
        printf("__bpc_progress_fileCnt__ %d\n", $t->{stats}{TotalFileCnt});
    }

    return $t->logWrite( $fileAction, 1 );
}

#
# Move $a to old; the new file $f will replace $a
#
sub moveFileToOld
{
    my($t, $a, $f) = @_;
    my $AttrNew = $t->{AttrNew};
    my $AttrOld = $t->{AttrOld};
    my $bpc = $t->{bpc};

    if ( !$a || keys(%$a) == 0 ) {
        #
        # A new file will be created, so add delete attribute to old
        #
        $AttrOld->set($f->{name}, { type => BPC_FTYPE_DELETED }) if ( $AttrOld );
        return;
    }
    if ( !$AttrOld || $AttrOld->get($f->{name}) ) {
        if ( $a->{nlinks} > 0 ) {
            $a->{nlinks}--;
            if ( $a->{nlinks} <= 0 ) {
                $AttrNew->deleteInode($a->{inode});
                BackupPC::XS::PoolRefCnt::DeltaUpdate($a->{compress}, $a->{digest}, -1);
            } else {
                $AttrNew->setInode($a->{inode}, $a);
            }
        } else {
            BackupPC::XS::PoolRefCnt::DeltaUpdate($a->{compress}, $a->{digest}, -1)
                                            if ( length($a->{digest}) );
        }
        $AttrNew->delete($f->{name});
        if ( $a->{type} == BPC_FTYPE_DIR ) {
            #
            # Delete the directory tree, including updating reference counts
            #
            my $pathNew = $AttrNew->getFullMangledPath($f->{name});
            BackupPC::DirOps::RmTreeQuiet($bpc, $pathNew, $a->{compress});
        }
        return;
    }

    if ( $a->{nlinks} > 0 ) {
        #
        # only write the inode if it doesn't exist in old;
        # in that case, increase the pool reference count
        #
        if ( $AttrOld->set($f->{name}, $a, 1) ) {
            BackupPC::XS::PoolRefCnt::DeltaUpdate($a->{compress}, $a->{digest}, 1);
        }
    } else {
        $AttrOld->set($f->{name}, $a);
    }
    $AttrNew->delete($f->{name});
    if ( $a->{type} == BPC_FTYPE_DIR ) {
        #
        # For a directory we need to move it to old, and copy
        # any inodes that are referenced below this directory.
        #
        my $pathNew = $AttrNew->getFullMangledPath($f->{name});
        my $pathOld = $AttrOld->getFullMangledPath($f->{name});
        print("moveFileToOld(..., $f->{name}): renaming $pathNew to $pathOld\n")
                                 if ( $t->{logLevel} >= 3 );
        $AttrNew->flush(0, $f->{name});
        $t->copyInodes($f->{name});
        $t->pathCreate($pathOld);
        if ( !rename($pathNew, $pathOld) ) {
            print("moveFileToOld(..., $f->{name}): can't rename $pathNew to $pathOld\n");
            $t->{xferErrCnt}++;
        }
    }
}

sub copyInodes
{
    my($t, $dirName) = @_;
    my $AttrNew = $t->{AttrNew};
    my $AttrOld = $t->{AttrOld};
    my $bpc = $t->{bpc};

    return if ( !defined($AttrOld) );

    my $dirPath  = $AttrNew->getFullMangledPath($dirName);

    print("copyInodes: dirName = $dirName, dirPath = $dirPath\n") if ( $t->{logLevel} >= 3 );

    my $attrAll = $AttrNew->getAll($dirName);
    print("copyInodes: finished getAll()\n");
    $bpc->flushXSLibMesgs();

    #
    # Add non-attrib directories (ie: directories that were created
    # to store attributes in deeper directories), since these
    # directories may not appear in the attrib file at this level.
    #
    if ( defined(my $entries = BackupPC::DirOps::dirRead($bpc, $dirPath)) ) {
        foreach my $e ( @$entries ) {
            next if ( $e->{name} eq "."
                   || $e->{name} eq ".."
                   || $e->{name} eq "inode"
                   || !-d "$dirPath/$e->{name}" );
            my $fileUM = $bpc->fileNameUnmangle($e->{name});
            next if ( $attrAll && defined($attrAll->{$fileUM}) );
            $attrAll->{$fileUM} = {
                type     => BPC_FTYPE_DIR,
                noAttrib => 1,
            };
        }
    }

    foreach my $fileUM ( keys(%$attrAll) ) {
        my $a = $attrAll->{$fileUM};
        if ( $a->{type} == BPC_FTYPE_DIR ) {
            #
            # recurse into this directory
            #
            $t->copyInodes("$dirName/$fileUM");
            next;
        }
        print("copyInodes($dirName): $fileUM has inode=$a->{inode}, links = $a->{nlinks}\n") if ( $t->{logLevel} >= 6 );
        next if ( $a->{nlinks} == 0 );
        #
        # Copy the inode if it doesn't exist in old and increment the
        # digest reference count.
        my $aInode = $AttrNew->getInode($a->{inode});
        if ( !defined($AttrOld->getInode($a->{inode})) ) {
            print("copyInodes($dirName): $fileUM moving inode $a->{inode} to old\n") if ( $t->{logLevel} >= 5 );
            $AttrOld->setInode($a->{inode}, $aInode);
            BackupPC::XS::PoolRefCnt::DeltaUpdate($aInode->{compress}, $aInode->{digest}, 1);
        }

        #
        # Also decrement the inode reference count in new.
        #
        $aInode->{nlinks}--;
        if ( $aInode->{nlinks} == 0 ) {
            $AttrNew->deleteInode($a->{inode});
            print("copyInodes($dirName): $fileUM deleting inode $a->{inode} in new\n") if ( $t->{logLevel} >= 5 );
            BackupPC::XS::PoolRefCnt::DeltaUpdate($aInode->{compress}, $aInode->{digest}, -1);
        } else {
            $AttrNew->setInode($a->{inode}, $aInode);
        }
        $bpc->flushXSLibMesgs();
    }
}

sub attribUpdate
{
    my($t, $a, $f, $same) = @_;

    #
    # If the file was the same, we have to check the attributes to see if they
    # are the same too.  If the file is newly written, we just write the
    # new attributes.
    #
    my $AttrNew     = $t->{AttrNew};
    my $AttrOld     = $t->{AttrOld};
    my $bpc         = $t->{bpc};
    my $attribSet   = 1;
    my $newCompress = $t->{compress};

    $newCompress = $a->{compress} if ( $a && defined($a->{compress}) );

    printf("File %s: old digest %s, new digest %s\n", $f->{name}, unpack("H*", $a->{digest}), unpack("H*", $f->{digest}))
                                    if ( $a && $t->{logLevel} >= 5 );

    if ( $same && $a ) {
        if ( $a->{type}   == $f->{type}
          && $a->{mode}   == S_IMODE($f->{mode})
          && $a->{uid}    == $f->{uid}
          && $a->{gid}    == $f->{gid}
          && $a->{size}   == $f->{size}
          && $a->{mtime}  == $f->{mtime}
          && $a->{digest} eq $f->{digest} ) {
            #
            # same contents, same attributes, so no need to rewrite
            #
            $attribSet = 0;
        } else {
            #
            # same contents, different attributes, so copy to old and
            # we will write the new attributes below
            #
            if ( $AttrOld && !$AttrOld->get($f->{name}) ) {
                if ( $AttrOld->set($f->{name}, $a, 1) ) {
                    BackupPC::XS::PoolRefCnt::DeltaUpdate($newCompress, $f->{digest}, 1);
                }
            }
            $f->{inode}  = $a->{inode};
            $f->{nlinks} = $a->{nlinks};
        }
    } else {
        #
        # file is new or changed; update ref counts
        #
        BackupPC::XS::PoolRefCnt::DeltaUpdate($newCompress, $f->{digest}, 1)
                                                if ( $f->{digest} ne "" );
    }

    if ( $attribSet ) {
        my $newInode = $f->{inode};
        $newInode = $t->{Inode}++ if ( !defined($newInode) );
        my $nlinks = 0;
        $nlinks = $f->{nlinks} if ( defined($f->{nlinks}) );
        $AttrNew->set($f->{name}, {
                        type     => $f->{type},
                        mode     => S_IMODE($f->{mode}),
                        uid      => $f->{uid},
                        gid      => $f->{gid},
                        size     => $f->{size},
                        mtime    => $f->{mtime},
                        inode    => $newInode,
                        nlinks   => $nlinks,
                        compress => $newCompress,
                        digest   => $f->{digest},
                   });
    }
    $bpc->flushXSLibMesgs();
}

#
# Create the parent directory of $fullPath (if necessary).
# If $noStrip != 0 then $fullPath is the directory to create,
# rather than the parent.
#
sub pathCreate
{
    my($t, $fullPath, $noStrip) = @_;

    #
    # Get parent directory of $fullPath
    #
    print("pathCreate: fullPath = $fullPath\n")  if ( $t->{logLevel} >= 6 );
    $fullPath =~ s{/[^/]*$}{} if ( !$noStrip );
    return 0 if ( -d $fullPath );
    unlink($fullPath) if ( -e $fullPath );
    eval { mkpath($fullPath, 0, 0777) };
    if ( $@ ) {
        print("Can't create $fullPath\n");
        $t->{xferErrCnt}++;
        return -1;
    }
    return 0;
}

1;
