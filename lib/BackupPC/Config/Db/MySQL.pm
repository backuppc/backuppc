package BackupPC::Config::Db::MySQL;

use base 'BackupPC::Config::Db';
use warnings;
use strict;

use DBI;
use DBD::mysql;

our %Db;

%BackupPC::Config::Db::gConfigTypeField =
    (BOOLEAN   => 'valueBit',
     INT       => 'valueInt',
     FLOAT     => 'valueFloat',
     STRING    => 'valueString',
     MEMO      => 'valueMemo',
    );

sub ConnectData
{
    my($self) = @_;
    return if $self->{dbh};
    
    my($mesg, %db, $parm, @missing);
    
    %db = $self->GetDbConnInfo;
    return $self->{errstr} if $self->{errstr};

    foreach $parm (qw(host database user passwd)) {
        push(@missing, $parm) if !exists $db{$parm}
    }
    
    if (@missing) {
        $mesg = "Missing Db connection parameters: "
            . join(", ", @missing);
        return $mesg;
    }
        
    my $dsn = "DBI:mysql:database=$db{database};host=$db{host}";

    $self->{dbh} = DBI->connect($dsn, $db{user}, $db{passwd}, {RaiseError => 1,
                                AutoCommit => 1,});
    
    return;
}


sub ConfigMTime
{
    my($self) = @_;
    my $cmd = "SHOW TABLE STATUS LIKE 'Config'";
    my $sth = $self->{dbh}->prepare($cmd);
 
    $sth->execute;
    my $row = $sth->fetchrow_hashref || return time();
    my $mtime;
 
    if (defined($mtime = $row->{'Update_time'})) {
       $mtime =~ m/(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/
         || return time();
       return &Date_SecsSince1970($2,$3,$1,$4,$5,$6);
    } else {
       return time();
    }
}

sub HostsMTime
{
    my($self) = @_;
    my $cmd = "SHOW TABLE STATUS LIKE 'Client'";
    my $sth = $self->{dbh}->prepare($cmd);
 
    $sth->execute;
    my $row = $sth->fetchrow_hashref || return time();
    my $mtime;
 
    if (defined($mtime = $row->{'Update_time'})) {
       return &Date_SecsSince1970($mtime);
    } else {
       return time();
    }
}

# Date subs borrowed from Date::Manip.
# Copyright (c) 1995-2001 Sullivan Beck.  All rights reserved.
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

sub Date_SecsSince1970
{
    my($mysqlDate) = @_;
    $mysqlDate =~ m/(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/
      || return time();
    my($y,$m,$d,$h,$mn,$s) = ($1,$2,$3,$4,$5,$6);
    my($sec_now,$sec_70,$Ny,$N4,$N100,$N400,$dayofyear,$days)=();
    my($cc,$yy)=();
  
    $y=~ /(\d{2})(\d{2})/;
    ($cc,$yy)=($1,$2);
  
    $Ny=$y;
  
    $N4=($Ny-1)/4 + 1;
    $N4=0         if ($y==0);
  
    $N100=$cc + 1;
    $N100--       if ($yy==0);
    $N100=0       if ($y==0);
  
    $N400=($N100-1)/4 + 1;
    $N400=0       if ($y==0);
  
    my(@days) = ( 0, 31, 59, 90,120,151,181,212,243,273,304,334,365);
    my($ly)=0;
    $ly=1  if ($m>2 && &Date_LeapYear($y));
  
    $dayofyear=$days[$m-1]+$d+$ly;
    $days= $Ny*365 + $N4 - $N100 + $N400 + $dayofyear;
    $sec_now=($days-1)*24*3600 + $h*3600 + $mn*60 + $s;
    $sec_70 =62167219200;
    return ($sec_now-$sec_70);
}

sub Date_LeapYear
{
    my($y)=@_;
    return 0 if $y % 4;
    return 1 if $y % 100;
    return 0 if $y % 400;
    return 1;
}



1;
