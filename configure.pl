#!/usr/bin/env perl
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
#   To read about the command-line options for this configure script:
#
#        perldoc configure.pl
#
#   The installation steps are described as the script runs.
#
# AUTHOR
#   Craig Barratt <cbarratt@users.sourceforge.net>
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

use strict;
no  utf8;
use vars qw(%Conf %OrigConf);
use lib "./lib";
use Encode;

my $EncodeVersion = eval($Encode::VERSION);
if ( $EncodeVersion < 1.99 ) {
    print("Error: you need to upgrade perl's Encode package.\n"
        . "I found $EncodeVersion and BackupPC needs >= 1.99\n"
        . "Please go to www.cpan.org or use the cpan command.\n");
    exit(1);
}

my @Packages = qw(File::Path File::Spec File::Copy DirHandle Digest::MD5
                  Data::Dumper Getopt::Std Getopt::Long Pod::Usage
                  BackupPC::Lib BackupPC::XS);

my $PackageVersion = {
        "BackupPC::XS" => "0.30",
    };

foreach my $pkg ( @Packages ) {
    eval "use $pkg";
    if ( !$@ ) {
        next if ( !defined($PackageVersion->{$pkg}) );
        my $version = eval "\$${pkg}::VERSION";
        next if ( $version >= $PackageVersion->{$pkg} );
        die <<EOF;

Package $pkg needs to be at least version $PackageVersion->{$pkg}.
The currently installed $pkg is version $version.

Please upgrade package $pkg to the latest version and then re-run
this script.
EOF
    }
    if ( $pkg =~ /BackupPC::Lib/ ) {
        die <<EOF;

Error loading $pkg: $@
BackupPC cannot load the package $pkg, which is included in the
BackupPC distribution.  This probably means you did not cd to the
unpacked BackupPC distribution before running configure.pl, eg:

    cd BackupPC-4.0.0alpha3
    ./configure.pl

Please try again.

EOF
    }
    die <<EOF;

BackupPC needs the package $pkg.  Please install $pkg
before installing BackupPC.

EOF
}

my %opts;
$opts{"set-perms"} = 1;
if ( !GetOptions(
            \%opts,
            "batch",
            "backuppc-user=s",
            "bin-path=s%",
            "cgi-dir=s",
            "compress-level=i",
            "config-path=s",
            "config-override=s%",
            "config-dir=s",
            "data-dir=s",
            "dest-dir=s",
            "fhs!",
            "help|?",
            "hostname=s",
            "html-dir=s",
            "html-dir-url=s",
            "install-dir=s",
            "log-dir=s",
            "man",
            "run-dir=s",
            "scgi-port=i",
            "set-perms!",
            "uid-ignore!",
        ) || @ARGV ) {
    pod2usage(2);
}
pod2usage(1) if ( $opts{help} );
pod2usage(-exitstatus => 0, -verbose => 2) if $opts{man};

my $DestDir = $opts{"dest-dir"};
$DestDir = "" if ( $DestDir eq "/" );

if ( !$opts{"uid-ignore"} && $< != 0 ) {
    print <<EOF;

This configure script should be run as root, rather than uid $<.
Provided uid $< has sufficient permissions to create the data and
install directories, then it should be ok to proceed.  Otherwise,
please quit and restart as root.

EOF
    exit(1) if ( prompt("--> Do you want to continue?",
                       "y") !~ /y/i );
    exit(1) if ( $opts{batch} && !$opts{"uid-ignore"} );
}

#
# Whether we use the file system hierarchy conventions or not.
# Older versions did not.  BackupPC used to be installed in
# two main directories (in addition to CGI and html pages)
#
#    TopDir       which includes subdirs conf, log, pc, pool, cpool
#                
#    InstallDir   which includes subdirs bin, lib, share/doc/BackupPC
#
# With FHS enabled (which is the default for new installations)
# the config files move to /etc/BackupPC and log files to /var/log:
#
#    /etc/BackupPC/config.pl  main config file (was $TopDir/conf/config.pl)
#    /etc/BackupPC/hosts      hosts file (was $TopDir/conf/hosts)
#    /etc/BackupPC/pc/HOST.pl per-pc config file (was $TopDir/pc/HOST/config.pl)
#    /var/log/BackupPC        log files (was $TopDir/log)
#    /var/log/BackupPC        Pid, status and email info (was $TopDir/log)
#

