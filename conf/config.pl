#============================================================= -*-perl-*-
#
# Configuration file for BackupPC.
#
# DESCRIPTION
#
#   This is the main configuration file for BackupPC.
#
#   This file must be valid perl source, so make sure the punctuation,
#   quotes, and other syntax are valid.
#
#   This file is read by BackupPC at startup, when a HUP (-1) signal
#   is sent to BackupPC and also at each wakeup time whenever the
#   modification time of this file changes.
#
#   The configuration parameters are divided into four general groups.
#   The first group (general server configuration) provides general
#   configuration for BackupPC.  The next two groups describe what
#   to backup, when to do it, and how long to keep it.  The fourth
#   group are settings for the CGI http interface.
#
#   Configuration settings can also be specified on a per-PC basis.
#   Simply put the relevant settings in a config.pl file in the
#   PC's backup directory (ie: in __TOPDIR__/pc/hostName).
#   All configuration settings in the second, third and fourth
#   groups can be overridden by the per-PC config.pl file.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2001-2009  Craig Barratt
#
#   See http://backuppc.sourceforge.net.
#
#========================================================================

###########################################################################
# General server configuration
###########################################################################
#
# Host name on which the BackupPC server is running.
#
$Conf{ServerHost} = '';

#
# TCP port number on which the BackupPC server listens for and accepts
# connections.  Normally this should be disabled (set to -1).  The TCP
# port is only needed if apache runs on a different machine from BackupPC.
# In that case, set this to any spare port number over 1024 (eg: 2359).
# If you enable the TCP port, make sure you set $Conf{ServerMesgSecret}
# too!
#
$Conf{ServerPort} = -1;

#
# Shared secret to make the TCP port secure.  Set this to a hard to guess
# string if you enable the TCP port (ie: $Conf{ServerPort} > 0).
#
# To avoid possible attacks via the TCP socket interface, every client
# message is protected by an MD5 digest. The MD5 digest includes four
# items:
#   - a seed that is sent to the client when the connection opens
#   - a sequence number that increments for each message
#   - a shared secret that is stored in $Conf{ServerMesgSecret}
#   - the message itself.
#
# The message is sent in plain text preceded by the MD5 digest.  A
# snooper can see the plain-text seed sent by BackupPC and plain-text
# message from the client, but cannot construct a valid MD5 digest since
# the secret $Conf{ServerMesgSecret} is unknown.  A replay attack is
# not possible since the seed changes on a per-connection and
# per-message basis.
#
$Conf{ServerMesgSecret} = '';

#
# PATH setting for BackupPC.  An explicit value is necessary
# for taint mode.  Value shouldn't matter too much since
# all execs use explicit paths.  However, taint mode in perl
# will complain if this directory is world writable.
#
$Conf{MyPath} = '/bin';

#
# Permission mask for directories and files created by BackupPC.
# Default value prevents any access from group other, and prevents
# group write.
#
$Conf{UmaskMode} = 027;

#
# Times at which we wake up, check all the PCs, and schedule necessary
# backups.  Times are measured in hours since midnight.  Can be
# fractional if necessary (eg: 4.25 means 4:15am).
#
# If the hosts you are backing up are always connected to the network
# you might have only one or two wakeups each night.  This will keep
# the backup activity after hours.  On the other hand, if you are backing
# up laptops that are only intermittently connected to the network you
# will want to have frequent wakeups (eg: hourly) to maximize the chance
# that each laptop is backed up.
#
# Examples:
#     $Conf{WakeupSchedule} = [22.5];         # once per day at 10:30 pm.
#     $Conf{WakeupSchedule} = [2,4,6,8,10,12,14,16,18,20,22];  # every 2 hours
#
# The default value is every hour except midnight.
#
# The first entry of $Conf{WakeupSchedule} is when BackupPC_nightly is run.
# You might want to re-arrange the entries in $Conf{WakeupSchedule}
# (they don't have to be ascending) so that the first entry is when
# you want BackupPC_nightly to run (eg: when you don't expect a lot
# of regular backups to run).
#
$Conf{WakeupSchedule} = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23];

#
# Maximum number of simultaneous backups to run.  If there
# are no user backup requests then this is the maximum number
# of simultaneous backups.
#
$Conf{MaxBackups} = 4;

#
# Additional number of simultaneous backups that users can run.
# As many as $Conf{MaxBackups} + $Conf{MaxUserBackups} requests can
# run at the same time.
#
$Conf{MaxUserBackups} = 4;

#
# Maximum number of pending link commands. New backups will only be
# started if there are no more than $Conf{MaxPendingCmds} plus
# $Conf{MaxBackups} number of pending link commands, plus running jobs.
# This limit is to make sure BackupPC doesn't fall too far behind in
# running BackupPC_link commands.
#
$Conf{MaxPendingCmds} = 15;

#
# Nice level at which CmdQueue commands (eg: BackupPC_link and
# BackupPC_nightly) are run at.
#
$Conf{CmdQueueNice} = 10;

#
# How many BackupPC_nightly processes to run in parallel.
#
# Each night, at the first wakeup listed in $Conf{WakeupSchedule},
# BackupPC_nightly is run.  Its job is to remove unneeded files
# in the pool, ie: files that only have one link.  To avoid race
# conditions, BackupPC_nightly and BackupPC_link cannot run at
# the same time.  Starting in v3.0.0, BackupPC_nightly can run
# concurrently with backups (BackupPC_dump).
#
# So to reduce the elapsed time, you might want to increase this
# setting to run several BackupPC_nightly processes in parallel
# (eg: 4, or even 8).
#
$Conf{MaxBackupPCNightlyJobs} = 2;

#
# How many days (runs) it takes BackupPC_nightly to traverse the
# entire pool.  Normally this is 1, which means every night it runs,
# it does traverse the entire pool removing unused pool files.
#
# Other valid values are 2, 4, 8, 16.  This causes BackupPC_nightly to
# traverse 1/2, 1/4, 1/8 or 1/16th of the pool each night, meaning it
# takes 2, 4, 8 or 16 days to completely traverse the pool.  The
# advantage is that each night the running time of BackupPC_nightly
# is reduced roughly in proportion, since the total job is split
# over multiple days.  The disadvantage is that unused pool files
# take longer to get deleted, which will slightly increase disk
# usage.
#
# Note that even when $Conf{BackupPCNightlyPeriod} > 1, BackupPC_nightly
# still runs every night.  It just does less work each time it runs.
#
# Examples:
#
#    $Conf{BackupPCNightlyPeriod} = 1;   # entire pool is checked every night
#
#    $Conf{BackupPCNightlyPeriod} = 2;   # two days to complete pool check
#                                        # (different half each night)
#
#    $Conf{BackupPCNightlyPeriod} = 4;   # four days to complete pool check
#                                        # (different quarter each night)
#
$Conf{BackupPCNightlyPeriod} = 1;

#
# Maximum number of log files we keep around in log directory.
# These files are aged nightly.  A setting of 14 means the log
# directory will contain about 2 weeks of old log files, in
# particular at most the files LOG, LOG.0, LOG.1, ... LOG.13
# (except today's LOG, these files will have a .z extension if
# compression is on).
#
# If you decrease this number after BackupPC has been running for a
# while you will have to manually remove the older log files.
#
$Conf{MaxOldLogFiles} = 14;

#
# Full path to the df command.  Security caution: normal users
# should not allowed to write to this file or directory.
#
$Conf{DfPath} = '';

#
# Command to run df.  The following variables are substituted at run-time:
#
#   $dfPath      path to df ($Conf{DfPath})
#   $topDir      top-level BackupPC data directory
#
# Note: all Cmds are executed directly without a shell, so the prog name
# needs to be a full path and you can't include shell syntax like
# redirection and pipes; put that in a script if you need it.
#
$Conf{DfCmd} = '$dfPath $topDir';

#
# Full path to various commands for archiving
#
$Conf{SplitPath} = '';
$Conf{ParPath}   = '';
$Conf{CatPath}   = '';
$Conf{GzipPath}  = '';
$Conf{Bzip2Path} = '';

#
# Maximum threshold for disk utilization on the __TOPDIR__ filesystem.
# If the output from $Conf{DfPath} reports a percentage larger than
# this number then no new regularly scheduled backups will be run.
# However, user requested backups (which are usually incremental and
# tend to be small) are still performed, independent of disk usage.
# Also, currently running backups will not be terminated when the disk
# usage exceeds this number.
#
$Conf{DfMaxUsagePct} = 95;

#
# How long BackupPC_trashClean sleeps in seconds between each check
# of the trash directory.  Once every 5 minutes should be reasonable.
#
$Conf{TrashCleanSleepSec} = 300;

#
# List of DHCP address ranges we search looking for PCs to backup.
# This is an array of hashes for each class C address range.
# This is only needed if hosts in the conf/hosts file have the
# dhcp flag set.
#
# Examples:
#    # to specify 192.10.10.20 to 192.10.10.250 as the DHCP address pool
#    $Conf{DHCPAddressRanges} = [
#        {
#            ipAddrBase => '192.10.10',
#            first => 20,
#            last  => 250,
#        },
#    ];
#    # to specify two pools (192.10.10.20-250 and 192.10.11.10-50)
#    $Conf{DHCPAddressRanges} = [
#        {
#            ipAddrBase => '192.10.10',
#            first => 20,
#            last  => 250,
#        },
#        {
#            ipAddrBase => '192.10.11',
#            first => 10,
#            last  => 50,
#        },
#    ];
#
$Conf{DHCPAddressRanges} = [];

#
# The BackupPC user.
#
$Conf{BackupPCUser} = '';

#
# Important installation directories:
#
#   TopDir     - where all the backup data is stored
#   ConfDir    - where the main config and hosts files resides
#   LogDir     - where log files and other transient information
#   InstallDir - where the bin, lib and doc installation dirs reside.
#                Note: you cannot change this value since all the
#                perl scripts include this path.  You must reinstall
#                with configure.pl to change InstallDir.
#   CgiDir     - Apache CGI directory for BackupPC_Admin
#
# Note: it is STRONGLY recommended that you don't change the
# values here.  These are set at installation time and are here
# for reference and are used during upgrades.
#
# Instead of changing TopDir here it is recommended that you use
# a symbolic link to the new location, or mount the new BackupPC
# store at the existing $Conf{TopDir} setting.
#
$Conf{TopDir}      = '';
$Conf{ConfDir}     = '';
$Conf{LogDir}      = '';
$Conf{InstallDir}  = '';
$Conf{CgiDir}      = '';

