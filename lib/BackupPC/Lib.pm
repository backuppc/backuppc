#============================================================= -*-perl-*-
#
# BackupPC::Lib package
#
# DESCRIPTION
#
#   This library defines a BackupPC::Lib class and a variety of utility
#   functions used by BackupPC.
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
# Version 2.1.0_CVS, released 8 Feb 2004.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

package BackupPC::Lib;

use strict;

use vars qw(%Conf %Lang);
use Fcntl qw/:flock/;
use Carp;
use DirHandle ();
use File::Path;
use File::Compare;
use Socket;
use Cwd;
use Digest::MD5;

sub new
{
    my $class = shift;
    my($topDir, $installDir, $noUserCheck) = @_;

    my $bpc = bless {
        TopDir  => $topDir || '/data/BackupPC',
        BinDir  => $installDir || '/usr/local/BackupPC',
        LibDir  => $installDir || '/usr/local/BackupPC',
        Version => '2.1.0_CVS',
        BackupFields => [qw(
                    num type startTime endTime
                    nFiles size nFilesExist sizeExist nFilesNew sizeNew
                    xferErrs xferBadFile xferBadShare tarErrs
                    compress sizeExistComp sizeNewComp
                    noFill fillFromNum mangle xferMethod level
                )],
        RestoreFields => [qw(
                    num startTime endTime result errorMsg nFiles size
                    tarCreateErrs xferErrs
                )],
        ArchiveFields => [qw(
                    num startTime endTime result errorMsg
                )],
    }, $class;
    $bpc->{BinDir} .= "/bin";
    $bpc->{LibDir} .= "/lib";
    #
    # Clean up %ENV and setup other variables.
    #
    delete @ENV{qw(IFS CDPATH ENV BASH_ENV)};
    $bpc->{PoolDir}  = "$bpc->{TopDir}/pool";
    $bpc->{CPoolDir} = "$bpc->{TopDir}/cpool";
    if ( defined(my $error = $bpc->ConfigRead()) ) {
        print(STDERR $error, "\n");
        return;
    }
    #
    # Verify we are running as the correct user
    #
    if ( !$noUserCheck
	    && $bpc->{Conf}{BackupPCUserVerify}
	    && $> != (my $uid = (getpwnam($bpc->{Conf}{BackupPCUser}))[2]) ) {
	print("Wrong user: my userid is $>, instead of $uid"
	    . " ($bpc->{Conf}{BackupPCUser})\n");
	return;
    }
    return $bpc;
}

sub TopDir
{
    my($bpc) = @_;
    return $bpc->{TopDir};
}

sub BinDir
{
    my($bpc) = @_;
    return $bpc->{BinDir};
}

sub Version
{
    my($bpc) = @_;
    return $bpc->{Version};
}

sub Conf
{
    my($bpc) = @_;
    return %{$bpc->{Conf}};
}

sub Lang
{
    my($bpc) = @_;
    return $bpc->{Lang};
}

sub adminJob
{
    return " admin ";
}

sub trashJob
{
    return " trashClean ";
}

sub ConfValue
{
    my($bpc, $param) = @_;

    return $bpc->{Conf}{$param};
}

sub verbose
{
    my($bpc, $param) = @_;

    $bpc->{verbose} = $param if ( defined($param) );
    return $bpc->{verbose};
}

#
# Generate an ISO 8601 format timeStamp (but without the "T").
# See http://www.w3.org/TR/NOTE-datetime and
# http://www.cl.cam.ac.uk/~mgk25/iso-time.html
#
sub timeStamp
{
    my($bpc, $t, $noPad) = @_;
    my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)
              = localtime($t || time);
    return sprintf("%04d-%02d-%02d %02d:%02d:%02d",
		    $year + 1900, $mon + 1, $mday, $hour, $min, $sec)
	     . ($noPad ? "" : " ");
}

sub BackupInfoRead
{
    my($bpc, $host) = @_;
    local(*BK_INFO, *LOCK);
    my(@Backups);

    flock(LOCK, LOCK_EX) if open(LOCK, "$bpc->{TopDir}/pc/$host/LOCK");
    if ( open(BK_INFO, "$bpc->{TopDir}/pc/$host/backups") ) {
	binmode(BK_INFO);
        while ( <BK_INFO> ) {
            s/[\n\r]+//;
            next if ( !/^(\d+\t(incr|full|partial)[\d\t]*$)/ );
            $_ = $1;
            @{$Backups[@Backups]}{@{$bpc->{BackupFields}}} = split(/\t/);
        }
        close(BK_INFO);
    }
    close(LOCK);
    return @Backups;
}

