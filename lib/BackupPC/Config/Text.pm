package BackupPC::Config::Text;

use warnings;
use strict;
use Fcntl qw/:flock/;

use base 'BackupPC::Config';

sub BackupInfoRead
{
    my($self, $host) = @_;
    local(*BK_INFO, *LOCK);
    my(@Backups);

    flock(LOCK, LOCK_EX) if open(LOCK, "$self->{TopDir}/pc/$host/LOCK");
    if ( open(BK_INFO, "$self->{TopDir}/pc/$host/backups") ) {
        while ( <BK_INFO> ) {
            s/[\n\r]+//;
            next if ( !/^(\d+\t(incr|full)[\d\t]*$)/ );
            $_ = $1;
            @{$Backups[@Backups]}{@{$self->{BackupFields}}} = split(/\t/);
        }
        close(BK_INFO);
    }
    close(LOCK);
    return @Backups;
}

sub BackupInfoWrite
{
    my($self, $host, @Backups) = @_;
    local(*BK_INFO, *LOCK);
    my($i);

    flock(LOCK, LOCK_EX) if open(LOCK, "$self->{TopDir}/pc/$host/LOCK");
    unlink("$self->{TopDir}/pc/$host/backups.old")
                if ( -f "$self->{TopDir}/pc/$host/backups.old" );
    rename("$self->{TopDir}/pc/$host/backups",
           "$self->{TopDir}/pc/$host/backups.old")
                if ( -f "$self->{TopDir}/pc/$host/backups" );
    if ( open(BK_INFO, ">$self->{TopDir}/pc/$host/backups") ) {
        for ( $i = 0 ; $i < @Backups ; $i++ ) {
            my %b = %{$Backups[$i]};
            printf(BK_INFO "%s\n", join("\t", @b{@{$self->{BackupFields}}}));
        }
        close(BK_INFO);
    }
    close(LOCK);
}

sub RestoreInfoRead
{
    my($self, $host) = @_;
    local(*RESTORE_INFO, *LOCK);
    my(@Restores);

    flock(LOCK, LOCK_EX) if open(LOCK, "$self->{TopDir}/pc/$host/LOCK");
    if ( open(RESTORE_INFO, "$self->{TopDir}/pc/$host/restores") ) {
        while ( <RESTORE_INFO> ) {
            s/[\n\r]+//;
            next if ( !/^(\d+.*)/ );
            $_ = $1;
            @{$Restores[@Restores]}{@{$self->{RestoreFields}}} = split(/\t/);
        }
        close(RESTORE_INFO);
    }
    close(LOCK);
    return @Restores;
}

sub RestoreInfoWrite
{
    my($self, $host, @Restores) = @_;
    local(*RESTORE_INFO, *LOCK);
    my($i);

    flock(LOCK, LOCK_EX) if open(LOCK, "$self->{TopDir}/pc/$host/LOCK");
    unlink("$self->{TopDir}/pc/$host/restores.old")
                if ( -f "$self->{TopDir}/pc/$host/restores.old" );
    rename("$self->{TopDir}/pc/$host/restores",
           "$self->{TopDir}/pc/$host/restores.old")
                if ( -f "$self->{TopDir}/pc/$host/restores" );
    if ( open(RESTORE_INFO, ">$self->{TopDir}/pc/$host/restores") ) {
        for ( $i = 0 ; $i < @Restores ; $i++ ) {
            my %b = %{$Restores[$i]};
            printf(RESTORE_INFO "%s\n",
                        join("\t", @b{@{$self->{RestoreFields}}}));
        }
        close(RESTORE_INFO);
    }
    close(LOCK);
}

sub ConfigRead
{
    my($self, $host) = @_;
    my($ret, $mesg, $config, @configs);
    
    our %Conf;

    $self->{Conf} = ();
    push(@configs, "$self->{TopDir}/conf/config.pl");
    push(@configs, "$self->{TopDir}/pc/$host/config.pl")
            if ( defined($host) && -f "$self->{TopDir}/pc/$host/config.pl" );
    foreach $config ( @configs ) {
        %Conf = ();
        if ( !defined($ret = do $config) && ($! || $@) ) {
            $mesg = "Couldn't open $config: $!" if ( $! );
            $mesg = "Couldn't execute $config: $@" if ( $@ );
            $mesg =~ s/[\n\r]+//;
            return $mesg;
        }
        %{$self->{Conf}} = ( %{$self->{Conf} || {}}, %Conf );
    }
    
    #$mesg = $self->CheckConfigInfo;
    #return $mesg if $mesg;
    
    return if ( !defined($self->{Conf}{Language}) );
    
    my $langFile = "$self->{LibDir}/BackupPC/Lang/$self->{Conf}{Language}.pm";
    
    if ( !defined($ret = do $langFile) && ($! || $@) ) {
        $mesg = "Couldn't open language file $langFile: $!" if ( $! );
        $mesg = "Couldn't execute language file $langFile: $@" if ( $@ );
        $mesg =~ s/[\n\r]+//;
        return $mesg;
    }
    
    our %Lang;
    $self->{Lang} = \%Lang;
    
    return;
}


#
# Return the mtime of the config file
#
sub ConfigMTime
{
    my($self) = @_;
    return (stat("$self->{TopDir}/conf/config.pl"))[9];
}

#
# Returns information from the host file in $self->{TopDir}/conf/hosts.
# With no argument a ref to a hash of hosts is returned.  Each
# hash contains fields as specified in the hosts file.  With an
# argument a ref to a single hash is returned with information
# for just that host.
#
sub HostInfoRead
{
    my($self, $host) = @_;
    my(%hosts, @hdr, @fld);
    local(*HOST_INFO);

    if ( !open(HOST_INFO, "$self->{TopDir}/conf/hosts") ) {
        print(STDERR $self->timeStamp,
                     "Can't open $self->{TopDir}/conf/hosts\n");
        return {};
    }
    while ( <HOST_INFO> ) {
        s/[\n\r]+//;
        s/#.*//;
        s/\s+$//;
        next if ( /^\s*$/ || !/^([\w\.-]+\s+.*)/ );
        @fld = split(/\s+/, $1);
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
    my($self) = @_;
    return (stat("$self->{TopDir}/conf/hosts"))[9];
}



1;