#
# Check if this is an upgrade, in which case read the existing
# config file to get all the defaults.
#
my $ConfigPath = "";
my $ConfigFileOK = 1;
while ( 1 ) {
    if ( $ConfigFileOK && -f "/etc/BackupPC/config.pl"
            && (!defined($opts{fhs}) || $opts{fhs}) && !defined($opts{"config-path"}) ) {
        $ConfigPath = "/etc/BackupPC/config.pl";
        $opts{fhs} = 1 if ( !defined($opts{fhs}) );
        print <<EOF;

Found /etc/BackupPC/config.pl, so this is an upgrade of an
existing BackupPC installation.  We will verify some existing
information, but you will probably not need to make any
changes - just hit ENTER to each question.
EOF
    } else {
        print <<EOF;

Is this a new installation or upgrade for BackupPC?  If this is
an upgrade please tell me the full path of the existing BackupPC
configuration file (eg: /etc/BackupPC/config.pl).  Otherwise, just
hit return.

EOF
        $ConfigPath = prompt("--> Full path to existing main config.pl",
                             $ConfigPath,
                             "config-path");
    }
    last if ( $ConfigPath eq ""
            || ($ConfigPath =~ /^\// && -f $ConfigPath && -w $ConfigPath) );
    my $problem = "is not an absolute path";
    $problem = "is not writable"        if ( !-w $ConfigPath );
    $problem = "is not readable"        if ( !-r $ConfigPath );
    $problem = "is not a regular file"  if ( !-f $ConfigPath );
    $problem = "doesn't exist"          if ( !-e $ConfigPath );
    print("The file '$ConfigPath' $problem.\n");
    if ( $opts{batch} ) {
        print("Need to specify a valid --config-path for upgrade\n");
        exit(1);
    }
    $ConfigFileOK = 0;
}
$opts{fhs} = 1 if ( !defined($opts{fhs}) && $ConfigPath eq "" );
$opts{fhs} = 0 if ( !defined($opts{fhs}) );

my $bpc;
if ( $ConfigPath ne "" && -r $ConfigPath ) {
    (my $confDir = $ConfigPath) =~ s{/[^/]+$}{};
    die("BackupPC::Lib->new failed\n")
            if ( !($bpc = BackupPC::Lib->new(".", ".", $confDir, 1)) );
    %Conf = $bpc->Conf();
    %OrigConf = %Conf;
    if ( !$opts{fhs} ) {
        ($Conf{TopDir} = $ConfigPath) =~ s{/[^/]+/[^/]+$}{}
                    if ( $Conf{TopDir} eq '' );
        $bpc->{LogDir} = $Conf{LogDir}  = "$Conf{TopDir}/log"
                    if ( $Conf{LogDir} eq '' );
        $bpc->{RunDir} = $Conf{RunDir}  = "$Conf{TopDir}/log"
                    if ( $Conf{RunDir} eq '' );
    }
    $bpc->{ConfDir} = $Conf{ConfDir} = $confDir;
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
# Create defaults for FHS setup
#
if ( $opts{fhs} ) {
    $Conf{TopDir}       ||= $opts{"data-dir"}    || "/data/BackupPC";
    $Conf{InstallDir}   ||= $opts{"install-dir"} || "/usr/local/BackupPC";
} else {
    $Conf{TopDir}       ||= $opts{"data-dir"}    || "/data/BackupPC";
    $Conf{InstallDir}   ||= $opts{"install-dir"} || "/usr/local/BackupPC";
}

#
# These are the programs whose paths we need to find
#
my %Programs = (
    perl           => "PerlPath",
    rsync_bpc      => "RsyncBackupPCPath",
    'gtar/tar'     => "TarClientPath",
    smbclient      => "SmbClientPath",
    nmblookup      => "NmbLookupPath",
    rsync          => "RsyncClientPath",
    ping           => "PingPath",
    df             => "DfPath",
    'ssh/ssh2'     => "SshPath",
    sendmail       => "SendmailPath",
    hostname       => "HostnamePath",
    split          => "SplitPath",
    par2           => "ParPath",
    cat            => "CatPath",
    gzip           => "GzipPath",
    bzip2          => "Bzip2Path",
    rrdtool        => "RrdToolPath",
);

foreach my $prog ( sort(keys(%Programs)) ) {
    my $path;
    foreach my $subProg ( split(/\//, $prog) ) {
        $path = FindProgram("$ENV{PATH}:/usr/bin:/bin:/sbin:/usr/sbin",
                            $subProg) if ( !length($path) );
    }
    $Conf{$Programs{$prog}} = $path if ( !length($Conf{$Programs{$prog}}) );
}

while ( 1 ) {
    print <<EOF;

I found the following locations for these programs:

EOF
    foreach my $prog ( sort(keys(%Programs)) ) {
        printf("    %-12s => %s\n", $prog, $Conf{$Programs{$prog}});
    }
    print "\n";
    last if (prompt('--> Are these paths correct?', 'y') =~ /^y/i);
    foreach my $prog ( sort(keys(%Programs)) ) {
        $Conf{$Programs{$prog}} = prompt("--> $prog path",
                                         $Conf{$Programs{$prog}});
    }
}

my $Perl58 = system($Conf{PerlPath}
                        . q{ -e 'exit($^V && $^V ge v5.8.0 ? 1 : 0);'});

if ( !$Perl58 ) {
    print <<EOF;

BackupPC needs perl version 5.8.0 or later.  $Conf{PerlPath} appears
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
$Conf{ServerHost} = prompt("--> BackupPC will run on host",
                           $Conf{ServerHost},
                           "hostname");

print <<EOF;

BackupPC should run as a dedicated user with limited privileges.  You
need to create a user.  This user will need read/write permission on
the main data directory and read/execute permission on the install
directory (these directories will be setup shortly).

The primary group for this user should also be chosen carefully.
The data directories and files will have group read permission,
so group members can access backup files.

EOF
my($name, $passwd, $Uid, $Gid);
while ( 1 ) {
    $Conf{BackupPCUser} = prompt("--> BackupPC should run as user",
                                 $Conf{BackupPCUser} || "backuppc",
                                 "backuppc-user");
    if ( $opts{"set-perms"} ) {
        ($name, $passwd, $Uid, $Gid) = getpwnam($Conf{BackupPCUser});
        last if ( $name ne "" );
        print <<EOF;

getpwnam() says that user $Conf{BackupPCUser} doesn't exist.  Please
check the name and verify that this user is in the passwd file.

EOF
        exit(1) if ( $opts{batch} );
    } else {
        last;
    }
}

print <<EOF;

Please specify an install directory for BackupPC.  This is where the
BackupPC scripts, library and documentation will be installed.

EOF

while ( 1 ) {
    $Conf{InstallDir} = prompt("--> Install directory (full path)",
                               $Conf{InstallDir},
                               "install-dir");
    last if ( $Conf{InstallDir} =~ /^\// );
    if ( $opts{batch} ) {
        print("Need to specify --install-dir for new installation\n");
        exit(1);
    }
}

print <<EOF;

Please specify a data directory for BackupPC.  This is where all the
PC backup data is stored.  This file system needs to be big enough to
accommodate all the PCs you expect to backup (eg: at least several GB
per machine).

EOF

while ( 1 ) {
    $Conf{TopDir} = prompt("--> Data directory (full path)",
                           $Conf{TopDir},
                           "data-dir");
    last if ( $Conf{TopDir} =~ /^\// );
    if ( $opts{batch} ) {
        print("Need to specify --data-dir for new installation\n");
        exit(1);
    }
}

if ( $opts{fhs} ) {
    $Conf{ConfDir}      ||= $opts{"config-dir"}  || "/etc/BackupPC";
    $Conf{LogDir}       ||= $opts{"log-dir"}     || "/var/log/BackupPC";
    $Conf{RunDir}       ||= $opts{"run-dir"}     || "/var/run/BackupPC";
} else {
    $Conf{ConfDir}      ||= $opts{"config-dir"}  || "$Conf{TopDir}/conf";
    $Conf{LogDir}       ||= $opts{"log-dir"}     || "$Conf{TopDir}/log";
    $Conf{RunDir}       ||= $opts{"run-dir"}     || "$Conf{TopDir}/log";
}

$Conf{CompressLevel} = $opts{"compress-level"}
                            if ( defined($opts{"compress-level"}) );

print <<EOF;

BackupPC has SCGI and CGI perl interfaces that run under Apache.  You need
to pick which one to run.

For SCGI, Apache uses the scgi_mod module to communicate with BackupPC_Admin_SCGI,
which handles the requests.  This allows Apache to run as a different user as
$Conf{BackupPCUser}.  To use SCGI you need to set SCGIServerPort to any spare
non-privileged TCP port number.  A negative value disables SCGI.

Important security warning!!  The SCGIServerPort must not be accessible by
anyone untrusted.  That means you can't allow untrusted users access to the
BackupPC server, and you should block the SCGIServerPort TCP port from
network access.

The traditional alternative is to use CGI.  In this case, an executable needs
to be installed Apache's cgi-bin directory.  This executable needs to run as
set-uid $Conf{BackupPCUser}, or it can be run under mod_perl with Apache
running as user $Conf{BackupPCUser}.

EOF

$Conf{SCGIServerPort} = prompt("--> SCGI port (-1 to disable)",
                               $Conf{SCGIServerPort} || -1,
                               "scgi-port");

if ( $Conf{SCGIServerPort} < 0 ) {
    while ( 1 ) {
        $Conf{CgiDir} = prompt("--> CGI bin directory (full path, or empty for no CGI)",
                               $Conf{CgiDir},
                               "cgi-dir");
        last if ( $Conf{CgiDir} =~ /^\// || $Conf{CgiDir} eq "" );
        if ( $opts{batch} ) {
            print("Need to specify --cgi-dir for new installation\n");
            exit(1);
        }
    }
} else {
    $Conf{CgiDir} = "";
}

if ( $Conf{SCGIServerPort} > 0 || $Conf{CgiDir} ne "" ) {
    print <<EOF;

BackupPC's CGI and SCGI script need to display various PNG/GIF
images that should be stored where Apache can serve them.  They
should be placed somewhere under Apache's DocumentRoot.  BackupPC
also needs to know the URL to access these images.  Example:

    Apache image directory:  /var/www/htdocs/BackupPC
    URL for image directory: /BackupPC

The URL for the image directory should start with a slash.

EOF
    while ( 1 ) {
        $Conf{CgiImageDir} = prompt("--> Apache image directory (full path, or empty for no S/CGI)",
                                    $Conf{CgiImageDir},
                                    "html-dir");
        last if ( $Conf{CgiImageDir} =~ /^\// || $Conf{CgiImageDir} eq "" );
        if ( $opts{batch} ) {
            print("Need to specify --html-dir for new installation\n");
            exit(1);
        }
    }
    while ( 1 ) {
        $Conf{CgiImageDirURL} = prompt("--> URL for image directory (omit http://host; starts with '/', or empty for no S/CGI)",
                                        $Conf{CgiImageDirURL},
                                        "html-dir-url");
        last if ( $Conf{CgiImageDirURL} =~ /^\// || $Conf{CgiImageDirURL} eq "" );
        if ( $opts{batch} ) {
            print("Need to specify --html-dir-url for new installation\n");
            exit(1);
        }
    }
}

print <<EOF;

Ok, we're about to:

  - install the binaries, lib and docs in $Conf{InstallDir},
  - create the data directory $Conf{TopDir},
  - create/update the config.pl file $Conf{ConfDir}/config.pl,
  - optionally install the cgi-bin interface.

EOF

exit unless prompt("--> Do you want to continue?", "y") =~ /y/i;

#
# Create install directories
#
foreach my $dir ( qw(bin share/doc/BackupPC
		     lib/BackupPC/CGI
		     lib/BackupPC/Config
		     lib/BackupPC/Lang
		     lib/BackupPC/Storage
		     lib/BackupPC/Xfer
		     lib/BackupPC/Zip
                     lib/Net/FTP
		 ) ) {
    next if ( -d "$DestDir$Conf{InstallDir}/$dir" );
    mkpath("$DestDir$Conf{InstallDir}/$dir", 0, 0755);
    if ( !-d "$DestDir$Conf{InstallDir}/$dir"
            || !my_chown($Uid, $Gid, "$DestDir$Conf{InstallDir}/$dir") ) {
        die("Failed to create or chown $DestDir$Conf{InstallDir}/$dir\n");
    } else {
        print("Created $DestDir$Conf{InstallDir}/$dir\n");
    }
}

#
# Create CGI image directory
#
foreach my $dir ( ($Conf{CgiImageDir}) ) {
    next if ( $dir eq "" || -d "$DestDir$dir" );
    mkpath("$DestDir$dir", 0, 0755);
    if ( !-d "$DestDir$dir" || !my_chown($Uid, $Gid, "$DestDir$dir") ) {
        die("Failed to create or chown $DestDir$dir");
    } else {
        print("Created $DestDir$dir\n");
    }
}

#
# Create other directories
#
foreach my $dir ( (
            "$Conf{TopDir}",
            "$Conf{TopDir}/pool",
            "$Conf{TopDir}/cpool",
            "$Conf{TopDir}/pc",
            "$Conf{ConfDir}",
            "$Conf{LogDir}",
            "$Conf{RunDir}",
        ) ) {
    mkpath("$DestDir$dir", 0, 0750) if ( !-d "$DestDir$dir" );
    if ( !-d "$DestDir$dir"
            || !my_chown($Uid, $Gid, "$DestDir$dir") ) {
        die("Failed to create or chown $DestDir$dir\n");
    } else {
        print("Created $DestDir$dir\n");
    }
}

printf("Installing binaries in $DestDir$Conf{InstallDir}/bin\n");
foreach my $prog ( qw(
        bin/BackupPC
        bin/BackupPC_Admin_SCGI
        bin/BackupPC_archive
        bin/BackupPC_archiveHost
        bin/BackupPC_archiveStart
        bin/BackupPC_attribPrint
        bin/BackupPC_backupDelete
        bin/BackupPC_backupDuplicate
        bin/BackupPC_dump
        bin/BackupPC_fixupBackupSummary
        bin/BackupPC_fsck
        bin/BackupPC_ls
        bin/BackupPC_nightly
        bin/BackupPC_poolCntPrint
        bin/BackupPC_refCountUpdate
        bin/BackupPC_restore
        bin/BackupPC_rrdUpdate
        bin/BackupPC_sendEmail
        bin/BackupPC_serverMesg
        bin/BackupPC_tarCreate
        bin/BackupPC_tarExtract
        bin/BackupPC_zcat
        bin/BackupPC_zipCreate
    ) ) {
    InstallFile($prog, "$DestDir$Conf{InstallDir}/$prog", 0555);
}

#
# remove old pre-v4 programs
#
foreach my $prog ( qw(
        bin/BackupPC_link
        bin/BackupPC_tarPCCopy
        bin/BackupPC_trashClean
        bin/BackupPC_compressPool
    ) ) {
    unlink("$DestDir$Conf{InstallDir}/$prog");
}

printf("Installing library in $DestDir$Conf{InstallDir}/lib\n");
foreach my $lib ( qw(
        lib/BackupPC/Config/Meta.pm
        lib/BackupPC/DirOps.pm
        lib/BackupPC/Lib.pm
        lib/BackupPC/Storage.pm
        lib/BackupPC/View.pm
        lib/BackupPC/Xfer/Archive.pm
        lib/BackupPC/Xfer/Ftp.pm
        lib/BackupPC/Xfer/Protocol.pm
        lib/BackupPC/Xfer/Rsync.pm
        lib/BackupPC/Xfer/Smb.pm
        lib/BackupPC/Xfer/Tar.pm
        lib/BackupPC/Xfer.pm
        lib/BackupPC/Zip/FileMember.pm
        lib/Net/FTP/AutoReconnect.pm
        lib/Net/FTP/RetrHandle.pm
        lib/BackupPC/CGI/AdminOptions.pm
        lib/BackupPC/CGI/Archive.pm
        lib/BackupPC/CGI/ArchiveInfo.pm
        lib/BackupPC/CGI/Browse.pm
        lib/BackupPC/CGI/DirHistory.pm
        lib/BackupPC/CGI/EditConfig.pm
        lib/BackupPC/CGI/EmailSummary.pm
        lib/BackupPC/CGI/GeneralInfo.pm
        lib/BackupPC/CGI/HostInfo.pm
        lib/BackupPC/CGI/Lib.pm
        lib/BackupPC/CGI/LOGlist.pm
        lib/BackupPC/CGI/Queue.pm
        lib/BackupPC/CGI/ReloadServer.pm
        lib/BackupPC/CGI/Restore.pm
        lib/BackupPC/CGI/RestoreFile.pm
        lib/BackupPC/CGI/RestoreInfo.pm
        lib/BackupPC/CGI/RSS.pm
        lib/BackupPC/CGI/StartServer.pm
        lib/BackupPC/CGI/StartStopBackup.pm
        lib/BackupPC/CGI/StopServer.pm
        lib/BackupPC/CGI/Summary.pm
        lib/BackupPC/CGI/View.pm
        lib/BackupPC/Lang/cz.pm
        lib/BackupPC/Lang/de.pm
        lib/BackupPC/Lang/en.pm
        lib/BackupPC/Lang/es.pm
        lib/BackupPC/Lang/fr.pm
        lib/BackupPC/Lang/it.pm
        lib/BackupPC/Lang/ja.pm
        lib/BackupPC/Lang/nl.pm
        lib/BackupPC/Lang/pl.pm
        lib/BackupPC/Lang/pt_br.pm
        lib/BackupPC/Lang/ru.pm
        lib/BackupPC/Lang/uk.pm
        lib/BackupPC/Lang/zh_CN.pm
        lib/BackupPC/Storage/Text.pm
    ) ) {
    InstallFile($lib, "$DestDir$Conf{InstallDir}/$lib", 0444);
}

#
# remove old pre-v4 libraries
#
foreach my $lib ( qw(
        lib/BackupPC/Attrib.pm
        lib/BackupPC/Config.pm
        lib/BackupPC/FileZIO.pm
        lib/BackupPC/PoolWrite.pm
        lib/BackupPC/Xfer/RsyncDigest.pm
        lib/BackupPC/Xfer/RsyncFileIO.pm
    ) ) {
    unlink("$DestDir$Conf{InstallDir}/$lib");
}

#
# clean pid and sock files from old location (they are now in $Conf{RunDir}, and they
# get re-created each time BackupPC starts, so it's ok if RunDir eq LogDir).
#
unlink("$DestDir$Conf{LogDir}/BackupPC.pid")  if ( -f "$DestDir$Conf{LogDir}/BackupPC.pid" );
unlink("$DestDir$Conf{LogDir}/BackupPC.sock") if ( -e "$DestDir$Conf{LogDir}/BackupPC.sock" );

if ( $Conf{CgiImageDir} ne "" ) {
    printf("Installing images in $DestDir$Conf{CgiImageDir}\n");
    foreach my $img ( <images/*> ) {
	(my $destImg = $img) =~ s{^images/}{};
	InstallFile($img, "$DestDir$Conf{CgiImageDir}/$destImg", 0444, 1);
    }

    #
    # Install new CSS file, making a backup copy if necessary
    #
    my $cssBackup = "$DestDir$Conf{CgiImageDir}/BackupPC_stnd.css.pre-4.0.0alpha3";
    if ( -f "$DestDir$Conf{CgiImageDir}/BackupPC_stnd.css" && !-f $cssBackup ) {
	rename("$DestDir$Conf{CgiImageDir}/BackupPC_stnd.css", $cssBackup);
    }
    InstallFile("conf/BackupPC_stnd.css",
	        "$DestDir$Conf{CgiImageDir}/BackupPC_stnd.css", 0444, 0);
    InstallFile("conf/BackupPC_stnd_orig.css",
	        "$DestDir$Conf{CgiImageDir}/BackupPC_stnd_orig.css", 0444, 0);
    InstallFile("conf/sorttable.js",
                "$DestDir$Conf{CgiImageDir}/sorttable.js", 0444, 0);
}

printf("Making init.d scripts\n");
foreach my $init ( qw(gentoo-backuppc gentoo-backuppc.conf linux-backuppc
		      solaris-backuppc debian-backuppc freebsd-backuppc
                      freebsd-backuppc2 suse-backuppc slackware-backuppc ) ) {
    InstallFile("init.d/src/$init", "init.d/$init", 0444);
}

printf("Making Apache configuration file for suid-perl\n");
InstallFile("httpd/src/BackupPC.conf", "httpd/BackupPC.conf", 0644);

printf("Installing docs in $DestDir$Conf{InstallDir}/share/doc/BackupPC\n");
foreach my $doc ( qw(BackupPC.pod BackupPC.html) ) {
    InstallFile("doc/$doc", "$DestDir$Conf{InstallDir}/share/doc/BackupPC/$doc", 0444);
    #
    # clean up files from old directory
    #
    unlink("$DestDir$Conf{InstallDir}/doc/$doc") if ( -f "$DestDir$Conf{InstallDir}/doc/$doc" );
}
#
# clean up old directory (ok if it quietly fails if there are other files in that directory)
#
rmdir("$DestDir$Conf{InstallDir}/doc") if ( -d "$DestDir$Conf{InstallDir}/doc" );

printf("Installing config.pl and hosts in $DestDir$Conf{ConfDir}\n");
InstallFile("conf/hosts", "$DestDir$Conf{ConfDir}/hosts", 0644)
                    if ( !-f "$DestDir$Conf{ConfDir}/hosts" );

#
# Now do the config file.  If there is an existing config file we
# merge in the new config file, adding any new configuration
# parameters and deleting ones that are no longer needed.
#
my $dest = "$DestDir$Conf{ConfDir}/config.pl";
my ($distConf, $distVars) = ConfigParse("conf/config.pl");
my ($oldConf, $oldVars);
my ($newConf, $newVars) = ($distConf, $distVars);
if ( -f $dest ) {
    ($oldConf, $oldVars) = ConfigParse($dest);
    ($newConf, $newVars) = ConfigMerge($oldConf, $oldVars, $distConf, $distVars);
}

#
# Update various config parameters.  The old config is in Conf{}
# and the new config is an array in text form in $newConf->[].
#
$Conf{EMailFromUserName}  ||= $Conf{BackupPCUser};
$Conf{EMailAdminUserName} ||= $Conf{BackupPCUser};

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
# CSS is now stored in a file rather than a big config variable.
#
delete($Conf{CSSstylesheet});

#
# The blackout timing settings are now stored in a list of hashes, rather
# than three scalar parameters.
#
if ( defined($Conf{BlackoutHourBegin}) ) {
    $Conf{BlackoutPeriods} = [
	 {
	     hourBegin => $Conf{BlackoutHourBegin},
	     hourEnd   => $Conf{BlackoutHourEnd},
	     weekDays  => $Conf{BlackoutWeekDays},
	 } 
    ];
    delete($Conf{BlackoutHourBegin});
    delete($Conf{BlackoutHourEnd});
    delete($Conf{BlackoutWeekDays});
}

#
# $Conf{RsyncLogLevel} has been replaced by $Conf{XferLogLevel}
#
if ( defined($Conf{RsyncLogLevel}) ) {
    $Conf{XferLogLevel} = $Conf{RsyncLogLevel};
    delete($Conf{RsyncLogLevel});
}

#
# Since 2.1.0 the default for $Conf{CgiNavBarAdminAllHosts} is now 1
#
$Conf{CgiNavBarAdminAllHosts} = 1;

#
# Empty $Conf{ParPath} if it isn't a valid executable
# (pre-3.0.0 configure.pl incorrectly set it to a
# hardcoded value).
#
$Conf{ParPath} = '' if ( $Conf{ParPath} ne '' && !-x $Conf{ParPath} );

#
# Figure out sensible arguments for the ping command
#
if ( defined($Conf{PingArgs}) ) {
    $Conf{PingCmd} = '$pingPath ' . $Conf{PingArgs};
} elsif ( !defined($Conf{PingCmd}) ) {
    if ( $^O eq "solaris" || $^O eq "sunos" ) {
	$Conf{PingCmd} = '$pingPath -s $host 56 1';
    } elsif ( ($^O eq "linux" || $^O eq "openbsd" || $^O eq "netbsd")
	    && !system("$Conf{PingPath} -c 1 -w 3 localhost") ) {
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

#
# Replace --devices with -D in RsyncArgs and RsyncRestoreArgs
#
foreach my $param ( qw(RsyncArgs RsyncRestoreArgs) ) {
    next if ( !defined($newVars->{$param}) );
    $newConf->[$newVars->{$param}]{text} =~ s/--devices/-D/g;
}

#
# Merge any new user-editable parameters into CgiUserConfigEdit
# by copying the old settings forward.
#
if ( defined($Conf{CgiUserConfigEdit}) ) {
    #
    # This is a real hack.  The config file merging is done in text
    # form without actually instantiating the new conf structure.
    # So we need to extract the new hash of settings, update it,
    # and merge the text.  Ugh...
    #
    my $new;
    my $str = $distConf->[$distVars->{CgiUserConfigEdit}]{text};

    $str =~ s/^\s*\$Conf\{.*?\}\s*=\s*/\$new = /m;
    eval($str);
    foreach my $p ( keys(%$new) ) {
        $new->{$p} = $Conf{CgiUserConfigEdit}{$p}
                if ( defined($Conf{CgiUserConfigEdit}{$p}) );
    }
    $Conf{CgiUserConfigEdit} = $new;
    my $d = Data::Dumper->new([$new], [*value]);
    $d->Indent(1);
    $d->Terse(1);
    my $value = $d->Dump;
    $value =~ s/(.*)\n/$1;\n/s;
    $newConf->[$newVars->{CgiUserConfigEdit}]{text}
            =~ s/(\s*\$Conf\{.*?\}\s*=\s*).*/$1$value/s;
}

#
# If it exists, use $Conf{RsyncClientCmd} to create the default $Conf{RsyncSshArgs}.
#
if ( $Conf{RsyncClientCmd} =~ /(\$sshPath.* +-l +\S+)/ && defined($newVars->{RsyncSshArgs}) ) {
    my $value = "[\n    '-e', '$1',\n];\n\n";
    $newConf->[$newVars->{RsyncSshArgs}]{text}
            =~ s/(\s*\$Conf\{RsyncSshArgs}\s*=\s*).*/$1$value/s;
}

#
# Overwrite $Conf{RsyncArgs} and $Conf{RsyncRestoreArgs}.
#
$newConf->[$newVars->{RsyncArgs}]{text}        = $distConf->[$distVars->{RsyncArgs}]{text};
$newConf->[$newVars->{RsyncRestoreArgs}]{text} = $distConf->[$distVars->{RsyncRestoreArgs}]{text};

#
# If this is an upgrade from V3, then set $Conf{PoolV3Enabled}
#
$Conf{PoolV3Enabled} = 1 if ( defined($Conf{ServerHost}) && !defined($Conf{PoolV3Enabled}) );

#
# Apply any command-line configuration parameter settings
#
foreach my $param ( keys(%{$opts{"config-override"}}) ) {
    my $value = $opts{"config-override"}{$param};
    my $val = eval { $value };
    if ( @$ ) {
        printf("Can't eval --config-override setting %s=%s\n",
                        $param, $opts{"config-override"}{$param});
        exit(1);
    }
    if ( !defined($newVars->{$param}) ) {
        printf("Unkown config parameter %s in --config-override\n", $param);
        exit(1);
    }
    $value .= ";\n\n";
    $newConf->[$newVars->{$param}]{text}
            =~ s/(\s*\$Conf\{$param}\s*=\s*).*/$1$value/s;
}

#
# Now backup and write the config file
#
my $confCopy = "$dest.pre-4.0.0alpha3";
if ( -f $dest && !-f $confCopy ) {
    #
    # Make copy of config file, preserving ownership and modes
    #
    printf("Making backup copy of $dest -> $confCopy\n");
    my @stat = stat($dest);
    my $mode = $stat[2];
    my $uid  = $stat[4];
    my $gid  = $stat[5];
    die("can't copy($dest, $confCopy)\n")
                                unless copy($dest, $confCopy);
    die("can't chown $uid, $gid $confCopy\n")
                                unless my_chown($uid, $gid, $confCopy);
    die("can't chmod $mode $confCopy\n")
                                unless my_chmod($mode, $confCopy);
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
    die("can't chmod 0640 mode $dest\n")  unless my_chmod(0640, $dest);
    die("can't chown $Uid, $Gid $dest\n") unless my_chown($Uid, $Gid, $dest);
}

if ( $Conf{CgiDir} ne "" ) {
    printf("Installing cgi script BackupPC_Admin in $DestDir$Conf{CgiDir}\n");
    mkpath("$DestDir$Conf{CgiDir}", 0, 0755);
    InstallFile("cgi-bin/BackupPC_Admin", "$DestDir$Conf{CgiDir}/BackupPC_Admin",
                04554);
}

print <<EOF;

Ok, it looks like we are finished.  There are several more things you
will need to do:

  - Browse through the config file, $Conf{ConfDir}/config.pl,
    and make sure all the settings are correct.  In particular,
    you will need to set \$Conf{CgiAdminUsers} so you have
    administration privileges in the CGI interface.

  - Edit the list of hosts to backup in $Conf{ConfDir}/hosts.

  - Read the documentation in $Conf{InstallDir}/doc/BackupPC.html.
    Please pay special attention to the security section.

  - Verify that the CGI script BackupPC_Admin runs correctly.  You might
    need to change the permissions or group ownership of BackupPC_Admin.
    If this is an upgrade and you are using mod_perl, you will need
    to restart Apache.  Otherwise it will have stale code.

  - BackupPC should be ready to start.  Don't forget to run it
    as user $Conf{BackupPCUser}!  The installation also contains an
    init.d/backuppc script that can be copied to /etc/init.d
    so that BackupPC can auto-start on boot.  This will also enable
    administrative users to start the server from the CGI interface.
    See init.d/README.

Enjoy!
EOF

if ( `$Conf{PerlPath} -V` =~ /uselargefiles=undef/ ) {
    print <<EOF;

Warning: your perl, $Conf{PerlPath}, does not support large files.
This means BackupPC won't be able to backup files larger than 2GB.
To solve this problem you should build/install a new version of perl
with large file support enabled.  Use

    $Conf{PerlPath} -V | egrep uselargefiles

to check if perl has large file support (undef means no support).
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
	    s/__LOGDIR__/$Conf{LogDir}/g;
	    s/__RUNDIR__/$Conf{RunDir}/g;
	    s/__CONFDIR__/$Conf{ConfDir}/g;
	    s/__TOPDIR__/$Conf{TopDir}/g;
            s/^(\s*my \$useFHS\s*=\s*)\d;/${1}$opts{fhs};/
                                    if ( $prog =~ /Lib.pm/ );
	    s/__BACKUPPCUSER__/$Conf{BackupPCUser}/g;
	    s/__CGIDIR__/$Conf{CgiDir}/g;
            s/__IMAGEDIR__/$Conf{CgiImageDir}/g;
            s/__IMAGEDIRURL__/$Conf{CgiImageDirURL}/g;
	    if ( $first && /^#.*bin\/perl/ ) {
		#
		# Fill in correct path to perl (no taint for >= 2.0.1).
		#
		print OUT "#!$Conf{PerlPath}\n";
	    } else {
		print OUT;
	    }
	    $first = 0;
	}
	close(PROG);
	close(OUT);
    }
    die("can't chown $uid, $gid $dest") unless my_chown($uid, $gid, $dest);
    die("can't chmod $mode $dest")      unless my_chmod($mode, $dest);
}

sub FindProgram
{
    my($path, $prog) = @_;

    if ( defined($opts{"bin-path"}{$prog}) ) {
        return $opts{"bin-path"}{$prog};
    }
    foreach my $dir ( split(/:/, $path) ) {
        my $file = File::Spec->catfile($dir, $prog);
        return $file if ( -x $file );
    }
    return;
}

sub ConfigParse
{
    my($file) = @_;
    open(C, $file) || die("can't open $file");
    binmode(C);
    my($out, @conf, $var);
    my $comment = 1;
    my $allVars = {};
    my $endLine = undef;
    while ( <C> ) {
        if ( /^#/ && !defined($endLine) ) {
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
	    $endLine = $1 if ( /^\s*\$Conf\{[^}]*} *= *<<(.*);/ );
	    $endLine = $1 if ( /^\s*\$Conf\{[^}]*} *= *<<'(.*)';/ );
        } else {
	    $endLine = undef if ( defined($endLine) && /^\Q$endLine\E[\n\r]*$/ );
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
    my($res, $resVars);

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
    for ( my $i = 0 ; $i < @$res ; $i++ ) {
        $resVars->{$res->[$i]{var}} = $i;
    }
    return ($res, $resVars);
}

sub my_chown
{
    my($uid, $gid, $file) = @_;

    return 1 if ( !$opts{"set-perms"} );
    return chown($uid, $gid, $file);
}

sub my_chmod
{
    my ($mode, $file) = @_;

    return 1 if ( !$opts{"set-perms"} );
    return chmod($mode, $file);
}

sub prompt
{
    my($question, $default, $option) = @_;

    $default = $opts{$option} if ( defined($opts{$option}) );
    if ( $opts{batch} ) {
        print("$question [$default]\n");
        return $default;
    }
    print("$question [$default]? ");
    my $reply = <STDIN>;
    $reply =~ s/[\n\r]*//g;
    return $reply if ( $reply !~ /^$/ );
    return $default;
}

__END__

=head1 SYNOPSIS

configure.pl [options]

=head1 DESCRIPTION

configure.pl is a script that is used to install or upgrade a BackupPC
installation.  It is usually run interactively without arguments.  It
also supports a batch mode where all the options can be specified
via the command-line.

For upgrading BackupPC you need to make sure that BackupPC is not
running prior to running BackupPC.

Typically configure.pl needs to run as the super user (root).

=head1 OPTIONS

=over 8

=item B<--batch>

Run configure.pl in batch mode.  configure.pl will run without
prompting the user.  The other command-line options are used
to specify the settings that the user is usually prompted for.

=item B<--backuppc-user=USER>

Specify the BackupPC user name that owns all the BackupPC
files and runs the BackupPC programs.  Default is backuppc.

=item B<--bin-path PROG=PATH>

Specify the path for various external programs that BackupPC
uses.  Several --bin-path options may be specified.  configure.pl
usually finds sensible defaults based on searching the PATH.
The format is:

    --bin-path PROG=PATH

where PROG is one of perl, tar, smbclient, nmblookup, rsync, ping,
df, ssh, sendmail, hostname, split, par2, cat, gzip, bzip2 and
PATH is that full path to that program.

Examples

    --bin-path cat=/bin/cat --bin-path bzip2=/home/user/bzip2

=item B<--compress-level=N>

Set the configuration compression level to N.  Default is 3.

=item B<--config-dir CONFIG_DIR>

Configuration directory for new installations.  Defaults
to /etc/BackupPC with FHS.  Automatically extracted
from --config-path for existing installations.

=item B<--config-override name=value>

Override a specific configuration parameter.  Can be specified multiple
times.  "Name" is the parameter name and "value" is the exact text that
is inserted in the config.pl file (so you will need to escape quotes etc).
For example, to override $Conf{ServerHost} you would specify:

    --config-override ServerHost=\"myhost\"

=item B<--config-path CONFIG_PATH>

Path to the existing config.pl configuration file for BackupPC.
This option should be specified for batch upgrades to an
existing installation.  The option should be omitted when
doing a batch new install.

=item B<--cgi-dir CGI_DIR>

Path to Apache's cgi-bin directory where the BackupPC_Admin
script will be installed.  This option only needs to be
specified for a batch new install.

=item B<--scgi-port N>

Numeric TCP port that is used for communication between Apache
and BackupPC_Admin_SCGI.  A negative value disables SCGI.

=item B<--data-dir DATA_DIR>

Path to the BackupPC data directory.  This is where all the backup
data is stored, and it should be on a large file system. This option
only needs to be specified for a batch new install.

Example:

    --data-dir /data/BackupPC

=item B<--dest-dir DEST_DIR>

An optional prefix to apply to all installation directories.
Usually this is not needed, but certain auto-installers like
to stage an install in a temporary directory, and then copy
the files to their real destination.  This option can be used
to specify the temporary directory prefix.  Note that if you
specify this option, BackupPC won't run correctly if you try
to run it from below the --dest-dir directory, since all the
paths are set assuming BackupPC is installed in the intended
final locations.

=item B<--fhs>

Use locations specified by the Filesystem Hierarchy Standard
for installing BackupPC.  This is enabled by default for new
installations.  To use the pre-3.0 installation locations,
specify --no-fhs.

=item B<--help|?>

Print a brief help message and exits.

=item B<--hostname HOSTNAME>

Host name (this machine's name) on which BackupPC is being installed.
This option only needs to be specified for a batch new install.

=item B<--html-dir HTML_DIR>

Path to an Apache html directory where various BackupPC image files
and the CSS files will be installed.  This is typically a directory
below Apache's DocumentRoot directory.  This option only needs to be
specified for a batch new install.

Example:

    --html-dir /var/www/htdocs/BackupPC

=item B<--html-dir-url URL>

The URL (without http://hostname) required to access the BackupPC html
directory specified with the --html-dir option.  This option only needs
to be specified for a batch new install.

Example:

    --html-dir-url /BackupPC

=item B<--install-dir INSTALL_DIR>

Installation directory for BackupPC scripts, libraries, and
documentation.  This option only needs to be specified for a
batch new install.

Example:

    --install-dir /usr/local/BackupPC

=item B<--log-dir LOG_DIR>

Log directory.  Defaults to /var/log/BackupPC with FHS.

=item B<--man>

Prints the manual page and exits.

=item B<--run-dir RUN_DIR>

Run directory.  Defaults to /var/run/BackupPC with FHS.

=item B<--set-perms>

When installing files and creating directories, chown them to
the BackupPC user and chmod them too.  This is enabled by default.
To disable (for example, if staging a destination directory)
then specify --no-set-perms.

=item B<--uid-ignore>

configure.pl verifies that the script is being run as the super user
(root).  Without the --uid-ignore option, in batch mode the script will
exit with an error if not run as the super user, and in interactive mode
the user will be prompted.  Specifying this option will cause the script
to continue even if the user id is not root.

=head1 EXAMPLES

For a standard interactive install, run without arguments:

    configure.pl

For a batch new install you need to specify answers to all the
questions that are normally prompted:

    configure.pl                                   \
        --batch                                    \
        --cgi-dir /var/www/cgi-bin/BackupPC        \
        --data-dir /data/BackupPC                  \
        --hostname myHost                          \
        --html-dir /var/www/html/BackupPC          \
        --html-dir-url /BackupPC                   \
        --install-dir /usr/local/BackupPC

For a batch upgrade, you only need to specify the path to the
configuration file:
        
    configure.pl --batch --config-path /data/BackupPC/conf/config.pl

=head1 AUTHOR

Craig Barratt <cbarratt@users.sourceforge.net>

=head1 COPYRIGHT

Copyright (C) 2001-2010  Craig Barratt.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

=cut
