#============================================================= -*-perl-*-
#
# BackupPC::CGI::Queue package
#
# DESCRIPTION
#
#   This module implements the Queue action for the CGI interface.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2003-2013  Craig Barratt
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#========================================================================
#
# Version 4.0.0alpha3, released 1 Dec 2013.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

package BackupPC::CGI::Queue;

use strict;
use BackupPC::CGI::Lib qw(:all);

sub action
{
    my($strBg, $strUser, $strCmd);

    GetStatusInfo("queues");
    my $Privileged = CheckPermission();

    if ( !$Privileged ) {
	ErrorExit($Lang->{Only_privileged_users_can_view_queues_});
    }

    while ( @BgQueue ) {
        my $req = pop(@BgQueue);
        my($reqTime) = timeStamp2($req->{reqTime});
        $strBg .= <<EOF;
<tr><td> ${HostLink($req->{host})} </td>
    <td align="center"> $reqTime </td>
    <td align="center"> $req->{user} </td></tr>
EOF
    }
    while ( @UserQueue ) {
        my $req = pop(@UserQueue);
        my $reqTime = timeStamp2($req->{reqTime});
        $strUser .= <<EOF;
<tr><td> ${HostLink($req->{host})} </td>
    <td align="center"> $reqTime </td>
    <td align="center"> $req->{user} </td></tr>
EOF
    }
    while ( @CmdQueue ) {
        my $req = pop(@CmdQueue);
        my $reqTime = timeStamp2($req->{reqTime});
        (my $cmd = $bpc->execCmd2ShellCmd(@{$req->{cmd}})) =~ s/$BinDir\///;
        $strCmd .= <<EOF;
<tr><td> ${HostLink($req->{host})} </td>
    <td align="center"> $reqTime </td>
    <td align="center"> $req->{user} </td>
    <td> $cmd </td></tr>
EOF
    }
    my $content = eval ( "qq{$Lang->{Backup_Queue_Summary}}");
    Header($Lang->{BackupPC__Queue_Summary}, $content);
    Trailer();
}

1;