#
# Whether BackupPC and the CGI script BackupPC_Admin verify that they
# are really running as user $Conf{BackupPCUser}.  If this flag is set
# and the effective user id (euid) differs from $Conf{BackupPCUser}
# then both scripts exit with an error.  This catches cases where
# BackupPC might be accidently started as root or the wrong user,
# or if the CGI script is not installed correctly.
#
$Conf{BackupPCUserVerify} = 1;

#
# Maximum number of hardlinks supported by the $TopDir file system
# that BackupPC uses.  Most linux or unix file systems should support
# at least 32000 hardlinks per file, or 64000 in other cases.  If a pool
# file already has this number of hardlinks, a new pool file is created
# so that new hardlinks can be accommodated.  This limit will only
# be hit if an identical file appears at least this number of times
# across all the backups.
#
$Conf{HardLinkMax} = 31999;

#
# Advanced option for asking BackupPC to load additional perl modules.
# Can be a list (array ref) of module names to load at startup.
#
$Conf{PerlModuleLoad}     = undef;

#
# Path to init.d script and command to use that script to start the
# server from the CGI interface.  The following variables are substituted
# at run-time:
#
#   $sshPath           path to ssh ($Conf{SshPath})
#   $serverHost        same as $Conf{ServerHost}
#   $serverInitdPath   path to init.d script ($Conf{ServerInitdPath})
#
# Example:
#
# $Conf{ServerInitdPath}     = '/etc/init.d/backuppc';
# $Conf{ServerInitdStartCmd} = '$sshPath -q -x -l root $serverHost'
#                            . ' $serverInitdPath start'
#                            . ' < /dev/null >& /dev/null';
#
# Note: all Cmds are executed directly without a shell, so the prog name
# needs to be a full path and you can't include shell syntax like
# redirection and pipes; put that in a script if you need it.
#
$Conf{ServerInitdPath} = '';
$Conf{ServerInitdStartCmd} = '';


###########################################################################
# What to backup and when to do it
# (can be overridden in the per-PC config.pl)
###########################################################################
#
# Minimum period in days between full backups. A full dump will only be
# done if at least this much time has elapsed since the last full dump,
# and at least $Conf{IncrPeriod} days has elapsed since the last
# successful dump.
#
# Typically this is set slightly less than an integer number of days. The
# time taken for the backup, plus the granularity of $Conf{WakeupSchedule}
# will make the actual backup interval a bit longer.
#
$Conf{FullPeriod} = 6.97;

#
# Minimum period in days between incremental backups (a user requested
# incremental backup will be done anytime on demand).
#
# Typically this is set slightly less than an integer number of days. The
# time taken for the backup, plus the granularity of $Conf{WakeupSchedule}
# will make the actual backup interval a bit longer.
#
$Conf{IncrPeriod} = 0.97;

#
# Number of full backups to keep.  Must be >= 1.
#
# In the steady state, each time a full backup completes successfully
# the oldest one is removed.  If this number is decreased, the
# extra old backups will be removed.
#
# If filling of incremental dumps is off the oldest backup always
# has to be a full (ie: filled) dump.  This might mean one or two
# extra full dumps are kept until the oldest incremental backups expire.
#
# Exponential backup expiry is also supported.  This allows you to specify:
#
#   - num fulls to keep at intervals of 1 * $Conf{FullPeriod}, followed by
#   - num fulls to keep at intervals of 2 * $Conf{FullPeriod},
#   - num fulls to keep at intervals of 4 * $Conf{FullPeriod},
#   - num fulls to keep at intervals of 8 * $Conf{FullPeriod},
#   - num fulls to keep at intervals of 16 * $Conf{FullPeriod},
#
# and so on.  This works by deleting every other full as each expiry
# boundary is crossed.
#
# Exponential expiry is specified using an array for $Conf{FullKeepCnt}:
#
#   $Conf{FullKeepCnt} = [4, 2, 3];
#
# Entry #n specifies how many fulls to keep at an interval of
# 2^n * $Conf{FullPeriod} (ie: 1, 2, 4, 8, 16, 32, ...).
#
# The example above specifies keeping 4 of the most recent full backups
# (1 week interval) two full backups at 2 week intervals, and 3 full
# backups at 4 week intervals, eg:
#
#    full 0 19 weeks old   \
#    full 1 15 weeks old    >---  3 backups at 4 * $Conf{FullPeriod}
#    full 2 11 weeks old   / 
#    full 3  7 weeks old   \____  2 backups at 2 * $Conf{FullPeriod}
#    full 4  5 weeks old   /
#    full 5  3 weeks old   \
#    full 6  2 weeks old    \___  4 backups at 1 * $Conf{FullPeriod}
#    full 7  1 week old     /
#    full 8  current       /
#
# On a given week the spacing might be less than shown as each backup
# ages through each expiry period.  For example, one week later, a
# new full is completed and the oldest is deleted, giving:
#
#    full 0 16 weeks old   \
#    full 1 12 weeks old    >---  3 backups at 4 * $Conf{FullPeriod}
#    full 2  8 weeks old   / 
#    full 3  6 weeks old   \____  2 backups at 2 * $Conf{FullPeriod}
#    full 4  4 weeks old   /
#    full 5  3 weeks old   \
#    full 6  2 weeks old    \___  4 backups at 1 * $Conf{FullPeriod}
#    full 7  1 week old     /
#    full 8  current       /
#
# You can specify 0 as a count (except in the first entry), and the
# array can be as long as you wish.  For example:
#
#   $Conf{FullKeepCnt} = [4, 0, 4, 0, 0, 2];
#
# This will keep 10 full dumps, 4 most recent at 1 * $Conf{FullPeriod},
# followed by 4 at an interval of 4 * $Conf{FullPeriod} (approx 1 month
# apart), and then 2 at an interval of 32 * $Conf{FullPeriod} (approx
# 7-8 months apart).
#
# Example: these two settings are equivalent and both keep just
# the four most recent full dumps:
#
#    $Conf{FullKeepCnt} = 4;
#    $Conf{FullKeepCnt} = [4];
#
$Conf{FullKeepCnt} = 1;

#
# Very old full backups are removed after $Conf{FullAgeMax} days.  However,
# we keep at least $Conf{FullKeepCntMin} full backups no matter how old
# they are.
#
# Note that $Conf{FullAgeMax} will be increased to $Conf{FullKeepCnt}
# times $Conf{FullPeriod} if $Conf{FullKeepCnt} specifies enough
# full backups to exceed $Conf{FullAgeMax}.
#
$Conf{FullKeepCntMin} = 1;
$Conf{FullAgeMax}     = 90;

#
# Number of incremental backups to keep.  Must be >= 1.
#
# In the steady state, each time an incr backup completes successfully
# the oldest one is removed.  If this number is decreased, the
# extra old backups will be removed.
#
$Conf{IncrKeepCnt} = 6;

#
# Very old incremental backups are removed after $Conf{IncrAgeMax} days.
# However, we keep at least $Conf{IncrKeepCntMin} incremental backups no
# matter how old they are.
#
$Conf{IncrKeepCntMin} = 1;
$Conf{IncrAgeMax}     = 30;

#
# Level of each incremental.  "Level" follows the terminology
# of dump(1).  A full backup has level 0.  A new incremental
# of level N will backup all files that have changed since
# the most recent backup of a lower level.
#
# The entries of $Conf{IncrLevels} apply in order to each
# incremental after each full backup.  It wraps around until
# the next full backup.  For example, these two settings
# have the same effect:
#
#       $Conf{IncrLevels} = [1, 2, 3];
#       $Conf{IncrLevels} = [1, 2, 3, 1, 2, 3];
#
# This means the 1st and 4th incrementals (level 1) go all
# the way back to the full.  The 2nd and 3rd (and 5th and
# 6th) backups just go back to the immediate preceeding
# incremental.
#
# Specifying a sequence of multi-level incrementals will
# usually mean more than $Conf{IncrKeepCnt} incrementals will
# need to be kept, since lower level incrementals are needed
# to merge a complete view of a backup.  For example, with
#
#       $Conf{FullPeriod}  = 7;
#       $Conf{IncrPeriod}  = 1;
#       $Conf{IncrKeepCnt} = 6;
#       $Conf{IncrLevels}  = [1, 2, 3, 4, 5, 6];
#
# there will be up to 11 incrementals in this case: 
#
#       backup #0  (full, level 0, oldest)
#       backup #1  (incr, level 1)
#       backup #2  (incr, level 2)
#       backup #3  (incr, level 3)
#       backup #4  (incr, level 4)
#       backup #5  (incr, level 5)
#       backup #6  (incr, level 6)
#       backup #7  (full, level 0)
#       backup #8  (incr, level 1)
#       backup #9  (incr, level 2)
#       backup #10 (incr, level 3)
#       backup #11 (incr, level 4)
#       backup #12 (incr, level 5, newest)
#
# Backup #1 (the oldest level 1 incremental) can't be deleted
# since backups 2..6 depend on it.  Those 6 incrementals can't
# all be deleted since that would only leave 5 (#8..12).
# When the next incremental happens (level 6), the complete
# set of 6 older incrementals (#1..6) will be deleted, since
# that maintains the required number ($Conf{IncrKeepCnt})
# of incrementals.  This situation is reduced if you set
# shorter chains of multi-level incrementals, eg:
#
#       $Conf{IncrLevels}  = [1, 2, 3];
#
# would only have up to 2 extra incremenals before all 3
# are deleted.
#
# BackupPC as usual merges the full and the sequence
# of incrementals together so each incremental can be
# browsed and restored as though it is a complete backup.
# If you specify a long chain of incrementals then more
# backups need to be merged when browsing, restoring,
# or getting the starting point for rsync backups.
# In the example above (levels 1..6), browing backup
# #6 requires 7 different backups (#0..6) to be merged.
#
# Because of this merging and the additional incrementals
# that need to be kept, it is recommended that some
# level 1 incrementals be included in $Conf{IncrLevels}.
#
# Prior to version 3.0 incrementals were always level 1,
# meaning each incremental backed up all the files that
# changed since the last full.
#
$Conf{IncrLevels} = [1];

