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

package BackupPC::Lib;

use strict;

use vars qw(%Conf %Lang);
use Fcntl ':mode';
use Carp;
use Socket;
use Cwd;
use Digest::MD5;
use Config;
use Encode qw/from_to encode_utf8/;

use BackupPC::Storage;
use BackupPC::XS;

sub new
{
    my $class = shift;
    my($topDir, $installDir, $confDir, $noUserCheck) = @_;

    #
    # Whether to use filesystem hierarchy standard for file layout.
    # If set, text config files are below /etc/BackupPC.
    #
    my $useFHS = 0;
    my $paths;

    #
    # Set defaults for $topDir and $installDir.
    #
    $topDir     = '__TOPDIR__' if ( $topDir eq "" );
    $installDir = '__INSTALLDIR__'    if ( $installDir eq "" );

    #
    # Pick some initial defaults.  For FHS the only critical
    # path is the ConfDir, since we get everything else out
    # of the main config file.
    #
    if ( $useFHS ) {
        $paths = {
            useFHS     => $useFHS,
            TopDir     => $topDir,
            InstallDir => $installDir,
            ConfDir    => $confDir eq "" ? '__CONFDIR__' : $confDir,
            LogDir     => '/var/log/BackupPC',
            RunDir     => '/var/run/BackupPC',
        };
    } else {
        $paths = {
            useFHS     => $useFHS,
            TopDir     => $topDir,
            InstallDir => $installDir,
            ConfDir    => $confDir eq "" ? "$topDir/conf" : $confDir,
            LogDir     => "$topDir/log",
            RunDir     => "$topDir/log",
        };
    }

    my $bpc = bless {
	%$paths,
        Version => '4.0.0alpha3',
    }, $class;

    $bpc->{storage} = BackupPC::Storage->new($paths);

    #
    # Clean up %ENV and setup other variables.
    #
    delete @ENV{qw(IFS CDPATH ENV BASH_ENV)};
    if ( defined(my $error = $bpc->ConfigRead()) ) {
        print(STDERR $error, "\n");
        return;
    }

    #
    # Update the paths based on the config file
    #
    foreach my $dir ( qw(TopDir ConfDir InstallDir LogDir RunDir) ) {
        next if ( $bpc->{Conf}{$dir} eq "" );
        $paths->{$dir} = $bpc->{$dir} = $bpc->{Conf}{$dir};
    }
    $bpc->{storage}->setPaths($paths);
    $bpc->{PoolDir}    = "$bpc->{TopDir}/pool";
    $bpc->{CPoolDir}   = "$bpc->{TopDir}/cpool";

    #
    # Verify we are running as the correct user
    #
    if ( !$noUserCheck
	    && $bpc->{Conf}{BackupPCUserVerify}
	    && $> != (my $uid = (getpwnam($bpc->{Conf}{BackupPCUser}))[2]) ) {
	print(STDERR "$0: Wrong user: my userid is $>, instead of $uid"
	    . " ($bpc->{Conf}{BackupPCUser})\n");
	print(STDERR "Please su $bpc->{Conf}{BackupPCUser} first\n");
	return;
    }

    BackupPC::XS::Lib::ConfInit($bpc->{TopDir}, $bpc->{Conf}{HardLinkMax}, $bpc->{Conf}{PoolV3Enabled}, $bpc->{Conf}{XferLogLevel});

    return $bpc;
}

sub TopDir
{
    my($bpc) = @_;
    return $bpc->{TopDir};
}

sub PoolDir
{
    my($bpc, $compress) = @_;
    return $compress ? $bpc->{CPoolDir} : $bpc->{PoolDir}
}

sub BinDir
{
    my($bpc) = @_;
    return "$bpc->{InstallDir}/bin";
}

sub LogDir
{
    my($bpc) = @_;
    return $bpc->{LogDir};
}

sub RunDir
{
    my($bpc) = @_;
    return $bpc->{RunDir};
}

sub ConfDir
{
    my($bpc) = @_;
    return $bpc->{ConfDir};
}

