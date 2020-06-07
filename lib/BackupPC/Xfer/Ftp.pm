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
# Version 4.3.3, released 5 Apr 2020.
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
            $FTPLibOK  = 0;
            $FTPLibErr = "module $module doesn't exist: $@";
            last;
        }
    }

    eval "use Net::FTP::AutoReconnect;";
    $ARCLibOK = (defined($@)) ? 1 : 0;
    #
    # TODO
    #
    $ARCLibOK = 0;
}

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
    my($class, $bpc, $args) = @_;
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
        }
    );
    return bless($t, $class);
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

    my $bpc    = $t->{bpc};
    my $conf   = $t->{conf};
    my $TopDir = $bpc->TopDir();

    my(@fileList, $logMsg, $args, $dumpText);

    #
    # initialize the statistics returned by getStats()
    #
    foreach (
        qw/byteCnt fileCnt xferErrCnt xferBadShareCnt
        xferBadFileCnt xferOK hostAbort hostError
        lastOutputLine/
    ) {
        $t->{$_} = 0;
    }

    #
    # Net::FTP::RetrHandle is necessary.
    #
    if ( !$FTPLibOK ) {
        $t->{_errStr} = "Error: FTP transfer selected but module Net::FTP::RetrHandle is not installed.";
        $t->{xferErrCnt}++;
        return;
    }

    #
    # standardize the file include/exclude settings if necessary
    #
    unless ( $t->{type} eq 'restore' ) {
        $bpc->backupFileConfFix($conf, "FtpShareName");
        $t->loadInclExclRegexps("FtpShareName");
    }

    #
    # Convert the encoding type of the names if at all possible
    #
    $t->{shareNamePath} = $t->shareName2Path($t->{shareName});
    from_to($args->{shareNamePath}, "utf8", $conf->{ClientCharset})
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
    eval { $t->{ftp} = ($ARCLibOK) ? Net::FTP::AutoReconnect->new(%$args) : Net::FTP->new(%$args); };
    if ( $@ || !defined($t->{ftp}) ) {
        $t->{_errStr} = "Can't open ftp connection to $args->{Host}: $!";
        $t->{xferErrCnt}++;
        return;
    }
    $t->logWrite("Connected to $args->{Host}\n", 2);

    #
    # Log in to the ftp server and set appropriate path information.
    #
    undef $@;
    my $ret;
    eval { $ret = $t->{ftp}->login($conf->{FtpUserName}, $conf->{FtpPasswd}); };
    if ( !$ret ) {
        $t->{_errStr} = "Can't ftp login to $args->{Host} (user = $conf->{FtpUserName}), $@";
        $t->{xferErrCnt}++;
        return;
    }
    $t->logWrite("Login successful to $conf->{FtpUserName}\@$args->{Host}\n", 2);

    eval { $ret = $t->{ftp}->binary(); };
    if ( !$ret ) {
        $t->{_errStr} =
          "Can't enable ftp binary transfer mode to $args->{Host}: " . $t->{ftp}->message();
        $t->{xferErrCnt}++;
        return;
    }
    $t->logWrite("Binary command successful\n", 2);

    eval { $ret = $t->{ftp}->cwd($t->{shareNamePath}); };
    if ( !$ret ) {
        $t->{_errStr} =
          "Can't change working directory to $t->{shareNamePath}: " . $t->{ftp}->message();
        $t->{xferErrCnt}++;
        return;
    }
    $t->logWrite("Set cwd to $t->{shareNamePath}\n", 2);

    #
    # log the beginning of action based on type
    #
    if ( $t->{type} eq 'restore' ) {
        $logMsg = "ftp restore for host $t->{host} started on directory $t->{shareName}";

    } elsif ( $t->{type} eq 'full' ) {
        $logMsg = "ftp full backup for host $t->{host} started on directory $t->{shareName}";

    } elsif ( $t->{type} eq 'incr' ) {
        $logMsg = "ftp incremental backup for $t->{host} started for directory $t->{shareName}";
    }
    $logMsg .= " (client path $t->{shareNamePath})" if ( $t->{shareName} ne $t->{shareNamePath} );
    $t->logWrite($logMsg . "\n", 1);

    #
    # call the recursive function based on the type of action
    #
    if ( $t->{type} eq 'restore' ) {

        $t->restore();
        $logMsg = "Restore of $t->{host} " . ($t->{xferOK} ? "complete" : "failed");

    } else {
        $t->{compress}    = $t->{backups}[$t->{newBkupIdx}]{compress};
        $t->{newBkupNum}  = $t->{backups}[$t->{newBkupIdx}]{num};
        $t->{lastBkupNum} = $t->{backups}[$t->{lastBkupIdx}]{num};
        $t->{AttrNew} = BackupPC::XS::AttribCache::new($t->{client}, $t->{newBkupNum}, $t->{shareName}, $t->{compress});
        $t->{DeltaNew} = BackupPC::XS::DeltaRefCnt::new("$TopDir/pc/$t->{client}/$t->{newBkupNum}");
        $t->{AttrNew}->setDeltaInfo($t->{DeltaNew});

        $t->{Inode} = 1;
        for ( my $i = 0 ; $i < @{$t->{backups}} ; $i++ ) {
            $t->{Inode} = $t->{backups}[$i]{inodeLast} + 1 if ( $t->{Inode} <= $t->{backups}[$i]{inodeLast} );
        }
        $t->{Inode0} = $t->{Inode};

        if ( !$t->{inPlace} ) {
            $t->{AttrOld} =
              BackupPC::XS::AttribCache::new($t->{client}, $t->{lastBkupNum}, $t->{shareName}, $t->{compress});
            $t->{DeltaOld} = BackupPC::XS::DeltaRefCnt::new("$TopDir/pc/$t->{client}/$t->{lastBkupNum}");
            $t->{AttrOld}->setDeltaInfo($t->{DeltaOld});
        }
        $t->logWrite("ftp inPlace = $t->{inPlace}, newBkupNum = $t->{newBkupNum}, lastBkupNum = $t->{lastBkupNum}\n",
            4);
        $bpc->flushXSLibMesgs();

        $t->backup();

        $t->{AttrNew}->flush(1);
        $bpc->flushXSLibMesgs();
        if ( $t->{AttrOld} ) {
            $t->{AttrOld}->flush(1);
            $bpc->flushXSLibMesgs();
        }

        if ( $t->{logLevel} >= 6 ) {
            print("RefCnt Deltas for new #$t->{newBkupNum}\n");
            $t->{DeltaNew}->print();
            if ( $t->{DeltaOld} ) {
                print("RefCnt Deltas for old #$t->{lastBkupNum}\n");
                $t->{DeltaOld}->print();
            }
        }
        $bpc->flushXSLibMesgs();
        $t->{DeltaNew}->flush();
        $t->{DeltaOld}->flush() if ( $t->{DeltaOld} );

        if ( $t->{type} eq 'incr' ) {
            $logMsg = "Incremental backup of $t->{host} " . ($t->{xferOK} ? "complete" : "failed");
        } else {
            $logMsg = "Full backup of $t->{host} " . ($t->{xferOK} ? "complete" : "failed");
        }
        return if ( !$t->{xferOK} && defined($t->{_errStr}) );
    }

    delete $t->{_errStr};
    return $logMsg;
}

