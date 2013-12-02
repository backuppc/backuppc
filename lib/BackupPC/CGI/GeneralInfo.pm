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
#   Copyright (C) 2001-2013  Craig Barratt
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
        next if ( $host eq $bpc->scgiJob );
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
    <td align="center" class="border"> $Jobs{$host}{xferState} </td>
    <td align="center" class="border"> $Jobs{$host}{xferFileCnt} </td>
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

    my $poolInfo     = genPoolInfo("pool4",  "pool",  \%Info);
    my $cpoolInfo    = genPoolInfo("cpool4", "cpool", \%Info);
    if ( $Info{pool4FileCnt} > 0 && $Info{cpool4FileCnt} > 0 ) {
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
    } elsif ( $Info{cpool4FileCnt} > 0 ) {
        $poolInfo = $cpoolInfo;
    }
    my $generalInfo = eval("qq{$Lang->{BackupPC_Server_Status_General_Info}}")
                                if ( $Privileged );
    my $generalInfo = "";
    if ( $Privileged ) {
        $generalInfo  = eval("qq{$Lang->{BackupPC_Server_Status_General_Info}}");
        if ( -r "$LogDir/poolUsage4.png" && -r "$LogDir/poolUsage52.png" ) {
            $generalInfo .= <<EOF;
<ul>
    <ul>
        <p><img src="$MyURL?action=view&type=poolUsage&num=4">
        <p><img src="$MyURL?action=view&type=poolUsage&num=52">
    </ul>
</ul>
EOF
        }
    }

    my $content = eval("qq{$Lang->{BackupPC_Server_Status}}");
    Header($Lang->{H_BackupPC_Server_Status}, $content);
    Trailer();
}

sub genPoolInfo
{
    my($name, $name3, $info) = @_;
    my $poolSize   = sprintf("%.2f", $info->{"${name}Kb"} / (1024 * 1024));
    my $poolRmSize = sprintf("%.2f", $info->{"${name}KbRm"} / (1024 * 1024));
    my $poolTime   = timeStamp2($info->{"${name}Time"});
    $info->{"${name}FileCntRm"} = $info->{"${name}FileCntRm"} + 0;
    if ( $Conf{PoolV3Enabled} ) {
        $poolSize   .= sprintf("+%.2f", $info->{"${name3}Kb"} / (1024 * 1024));
        $poolRmSize .= sprintf("+%.2f", $info->{"${name3}KbRm"} / (1024 * 1024));
        foreach my $stat ( qw(DirCnt FileCnt FileCntRep FileRepMax FileCntRm) ) {
            $Info{"$name$stat"} = $Info{"$name$stat"} . "+" . $Info{"$name3$stat"};
        }
    }
    return eval("qq{$Lang->{Pool_Stat}}");
}

1;
