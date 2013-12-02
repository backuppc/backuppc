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

package BackupPC::CGI::HostInfo;

use strict;
use BackupPC::CGI::Lib qw(:all);

sub action
{
    my $host = $1 if ( $In{host} =~ /(.*)/ );
    my($statusStr, $startIncrStr);

    $host =~ s/^\s+//;
    $host =~ s/\s+$//;
    if ( $host eq "" ) {
	ErrorExit(eval("qq{$Lang->{Unknown_host_or_user}}"));
    }
    $host = lc($host)
               if ( !-d "$TopDir/pc/$host" && -d "$TopDir/pc/" . lc($host) );
    if ( $host =~ /\.\./ || !-d "$TopDir/pc/$host" ) {
        #
        # try to lookup by user name
        #
        if ( $host eq "" || !defined($Hosts->{$host}) ) {
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

    if ( $Conf{XferMethod} eq "archive" ) {
        my @Archives = $bpc->ArchiveInfoRead($host);
        my ($ArchiveStr,$warnStr);

        for ( my $i = 0 ; $i < @Archives ; $i++ ) {
            my $startTime = timeStamp2($Archives[$i]{startTime});
            my $dur       = $Archives[$i]{endTime} - $Archives[$i]{startTime};
            $dur          = 1 if ( $dur <= 0 );
            my $duration  = sprintf("%.1f", $dur / 60);
            my $Archives_Result = $Lang->{failed};
            if ($Archives[$i]{result} ne "failed") { $Archives_Result = $Lang->{success}; }
            $ArchiveStr  .= <<EOF;
<tr><td align="center"><a href="$MyURL?action=archiveInfo&num=$Archives[$i]{num}&host=${EscURI($host)}">$Archives[$i]{num}</a> </td>
    <td align="center"> $Archives_Result </td>
    <td align="right"> $startTime </td>
    <td align="right"> $duration </td>
</tr>
EOF
        }
        if ( $ArchiveStr ne "" ) {
            $ArchiveStr = eval("qq{$Lang->{Archive_Summary}}");
        }
        if ( @Archives == 0 ) {
            $warnStr = $Lang->{There_have_been_no_archives};
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

        my $content = eval("qq{$Lang->{Host__host_Archive_Summary2}}");
        Header(eval("qq{$Lang->{Host__host_Archive_Summary}}"), $content, 1);
        Trailer();
        return;
    }

    #
    # Normal, non-archive case
    #
    my @Backups = $bpc->BackupInfoRead($host);
    my($str, $sizeStr, $compStr, $errStr, $warnStr);
    for ( my $i = 0 ; $i < @Backups ; $i++ ) {
        my($MBExistComp, $ExistComp, $MBNewComp, $NewComp);
        my($dur, $duration, $MB, $MBperSec, $MBExist, $MBNew);
        my $startTime = timeStamp2($Backups[$i]{startTime});

        if ( $Backups[$i]{type} ne "active" ) {
            $dur       = $Backups[$i]{endTime} - $Backups[$i]{startTime};
            $dur          = 1 if ( $dur <= 0 );
            $duration  = sprintf("%.1f", $dur / 60);
            $MB        = sprintf("%.1f", $Backups[$i]{size} / (1024*1024));
            $MBperSec  = sprintf("%.2f", $Backups[$i]{size} / (1024*1024*$dur));
            $MBExist   = sprintf("%.1f", $Backups[$i]{sizeExist} / (1024*1024));
            $MBNew     = sprintf("%.1f", $Backups[$i]{sizeNew} / (1024*1024));
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
        }
        my $age = sprintf("%.1f", (time - $Backups[$i]{startTime}) / (24*3600));
        my $browseURL = "$MyURL?action=browse&host=${EscURI($host)}&num=$Backups[$i]{num}";
        my $level  = $Backups[$i]{level};
        my $filled = $Backups[$i]{noFill} ? $Lang->{No} : $Lang->{Yes};
        $filled .= " ($Backups[$i]{fillFromNum}) "
                            if ( $Backups[$i]{fillFromNum} ne "" );
        my $ltype = $Lang->{"backupType_$Backups[$i]{type}"};
        $str .= <<EOF;
<tr><td align="center" class="border"> <a href="$browseURL">$Backups[$i]{num}</a> </td>
    <td align="center" class="border"> $ltype </td>
    <td align="center" class="border"> $filled </td>
    <td align="center" class="border"> $level </td>
    <td align="right" class="border">  $startTime </td>
    <td align="right" class="border">  $duration </td>
    <td align="right" class="border">  $age </td>
    <td align="left" class="border">   <tt>$TopDir/pc/$host/$Backups[$i]{num}</tt> </td></tr>
EOF
        $sizeStr .= <<EOF;
<tr><td align="center" class="border"> <a href="$browseURL">$Backups[$i]{num}</a> </td>
    <td align="center" class="border"> $ltype </td>
    <td align="right" class="border">  $Backups[$i]{nFiles} </td>
    <td align="right" class="border">  $MB </td>
    <td align="right" class="border">  $MBperSec </td>
    <td align="right" class="border">  $Backups[$i]{nFilesExist} </td>
    <td align="right" class="border">  $MBExist </td>
    <td align="right" class="border">  $Backups[$i]{nFilesNew} </td>
    <td align="right" class="border">  $MBNew </td>
</tr>
EOF
        my $is_compress = $Backups[$i]{compress} || $Lang->{off};
        if (! $ExistComp) { $ExistComp = "&nbsp;"; }
        if (! $MBExistComp) { $MBExistComp = "&nbsp;"; }
        $compStr .= <<EOF;
<tr><td align="center" class="border"> <a href="$browseURL">$Backups[$i]{num}</a> </td>
    <td align="center" class="border"> $ltype </td>
    <td align="center" class="border"> $is_compress </td>
    <td align="right" class="border">  $MBExist </td>
    <td align="right" class="border">  $MBExistComp </td>
    <td align="right" class="border">  $ExistComp </td>
    <td align="right" class="border">  $MBNew </td>
    <td align="right" class="border">  $MBNewComp </td>
    <td align="right" class="border">  $NewComp </td>
</tr>
EOF
        $errStr .= <<EOF;
<tr><td align="center" class="border"> <a href="$browseURL">$Backups[$i]{num}</a> </td>
    <td align="center" class="border"> $ltype </td>
    <td align="center" class="border"> <a href="$MyURL?action=view&type=XferLOG&num=$Backups[$i]{num}&host=${EscURI($host)}">$Lang->{XferLOG}</a>,
                      <a href="$MyURL?action=view&type=XferErr&num=$Backups[$i]{num}&host=${EscURI($host)}">$Lang->{Errors}</a> </td>
    <td align="right" class="border">  $Backups[$i]{xferErrs} </td>
    <td align="right" class="border">  $Backups[$i]{xferBadFile} </td>
    <td align="right" class="border">  $Backups[$i]{xferBadShare} </td>
    <td align="right" class="border">  $Backups[$i]{tarErrs} </td></tr>
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
<tr><td align="center" class="border"><a href="$MyURL?action=restoreInfo&num=$Restores[$i]{num}&host=${EscURI($host)}">$Restores[$i]{num}</a> </td>
    <td align="center" class="border"> $Restores_Result </td>
    <td align="right" class="border"> $startTime </td>
    <td align="right" class="border"> $duration </td>
    <td align="right" class="border"> $Restores[$i]{nFiles} </td>
    <td align="right" class="border"> $MB </td>
    <td align="right" class="border"> $Restores[$i]{tarCreateErrs} </td>
    <td align="right" class="border"> $Restores[$i]{xferErrs} </td>
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
                && defined($UserEmailInfo{$user}{$host})
                && defined($UserEmailInfo{$user}{$host}{lastSubj}) ) {
            my $mailTime = timeStamp2($UserEmailInfo{$user}{$host}{lastTime});
            my $subj     = $UserEmailInfo{$user}{$host}{lastSubj};
            $statusStr  .= eval("qq{$Lang->{Last_email_sent_to__was_at___subject}}");
        } elsif ( defined($UserEmailInfo{$user})
                && $UserEmailInfo{$user}{lastHost} eq $host
                && defined($UserEmailInfo{$user}{lastSubj}) ) {
            #
            # Old format %UserEmailInfo - pre 3.2.0.
            #
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

        if ( (@{$Conf{BlackoutPeriods}} || defined($Conf{BlackoutHourBegin}))
		&& $StatusHost{aliveCnt} >= $Conf{BlackoutGoodCnt}
                && $Conf{BlackoutGoodCnt} >= 0 ) {
            #
            # Handle backward compatibility with original separate scalar
            # blackout parameters.
            #
            if ( defined($Conf{BlackoutHourBegin}) ) {
                push(@{$Conf{BlackoutPeriods}},
                     {
                         hourBegin => $Conf{BlackoutHourBegin},
                         hourEnd   => $Conf{BlackoutHourEnd},
                         weekDays  => $Conf{BlackoutWeekDays},
                     }
                );
            }

            #
            # TODO: this string needs i18n.  Also, comma-separated
            # list with "and" for the last element might not translate
            # correctly.
            #
            my(@days) = qw(Sun Mon Tue Wed Thu Fri Sat);
            my $blackoutStr;
            my $periodCnt = 0;
            foreach my $p ( @{$Conf{BlackoutPeriods}} ) {
                next if ( ref($p->{weekDays}) ne "ARRAY"
                            || !defined($p->{hourBegin})
                            || !defined($p->{hourEnd})
                        );
                my $days = join(", ", @days[@{$p->{weekDays}}]);
                my $t0   = sprintf("%d:%02d", $p->{hourBegin},
                              60 * ($p->{hourBegin} - int($p->{hourBegin})));
                my $t1   = sprintf("%d:%02d", $p->{hourEnd},
                              60 * ($p->{hourEnd} - int($p->{hourEnd})));
                if ( $periodCnt ) {
                    $blackoutStr .= ", ";
                    if ( $periodCnt == @{$Conf{BlackoutPeriods}} - 1 ) {
                        $blackoutStr .= eval("qq{$Lang->{and}}");
                        $blackoutStr .= " ";
                    }
                }
                $blackoutStr
                        .= eval("qq{$Lang->{__time0_to__time1_on__days}}");
                $periodCnt++;
            }
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
<input type="button" value="$Lang->{Start_Incr_Backup}"
 onClick="document.StartStopForm.action.value='Start_Incr_Backup';
          document.StartStopForm.submit();">
EOF
    }

    $startIncrStr = eval("qq{$startIncrStr}");
    my $content = eval("qq{$Lang->{Host__host_Backup_Summary2}}");
    Header(eval("qq{$Lang->{Host__host_Backup_Summary}}"), $content);
    Trailer();
}

1;
