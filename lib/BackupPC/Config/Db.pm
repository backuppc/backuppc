package BackupPC::Config::Db;

use base 'BackupPC::Config';
use warnings;
use strict;

use DBI;

sub GetDbConnInfo
{
    my($self, $dbi) = @_;
    my($ret, $mesg, $dbConfig);

    $dbConfig = "$self->{TopDir}/conf/db.pl";
    
    our %Db;
    
    if ( !defined($ret = do $dbConfig) && ($! || $@) ) {
        $mesg = "Couldn't open $dbConfig: $!" if ( $! );
        $mesg = "Couldn't execute $dbConfig: $@" if ( $@ );
        $mesg =~ s/[\n\r]+//;
        
        $self->{errstr} = $mesg;
        return undef;
    }
    
    $Db{passwd} = $ENV{BPC_DBPASSWD} if !exists $Db{passwd};
    
    my %parm = %Db;
    undef %Db;
    
    return %parm;
}

sub BackupInfoRead
{
    my($self, $client) = @_;

    # ORDER BY is important! BackupPC_dump expects list to be sorted
    my $cmd = "SELECT " . join(', ', @{ $self->{BackupFields} })
        . " FROM Backup WHERE client = '$client' ORDER BY num";
    my $sth = $self->{dbh}->prepare($cmd);

    $sth->execute;
    my($row, @backups);

NUM:
    while ($row = $sth->fetchrow_hashref) {
        $backups[@backups] = { %$row };
    }

    return @backups;
}

sub BackupInfoWrite
{
    my($self, $client, @backups) = @_;
    
    #BackupPC_dump passes an array containing all backup records, so we must
    #1) figure out which ones aren't in the database and add them; then
    #2) delete records in the database that weren't passed
    
    # get a hash of currently existing backup nums from database
    my %current = map {$_, 1}
        @{ $self->{dbh}->selectcol_arrayref("SELECT num FROM Backup") };
        
    my %textFields = map {$_, 1} 'client', @{ $self->{BackupTextFields} };
    
    my($num, $cmd, $sth);

NUM:
    foreach my $backup (@backups) {
        $num = $backup->{num};
        
        if (defined $current{$num}) {
            #it's in the database as well as @backups; delete it from hash
            delete $current{$num};
            
        } else {
            #it's not in database yet, so add it
            $cmd = "INSERT Backup (client, " . join(', ', @{ $self->{BackupFields} })
                . ") VALUES ('$client', " . join(', ',
                map {(defined $textFields{$_})? "'$backup->{$_}'" : $backup->{$_}}
                @{ $self->{BackupFields} }) . ")";
        
            $self->{dbh}->prepare($cmd)->execute;
        }

    }

    # any remaining items in %current should be discarded
    if (%current) {
        $cmd = "DELETE FROM Backup WHERE num IN (" . join(', ', sort keys %current)
            . ")";
        $self->{dbh}->prepare($cmd)->execute;
    }

}


# See comments in "Backup" subs, above
sub RestoreInfoRead
{
    my($self, $client) = @_;

    # ORDER BY is important! BackupPC_dump expects list to be sorted
    my $cmd = "SELECT " . join(', ', @{ $self->{RestoreFields} })
        . " FROM Restore WHERE client = '$client' ORDER BY num";
    my $sth = $self->{dbh}->prepare($cmd);

    $sth->execute;
    my($row, @restores);

NUM:
    while ($row = $sth->fetchrow_hashref) {
        $restores[@restores] = { %$row };
    }

    return @restores;
}


# See comments in "Backup" subs, above
sub RestoreInfoWrite
{
    my($self, $client, @restores) = @_;
    
    my %current = map {$_, 1}
        @{ $self->{dbh}->selectcol_arrayref("SELECT num FROM Restore") };
        
    my %textFields = map {$_, 1} 'client', @{ $self->{RestoreTextFields} };
    
    my($num, $cmd, $sth);

NUM:
    foreach my $restore (@restores) {
        $num = $restore->{num};
        
        if (defined $current{$num}) {
            delete $current{$num};
            
        } else {
            $cmd = "INSERT Restore (client, " . join(', ', @{ $self->{RestoreFields} })
                . ") VALUES ('$client', " . join(', ',
                map {(defined $textFields{$_})? "'$restore->{$_}'" : $restore->{$_}}
                @{ $self->{RestoreFields} }) . ")";
        
            $self->{dbh}->prepare($cmd)->execute;
        }

    }

    if (%current) {
        $cmd = "DELETE FROM Restore WHERE num IN (" . join(', ', sort keys %current)
            . ")";
        $self->{dbh}->prepare($cmd)->execute;
    }

}

