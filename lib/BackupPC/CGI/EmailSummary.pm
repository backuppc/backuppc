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
        my $info;
        if ( defined($UserEmailInfo{$u}{lastTime})
                && ref($UserEmailInfo{$u}{lastTime}) ne 'HASH' ) {
            #
            # old format $UserEmailInfo - pre 3.2.0.
            #
            my $host = $UserEmailInfo{$u}{lastHost};
            $info = {
                $host => {
                    lastTime => $UserEmailInfo{$u}{lastTime},
                    lastSubj => $UserEmailInfo{$u}{lastSubj},
                },
            };
        } else {
            $info = $UserEmailInfo{$u};
        }
        foreach my $host ( keys(%$info) ) {
            next if ( !defined($info->{$host}{lastTime}) );
            my $emailTimeStr = timeStamp2($info->{$host}{lastTime});
            $EmailStr{$info->{$host}{lastTime}} .= <<EOF;
<tr><td>${UserLink($u)} </td>
    <td>${HostLink($host)} </td>
    <td>$emailTimeStr </td>
    <td>$info->{$host}{lastSubj} </td></tr>
EOF
        }
    }
    foreach my $t ( sort({$b <=> $a} keys(%EmailStr)) ) {
        $str .= $EmailStr{$t};
    }
    my $content = eval("qq{$Lang->{Recent_Email_Summary}}");
    Header($Lang->{Email_Summary}, $content);
    Trailer();
}

1;
