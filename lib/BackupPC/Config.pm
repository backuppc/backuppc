package BackupPC::Config;

use warnings;
use Data::Dumper;

our %ConfigDef;

# this currently isn't used (or completed)
sub CheckConfigInfo
{
    my($self) = @_;
    my $errstr = '';
    
    my($attr, $val, $def, $ref);
    
    foreach $attr (sort keys %{ $self->{Conf} }) {
        $val = $self->{Conf}->{$attr};
        $ref = ref $val;
        $def = $ConfigDef{$attr};
        
        if (!defined $def) {
            $errstr .= "Unknown attribute $attr; ";
        } elsif ($def->{struct} eq 'SCALAR' && $ref) {
            $errstr .= "$attr expected to be SCALAR but is $ref; ";
        } elsif ($def->{struct} =~ /^ARRAY(OFHASH)$/ && $ref && $ref ne 'ARRAY') {
            $errstr .= "$attr expected to be ARRAY but is $ref; ";
        } elsif ($def->{struct} =~ /^HASH(OFARRAY)$/ && $ref && $ref ne 'HASH') {
            $errstr .= "$attr expected to be HASH but is $ref; ";
        # still working out this logic..
        #} elsif (defined $val && !$ref) {
        #    # if we got a scalar but were expecting a reference, fix it
        #    
        #    if($def->{struct} eq 'ARRAY') {
        #        $val = [ $val ];
        #    } elsif ($def->{struct} eq 'HASH') {
        #        $val = { $val };
        #    } elsif ($def->{struct} eq 'ARRAYOFHASH') {
        #        $val = [ { $val } ];
        #    } elsif ($def->{struct} eq 'HASHOFARRAY') {
        #        $val = { [ $val ] };
        #    }
            
        }
    }
    
    return $errstr;
}

sub TopDir
{
    my($self) = @_;
    return $self->{TopDir};
}

sub BinDir
{
    my($self) = @_;
    return $self->{BinDir};
}

sub Version
{
    my($self) = @_;
    return $self->{Version};
}

sub Conf
{
    my($self) = @_;
    return %{$self->{Conf}};
}

sub ConfigDef
{
    my($self) = @_;
    return \%ConfigDef;
}

sub Lang
{
    my($self) = @_;
    return $self->{Lang};
}

sub adminJob
{
    return " admin ";
}

sub trashJob
{
    return " trashClean ";
}

sub timeStamp
{
    my($self, $t, $noPad) = @_;
    my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)
              = localtime($t || time);
    $year += 1900;
    $mon++;
    return "$year/$mon/$mday " . sprintf("%02d:%02d:%02d", $hour, $min, $sec)
            . ($noPad ? "" : " ");
}

sub ConnectData
{
    # fallback routine in case no database used
    return 1;

}

###########################