sub HostInfoRead {
    my($self, $oneClient) = @_;
    
    my $cmd = "SELECT client AS host, dhcp, user, moreUsers FROM Client";
    my $sth = $self->{dbh}->prepare($cmd);
    
    $sth->execute;
    my($row, $client, %clients);
    
CLIENT:
    while ($row = $sth->fetchrow_hashref) {
        $client = $row->{host};
    
        if (defined $oneClient) {
            next CLIENT unless $oneClient eq $client;
            $clients{$client} = {%$row};
            return \%clients;
        }
    
        $clients{$client} = {%$row};
    }
    
    return \%clients;

}


#TODO: Replace w/ Db version!!
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

our %gConfigWriteHandler = (SCALAR      => \&_ConfigWriteScalar,
                            ARRAY       => \&_ConfigWriteArray,
                            HASH        => \&_ConfigWriteHash,
                            ARRAYOFHASH => \&_ConfigWriteArrayOfHash,
                            HASHOFARRAY => \&_ConfigWriteHashOfArray,
                           );

our %gConfigTypeField; # will be defined by database-specific Config module

sub ConfigWrite {
    my($self, $client) = @_;
    my $dbh = $self->{dbh};
    
    $dbh->{RaiseError} = 0;
    my($cmd, $sth);
    
    $cmd = "DELETE FROM Config WHERE client = '~~$client'";
    $sth = $dbh->prepare($cmd) or return "$cmd\n". $dbh->errstr;
    $sth->execute or return "$cmd\n". $dbh->errstr;
    
    $cmd = "UPDATE Config SET client = '~~$client' WHERE client = '$client'";
    $sth = $dbh->prepare($cmd) or return "$cmd\n". $dbh->errstr;
    $sth->execute or return "$cmd\n". $dbh->errstr;
    
    my($attr, $val, $def, $handler, $mesg);
    
    foreach $attr (sort keys %{ $self->{Conf} }) {
        $val = $self->{Conf}->{$attr};
        $def = $self->{ConfigDef}->{$attr};
        
        $handler = $gConfigWriteHandler{$def->{struct}};
        $mesg = &$handler($dbh, $def, $client, $attr, $val);
        return $mesg if $mesg;
    }

    
    $cmd = "DELETE FROM Config WHERE client = '~~$client'";
    $sth = $dbh->prepare($cmd) or return "$cmd\n". $dbh->errstr;
    $sth->execute or return "$cmd\n". $dbh->errstr;
    
    $self->{dbh}->{RaiseError} = 1;
    
    return;
}

sub _ConfigWriteScalar {
    my($dbh, $def, $client, $attr, $val) = @_;
    return if !defined $val;
    
    my $ref = ref $val;
    
    if ($ref) {
        return "Expected $attr to be SCALAR, but got $ref";
    }
    
    &_WriteConfigRow($dbh, $client, $attr, -1, '', $def->{type}, $val)
}

sub _ConfigWriteArray {
    my($dbh, $def, $client, $attr, $val, $key) = @_;
    return if !defined $val;

    $key = '' unless defined $key;
    my $ref = ref $val;
    
    if (!$ref) {
        #expecting ARRAY, got string -- implicit convert
        $val = [ $val ];
    } elsif ($ref ne 'ARRAY') {
        $attr = "$attr\{$key}" if $key ne '';
        return "Expected $attr to be ARRAY, but got $ref";
    }
    
    my $subscript = 0;
    my $item;
    my $type = $def->{type};
    
    foreach $item (@$val) {
        &_WriteConfigRow($dbh, $client, $attr, $subscript++,
                         $key, $type, $item)
    }
}

