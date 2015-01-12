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
#   Copyright (C) 2004-2015  Craig Barratt
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
# Version 3.3.1, released 11 Jan 2015.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

package BackupPC::Storage::Text;

use strict;
use vars qw(%Conf);
use Data::Dumper;
use File::Path;
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

sub setPaths
{
    my $class = shift;
    my($paths) = @_;

    foreach my $v ( keys(%$paths) ) {
        $class->{$v} = $paths->{$v};
    }
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
            next if ( !/^(\d+\t(incr|full|partial).*)/ );
            $_ = $1;
            @{$Backups[@Backups]}{@{$s->{BackupFields}}} = split(/\t/);
        }
        close(BK_INFO);
    }
    close(LOCK);
    #
    # Default the version field.  Prior to 3.0.0 the xferMethod
    # field is empty, so we use that to figure out the version.
    #
    for ( my $i = 0 ; $i < @Backups ; $i++ ) {
        next if ( $Backups[$i]{version} ne "" );
        if ( $Backups[$i]{xferMethod} eq "" ) {
            $Backups[$i]{version} = "2.1.2";
        } else {
            $Backups[$i]{version} = "3.0.0";
        }
    }
    return @Backups;
}

sub BackupInfoWrite
{
    my($s, $host, @Backups) = @_;
    my($i, $contents, $fileOk);

    #
    # Generate the file contents
    #
    for ( $i = 0 ; $i < @Backups ; $i++ ) {
        my %b = %{$Backups[$i]};
        $contents .= join("\t", @b{@{$s->{BackupFields}}}) . "\n";
    }
    
    #
    # Write the file
    #
    return $s->TextFileWrite("$s->{TopDir}/pc/$host/backups", $contents);
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
    my($i, $contents, $fileOk);

    #
    # Generate the file contents
    #
    for ( $i = 0 ; $i < @Restores ; $i++ ) {
        my %b = %{$Restores[$i]};
        $contents .= join("\t", @b{@{$s->{RestoreFields}}}) . "\n";
    }

    #
    # Write the file
    #
    return $s->TextFileWrite("$s->{TopDir}/pc/$host/restores", $contents);
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
    my($i, $contents, $fileOk);

    #
    # Generate the file contents
    #
    for ( $i = 0 ; $i < @Archives ; $i++ ) {
        my %b = %{$Archives[$i]};
        $contents .= join("\t", @b{@{$s->{ArchiveFields}}}) . "\n";
    }

    #
    # Write the file
    #
    return $s->TextFileWrite("$s->{TopDir}/pc/$host/archives", $contents);
}

#
# Write a text file as safely as possible.  We write to
# a new file, verify the file, and the rename the file.
# The previous version of the file is renamed with a
# .old extension.
#
sub TextFileWrite
{
    my($s, $file, $contents) = @_;
    local(*FD, *LOCK);
    my($fileOk);

    (my $dir = $file) =~ s{(.+)/(.+)}{$1};

    if ( !-d $dir ) {
        eval { mkpath($dir, 0, 0775) };
        return "TextFileWrite: can't create directory $dir" if ( $@ );
    }
    if ( open(FD, ">", "$file.new") ) {
	binmode(FD);
        print FD $contents;
        close(FD);
        #
        # verify the file
        #
        if ( open(FD, "<", "$file.new") ) {
            binmode(FD);
            if ( join("", <FD>) ne $contents ) {
                return "TextFileWrite: Failed to verify $file.new";
            } else {
                $fileOk = 1;
            }
            close(FD);
        }
    }
    if ( $fileOk ) {
        my $lock;
        
        if ( open(LOCK, "$dir/LOCK") || open(LOCK, ">", "$dir/LOCK") ) {
            $lock = 1;
            flock(LOCK, LOCK_EX);
        }
        if ( -s "$file" ) {
            unlink("$file.old")           if ( -f "$file.old" );
            rename("$file", "$file.old")  if ( -f "$file" );
        } else {
            unlink("$file") if ( -f "$file" );
        }
        rename("$file.new", "$file") if ( -f "$file.new" );
        close(LOCK) if ( $lock );
    } else {
        return "TextFileWrite: Failed to write $file.new";
    }
    return;
}

