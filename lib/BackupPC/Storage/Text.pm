#============================================================= -*-perl-*-
#
# BackupPC::Storage::Text package
#
# DESCRIPTION
#
#   This library defines a BackupPC::Storage::Text class that implements
#   BackupPC's persistent state storage (config, host info, backup
#   and restore info) using text files.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2004  Craig Barratt
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
# Version 2.1.0, released 20 Jun 2004.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

package BackupPC::Storage::Text;

use strict;
use vars qw(%Conf);
use Data::Dumper;
use Fcntl qw/:flock/;

sub new
{
    my $class = shift;
    my($flds, $paths) = @_;

    my $s = bless {
	%$flds,
	%$paths,
    }, $class;
    return $s;
}

sub BackupInfoRead
{
    my($s, $host) = @_;
    local(*BK_INFO, *LOCK);
    my(@Backups);

    flock(LOCK, LOCK_EX) if open(LOCK, "$s->{TopDir}/pc/$host/LOCK");
    if ( open(BK_INFO, "$s->{TopDir}/pc/$host/backups") ) {
	binmode(BK_INFO);
        while ( <BK_INFO> ) {
            s/[\n\r]+//;
            next if ( !/^(\d+\t(incr|full|partial)[\d\t]*$)/ );
            $_ = $1;
            @{$Backups[@Backups]}{@{$s->{BackupFields}}} = split(/\t/);
        }
        close(BK_INFO);
    }
    close(LOCK);
    return @Backups;
}

sub BackupInfoWrite
{
    my($s, $host, @Backups) = @_;
    local(*BK_INFO, *LOCK);
    my($i);

    flock(LOCK, LOCK_EX) if open(LOCK, "$s->{TopDir}/pc/$host/LOCK");
    if ( -s "$s->{TopDir}/pc/$host/backups" ) {
	unlink("$s->{TopDir}/pc/$host/backups.old")
		    if ( -f "$s->{TopDir}/pc/$host/backups.old" );
	rename("$s->{TopDir}/pc/$host/backups",
	       "$s->{TopDir}/pc/$host/backups.old")
		    if ( -f "$s->{TopDir}/pc/$host/backups" );
    }
    if ( open(BK_INFO, ">$s->{TopDir}/pc/$host/backups") ) {
	binmode(BK_INFO);
        for ( $i = 0 ; $i < @Backups ; $i++ ) {
            my %b = %{$Backups[$i]};
            printf(BK_INFO "%s\n", join("\t", @b{@{$s->{BackupFields}}}));
        }
        close(BK_INFO);
    }
    close(LOCK);
}

sub RestoreInfoRead
{
    my($s, $host) = @_;
    local(*RESTORE_INFO, *LOCK);
    my(@Restores);

    flock(LOCK, LOCK_EX) if open(LOCK, "$s->{TopDir}/pc/$host/LOCK");
    if ( open(RESTORE_INFO, "$s->{TopDir}/pc/$host/restores") ) {
	binmode(RESTORE_INFO);
        while ( <RESTORE_INFO> ) {
            s/[\n\r]+//;
            next if ( !/^(\d+.*)/ );
            $_ = $1;
            @{$Restores[@Restores]}{@{$s->{RestoreFields}}} = split(/\t/);
        }
        close(RESTORE_INFO);
    }
    close(LOCK);
    return @Restores;
}

sub RestoreInfoWrite
{
    my($s, $host, @Restores) = @_;
    local(*RESTORE_INFO, *LOCK);
    my($i);

    flock(LOCK, LOCK_EX) if open(LOCK, "$s->{TopDir}/pc/$host/LOCK");
    if ( -s "$s->{TopDir}/pc/$host/restores" ) {
	unlink("$s->{TopDir}/pc/$host/restores.old")
		    if ( -f "$s->{TopDir}/pc/$host/restores.old" );
	rename("$s->{TopDir}/pc/$host/restores",
	       "$s->{TopDir}/pc/$host/restores.old")
		    if ( -f "$s->{TopDir}/pc/$host/restores" );
    }
    if ( open(RESTORE_INFO, ">$s->{TopDir}/pc/$host/restores") ) {
	binmode(RESTORE_INFO);
        for ( $i = 0 ; $i < @Restores ; $i++ ) {
            my %b = %{$Restores[$i]};
            printf(RESTORE_INFO "%s\n",
                        join("\t", @b{@{$s->{RestoreFields}}}));
        }
        close(RESTORE_INFO);
    }
    close(LOCK);
}

sub ArchiveInfoRead
{
    my($s, $host) = @_;
    local(*ARCHIVE_INFO, *LOCK);
    my(@Archives);

    flock(LOCK, LOCK_EX) if open(LOCK, "$s->{TopDir}/pc/$host/LOCK");
    if ( open(ARCHIVE_INFO, "$s->{TopDir}/pc/$host/archives") ) {
        binmode(ARCHIVE_INFO);
        while ( <ARCHIVE_INFO> ) {
            s/[\n\r]+//;
            next if ( !/^(\d+.*)/ );
            $_ = $1;
            @{$Archives[@Archives]}{@{$s->{ArchiveFields}}} = split(/\t/);
        }
        close(ARCHIVE_INFO);
    }
    close(LOCK);
    return @Archives;
}

