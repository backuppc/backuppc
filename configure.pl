#!/bin/perl
#============================================================= -*-perl-*-
#
# configure.pl: Configuration and installation program for BackupPC
#
# DESCRIPTION
#
#   This script should be run as root:
#
#        perl configure.pl
#
#   The installation steps are described as the script runs.
#
# AUTHOR
#   Craig Barratt <cbarratt@users.sourceforge.net>
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
# Version 2.0.0_CVS, released 18 Jan 2003.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

use strict;
no  utf8;
use vars qw(%Conf %OrigConf);
use lib "./lib";

my @Packages = qw(ExtUtils::MakeMaker File::Path File::Spec File::Copy
                  DirHandle Digest::MD5 Data::Dumper Getopt::Std
		  BackupPC::Lib BackupPC::FileZIO);

foreach my $pkg ( @Packages ) {
    eval "use $pkg";
    next if ( !$@ );
    die <<EOF;

BackupPC needs the package $pkg.  Please install $pkg
before installing BackupPC.

EOF
}

if ( $< != 0 ) {
    print <<EOF;

This configure script should be run as root, rather than uid $<.
Provided uid $< has sufficient permissions to create the data and
install directories, then it should be ok to proceed.  Otherwise,
please quit and restart as root.

EOF
    exit unless prompt("--> Do you want to continue?", "y") =~ /y/i;
}

print <<EOF;

Is this a new installation or upgrade for BackupPC?  If this is
an upgrade please tell me the full path of the existing BackupPC
configuration file (eg: /xxxx/conf/config.pl).  Otherwise, just
hit return.

EOF