#
# Disable all full and incremental backups.  These settings are
# useful for a client that is no longer being backed up
# (eg: a retired machine), but you wish to keep the last
# backups available for browsing or restoring to other machines.
#
# There are three values for $Conf{BackupsDisable}:
#
#   0    Backups are enabled.
#
#   1    Don't do any regular backups on this client.  Manually
#        requested backups (via the CGI interface) will still occur.
#
#   2    Don't do any backups on this client.  Manually requested
#        backups (via the CGI interface) will be ignored.
#
# In versions prior to 3.0 Backups were disabled by setting
# $Conf{FullPeriod} to -1 or -2.
#
$Conf{BackupsDisable} = 0;

#
# A failed full backup is saved as a partial backup.  The rsync
# XferMethod can take advantage of the partial full when the next
# backup is run. This parameter sets the age of the partial full
# in days: if the partial backup is older than this number of
# days, then rsync will ignore (not use) the partial full when
# the next backup is run.  If you set this to a negative value
# then no partials will be saved.  If you set this to 0, partials
# will be saved, but will not be used by the next backup.
#
# The default setting of 3 days means that a partial older than
# 3 days is ignored when the next full backup is done.
#
$Conf{PartialAgeMax} = 3;

#
# Whether incremental backups are filled.  "Filling" means that the
# most recent full (or filled) dump is merged into the new incremental
# dump using hardlinks.  This makes an incremental dump look like a
# full dump.  Prior to v1.03 all incremental backups were filled.
# In v1.4.0 and later the default is off.
#
# BackupPC, and the cgi interface in particular, do the right thing on
# un-filled incremental backups.  It will correctly display the merged
# incremental backup with the most recent filled backup, giving the
# un-filled incremental backups a filled appearance.  That means it
# invisible to the user whether incremental dumps are filled or not.
#
# Filling backups takes a little extra disk space, and it does cost
# some extra disk activity for filling, and later removal.  Filling
# is no longer useful, since file mangling and compression doesn't
# make a filled backup very useful. It's likely the filling option
# will be removed from future versions: filling will be delegated to
# the display and extraction of backup data.
#
# If filling is off, BackupPC makes sure that the oldest backup is
# a full, otherwise the following incremental backups will be
# incomplete.  This might mean an extra full backup has to be
# kept until the following incremental backups expire.
#
# The default is off.  You can turn this on or off at any
# time without affecting existing backups.
#
$Conf{IncrFill} = 0;

#
# Number of restore logs to keep.  BackupPC remembers information about
# each restore request.  This number per client will be kept around before
# the oldest ones are pruned.
#
# Note: files/dirs delivered via Zip or Tar downloads don't count as
# restores.  Only the first restore option (where the files and dirs
# are written to the host) count as restores that are logged.
#
$Conf{RestoreInfoKeepCnt} = 10;

#
# Number of archive logs to keep.  BackupPC remembers information
# about each archive request.  This number per archive client will
# be kept around before the oldest ones are pruned.
#
$Conf{ArchiveInfoKeepCnt} = 10;

#
# List of directories or files to backup.  If this is defined, only these
# directories or files will be backed up.
#
# For Smb, only one of $Conf{BackupFilesExclude} and $Conf{BackupFilesOnly}
# can be specified per share. If both are set for a particular share, then
# $Conf{BackupFilesOnly} takes precedence and $Conf{BackupFilesExclude}
# is ignored.
#
# This can be set to a string, an array of strings, or, in the case
# of multiple shares, a hash of strings or arrays.  A hash is used
# to give a list of directories or files to backup for each share
# (the share name is the key).  If this is set to just a string or
# array, and $Conf{SmbShareName} contains multiple share names, then
# the setting is assumed to apply all shares.
#
# If a hash is used, a special key "*" means it applies to all
# shares that don't have a specific entry.
#
# Examples:
#    $Conf{BackupFilesOnly} = '/myFiles';
#    $Conf{BackupFilesOnly} = ['/myFiles'];     # same as first example
#    $Conf{BackupFilesOnly} = ['/myFiles', '/important'];
#    $Conf{BackupFilesOnly} = {
#       'c' => ['/myFiles', '/important'],      # these are for 'c' share
#       'd' => ['/moreFiles', '/archive'],      # these are for 'd' share
#    };
#    $Conf{BackupFilesOnly} = {
#       'c' => ['/myFiles', '/important'],      # these are for 'c' share
#       '*' => ['/myFiles', '/important'],      # these are other shares
#    };
#
$Conf{BackupFilesOnly} = undef;

#
# List of directories or files to exclude from the backup.  For Smb,
# only one of $Conf{BackupFilesExclude} and $Conf{BackupFilesOnly}
# can be specified per share.  If both are set for a particular share,
# then $Conf{BackupFilesOnly} takes precedence and
# $Conf{BackupFilesExclude} is ignored.
#
# This can be set to a string, an array of strings, or, in the case
# of multiple shares, a hash of strings or arrays.  A hash is used
# to give a list of directories or files to exclude for each share
# (the share name is the key).  If this is set to just a string or
# array, and $Conf{SmbShareName} contains multiple share names, then
# the setting is assumed to apply to all shares.
#
# The exact behavior is determined by the underlying transport program,
# smbclient or tar.  For smbclient the exlclude file list is passed into
# the X option.  Simple shell wild-cards using "*" or "?" are allowed.
#
# For tar, if the exclude file contains a "/" it is assumed to be anchored
# at the start of the string.  Since all the tar paths start with "./",
# BackupPC prepends a "." if the exclude file starts with a "/".  Note
# that GNU tar version >= 1.13.7 is required for the exclude option to
# work correctly.  For linux or unix machines you should add
# "/proc" to $Conf{BackupFilesExclude} unless you have specified
# --one-file-system in $Conf{TarClientCmd} or --one-file-system in
# $Conf{RsyncArgs}.  Also, for tar, do not use a trailing "/" in
# the directory name: a trailing "/" causes the name to not match
# and the directory will not be excluded.
#
# Users report that for smbclient you should specify a directory
# followed by "/*", eg: "/proc/*", instead of just "/proc".
#
# FTP servers are traversed recursively so excluding directories will
# also exclude its contents.  You can use the wildcard characters "*"
# and "?" to define files for inclusion and exclusion.  Both
# attributes $Conf{BackupFilesOnly} and $Conf{BackupFilesExclude} can
# be defined for the same share.
#
# If a hash is used, a special key "*" means it applies to all
# shares that don't have a specific entry.
#
# Examples:
#    $Conf{BackupFilesExclude} = '/temp';
#    $Conf{BackupFilesExclude} = ['/temp'];     # same as first example
#    $Conf{BackupFilesExclude} = ['/temp', '/winnt/tmp'];
#    $Conf{BackupFilesExclude} = {
#       'c' => ['/temp', '/winnt/tmp'],         # these are for 'c' share
#       'd' => ['/junk', '/dont_back_this_up'], # these are for 'd' share
#    };
#    $Conf{BackupFilesExclude} = {
#       'c' => ['/temp', '/winnt/tmp'],         # these are for 'c' share
#       '*' => ['/junk', '/dont_back_this_up'], # these are for other shares
#    };
#
$Conf{BackupFilesExclude} = undef;

#
# PCs that are always or often on the network can be backed up after
# hours, to reduce PC, network and server load during working hours. For
# each PC a count of consecutive good pings is maintained. Once a PC has
# at least $Conf{BlackoutGoodCnt} consecutive good pings it is subject
# to "blackout" and not backed up during hours and days specified by
# $Conf{BlackoutPeriods}.
#
# To allow for periodic rebooting of a PC or other brief periods when a
# PC is not on the network, a number of consecutive bad pings is allowed
# before the good ping count is reset. This parameter is
# $Conf{BlackoutBadPingLimit}.
#
# Note that bad and good pings don't occur with the same interval. If a
# machine is always on the network, it will only be pinged roughly once
# every $Conf{IncrPeriod} (eg: once per day). So a setting for
# $Conf{BlackoutGoodCnt} of 7 means it will take around 7 days for a
# machine to be subject to blackout. On the other hand, if a ping is
# failed, it will be retried roughly every time BackupPC wakes up, eg,
# every one or two hours. So a setting for $Conf{BlackoutBadPingLimit} of
# 3 means that the PC will lose its blackout status after 3-6 hours of
# unavailability.
#
# To disable the blackout feature set $Conf{BlackoutGoodCnt} to a negative
# value.  A value of 0 will make all machines subject to blackout.  But
# if you don't want to do any backups during the day it would be easier
# to just set $Conf{WakeupSchedule} to a restricted schedule.
#
$Conf{BlackoutBadPingLimit} = 3;
$Conf{BlackoutGoodCnt}      = 7;

#
# One or more blackout periods can be specified.  If a client is
# subject to blackout then no regular (non-manual) backups will
# be started during any of these periods.  hourBegin and hourEnd
# specify hours fro midnight and weekDays is a list of days of
# the week where 0 is Sunday, 1 is Monday etc.
#
# For example:
#
#    $Conf{BlackoutPeriods} = [
#	{
#	    hourBegin =>  7.0,
#	    hourEnd   => 19.5,
#	    weekDays  => [1, 2, 3, 4, 5],
#	},
#    ];
#
# specifies one blackout period from 7:00am to 7:30pm local time
# on Mon-Fri.
#
# The blackout period can also span midnight by setting
# hourBegin > hourEnd, eg:
#
#    $Conf{BlackoutPeriods} = [
#	{
#	    hourBegin =>  7.0,
#	    hourEnd   => 19.5,
#	    weekDays  => [1, 2, 3, 4, 5],
#	},
#	{
#	    hourBegin => 23,
#	    hourEnd   =>  5,
#	    weekDays  => [5, 6],
#	},
#    ];
#
# This specifies one blackout period from 7:00am to 7:30pm local time
# on Mon-Fri, and a second period from 11pm to 5am on Friday and
# Saturday night.
#
$Conf{BlackoutPeriods} = [
    {
	hourBegin =>  7.0,
	hourEnd   => 19.5,
	weekDays  => [1, 2, 3, 4, 5],
    },
];

#
# A backup of a share that has zero files is considered fatal. This is
# used to catch miscellaneous Xfer errors that result in no files being
# backed up.  If you have shares that might be empty (and therefore an
# empty backup is valid) you should set this flag to 0.
#
$Conf{BackupZeroFilesIsFatal} = 1;