sub BackupInfoWrite
{
    my($bpc, $host, @Backups) = @_;
    local(*BK_INFO, *LOCK);
    my($i);

    flock(LOCK, LOCK_EX) if open(LOCK, "$bpc->{TopDir}/pc/$host/LOCK");
    unlink("$bpc->{TopDir}/pc/$host/backups.old")
                if ( -f "$bpc->{TopDir}/pc/$host/backups.old" );
    rename("$bpc->{TopDir}/pc/$host/backups",
           "$bpc->{TopDir}/pc/$host/backups.old")
                if ( -f "$bpc->{TopDir}/pc/$host/backups" );
    if ( open(BK_INFO, ">$bpc->{TopDir}/pc/$host/backups") ) {
	binmode(BK_INFO);
        for ( $i = 0 ; $i < @Backups ; $i++ ) {
            my %b = %{$Backups[$i]};
            printf(BK_INFO "%s\n", join("\t", @b{@{$bpc->{BackupFields}}}));
        }
        close(BK_INFO);
    }
    close(LOCK);
}

sub RestoreInfoRead
{
    my($bpc, $host) = @_;
    local(*RESTORE_INFO, *LOCK);
    my(@Restores);

    flock(LOCK, LOCK_EX) if open(LOCK, "$bpc->{TopDir}/pc/$host/LOCK");
    if ( open(RESTORE_INFO, "$bpc->{TopDir}/pc/$host/restores") ) {
	binmode(RESTORE_INFO);
        while ( <RESTORE_INFO> ) {
            s/[\n\r]+//;
            next if ( !/^(\d+.*)/ );
            $_ = $1;
            @{$Restores[@Restores]}{@{$bpc->{RestoreFields}}} = split(/\t/);
        }
        close(RESTORE_INFO);
    }
    close(LOCK);
    return @Restores;
}

sub RestoreInfoWrite
{
    my($bpc, $host, @Restores) = @_;
    local(*RESTORE_INFO, *LOCK);
    my($i);

    flock(LOCK, LOCK_EX) if open(LOCK, "$bpc->{TopDir}/pc/$host/LOCK");
    unlink("$bpc->{TopDir}/pc/$host/restores.old")
                if ( -f "$bpc->{TopDir}/pc/$host/restores.old" );
    rename("$bpc->{TopDir}/pc/$host/restores",
           "$bpc->{TopDir}/pc/$host/restores.old")
                if ( -f "$bpc->{TopDir}/pc/$host/restores" );
    if ( open(RESTORE_INFO, ">$bpc->{TopDir}/pc/$host/restores") ) {
	binmode(RESTORE_INFO);
        for ( $i = 0 ; $i < @Restores ; $i++ ) {
            my %b = %{$Restores[$i]};
            printf(RESTORE_INFO "%s\n",
                        join("\t", @b{@{$bpc->{RestoreFields}}}));
        }
        close(RESTORE_INFO);
    }
    close(LOCK);
}

sub ArchiveInfoRead
{
    my($bpc, $host) = @_;
    local(*ARCHIVE_INFO, *LOCK);
    my(@Archives);

    flock(LOCK, LOCK_EX) if open(LOCK, "$bpc->{TopDir}/pc/$host/LOCK");
    if ( open(ARCHIVE_INFO, "$bpc->{TopDir}/pc/$host/archives") ) {
        binmode(ARCHIVE_INFO);
        while ( <ARCHIVE_INFO> ) {
            s/[\n\r]+//;
            next if ( !/^(\d+.*)/ );
            $_ = $1;
            @{$Archives[@Archives]}{@{$bpc->{ArchiveFields}}} = split(/\t/);
        }
        close(ARCHIVE_INFO);
    }
    close(LOCK);
    return @Archives;
}

sub ArchiveInfoWrite
{
    my($bpc, $host, @Archives) = @_;
    local(*ARCHIVE_INFO, *LOCK);
    my($i);

    flock(LOCK, LOCK_EX) if open(LOCK, "$bpc->{TopDir}/pc/$host/LOCK");
    unlink("$bpc->{TopDir}/pc/$host/archives.old")
                if ( -f "$bpc->{TopDir}/pc/$host/archives.old" );
    rename("$bpc->{TopDir}/pc/$host/archives",
           "$bpc->{TopDir}/pc/$host/archives.old")
                if ( -f "$bpc->{TopDir}/pc/$host/archives" );
    if ( open(ARCHIVE_INFO, ">$bpc->{TopDir}/pc/$host/archives") ) {
        binmode(ARCHIVE_INFO);
        for ( $i = 0 ; $i < @Archives ; $i++ ) {
            my %b = %{$Archives[$i]};
            printf(ARCHIVE_INFO "%s\n",
                        join("\t", @b{@{$bpc->{ArchiveFields}}}));
        }
        close(ARCHIVE_INFO);
    }
    close(LOCK);
}