#
# Check if this is an upgrade, in which case read the existing
# config file to get all the defaults.
#
my $ConfigPath = "";
while ( 1 ) {
    $ConfigPath = prompt("--> Full path to existing conf/config.pl",
                                    $ConfigPath);
    last if ( $ConfigPath eq ""
            || ($ConfigPath =~ /^\// && -r $ConfigPath && -w $ConfigPath) );
    my $problem = "is not an absolute path";
    $problem = "is not writable" if ( !-w $ConfigPath );
    $problem = "is not readable" if ( !-r $ConfigPath );
    $problem = "doesn't exist"   if ( !-f $ConfigPath );
    print("The file '$ConfigPath' $problem.\n");
}
my $bpc;
if ( $ConfigPath ne "" && -r $ConfigPath ) {
    (my $topDir = $ConfigPath) =~ s{/[^/]+/[^/]+$}{};
    die("BackupPC::Lib->new failed\n")
            if ( !($bpc = BackupPC::Lib->new($topDir, ".", 1)) );
    %Conf = $bpc->Conf();
    %OrigConf = %Conf;
    $Conf{TopDir} = $topDir;
    my $err = $bpc->ServerConnect($Conf{ServerHost}, $Conf{ServerPort}, 1); 
    if ( $err eq "" ) {
        print <<EOF;

BackupPC is running on $Conf{ServerHost}.  You need to stop BackupPC
before you can upgrade the code.  Depending upon your installation,
you could run "/etc/init.d/backuppc stop".

EOF
        exit(1);
    }
}

#
# These are the programs whose paths we need to find
#
my %Programs = (
    perl       => "PerlPath",
    'gtar/tar' => "TarClientPath",
    smbclient  => "SmbClientPath",
    nmblookup  => "NmbLookupPath",
    rsync      => "RsyncClientPath",
    ping       => "PingPath",
    df         => "DfPath",
    'ssh/ssh2' => "SshPath",
    sendmail   => "SendmailPath",
    hostname   => "HostnamePath",
);

foreach my $prog ( sort(keys(%Programs)) ) {
    my $path;
    foreach my $subProg ( split(/\//, $prog) ) {
        $path ||= FindProgram("$ENV{PATH}:/bin:/usr/bin:/sbin:/usr/sbin",
                              $subProg);
    }
    $Conf{$Programs{$prog}} ||= $path;
}

while ( 1 ) {
    print <<EOF;

I found the following locations for these programs:

EOF
    foreach my $prog ( sort(keys(%Programs)) ) {
        printf("    %-11s => %s\n", $prog, $Conf{$Programs{$prog}});
    }
    print "\n";
    last if (prompt('--> Are these paths correct?', 'y') =~ /^y/i);
    foreach my $prog ( sort(keys(%Programs)) ) {
        $Conf{$Programs{$prog}} = prompt("--> $prog path",
                                         $Conf{$Programs{$prog}});
    }
}

my $Perl56 = system($Conf{PerlPath}
                        . q{ -e 'exit($^V && $^V ge v5.6.0 ? 1 : 0);'});

if ( !$Perl56 ) {
    print <<EOF;

BackupPC needs perl version 5.6.0 or later.  $Conf{PerlPath} appears
to be an older version.  Please upgrade to a newer version of perl
and re-run this configure script.

EOF
    exit(1);
}

print <<EOF;

Please tell me the hostname of the machine that BackupPC will run on.

EOF
chomp($Conf{ServerHost} = `$Conf{HostnamePath}`)
        if ( defined($Conf{HostnamePath}) && !defined($Conf{ServerHost}) );
$Conf{ServerHost} = prompt("--> BackupPC will run on host", $Conf{ServerHost});

print <<EOF;

BackupPC should run as a dedicated user with limited privileges.  You
need to create a user.  This user will need read/write permission on
the main data directory and read/execute permission on the install
directory (these directories will be setup shortly).

The primary group for this user should also be chosen carefully.
By default the install directories will have group write permission.
The data directories and files will have group read permission but
no other permission.

EOF
my($name, $passwd, $Uid, $Gid);
while ( 1 ) {
    $Conf{BackupPCUser} = prompt("--> BackupPC should run as user",
                                 $Conf{BackupPCUser} || "backuppc");
    ($name, $passwd, $Uid, $Gid) = getpwnam($Conf{BackupPCUser});
    last if ( $name ne "" );
    print <<EOF;

getpwnam() says that user $Conf{BackupPCUser} doesn't exist.  Please check the
name and verify that this user is in the passwd file.

EOF
}

print <<EOF;

Please specify an install directory for BackupPC.  This is where the
BackupPC scripts, library and documentation will be installed.

EOF

while ( 1 ) {
    $Conf{InstallDir} = prompt("--> Install directory (full path)",
                               $Conf{InstallDir});
    last if ( $Conf{InstallDir} =~ /^\// );
}

print <<EOF;

Please specify a data directory for BackupPC.  This is where the
configuration files, LOG files and all the PC backups are stored.
This file system needs to be big enough to accommodate all the
PCs you expect to backup (eg: at least 1-2GB per machine).

EOF

while ( 1 ) {
    $Conf{TopDir} = prompt("--> Data directory (full path)", $Conf{TopDir});
    last if ( $Conf{TopDir} =~ /^\// );
}

if ( !defined($Conf{CompressLevel}) ) {
    $Conf{CompressLevel} = BackupPC::FileZIO->compOk ? 3 : 0;
    if ( $ConfigPath eq "" && $Conf{CompressLevel} ) {
        print <<EOF;

BackupPC can compress pool files, providing around a 40% reduction in pool
size (your mileage may vary). Specify the compression level (0 turns
off compression, and 1 to 9 represent good/fastest to best/slowest).
The recommended values are 0 (off) or 3 (reasonable compression and speed).
Increasing the compression level to 5 will use around 20% more cpu time
and give perhaps 2-3% more compression.

EOF
    } elsif ( $ConfigPath eq "" ) {
        print <<EOF;

BackupPC can compress pool files, but it needs the Compress::Zlib
package installed (see www.cpan.org). Compression will provide around a
40% reduction in pool size, at the expense of cpu time.  You can leave
compression off and run BackupPC without compression, in which case you
should leave the compression level at 0 (which means off).  You could
install Compress::Zlib and turn compression on later, but read the
documentation first about how to do this.  Or the better choice is
to quit, install Compress::Zlib, and re-run configure.pl.

EOF
    } elsif ( $Conf{CompressLevel} ) {
        $Conf{CompressLevel} = 0;
        print <<EOF;

BackupPC now supports pool file compression.  Since you are upgrading
BackupPC you probably have existing uncompressed backups.  You have
several choices if you want to turn on compression.  You can run
the script BackupPC_compressPool to convert everything to compressed
form.  Or you can simply turn on compression, so that new backups
will be compressed.  This will increase the pool storage requirement,
since both uncompressed and compressed copies of files will be stored.
But eventually the old uncompressed backups will expire, recovering
the pool storage.  Please see the documentation for more details.

If you are not sure what to do, leave the Compression Level at 0,
which disables compression.  You can always read the documentation
and turn it on later.

EOF
    } else {
        $Conf{CompressLevel} = 0;
        print <<EOF;

BackupPC now supports pool file compression, but it needs the
Compress::Zlib module (see www.cpan.org).  For now, leave
the compression level set at 0 to disable compression.  If you
want you can install Compress::Zlib and turn compression on.
Please see the documentation for more details about converting
old backups to compressed form.

EOF
    }
    while ( 1 ) {
        $Conf{CompressLevel}
                    = prompt("--> Compression level", $Conf{CompressLevel});
        last if ( $Conf{CompressLevel} =~ /^\d+$/ );
    }
}

print <<EOF;

BackupPC has a powerful CGI perl interface that runs under Apache.
A single executable needs to be installed in a cgi-bin directory.
This executable needs to run as set-uid $Conf{BackupPCUser}, or
it can be run under mod_perl with Apache running as user $Conf{BackupPCUser}.

Leave this path empty if you don't want to install the CGI interface.

EOF

while ( 1 ) {
    $Conf{CgiDir} = prompt("--> CGI bin directory (full path)", $Conf{CgiDir});
    last if ( $Conf{CgiDir} =~ /^\// || $Conf{CgiDir} eq "" );
}

if ( $Conf{CgiDir} ne "" ) {

    print <<EOF;

BackupPC's CGI script needs to display various GIF images that
should be stored where Apache can serve them.  They should be
placed somewher under Apache's DocumentRoot.  BackupPC also
needs to know the URL to access these images.  Example:

    Apache image directory:  /usr/local/apache/htdocs/BackupPC
    URL for image directory: /BackupPC

The URL for the image directory should start with a slash.

EOF
    while ( 1 ) {
	$Conf{CgiImageDir} = prompt("--> Apache image directory (full path)",
					$Conf{CgiImageDir});
	last if ( $Conf{CgiImageDir} =~ /^\// );
    }
    while ( 1 ) {
	$Conf{CgiImageDirURL} = prompt("--> URL for image directory (omit http://host; starts with '/')",
					$Conf{CgiImageDirURL});
	last if ( $Conf{CgiImageDirURL} =~ /^\// );
    }
}

print <<EOF;

Ok, we're about to:

  - install the binaries, lib and docs in $Conf{InstallDir},
  - create the data directory $Conf{TopDir},
  - create/update the config.pl file $Conf{TopDir}/conf,
  - optionally install the cgi-bin interface.

EOF

exit unless prompt("--> Do you want to continue?", "y") =~ /y/i;

#
# Create install directories
#
foreach my $dir ( qw(bin lib/BackupPC/Xfer lib/BackupPC/Zip
		     lib/BackupPC/Lang doc) ) {
    next if ( -d "$Conf{InstallDir}/$dir" );
    mkpath("$Conf{InstallDir}/$dir", 0, 0775);
    if ( !-d "$Conf{InstallDir}/$dir"
            || !chown($Uid, $Gid, "$Conf{InstallDir}/$dir") ) {
        die("Failed to create or chown $Conf{InstallDir}/$dir\n");
    } else {
        print("Created $Conf{InstallDir}/$dir\n");
    }
}

#
# Create CGI image directory
#
foreach my $dir ( ($Conf{CgiImageDir}) ) {
    next if ( $dir eq "" || -d $dir );
    mkpath($dir, 0, 0775);
    if ( !-d $dir || !chown($Uid, $Gid, $dir) ) {
        die("Failed to create or chown $dir");
    } else {
        print("Created $dir\n");
    }
}

#
# Create $TopDir's top-level directories
#
foreach my $dir ( qw(. conf pool cpool pc trash log) ) {
    mkpath("$Conf{TopDir}/$dir", 0, 0750) if ( !-d "$Conf{TopDir}/$dir" );
    if ( !-d "$Conf{TopDir}/$dir"
            || !chown($Uid, $Gid, "$Conf{TopDir}/$dir") ) {
        die("Failed to create or chown $Conf{TopDir}/$dir\n");
    } else {
        print("Created $Conf{TopDir}/$dir\n");
    }
}

printf("Installing binaries in $Conf{InstallDir}/bin\n");
foreach my $prog ( qw(BackupPC BackupPC_dump BackupPC_link BackupPC_nightly
        BackupPC_sendEmail BackupPC_tarCreate BackupPC_trashClean
        BackupPC_tarExtract BackupPC_compressPool BackupPC_zcat
        BackupPC_restore BackupPC_serverMesg BackupPC_zipCreate ) ) {
    InstallFile("bin/$prog", "$Conf{InstallDir}/bin/$prog", 0555);
}

#
# Remove unused binaries from older versions
#
unlink("$Conf{InstallDir}/bin/BackupPC_queueAll");

printf("Installing library in $Conf{InstallDir}/lib\n");
foreach my $lib ( qw(BackupPC/Lib.pm BackupPC/FileZIO.pm BackupPC/Attrib.pm
        BackupPC/PoolWrite.pm BackupPC/View.pm BackupPC/Xfer/Tar.pm
        BackupPC/Xfer/Smb.pm BackupPC/Xfer/Rsync.pm
        BackupPC/Xfer/RsyncFileIO.pm BackupPC/Zip/FileMember.pm
        BackupPC/Lang/en.pm BackupPC/Lang/fr.pm BackupPC/Lang/es.pm
        BackupPC/Lang/de.pm
    ) ) {
    InstallFile("lib/$lib", "$Conf{InstallDir}/lib/$lib", 0444);
}

if ( $Conf{CgiImageDir} ne "" ) {
    printf("Installing images in $Conf{CgiImageDir}\n");
    foreach my $img ( <images/*> ) {
	(my $destImg = $img) =~ s{^images/}{};
	InstallFile($img, "$Conf{CgiImageDir}/$destImg", 0444, 1);
    }
}

printf("Making init.d scripts\n");
foreach my $init ( qw(gentoo-backuppc gentoo-backuppc.conf linux-backuppc
		      solaris-backuppc debian-backuppc suse-backuppc) ) {
    InstallFile("init.d/src/$init", "init.d/$init", 0444);
}

printf("Installing docs in $Conf{InstallDir}/doc\n");
foreach my $doc ( qw(BackupPC.pod BackupPC.html) ) {
    InstallFile("doc/$doc", "$Conf{InstallDir}/doc/$doc", 0444);
}

printf("Installing config.pl and hosts in $Conf{TopDir}/conf\n");
InstallFile("conf/hosts", "$Conf{TopDir}/conf/hosts", 0644)
                    if ( !-f "$Conf{TopDir}/conf/hosts" );

#
# Now do the config file.  If there is an existing config file we
# merge in the new config file, adding any new configuration
# parameters and deleting ones that are no longer needed.
#
my $dest = "$Conf{TopDir}/conf/config.pl";
my ($newConf, $newVars) = ConfigParse("conf/config.pl");
my ($oldConf, $oldVars);
if ( -f $dest ) {
    ($oldConf, $oldVars) = ConfigParse($dest);
    $newConf = ConfigMerge($oldConf, $oldVars, $newConf, $newVars);
}
$Conf{EMailFromUserName}  ||= $Conf{BackupPCUser};
$Conf{EMailAdminUserName} ||= $Conf{BackupPCUser};

#
# Update various config parameters
#

#
# Guess $Conf{CgiURL}
#
if ( !defined($Conf{CgiURL}) ) {
    if ( $Conf{CgiDir} =~ m{cgi-bin(/.*)} ) {
	$Conf{CgiURL} = "'http://$Conf{ServerHost}/cgi-bin$1/BackupPC_Admin'";
    } else {
	$Conf{CgiURL} = "'http://$Conf{ServerHost}/cgi-bin/BackupPC_Admin'";
    }
}

#
# The smbclient commands have moved from hard-coded to the config file.
# $Conf{SmbClientArgs} no longer exists, so merge it into the new
# commands if it still exists.
#
if ( defined($Conf{SmbClientArgs}) ) {
    if ( $Conf{SmbClientArgs} ne "" ) {
        foreach my $param ( qw(SmbClientRestoreCmd SmbClientFullCmd
                                SmbClientIncrCmd) ) {
            $newConf->[$newVars->{$param}]{text}
                            =~ s/(-E\s+-N)/$1 $Conf{SmbClientArgs}/;
        }
    }
    delete($Conf{SmbClientArgs});
}

#
# IncrFill should now be off
#
$Conf{IncrFill} = 0;

#
# Figure out sensible arguments for the ping command
#
if ( defined($Conf{PingArgs}) ) {
    $Conf{PingCmd} = '$pingPath ' . $Conf{PingArgs};
} elsif ( !defined($Conf{PingCmd}) ) {
    if ( $^O eq "solaris" || $^O eq "sunos" ) {
	$Conf{PingCmd} = '$pingPath -s $host 56 1';
    } elsif ( ($^O eq "linux" || $^O eq "openbsd" || $^O eq "netbsd")
	    && !system("$Conf{PingClientPath} -c 1 -w 3 localhost") ) {
	$Conf{PingCmd} = '$pingPath -c 1 -w 3 $host';
    } else {
	$Conf{PingCmd} = '$pingPath -c 1 $host';
    }
    delete($Conf{PingArgs});
}

#
# Figure out sensible arguments for the df command
#
if ( !defined($Conf{DfCmd}) ) {
    if ( $^O eq "solaris" || $^O eq "sunos" ) {
	$Conf{DfCmd} = '$dfPath -k $topDir';
    }
}

#
# $Conf{SmbClientTimeout} is now $Conf{ClientTimeout}
#
if ( defined($Conf{SmbClientTimeout}) ) {
    $Conf{ClientTimeout} = $Conf{SmbClientTimeout};
    delete($Conf{SmbClientTimeout});
}

my $confCopy = "$dest.pre-__VERSION__";
if ( -f $dest && !-f $confCopy ) {
    #
    # Make copy of config file, preserving ownership and modes
    #
    printf("Making backup copy of $dest -> $confCopy\n");
    my @stat = stat($dest);
    my $mode = $stat[2];
    my $uid  = $stat[4];
    my $gid  = $stat[5];
    die("can't copy($dest, $confCopy)\n")  unless copy($dest, $confCopy);
    die("can't chown $uid, $gid $confCopy\n")
                                           unless chown($uid, $gid, $confCopy);
    die("can't chmod $mode $confCopy\n")   unless chmod($mode, $confCopy);
}
open(OUT, ">", $dest) || die("can't open $dest for writing\n");
binmode(OUT);
my $blockComment;
foreach my $var ( @$newConf ) {
    if ( length($blockComment)
          && substr($var->{text}, 0, length($blockComment)) eq $blockComment ) {
        $var->{text} = substr($var->{text}, length($blockComment));
        $blockComment = undef;
    }
    $blockComment = $1 if ( $var->{text} =~ /^([\s\n]*#{70}.*#{70}[\s\n]+)/s );
    $var->{text} =~ s/^\s*\$Conf\{(.*?)\}(\s*=\s*['"]?)(.*?)(['"]?\s*;)/
                defined($Conf{$1}) && ref($Conf{$1}) eq ""
                                   && $Conf{$1} ne $OrigConf{$1}
                                   ? "\$Conf{$1}$2$Conf{$1}$4"
                                   : "\$Conf{$1}$2$3$4"/emg;
    print OUT $var->{text};
}
close(OUT);
if ( !defined($oldConf) ) {
    die("can't chmod 0640 mode $dest\n")  unless chmod(0640, $dest);
    die("can't chown $Uid, $Gid $dest\n") unless chown($Uid, $Gid, $dest);
}

if ( $Conf{CgiDir} ne "" ) {
    printf("Installing cgi script BackupPC_Admin in $Conf{CgiDir}\n");
    mkpath("$Conf{CgiDir}", 0, 0755);
    InstallFile("cgi-bin/BackupPC_Admin", "$Conf{CgiDir}/BackupPC_Admin",
                04554);
}

print <<EOF;

Ok, it looks like we are finished.  There are several more things you
will need to do:

  - Browse through the config file, $Conf{TopDir}/conf/config.pl,
    and make sure all the settings are correct.  In particular, you
    will need to set the smb share password and user name, backup
    policies and check the email message headers and bodies.

  - Edit the list of hosts to backup in $Conf{TopDir}/conf/hosts.

  - Read the documentation in $Conf{InstallDir}/doc/BackupPC.html.
    Please pay special attention to the security section.

  - Verify that the CGI script BackupPC_Admin runs correctly.  You might
    need to change the permissions or group ownership of BackupPC_Admin.

  - BackupPC should be ready to start.  Don't forget to run it
    as user $Conf{BackupPCUser}!  The installation also contains an
    init.d/backuppc script that can be copied to /etc/init.d
    so that BackupPC can auto-start on boot.  See init.d/README.

Enjoy!
EOF

if ( $ENV{LANG} =~ /utf/i && $^V ge v5.8.0 ) {
    print <<EOF;

WARNING: Your LANG environment variable is set to $ENV{LANG}, which
doesn't behave well with this version of perl.  Please set the
LANG environment variable to en_US before running BackupPC.

On RH-8 this setting is in the file /etc/sysconfig/i18n, or you
could set it in BackupPC's init.d script.
EOF
}

exit(0);

###########################################################################
# Subroutines
###########################################################################

sub InstallFile
{
    my($prog, $dest, $mode, $binary) = @_;
    my $first = 1;
    my($uid, $gid) = ($Uid, $Gid);

    if ( -f $dest ) {
        #
        # preserve ownership and modes of files that already exist
        #
        my @stat = stat($dest);
        $mode = $stat[2];
        $uid  = $stat[4];
        $gid  = $stat[5];
    }
    unlink($dest) if ( -f $dest );
    if ( $binary ) {
	die("can't copy($prog, $dest)\n") unless copy($prog, $dest);
    } else {
	open(PROG, $prog)     || die("can't open $prog for reading\n");
	open(OUT, ">", $dest) || die("can't open $dest for writing\n");
	binmode(PROG);
	binmode(OUT);
	while ( <PROG> ) {
	    s/__INSTALLDIR__/$Conf{InstallDir}/g;
	    s/__TOPDIR__/$Conf{TopDir}/g;
	    s/__BACKUPPCUSER__/$Conf{BackupPCUser}/g;
	    s/__CGIDIR__/$Conf{CgiDir}/g;
	    if ( $first && /^#.*bin\/perl/ ) {
		if ( $Perl56 ) {
		    #
		    # perl56 and later is taint ok
		    #
		    print OUT "#!$Conf{PerlPath} -T\n";
		} else {
		    #
		    # prior to perl56, File::Find fails taint checks,
		    # so we run without -T.  It's still safe.
		    #
		    print OUT "#!$Conf{PerlPath}\n";
		}
	    } else {
		print OUT;
	    }
	    $first = 0;
	}
	close(PROG);
	close(OUT);
    }
    die("can't chown $uid, $gid $dest") unless chown($uid, $gid, $dest);
    die("can't chmod $mode $dest")      unless chmod($mode, $dest);
}

sub FindProgram
{
    my($path, $prog) = @_;
    foreach my $dir ( split(/:/, $path) ) {
        my $file = File::Spec->catfile($dir, $prog);
        return $file if ( -x $file );
    }
}

sub ConfigParse
{
    my($file) = @_;
    open(C, $file) || die("can't open $file");
    binmode(C);
    my($out, @conf, $var);
    my $comment = 1;
    my $allVars = {};
    while ( <C> ) {
        if ( /^#/ ) {
            if ( $comment ) {
                $out .= $_;
            } else {
                if ( $out ne "" ) {
                    $allVars->{$var} = @conf if ( defined($var) );
                    push(@conf, {
                        text => $out,
                        var => $var,
                    });
                }
                $var = undef;
                $comment = 1;
                $out = $_;
            }
        } elsif ( /^\s*\$Conf\{([^}]*)/ ) {
            $comment = 0;
            if ( defined($var) ) {
                $allVars->{$var} = @conf if ( defined($var) );
                push(@conf, {
                    text => $out,
                    var => $var,
                });
                $out = $_;
            } else {
                $out .= $_;
            }
            $var = $1;
        } else {
            $out .= $_;
        }
    }
    if ( $out ne "" ) {
        $allVars->{$var} = @conf if ( defined($var) );
        push(@conf, {
            text => $out,
            var  => $var,
        });
    }
    close(C);
    return (\@conf, $allVars);
}

sub ConfigMerge
{
    my($old, $oldVars, $new, $newVars) = @_;
    my $posn = 0;
    my $res;

    #
    # Find which config parameters are not needed any longer
    #
    foreach my $var ( @$old ) {
        next if ( !defined($var->{var}) || defined($newVars->{$var->{var}}) );
        #print(STDERR "Deleting old config parameter $var->{var}\n");
        $var->{delete} = 1;
    }
    #
    # Find which config parameters are new
    #
    foreach my $var ( @$new ) {
        next if ( !defined($var->{var}) );
        if ( defined($oldVars->{$var->{var}}) ) {
            $posn = $oldVars->{$var->{var}};
        } else {
            #print(STDERR "New config parameter $var->{var}: $var->{text}\n");
            push(@{$old->[$posn]{new}}, $var);
        }
    }
    #
    # Create merged config file
    #
    foreach my $var ( @$old ) {
        next if ( $var->{delete} );
        push(@$res, $var);
        foreach my $new ( @{$var->{new}} ) {
            push(@$res, $new);
        }
    }
    return $res;
}