###########################################################################
# How to backup a client
# (can be overridden in the per-PC config.pl)
###########################################################################
#
# What transport method to use to backup each host.  If you have
# a mixed set of WinXX and linux/unix hosts you will need to override
# this in the per-PC config.pl.
#
# The valid values are:
#
#   - 'smb':     backup and restore via smbclient and the SMB protocol.
#                Easiest choice for WinXX.
#
#   - 'rsync':   backup and restore via rsync (via rsh or ssh).
#                Best choice for linux/unix.  Good choice also for WinXX.
#
#   - 'rsyncd':  backup and restore via rsync daemon on the client.
#                Best choice for linux/unix if you have rsyncd running on
#                the client.  Good choice also for WinXX.
#
#   - 'tar':    backup and restore via tar, tar over ssh, rsh or nfs.
#               Good choice for linux/unix.
#
#   - 'archive': host is a special archive host.  Backups are not done.
#                An archive host is used to archive other host's backups
#                to permanent media, such as tape, CDR or DVD.
#               
#
$Conf{XferMethod} = 'smb';

#
# Level of verbosity in Xfer log files.  0 means be quiet, 1 will give
# will give one line per file, 2 will also show skipped files on
# incrementals, higher values give more output.
#
$Conf{XferLogLevel} = 1;

#
# Filename charset encoding on the client.  BackupPC uses utf8
# on the server for filename encoding.  If this is empty, then
# utf8 is assumed and client filenames will not be modified.
# If set to a different encoding then filenames will converted
# to/from utf8 automatically during backup and restore.
#
# If the file names displayed in the browser (eg: accents or special
# characters) don't look right then it is likely you haven't set
# $Conf{ClientCharset} correctly.
#
# If you are using smbclient on a WinXX machine, smbclient will convert
# to the "unix charset" setting in smb.conf.  The default is utf8,
# in which case leave $Conf{ClientCharset} empty since smbclient does
# the right conversion.
#
# If you are using rsync on a WinXX machine then it does no conversion.
# A typical WinXX encoding for latin1/western europe is 'cp1252',
# so in this case set $Conf{ClientCharset} to 'cp1252'.
#
# On a linux or unix client, run "locale charmap" to see the client's
# charset.  Set $Conf{ClientCharset} to this value.  A typical value
# for english/US is 'ISO-8859-1'.
#
# Do "perldoc Encode::Supported" to see the list of possible charset
# values.  The FAQ at http://www.cl.cam.ac.uk/~mgk25/unicode.html
# is excellent, and http://czyborra.com/charsets/iso8859.html
# provides more information on the iso-8859 charsets.
#
$Conf{ClientCharset} = '';

#
# Prior to 3.x no charset conversion was done by BackupPC.  Backups were
# stored in what ever charset the XferMethod provided - typically utf8
# for smbclient and the client's locale settings for rsync and tar (eg:
# cp1252 for rsync on WinXX and perhaps iso-8859-1 with rsync on linux).
# This setting tells BackupPC the charset that was used to store file
# names in old backups taken with BackupPC 2.x, so that non-ascii file
# names in old backups can be viewed and restored.
#
$Conf{ClientCharsetLegacy} = 'iso-8859-1';

###########################################################################
# Samba Configuration
# (can be overwritten in the per-PC log file)
###########################################################################
#
# Name of the host share that is backed up when using SMB.  This can be a
# string or an array of strings if there are multiple shares per host.
# Examples:
#
#   $Conf{SmbShareName} = 'c';          # backup 'c' share
#   $Conf{SmbShareName} = ['c', 'd'];   # backup 'c' and 'd' shares
#
# This setting only matters if $Conf{XferMethod} = 'smb'.
#
$Conf{SmbShareName} = 'C$';

#
# Smbclient share user name.  This is passed to smbclient's -U argument.
#
# This setting only matters if $Conf{XferMethod} = 'smb'.
#
$Conf{SmbShareUserName} = '';

#
# Smbclient share password.  This is passed to smbclient via its PASSWD
# environment variable.  There are several ways you can tell BackupPC
# the smb share password.  In each case you should be very careful about
# security.  If you put the password here, make sure that this file is
# not readable by regular users!  See the "Setting up config.pl" section
# in the documentation for more information.
#
# This setting only matters if $Conf{XferMethod} = 'smb'.
#
$Conf{SmbSharePasswd} = '';

#
# Full path for smbclient. Security caution: normal users should not
# allowed to write to this file or directory.
#
# smbclient is from the Samba distribution. smbclient is used to
# actually extract the incremental or full dump of the share filesystem
# from the PC.
#
# This setting only matters if $Conf{XferMethod} = 'smb'.
#
$Conf{SmbClientPath} = '';

#
# Command to run smbclient for a full dump.
# This setting only matters if $Conf{XferMethod} = 'smb'.
#
# The following variables are substituted at run-time:
#
#    $smbClientPath   same as $Conf{SmbClientPath}
#    $host            host to backup/restore
#    $hostIP          host IP address
#    $shareName       share name
#    $userName        user name
#    $fileList        list of files to backup (based on exclude/include)
#    $I_option        optional -I option to smbclient
#    $X_option        exclude option (if $fileList is an exclude list)
#    $timeStampFile   start time for incremental dump
#
# Note: all Cmds are executed directly without a shell, so the prog name
# needs to be a full path and you can't include shell syntax like
# redirection and pipes; put that in a script if you need it.
#
$Conf{SmbClientFullCmd} = '$smbClientPath \\\\$host\\$shareName'
	    . ' $I_option -U $userName -E -N -d 1'
            . ' -c tarmode\\ full -Tc$X_option - $fileList';

#
# Command to run smbclient for an incremental dump.
# This setting only matters if $Conf{XferMethod} = 'smb'.
#
# Same variable substitutions are applied as $Conf{SmbClientFullCmd}.
#
# Note: all Cmds are executed directly without a shell, so the prog name
# needs to be a full path and you can't include shell syntax like
# redirection and pipes; put that in a script if you need it.
#
$Conf{SmbClientIncrCmd} = '$smbClientPath \\\\$host\\$shareName'
	    . ' $I_option -U $userName -E -N -d 1'
	    . ' -c tarmode\\ full -TcN$X_option $timeStampFile - $fileList';

#
# Command to run smbclient for a restore.
# This setting only matters if $Conf{XferMethod} = 'smb'.
#
# Same variable substitutions are applied as $Conf{SmbClientFullCmd}.
#
# If your smb share is read-only then direct restores will fail.
# You should set $Conf{SmbClientRestoreCmd} to undef and the
# corresponding CGI restore option will be removed.
#
# Note: all Cmds are executed directly without a shell, so the prog name
# needs to be a full path and you can't include shell syntax like
# redirection and pipes; put that in a script if you need it.
#
$Conf{SmbClientRestoreCmd} = '$smbClientPath \\\\$host\\$shareName'
            . ' $I_option -U $userName -E -N -d 1'
            . ' -c tarmode\\ full -Tx -';

###########################################################################
# Tar Configuration
# (can be overwritten in the per-PC log file)
###########################################################################
#
# Which host directories to backup when using tar transport.  This can be a
# string or an array of strings if there are multiple directories to
# backup per host.  Examples:
#
#   $Conf{TarShareName} = '/';			# backup everything
#   $Conf{TarShareName} = '/home';		# only backup /home
#   $Conf{TarShareName} = ['/home', '/src'];	# backup /home and /src
#
# The fact this parameter is called 'TarShareName' is for historical
# consistency with the Smb transport options.  You can use any valid
# directory on the client: there is no need for it to correspond to
# any Smb share or device mount point.
#
# Note also that you can also use $Conf{BackupFilesOnly} to specify
# a specific list of directories to backup.  It's more efficient to
# use this option instead of $Conf{TarShareName} since a new tar is
# run for each entry in $Conf{TarShareName}.
#
# On the other hand, if you add --one-file-system to $Conf{TarClientCmd}
# you can backup each file system separately, which makes restoring one
# bad file system easier.  In this case you would list all of the mount
# points here, since you can't get the same result with
# $Conf{BackupFilesOnly}:
#
#     $Conf{TarShareName} = ['/', '/var', '/data', '/boot'];
#
# This setting only matters if $Conf{XferMethod} = 'tar'.
#
$Conf{TarShareName} = '/';

#
# Full command to run tar on the client.  GNU tar is required.  You will
# need to fill in the correct paths for ssh2 on the local host (server)
# and GNU tar on the client.  Security caution: normal users should not
# allowed to write to these executable files or directories.
#
# See the documentation for more information about setting up ssh2 keys.
#
# If you plan to use NFS then tar just runs locally and ssh2 is not needed.
# For example, assuming the client filesystem is mounted below /mnt/hostName,
# you could use something like:
#
#    $Conf{TarClientCmd} = '$tarPath -c -v -f - -C /mnt/$host/$shareName'
#                        . ' --totals';
#
# In the case of NFS or rsh you need to make sure BackupPC's privileges
# are sufficient to read all the files you want to backup.  Also, you
# will probably want to add "/proc" to $Conf{BackupFilesExclude}.
#
# The following variables are substituted at run-time:
#
#   $host        host name
#   $hostIP      host's IP address
#   $incrDate    newer-than date for incremental backups
#   $shareName   share name to backup (ie: top-level directory path)
#   $fileList    specific files to backup or exclude
#   $tarPath     same as $Conf{TarClientPath}
#   $sshPath     same as $Conf{SshPath}
#
# If a variable is followed by a "+" it is shell escaped.  This is
# necessary for the command part of ssh or rsh, since it ends up
# getting passed through the shell.
#
# This setting only matters if $Conf{XferMethod} = 'tar'.
#
# Note: all Cmds are executed directly without a shell, so the prog name
# needs to be a full path and you can't include shell syntax like
# redirection and pipes; put that in a script if you need it.
#
$Conf{TarClientCmd} = '$sshPath -q -x -n -l root $host'
                    . ' env LC_ALL=C $tarPath -c -v -f - -C $shareName+'
                    . ' --totals';