#
#
#
sub run
{
    my($t) = @_;
    my $stats = $t->{stats};

    my($tarErrs, $nFilesExist, $sizeExist, $sizeExistCom, $nFilesTotal, $sizeTotal);

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
        return ($t->{fileCnt}, $t->{byteCnt}, 0, 0);

    } else {
        return ($tarErrs, $nFilesExist, $sizeExist, $sizeExistCom, $nFilesTotal, $sizeTotal);
    }
}

sub restore
{
    my($t) = @_;

    my $bpc      = $t->{bpc};
    my $fileList = $t->{fileList};

    $t->{view} = BackupPC::View->new($bpc, $t->{bkupSrcHost}, $t->{backups});
    my $view = $t->{view};

    foreach my $file ( @$fileList ) {

        my $attr = $view->fileAttrib($t->{bkupSrcNum}, $t->{bkupSrcShare}, $file);

        $t->logWrite("restore($file)\n", 4);

        if ( $attr->{type} == BPC_FTYPE_DIR ) {

            $t->restoreDir($file, $attr);

        } elsif ( $attr->{type} == BPC_FTYPE_FILE ) {

            $t->restoreFile($file, $attr);

        } else {
            #
            # can't restore any other file types
            #
            $t->logWrite("restore($file): failed... unsupported file type $attr->{type}\n", 0);
            $t->{xferErrCnt}++;
        }
    }
    $t->{xferOK} = 1;
    return 1;
}