sub ConfigRead
{
    my($bpc, $host) = @_;
    my($ret, $mesg, $config, @configs);

    $bpc->{Conf} = ();
    push(@configs, "$bpc->{TopDir}/conf/config.pl");
    push(@configs, "$bpc->{TopDir}/conf/$host.pl")
            if ( $host ne "config" && -f "$bpc->{TopDir}/conf/$host.pl" );
    push(@configs, "$bpc->{TopDir}/pc/$host/config.pl")
            if ( defined($host) && -f "$bpc->{TopDir}/pc/$host/config.pl" );
    foreach $config ( @configs ) {
        %Conf = ();
        if ( !defined($ret = do $config) && ($! || $@) ) {
            $mesg = "Couldn't open $config: $!" if ( $! );
            $mesg = "Couldn't execute $config: $@" if ( $@ );
            $mesg =~ s/[\n\r]+//;
            return $mesg;
        }
        %{$bpc->{Conf}} = ( %{$bpc->{Conf} || {}}, %Conf );
    }
    return if ( !defined($bpc->{Conf}{Language}) );
    if ( defined($bpc->{Conf}{PerlModuleLoad}) ) {
        #
        # Load any user-specified perl modules.  This is for
        # optional user-defined extensions.
        #
        $bpc->{Conf}{PerlModuleLoad} = [$bpc->{Conf}{PerlModuleLoad}]
                    if ( ref($bpc->{Conf}{PerlModuleLoad}) ne "ARRAY" );
        foreach my $module ( @{$bpc->{Conf}{PerlModuleLoad}} ) {
            eval("use $module;");
        }
    }
    my $langFile = "$bpc->{LibDir}/BackupPC/Lang/$bpc->{Conf}{Language}.pm";
    if ( !defined($ret = do $langFile) && ($! || $@) ) {
	$mesg = "Couldn't open language file $langFile: $!" if ( $! );
	$mesg = "Couldn't execute language file $langFile: $@" if ( $@ );
	$mesg =~ s/[\n\r]+//;
	return $mesg;
    }
    $bpc->{Lang} = \%Lang;
    return;
}

#
# Return the mtime of the config file
#
sub ConfigMTime
{
    my($bpc) = @_;
    return (stat("$bpc->{TopDir}/conf/config.pl"))[9];
}

#
# Returns information from the host file in $bpc->{TopDir}/conf/hosts.
# With no argument a ref to a hash of hosts is returned.  Each
# hash contains fields as specified in the hosts file.  With an
# argument a ref to a single hash is returned with information
# for just that host.
#
sub HostInfoRead
{
    my($bpc, $host) = @_;
    my(%hosts, @hdr, @fld);
    local(*HOST_INFO);

    if ( !open(HOST_INFO, "$bpc->{TopDir}/conf/hosts") ) {
        print(STDERR $bpc->timeStamp,
                     "Can't open $bpc->{TopDir}/conf/hosts\n");
        return {};
    }
    binmode(HOST_INFO);
    while ( <HOST_INFO> ) {
        s/[\n\r]+//;
        s/#.*//;
        s/\s+$//;
        next if ( /^\s*$/ || !/^([\w\.\\-]+\s+.*)/ );
        #
        # Split on white space, except if preceded by \
        # using zero-width negative look-behind assertion
	# (always wanted to use one of those).
        #
        @fld = split(/(?<!\\)\s+/, $1);
        #
        # Remove any \
        #
        foreach ( @fld ) {
            s{\\(\s)}{$1}g;
        }
        if ( @hdr ) {
            if ( defined($host) ) {
                next if ( lc($fld[0]) ne $host );
                @{$hosts{lc($fld[0])}}{@hdr} = @fld;
		close(HOST_INFO);
                return \%hosts;
            } else {
                @{$hosts{lc($fld[0])}}{@hdr} = @fld;
            }
        } else {
            @hdr = @fld;
        }
    }
    close(HOST_INFO);
    return \%hosts;
}

#
# Return the mtime of the hosts file
#
sub HostsMTime
{
    my($bpc) = @_;
    return (stat("$bpc->{TopDir}/conf/hosts"))[9];
}