#
# Extra tar arguments for full backups.  Several variables are substituted at
# run-time.  See $Conf{TarClientCmd} for the list of variable substitutions.
#
# If you are running tar locally (ie: without rsh or ssh) then remove the
# "+" so that the argument is no longer shell escaped.
#
# This setting only matters if $Conf{XferMethod} = 'tar'.
#
$Conf{TarFullArgs} = '$fileList+';

#
# Extra tar arguments for incr backups.  Several variables are substituted at
# run-time.  See $Conf{TarClientCmd} for the list of variable substitutions.
#
# Note that GNU tar has several methods for specifying incremental backups,
# including:
#
#   --newer-mtime $incrDate+
#          This causes a file to be included if the modification time is
#          later than $incrDate (meaning its contents might have changed).
#          But changes in the ownership or modes will not qualify the
#          file to be included in an incremental.
#
#   --newer=$incrDate+
#          This causes the file to be included if any attribute of the
#          file is later than $incrDate, meaning either attributes or
#          the modification time.  This is the default method.  Do
#          not use --atime-preserve in $Conf{TarClientCmd} above,
#          otherwise resetting the atime (access time) counts as an
#          attribute change, meaning the file will always be included
#          in each new incremental dump.
#
# If you are running tar locally (ie: without rsh or ssh) then remove the
# "+" so that the argument is no longer shell escaped.
#
# This setting only matters if $Conf{XferMethod} = 'tar'.
#
$Conf{TarIncrArgs} = '--newer=$incrDate+ $fileList+';

#
# Full command to run tar for restore on the client.  GNU tar is required.
# This can be the same as $Conf{TarClientCmd}, with tar's -c replaced by -x
# and ssh's -n removed.
#
# See $Conf{TarClientCmd} for full details.
#
# This setting only matters if $Conf{XferMethod} = "tar".
#
# If you want to disable direct restores using tar, you should set
# $Conf{TarClientRestoreCmd} to undef and the corresponding CGI
# restore option will be removed.
#
# Note: all Cmds are executed directly without a shell, so the prog name
# needs to be a full path and you can't include shell syntax like
# redirection and pipes; put that in a script if you need it.
#
$Conf{TarClientRestoreCmd} = '$sshPath -q -x -l root $host'
		   . ' env LC_ALL=C $tarPath -x -p --numeric-owner --same-owner'
		   . ' -v -f - -C $shareName+';

#
# Full path for tar on the client. Security caution: normal users should not
# allowed to write to this file or directory.
#
# This setting only matters if $Conf{XferMethod} = 'tar'.
#
$Conf{TarClientPath} = '';

###########################################################################
# Rsync/Rsyncd Configuration
# (can be overwritten in the per-PC log file)
###########################################################################
#
# Path to rsync executable on the client
#
$Conf{RsyncClientPath} = '';

#
# Full command to run rsync on the client machine.  The following variables
# are substituted at run-time:
#
#        $host           host name being backed up
#        $hostIP         host's IP address
#        $shareName      share name to backup (ie: top-level directory path)
#        $rsyncPath      same as $Conf{RsyncClientPath}
#        $sshPath        same as $Conf{SshPath}
#        $argList        argument list, built from $Conf{RsyncArgs},
#                        $shareName, $Conf{BackupFilesExclude} and
#                        $Conf{BackupFilesOnly}
#
# This setting only matters if $Conf{XferMethod} = 'rsync'.
#
$Conf{RsyncClientCmd} = '$sshPath -q -x -l root $host $rsyncPath $argList+';

#
# Full command to run rsync for restore on the client.  The following
# variables are substituted at run-time:
#
#        $host           host name being backed up
#        $hostIP         host's IP address
#        $shareName      share name to backup (ie: top-level directory path)
#        $rsyncPath      same as $Conf{RsyncClientPath}
#        $sshPath        same as $Conf{SshPath}
#        $argList        argument list, built from $Conf{RsyncArgs},
#                        $shareName, $Conf{BackupFilesExclude} and
#                        $Conf{BackupFilesOnly}
#
# This setting only matters if $Conf{XferMethod} = 'rsync'.
#
# Note: all Cmds are executed directly without a shell, so the prog name
# needs to be a full path and you can't include shell syntax like
# redirection and pipes; put that in a script if you need it.
#
$Conf{RsyncClientRestoreCmd} = '$sshPath -q -x -l root $host $rsyncPath $argList+';

#
# Share name to backup.  For $Conf{XferMethod} = "rsync" this should
# be a file system path, eg '/' or '/home'.
#
# For $Conf{XferMethod} = "rsyncd" this should be the name of the module
# to backup (ie: the name from /etc/rsynd.conf).
#
# This can also be a list of multiple file system paths or modules.
# For example, by adding --one-file-system to $Conf{RsyncArgs} you
# can backup each file system separately, which makes restoring one
# bad file system easier.  In this case you would list all of the mount
# points:
#
#     $Conf{RsyncShareName} = ['/', '/var', '/data', '/boot'];
#
$Conf{RsyncShareName} = '/';

#
# Rsync daemon port on the client, for $Conf{XferMethod} = "rsyncd".
#
$Conf{RsyncdClientPort} = 873;

#
# Rsync daemon user name on client, for $Conf{XferMethod} = "rsyncd".
# The user name and password are stored on the client in whatever file
# the "secrets file" parameter in rsyncd.conf points to
# (eg: /etc/rsyncd.secrets).
#
$Conf{RsyncdUserName} = '';

#
# Rsync daemon user name on client, for $Conf{XferMethod} = "rsyncd".
# The user name and password are stored on the client in whatever file
# the "secrets file" parameter in rsyncd.conf points to
# (eg: /etc/rsyncd.secrets).
#
$Conf{RsyncdPasswd} = '';

#
# Whether authentication is mandatory when connecting to the client's
# rsyncd.  By default this is on, ensuring that BackupPC will refuse to
# connect to an rsyncd on the client that is not password protected.
# Turn off at your own risk.
#
$Conf{RsyncdAuthRequired} = 1;

#
# When rsync checksum caching is enabled (by adding the
# --checksum-seed=32761 option to $Conf{RsyncArgs}), the cached
# checksums can be occasionally verified to make sure the file
# contents matches the cached checksums.  This is to avoid the
# risk that disk problems might cause the pool file contents to
# get corrupted, but the cached checksums would make BackupPC
# think that the file still matches the client.
#
# This setting is the probability (0 means never and 1 means always)
# that a file will be rechecked.  Setting it to 0 means the checksums
# will not be rechecked (unless there is a phase 0 failure).  Setting
# it to 1 (ie: 100%) means all files will be checked, but that is
# not a desirable setting since you are better off simply turning
# caching off (ie: remove the --checksum-seed option).
#   
# The default of 0.01 means 1% (on average) of the files during a full
# backup will have their cached checksum re-checked.
#   
# This setting has no effect unless checksum caching is turned on.
#   
$Conf{RsyncCsumCacheVerifyProb} = 0.01;

#
# Arguments to rsync for backup.  Do not edit the first set unless you
# have a thorough understanding of how File::RsyncP works.
#
$Conf{RsyncArgs} = [
	    #
	    # Do not edit these!
	    #
            '--numeric-ids',
            '--perms',
            '--owner',
            '--group',
            '-D',
            '--links',
            '--hard-links',
            '--times',
            '--block-size=2048',
            '--recursive',

	    #
	    # Rsync >= 2.6.3 supports the --checksum-seed option
            # which allows rsync checksum caching on the server.
	    # Uncomment this to enable rsync checksum caching if
            # you have a recent client rsync version and you want
            # to enable checksum caching.
	    #
	    #'--checksum-seed=32761',
];

#
# Additional arguments added to RsyncArgs.  This can be used in
# conbination with $Conf{RsyncArgs} to allow customization of
# the rsync arguments on a part-client basis.  The standard
# arguments go in $Conf{RsyncArgs} and $Conf{RsyncArgsExtra}
# can be set on a per-client basis.
#
# Examples of additional arguments that should work are --exclude/--include,
# eg:
#
#     $Conf{RsyncArgsExtra} = [
#           '--exclude', '/proc',
#           '--exclude', '*.tmp',
#     ];
#
# Both $Conf{RsyncArgs} and $Conf{RsyncArgsExtra} are subject
# to the following variable substitutions:
#
#        $client       client name being backed up
#        $host         host name (could be different from client name if
#                                 $Conf{ClientNameAlias} is set)
#        $hostIP       IP address of host
#        $confDir      configuration directory path
#
# This allows settings of the form:
#
#     $Conf{RsyncArgsExtra} = [
#             '--exclude-from=$confDir/pc/$host.exclude',
#     ];
#
$Conf{RsyncArgsExtra} = [];

#
# Arguments to rsync for restore.  Do not edit the first set unless you
# have a thorough understanding of how File::RsyncP works.
#
# If you want to disable direct restores using rsync (eg: is the module
# is read-only), you should set $Conf{RsyncRestoreArgs} to undef and
# the corresponding CGI restore option will be removed.
#
# $Conf{RsyncRestoreArgs} is subject to the following variable
# substitutions:
#
#        $client       client name being backed up
#        $host         host name (could be different from client name if
#                                 $Conf{ClientNameAlias} is set)
#        $hostIP       IP address of host
#        $confDir      configuration directory path
#
# Note: $Conf{RsyncArgsExtra} doesn't apply to $Conf{RsyncRestoreArgs}.
#
$Conf{RsyncRestoreArgs} = [
	    #
	    # Do not edit these!
	    #
	    '--numeric-ids',
	    '--perms',
	    '--owner',
	    '--group',
	    '-D',
	    '--links',
            '--hard-links',
	    '--times',
	    '--block-size=2048',
	    '--relative',
	    '--ignore-times',
	    '--recursive',

	    #
	    # Rsync >= 2.6.3 supports the --checksum-seed option
            # which allows rsync checksum caching on the server.
	    # Uncomment this to enable rsync checksum caching if
            # you have a recent client rsync version and you want
            # to enable checksum caching.
	    #
	    #'--checksum-seed=32761',

	    #
	    # Add additional arguments here
	    #
];

