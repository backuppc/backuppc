#============================================================= -*-perl-*-
#
# BackupPC::CGI::HostInfo package
#
# DESCRIPTION
#
#   This module implements the HostInfo action for the CGI interface.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2003  Craig Barratt
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
# Version 2.1.0_CVS, released 3 Jul 2003.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

package BackupPC::CGI::HostInfo;

use strict;
use BackupPC::CGI::Lib qw(:all);

sub action
{
    my $host = $1 if ( $In{host} =~ /(.*)/ );
    my($statusStr, $startIncrStr);

    $host =~ s/^\s+//;
    $host =~ s/\s+$//;
    return Action_GeneralInfo() if ( $host eq "" );
    $host = lc($host)
                if ( !-d "$TopDir/pc/$host" && -d "$TopDir/pc/" . lc($host) );
    if ( $host =~ /\.\./ || !-d "$TopDir/pc/$host" ) {
        #
        # try to lookup by user name
        #
        if ( !defined($Hosts->{$host}) ) {
            foreach my $h ( keys(%$Hosts) ) {
                if ( $Hosts->{$h}{user} eq $host
                        || lc($Hosts->{$h}{user}) eq lc($host) ) {
                    $host = $h;
                    last;
                }
            }
            CheckPermission();
            ErrorExit(eval("qq{$Lang->{Unknown_host_or_user}}"))
                                if ( !defined($Hosts->{$host}) );
        }
        $In{host} = $host;
    }
    GetStatusInfo("host(${EscURI($host)})");
    $bpc->ConfigRead($host);
    %Conf = $bpc->Conf();
    my $Privileged = CheckPermission($host);
    if ( !$Privileged ) {
        ErrorExit(eval("qq{$Lang->{Only_privileged_users_can_view_information_about}}"));
    }
    ReadUserEmailInfo();

    my @Backups = $bpc->BackupInfoRead($host);
    my($str, $sizeStr, $compStr, $errStr, $warnStr);
    for ( my $i = 0 ; $i < @Backups ; $i++ ) {
        my $startTime = timeStamp2($Backups[$i]{startTime});
        my $dur       = $Backups[$i]{endTime} - $Backups[$i]{startTime};
        $dur          = 1 if ( $dur <= 0 );
        my $duration  = sprintf("%.1f", $dur / 60);
        my $MB        = sprintf("%.1f", $Backups[$i]{size} / (1024*1024));
        my $MBperSec  = sprintf("%.2f", $Backups[$i]{size} / (1024*1024*$dur));
        my $MBExist   = sprintf("%.1f", $Backups[$i]{sizeExist} / (1024*1024));
        my $MBNew     = sprintf("%.1f", $Backups[$i]{sizeNew} / (1024*1024));
        my($MBExistComp, $ExistComp, $MBNewComp, $NewComp);
        if ( $Backups[$i]{sizeExist} && $Backups[$i]{sizeExistComp} ) {
            $MBExistComp = sprintf("%.1f", $Backups[$i]{sizeExistComp}
                                                / (1024 * 1024));
            $ExistComp = sprintf("%.1f%%", 100 *
                  (1 - $Backups[$i]{sizeExistComp} / $Backups[$i]{sizeExist}));
        }
        if ( $Backups[$i]{sizeNew} && $Backups[$i]{sizeNewComp} ) {
            $MBNewComp = sprintf("%.1f", $Backups[$i]{sizeNewComp}
                                                / (1024 * 1024));
            $NewComp = sprintf("%.1f%%", 100 *
                  (1 - $Backups[$i]{sizeNewComp} / $Backups[$i]{sizeNew}));
        }
        my $age = sprintf("%.1f", (time - $Backups[$i]{startTime}) / (24*3600));
        my $browseURL = "$MyURL?action=browse&host=${EscURI($host)}&num=$Backups[$i]{num}";
        my $filled = $Backups[$i]{noFill} ? $Lang->{No} : $Lang->{Yes};
        $filled .= " ($Backups[$i]{fillFromNum}) "
                            if ( $Backups[$i]{fillFromNum} ne "" );
	my $ltype = $Lang->{"backupType_$Backups[$i]{type}"};
        $str .= <<EOF;
<tr><td align="center"> <a href="$browseURL">$Backups[$i]{num}</a> </td>
    <td align="center"> $ltype </td>
    <td align="center"> $filled </td>
    <td align="right">  $startTime </td>
    <td align="right">  $duration </td>
    <td align="right">  $age </td>
    <td align="left">   <tt>$TopDir/pc/$host/$Backups[$i]{num}</tt> </td></tr>
EOF
        $sizeStr .= <<EOF;
<tr><td align="center"> <a href="$browseURL">$Backups[$i]{num}</a> </td>
    <td align="center"> $ltype </td>
    <td align="right">  $Backups[$i]{nFiles} </td>
    <td align="right">  $MB </td>
    <td align="right">  $MBperSec </td>
    <td align="right">  $Backups[$i]{nFilesExist} </td>
    <td align="right">  $MBExist </td>
    <td align="right">  $Backups[$i]{nFilesNew} </td>
    <td align="right">  $MBNew </td>
</tr>
EOF
	my $is_compress = $Backups[$i]{compress} || $Lang->{off};
	if (! $ExistComp) { $ExistComp = "&nbsp;"; }
	if (! $MBExistComp) { $MBExistComp = "&nbsp;"; }
        $compStr .= <<EOF;
<tr><td align="center"> <a href="$browseURL">$Backups[$i]{num}</a> </td>
    <td align="center"> $ltype </td>
    <td align="center"> $is_compress </td> 
    <td align="right">  $MBExist </td>
    <td align="right">  $MBExistComp </td> 
    <td align="right">  $ExistComp </td>   
    <td align="right">  $MBNew </td>
    <td align="right">  $MBNewComp </td>
    <td align="right">  $NewComp </td>
</tr>
EOF
        $errStr .= <<EOF;
<tr><td align="center"> <a href="$browseURL">$Backups[$i]{num}</a> </td>
    <td align="center"> $ltype </td>
    <td align="center"> <a href="$MyURL?action=view&type=XferLOG&num=$Backups[$i]{num}&host=${EscURI($host)}">$Lang->{XferLOG}</a>,
                      <a href="$MyURL?action=view&type=XferErr&num=$Backups[$i]{num}&host=${EscURI($host)}">$Lang->{Errors}</a> </td>
    <td align="right">  $Backups[$i]{xferErrs} </td>
    <td align="right">  $Backups[$i]{xferBadFile} </td>
    <td align="right">  $Backups[$i]{xferBadShare} </td>
    <td align="right">  $Backups[$i]{tarErrs} </td></tr>
EOF
    }

    my @Restores = $bpc->RestoreInfoRead($host);
    my $restoreStr;

    for ( my $i = 0 ; $i < @Restores ; $i++ ) {
        my $startTime = timeStamp2($Restores[$i]{startTime});
        my $dur       = $Restores[$i]{endTime} - $Restores[$i]{startTime};
        $dur          = 1 if ( $dur <= 0 );
        my $duration  = sprintf("%.1f", $dur / 60);
        my $MB        = sprintf("%.1f", $Restores[$i]{size} / (1024*1024));
        my $MBperSec  = sprintf("%.2f", $Restores[$i]{size} / (1024*1024*$dur));
	my $Restores_Result = $Lang->{failed};
	if ($Restores[$i]{result} ne "failed") { $Restores_Result = $Lang->{success}; }
	$restoreStr  .= <<EOF;
<tr><td align="center"><a href="$MyURL?action=restoreInfo&num=$Restores[$i]{num}&host=${EscURI($host)}">$Restores[$i]{num}</a> </td>
    <td align="center"> $Restores_Result </td>
    <td align="right"> $startTime </td>
    <td align="right"> $duration </td>
    <td align="right"> $Restores[$i]{nFiles} </td>
    <td align="right"> $MB </td>
    <td align="right"> $Restores[$i]{tarCreateErrs} </td>
    <td align="right"> $Restores[$i]{xferErrs} </td>
</tr>
EOF
    }
    if ( $restoreStr ne "" ) {
	$restoreStr = eval("qq{$Lang->{Restore_Summary}}");
    }
    if ( @Backups == 0 ) {
        $warnStr = $Lang->{This_PC_has_never_been_backed_up};
    }
    if ( defined($Hosts->{$host}) ) {
        my $user = $Hosts->{$host}{user};
	my @moreUsers = sort(keys(%{$Hosts->{$host}{moreUsers}}));
	my $moreUserStr;
	foreach my $u ( sort(keys(%{$Hosts->{$host}{moreUsers}})) ) {
	    $moreUserStr .= ", " if ( $moreUserStr ne "" );
	    $moreUserStr .= "${UserLink($u)}";
	}
	if ( $moreUserStr ne "" ) {
	    $moreUserStr = " ($Lang->{and} $moreUserStr).\n";
	} else {
	    $moreUserStr = ".\n";
	}
        if ( $user ne "" ) {
            $statusStr .= eval("qq{$Lang->{This_PC_is_used_by}$moreUserStr}");
        }
        if ( defined($UserEmailInfo{$user})
                && $UserEmailInfo{$user}{lastHost} eq $host ) {
            my $mailTime = timeStamp2($UserEmailInfo{$user}{lastTime});
            my $subj     = $UserEmailInfo{$user}{lastSubj};
            $statusStr  .= eval("qq{$Lang->{Last_email_sent_to__was_at___subject}}");
        }
    }
    if ( defined($Jobs{$host}) ) {
        my $startTime = timeStamp2($Jobs{$host}{startTime});
        (my $cmd = $Jobs{$host}{cmd}) =~ s/$BinDir\///g;
        $statusStr .= eval("qq{$Lang->{The_command_cmd_is_currently_running_for_started}}");
    }
    if ( $StatusHost{BgQueueOn} ) {
        $statusStr .= eval("qq{$Lang->{Host_host_is_queued_on_the_background_queue_will_be_backed_up_soon}}");
    }
    if ( $StatusHost{UserQueueOn} ) {
        $statusStr .= eval("qq{$Lang->{Host_host_is_queued_on_the_user_queue__will_be_backed_up_soon}}");
    }
    if ( $StatusHost{CmdQueueOn} ) {
        $statusStr .= eval("qq{$Lang->{A_command_for_host_is_on_the_command_queue_will_run_soon}}");
    }
    my $startTime = timeStamp2($StatusHost{endTime} == 0 ?
                $StatusHost{startTime} : $StatusHost{endTime});
    my $reason = "";
    if ( $StatusHost{reason} ne "" ) {
        $reason = " ($Lang->{$StatusHost{reason}})";
    }
    $statusStr .= eval("qq{$Lang->{Last_status_is_state_StatusHost_state_reason_as_of_startTime}}");

    if ( $StatusHost{state} ne "Status_backup_in_progress"
	    && $StatusHost{state} ne "Status_restore_in_progress"
	    && $StatusHost{error} ne "" ) {
        $statusStr .= eval("qq{$Lang->{Last_error_is____EscHTML_StatusHost_error}}");
    }
    my $priorStr = "Pings";
    if ( $StatusHost{deadCnt} > 0 ) {
        $statusStr .= eval("qq{$Lang->{Pings_to_host_have_failed_StatusHost_deadCnt__consecutive_times}}");
        $priorStr = $Lang->{Prior_to_that__pings};
    }
    if ( $StatusHost{aliveCnt} > 0 ) {
        $statusStr .= eval("qq{$Lang->{priorStr_to_host_have_succeeded_StatusHostaliveCnt_consecutive_times}}");

        if ( $StatusHost{aliveCnt} >= $Conf{BlackoutGoodCnt}
		&& $Conf{BlackoutGoodCnt} >= 0 && $Conf{BlackoutHourBegin} >= 0
		&& $Conf{BlackoutHourEnd} >= 0 ) {
            my(@days) = qw(Sun Mon Tue Wed Thu Fri Sat);
            my($days) = join(", ", @days[@{$Conf{BlackoutWeekDays}}]);
            my($t0) = sprintf("%d:%02d", $Conf{BlackoutHourBegin},
                            60 * ($Conf{BlackoutHourBegin}
                                     - int($Conf{BlackoutHourBegin})));
            my($t1) = sprintf("%d:%02d", $Conf{BlackoutHourEnd},
                            60 * ($Conf{BlackoutHourEnd}
                                     - int($Conf{BlackoutHourEnd})));
            $statusStr .= eval("qq{$Lang->{Because__host_has_been_on_the_network_at_least__Conf_BlackoutGoodCnt_consecutive_times___}}");
        }
    }
    if ( $StatusHost{backoffTime} > time ) {
        my $hours = sprintf("%.1f", ($StatusHost{backoffTime} - time) / 3600);
        $statusStr .= eval("qq{$Lang->{Backups_are_deferred_for_hours_hours_change_this_number}}");

    }
    if ( @Backups ) {
        # only allow incremental if there are already some backups
        $startIncrStr = <<EOF;
<input type="submit" value="\$Lang->{Start_Incr_Backup}" name="action">
EOF
    }

    $startIncrStr = eval ("qq{$startIncrStr}");

    Header(eval("qq{$Lang->{Host__host_Backup_Summary}}"));
    print(eval("qq{$Lang->{Host__host_Backup_Summary2}}"));
    Trailer();
}

1;