#
# Stripped down from File::Path.  In particular we don't print
# many warnings and we try three times to delete each directory
# and file -- for some reason the original File::Path rmtree
# didn't always completely remove a directory tree on the NetApp.
#
# Warning: this routine changes the cwd.
#
sub RmTreeQuiet
{
    my($bpc, $pwd, $roots) = @_;
    my(@files, $root);

    if ( defined($roots) && length($roots) ) {
      $roots = [$roots] unless ref $roots;
    } else {
      print "RmTreeQuiet: No root path(s) specified\n";
    }
    chdir($pwd);
    foreach $root (@{$roots}) {
	$root = $1 if ( $root =~ m{(.*?)/*$} );
	#
	# Try first to simply unlink the file: this avoids an
	# extra stat for every file.  If it fails (which it
	# will for directories), check if it is a directory and
	# then recurse.
	#
	if ( !unlink($root) ) {
            if ( -d $root ) {
                my $d = DirHandle->new($root)
                  or print "Can't read $pwd/$root: $!";
                @files = $d->read;
                $d->close;
                @files = grep $_!~/^\.{1,2}$/, @files;
                $bpc->RmTreeQuiet("$pwd/$root", \@files);
                chdir($pwd);
                rmdir($root) || rmdir($root);
            } else {
                unlink($root) || unlink($root);
            }
        }
    }
}

#
# Move a directory or file away for later deletion
#
sub RmTreeDefer
{
    my($bpc, $trashDir, $file) = @_;
    my($i, $f);

    return if ( !-e $file );
    mkpath($trashDir, 0, 0777) if ( !-d $trashDir );
    for ( $i = 0 ; $i < 1000 ; $i++ ) {
        $f = sprintf("%s/%d_%d_%d", $trashDir, time, $$, $i);
        next if ( -e $f );
        return if ( rename($file, $f) );
    }
    # shouldn't get here, but might if you tried to call this
    # across file systems.... just remove the tree right now.
    if ( $file =~ /(.*)\/([^\/]*)/ ) {
        my($d) = $1;
        my($f) = $2;
        my($cwd) = Cwd::fastcwd();
        $cwd = $1 if ( $cwd =~ /(.*)/ );
        $bpc->RmTreeQuiet($d, $f);
        chdir($cwd) if ( $cwd );
    }
}

#
# Empty the trash directory.  Returns 0 if it did nothing, 1 if it
# did something, -1 if it failed to remove all the files.
#
sub RmTreeTrashEmpty
{
    my($bpc, $trashDir) = @_;
    my(@files);
    my($cwd) = Cwd::fastcwd();

    $cwd = $1 if ( $cwd =~ /(.*)/ );
    return if ( !-d $trashDir );
    my $d = DirHandle->new($trashDir) or carp "Can't read $trashDir: $!";
    @files = $d->read;
    $d->close;
    @files = grep $_!~/^\.{1,2}$/, @files;
    return 0 if ( !@files );
    $bpc->RmTreeQuiet($trashDir, \@files);
    foreach my $f ( @files ) {
	return -1 if ( -e $f );
    }
    chdir($cwd) if ( $cwd );
    return 1;
}

#
# Open a connection to the server.  Returns an error string on failure.
# Returns undef on success.
#
sub ServerConnect
{
    my($bpc, $host, $port, $justConnect) = @_;
    local(*FH);

    return if ( defined($bpc->{ServerFD}) );
    #
    # First try the unix-domain socket
    #
    my $sockFile = "$bpc->{TopDir}/log/BackupPC.sock";
    socket(*FH, PF_UNIX, SOCK_STREAM, 0)     || return "unix socket: $!";
    if ( !connect(*FH, sockaddr_un($sockFile)) ) {
        my $err = "unix connect: $!";
        close(*FH);
        if ( $port > 0 ) {
            my $proto = getprotobyname('tcp');
            my $iaddr = inet_aton($host)     || return "unknown host $host";
            my $paddr = sockaddr_in($port, $iaddr);

            socket(*FH, PF_INET, SOCK_STREAM, $proto)
                                             || return "inet socket: $!";
            connect(*FH, $paddr)             || return "inet connect: $!";
        } else {
            return $err;
        }
    }
    my($oldFH) = select(*FH); $| = 1; select($oldFH);
    $bpc->{ServerFD} = *FH;
    return if ( $justConnect );
    #
    # Read the seed that we need for our MD5 message digest.  See
    # ServerMesg below.
    #
    sysread($bpc->{ServerFD}, $bpc->{ServerSeed}, 1024);
    $bpc->{ServerMesgCnt} = 0;
    return;
}

#
# Check that the server connection is still ok
#
sub ServerOK
{
    my($bpc) = @_;

    return 0 if ( !defined($bpc->{ServerFD}) );
    vec(my $FDread, fileno($bpc->{ServerFD}), 1) = 1;
    my $ein = $FDread;
    return 0 if ( select(my $rout = $FDread, undef, $ein, 0.0) < 0 );
    return 1 if ( !vec($rout, fileno($bpc->{ServerFD}), 1) );
}

#
# Disconnect from the server
#
sub ServerDisconnect
{
    my($bpc) = @_;
    return if ( !defined($bpc->{ServerFD}) );
    close($bpc->{ServerFD});
    delete($bpc->{ServerFD});
}

#
# Sends a message to the server and returns with the reply.
#
# To avoid possible attacks via the TCP socket interface, every client
# message is protected by an MD5 digest. The MD5 digest includes four
# items:
#   - a seed that is sent to us when we first connect
#   - a sequence number that increments for each message
#   - a shared secret that is stored in $Conf{ServerMesgSecret}
#   - the message itself.
# The message is sent in plain text preceded by the MD5 digest. A
# snooper can see the plain-text seed sent by BackupPC and plain-text
# message, but cannot construct a valid MD5 digest since the secret in
# $Conf{ServerMesgSecret} is unknown. A replay attack is not possible
# since the seed changes on a per-connection and per-message basis.
#
sub ServerMesg
{
    my($bpc, $mesg) = @_;
    return if ( !defined(my $fh = $bpc->{ServerFD}) );
    my $md5 = Digest::MD5->new;
    $md5->add($bpc->{ServerSeed} . $bpc->{ServerMesgCnt}
            . $bpc->{Conf}{ServerMesgSecret} . $mesg);
    print($fh $md5->b64digest . " $mesg\n");
    $bpc->{ServerMesgCnt}++;
    return <$fh>;
}

#
# Do initialization for child processes
#
sub ChildInit
{
    my($bpc) = @_;
    close(STDERR);
    open(STDERR, ">&STDOUT");
    select(STDERR); $| = 1;
    select(STDOUT); $| = 1;
    $ENV{PATH} = $bpc->{Conf}{MyPath};
}

#
# Compute the MD5 digest of a file.  For efficiency we don't
# use the whole file for big files:
#   - for files <= 256K we use the file size and the whole file.
#   - for files <= 1M we use the file size, the first 128K and
#     the last 128K.
#   - for files > 1M, we use the file size, the first 128K and
#     the 8th 128K (ie: the 128K up to 1MB).
# See the documentation for a discussion of the tradeoffs in
# how much data we use and how many collisions we get.
#
# Returns the MD5 digest (a hex string) and the file size.
#
sub File2MD5
{
    my($bpc, $md5, $name) = @_;
    my($data, $fileSize);
    local(*N);

    $fileSize = (stat($name))[7];
    return ("", -1) if ( !-f _ );
    $name = $1 if ( $name =~ /(.*)/ );
    return ("", 0) if ( $fileSize == 0 );
    return ("", -1) if ( !open(N, $name) );
    binmode(N);
    $md5->reset();
    $md5->add($fileSize);
    if ( $fileSize > 262144 ) {
        #
        # read the first and last 131072 bytes of the file,
        # up to 1MB.
        #
        my $seekPosn = ($fileSize > 1048576 ? 1048576 : $fileSize) - 131072;
        $md5->add($data) if ( sysread(N, $data, 131072) );
        $md5->add($data) if ( sysseek(N, $seekPosn, 0)
                                && sysread(N, $data, 131072) );
    } else {
        #
        # read the whole file
        #
        $md5->add($data) if ( sysread(N, $data, $fileSize) );
    }
    close(N);
    return ($md5->hexdigest, $fileSize);
}

#
# Compute the MD5 digest of a buffer (string).  For efficiency we don't
# use the whole string for big strings:
#   - for files <= 256K we use the file size and the whole file.
#   - for files <= 1M we use the file size, the first 128K and
#     the last 128K.
#   - for files > 1M, we use the file size, the first 128K and
#     the 8th 128K (ie: the 128K up to 1MB).
# See the documentation for a discussion of the tradeoffs in
# how much data we use and how many collisions we get.
#
# Returns the MD5 digest (a hex string).
#
sub Buffer2MD5
{
    my($bpc, $md5, $fileSize, $dataRef) = @_;

    $md5->reset();
    $md5->add($fileSize);
    if ( $fileSize > 262144 ) {
        #
        # add the first and last 131072 bytes of the string,
        # up to 1MB.
        #
        my $seekPosn = ($fileSize > 1048576 ? 1048576 : $fileSize) - 131072;
        $md5->add(substr($$dataRef, 0, 131072));
        $md5->add(substr($$dataRef, $seekPosn, 131072));
    } else {
        #
        # add the whole string
        #
        $md5->add($$dataRef);
    }
    return $md5->hexdigest;
}

#
# Given an MD5 digest $d and a compress flag, return the full
# path in the pool.
#
sub MD52Path
{
    my($bpc, $d, $compress, $poolDir) = @_;

    return if ( $d !~ m{(.)(.)(.)(.*)} );
    $poolDir = ($compress ? $bpc->{CPoolDir} : $bpc->{PoolDir})
		    if ( !defined($poolDir) );
    return "$poolDir/$1/$2/$3/$1$2$3$4";
}

#
# For each file, check if the file exists in $bpc->{TopDir}/pool.
# If so, remove the file and make a hardlink to the file in
# the pool.  Otherwise, if the newFile flag is set, make a
# hardlink in the pool to the new file.
#
# Returns 0 if a link should be made to a new file (ie: when the file
#    is a new file but the newFile flag is 0).
# Returns 1 if a link to an existing file is made,
# Returns 2 if a link to a new file is made (only if $newFile is set)
# Returns negative on error.
#
sub MakeFileLink
{
    my($bpc, $name, $d, $newFile, $compress) = @_;
    my($i, $rawFile);

    return -1 if ( !-f $name );
    for ( $i = -1 ; ; $i++ ) {
        return -2 if ( !defined($rawFile = $bpc->MD52Path($d, $compress)) );
        $rawFile .= "_$i" if ( $i >= 0 );
        if ( -f $rawFile ) {
            if ( (stat(_))[3] < $bpc->{Conf}{HardLinkMax}
                    && !compare($name, $rawFile) ) {
                unlink($name);
                return -3 if ( !link($rawFile, $name) );
                return 1;
            }
        } elsif ( $newFile && -f $name && (stat($name))[3] == 1 ) {
            my($newDir);
            ($newDir = $rawFile) =~ s{(.*)/.*}{$1};
            mkpath($newDir, 0, 0777) if ( !-d $newDir );
            return -4 if ( !link($name, $rawFile) );
            return 2;
        } else {
            return 0;
        }
    }
}

sub CheckHostAlive
{
    my($bpc, $host) = @_;
    my($s, $pingCmd, $ret);

    #
    # Return success if the ping cmd is undefined or empty.
    #
    if ( $bpc->{Conf}{PingCmd} eq "" ) {
	print(STDERR "CheckHostAlive: return ok because \$Conf{PingCmd}"
	           . " is empty\n") if ( $bpc->{verbose} );
	return 0;
    }

    my $args = {
	pingPath => $bpc->{Conf}{PingPath},
	host     => $host,
    };
    $pingCmd = $bpc->cmdVarSubstitute($bpc->{Conf}{PingCmd}, $args);

    #
    # Do a first ping in case the PC needs to wakeup
    #
    $s = $bpc->cmdSystemOrEval($pingCmd, undef, $args);
    if ( $? ) {
	print(STDERR "CheckHostAlive: first ping failed ($?, $!)\n")
			if ( $bpc->{verbose} );
	return -1;
    }

    #
    # Do a second ping and get the round-trip time in msec
    #
    $s = $bpc->cmdSystemOrEval($pingCmd, undef, $args);
    if ( $? ) {
	print(STDERR "CheckHostAlive: second ping failed ($?, $!)\n")
			if ( $bpc->{verbose} );
	return -1;
    }
    if ( $s =~ /time=([\d\.]+)\s*ms/i ) {
	$ret = $1;
    } elsif ( $s =~ /time=([\d\.]+)\s*usec/i ) {
	$ret =  $1/1000;
    } else {
	print(STDERR "CheckHostAlive: can't extract round-trip time"
	           . " (not fatal)\n") if ( $bpc->{verbose} );
	$ret = 0;
    }
    print(STDERR "CheckHostAlive: returning $ret\n") if ( $bpc->{verbose} );
    return $ret;
}

sub CheckFileSystemUsage
{
    my($bpc) = @_;
    my($topDir) = $bpc->{TopDir};
    my($s, $dfCmd);

    return 0 if ( $bpc->{Conf}{DfCmd} eq "" );
    my $args = {
	dfPath   => $bpc->{Conf}{DfPath},
	topDir   => $bpc->{TopDir},
    };
    $dfCmd = $bpc->cmdVarSubstitute($bpc->{Conf}{DfCmd}, $args);
    $s = $bpc->cmdSystemOrEval($dfCmd, undef, $args);
    return 0 if ( $? || $s !~ /(\d+)%/s );
    return $1;
}

#
# Given an IP address, return the host name and user name via
# NetBios.
#
sub NetBiosInfoGet
{
    my($bpc, $host) = @_;
    my($netBiosHostName, $netBiosUserName);
    my($s, $nmbCmd);

    #
    # Skip NetBios check if NmbLookupCmd is emtpy
    #
    if ( $bpc->{Conf}{NmbLookupCmd} eq "" ) {
	print(STDERR "NetBiosInfoGet: return $host because \$Conf{NmbLookupCmd}"
	           . " is empty\n") if ( $bpc->{verbose} );
	return ($host, undef);
    }

    my $args = {
	nmbLookupPath => $bpc->{Conf}{NmbLookupPath},
	host	      => $host,
    };
    $nmbCmd = $bpc->cmdVarSubstitute($bpc->{Conf}{NmbLookupCmd}, $args);
    foreach ( split(/[\n\r]+/, $bpc->cmdSystemOrEval($nmbCmd, undef, $args)) ) {
        next if ( !/^\s*([\w\s-]+?)\s*<(\w{2})\> - .*<ACTIVE>/i );
        $netBiosHostName ||= $1 if ( $2 eq "00" );  # host is first 00
        $netBiosUserName   = $1 if ( $2 eq "03" );  # user is last 03
    }
    if ( !defined($netBiosHostName) ) {
	print(STDERR "NetBiosInfoGet: failed: can't parse return string\n")
			if ( $bpc->{verbose} );
	return;
    }
    $netBiosHostName = lc($netBiosHostName);
    $netBiosUserName = lc($netBiosUserName);
    print(STDERR "NetBiosInfoGet: success, returning host $netBiosHostName,"
               . " user $netBiosUserName\n") if ( $bpc->{verbose} );
    return ($netBiosHostName, $netBiosUserName);
}

#
# Given a NetBios name lookup the IP address via NetBios.
# In the case of a host returning multiple interfaces we
# return the first IP address that matches the subnet mask.
# If none match the subnet mask (or nmblookup doesn't print
# the subnet mask) then just the first IP address is returned.
#
sub NetBiosHostIPFind
{
    my($bpc, $host) = @_;
    my($netBiosHostName, $netBiosUserName);
    my($s, $nmbCmd, $subnet, $ipAddr, $firstIpAddr);

    #
    # Skip NetBios lookup if NmbLookupFindHostCmd is emtpy
    #
    if ( $bpc->{Conf}{NmbLookupFindHostCmd} eq "" ) {
	print(STDERR "NetBiosHostIPFind: return $host because"
	    . " \$Conf{NmbLookupFindHostCmd} is empty\n")
		if ( $bpc->{verbose} );
	return $host;
    }

    my $args = {
	nmbLookupPath => $bpc->{Conf}{NmbLookupPath},
	host	      => $host,
    };
    $nmbCmd = $bpc->cmdVarSubstitute($bpc->{Conf}{NmbLookupFindHostCmd}, $args);
    foreach my $resp ( split(/[\n\r]+/, $bpc->cmdSystemOrEval($nmbCmd, undef,
							      $args) ) ) {
	if ( $resp =~ /querying\s+\Q$host\E\s+on\s+(\d+\.\d+\.\d+\.\d+)/i ) {
	    $subnet = $1;
	    $subnet = $1 if ( $subnet =~ /^(.*?)(\.255)+$/ );
	} elsif ( $resp =~ /^\s*(\d+\.\d+\.\d+\.\d+)\s+\Q$host/ ) {
	    my $ip = $1;
	    $firstIpAddr = $ip if ( !defined($firstIpAddr) );
	    $ipAddr      = $ip if ( !defined($ipAddr) && $ip =~ /^\Q$subnet/ );
	}
    }
    $ipAddr = $firstIpAddr if ( !defined($ipAddr) );
    if ( defined($ipAddr) ) {
	print(STDERR "NetBiosHostIPFind: found IP address $ipAddr for"
	           . " host $host\n") if ( $bpc->{verbose} );
	return $ipAddr;
    } else {
	print(STDERR "NetBiosHostIPFind: couldn't find IP address for"
	           . " host $host\n") if ( $bpc->{verbose} );
	return;
    }
}

sub fileNameEltMangle
{
    my($bpc, $name) = @_;

    return "" if ( $name eq "" );
    $name =~ s{([%/\n\r])}{sprintf("%%%02x", ord($1))}eg;
    return "f$name";
}

#
# We store files with every name preceded by "f".  This
# avoids possible name conflicts with other information
# we store in the same directories (eg: attribute info).
# The process of turning a normal path into one with each
# node prefixed with "f" is called mangling.
#
sub fileNameMangle
{
    my($bpc, $name) = @_;

    $name =~ s{/([^/]+)}{"/" . $bpc->fileNameEltMangle($1)}eg;
    $name =~ s{^([^/]+)}{$bpc->fileNameEltMangle($1)}eg;
    return $name;
}

#
# This undoes FileNameMangle
#
sub fileNameUnmangle
{
    my($bpc, $name) = @_;

    $name =~ s{/f}{/}g;
    $name =~ s{^f}{};
    $name =~ s{%(..)}{chr(hex($1))}eg;
    return $name;
}

#
# Escape shell meta-characters with backslashes.
# This should be applied to each argument seperately, not an
# entire shell command.
#
sub shellEscape
{
    my($bpc, $cmd) = @_;

    $cmd =~ s/([][;&()<>{}|^\n\r\t *\$\\'"`?])/\\$1/g;
    return $cmd;
}

#
# For printing exec commands (which don't use a shell) so they look like
# a valid shell command this function should be called with the exec
# args.  The shell command string is returned.
#
sub execCmd2ShellCmd
{
    my($bpc, @args) = @_;
    my $str;

    foreach my $a ( @args ) {
	$str .= " " if ( $str ne "" );
	$str .= $bpc->shellEscape($a);
    }
    return $str;
}

#
# Do a URI-style escape to protect/encode special characters
#
sub uriEsc
{
    my($bpc, $s) = @_;
    $s =~ s{([^\w.\/-])}{sprintf("%%%02X", ord($1));}eg;
    return $s;
}

#
# Do a URI-style unescape to restore special characters
#
sub uriUnesc
{
    my($bpc, $s) = @_;
    $s =~ s{%(..)}{chr(hex($1))}eg;
    return $s;
}

#
# Do variable substitution prior to execution of a command.
#
sub cmdVarSubstitute
{
    my($bpc, $template, $vars) = @_;
    my(@cmd);

    #
    # Return without any substitution if the first entry starts with "&",
    # indicating this is perl code.
    #
    if ( (ref($template) eq "ARRAY" ? $template->[0] : $template) =~ /^\&/ ) {
        return $template;
    }
    if ( ref($template) ne "ARRAY" ) {
	#
	# Split at white space, except if escaped by \
	#
	$template = [split(/(?<!\\)\s+/, $template)];
	#
	# Remove the \ that escaped white space.
	#
        foreach ( @$template ) {
            s{\\(\s)}{$1}g;
        }
    }
    #
    # Merge variables into @tarClientCmd
    #
    foreach my $arg ( @$template ) {
        #
        # Replace scalar variables first
        #
        $arg =~ s{\$(\w+)(\+?)}{
            exists($vars->{$1}) && ref($vars->{$1}) ne "ARRAY"
                ? ($2 eq "+" ? $bpc->shellEscape($vars->{$1}) : $vars->{$1})
                : "\$$1$2"
        }eg;
        #
        # Now replicate any array arguments; this just works for just one
        # array var in each argument.
        #
        if ( $arg =~ m{(.*)\$(\w+)(\+?)(.*)} && ref($vars->{$2}) eq "ARRAY" ) {
            my $pre  = $1;
            my $var  = $2;
            my $esc  = $3;
            my $post = $4;
            foreach my $v ( @{$vars->{$var}} ) {
                $v = $bpc->shellEscape($v) if ( $esc eq "+" );
                push(@cmd, "$pre$v$post");
            }
        } else {
            push(@cmd, $arg);
        }
    }
    return \@cmd;
}

#
# Exec or eval a command.  $cmd is either a string on an array ref.
#
# @args are optional arguments for the eval() case; they are not used
# for exec().
#
sub cmdExecOrEval
{
    my($bpc, $cmd, @args) = @_;
    
    if ( (ref($cmd) eq "ARRAY" ? $cmd->[0] : $cmd) =~ /^\&/ ) {
        $cmd = join(" ", $cmd) if ( ref($cmd) eq "ARRAY" );
	print(STDERR "cmdExecOrEval: about to eval perl code $cmd\n")
			if ( $bpc->{verbose} );
        eval($cmd);
        print(STDERR "Perl code fragment for exec shouldn't return!!\n");
        exit(1);
    } else {
        $cmd = [split(/\s+/, $cmd)] if ( ref($cmd) ne "ARRAY" );
	print(STDERR "cmdExecOrEval: about to exec ",
	      $bpc->execCmd2ShellCmd(@$cmd), "\n")
			if ( $bpc->{verbose} );
	alarm(0);
	$cmd = [map { m/(.*)/ } @$cmd];		# untaint
	#
	# force list-form of exec(), ie: no shell even for 1 arg
	#
        exec { $cmd->[0] } @$cmd;
        print(STDERR "Exec failed for @$cmd\n");
        exit(1);
    }
}

#
# System or eval a command.  $cmd is either a string on an array ref.
# $stdoutCB is a callback for output generated by the command.  If it
# is undef then output is returned.  If it is a code ref then the function
# is called with each piece of output as an argument.  If it is a scalar
# ref the output is appended to this variable.
#
# @args are optional arguments for the eval() case; they are not used
# for system().
#
# Also, $? should be set when the CHILD pipe is closed.
#
sub cmdSystemOrEval
{
    my($bpc, $cmd, $stdoutCB, @args) = @_;
    my($pid, $out, $allOut);
    local(*CHILD);
    
    if ( (ref($cmd) eq "ARRAY" ? $cmd->[0] : $cmd) =~ /^\&/ ) {
        $cmd = join(" ", $cmd) if ( ref($cmd) eq "ARRAY" );
	print(STDERR "cmdSystemOrEval: about to eval perl code $cmd\n")
			if ( $bpc->{verbose} );
        $out = eval($cmd);
	$$stdoutCB .= $out if ( ref($stdoutCB) eq 'SCALAR' );
	&$stdoutCB($out)   if ( ref($stdoutCB) eq 'CODE' );
	print(STDERR "cmdSystemOrEval: finished: got output $out\n")
			if ( $bpc->{verbose} );
	return $out        if ( !defined($stdoutCB) );
	return;
    } else {
        $cmd = [split(/\s+/, $cmd)] if ( ref($cmd) ne "ARRAY" );
	print(STDERR "cmdSystemOrEval: about to system ",
	      $bpc->execCmd2ShellCmd(@$cmd), "\n")
			if ( $bpc->{verbose} );
        if ( !defined($pid = open(CHILD, "-|")) ) {
	    my $err = "Can't fork to run @$cmd\n";
	    $? = 1;
	    $$stdoutCB .= $err if ( ref($stdoutCB) eq 'SCALAR' );
	    &$stdoutCB($err)   if ( ref($stdoutCB) eq 'CODE' );
	    return $err        if ( !defined($stdoutCB) );
	    return;
	}
	binmode(CHILD);
	if ( !$pid ) {
	    #
	    # This is the child
	    #
            close(STDERR);
	    open(STDERR, ">&STDOUT");
	    alarm(0);
	    $cmd = [map { m/(.*)/ } @$cmd];		# untaint
	    #
	    # force list-form of exec(), ie: no shell even for 1 arg
	    #
	    exec { $cmd->[0] } @$cmd;
            print("Exec of @$cmd failed\n");
            exit(1);
	}
	#
	# The parent gathers the output from the child
	#
	while ( <CHILD> ) {
	    $$stdoutCB .= $_ if ( ref($stdoutCB) eq 'SCALAR' );
	    &$stdoutCB($_)   if ( ref($stdoutCB) eq 'CODE' );
	    $out .= $_ 	     if ( !defined($stdoutCB) );
	    $allOut .= $_    if ( $bpc->{verbose} );
	}
	$? = 0;
	close(CHILD);
    }
    print(STDERR "cmdSystemOrEval: finished: got output $allOut\n")
			if ( $bpc->{verbose} );
    return $out;
}

1;