###########################################################################
# FTP Configuration
# (can be overwritten in the per-PC log file)
##########################################################################
#
# Which host directories to backup when using FTP.  This can be a
# string or an array of strings if there are multiple shares per host.
#
# This value must be specified in one of two ways: either as a
# subdirectory of the 'share root' on the server, or as the absolute
# path of the directory.
#
# In the following example, if the directory /home/username is the
# root share of the ftp server with the given username, the following
# two values will back up the same directory:
#
#    $Conf{FtpShareName} = 'www';                # www directory
#    $Conf{FtpShareName} = '/home/username/www'; # same directory
#
# Path resolution is not supported; i.e.; you may not have an ftp
# share path defined as '../otheruser' or '~/games'.
#
#  Multiple shares may also be specified, as with other protocols:
#
#    $Conf{FtpShareName} = [ 'www',
#                            'bin',
#                            'config' ];
#
# Note also that you can also use $Conf{BackupFilesOnly} to specify
# a specific list of directories to backup.  It's more efficient to
# use this option instead of $Conf{FtpShareName} since a new tar is
# run for each entry in $Conf{FtpShareName}.
#
# This setting only matters if $Conf{XferMethod} = 'ftp'.
#
$Conf{FtpShareName} = '';

#
# FTP user name.  This is used to log into the server.
#
# This setting is used only if $Conf{XferMethod} = 'ftp'.
#
$Conf{FtpUserName} = '';

#
# FTP user password.  This is used to log into the server.
#
# This setting is used only if $Conf{XferMethod} = 'ftp'.
#
$Conf{FtpPasswd} = '';

#
# Whether passive mode is used.  The correct setting depends upon
# whether local or remote ports are accessible from the other machine,
# which is affected by any firewall or routers between the FTP server
# on the client and the BackupPC server.
#
# This setting is used only if $Conf{XferMethod} = 'ftp'.
#
$Conf{FtpPassive} = 1;

#
# Transfer block size. This sets the size of the amounts of data in
# each frame. While undefined, this value takes the default value.
#
# This setting is used only if $Conf{XferMethod} = 'ftp'.
#
$Conf{FtpBlockSize} = 10240;

#
# The port of the ftp server.  If undefined, 21 is used.
#
# This setting is used only if $Conf{XferMethod} = 'ftp'.
#
$Conf{FtpPort} = 21;

#
# Connection timeout for FTP.  When undefined, the default is 120 seconds.
#
# This setting is used only if $Conf{XferMethod} = 'ftp'.
#
$Conf{FtpTimeout} = 120;

#
# Behaviour when BackupPC encounters symlinks on the FTP share.
#
# Symlinks cannot be restored via FTP, so the desired behaviour will
# be different depending on the setup of the share. The default for
# this behavor is 1.  Directory shares with more complicated directory
# structures should consider other protocols.
#
$Conf{FtpFollowSymlinks} = 0;

###########################################################################
# Archive Configuration
# (can be overwritten in the per-PC log file)
###########################################################################
#
# Archive Destination
#
# The Destination of the archive
# e.g. /tmp for file archive or /dev/nst0 for device archive
#
$Conf{ArchiveDest} = '/tmp';

#
# Archive Compression type
#
# The valid values are:
#
#   - 'none':  No Compression
#
#   - 'gzip':  Medium Compression. Recommended.
#
#   - 'bzip2': High Compression but takes longer.
#
$Conf{ArchiveComp} = 'gzip';

#
# Archive Parity Files
#
# The amount of Parity data to generate, as a percentage
# of the archive size.
# Uses the commandline par2 (par2cmdline) available from
# http://parchive.sourceforge.net
#
# Only useful for file dumps.
#
# Set to 0 to disable this feature.
#
$Conf{ArchivePar} = 0;

#
# Archive Size Split
#
# Only for file archives. Splits the output into 
# the specified size * 1,000,000.
# e.g. to split into 650,000,000 bytes, specify 650 below.
# 
# If the value is 0, or if $Conf{ArchiveDest} is an existing file or
# device (e.g. a streaming tape drive), this feature is disabled.
#
$Conf{ArchiveSplit} = 0;

#
# Archive Command
#
# This is the command that is called to actually run the archive process
# for each host.  The following variables are substituted at run-time:
#
#   $Installdir    The installation directory of BackupPC
#   $tarCreatePath The path to BackupPC_tarCreate
#   $splitpath     The path to the split program
#   $parpath       The path to the par2 program
#   $host          The host to archive
#   $backupnumber  The backup number of the host to archive
#   $compression   The path to the compression program
#   $compext       The extension assigned to the compression type
#   $splitsize     The number of bytes to split archives into
#   $archiveloc    The location to put the archive
#   $parfile       The amount of parity data to create (percentage)
#
# Note: all Cmds are executed directly without a shell, so the prog name
# needs to be a full path and you can't include shell syntax like
# redirection and pipes; put that in a script if you need it.
#
$Conf{ArchiveClientCmd} = '$Installdir/bin/BackupPC_archiveHost'
	. ' $tarCreatePath $splitpath $parpath $host $backupnumber'
	. ' $compression $compext $splitsize $archiveloc $parfile *';

#
# Full path for ssh. Security caution: normal users should not
# allowed to write to this file or directory.
#
$Conf{SshPath} = '';

#
# Full path for nmblookup. Security caution: normal users should not
# allowed to write to this file or directory.
#
# nmblookup is from the Samba distribution. nmblookup is used to get the
# netbios name, necessary for DHCP hosts.
#
$Conf{NmbLookupPath} = '';

#
# NmbLookup command.  Given an IP address, does an nmblookup on that
# IP address.  The following variables are substituted at run-time:
#
#   $nmbLookupPath      path to nmblookup ($Conf{NmbLookupPath})
#   $host               IP address
#
# This command is only used for DHCP hosts: given an IP address, this
# command should try to find its NetBios name.
#
# Note: all Cmds are executed directly without a shell, so the prog name
# needs to be a full path and you can't include shell syntax like
# redirection and pipes; put that in a script if you need it.
#
$Conf{NmbLookupCmd} = '$nmbLookupPath -A $host';

#
# NmbLookup command.  Given a netbios name, finds that host by doing
# a NetBios lookup.  Several variables are substituted at run-time:
#
#   $nmbLookupPath      path to nmblookup ($Conf{NmbLookupPath})
#   $host               NetBios name
#
# In some cases you might need to change the broadcast address, for
# example if nmblookup uses 192.168.255.255 by default and you find
# that doesn't work, try 192.168.1.255 (or your equivalent class C
# address) using the -B option:
#
#    $Conf{NmbLookupFindHostCmd} = '$nmbLookupPath -B 192.168.1.255 $host';
#
# If you use a WINS server and your machines don't respond to
# multicast NetBios requests you can use this (replace 1.2.3.4
# with the IP address of your WINS server):
#
#    $Conf{NmbLookupFindHostCmd} = '$nmbLookupPath -R -U 1.2.3.4 $host';
#
# This is preferred over multicast since it minimizes network traffic.
#
# Experiment manually for your site to see what form of nmblookup command
# works.
#
# Note: all Cmds are executed directly without a shell, so the prog name
# needs to be a full path and you can't include shell syntax like
# redirection and pipes; put that in a script if you need it.
#
$Conf{NmbLookupFindHostCmd} = '$nmbLookupPath $host';

#
# For fixed IP address hosts, BackupPC_dump can also verify the netbios
# name to ensure it matches the host name.  An error is generated if
# they do not match.  Typically this flag is off.  But if you are going
# to transition a bunch of machines from fixed host addresses to DHCP,
# setting this flag is a great way to verify that the machines have
# their netbios name set correctly before turning on DCHP.
#
$Conf{FixedIPNetBiosNameCheck} = 0;

#
# Full path to the ping command.  Security caution: normal users
# should not be allowed to write to this file or directory.
#
# If you want to disable ping checking, set this to some program
# that exits with 0 status, eg:
#
#     $Conf{PingPath} = '/bin/echo';
#
$Conf{PingPath} = '';

#
# Ping command.  The following variables are substituted at run-time:
#
#   $pingPath      path to ping ($Conf{PingPath})
#   $host          host name
#
# Wade Brown reports that on solaris 2.6 and 2.7 ping -s returns the wrong
# exit status (0 even on failure).  Replace with "ping $host 1", which
# gets the correct exit status but we don't get the round-trip time.
#
# Note: all Cmds are executed directly without a shell, so the prog name
# needs to be a full path and you can't include shell syntax like
# redirection and pipes; put that in a script if you need it.
#
$Conf{PingCmd} = '$pingPath -c 1 $host';

#
# Maximum round-trip ping time in milliseconds.  This threshold is set
# to avoid backing up PCs that are remotely connected through WAN or
# dialup connections.  The output from ping -s (assuming it is supported
# on your system) is used to check the round-trip packet time.  On your
# local LAN round-trip times should be much less than 20msec.  On most
# WAN or dialup connections the round-trip time will be typically more
# than 20msec.  Tune if necessary.
#
$Conf{PingMaxMsec} = 20;

#
# Compression level to use on files.  0 means no compression.  Compression
# levels can be from 1 (least cpu time, slightly worse compression) to
# 9 (most cpu time, slightly better compression).  The recommended value
# is 3.  Changing to 5, for example, will take maybe 20% more cpu time
# and will get another 2-3% additional compression. See the zlib
# documentation for more information about compression levels.
#
# Changing compression on or off after backups have already been done
# will require both compressed and uncompressed pool files to be stored.
# This will increase the pool storage requirements, at least until all
# the old backups expire and are deleted.
#
# It is ok to change the compression value (from one non-zero value to
# another non-zero value) after dumps are already done.  Since BackupPC
# matches pool files by comparing the uncompressed versions, it will still
# correctly match new incoming files against existing pool files.  The
# new compression level will take effect only for new files that are
# newly compressed and added to the pool.
#
# If compression was off and you are enabling compression for the first
# time you can use the BackupPC_compressPool utility to compress the
# pool.  This avoids having the pool grow to accommodate both compressed
# and uncompressed backups.  See the documentation for more information.
#
# Note: compression needs the Compress::Zlib perl library.  If the
# Compress::Zlib library can't be found then $Conf{CompressLevel} is
# forced to 0 (compression off).
#
$Conf{CompressLevel} = 0;

#
# Timeout in seconds when listening for the transport program's
# (smbclient, tar etc) stdout. If no output is received during this
# time, then it is assumed that something has wedged during a backup,
# and the backup is terminated.
#
# Note that stdout buffering combined with huge files being backed up
# could cause longish delays in the output from smbclient that
# BackupPC_dump sees, so in rare cases you might want to increase
# this value.
#
# Despite the name, this parameter sets the timeout for all transport
# methods (tar, smb etc).
#
$Conf{ClientTimeout} = 72000;

