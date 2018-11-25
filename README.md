[![BackupPC](images/logo320.png)](https://backuppc.github.io/backuppc/)

BackupPC is a high-performance, enterprise-grade system for backing up to a server's disk.

## Quick Start

The latest version of BackupPC can be fetched from:

* [github.com/backuppc/backuppc/releases](https://github.com/backuppc/backuppc/releases)

You'll need to install the perl module BackupPC::XS, available from:

* [github.com/backuppc/backuppc-xs/releases](https://github.com/backuppc/backuppc-xs/releases)

and the server-side rsync from:

* [github.com/backuppc/rsync-bpc/releases](https://github.com/backuppc/rsync-bpc/releases)


If you will use SMB for WinXX clients, you will need smbclient and
nmblookup from the Samba distribution.

To install BackupPC run these commands as root:

    tar zxf BackupPC-__VERSION__.tar.gz
    cd BackupPC-__VERSION__
    perl configure.pl

This will automatically determine some system information and prompt you
for install paths. Do `perldoc configure.pl` to see the various options
that configure.pl provides.



## Introduction

BackupPC is a high-performance, enterprise-grade system for backing
up Linux, WinXX, and MacOS PCs and laptops to a server's disk.
BackupPC is highly configurable and easy to install and maintain.

Given the ever decreasing cost of disks and raid systems, it is now
practical and cost effective to backup a large number of machines onto
a server's local disk or network storage. This is what BackupPC does.
For some sites, this might be the complete backup solution. For other
sites, additional permanent archives could be created by periodically
backing up the server to tape. A variety of Open Source systems are
available for doing backup to tape.

BackupPC is written in Perl and extracts backup data via SMB (using Samba),
rsync, or tar over ssh/rsh/nfs. It is robust, reliable, well documented
and freely available as Open Source on [GitHub](https://github.com/backuppc/backuppc/).



## Features

- A clever pooling scheme minimizes disk storage and disk IO. Identical
  files across multiple backups of the same or different PCs are stored
  only once resulting in substantial savings in disk storage.

- One example of disk use: 95 laptops with each full backup averaging
  3.6GB each, and each incremental averaging about 0.3GB. Storing
  three weekly full backups and six incremental backups per laptop
  is around 1200GB of raw data, but because of pooling and compression
  only 150GB is needed.

- No client-side software is needed. The standard smb protocol is used
  to extract backup data on WinXX clients. On *nix clients, either rsync
  or tar over ssh/rsh/nfs is used to backup the data. Various alternatives
  are possible: rsync can also be used with WinXX by running rsyncd/cygwin.
  Similarly, smb could be used to backup *nix file systems if they are
  exported as smb shares.

- A powerful http/cgi user interface allows administrators to view log
  files, configuration, current status and allows users to initiate and
  cancel backups and browse and restore files from backups.

- Flexible restore options. Single files can be downloaded from
  any backup directly from the CGI interface. Zip or Tar archives
  for selected files or directories from any backup can also be
  downloaded from the CGI interface. Finally, direct restore to
  the client machine (using SMB, rsync or tar) for selected files
  or directories is also supported from the CGI interface.

- Supports mobile environments where laptops are only intermittently
  connected to the network and have dynamic IP addresses (DHCP).

- Flexible configuration parameters allow multiple backups to be performed
  in parallel, specification of which shares to backup, which directories
  to backup or not backup, various schedules for full and incremental
  backups, schedules for email reminders to users and so on. Configuration
  parameters can be set system-wide or also on a per-PC basis.

- Users are sent periodic email reminders if their PC has not
  recently been backed up. Email content, timing and policies
  are configurable.

- Tested on Linux and Solaris hosts, and Linux, Win95, Win98, Win2000
  and WinXP clients.

- Detailed documentation.

- Open Source hosted by GitHub and freely available under GPL.



## Resources

Complete documentation is available in this release in doc/BackupPC.pod
or doc/BackupPC.html. You can read doc/BackupPC.pod with perldoc and
doc/BackupPC.html with any browser. You can also see the documentation
and general information at:

* [backuppc.github.io/backuppc](https://backuppc.github.io/backuppc)

The source code is available on Github at:

* [github.com/backuppc](https://github.com/backuppc)

and releases are available on github:

* [github.com/backuppc/backuppc/releases](https://github.com/backuppc/backuppc/releases)
* [github.com/backuppc/backuppc-xs/releases](https://github.com/backuppc/backuppc-xs/releases)
* [github.com/backuppc/rsync-bpc/releases](https://github.com/backuppc/rsync-bpc/releases)

or SourceForge:

* [sourceforge.net/projects/backuppc/files](https://sourceforge.net/projects/backuppc/files)

You are encouraged to subscribe to any of the mail lists available
on sourceforge.net:

* [lists.sourceforge.net/lists/listinfo/backuppc-announce](http://lists.sourceforge.net/lists/listinfo/backuppc-announce)
* [lists.sourceforge.net/lists/listinfo/backuppc-users](http://lists.sourceforge.net/lists/listinfo/backuppc-users)
* [lists.sourceforge.net/lists/listinfo/backuppc-devel](http://lists.sourceforge.net/lists/listinfo/backuppc-devel)

The backuppc-announce list is moderated and is used only for
important announcements (eg: new versions). It is low traffic.
You only need to subscribe to one of users and announce: backuppc-users
also receives any messages on backuppc-announce.

The backuppc-devel list is only for developers who are working on BackupPC.
Do not post questions or support requests there. But detailed technical
discussions should happen on this list.

To post a message to the backuppc-users list, send an email to

* backuppc-users@lists.sourceforge.net

Do not send subscription requests to this address!



## Copyright

Copyright (C) 2001-2018 Craig Barratt. All rights reserved.

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License.

See the LICENSE file.
