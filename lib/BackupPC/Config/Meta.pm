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

    SshPath	 	=> {type => "string", undefIfEmpty => 1},
    NmbLookupPath 	=> {type => "string", undefIfEmpty => 1},
    PingPath	 	=> {type => "string", undefIfEmpty => 1},
    DfPath	 	=> {type => "string", undefIfEmpty => 1},
    DfCmd	 	=> "string",
    SplitPath	 	=> {type => "string", undefIfEmpty => 1},
    ParPath	 	=> {type => "string", undefIfEmpty => 1},
    CatPath	 	=> {type => "string", undefIfEmpty => 1},
    GzipPath	 	=> {type => "string", undefIfEmpty => 1},
    Bzip2Path	 	=> {type => "string", undefIfEmpty => 1},
    DfMaxUsagePct	=> "float",
    TrashCleanSleepSec	=> "integer",
    DHCPAddressRanges   => {
            type    => "list",
	    emptyOk => 1,
            child   => {
                type      => "hash",
                noKeyEdit => 1,
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
    BackupPCUserVerify  => "integer",
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
    PartialAgeMax	=> "float",
    IncrFill	 	=> "integer",
    RestoreInfoKeepCnt	=> "integer",
    ArchiveInfoKeepCnt	=> "integer",

    BackupFilesOnly	=> {
	    type         => "list",
	    emptyOk      => 1,
	    undefIfEmpty => 1,
	    child        => "string",
    },
    BackupFilesExclude	=> {
	    type         => "list",
	    emptyOk      => 1,
	    undefIfEmpty => 1,
	    child        => "string",
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

    BackupZeroFilesIsFatal => "integer",

    ######################################################################
    # How to backup a client
    ######################################################################
    XferMethod => {
	    type   => "select",
	    values => [qw(archive rsync rsyncd smb tar)],
    },
    XferLogLevel	=> "integer",

    SmbShareName 	=> {
	    type   => "list",
	    child  => "string",
    },
    SmbShareUserName 	=> "string",
    SmbSharePasswd 	=> "string",
    SmbClientPath 	=> {type => "string", undefIfEmpty => 1},
    SmbClientFullCmd 	=> "string",
    SmbClientIncrCmd 	=> "string",
    SmbClientRestoreCmd => "string",

    TarShareName 	=> {
	    type   => "list",
	    child  => "string",
    },
    TarClientCmd	=> "string",
    TarFullArgs 	=> "string",
    TarIncrArgs		=> "string",
    TarClientRestoreCmd	=> "string",
    TarClientPath 	=> {type => "string", undefIfEmpty => 1},

    RsyncShareName 	=> {
	    type   => "list",
	    child  => "string",
    },
    RsyncClientPath 	=> {type => "string", undefIfEmpty => 1},
    RsyncClientCmd 	=> "string",
    RsyncClientRestoreCmd => "string",

    RsyncdClientPort	=> "integer",
    RsyncdPasswd 	=> "string",
    RsyncdAuthRequired	=> "integer",

    RsyncCsumCacheVerifyProb => "float",
    RsyncArgs	 	=> {
	    type   => "list",
	    emptyOk => 1,
	    child  => "string",
    },
    RsyncRestoreArgs	=> {
	    type   => "list",
	    emptyOk => 1,
	    child  => "string",
    },

    ArchiveDest 	=> "string",
    ArchiveComp		=> {
	    type   => "select",
	    values => [qw(none bzip2 gzip)],
    },
    ArchivePar	 	=> "integer",
    ArchiveSplit	=> "float",
    ArchiveClientCmd 	=> "string",

    NmbLookupCmd 	=> "string",
    NmbLookupFindHostCmd => "string",

    FixedIPNetBiosNameCheck => "integer",
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

    ClientNameAlias 	=> {type => "string", undefIfEmpty => 1},

    ######################################################################
    # Email reminders, status and messages
    # (can be overridden in the per-PC config.pl)
    ######################################################################
    SendmailPath 	      => {type => "string", undefIfEmpty => 1},
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

    ######################################################################
    # CGI user interface configuration settings
    ######################################################################
    CgiAdminUserGroup 	=> "string",
    CgiAdminUsers	=> "string",
    CgiURL	 	=> "string",
    Language	 	=> "string",
    CgiUserHomePageCheck => "string",
    CgiUserUrlCreate    => "string",
    CgiDateFormatMMDD	=> "integer",
    CgiNavBarAdminAllHosts => "integer",
    CgiSearchBoxEnable 	=> "integer",
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
                PartialAgeMax             => "boolean",
                IncrFill                  => "boolean",
                RestoreInfoKeepCnt        => "boolean",
                ArchiveInfoKeepCnt        => "boolean",
                BackupFilesOnly           => "boolean",
                BackupFilesExclude        => "boolean",
                BlackoutBadPingLimit      => "boolean",
                BlackoutGoodCnt           => "boolean",
                BlackoutPeriods           => "boolean",
                BackupZeroFilesIsFatal    => "boolean",
                XferMethod                => "boolean",
                XferLogLevel              => "boolean",
                SmbShareName              => "boolean",
                SmbShareUserName          => "boolean",
                SmbSharePasswd            => "boolean",
                TarShareName              => "boolean",
                TarFullArgs               => "boolean",
                TarIncrArgs               => "boolean",
                RsyncShareName            => "boolean",
                RsyncdClientPort          => "boolean",
                RsyncdPasswd              => "boolean",
                RsyncdAuthRequired        => "boolean",
                RsyncCsumCacheVerifyProb  => "boolean",
                RsyncArgs                 => "boolean",
                RsyncRestoreArgs          => "boolean",
                ArchiveDest               => "boolean",
                ArchiveComp               => "boolean",
                ArchivePar                => "boolean",
                ArchiveSplit              => "boolean",
                FixedIPNetBiosNameCheck   => "boolean",
                PingMaxMsec               => "boolean",
                ClientTimeout             => "boolean",
                MaxOldPerPCLogFiles       => "boolean",
                CompressLevel             => "boolean",
                ClientNameAlias           => "boolean",
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
	    },
    },
);

1;