#
# Maximum number of log files we keep around in each PC's directory
# (ie: pc/$host).  These files are aged monthly.  A setting of 12
# means there will be at most the files LOG, LOG.0, LOG.1, ... LOG.11
# in the pc/$host directory (ie: about a years worth).  (Except this
# month's LOG, these files will have a .z extension if compression
# is on).
#
# If you decrease this number after BackupPC has been running for a
# while you will have to manually remove the older log files.
#
$Conf{MaxOldPerPCLogFiles} = 12;

#
# Optional commands to run before and after dumps and restores,
# and also before and after each share of a dump.
#
# Stdout from these commands will be written to the Xfer (or Restore)
# log file.  One example of using these commands would be to
# shut down and restart a database server, dump a database
# to files for backup, or doing a snapshot of a share prior
# to a backup.  Example:
#
#    $Conf{DumpPreUserCmd} = '$sshPath -q -x -l root $host /usr/bin/dumpMysql';
#
# The following variable substitutions are made at run time for
# $Conf{DumpPreUserCmd}, $Conf{DumpPostUserCmd}, $Conf{DumpPreShareCmd}
# and $Conf{DumpPostShareCmd}:
#
#        $type         type of dump (incr or full)
#        $xferOK       1 if the dump succeeded, 0 if it didn't
#        $client       client name being backed up
#        $host         host name (could be different from client name if
#                                 $Conf{ClientNameAlias} is set)
#        $hostIP       IP address of host
#        $user         user name from the hosts file
#        $moreUsers    list of additional users from the hosts file
#        $share        the first share name (or current share for
#                        $Conf{DumpPreShareCmd} and $Conf{DumpPostShareCmd})
#        $shares       list of all the share names
#        $XferMethod   value of $Conf{XferMethod} (eg: tar, rsync, smb)
#        $sshPath      value of $Conf{SshPath},
#        $cmdType      set to DumpPreUserCmd or DumpPostUserCmd
#
# The following variable substitutions are made at run time for
# $Conf{RestorePreUserCmd} and $Conf{RestorePostUserCmd}:
#
#        $client       client name being backed up
#        $xferOK       1 if the restore succeeded, 0 if it didn't
#        $host         host name (could be different from client name if
#                                 $Conf{ClientNameAlias} is set)
#        $hostIP       IP address of host
#        $user         user name from the hosts file
#        $moreUsers    list of additional users from the hosts file
#        $share        the first share name
#        $XferMethod   value of $Conf{XferMethod} (eg: tar, rsync, smb)
#        $sshPath      value of $Conf{SshPath},
#        $type         set to "restore"
#        $bkupSrcHost  host name of the restore source
#        $bkupSrcShare share name of the restore source
#        $bkupSrcNum   backup number of the restore source
#        $pathHdrSrc   common starting path of restore source
#        $pathHdrDest  common starting path of destination
#        $fileList     list of files being restored
#        $cmdType      set to RestorePreUserCmd or RestorePostUserCmd
#
# The following variable substitutions are made at run time for
# $Conf{ArchivePreUserCmd} and $Conf{ArchivePostUserCmd}:
#
#        $client       client name being backed up
#        $xferOK       1 if the archive succeeded, 0 if it didn't
#        $host         Name of the archive host
#        $user         user name from the hosts file
#        $share        the first share name
#        $XferMethod   value of $Conf{XferMethod} (eg: tar, rsync, smb)
#        $HostList     list of hosts being archived
#        $BackupList   list of backup numbers for the hosts being archived
#        $archiveloc   location where the archive is sent to
#        $parfile      amount of parity data being generated (percentage)
#        $compression  compression program being used (eg: cat, gzip, bzip2)
#        $compext      extension used for compression type (eg: raw, gz, bz2)
#        $splitsize    size of the files that the archive creates
#        $sshPath      value of $Conf{SshPath},
#        $type         set to "archive"
#        $cmdType      set to ArchivePreUserCmd or ArchivePostUserCmd
#
# Note: all Cmds are executed directly without a shell, so the prog name
# needs to be a full path and you can't include shell syntax like
# redirection and pipes; put that in a script if you need it.
#
$Conf{DumpPreUserCmd}     = undef;
$Conf{DumpPostUserCmd}    = undef;
$Conf{DumpPreShareCmd}    = undef;
$Conf{DumpPostShareCmd}   = undef;
$Conf{RestorePreUserCmd}  = undef;
$Conf{RestorePostUserCmd} = undef;
$Conf{ArchivePreUserCmd}  = undef;
$Conf{ArchivePostUserCmd} = undef;

#
# Whether the exit status of each PreUserCmd and
# PostUserCmd is checked.
#
# If set and the Dump/Restore/Archive Pre/Post UserCmd
# returns a non-zero exit status then the dump/restore/archive
# is aborted.  To maintain backward compatibility (where
# the exit status in early versions was always ignored),
# this flag defaults to 0.
#
# If this flag is set and the Dump/Restore/Archive PreUserCmd
# fails then the matching Dump/Restore/Archive PostUserCmd is
# not executed.  If DumpPreShareCmd returns a non-exit status,
# then DumpPostShareCmd is not executed, but the DumpPostUserCmd
# is still run (since DumpPreUserCmd must have previously
# succeeded).
#
# An example of a DumpPreUserCmd that might fail is a script
# that snapshots or dumps a database which fails because
# of some database error.
#
$Conf{UserCmdCheckStatus} = 0;

#
# Override the client's host name.  This allows multiple clients
# to all refer to the same physical host.  This should only be
# set in the per-PC config file and is only used by BackupPC at
# the last moment prior to generating the command used to backup
# that machine (ie: the value of $Conf{ClientNameAlias} is invisible
# everywhere else in BackupPC).  The setting can be a host name or
# IP address, eg:
#
#         $Conf{ClientNameAlias} = 'realHostName';
#         $Conf{ClientNameAlias} = '192.1.1.15';
#
# will cause the relevant smb/tar/rsync backup/restore commands to be
# directed to realHostName, not the client name.
#
# Note: this setting doesn't work for hosts with DHCP set to 1.
#
$Conf{ClientNameAlias} = undef;

###########################################################################
# Email reminders, status and messages
# (can be overridden in the per-PC config.pl)
###########################################################################
#
# Full path to the sendmail command.  Security caution: normal users
# should not allowed to write to this file or directory.
#
$Conf{SendmailPath} = '';

#
# Minimum period between consecutive emails to a single user.
# This tries to keep annoying email to users to a reasonable
# level.  Email checks are done nightly, so this number is effectively
# rounded up (ie: 2.5 means a user will never receive email more
# than once every 3 days).
#
$Conf{EMailNotifyMinDays} = 2.5;

#
# Name to use as the "from" name for email.  Depending upon your mail
# handler this is either a plain name (eg: "admin") or a fully-qualified
# name (eg: "admin@mydomain.com").
#
$Conf{EMailFromUserName} = '';

#
# Destination address to an administrative user who will receive a
# nightly email with warnings and errors.  If there are no warnings
# or errors then no email will be sent.  Depending upon your mail
# handler this is either a plain name (eg: "admin") or a fully-qualified
# name (eg: "admin@mydomain.com").
#
$Conf{EMailAdminUserName} = '';

#
# Destination domain name for email sent to users.  By default
# this is empty, meaning email is sent to plain, unqualified
# addresses.  Otherwise, set it to the destintation domain, eg:
#
#    $Cong{EMailUserDestDomain} = '@mydomain.com';
#
# With this setting user email will be set to 'user@mydomain.com'.
#
$Conf{EMailUserDestDomain} = '';

#
# This subject and message is sent to a user if their PC has never been
# backed up.
#
# These values are language-dependent.  The default versions can be
# found in the language file (eg: lib/BackupPC/Lang/en.pm).  If you
# need to change the message, copy it here and edit it, eg:
#
#   $Conf{EMailNoBackupEverMesg} = <<'EOF';
#   To: $user$domain
#   cc:
#   Subject: $subj
#   
#   Dear $userName,
#   
#   This is a site-specific email message.
#   EOF
#
$Conf{EMailNoBackupEverSubj} = undef;
$Conf{EMailNoBackupEverMesg} = undef;

#
# How old the most recent backup has to be before notifying user.
# When there have been no backups in this number of days the user
# is sent an email.
#
$Conf{EMailNotifyOldBackupDays} = 7.0;

#
# This subject and message is sent to a user if their PC has not recently
# been backed up (ie: more than $Conf{EMailNotifyOldBackupDays} days ago).
#
# These values are language-dependent.  The default versions can be
# found in the language file (eg: lib/BackupPC/Lang/en.pm).  If you
# need to change the message, copy it here and edit it, eg:
#
#   $Conf{EMailNoBackupRecentMesg} = <<'EOF';
#   To: $user$domain
#   cc:
#   Subject: $subj
#   
#   Dear $userName,
#   
#   This is a site-specific email message.
#   EOF
#
$Conf{EMailNoBackupRecentSubj} = undef;
$Conf{EMailNoBackupRecentMesg} = undef;

#
# How old the most recent backup of Outlook files has to be before
# notifying user.
#
$Conf{EMailNotifyOldOutlookDays} = 5.0;

#
# This subject and message is sent to a user if their Outlook files have
# not recently been backed up (ie: more than $Conf{EMailNotifyOldOutlookDays}
# days ago).
#
# These values are language-dependent.  The default versions can be
# found in the language file (eg: lib/BackupPC/Lang/en.pm).  If you
# need to change the message, copy it here and edit it, eg:
#
#   $Conf{EMailOutlookBackupMesg} = <<'EOF';
#   To: $user$domain
#   cc:
#   Subject: $subj
#   
#   Dear $userName,
#   
#   This is a site-specific email message.
#   EOF
#
$Conf{EMailOutlookBackupSubj} = undef;
$Conf{EMailOutlookBackupMesg} = undef;

#
# Additional email headers.  This sets to charset to
# utf8.
#
$Conf{EMailHeaders} = <<EOF;
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
EOF

