#============================================================= -*-perl-*-
#
# BackupPC::CGI::StartStopBackup package
#
# DESCRIPTION
#
#   This module implements the StartStopBackup action for the CGI interface.
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

package BackupPC::CGI::StartStopBackup;

use strict;
use BackupPC::CGI::Lib qw(:all);

sub action
{
    my($str, $reply);

    my $start = 1 if ( $In{action} eq "Start_Incr_Backup"
                       || $In{action} eq "Start_Full_Backup" );
    my $doFull = $In{action} eq "Start_Full_Backup" ? 1 : 0;
    my $type = $doFull ? $Lang->{Type_full} : $Lang->{Type_incr};
    my $host = $In{host};
    my $Privileged = CheckPermission($host);

    if ( !$Privileged ) {
        ErrorExit(eval("qq{$Lang->{Only_privileged_users_can_stop_or_start_backups}}"));
    }
    ServerConnect();

    if ( $In{doit} ) {
        if ( $start ) {
	    if ( $Hosts->{$host}{dhcp} ) {
		$reply = $bpc->ServerMesg("backup $In{hostIP} ${EscURI($host)}"
				    . " $User $doFull");
		$str = eval("qq{$Lang->{Backup_requested_on_DHCP__host}}");
	    } else {
		$reply = $bpc->ServerMesg("backup ${EscURI($host)}"
				    . " ${EscURI($host)} $User $doFull");
		$str = eval("qq{$Lang->{Backup_requested_on__host_by__User}}");
	    }
        } else {
            $reply = $bpc->ServerMesg("stop ${EscURI($host)} $User $In{backoff}");
            $str = eval("qq{$Lang->{Backup_stopped_dequeued_on__host_by__User}}");
        }
    my $content = eval ("qq{$Lang->{REPLY_FROM_SERVER}}");
        Header(eval ("qq{$Lang->{BackupPC__Backup_Requested_on__host}}"),$content);

        Trailer();
    } else {
        if ( $start ) {
            $bpc->ConfigRead($host);
            %Conf = $bpc->Conf();

            my $checkHost = $host;
            $checkHost = $Conf{ClientNameAlias}
                                if ( $Conf{ClientNameAlias} ne "" );
	    my $ipAddr     = ConfirmIPAddress($checkHost);
            my $buttonText = $Lang->{$In{action}};
	    my $content = eval("qq{$Lang->{Are_you_sure_start}}");
            Header(eval("qq{$Lang->{BackupPC__Start_Backup_Confirm_on__host}}"),$content);
        } else {
            my $backoff = "";
            GetStatusInfo("host(${EscURI($host)})");
            if ( $StatusHost{backoffTime} > time ) {
                $backoff = sprintf("%.1f",
                                  ($StatusHost{backoffTime} - time) / 3600);
            }
            my $buttonText = $Lang->{$In{action}};
            my $content = eval ("qq{$Lang->{Are_you_sure_stop}}");
            Header(eval("qq{$Lang->{BackupPC__Stop_Backup_Confirm_on__host}}"),
                        $content);
        }
        Trailer();
    }
}

1;