%ConfigDef = (
    ServerHost                   => {struct => 'SCALAR',
                                     type   => 'STRING', },

    ServerPort                   => {struct => 'SCALAR',
                                     type   => 'INT', },

    ServerMesgSecret             => {struct => 'SCALAR',
                                     type   => 'STRING', },

    MyPath                       => {struct => 'SCALAR',
                                     type   => 'STRING', },

    UmaskMode                    => {struct => 'SCALAR',
                                     type   => 'INT', },

    WakeupSchedule               => {struct => 'ARRAY',
                                     type   => 'INT', },

    MaxBackups                   => {struct => 'SCALAR',
                                     type   => 'INT', },

    MaxUserBackups               => {struct => 'SCALAR',
                                     type   => 'INT', },

    MaxPendingCmds               => {struct => 'SCALAR',
                                     type   => 'INT', },

    MaxOldLogFiles               => {struct => 'SCALAR',
                                     type   => 'INT', },

    DfPath                       => {struct => 'SCALAR',
                                     type   => 'STRING', },

    DfMaxUsagePct                => {struct => 'SCALAR',
                                     type   => 'INT', },

    TrashCleanSleepSec           => {struct => 'SCALAR',
                                     type   => 'INT', },

    DHCPAddressRanges            => {struct => 'ARRAYOFHASH',
                                     type   => {ipAddrBase => 'STRING',
                                                first      => 'INT',
                                                last       => 'INT',}, },

    BackupPCUser                 => {struct => 'SCALAR',
                                     type   => 'STRING', },

    CgiDir                       => {struct => 'SCALAR',
                                     type   => 'STRING', },

    InstallDir                   => {struct => 'SCALAR',
                                     type   => 'STRING', },

    BackupPCUserVerify           => {struct => 'SCALAR',
                                     type   => 'BOOLEAN', },

    SmbShareName                 => {struct => 'ARRAY',
                                     type   => 'STRING', },

    SmbShareUserName             => {struct => 'SCALAR',
                                     type   => 'STRING', },

    SmbSharePasswd               => {struct => 'SCALAR',
                                     type   => 'STRING', },

    TarShareName                 => {struct => 'ARRAY',
                                     type   => 'STRING', },

    FullPeriod                   => {struct => 'SCALAR',
                                     type   => 'FLOAT', },

    IncrPeriod                   => {struct => 'SCALAR',
                                     type   => 'FLOAT', },

    FullKeepCnt                  => {struct => 'SCALAR',
                                     type   => 'INT', },

    FullKeepCntMin               => {struct => 'SCALAR',
                                     type   => 'INT', },

    FullAgeMax                   => {struct => 'SCALAR',
                                     type   => 'INT', },

    IncrKeepCnt                  => {struct => 'SCALAR',
                                     type   => 'INT', },

    IncrKeepCntMin               => {struct => 'SCALAR',
                                     type   => 'INT', },

    IncrAgeMax                   => {struct => 'SCALAR',
                                     type   => 'INT', },

    IncrFill                     => {struct => 'SCALAR',
                                     type   => 'BOOLEAN', },

    RestoreInfoKeepCnt           => {struct => 'SCALAR',
                                     type   => 'INT', },

    BackupFilesOnly              => {struct => 'HASHOFARRAY',
                                     type   => 'STRING', },

    BackupFilesExclude           => {struct => 'HASHOFARRAY',
                                     type   => 'STRING', },

    BlackoutBadPingLimit         => {struct => 'SCALAR',
                                     type   => 'INT', },

    BlackoutGoodCnt              => {struct => 'SCALAR',
                                     type   => 'INT', },

    BlackoutHourBegin            => {struct => 'SCALAR',
                                     type   => 'FLOAT', },

    BlackoutHourEnd              => {struct => 'SCALAR',
                                     type   => 'FLOAT', },

    BlackoutWeekDays             => {struct => 'ARRAY',
                                     type   => 'INT', },

    XferMethod                   => {struct => 'SCALAR',
                                     type   => 'STRING', },

    SmbClientPath                => {struct => 'SCALAR',
                                     type   => 'STRING', },

    SmbClientArgs                => {struct => 'SCALAR',
                                     type   => 'STRING', },

    TarClientCmd                 => {struct => 'SCALAR',
                                     type   => 'STRING', },

    TarFullArgs                  => {struct => 'SCALAR',
                                     type   => 'STRING', },

    TarIncrArgs                  => {struct => 'SCALAR',
                                     type   => 'STRING', },

    TarClientRestoreCmd          => {struct => 'SCALAR',
                                     type   => 'STRING', },

    TarClientPath                => {struct => 'SCALAR',
                                     type   => 'STRING', },

    SshPath                      => {struct => 'SCALAR',
                                     type   => 'STRING', },

    NmbLookupPath                => {struct => 'SCALAR',
                                     type   => 'STRING', },

    FixedIPNetBiosNameCheck      => {struct => 'SCALAR',
                                     type   => 'BOOLEAN', },

    PingPath                     => {struct => 'SCALAR',
                                     type   => 'STRING', },

    PingArgs                     => {struct => 'SCALAR',
                                     type   => 'STRING', },

    CompressLevel                => {struct => 'SCALAR',
                                     type   => 'INT', },

    PingMaxMsec                  => {struct => 'SCALAR',
                                     type   => 'INT', },

    SmbClientTimeout             => {struct => 'SCALAR',
                                     type   => 'INT', },

    MaxOldPerPCLogFiles          => {struct => 'SCALAR',
                                     type   => 'INT', },

    SendmailPath                 => {struct => 'SCALAR',
                                     type   => 'STRING', },

    EMailNotifyMinDays           => {struct => 'SCALAR',
                                     type   => 'INT', },

    EMailFromUserName            => {struct => 'SCALAR',
                                     type   => 'STRING', },

    EMailAdminUserName           => {struct => 'SCALAR',
                                     type   => 'STRING', },

    EMailNoBackupEverMesg        => {struct => 'SCALAR',
                                     type   => 'MEMO', },

    EMailNotifyOldBackupDays     => {struct => 'SCALAR',
                                     type   => 'INT', },

    EMailNoBackupRecentMesg      => {struct => 'SCALAR',
                                     type   => 'MEMO', },

    EMailNotifyOldOutlookDays    => {struct => 'SCALAR',
                                     type   => 'INT', },

    EMailOutlookBackupMesg       => {struct => 'SCALAR',
                                     type   => 'MEMO', },

    CgiAdminUserGroup            => {struct => 'SCALAR',
                                     type   => 'STRING', },

    CgiAdminUsers                => {struct => 'SCALAR',
                                     type   => 'STRING', },

    Language                     => {struct => 'SCALAR',
                                     type   => 'STRING', },

    CgiUserHomePageCheck         => {struct => 'SCALAR',
                                     type   => 'STRING', },

    CgiUserUrlCreate             => {struct => 'SCALAR',
                                     type   => 'STRING', },

    CgiDateFormatMMDD            => {struct => 'SCALAR',
                                     type   => 'BOOLEAN', },

    CgiNavBarAdminAllHosts       => {struct => 'SCALAR',
                                     type   => 'BOOLEAN', },

    CgiHeaders                   => {struct => 'SCALAR',
                                     type   => 'STRING', },

    CgiImageDir                  => {struct => 'SCALAR',
                                     type   => 'STRING', },

    CgiImageDirURL               => {struct => 'SCALAR',
                                     type   => 'STRING', },

);

1;