###########################################################################
# CGI user interface configuration settings
# (can be overridden in the per-PC config.pl)
###########################################################################
#
# Normal users can only access information specific to their host.
# They can start/stop/browse/restore backups.
#
# Administrative users have full access to all hosts, plus overall
# status and log information.
#
# The administrative users are the union of the unix/linux group
# $Conf{CgiAdminUserGroup} and the manual list of users, separated
# by spaces, in $Conf{CgiAdminUsers}. If you don't want a group or
# manual list of users set the corresponding configuration setting
# to undef or an empty string.
#
# If you want every user to have admin privileges (careful!), set
# $Conf{CgiAdminUsers} = '*'.
#
# Examples:
#    $Conf{CgiAdminUserGroup} = 'admin';
#    $Conf{CgiAdminUsers}     = 'craig celia';
#    --> administrative users are the union of group admin, plus
#      craig and celia.
#
#    $Conf{CgiAdminUserGroup} = '';
#    $Conf{CgiAdminUsers}     = 'craig celia';
#    --> administrative users are only craig and celia'.
#
$Conf{CgiAdminUserGroup} = '';
$Conf{CgiAdminUsers}     = '';

#
# URL of the BackupPC_Admin CGI script.  Used for email messages.
#
$Conf{CgiURL} = undef;

#   
# Language to use.  See lib/BackupPC/Lang for the list of supported
# languages, which include English (en), French (fr), Spanish (es),
# German (de), Italian (it), Dutch (nl), Polish (pl), Portuguese
# Brazillian (pt_br) and Chinese (zh_CH).
#
# Currently the Language setting applies to the CGI interface and email
# messages sent to users.  Log files and other text are still in English.
#
$Conf{Language} = 'en';

#
# User names that are rendered by the CGI interface can be turned
# into links into their home page or other information about the
# user.  To set this up you need to create two sprintf() strings,
# that each contain a single '%s' that will be replaced by the user
# name.  The default is a mailto: link.
#
# $Conf{CgiUserHomePageCheck} should be an absolute file path that
# is used to check (via "-f") that the user has a valid home page.
# Set this to undef or an empty string to turn off this check.
#
# $Conf{CgiUserUrlCreate} should be a full URL that points to the
# user's home page.  Set this to undef or an empty string to turn
# off generation of URLs for user names.
#
# Example:
#    $Conf{CgiUserHomePageCheck} = '/var/www/html/users/%s.html';
#    $Conf{CgiUserUrlCreate}     = 'http://myhost/users/%s.html';
#    --> if /var/www/html/users/craig.html exists, then 'craig' will
#      be rendered as a link to http://myhost/users/craig.html.
#
$Conf{CgiUserHomePageCheck} = '';
$Conf{CgiUserUrlCreate}     = 'mailto:%s';

#
# Date display format for CGI interface.  A value of 1 uses US-style
# dates (MM/DD), a value of 2 uses full YYYY-MM-DD format, and zero
# for international dates (DD/MM).
#
$Conf{CgiDateFormatMMDD} = 1;

#
# If set, the complete list of hosts appears in the left navigation
# bar pull-down for administrators.  Otherwise, just the hosts for which
# the user is listed in the host file (as either the user or in moreUsers)
# are displayed.
#
$Conf{CgiNavBarAdminAllHosts} = 1;

#
# Enable/disable the search box in the navigation bar.
#
$Conf{CgiSearchBoxEnable} = 1;

#
# Additional navigation bar links.  These appear for both regular users
# and administrators.  This is a list of hashes giving the link (URL)
# and the text (name) for the link.  Specifying lname instead of name
# uses the language specific string (ie: $Lang->{lname}) instead of
# just literally displaying name.
#
$Conf{CgiNavBarLinks} = [
    {
        link  => "?action=view&type=docs",
        lname => "Documentation",    # actually displays $Lang->{Documentation}
    },
    {
        link  => "http://backuppc.wiki.sourceforge.net",
        name  => "Wiki",              # displays literal "Wiki"
    },
    {
        link  => "http://backuppc.sourceforge.net",
        name  => "SourceForge",      # displays literal "SourceForge"
    },
];

#
# Hilight colors based on status that are used in the PC summary page.
#
$Conf{CgiStatusHilightColor} = {
    Reason_backup_failed           => '#ffcccc',
    Reason_backup_done             => '#ccffcc',
    Reason_no_ping                 => '#ffff99',
    Reason_backup_canceled_by_user => '#ff9900',
    Status_backup_in_progress      => '#66cc99',
    Disabled_OnlyManualBackups     => '#d1d1d1',   
    Disabled_AllBackupsDisabled    => '#d1d1d1',          
};

#
# Additional CGI header text.
#
$Conf{CgiHeaders} = '<meta http-equiv="pragma" content="no-cache">';

#
# Directory where images are stored.  This directory should be below
# Apache's DocumentRoot.  This value isn't used by BackupPC but is
# used by configure.pl when you upgrade BackupPC.
#
# Example:
#     $Conf{CgiImageDir} = '/var/www/htdocs/BackupPC';
#
$Conf{CgiImageDir} = '';

#
# Additional mappings of file name extenions to Content-Type for
# individual file restore.  See $Ext2ContentType in BackupPC_Admin
# for the default setting.  You can add additional settings here,
# or override any default settings.  Example:
#
#     $Conf{CgiExt2ContentType} = {
#                 'pl'  => 'text/plain',
#          };
#
$Conf{CgiExt2ContentType} = { };

#
# URL (without the leading http://host) for BackupPC's image directory.
# The CGI script uses this value to serve up image files.
#
# Example:
#     $Conf{CgiImageDirURL} = '/BackupPC';
#
$Conf{CgiImageDirURL} = '';

#
# CSS stylesheet "skin" for the CGI interface.  It is stored
# in the $Conf{CgiImageDir} directory and accessed via the
# $Conf{CgiImageDirURL} URL.
#
# For BackupPC v3.x several color, layout and font changes were made.
# The previous v2.x version is available as BackupPC_stnd_orig.css, so
# if you prefer the old skin, change this to BackupPC_stnd_orig.css.
#
$Conf{CgiCSSFile} = 'BackupPC_stnd.css';

#
# Whether the user is allowed to edit their per-PC config.
#
$Conf{CgiUserConfigEditEnable} = 1;

#
# Which per-host config variables a non-admin user is allowed
# to edit.  Admin users can edit all per-host config variables,
# even if disabled in this list.
#
# SECURITY WARNING: Do not let users edit any of the Cmd
# config variables!  That's because a user could set a
# Cmd to a shell script of their choice and it will be
# run as the BackupPC user.  That script could do all
# sorts of bad things.
#
$Conf{CgiUserConfigEdit} = {
        FullPeriod                => 1,
        IncrPeriod                => 1,
        FullKeepCnt               => 1,
        FullKeepCntMin            => 1,
        FullAgeMax                => 1,
        IncrKeepCnt               => 1,
        IncrKeepCntMin            => 1,
        IncrAgeMax                => 1,
        IncrLevels                => 1,
        IncrFill                  => 1,
        PartialAgeMax             => 1,
        RestoreInfoKeepCnt        => 1,
        ArchiveInfoKeepCnt        => 1,
        BackupFilesOnly           => 1,
        BackupFilesExclude        => 1,
        BackupsDisable            => 1,
        BlackoutBadPingLimit      => 1,
        BlackoutGoodCnt           => 1,
        BlackoutPeriods           => 1,
        BackupZeroFilesIsFatal    => 1,
        ClientCharset             => 1,
        ClientCharsetLegacy       => 1,
        XferMethod                => 1,
        XferLogLevel              => 1,
        SmbShareName              => 1,
        SmbShareUserName          => 1,
        SmbSharePasswd            => 1,
        SmbClientFullCmd          => 0,
        SmbClientIncrCmd          => 0,
        SmbClientRestoreCmd       => 0,
        TarShareName              => 1,
        TarFullArgs               => 1,
        TarIncrArgs               => 1,
        TarClientCmd              => 0,
        TarClientRestoreCmd       => 0,
        TarClientPath             => 0,
        RsyncShareName            => 1,
        RsyncdClientPort          => 1,
        RsyncdPasswd              => 1,
        RsyncdUserName            => 1,
        RsyncdAuthRequired        => 1,
        RsyncCsumCacheVerifyProb  => 1,
        RsyncArgs                 => 1,
        RsyncArgsExtra            => 1,
        RsyncRestoreArgs          => 1,
        RsyncClientCmd            => 0,
        RsyncClientRestoreCmd     => 0,
        RsyncClientPath           => 0,
        FtpShareName              => 1,
        FtpUserName               => 1,
        FtpPasswd                 => 1,
        FtpBlockSize              => 1,
        FtpPort                   => 1,
        FtpTimeout                => 1,
        FtpFollowSymlinks         => 1,
        FtpRestoreEnabled         => 1,
        ArchiveDest               => 1,
        ArchiveComp               => 1,
        ArchivePar                => 1,
        ArchiveSplit              => 1,
        ArchiveClientCmd          => 0,
        FixedIPNetBiosNameCheck   => 1,
        NmbLookupCmd              => 0,
        NmbLookupFindHostCmd      => 0,
        PingMaxMsec               => 1,
        PingCmd                   => 0,
        ClientTimeout             => 1,
        MaxOldPerPCLogFiles       => 1,
        CompressLevel             => 1,
        ClientNameAlias           => 1,
        DumpPreUserCmd            => 0,
        DumpPostUserCmd           => 0,
        RestorePreUserCmd         => 0,
        RestorePostUserCmd        => 0,
        ArchivePreUserCmd         => 0,
        ArchivePostUserCmd        => 0,
        DumpPostShareCmd          => 0,
        DumpPreShareCmd           => 0,
        UserCmdCheckStatus        => 0,
        EMailNotifyMinDays        => 1,
        EMailFromUserName         => 1,
        EMailAdminUserName        => 1,
        EMailUserDestDomain       => 1,
        EMailNoBackupEverSubj     => 1,
        EMailNoBackupEverMesg     => 1,
        EMailNotifyOldBackupDays  => 1,
        EMailNoBackupRecentSubj   => 1,
        EMailNoBackupRecentMesg   => 1,
        EMailNotifyOldOutlookDays => 1,
        EMailOutlookBackupSubj    => 1,
        EMailOutlookBackupMesg    => 1,
        EMailHeaders              => 1,
};
