#============================================================= -*-perl-*-
#
# BackupPC::Config::Meta package
#
# DESCRIPTION
#
#   This library defines a BackupPC::Config::Meta class.
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

package BackupPC::Config::Meta;

use strict;

require Exporter;

use vars qw( @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );

use vars qw(%ConfigMeta);

@ISA = qw(Exporter);

@EXPORT    = qw( );

@EXPORT_OK = qw(
		    %ConfigMeta
             );

%EXPORT_TAGS = (
    'all'    => [ @EXPORT_OK ],
);

#
# Define the data types for all the config variables
#

%ConfigMeta = (

    ######################################################################
    # General server configuration
    ######################################################################
    ServerHost 		=> "string",
    ServerPort	 	=> "integer",
    ServerMesgSecret 	=> "string",
    MyPath	 	=> {type => "string", undefIfEmpty => 1},
    UmaskMode	 	=> "integer",
    WakeupSchedule => {
            type  => "shortlist",
            child => "float",
        },
    MaxBackups	 	=> "integer",
    MaxUserBackups	=> "integer",
    MaxPendingCmds	=> "integer",
    MaxBackupPCNightlyJobs => "integer",
    BackupPCNightlyPeriod  => "integer",
    MaxOldLogFiles      => "integer",
    CmdQueueNice        => "integer",

    SshPath	 	=> {type => "execPath", undefIfEmpty => 1},
    NmbLookupPath 	=> {type => "execPath", undefIfEmpty => 1},
    PingPath	 	=> {type => "execPath", undefIfEmpty => 1},
    DfPath	 	=> {type => "execPath", undefIfEmpty => 1},
    DfCmd	 	=> "string",
    SplitPath	 	=> {type => "execPath", undefIfEmpty => 1},
    ParPath	 	=> {type => "execPath", undefIfEmpty => 1},
    CatPath	 	=> {type => "execPath", undefIfEmpty => 1},
    GzipPath	 	=> {type => "execPath", undefIfEmpty => 1},
    Bzip2Path	 	=> {type => "execPath", undefIfEmpty => 1},
    DfMaxUsagePct	=> "float",
    TrashCleanSleepSec	=> "integer",
    DHCPAddressRanges   => {
            type    => "list",
	    emptyOk => 1,
            child   => {
                type      => "hash",
                noKeyEdit => 1,
                order     => [qw(ipAddrBase first last)],
                child     => {
                    ipAddrBase => "string",
                    first      => "integer",
                    last       => "integer",
                },
	    },
    },
    BackupPCUser 	=> "string",
    CgiDir	 	=> "string",
    InstallDir	 	=> "string",
    TopDir              => "string",
    ConfDir             => "string",
    LogDir              => "string",
    BackupPCUserVerify  => "boolean",
    HardLinkMax	 	=> "integer",
    PerlModuleLoad 	=> {
	    type    => "list",
	    emptyOk => 1,
	    undefIfEmpty => 1,
	    child   => "string",
    },
    ServerInitdPath 	=> {type => "string", undefIfEmpty => 1},
    ServerInitdStartCmd => "string",

    ######################################################################
    # What to backup and when to do it
    # (can be overridden in the per-PC config.pl)
    ######################################################################
    FullPeriod	 	=> "float",
    IncrPeriod	 	=> "float",
    FullKeepCnt         => {
	    type   => "shortlist",
	    child  => "integer",
    },
    FullKeepCntMin	=> "integer",
    FullAgeMax		=> "float",
    IncrKeepCnt	 	=> "integer",
    IncrKeepCntMin	=> "integer",
    IncrAgeMax		=> "float",
    IncrLevels          => {
	    type   => "shortlist",
	    child  => "integer",
    },
    PartialAgeMax	=> "float",
    BackupsDisable      => "integer",
    IncrFill	 	=> "boolean",
    RestoreInfoKeepCnt	=> "integer",
    ArchiveInfoKeepCnt	=> "integer",

    BackupFilesOnly	=> {
            type      => "hash",
            keyText   => "CfgEdit_Button_New_Share",
            emptyOk   => 1,
            childType => {
                type      => "list",
                emptyOk   => 1,
                child     => "string",
            },
    },
    BackupFilesExclude	=> {
            type      => "hash",
            keyText   => "CfgEdit_Button_New_Share",
            emptyOk   => 1,
            childType => {
                type      => "list",
                emptyOk   => 1,
                child     => "string",
            },
    },

    BlackoutBadPingLimit => "integer",
    BlackoutGoodCnt	 => "integer",
    BlackoutPeriods 	 => {
            type    => "list",
	    emptyOk => 1,
            child   => {
                type      => "hash",
                noKeyEdit => 1,
                child     => {
                    hourBegin => "float",
                    hourEnd   => "float",
                    weekDays  => {
                        type  => "shortlist",
                        child => "integer",
                    },
                },
            },
        },

    BackupZeroFilesIsFatal => "boolean",

    ######################################################################
    # How to backup a client
    ######################################################################
    XferMethod => {
	    type   => "select",
	    values => [qw(archive ftp rsync rsyncd smb tar)],
    },
    XferLogLevel	=> "integer",

    ClientCharset       => "string",
    ClientCharsetLegacy => "string",

    ######################################################################
    # Smb Configuration
    ######################################################################
    SmbShareName 	=> {
	    type   => "list",
	    child  => "string",
    },
    SmbShareUserName 	=> "string",
    SmbSharePasswd 	=> "string",
    SmbClientPath 	=> {type => "execPath", undefIfEmpty => 1},
    SmbClientFullCmd 	=> "string",
    SmbClientIncrCmd 	=> "string",
    SmbClientRestoreCmd => {type => "string", undefIfEmpty => 1},

    ######################################################################
    # Tar Configuration
    ######################################################################
    TarShareName 	=> {
	    type   => "list",
	    child  => "string",
    },
    TarClientCmd	=> "string",
    TarFullArgs 	=> "string",
    TarIncrArgs		=> "string",
    TarClientRestoreCmd	=> {type => "string", undefIfEmpty => 1},
    TarClientPath 	=> {type => "string", undefIfEmpty => 1},

    ######################################################################
    # Rsync Configuration
    ######################################################################
    RsyncShareName 	=> {
	    type   => "list",
	    child  => "string",
    },
    RsyncClientPath 	=> {type => "string", undefIfEmpty => 1},
    RsyncClientCmd 	=> "string",
    RsyncClientRestoreCmd => "string",

    ######################################################################
    # Rsyncd Configuration
    ######################################################################
    RsyncdClientPort	=> "integer",
    RsyncdUserName 	=> "string",
    RsyncdPasswd 	=> "string",
    RsyncdAuthRequired	=> "boolean",

    ######################################################################
    # Rsync(d) Options
    ######################################################################
    RsyncCsumCacheVerifyProb => "float",
    RsyncArgs	 	=> {
	    type         => "list",
	    emptyOk      => 1,
	    child        => "string",
    },
    RsyncArgsExtra	 => {
	    type         => "list",
	    emptyOk      => 1,
	    child        => "string",
    },
    RsyncRestoreArgs	=> {
	    type         => "list",
	    emptyOk      => 1,
            undefIfEmpty => 1,
	    child        => "string",
    },

    ######################################################################
    # FTP Configuration
    ######################################################################
    FtpShareName        => {
            type  => "list",
            child => "string",
    },
    FtpUserName         => "string",
    FtpPasswd           => "string",
    FtpPassive          => "boolean",
    FtpBlockSize        => "integer",
    FtpPort             => "integer",
    FtpTimeout          => "integer",
    FtpFollowSymlinks   => "boolean",

    ######################################################################
    # Archive Configuration
    ######################################################################
    ArchiveDest 	=> "string",
    ArchiveComp		=> {
	    type   => "select",
	    values => [qw(none bzip2 gzip)],
    },
    ArchivePar	 	=> "boolean",
    ArchiveSplit	=> "float",
    ArchiveClientCmd 	=> "string",

    ######################################################################
    # Other Client Configuration
    ######################################################################
    NmbLookupCmd 	=> "string",
    NmbLookupFindHostCmd => "string",

    FixedIPNetBiosNameCheck => "boolean",
    PingCmd	 	=> "string",
    PingMaxMsec		=> "float",

    ClientTimeout	=> "integer",

    MaxOldPerPCLogFiles	=> "integer",

    CompressLevel	=> "integer",

    DumpPreUserCmd	=> {type => "string", undefIfEmpty => 1},
    DumpPostUserCmd	=> {type => "string", undefIfEmpty => 1},
    DumpPreShareCmd     => {type => "string", undefIfEmpty => 1},
    DumpPostShareCmd	=> {type => "string", undefIfEmpty => 1},
    RestorePreUserCmd	=> {type => "string", undefIfEmpty => 1},
    RestorePostUserCmd	=> {type => "string", undefIfEmpty => 1},
    ArchivePreUserCmd	=> {type => "string", undefIfEmpty => 1},
    ArchivePostUserCmd	=> {type => "string", undefIfEmpty => 1},
    UserCmdCheckStatus  => "boolean",

    ClientNameAlias 	=> {type => "string", undefIfEmpty => 1},

    ######################################################################
    # Email reminders, status and messages
    # (can be overridden in the per-PC config.pl)
    ######################################################################
    SendmailPath 	      => {type => "execPath", undefIfEmpty => 1},
    EMailNotifyMinDays        => "float",
    EMailFromUserName         => "string",
    EMailAdminUserName        => "string",
    EMailUserDestDomain       => "string",
    EMailNoBackupEverSubj     => {type => "string",    undefIfEmpty => 1},
    EMailNoBackupEverMesg     => {type => "bigstring", undefIfEmpty => 1},
    EMailNotifyOldBackupDays  => "float",
    EMailNoBackupRecentSubj   => {type => "string",    undefIfEmpty => 1},
    EMailNoBackupRecentMesg   => {type => "bigstring", undefIfEmpty => 1},
    EMailNotifyOldOutlookDays => "float",
    EMailOutlookBackupSubj    => {type => "string",    undefIfEmpty => 1},
    EMailOutlookBackupMesg    => {type => "bigstring", undefIfEmpty => 1},
    EMailHeaders              => {type => "bigstring", undefIfEmpty => 1},

    ######################################################################
    # CGI user interface configuration settings
    ######################################################################
    CgiAdminUserGroup 	=> "string",
    CgiAdminUsers	=> "string",
    CgiURL	 	=> "string",
    Language	 	=> {
	    type   => "select",
	    values => [qw(cz de en es fr it ja nl pl pt_br ru uk zh_CN)],
    },
    CgiUserHomePageCheck => "string",
    CgiUserUrlCreate    => "string",
    CgiDateFormatMMDD	=> "integer",
    CgiNavBarAdminAllHosts => "boolean",
    CgiSearchBoxEnable 	=> "boolean",
    CgiNavBarLinks	=> {
	    type    => "list",
	    emptyOk => 1,
	    child   => {
		type => "hash",
                noKeyEdit => 1,
		child => {
		    link  => "string",
		    lname => {type => "string", undefIfEmpty => 1},
		    name  => {type => "string", undefIfEmpty => 1},
		},
	    },
    },
    CgiStatusHilightColor => {
	    type => "hash",
	    noKeyEdit => 1,
	    child => {
		Reason_backup_failed           => "string",
		Reason_backup_done             => "string",
		Reason_no_ping                 => "string",
		Reason_backup_canceled_by_user => "string",
		Status_backup_in_progress      => "string",
                Disabled_OnlyManualBackups     => "string", 
                Disabled_AllBackupsDisabled    => "string",  
	    },
    },
    CgiHeaders	 	=> "bigstring",
    CgiImageDir 	=> "string",
    CgiExt2ContentType  => {
            type      => "hash",
	    emptyOk   => 1,
            childType => "string",
        },
    CgiImageDirURL 	=> "string",
    CgiCSSFile	 	=> "string",
    CgiUserConfigEditEnable => "boolean",
    CgiUserConfigEdit   => {
	    type => "hash",
	    noKeyEdit => 1,
	    child => {
                FullPeriod                => "boolean",
                IncrPeriod                => "boolean",
                FullKeepCnt               => "boolean",
                FullKeepCntMin            => "boolean",
                FullAgeMax                => "boolean",
                IncrKeepCnt               => "boolean",
                IncrKeepCntMin            => "boolean",
                IncrAgeMax                => "boolean",
                IncrLevels                => "boolean",
                PartialAgeMax             => "boolean",
                IncrFill                  => "boolean",
                RestoreInfoKeepCnt        => "boolean",
                ArchiveInfoKeepCnt        => "boolean",
                BackupFilesOnly           => "boolean",
                BackupFilesExclude        => "boolean",
                BackupsDisable            => "boolean",
                BlackoutBadPingLimit      => "boolean",
                BlackoutGoodCnt           => "boolean",
                BlackoutPeriods           => "boolean",
                BackupZeroFilesIsFatal    => "boolean",
                XferMethod                => "boolean",
                XferLogLevel              => "boolean",
                ClientCharset             => "boolean",
                ClientCharsetLegacy       => "boolean",
                SmbShareName              => "boolean",
                SmbShareUserName          => "boolean",
                SmbSharePasswd            => "boolean",
                SmbClientFullCmd          => "boolean",
                SmbClientIncrCmd          => "boolean",
                SmbClientRestoreCmd       => "boolean",
                TarShareName              => "boolean",
                TarFullArgs               => "boolean",
                TarIncrArgs               => "boolean",
                TarClientCmd              => "boolean",
                TarClientPath             => "boolean",
                TarClientRestoreCmd       => "boolean",
                RsyncShareName            => "boolean",
                RsyncdClientPort          => "boolean",
                RsyncdUserName            => "boolean",
                RsyncdPasswd              => "boolean",
                RsyncdAuthRequired        => "boolean",
                RsyncCsumCacheVerifyProb  => "boolean",
                RsyncArgs                 => "boolean",
                RsyncArgsExtra            => "boolean",
                RsyncRestoreArgs          => "boolean",
                RsyncClientCmd            => "boolean",
                RsyncClientPath           => "boolean",
                RsyncClientRestoreCmd     => "boolean",
                FtpShareName              => "boolean",
                FtpUserName               => "boolean",
                FtpPasswd                 => "boolean",
                FtpBlockSize              => "boolean",
                FtpPort                   => "boolean",
                FtpTimeout                => "boolean",
                FtpFollowSymlinks         => "boolean",
                FtpRestoreEnabled         => "boolean",
                ArchiveDest               => "boolean",
                ArchiveComp               => "boolean",
                ArchivePar                => "boolean",
                ArchiveSplit              => "boolean",
                ArchiveClientCmd          => "boolean",
                FixedIPNetBiosNameCheck   => "boolean",
                PingMaxMsec               => "boolean",
                NmbLookupCmd              => "boolean",
                NmbLookupFindHostCmd      => "boolean",
                PingCmd                   => "boolean",
                ClientTimeout             => "boolean",
                MaxOldPerPCLogFiles       => "boolean",
                CompressLevel             => "boolean",
                ClientNameAlias           => "boolean",
                DumpPreUserCmd            => "boolean",
                DumpPostUserCmd           => "boolean",
                RestorePreUserCmd         => "boolean",
                RestorePostUserCmd        => "boolean",
                ArchivePreUserCmd         => "boolean",
                ArchivePostUserCmd        => "boolean",
                DumpPostShareCmd          => "boolean",
                DumpPreShareCmd           => "boolean",
                UserCmdCheckStatus        => "boolean",
                EMailNotifyMinDays        => "boolean",
                EMailFromUserName         => "boolean",
                EMailAdminUserName        => "boolean",
                EMailUserDestDomain       => "boolean",
                EMailNoBackupEverSubj     => "boolean",
                EMailNoBackupEverMesg     => "boolean",
                EMailNotifyOldBackupDays  => "boolean",
                EMailNoBackupRecentSubj   => "boolean",
                EMailNoBackupRecentMesg   => "boolean",
                EMailNotifyOldOutlookDays => "boolean",
                EMailOutlookBackupSubj    => "boolean",
                EMailOutlookBackupMesg    => "boolean",
                EMailHeaders              => "boolean",
	    },
    },

    ######################################################################
    # Fake config setting for editing the hosts
    ######################################################################
    Hosts => {
	    type    => "list",
	    emptyOk => 1,
	    child   => {
		type  => "horizHash",
                order => [qw(host dhcp user moreUsers)],
                noKeyEdit => 1,
		child => {
		    host       => { type => "string", size => 20 },
		    dhcp       => { type => "boolean"            },
		    user       => { type => "string", size => 20 },
		    moreUsers  => { type => "string", size => 30 },
		},
	    },
    },
);

1;