sub restoreDir
{
    my($t, $dirName, $dirAttr) = @_;

    my $ftp  = $t->{ftp};
    my $bpc  = $t->{bpc};
    my $conf = $t->{conf};
    my $view = $t->{view};

    my $dirList = $view->dirAttrib($t->{bkupSrcNum}, $t->{bkupSrcShare}, $dirName);

    (my $targetPath = "$t->{shareNamePath}/$dirName") =~ s{//+}{/}g;

    my($fileName, $fileAttr, $fileType);

    $t->logWrite("restoreDir($dirName) -> $targetPath\n", 4);

    #
    # Create the remote directory
    #
    undef $@;
    eval { $ftp->mkdir($targetPath, 1); };
    if ( $@ ) {
        $t->logFileAction("fail", $dirName, $dirAttr);
        return;
    } else {
        $t->logFileAction("restore", $dirName, $dirAttr);
    }

    while ( ($fileName, $fileAttr) = each %$dirList ) {

        $t->logWrite("restoreDir: entry = $dirName/$fileName\n", 4);

        if ( $fileAttr->{type} == BPC_FTYPE_DIR ) {

            $t->restoreDir("$dirName/$fileName", $fileAttr);

        } elsif ( $fileAttr->{type} == BPC_FTYPE_FILE ) {

            $t->restoreFile("$dirName/$fileName", $fileAttr);

        } else {
            #
            # can't restore any other file types
            #
            $t->logWrite("restore($fileName): failed... unsupported file type $fileAttr->{type}\n", 0);
        }
    }
}

sub restoreFile
{
    my($t, $fileName, $fileAttr) = @_;

    my $conf   = $t->{conf};
    my $ftp    = $t->{ftp};
    my $bpc    = $t->{bpc};
    my $TopDir = $bpc->TopDir();

    my $poolFile = $fileAttr->{fullPath};
    my $tempFile = "$TopDir/pc/$t->{client}/FtpRestoreTmp$$";
    my $fout;

    my $fileDest =
      ($conf->{ClientCharset} ne "")
      ? from_to("$t->{shareNamePath}//$fileName", "utf8", $conf->{ClientCharset})
      : "$t->{shareNamePath}/$fileName";

    $t->logWrite("restoreFile($fileName) -> $fileDest\n", 4);

    if ( $fileAttr->{compress} ) {
        my $f = BackupPC::XS::FileZIO::open($poolFile, 0, $fileAttr->{compress});
        if ( !defined($f) ) {
            $t->logWrite("restoreFile: Unable to open file $poolFile (during restore of $fileName)\n", 0);
            $t->{stats}{errCnt}++;
            return;
        }
        if ( !open($fout, ">", $tempFile) ) {
            $t->logWrite("restoreFile: Can't create/open temp file $tempFile (during restore of $fileName)\n", 0);
            $t->{stats}{errCnt}++;
            $f->close();
            return;
        }

        my $data;
        my $outData = "";
        while ( $f->read(\$data, 65536) > 0 ) {
            my $ret = syswrite($fout, $data);
            if ( !defined($ret) || $ret != length($data) ) {
                $t->logWrite("restoreFile: Can't write file $tempFile ($ret, $@) (during restore of $fileName)\n", 0);
                $t->{stats}{errCnt}++;
                $f->close();
                close($fout);
                return;
            }
        }
        $f->close();
        close($fout);
    } else {
        $tempFile = $poolFile;
    }

    undef $@;
    eval {
        if ( $ftp->put($tempFile, $fileDest) ) {
            $t->logFileAction("restore", $fileName, $fileAttr);
        } else {
            $@ = 1 if ( !$@ );    # force the fail message below
        }
    };
    unlink($tempFile);
    if ( $@ ) {
        $t->logWrite("restoreFile($fileName) failed ($@)\n", 4);
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
    my($t) = @_;

    my $ftp  = $t->{ftp};
    my $bpc  = $t->{bpc};
    my $conf = $t->{conf};

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

        $t->logWrite("adding top-level attrib for share $t->{shareName}\n", 4);
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
    my($t) = @_;
    my $conf = $t->{conf};

    return {
        Host         => $t->{hostIP} || $t->{host},
        Firewall     => undef,                                                      # not used
        FirewallType => undef,                                                      # not used
        BlockSize    => $conf->{FtpBlockSize} || 10240,
        Port         => $conf->{FtpPort} || 21,
        Timeout      => defined($conf->{FtpTimeout}) ? $conf->{FtpTimeout} : 120,
        Debug        => $t->{logLevel} >= 5 ? 1 : 0,
        Passive      => (defined($conf->{FtpPassive}) ? $conf->{FtpPassive} : 1),
        Hash         => undef,                                                      # do not touch
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
    my($t, $name) = @_;

    my $ftp        = $t->{ftp};
    my $bpc        = $t->{bpc};
    my $conf       = $t->{conf};
    my $nameClient = $name;
    my $char2type  = {
        'f' => BPC_FTYPE_FILE,
        'd' => BPC_FTYPE_DIR,
        'l' => BPC_FTYPE_SYMLINK,
    };
    my($dirContents, $remoteDir, $f, $linkname);

    from_to($nameClient, "utf8", $conf->{ClientCharset})
      if ( $conf->{ClientCharset} ne "" );
    $remoteDir = [];
    undef $@;
    $t->logWrite("remotels: about to list $name\n", 4);
    eval {
        $dirContents = ($nameClient =~ /^\.?$/ || $nameClient =~ /^\/*$/) ? $ftp->dir() : $ftp->dir("$nameClient/");
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
        my $dirStr = shift(@$dirContents);
        my($uid, $gid);

        next if ( $info->[0] eq "." || $info->[0] eq ".." );

        if ( $info->[1] =~ /^l (.*)/ ) {
            $linkname = $1;
        }

        #
        # Try to extract number uid/gid, if present.  If there are special files (eg, devices or pipe) that are
        # in the directoy listing, they won't be in $dirContents.  So $dirStr might not be the matching text
        # for $info.  So we peel off more elements if they don't appear to match.  This is very fragile.
        # Better solution would be to update $ftp->dir() to extract uid/gid if present.
        #
        while ( @$dirContents
            && $dirStr !~ m{\s+\Q$info->[0]\E$}
            && $dirStr !~ m{^l.*\s+\Q$info->[0] -> $linkname\E$} ) {
            $t->logWrite("no match between $dirStr and $info->[0]\n", 4);
            $dirStr = shift(@$dirContents);
        }
        my $fTypeChar = substr($info->[1], 0, 1);
        if ( $dirStr =~ m{^.{10}\s+\d+\s+(\d+)\s+(\d+)\s+(\d+).*\Q$info->[0]\E}
            && ($fTypeChar ne "f" || $info->[2] == $3) ) {
            $uid = $1;
            $gid = $2;
        }

        from_to($info->[0], $conf->{ClientCharset}, "utf8")
          if ( $conf->{ClientCharset} ne "" );
        from_to($linkname, $conf->{ClientCharset}, "utf8")
          if ( $linkname ne "" && $conf->{ClientCharset} ne "" );

        my $dir = "$name/";
        $dir = "" if ( $name eq "" );
        $dir =~ s{^/+}{};

        $f = {
            name     => "$dir$info->[0]",
            type     => defined($char2type->{$fTypeChar}) ? $char2type->{$fTypeChar} : BPC_FTYPE_UNKNOWN,
            size     => $info->[2],
            mtime    => $info->[3],
            mode     => $info->[4],
            uid      => $uid,
            gid      => $gid,
            compress => $t->{compress},
        };
        $f->{linkname} = $linkname if ( defined($linkname) );

        $t->logWrite(
            "remotels: adding name $f->{name}, type $f->{type} ($info->[1]), size $f->{size}, mode $f->{mode}, $uid/$gid\n",
            4
        );

        push(@$remoteDir, $f);
    }
    return $remoteDir;
}

#
# handleSymlink() backs up a symlink.
#
sub handleSymlink
{
    my($t, $f) = @_;
    my $a     = $t->{AttrNew}->get($f->{name});
    my $stats = $t->{stats};
    my($same, $exists, $digest, $outSize, $errs);

    #
    # Symbolic link: write the value of the link to a plain file,
    # that we pool as usual (ie: we don't create a symlink).
    # The attributes remember the original file type.
    # We also change the size to reflect the size of the link
    # contents.
    #
    $f->{size} = length($f->{linkname});
    if ( $a && $a->{type} == BPC_FTYPE_SYMLINK ) {
        #
        # Check if it is the same
        #
        my $oldLink = $t->fileReadAll($a, $f);
        if ( $oldLink eq $f->{linkname} ) {
            logFileAction("same", $f) if ( $t->{logLevel} >= 1 );
            $stats->{ExistFileCnt}++;
            $stats->{ExistFileSize}     += $f->{size};
            $stats->{ExistFileCompSize} += -s $a->{poolPath}
              if ( -f $a->{poolPath} );
            $same = 1;
        }
    }
    if ( !$same ) {
        $t->moveFileToOld($a, $f);
        $t->logWrite("PoolWrite->new(name = $f->{name}, compress = $t->{compress})\n", 5);
        my $poolWrite = BackupPC::XS::PoolWrite::new($t->{compress});
        $poolWrite->write(\$f->{linkname});
        ($exists, $digest, $outSize, $errs) = $poolWrite->close();
        $f->{digest} = $digest;
        if ( $errs ) {
            $t->logFileAction("fail", $f->{name}, $f);
            $t->{xferBadFileCnt}++;
            $stats->{errCnt} += scalar @$errs;
            return;
        }
    }

    #
    # Update attribs
    #
    $t->attribUpdate($a, $f, $same);

    #
    # Perform logging
    #
    $t->logFileAction($same ? "same" : $exists ? "pool" : "new", $f->{name}, $f);

    #
    # Cumulate the stats
    #
    $stats->{TotalFileCnt}++;
    $stats->{TotalFileSize} += $f->{size};
    if ( $exists ) {
        $stats->{ExistFileCnt}++;
        $stats->{ExistFileCompSize} += -s $a->{poolPath}
          if ( -f $a->{poolPath} );
        $stats->{ExistFileSize} += $f->{size};
    } else {
        $stats->{NewFileCnt}++;
        $stats->{NewFileCompSize} += -s $a->{poolPath}
          if ( -f $a->{poolPath} );
        $stats->{NewFileSize} += $f->{size};
    }
    $t->{byteCnt} += $f->{size};
    $t->{fileCnt}++;

    return 1;
}

#
# handleDir() backs up a directory, and initiates a backup of its
# contents.
#
sub handleDir
{
    my($t, $f) = @_;

    my $ftp     = $t->{ftp};
    my $bpc     = $t->{bpc};
    my $conf    = $t->{conf};
    my $stats   = $t->{stats};
    my $AttrNew = $t->{AttrNew};
    my $same    = 0;
    my $a       = $AttrNew->get($f->{name});

    my($exists, $digest, $outSize, $errs);
    my($poolWrite, $poolFile);
    my($localDir, $remoteDir, %expectedFiles);

    $a->{poolPath} = $bpc->MD52Path($a->{digest}, $a->{compress}) if ( length($a->{digest}) );

    my $pathNew = $AttrNew->getFullMangledPath($f->{name});

    if ( -d $pathNew ) {
        $t->logFileAction("same", $f->{name}, $f);
        $same = 1;
    } else {
        if ( -e $pathNew ) {
            $t->logWrite("handleDir: $pathNew ($f->{name}) isn't a directory... renaming and recreating\n", 3)
              if ( defined($a) );
        } else {
            $t->logWrite("handleDir: creating directory $pathNew ($f->{name})\n", 3)
              if ( defined($a) );
        }
        $t->moveFileToOld($a, $f);
        $t->logFileAction("new", $f->{name}, $f) if ( $t->{logLevel} >= 1 );
        #
        # make sure all the parent directories exist and have directory attribs
        #
        $t->pathCreate($pathNew, 1);
        my $name = $f->{name};
        $name = "/$name" if ( $name !~ m{^/} );
        while ( length($name) > 1 ) {
            if ( $name =~ m{/} ) {
                $name =~ s{(.*)/.*}{$1};
            } else {
                $name = "/";
            }
            my $a = $AttrNew->get($name);
            last if ( defined($a) && $a->{type} == BPC_FTYPE_DIR );
            $t->logWrite("handleDir: adding BPC_FTYPE_DIR attrib entry for $name\n", 3);
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

    #
    # Update attribs
    #
    $t->attribUpdate($a, $f, $same);

    $t->logWrite("handleDir: name = $f->{name}, pathNew = $pathNew\n", 4);

    $remoteDir = $t->remotels($f->{name});

    if ( ref($remoteDir) ne 'ARRAY' ) {
        $t->logWrite("handleDir failed: $remoteDir\n", 1);
        $t->logFileAction("fail", $f->{name}, $f);
        $t->{xferErrCnt}++;
        return;
    }

    my $all = $AttrNew->getAll($f->{name});
    $bpc->flushXSLibMesgs();

    #
    # take care of each file in the directory
    #
    foreach my $f ( @{$remoteDir} ) {

        my $fullName = "$t->{shareName}/$f->{name}";
        $fullName =~ s{/+}{/}g;
        next if ( !$t->checkIncludeExclude($fullName) );

        #
        # handle based on filetype
        #
        if ( $f->{type} == BPC_FTYPE_FILE ) {

            $t->handleFile($f);

        } elsif ( $f->{type} == BPC_FTYPE_DIR ) {

            $t->handleDir($f);

        } elsif ( $f->{type} == BPC_FTYPE_SYMLINK ) {

            $t->handleSymlink($f);

        } else {

            $t->logWrite("handleDir: unexpected file type $f->{type} for $f->{name})\n", 1);
            $t->{xferBadFileCnt}++;

        }

        #
        # Mark file as seen in expected files hash
        #
        $t->logWrite("dirLoop: handled $f->{name}\n", 5);
        $expectedFiles{$f->{name}}++;

    }    # end foreach (@{$remoteDir})

    #
    # If we didn't see a file, move to old.
    #
    foreach my $name ( keys(%$all) ) {
        next if ( $name eq "." || $name eq ".." );
        my $path = "$f->{name}/$name";
        $path =~ s{^/+}{};
        $t->logWrite("dirCleanup: checking $path, expected = $expectedFiles{$path}\n", 5);
        next if ( $expectedFiles{$path} );
        $t->moveFileToOld($AttrNew->get($path), {name => $path});
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
    my($t, $f) = @_;

    my $bpc   = $t->{bpc};
    my $ftp   = $t->{ftp};
    my $view  = $t->{view};
    my $stats = $t->{stats};

    my($poolFile, $poolWrite, $data,    $localSize);
    my($exists,   $digest,    $outSize, $errs);
    my($oldAttrib);
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
            && $f->{type} == $a->{type}
            && $f->{mtime} == $a->{mtime}
            && $f->{size} == $a->{size}
            && $f->{uid} == $a->{uid}
            && $f->{gid} == $a->{gid} ) {
            $t->logWrite("handleFile: $f->{name} has same attribs\n", 5);
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
    eval { tie(*FTP, 'Net::FTP::RetrHandle', $ftp, "$f->{name}"); };
    if ( !*FTP || $@ ) {
        $t->logFileAction("fail", $f->{name}, $f);
        $t->{xferBadFileCnt}++;
        $stats->{errCnt}++;
        return;
    }

    $t->logWrite("PoolWrite->new(name = $f->{name}, compress = $t->{compress})\n", 5);
    $poolWrite = BackupPC::XS::PoolWrite::new($t->{compress});
    $localSize = 0;

    undef $@;
    eval {
        while ( <FTP> ) {
            $localSize += length($_);
            $poolWrite->write(\$_);
        }
    };
    ($exists, $digest, $outSize, $errs) = $poolWrite->close();
    $f->{digest} = $digest;

    if ( $a && $a->{digest} eq $digest ) {
        $same = 1 if ( $a->{nlinks} == 0 );
    }

    if ( !$same ) {
        $t->moveFileToOld($a, $f);
    }

    if ( !*FTP || $@ || $errs ) {
        $t->logFileAction("fail", $f->{name}, $f);
        $t->{xferBadFileCnt}++;
        $stats->{errCnt} += ref($errs) eq 'ARRAY' ? scalar(@$errs) : 1;
        return;
    }

    #
    # this should never happen
    #
    if ( $localSize != $f->{size} ) {
        $t->logFileAction("fail", $f->{name}, $f);
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
    $t->logFileAction($same ? "same" : $exists ? "pool" : "new", $f->{name}, $f);

    #
    # Cumulate the stats
    #
    $stats->{TotalFileCnt}++;
    $stats->{TotalFileSize} += $f->{size};
    if ( $exists ) {
        $stats->{ExistFileCnt}++;
        $stats->{ExistFileCompSize} += $outSize;
        $stats->{ExistFileSize}     += $f->{size};
    } else {
        $stats->{NewFileCnt}++;
        $stats->{NewFileCompSize} += $outSize;
        $stats->{NewFileSize}     += $f->{size};
    }
    $t->{byteCnt} += $localSize;
    $t->{fileCnt}++;
}

#
# Generate a log file message for a completed file.  Taken from
# BackupPC_tarExtract. $f should be an attrib object.
#
sub logFileAction
{
    my($t, $action, $name, $attrib) = @_;

    my $owner = "$attrib->{uid}/$attrib->{gid}";
    my $type  = BackupPC::XS::Attrib::fileType2Text($attrib->{type});

    $type = $1 if ( $type =~ /(.)/ );
    $type = "" if ( $type eq "f" );

    $name  = "."   if ( $name eq "" );
    $owner = "-/-" if ( $owner eq "/" );

    $t->{bpc}->flushXSLibMesgs();

    my $fileAction = sprintf(
        "  %-6s %1s%4o %9s %11.0f %s\n",
        $action, $type,           $attrib->{mode} & 07777,
        $owner,  $attrib->{size}, $attrib->{name}
    );

    if ( ($t->{stats}{TotalFileCnt} % 20) == 0 && !$t->{noProgressPrint} ) {
        printf("__bpc_progress_fileCnt__ %d\n", $t->{stats}{TotalFileCnt});
    }

    return $t->logWrite($fileAction, 1);
}

#
# Move $a to old; the new file $f will replace $a
#
sub moveFileToOld
{
    my($t, $a, $f) = @_;
    my $AttrNew  = $t->{AttrNew};
    my $AttrOld  = $t->{AttrOld};
    my $DeltaNew = $t->{DeltaNew};
    my $DeltaOld = $t->{DeltaOld};
    my $bpc      = $t->{bpc};

    if ( !$a || keys(%$a) == 0 ) {
        #
        # A new file will be created, so add delete attribute to old
        #
        if ( $AttrOld ) {
            $AttrOld->set($f->{name}, {type => BPC_FTYPE_DELETED});
            $t->logWrite("moveFileToOld: added $f->{name} as BPC_FTYPE_DELETED in old\n", 5);
        }
        return;
    }
    $t->logWrite("moveFileToOld: $a->{name}, $f->{name}, links = $a->{nlinks}, type = $a->{type}\n", 5);
    if ( $a->{type} != BPC_FTYPE_DIR ) {
        if ( $a->{nlinks} > 0 ) {
            if ( $AttrOld ) {
                if ( !$AttrOld->getInode($a->{inode}) ) {
                    #
                    # copy inode to old if it isn't already there
                    #
                    $AttrOld->setInode($a->{inode}, $a);
                    $DeltaOld->update($a->{compress}, $a->{digest}, 1);
                }
                #
                # copy to old - no need for refeence count update since
                # inode is already there
                #
                $AttrOld->set($f->{name}, $a, 1) if ( !$AttrOld->get($f->{name}) );
            }
            $a->{nlinks}--;
            if ( $a->{nlinks} <= 0 ) {
                $AttrNew->deleteInode($a->{inode});
                $DeltaNew->update($a->{compress}, $a->{digest}, -1);
            } else {
                $AttrNew->setInode($a->{inode}, $a);
            }
        } else {
            $DeltaNew->update($a->{compress}, $a->{digest}, -1);
            if ( $AttrOld && !$AttrOld->get($f->{name}) && $AttrOld->set($f->{name}, $a, 1) ) {
                $DeltaOld->update($a->{compress}, $a->{digest}, 1);
            }
        }
        $AttrNew->delete($f->{name});
    } else {
        if ( !$AttrOld || $AttrOld->get($f->{name}) ) {
            #
            # Delete the directory tree, including updating reference counts
            #
            my $pathNew = $AttrNew->getFullMangledPath($f->{name});
            $t->logWrite("moveFileToOld(..., $f->{name}): deleting $pathNew\n", 3);
            BackupPC::DirOps::RmTreeQuiet($bpc, $pathNew, $a->{compress}, $DeltaNew, $AttrNew);
        } else {
            #
            # For a directory we need to move it to old, and copy
            # any inodes that are referenced below this directory.
            # Also update the reference counts for the moved files.
            #
            my $pathNew = $AttrNew->getFullMangledPath($f->{name});
            my $pathOld = $AttrOld->getFullMangledPath($f->{name});
            $t->logWrite("moveFileToOld(..., $f->{name}): renaming $pathNew to $pathOld\n", 5);
            $t->pathCreate($pathOld);
            $AttrNew->flush(0, $f->{name});
            if ( !rename($pathNew, $pathOld) ) {
                $t->logWrite(sprintf(
                    "moveFileToOld(..., %s: can't rename %s to %s ($!, %d, %d, %d)\n",
                    $f->{name}, $pathNew, $pathOld, -e $pathNew, -e $pathOld, -d $pathOld
                ));
                $t->{xferErrCnt}++;
            } else {
                BackupPC::XS::DirOps::refCountAll($pathOld, $a->{compress}, -1, $DeltaNew);
                BackupPC::XS::DirOps::refCountAll($pathOld, $a->{compress}, 1,  $DeltaOld);
                $t->copyInodes($f->{name});
                $AttrOld->set($f->{name}, $a, 1);
            }
        }
        $AttrNew->delete($f->{name});
    }
}

sub copyInodes
{
    my($t, $dirName) = @_;
    my $AttrNew  = $t->{AttrNew};
    my $AttrOld  = $t->{AttrOld};
    my $DeltaNew = $t->{DeltaNew};
    my $DeltaOld = $t->{DeltaOld};
    my $bpc      = $t->{bpc};

    return if ( !defined($AttrOld) );

    my $dirPath = $AttrNew->getFullMangledPath($dirName);

    $t->logWrite("copyInodes: dirName = $dirName, dirPath = $dirPath\n", 4);

    my $attrAll = $AttrNew->getAll($dirName);
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
        next if ( $fileUM eq "." || $fileUM eq ".." );
        my $a = $attrAll->{$fileUM};
        if ( $a->{type} == BPC_FTYPE_DIR ) {
            #
            # recurse into this directory
            #
            $t->copyInodes("$dirName/$fileUM");
            next;
        }
        $t->logWrite("copyInodes($dirName): $fileUM has inode=$a->{inode}, links = $a->{nlinks}\n", 6);
        next if ( $a->{nlinks} == 0 );
        #
        # Copy the inode if it doesn't exist in old and increment the
        # digest reference count.
        my $aInode = $AttrNew->getInode($a->{inode});
        if ( !defined($AttrOld->getInode($a->{inode})) ) {
            $t->logWrite("copyInodes($dirName): $fileUM moving inode $a->{inode} to old\n", 5);
            $AttrOld->setInode($a->{inode}, $aInode);
            $DeltaOld->update($aInode->{compress}, $aInode->{digest}, 1);
        }

        #
        # Also decrement the inode reference count in new.
        #
        $aInode->{nlinks}--;
        if ( $aInode->{nlinks} == 0 ) {
            $AttrNew->deleteInode($a->{inode});
            $t->logWrite("copyInodes($dirName): $fileUM deleting inode $a->{inode} in new\n", 5);
            $DeltaNew->update($aInode->{compress}, $aInode->{digest}, -1);
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
    my $DeltaNew    = $t->{DeltaNew};
    my $DeltaOld    = $t->{DeltaOld};
    my $bpc         = $t->{bpc};
    my $attribSet   = 1;
    my $newCompress = $t->{compress};

    $newCompress = $a->{compress} if ( $a && defined($a->{compress}) );

    $t->logWrite(
        sprintf(
            "File %s: old digest %s, new digest %s\n",
            $f->{name},
            unpack("H*", $a->{digest}),
            unpack("H*", $f->{digest})
        ),
        5
    ) if ( $a );

    if ( $same && $a ) {
        if (   $a->{type} == $f->{type}
            && $a->{mode} == S_IMODE($f->{mode})
            && $a->{uid} == $f->{uid}
            && $a->{gid} == $f->{gid}
            && $a->{size} == $f->{size}
            && $a->{mtime} == $f->{mtime}
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
                    $DeltaOld->update($newCompress, $f->{digest}, 1);
                }
            }
            $f->{inode}  = $a->{inode};
            $f->{nlinks} = $a->{nlinks};
        }
    } else {
        #
        # file is new or changed; update ref counts
        #
        $DeltaNew->update($newCompress, $f->{digest}, 1)
          if ( $f->{digest} ne "" );
    }

    if ( $attribSet ) {
        my $newInode = $f->{inode};
        $newInode = $t->{Inode}++ if ( !defined($newInode) );
        my $nlinks = 0;
        $nlinks = $f->{nlinks} if ( defined($f->{nlinks}) );
        $AttrNew->set(
            $f->{name},
            {
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
            }
        );
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
    $t->logWrite("pathCreate: fullPath = $fullPath\n", 6);
    $fullPath =~ s{/[^/]*$}{} if ( !$noStrip );
    return 0                  if ( -d $fullPath );
    unlink($fullPath)         if ( -e $fullPath );
    eval { mkpath($fullPath, 0, 0777) };
    if ( $@ ) {
        $t->logWrite("Can't create $fullPath\n", 1);
        $t->{xferErrCnt}++;
        return -1;
    }
    return 0;
}

sub fileReadAll
{
    my($t, $a, $f) = @_;

    return "" if ( $a->{size} == 0 );
    my $f = BackupPC::XS::FileZIO::open($a->{poolPath}, 0, $a->{compress});
    if ( !defined($f) ) {
        print("fileReadAll: Unable to open file $a->{poolPath} (for $f->{name})\n");
        $t->{stats}{errCnt}++;
        return;
    }
    my $data;
    my $outData = "";
    while ( $f->read(\$data, 65536) > 0 ) {
        $outData .= $data;
    }
    $f->close;
    return $outData;
}

1;