sub ArchiveInfoWrite
{
    my($s, $host, @Archives) = @_;
    local(*ARCHIVE_INFO, *LOCK);
    my($i);

    flock(LOCK, LOCK_EX) if open(LOCK, "$s->{TopDir}/pc/$host/LOCK");
    if ( -s "$s->{TopDir}/pc/$host/archives" ) {
	unlink("$s->{TopDir}/pc/$host/archives.old")
		    if ( -f "$s->{TopDir}/pc/$host/archives.old" );
	rename("$s->{TopDir}/pc/$host/archives",
	       "$s->{TopDir}/pc/$host/archives.old")
		    if ( -f "$s->{TopDir}/pc/$host/archives" );
    }
    if ( open(ARCHIVE_INFO, ">$s->{TopDir}/pc/$host/archives") ) {
        binmode(ARCHIVE_INFO);
        for ( $i = 0 ; $i < @Archives ; $i++ ) {
            my %b = %{$Archives[$i]};
            printf(ARCHIVE_INFO "%s\n",
                        join("\t", @b{@{$s->{ArchiveFields}}}));
        }
        close(ARCHIVE_INFO);
    }
    close(LOCK);
}

sub ConfigDataRead
{
    my($s, $host) = @_;
    my($ret, $mesg, $config, @configs);

    #
    # TODO: add lock
    #
    my $conf = {};

    if ( defined($host) ) {
	push(@configs, "$s->{TopDir}/conf/$host.pl")
		if ( $host ne "config" && -f "$s->{TopDir}/conf/$host.pl" );
	push(@configs, "$s->{TopDir}/pc/$host/config.pl")
		if ( -f "$s->{TopDir}/pc/$host/config.pl" );
    } else {
	push(@configs, "$s->{TopDir}/conf/config.pl");
    }
    foreach $config ( @configs ) {
        %Conf = ();
        if ( !defined($ret = do $config) && ($! || $@) ) {
            $mesg = "Couldn't open $config: $!" if ( $! );
            $mesg = "Couldn't execute $config: $@" if ( $@ );
            $mesg =~ s/[\n\r]+//;
            return ($mesg, $conf);
        }
        %$conf = ( %$conf, %Conf );
    }
    return (undef, $conf);
}

sub ConfigDataWrite
{
    my($s, $host, $newConf) = @_;

    my($confPath) = $host eq "" ? "$s->{TopDir}/conf/config.pl"
				: "$s->{TopDir}/pc/$host/config.pl";

    my $err = $s->ConfigFileMerge($confPath, "$confPath.new", $newConf);
    #
    # TODO: add lock and rename
    #
}

sub ConfigFileMerge
{
    my($s, $inFile, $outFile, $newConf) = @_;

    open(C, $inFile) || return "ConfigFileMerge: can't open/read $inFile";
    binmode(C);

    open(OUT, ">", $outFile)
		     || return "ConfigFileMerge: can't open/write $outFile";
    binmode(OUT);

    my($out);
    my $comment = 1;
    my $skipVar = 0;
    my $endLine = undef;
    my $done = {};

    while ( <C> ) {
	if ( $comment && /^\s*#/ ) {
	    $out .= $_;
	} elsif ( /^\s*\$Conf\{([^}]*)\}\s*=/ ) {
	    my $var = $1;
	    if ( exists($newConf->{$var}) ) { 
		print OUT $out;
		my $d = Data::Dumper->new([$newConf->{$var}], [*value]);
		$d->Indent(1);
		$d->Terse(1);
		my $value = $d->Dump;
		$value =~ s/(.*)\n/$1;\n/s;
		print OUT "\$Conf{$var} = ", $value;
		$done->{$var} = 1;
	    }
	    $endLine = $1 if ( /^\s*\$Conf\{[^}]*} *= *<<(.*);/ );
	    $endLine = $1 if ( /^\s*\$Conf\{[^}]*} *= *<<'(.*)';/ );
	    $out = "";
	    $skipVar = 1;
	} elsif ( $skipVar ) {
	    if ( !defined($endLine) && (/^\s*[\r\n]*$/ || /^\s*#/) ) {
		$skipVar = 0;
		$comment = 1;
		$out .= $_;
	    }
	    if ( defined($endLine) && /^\Q$endLine\E[\n\r]*$/ ) {
		$endLine = undef;
		$skipVar = 0;
		$comment = 1;
	    }
	} else {
	    $out .= $_;
	}
    }
    if ( $out ne "" ) {
	print OUT $out;
    }
    foreach my $var ( sort(keys(%$newConf)) ) {
	next if ( $done->{$var} );
	my $d = Data::Dumper->new([$newConf->{$var}], [*value]);
	$d->Indent(1);
	$d->Terse(1);
	my $value = $d->Dump;
	$value =~ s/(.*)\n/$1;\n/s;
	print OUT "\$Conf{$var} = ", $value;
	$done->{$var} = 1;
    }
    close(C);
    close(OUT);
}

#
# Return the mtime of the config file
#
sub ConfigMTime
{
    my($s) = @_;
    return (stat("$s->{TopDir}/conf/config.pl"))[9];
}

#
# Returns information from the host file in $s->{TopDir}/conf/hosts.
# With no argument a ref to a hash of hosts is returned.  Each
# hash contains fields as specified in the hosts file.  With an
# argument a ref to a single hash is returned with information
# for just that host.
#
sub HostInfoRead
{
    my($s, $host) = @_;
    my(%hosts, @hdr, @fld);
    local(*HOST_INFO);

    if ( !open(HOST_INFO, "$s->{TopDir}/conf/hosts") ) {
        print(STDERR $s->timeStamp,
                     "Can't open $s->{TopDir}/conf/hosts\n");
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
    my($s) = @_;
    return (stat("$s->{TopDir}/conf/hosts"))[9];
}

1;