sub LibDir
{
    my($bpc) = @_;
    return "$bpc->{InstallDir}/lib";
}

sub InstallDir
{
    my($bpc) = @_;
    return $bpc->{InstallDir};
}

sub useFHS
{
    my($bpc) = @_;
    return $bpc->{useFHS};
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

sub scgiJob
{
    return " scgi ";
}

sub adminJob
{
    my($bpc, $num) = @_;
    return " admin " if ( !$num );
    return " admin$num ";
}

sub isAdminJob
{
    my($bpc, $str) = @_;
    return $str =~ /^ admin/;
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

sub sigName2num
{
    my($bpc, $sig) = @_;

    if ( !defined($bpc->{SigName2Num}) ) {
	my $i = 0;
	foreach my $name ( split(' ', $Config{sig_name}) ) {
	    $bpc->{SigName2Num}{$name} = $i;
	    $i++;
	}
    }
    return $bpc->{SigName2Num}{$sig};
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

    return $bpc->{storage}->BackupInfoRead($host);
}

sub BackupInfoWrite
{
    my($bpc, $host, @Backups) = @_;

    return $bpc->{storage}->BackupInfoWrite($host, @Backups);
}

sub RestoreInfoRead
{
    my($bpc, $host) = @_;

    return $bpc->{storage}->RestoreInfoRead($host);
}

sub RestoreInfoWrite
{
    my($bpc, $host, @Restores) = @_;

    return $bpc->{storage}->RestoreInfoWrite($host, @Restores);
}

sub ArchiveInfoRead
{
    my($bpc, $host) = @_;

    return $bpc->{storage}->ArchiveInfoRead($host);
}

sub ArchiveInfoWrite
{
    my($bpc, $host, @Archives) = @_;

    return $bpc->{storage}->ArchiveInfoWrite($host, @Archives);
}

sub ConfigDataRead
{
    my($bpc, $host) = @_;

    return $bpc->{storage}->ConfigDataRead($host);
}

sub ConfigDataWrite
{
    my($bpc, $host, $conf) = @_;

    return $bpc->{storage}->ConfigDataWrite($host, $conf);
}

sub ConfigRead
{
    my($bpc, $host) = @_;
    my($ret);

    #
    # Read main config file
    #
    my($mesg, $config) = $bpc->{storage}->ConfigDataRead();
    return $mesg if ( defined($mesg) );

    $bpc->{Conf} = $config;

    #
    # Read host config file
    #
    if ( $host ne "" ) {
	($mesg, $config) = $bpc->{storage}->ConfigDataRead($host, $config);
	return $mesg if ( defined($mesg) );
	$bpc->{Conf} = $config;
    }

    #
    # Load optional perl modules
    #
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

    #
    # Load language file
    #
    return "No language setting" if ( !defined($bpc->{Conf}{Language}) );
    my $langFile = "$bpc->{InstallDir}/lib/BackupPC/Lang/$bpc->{Conf}{Language}.pm";
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

    return $bpc->{storage}->ConfigMTime();
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

    return $bpc->{storage}->HostInfoRead($host);
}

sub HostInfoWrite
{
    my($bpc, $host) = @_;

    return $bpc->{storage}->HostInfoWrite($host);
}

#
# Return the mtime of the hosts file
#
sub HostsMTime
{
    my($bpc) = @_;

    return $bpc->{storage}->HostsMTime();
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
    my $sockFile = "$bpc->{RunDir}/BackupPC.sock";
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
    $mesg =~ s/\n/\\n/g;
    $mesg =~ s/\r/\\r/g;
    my $md5 = Digest::MD5->new;
    $mesg = encode_utf8($mesg);
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
# New digest calculation for BackupPC >= 4.X.
#
# Compute the MD5 digest of an entire file.
# Returns the binary MD5 digest.
# On error returns undef.
#
sub File2MD5
{
    my($bpc, $md5, $name) = @_;
    my($data, $fileSize);
    local(*N);

    $name = $1 if ( $name =~ /(.*)/ );
    return undef if ( !open(N, $name) );
    binmode(N);
    $md5->reset();
    $md5->addfile(*N);
    close(N);
    return $md5->digest;
}

#
# New digest calculation for BackupPC >= 4.X.
#
# Compute the MD5 digest of a buffer (string).
# Returns the binary MD5 digest.
#
sub Buffer2MD5
{
    my($bpc, $md5, $dataRef) = @_;

    $md5->reset();
    $md5->add($$dataRef);
    return $md5->digest;
}

#
# Given a binary MD5 digest $d and a compress flag, return the
# full path in the pool.  We use the top 7 bits of the first
# byte for the top-level directory and the top 7 bits of the
# second byte for the 2nd-level directory.
#
sub MD52Path
{
    my($bpc, $d, $compress, $poolDir) = @_;

    my $b2 = vec($d, 0, 16);

    $poolDir = ($compress ? $bpc->{CPoolDir} : $bpc->{PoolDir})
		    if ( !defined($poolDir) );
    return sprintf("%s/%02x/%02x/%s", $poolDir,
                     ($b2 >> 8) & 0xfe,
                     ($b2 >> 0) & 0xfe,
                     unpack("H*", $d));
}

#
# V4 digest extension for MD5 collisions.
#
# Take the digest and append $extCnt in binary, with leading
# 0x0 removed.  That means when $extCnt == 0, nothing is
# appended and the digest is the original 16 byte MD5 digest.
#
# Example: when $extCnt == 1 then 0x01 is appended (1 more byte).
# When $extCnt == 258 then 0x0102 is appended (2 more bytes).
#
sub digestConcat
{
    my($bpc, $digest, $extCnt, $compress) = @_;

    $digest = substr($digest, 16) if ( length($digest) > 16 );
    my $ext = pack("N", $extCnt);
    $ext =~ s/^\x00+//;
    my $thisDigest = $digest . $ext;
    my $poolName = $bpc->MD52Path($thisDigest, $compress);

    return($thisDigest, $poolName);
}

#
# Given a digest from digestConcat() return the extension value
# as an integer
#
sub digestExtGet
{
    my($bpc, $digest) = @_;

    #
    # get the extension bytes, which start a byte 16.
    # also, prepend hour 0x0 bytes, then take the last 4 bytes.
    # this repads the extension to "N" format with leading 0x0
    # bytes.
    #
    return unpack("N", substr(pack("N", 0) . substr($digest, 16), -4));
}

#
# Old Digest calculation for BackupPC <= 3.X.
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
sub File2MD5_v3
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
# Old Digest calculation for BackupPC <= 3.X.
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
sub Buffer2MD5_v3
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
# Old pool path for BackupPC <= 3.X.  Prior to 4.X the pool
# was stored in a directory tree 3 levels deep using the first
# 3 hex digits of the digest.
#
# Given an MD5 digest $d and a compress flag, return the full
# path in the pool.
#
sub MD52Path_v3
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
            if ( !-d $newDir ) {
                eval { mkpath($newDir, 0, 0777) };
                return -5 if ( $@ );
            }
            return -4 if ( !link($name, $rawFile) );
            return 2;
        } else {
            return 0;
        }
    }
}

