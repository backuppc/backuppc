#============================================================= -*-perl-*-
#
# BackupPC::CGI::DeleteBackup package
#
# DESCRIPTION
#
#   This module implements the DeleteBackup action for the CGI interface.
#
# AUTHORS
#   Craig Barratt       <cbarratt@users.sourceforge.net>
#   Alexander Moisseev  <moiseev@mezonplus.ru>
#
# COPYRIGHT
#   Copyright (C) 2003-2018  Craig Barratt
#   Copyright (C) 2017  Alexander Moisseev
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
# Version 4.2.0, released 8 Apr 2018.
#
# See http://backuppc.github.io/backuppc
#
#========================================================================

package BackupPC::CGI::DeleteBackup;

use strict;
use warnings;
use BackupPC::CGI::Lib qw(:all);
use Encode qw(decode_utf8);

sub action
{
    my($str, $reply);
    my $host = $In{host};

    my $Privileged = CheckPermission($host)
      && ($PrivAdmin || $Conf{CgiUserDeleteBackupEnable} > 0);
    $Privileged = 0 if ( $Conf{CgiUserDeleteBackupEnable} < 0 );
    if ( !$Privileged ) {
        ErrorExit(eval("qq{$Lang->{Only_privileged_users_can_delete_backups}}"));
    }
    if ( $In{num} !~ /^\d+$/ || $In{type} !~ /^\w*$/ || $In{nofill} !~ /^\d*$/ ) {
        ErrorExit("Backup number ${EscHTML($In{num})} for host ${EscHTML($host)} does not exist.");
    }
    my $num    = $In{num};
    my $filled = $In{nofill} ? $Lang->{An_unfilled} : $Lang->{A_filled};
    my $type   = $Lang->{$In{type}};
    ServerConnect();
    if ( $In{doit} ) {
        $str = eval("qq{$Lang->{Delete_requested_for_backup_of__host_by__User}}");
        $bpc->ServerMesg("log $str");

        $reply = $bpc->ServerMesg("delete $User ${EscURI($host)} $num -r");

        my $content = eval("qq{$Lang->{REPLY_FROM_SERVER}}");
        Header(eval("qq{$Lang->{BackupPC__Delete_Requested_for_a_backup_of__host}}"), $content);
    } else {
        my $content = eval("qq{$Lang->{Are_you_sure_delete}}");
        Header(eval("qq{$Lang->{BackupPC__Delete_Backup_Confirm__num_of__host}}"), $content);
    }
    Trailer();
}

1;