sub ConfigPath
{
    my($s, $host) = @_;

    return "$s->{ConfDir}/config.pl" if ( !defined($host) );
    if ( $s->{useFHS} ) {
        return "$s->{ConfDir}/pc/$host.pl";
    } else {
        return "$s->{TopDir}/pc/$host/config.pl"
            if ( -f "$s->{TopDir}/pc/$host/config.pl" );
        return "$s->{ConfDir}/$host.pl"
            if ( $host ne "config" && -f "$s->{ConfDir}/$host.pl" );
        return "$s->{ConfDir}/pc/$host.pl";
    }
}

sub ConfigDataRead
{
    my($s, $host, $prevConfig) = @_;
    my($ret, $mesg, $config, @configs);

    #
    # TODO: add lock
    #
    my $conf = $prevConfig || {};
    my $configPath = $s->ConfigPath($host);

    push(@configs, $configPath) if ( -f $configPath );
    foreach $config ( @configs ) {
        %Conf = %$conf;
        if ( !defined($ret = do $config) && ($! || $@) ) {
            $mesg = "Couldn't open $config: $!" if ( $! );
            $mesg = "Couldn't execute $config: $@" if ( $@ );
            $mesg =~ s/[\n\r]+//;
            return ($mesg, $conf);
        }
        %$conf = %Conf;
    }

    #
    # Promote BackupFilesOnly and BackupFilesExclude to hashes
    #
    foreach my $param ( qw(BackupFilesOnly BackupFilesExclude) ) {
        next if ( !defined($conf->{$param}) || ref($conf->{$param}) eq "HASH" );
        $conf->{$param} = [ $conf->{$param} ]
                                if ( ref($conf->{$param}) ne "ARRAY" );
        $conf->{$param} = { "*" => $conf->{$param} };
    }

    #
    # Handle backward compatibility with defunct BlackoutHourBegin,
    # BlackoutHourEnd, and BlackoutWeekDays parameters.
    #
    if ( defined($conf->{BlackoutHourBegin}) ) {
        push(@{$conf->{BlackoutPeriods}},
             {
                 hourBegin => $conf->{BlackoutHourBegin},
                 hourEnd   => $conf->{BlackoutHourEnd},
                 weekDays  => $conf->{BlackoutWeekDays},
             }
        );
        delete($conf->{BlackoutHourBegin});
        delete($conf->{BlackoutHourEnd});
        delete($conf->{BlackoutWeekDays});
    }

    return (undef, $conf);
}

sub ConfigDataWrite
{
    my($s, $host, $newConf) = @_;

    my $configPath = $s->ConfigPath($host);

    my($err, $contents) = $s->ConfigFileMerge("$configPath", $newConf);
    if ( defined($err) ) {
        return $err;
    } else {
        #
        # Write the file
        #
        return $s->TextFileWrite($configPath, $contents);
    }
}

sub ConfigFileMerge
{
    my($s, $inFile, $newConf) = @_;
    local(*C);
    my($contents, $skipExpr, $fakeVar);
    my $done = {};

    if ( -f $inFile ) {
        #
        # Match existing settings in current config file
        #
        open(C, $inFile)
            || return ("ConfigFileMerge: can't open/read $inFile", undef);
        binmode(C);

        while ( <C> ) {
            if ( /^\s*\$Conf\{([^}]*)\}\s*=(.*)/ ) {
                my $var = $1;
                $skipExpr = "\$fakeVar = $2\n";
                if ( exists($newConf->{$var}) ) {
                    my $d = Data::Dumper->new([$newConf->{$var}], [*value]);
                    $d->Indent(1);
                    $d->Terse(1);
                    my $value = $d->Dump;
                    $value =~ s/(.*)\n/$1;\n/s;
                    $contents .= "\$Conf{$var} = " . $value;
                    $done->{$var} = 1;
                }
            } elsif ( defined($skipExpr) ) {
                $skipExpr .= $_;
            } else {
                $contents .= $_;
            }
            if ( defined($skipExpr)
                    && ($skipExpr =~ /^\$fakeVar = *<</
                        || $skipExpr =~ /;[\n\r]*$/) ) {
                #
                # if we have a complete expression, then we are done
                # skipping text from the original config file.
                #
                $skipExpr = $1 if ( $skipExpr =~ /(.*)/s );
                eval($skipExpr);
                $skipExpr = undef if ( $@ eq "" );
            }
        }
        close(C);
    }

    #
    # Add new entries not matched in current config file
    #
    foreach my $var ( sort(keys(%$newConf)) ) {
	next if ( $done->{$var} );
	my $d = Data::Dumper->new([$newConf->{$var}], [*value]);
	$d->Indent(1);
	$d->Terse(1);
	my $value = $d->Dump;
	$value =~ s/(.*)\n/$1;\n/s;
	$contents .= "\$Conf{$var} = " . $value;
	$done->{$var} = 1;
    }
    return (undef, $contents);
}