sub _ConfigWriteHash {
    my($dbh, $def, $client, $attr, $val, $subscript) = @_;
    return if !defined $val;

    $subscript = -1 unless defined $subscript;
    my $ref = ref $val;
    
    if (!$ref) {
        #expecting HASH, got string -- implicit convert
        $val = { '*' => $val };
    } elsif ($ref ne 'HASH') {
        $attr = "$attr\[$subscript]" if $subscript != -1;
        return "Expected $attr to be HASH, but got $ref";
    }
    
    my($key, $item);
    my $type = $def->{type};
    
    # If 'type' is a hash ref, this means the attribute's subvalue type
    # depends on what its corresponding key is. In that case, we set
    # $thisType for each iteration; otherwise, we leave it set to 'type'
    my $typeByKey = ref $type;
    my $thisType = $type;
    
    foreach $key (sort keys %$val) {
        $item = $val->{$key};
        
        if ($typeByKey) {
            $thisType = $type->{$key};
            
            if (!defined $thisType) {
                return "Don't know how to handle subvalue $key for $attr";
            }
        }
        
        &_WriteConfigRow($dbh, $client, $attr, $subscript,
                         $key, $thisType, $item)
    }
}

sub _ConfigWriteArrayOfHash {
    my($dbh, $def, $client, $attr, $val) = @_;
    return if !defined $val;

    my $ref = ref $val;
    
    if (!$ref) {
        #expecting ARRAY, got string -- implicit convert
        $val = [ $val ];
    } elsif ($ref ne 'ARRAY') {
        return "Expected $attr to be ARRAY, but got $ref";
    }
    
    my $subscript = 0;
    my $item;
    
    foreach $item (@$val) {
        &_ConfigWriteHash($dbh, $def, $client, $attr,
                          $item, $subscript++);
    }
}

sub _ConfigWriteHashOfArray {
    my($dbh, $def, $client, $attr, $val) = @_;
    return if !defined $val;

    my $ref = ref $val;
    
    if (!$ref) {
        #expecting HASH, got string -- implicit convert
        $val = { '*' => $val };
    } elsif ($ref ne 'HASH') {
        return "Expected $attr to be HASH, but got $ref";
    }
    
    my($key, $item);
    
    foreach $key (sort keys %$val) {
        $item = $val->{$key};
        &_ConfigWriteArray($dbh, $def, $client, $attr,
                           $item, $key);
    }
    
}

sub _WriteConfigRow {
    my($dbh, $client, $attr, $subscript, $key, $type, $val) = @_;
    
    defined $gConfigTypeField{$type}
        or return "Unknown ConfigDef type '$type' ($attr); aborting";
        
    my($confType, $field, %fields);
    
    while(($confType, $field) = each %gConfigTypeField) {
        if ($confType eq $type) {
            # this is the correct field for value of interest,
            # so copy and format it
            $fields{$field} = ($confType =~ /^(STRING|MEMO)$/)?
                $dbh->quote($val) : $val;
        } else {
            $fields{$field} = 'NULL';
        }
    }
    
    $fields{'client'} = $dbh->quote($client);
    $fields{'clientGroup'} = "''"; #TODO: add group logic
    $fields{'attribute'} = $dbh->quote($attr);
    $fields{'subscript'} = $subscript;
    $fields{'hashKey'} = $dbh->quote($key);
    
    my @fields = sort keys %fields;
    my @values = map { $fields{ $_ } } @fields;
    
    my $cmd = "INSERT Config (" . join(', ', @fields) . ")\nVALUES ("
        . join(', ', @values) . ")";
    
    my $sth = $dbh->prepare($cmd) or return "$cmd\n\n" . $dbh->errstr;
    $sth->execute or return "$cmd\n\n". $dbh->errstr;

    return;
}

#TODO: Replace w/ Db version!!
#
# Return the mtime of the config file
#
sub ConfigMTime
{
    my($self) = @_;
    return (stat("$self->{TopDir}/conf/config.pl"))[9];
}



sub DESTROY {
    my($self) = @_;

    $self->{dbh}->disconnect if defined $self->{dbh};
}


1;
