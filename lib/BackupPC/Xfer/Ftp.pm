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
#   This program is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License as
#   published by the Free Software Foundation; either version 2 of the
#   License, or (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
#   02111-1307 USA
#
#
#========================================================================
#
# Unreleased, planned release in 3.2 (or 3.1.1)
#
# See http://backuppc.sourceforge.net.
#
#========================================================================


package BackupPC::Xfer::Ftp;

use strict;

use BackupPC::View;
use BackupPC::Attrib qw(:all);

use Encode qw/from_to encode/;
use File::Listing qw/parse_dir/;
use File::Path;
use Data::Dumper;
use base qw(BackupPC::Xfer::Protocol);

use vars qw( $FTPLibOK $FTPLibErr $ARCLibOK );

use constant S_IFMT => 0170000;

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
    my ($t) = @_;

    my $bpc  = $t->{bpc};
    my $conf = $t->{conf};

    my ( @fileList, $logMsg, $incrDate, $args, $dumpText );

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
    $args = $t->getFTPArgs();

    #
    # Create the Net::FTP::AutoReconnect or Net::FTP object.
    #
    unless ( $t->{ftp} = ($ARCLibOK) ? Net::FTP::AutoReconnect->new(%$args)
                                     : Net::FTP->new(%$args) )
    {
        $t->{_errStr} = "Can't open connection to $args->{Host}";
        $t->{xferErrCnt}++;
        return;
    }

    #
    # Log in to the ftp server and set appropriate path information.
    #
    unless ( $t->{ftp}->login( $conf->{FtpUserName}, $conf->{FtpPasswd} ) ) {
        $t->{_errStr} = "Can't login to $args->{Host}";
        $t->{xferErrCnt}++;
        return;
    }

    unless ( $t->{ftp}->binary() ) {
        $t->{_errStr} = "Can't enable binary transfer mode to $args->{Host}";
        $t->{xferErrCnt}++;
        return;
    }

    unless (    ( $t->{shareName} =~ m/^\.?$/ )
             || ( $t->{ftp}->cwd( $t->{shareName} ) ) )
    {
        $t->{_errStr} = "Can't change working directory to $t->{shareName}";
        $t->{xferErrCnt}++;
        return;
    }

    unless  ( $t->{sharePath} = $t->{ftp}->pwd() ) {
        $t->{_errStr} = "Can't retrieve full working directory of $t->{shareName}";
        $t->{xferErrCnt}++;
        return;
    }

    #
    # log the beginning of action based on type
    #
    if ( $t->{type} eq 'restore' ) {
        $logMsg = "restore started on directory $t->{shareName}";

    } elsif ( $t->{type} eq 'full' ) {
        $logMsg = "full backup started on directory $t->{shareName}";

    } elsif ( $t->{type} eq 'incr' ) {

        $incrDate = $bpc->timeStamp( $t->{incrBaseTime} - 3600, 1 );
        $logMsg = "incremental backup started back to $incrDate" .
            " (backup #$t->{incrBaseBkupNum}) for directory" . "
            $t->{shareName}";
    }

    #
    # call the recursive function based on the type of action
    #
    if ( $t->{type} eq 'restore' ) {

        $t->restore();
        $logMsg = "Restore of $args->{Host} complete";

    } elsif ( $t->{type} eq 'incr' ) {

        $t->backup();
        $logMsg = "Incremental backup of $args->{Host} complete";

    } elsif ( $t->{type} eq 'full' ) {

        $t->backup();
        $logMsg = "Full backup of $args->{Host} complete";
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
        return \( $tarErrs,      $nFilesExist, $sizeExist,
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

    my $path    = "$dirAttr->{relPath}/$dirName";
    my $dirList = $view->dirAttrib( -1, $t->{shareName}, $path );

    my ( $fileName, $fileAttr, $fileType );

    #print STDERR "BackupPC::Xfer::Ftp->restore($dirName)\n";

    #
    # Create the remote directory
    #
    unless ( $ftp->mkdir( $path, 1 ) ) {

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
                 ? from_to( "$fileAttr->{relPath}/$fileName",
                            "utf8", $conf->{ClientCharset} )
                 : "$fileAttr->{relPath}/$fileName";

    #print STDERR "BackupPC::Xfer::Ftp->restoreFile($fileName)\n";

    #
    # Note: is logging necessary here?
    #
    if ( $ftp->put( $poolFile, $fileDest ) ) {
        $t->logFileAction("restore", $fileName, $fileAttr);

    } else {
        $t->logFileAction("fail", $fileName, $fileAttr);
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
    # Prepare the view object
    #
    $t->{view} = BackupPC::View->new( $bpc, $t->{client}, $t->{backups} );

    #
    # Prepare backup folder
    #
    unless ( mkpath( $OutDir, 0, 0755 ) ) {
        $t->{_errStr} = "can't create OutDir: $OutDir";
        $t->{xferErrCnt}++;
        return;
    }

    #
    # determine the filetype of the shareName and back it up
    # appropriately.  For now, assume that $t->{shareName} is a
    # directory.
    #
    my $f = {
              relPath  => "",
              fullName => $t->{shareName},
            };

    if ( $t->handleDir( $f, $OutDir ) ) {

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
    my $bpc  = $t->{bpc};
    my $conf = $t->{conf};

    #
    # accepted default key => value pairs to Net::FTP
    #
    my $args = {
                 Host         => undef,
                 Firewall     => undef,          # not used
                 FirewallType => undef,          # not used
                 BlockSize    => 10240,
                 Port         => 21,
                 Timeout      => 120,
                 Debug        => 0,              # do not touch
                 Passive      => 1,              # do not touch
                 Hash         => undef,          # do not touch
                 LocalAddr    => "localhost",    # do not touch
               };

    #
    # This is mostly to fool makeDist
    #
    exists( $conf->{ClientNameAlias} ) && exists( $conf->{FtpBlockSize} ) &&
    exists( $conf->{FtpPort} )         && exists( $conf->{FtpTimeout} )
        or die "Configuration variables for FTP not present in config.pl";

    #
    # map of options from %Conf in the config.pl scripts to options
    # the Net::FTP::AutoReconnect object.
    #
    my $argMap = {
                   "Host"      => "ClientNameAlias",
                   "BlockSize" => "FtpBlockSize",
                   "Port"      => "FtpPort",
                   "Timeout"   => "FtpTimeout",
                 };

    foreach my $key ( keys(%$args) ) {
        $args->{$key} = $conf->{ $argMap->{$key} } || $args->{$key};
    }

    #
    # Fix for $args->{Host} since it can be in more than one location.
    # Note the precedence here, this may need to be fixed.  Order of
    # precedence:
    #   $conf->{ClientNameAlias}
    #   $t->{hostIP}
    #   $t->{host}
    #
    $args->{Host} ||= $t->{hostIP};
    $args->{Host} ||= $t->{host};

    #
    # return the reference to the hash of items
    #
    return $args;
}


#
#   usage:
#     $dirList = $t->remotels($path);
#
# remotels() returns a reference to a list of hash references that
# describe the contents of each file in the directory of the path
# specified.
#
# In the future, I would like to make this function return objects in
# Attrib format.  That would be very optimal, and I could probably
# release the code to CPAN.
#
sub remotels
{
    my ( $t, $path ) = @_;

    my $ftp  = $t->{ftp};
    my $bpc  = $t->{bpc};
    my $conf = $t->{conf};

    my ( $dirContents, $remoteDir, $f );

    unless ( $dirContents = ($path =~ /^\.?$/ ) ? $ftp->dir() :
                                                  $ftp->dir("$path/") )
    {
        $t->{xferErrCnt}++;
        return "can't retrieve remote directory contents of $path";
    }

    foreach my $info ( @{parse_dir($dirContents)} ) {

        $f = {
	       name   => $info->[0],
	       type   => $info->[1],
	       size   => $info->[2],
	       mtime  => $info->[3],
	       mode   => $info->[4],
	     };

	#
	# convert & store utf8 version of filename
        #
        $f->{utf8name} = $f->{name};
        from_to( $f->{utf8name}, $conf->{ClientCharset}, "utf8" );

	#
	# construct the full name
	#
	$f->{fullName} = "$t->{sharePath}/$path/$f->{name}";
	$f->{fullName} =~ s/\/+/\//g;

	$f->{relPath} = ($path eq "") ? $f->{name} : "$path/$f->{name}";
	$f->{relPath} =~ s/\/+/\//g;

        push( @$remoteDir, $f );
    }

    return $remoteDir;
}


#
# ignoreFileCheck() looks at the attributes of the arguments and the
# backup types, and determines if the file should be skipped in this
# backup.
#
sub ignoreFileCheck
{
    my ( $t, $f, $attrib ) = @_;

    #
    # case for ignoring the files '.' & '..'
    #
    if ( $f->{name} =~ /^\.\.?$/ ) {
        return 1;
    }

    #
    # Check the include/exclude lists.  the function returns true if
    # the file should be backed up, so return the opposite.
    #
    return ( !$t->checkIncludeExclude( $f->{fullName} ) );
}


#
# handleSymlink() backs up a symlink.
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

        if ( $targetDesc = $ftp->dir("$target/") ) {
            $t->handleSymDir( $f, $OutDir, $attrib, $targetDesc );

        } elsif ( $targetDesc = $ftp->dir($target) ) {
            if ( $targetDesc->[4] eq 'file' ) {
                $t->handleSymFile( $f, $OutDir, $attrib );

            } elsif ( $targetDesc->[4] =~ /l (.*)/) {

                $t->logFileAction("fail", $f->{utf8name}, $attribInfo);
                return;
            }
        } else {

            $t->("fail", $f);
            return;
        }

    } else {

        #
        # If we are not following symlinks, record them normally.
        #
        $attrib->set( $f->{utf8name}, $attribInfo );
        $t->logFileAction("create", $f->{utf8name}, $attribInfo);
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

    $f->{utf8name} = $fSym->{name};
    from_to( $f->{utf8name}, $conf->{ClientCharset}, "utf8" );

    $f->{relPath} = $fSym->{relPath};

    $f->{fullName} = "$t->{shareName}/$fSym->{relPath}/$fSym->{name}";
    $f->{fullName} =~ s/\/+/\//g;

    #
    # since FTP servers follow symlinks, we can jsut do this:
    #
    return $t->handleFile( $f, $OutDir, $attrib );
}


#
# handleDir() backs up a directory, and initiates a backup of its
# contents.
#
sub handleDir
{
    my ( $t, $dir, $OutDir ) = @_;

    my $ftp   = $t->{ftp};
    my $bpc   = $t->{bpc};
    my $conf  = $t->{conf};
    my $view  = $t->{view};
    my $stats = $t->{stats};

    my ( $exists, $digest, $outSize, $errs );
    my ( $poolWrite, $poolFile, $attribInfo );
    my ( $localDir, $remoteDir, $attrib, %expectedFiles );

    if ( exists($dir->{utf8name})) {
        $OutDir .= "/" . $bpc->fileNameMangle( $dir->{utf8name} );
    }

    unless ( -d $OutDir ) {

        mkpath( $OutDir, 0, 0755 );
        $t->logFileAction( "create", $dir->{utf8name}, $dir );
    }

    $attrib    = BackupPC::Attrib->new( { compress => $t->{Compress} } );
    $remoteDir = $t->remotels( $dir->{relPath} );

    if ( $t->{type} eq "incr" ) {
        $localDir  = $view->dirAttrib( $t->{incrBaseBkupNum},
                                       $t->{shareName}, $dir->{relPath} );
        %expectedFiles = map { $_ => 0 } sort keys %$localDir
    }

    #
    # take care of each file in the directory
    #
 SCAN: foreach my $f ( @{$remoteDir} ) {

        next SCAN if $t->ignoreFileCheck( $f, $attrib );

        #
        # handle based on filetype
        #
        if ( $f->{type} eq 'f' ) {
            $t->handleFile( $f, $OutDir, $attrib );

        } elsif ( $f->{type} eq 'd' ) {

            $attribInfo = {
                type  => BPC_FTYPE_DIR,
                mode  => $f->{mode},
                uid   => undef,           # unsupported
                gid   => undef,           # unsupported
                size  => $f->{size},
                mtime => $f->{mtime},
            };

            #print STDERR "$f->{utf8name}: ". Dumper($attribInfo);

            if ( $t->handleDir($f, $OutDir) ) {
                $attrib->set( $f->{utf8name}, $attribInfo);
            }

        } elsif ( $f->{type} =~ /^l (.*)/ ) {
            $t->handleSymlink( $f, $OutDir, $attrib );

        } else {
            #
            # do nothing
            #
        }

        #
        # Mark file as seen in expected files hash
        #
        $expectedFiles{ $f->{utf8name} }++ if ( $t->{type} eq "incr" );

    } # end foreach (@{$remoteDir})

    #
    # If the backup type is incremental, mark the files that are not
    # present on the server as deleted.
    #
    if ( $t->{type} eq "incr" ) {
        while ( my ($f, $seen) = each %expectedFiles ) {
            $attrib->set( $f, { type => BPC_FTYPE_DELETED } )
                unless ($seen);
        }
    }

    #
    # print the directory attributes, now that the directory is done.
    #
    my $fileName = $attrib->fileName($OutDir);
    my $data     = $attrib->writeData();

    $poolWrite = BackupPC::PoolWrite->new( $bpc, $fileName, length($data),
                                           $t->{Compress} );
    $poolWrite->write( \$data );
    ( $exists, $digest, $outSize, $errs ) = $poolWrite->close();

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
    my ( $t, $f, $OutDir, $attrib ) = @_;

    my $bpc        = $t->{bpc};
    my $ftp        = $t->{ftp};
    my $view       = $t->{view};
    my $stats      = $t->{stats};
    my $newFilesFH = $t->{newFilesFH};

    my ( $poolFile, $poolWrite, $data, $localSize );
    my ( $exists, $digest, $outSize, $errs );
    my ( $oldAttrib );
    local *FTP;

    #
    # If this is an incremental backup and the file exists in a
    # previous backup unchanged, write the attribInfo for the file
    # accordingly.
    #
    if ( $t->{type} eq "incr" ) {
        return 1 if $t->incrFileExistCheck( $f, $attrib );
    }

    my $attribInfo = {
                       type  => BPC_FTYPE_FILE,
                       mode  => $f->{mode},
                       uid   => undef,            # unsupported
                       gid   => undef,            # unsupported
                       size  => $f->{size},
                       mtime => $f->{mtime},
                     };

    #
    # If this is a full backup or the file has changed on the host,
    # back it up.
    #
    unless ( tie( *FTP, 'Net::FTP::RetrHandle', $ftp, $f->{fullName} ) ) {

        $t->handleFileAction( "fail", $attribInfo );
        $t->{xferBadFileCnt}++;
        $stats->{errCnt}++;
        return;
    }

    $poolFile  = $OutDir . "/" . $bpc->fileNameMangle( $f->{name} );
    $poolWrite = BackupPC::PoolWrite->new( $bpc, $poolFile, $f->{size},
                                           $bpc->{xfer}{compress} );

    $localSize = 0;
    while (<FTP>) {

        $localSize += length($_);
        $poolWrite->write( \$_ );
    }
    ( $exists, $digest, $outSize, $errs ) = $poolWrite->close();

    #
    # calculate the file statistics
    #
    if (@$errs) {

        $t->logFileAction( "fail", $f->{utf8name}, $attribInfo );
        unlink($poolFile);
        $t->{xferBadFileCnt}++;
        $t->{errCnt} += scalar(@$errs);
        return;
    }

    #
    # this should never happen
    #
    if ( $localSize != $f->{size} ) {

        $t->logFileAction( "fail", $f->{utf8name}, $attribInfo );
        unklink($poolFile);
        $stats->{xferBadFileCnt}++;
        $stats->{errCnt}++;
        return;
    }

    #
    # Perform logging
    #
    $attrib->set( $f->{utf8name}, $attribInfo );
    $t->logFileAction( $exists ? "pool" : "create", $f->{utf8name}, $attribInfo );
    print $newFilesFH "$digest $f->{size} $poolFile\n" unless $exists;

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
# this function checks if the file has been modified on disk, and if
# it has, returns.  Otherwise, it updates the attrib values.
#
sub incrFileExistCheck
{
    my ($t, $f, $attrib) = @_;

    my $view = $t->{view};

    my $oldAttribInfo = $view->fileAttrib( $t->{incrBaseBkupNum},
                                       $t->{shareName}, $f->{relPath} );

    #print STDERR "*" x 50 . "\n";
    #print STDERR "Old data:\n" . Dumper($oldAttribInfo);
    #print STDERR "New data:\n" . Dumper($f);
    #print STDERR "$f->{fullName}: $oldAttribInfo->{mtime} ?= $f->{mtime}, $oldAttribInfo->{size} ?= $f->{size}\n";

    return ( $oldAttribInfo->{mtime} == $f->{mtime}
          && $oldAttribInfo->{size} == $f->{size} );
}


#
# Generate a log file message for a completed file.  Taken from
# BackupPC_tarExtract. $f should be an attrib object.
#
sub logFileAction
{
    my ( $t, $action, $name, $attrib ) = @_;

    my $owner = "$attrib->{uid}/$attrib->{gid}";
    my $type =
      ( ( "", "p", "c", "", "d", "", "b", "", "", "", "l", "", "s" ) )
      [ ( $attrib->{mode} & S_IFMT ) >> 12 ];

    $name  = "."   if ( $name  eq "" );
    $owner = "-/-" if ( $owner eq "/" );

    my $fileAction = sprintf( "  %-6s %1s%4o %9s %11.0f %s\n",
                              $action, $type, $attrib->{mode} & 07777,
                              $owner, $attrib->{size}, $name );

    return $t->logWrite( $fileAction, 1 );
}

1;