#
# Return the mtime of the config file
#
sub ConfigMTime
{
    my($s) = @_;
    return (stat($s->ConfigPath()))[9];
}

#
# Returns information from the host file in $s->{ConfDir}/hosts.
# With no argument a ref to a hash of hosts is returned.  Each
# hash contains fields as specified in the hosts file.  With an
# argument a ref to a single hash is returned with information
# for just that host.
#
sub HostInfoRead
{
    my($s, $host) = @_;
    my(%hosts, @hdr, @fld);
    local(*HOST_INFO, *LOCK);

    flock(LOCK, LOCK_EX) if open(LOCK, "$s->{ConfDir}/LOCK");
    if ( !open(HOST_INFO, "$s->{ConfDir}/hosts") ) {
        print(STDERR "Can't open $s->{ConfDir}/hosts\n");
        close(LOCK);
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
                next if ( lc($fld[0]) ne lc($host) );
                @{$hosts{lc($fld[0])}}{@hdr} = @fld;
		close(HOST_INFO);
                close(LOCK);
                return \%hosts;
            } else {
                @{$hosts{lc($fld[0])}}{@hdr} = @fld;
            }
        } else {
            @hdr = @fld;
        }
    }
    close(HOST_INFO);
    close(LOCK);
    return \%hosts;
}

#
# Writes new hosts information to the hosts file in $s->{ConfDir}/hosts.
# With no argument a ref to a hash of hosts is returned.  Each
# hash contains fields as specified in the hosts file.  With an
# argument a ref to a single hash is returned with information
# for just that host.
#
sub HostInfoWrite
{
    my($s, $hosts) = @_;
    my($gotHdr, @fld, $hostText, $contents);
    local(*HOST_INFO);

    if ( !open(HOST_INFO, "$s->{ConfDir}/hosts") ) {
        return "Can't open $s->{ConfDir}/hosts";
    }
    foreach my $host ( keys(%$hosts) ) {
        my $name = "$hosts->{$host}{host}";
        my $rest = "\t$hosts->{$host}{dhcp}"
                 . "\t$hosts->{$host}{user}"
                 . "\t$hosts->{$host}{moreUsers}";
        $name =~ s/ /\\ /g;
        $rest =~ s/ //g;
        $hostText->{$host} = $name . $rest;
    }
    binmode(HOST_INFO);
    while ( <HOST_INFO> ) {
        s/[\n\r]+//;
        if ( /^\s*$/ || /^\s*#/ ) {
            $contents .= $_ . "\n";
            next;
        }
        if ( !$gotHdr ) {
            $contents .= $_ . "\n";
            $gotHdr = 1;
            next;
        }
        @fld = split(/(?<!\\)\s+/, $1);
        #
        # Remove any \
        #
        foreach ( @fld ) {
            s{\\(\s)}{$1}g;
        }
        if ( defined($hostText->{$fld[0]}) ) {
            $contents .= $hostText->{$fld[0]} . "\n";
            delete($hostText->{$fld[0]});
        }
    }
    foreach my $host ( sort(keys(%$hostText)) ) {
        $contents .= $hostText->{$host} . "\n";
        delete($hostText->{$host});
    }
    close(HOST_INFO);

    #
    # Write and verify the new host file
    #
    return $s->TextFileWrite("$s->{ConfDir}/hosts", $contents);
}

#
# Return the mtime of the hosts file
#
sub HostsMTime
{
    my($s) = @_;
    return (stat("$s->{ConfDir}/hosts"))[9];
}

1;
