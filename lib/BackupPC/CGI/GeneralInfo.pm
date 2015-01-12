#============================================================= -*-perl-*-
#
# BackupPC::CGI::GeneralInfo package
#
# DESCRIPTION
#
#   This module implements the GeneralInfo action for the CGI interface.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2003-2015  Craig Barratt
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
# Version 3.3.1, released 11 Jan 2015.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

package BackupPC::CGI::GeneralInfo;

use strict;
use BackupPC::CGI::Lib qw(:all);

sub action
{
    GetStatusInfo("info jobs hosts queueLen");
    my $Privileged = CheckPermission();

    my($jobStr, $statusStr);
    foreach my $host ( sort(keys(%Jobs)) ) {
        my $startTime = timeStamp2($Jobs{$host}{startTime});
        next if ( $host eq $bpc->trashJob
                    && $Jobs{$host}{processState} ne "running" );
        next if ( !$Privileged && !CheckPermission($host) );
        $Jobs{$host}{type} = $Status{$host}{type}
                    if ( $Jobs{$host}{type} eq "" && defined($Status{$host}));
        (my $cmd = $Jobs{$host}{cmd}) =~ s/$BinDir\///g;
        (my $xferPid = $Jobs{$host}{xferPid}) =~ s/,/, /g;
        $jobStr .= <<EOF;
<tr><td class="border"> ${HostLink($host)} </td>
    <td align="center" class="border"> $Jobs{$host}{type} </td>
    <td align="center" class="border"> ${UserLink(defined($Hosts->{$host})
					? $Hosts->{$host}{user} : "")} </td>
    <td class="border"> $startTime </td>
    <td class="border"> $cmd </td>
    <td align="center" class="border"> $Jobs{$host}{pid} </td>
    <td align="center" class="border"> $xferPid </td>
EOF
        $jobStr .= "</tr>\n";
    }
    foreach my $host ( sort(keys(%Status)) ) {
        next if ( $Status{$host}{reason} ne "Reason_backup_failed"
		    && $Status{$host}{reason} ne "Reason_restore_failed"
		    && (!$Status{$host}{userReq}
			|| $Status{$host}{reason} ne "Reason_no_ping") );
        next if ( !$Privileged && !CheckPermission($host) );
        my $startTime = timeStamp2($Status{$host}{startTime});
        my($errorTime, $XferViewStr);
        if ( $Status{$host}{errorTime} > 0 ) {
            $errorTime = timeStamp2($Status{$host}{errorTime});
        }
        if ( -f "$TopDir/pc/$host/SmbLOG.bad"
                || -f "$TopDir/pc/$host/SmbLOG.bad.z"
                || -f "$TopDir/pc/$host/XferLOG.bad"
                || -f "$TopDir/pc/$host/XferLOG.bad.z"
                ) {
            $XferViewStr = <<EOF;
<a href="$MyURL?action=view&type=XferLOGbad&host=${EscURI($host)}">$Lang->{XferLOG}</a>,
<a href="$MyURL?action=view&type=XferErrbad&host=${EscURI($host)}">$Lang->{Errors}</a>
EOF
        } else {
            $XferViewStr = "";
        }
        (my $shortErr = $Status{$host}{error}) =~ s/(.{48}).*/$1.../;   
        $statusStr .= <<EOF;
<tr><td class="border"> ${HostLink($host)} </td>
    <td align="center" class="border"> $Status{$host}{type} </td>
    <td align="center" class="border"> ${UserLink(defined($Hosts->{$host})
					? $Hosts->{$host}{user} : "")} </td>
    <td align="right" class="border"> $startTime </td>
    <td class="border"> $XferViewStr </td>
    <td align="right" class="border"> $errorTime </td>
    <td class="border"> ${EscHTML($shortErr)} </td></tr>
EOF
    }
    my $now          = timeStamp2(time);
    my $nextWakeupTime = timeStamp2($Info{nextWakeup});
    my $DUlastTime   = timeStamp2($Info{DUlastValueTime});
    my $DUmaxTime    = timeStamp2($Info{DUDailyMaxTime});
    my $numBgQueue   = $QueueLen{BgQueue};
    my $numUserQueue = $QueueLen{UserQueue};
    my $numCmdQueue  = $QueueLen{CmdQueue};
    my $serverStartTime = timeStamp2($Info{startTime});
    my $configLoadTime  = timeStamp2($Info{ConfigLTime});
    my $poolInfo     = genPoolInfo("pool", \%Info);
    my $cpoolInfo    = genPoolInfo("cpool", \%Info);
    if ( $Info{poolFileCnt} > 0 && $Info{cpoolFileCnt} > 0 ) {
        $poolInfo = <<EOF;
<li>Uncompressed pool:
<ul>
$poolInfo
</ul>
<li>Compressed pool:
<ul>
$cpoolInfo
</ul>
EOF
    } elsif ( $Info{cpoolFileCnt} > 0 ) {
        $poolInfo = $cpoolInfo;
    }
    my $generalInfo = eval("qq{$Lang->{BackupPC_Server_Status_General_Info}}")
                                if ( $Privileged );
    my $content = eval("qq{$Lang->{BackupPC_Server_Status}}");
    Header($Lang->{H_BackupPC_Server_Status}, $content);
    Trailer();
}

sub genPoolInfo
{
    my($name, $info) = @_;
    my $poolSize   = sprintf("%.2f", $info->{"${name}Kb"} / (1000 * 1024));
    my $poolRmSize = sprintf("%.2f", $info->{"${name}KbRm"} / (1000 * 1024));
    my $poolTime   = timeStamp2($info->{"${name}Time"});
    $info->{"${name}FileCntRm"} = $info->{"${name}FileCntRm"} + 0;
    return eval("qq{$Lang->{Pool_Stat}}");
}

1;