#
# Tests if we can create a hardlink from a file in directory
# $newDir to a file in directory $targetDir.  A temporary
# file in $targetDir is created and an attempt to create a
# hardlink of the same name in $newDir is made.  The temporary
# files are removed.
#
# Like link(), returns true on success and false on failure.
#
sub HardlinkTest
{
    my($bpc, $targetDir, $newDir) = @_;

    my($targetFile, $newFile, $fd);
    for ( my $i = 0 ; ; $i++ ) {
        $targetFile = "$targetDir/.TestFileLink.$$.$i";
        $newFile    = "$newDir/.TestFileLink.$$.$i";
        last if ( !-e $targetFile && !-e $newFile );
    }
    return 0 if ( !open($fd, ">", $targetFile) );
    close($fd);
    my $ret = link($targetFile, $newFile);
    unlink($targetFile);
    unlink($newFile);
    return $ret;
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
    if ( $s =~ /rtt\s*min\/avg\/max\/mdev\s*=\s*[\d.]+\/([\d.]+)\/[\d.]+\/[\d.]+\s*(ms|usec)/i ) {
        $ret = $1;
        $ret /= 1000 if ( lc($2) eq "usec" );
    } elsif ( $s =~ /time=([\d.]+)\s*(ms|usec)/i ) {
	$ret = $1;
        $ret /= 1000 if ( lc($2) eq "usec" );
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
        #
        # skip <GROUP> and other non <ACTIVE> entries
        #
        next if ( /<\w{2}> - <GROUP>/i );
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
        return ref($template) eq "ARRAY" ? $template : [$template];
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
    # Merge variables into @cmd
    #
    foreach my $arg ( @$template ) {
        #
        # Replace $VAR with ${VAR} so that both types of variable
        # substitution are supported
        #
        $arg =~ s[\$(\w+)]{\${$1}}g;
        #
        # Replace scalar variables first
        #
        $arg =~ s[\${(\w+)}(\+?)]{
            exists($vars->{$1}) && ref($vars->{$1}) ne "ARRAY"
                ? ($2 eq "+" ? $bpc->shellEscape($vars->{$1}) : $vars->{$1})
                : "\${$1}$2"
        }eg;
        #
        # Now replicate any array arguments; this just works for just one
        # array var in each argument.
        #
        if ( $arg =~ m[(.*)\${(\w+)}(\+?)(.*)] && ref($vars->{$2}) eq "ARRAY" ) {
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
        $cmd = join(" ", @$cmd) if ( ref($cmd) eq "ARRAY" );
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
sub cmdSystemOrEvalLong
{
    my($bpc, $cmd, $stdoutCB, $ignoreStderr, $pidHandlerCB, @args) = @_;
    my($pid, $out, $allOut);
    local(*CHILD);
    
    $? = 0;
    if ( (ref($cmd) eq "ARRAY" ? $cmd->[0] : $cmd) =~ /^\&/ ) {
        $cmd = join(" ", @$cmd) if ( ref($cmd) eq "ARRAY" );
	print(STDERR "cmdSystemOrEval: about to eval perl code $cmd\n")
			if ( $bpc->{verbose} );
        $out = eval($cmd);
	$$stdoutCB .= $out if ( ref($stdoutCB) eq 'SCALAR' );
	&$stdoutCB($out)   if ( ref($stdoutCB) eq 'CODE' );
	#print(STDERR "cmdSystemOrEval: finished: got output $out\n")
	#		if ( $bpc->{verbose} );
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
	    if ( $ignoreStderr ) {
		open(STDERR, ">", "/dev/null");
	    } else {
		open(STDERR, ">&STDOUT");
	    }
	    alarm(0);
	    $cmd = [map { m/(.*)/ } @$cmd];		# untaint
	    #
	    # force list-form of exec(), ie: no shell even for 1 arg
	    #
	    exec { $cmd->[0] } @$cmd;
            print(STDERR "Exec of @$cmd failed\n");
            exit(1);
	}

	#
	# Notify caller of child's pid
	#
	&$pidHandlerCB($pid) if ( ref($pidHandlerCB) eq "CODE" );

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
    #print(STDERR "cmdSystemOrEval: finished: got output $allOut\n")
    #   		if ( $bpc->{verbose} );
    return $out;
}

#
# The shorter version that sets $ignoreStderr = 0, ie: merges stdout
# and stderr together.
#
sub cmdSystemOrEval
{
    my($bpc, $cmd, $stdoutCB, @args) = @_;

    return $bpc->cmdSystemOrEvalLong($cmd, $stdoutCB, 0, undef, @args);
}

#
# Promotes $conf->{BackupFilesOnly}, $conf->{BackupFilesExclude}
# to hashes and $conf->{$shareName} to an array.
#
sub backupFileConfFix
{
    my($bpc, $conf, $shareName) = @_;

    $conf->{$shareName} = [ $conf->{$shareName} ]
                    if ( ref($conf->{$shareName}) ne "ARRAY" );
    foreach my $param ( qw(BackupFilesOnly BackupFilesExclude) ) {
        next if ( !defined($conf->{$param}) );
        if ( ref($conf->{$param}) eq "HASH" ) {
            #
            # A "*" entry means wildcard - it is the default for
            # all shares.  Replicate the "*" entry for all shares,
            # but still allow override of specific entries.
            #
            next if ( !defined($conf->{$param}{"*"}) );
            $conf->{$param} = {
                                    map({ $_ => $conf->{$param}{"*"} }
                                            @{$conf->{$shareName}}),
                                    %{$conf->{$param}}
                              };
        } else {
            $conf->{$param} = [ $conf->{$param} ]
                                    if ( ref($conf->{$param}) ne "ARRAY" );
            $conf->{$param} = { map { $_ => $conf->{$param} }
                                    @{$conf->{$shareName}} };
        }
    }
}

#
# This is sort() compare function, used below.
#
# New client LOG names are LOG.MMYYYY.  Old style names are
# LOG, LOG.0, LOG.1 etc.  Sort them so new names are
# first, and newest to oldest.
#
sub compareLOGName
{
    my $na = $1 if ( $a =~ /LOG\.(\d+)(\.z)?$/ );
    my $nb = $1 if ( $b =~ /LOG\.(\d+)(\.z)?$/ );

    $na = -1 if ( !defined($na) );
    $nb = -1 if ( !defined($nb) );

    if ( length($na) >= 5 && length($nb) >= 5 ) {
        #
        # Both new style: format is MMYYYY.  Bigger dates are
        # more recent.
        #
        my $ma = $2 * 12 + $1 if ( $na =~ /(\d+)(\d{4})/ );
        my $mb = $2 * 12 + $1 if ( $nb =~ /(\d+)(\d{4})/ );
        return $mb - $ma;
    } elsif ( length($na) >= 5 && length($nb) < 5 ) {
        return -1;
    } elsif ( length($na) < 5 && length($nb) >= 5 ) {
        return 1;
    } else {
        #
        # Both old style.  Smaller numbers are more recent.
        #
        return $na - $nb;
    }
}

#
# Returns list of paths to a clients's (or main) LOG files,
# most recent first.
#
sub sortedPCLogFiles
{
    my($bpc, $host) = @_;

    my(@files, $dir);

    if ( $host ne "" ) {
        $dir = "$bpc->{TopDir}/pc/$host";
    } else {
        $dir = "$bpc->{LogDir}";
    }
    if ( opendir(DIR, $dir) ) {
        foreach my $file ( readdir(DIR) ) {
            next if ( !-f "$dir/$file" );
            next if ( $file ne "LOG" && $file !~ /^LOG\.\d/ );
            push(@files, "$dir/$file");
        }
        closedir(DIR);
    }
    return sort compareLOGName @files;
}

#
# converts a glob-style pattern into a perl regular expression.
#
sub glob2re
{
    my ( $bpc, $glob ) = @_;
    my ( $char, $subst );

    # $escapeChars escapes characters with no special glob meaning but
    # have meaning in regexps.
    my $escapeChars = [ '.', '/', ];

    # $charMap is where we implement the special meaning of glob
    # patterns and translate them to regexps.
    my $charMap = {
                    '?' => '[^/]',
                    '*' => '[^/]*', };

    # multiple forward slashes are equivalent to one slash.  We should
    # never have to use this.
    $glob =~ s/\/+/\//;

    foreach $char (@$escapeChars) {
        $glob =~ s/\Q$char\E/\\$char/g;
    }

    while ( ( $char, $subst ) = each(%$charMap) ) {
        $glob =~ s/(?<!\\)\Q$char\E/$subst/g;
    }

    return $glob;
}

sub flushXSLibMesgs()
{
    my $msg = BackupPC::XS::Lib::logMsgGet();
    return if ( !defined($msg) );
    foreach my $m ( @$msg ) {
        print($m);
    }
}

1;
