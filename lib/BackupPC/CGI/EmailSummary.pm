#============================================================= -*-perl-*-
#
# BackupPC::CGI::EmailSummary package
#
# DESCRIPTION
#
#   This module implements the EmailSummary action for the CGI interface.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2003-2007  Craig Barratt
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
# Version 3.1.0, released 25 Nov 2007.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

package BackupPC::CGI::EmailSummary;

use strict;
use BackupPC::CGI::Lib qw(:all);

sub action
{
    my $Privileged = CheckPermission();

    if ( !$Privileged ) {
        ErrorExit($Lang->{Only_privileged_users_can_view_email_summaries});
    }
    GetStatusInfo("hosts");
    ReadUserEmailInfo();
    my(%EmailStr, $str);
    foreach my $u ( keys(%UserEmailInfo) ) {
        next if ( !defined($UserEmailInfo{$u}{lastTime}) );
        my $emailTimeStr = timeStamp2($UserEmailInfo{$u}{lastTime});
        $EmailStr{$UserEmailInfo{$u}{lastTime}} .= <<EOF;
<tr><td>${UserLink($u)} </td>
    <td>${HostLink($UserEmailInfo{$u}{lastHost})} </td>
    <td>$emailTimeStr </td>
    <td>$UserEmailInfo{$u}{lastSubj} </td></tr>
EOF
    }
    foreach my $t ( sort({$b <=> $a} keys(%EmailStr)) ) {
        $str .= $EmailStr{$t};
    }
    my $content = eval("qq{$Lang->{Recent_Email_Summary}}");
    Header($Lang->{Email_Summary}, $content);
    Trailer();
}

1;
