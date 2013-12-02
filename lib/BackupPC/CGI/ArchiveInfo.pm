#============================================================= -*-perl-*-
#
# BackupPC::CGI::ArchiveInfo package
#
# DESCRIPTION
#
#   This module implements the ArchiveInfo action for the CGI interface.
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

package BackupPC::CGI::ArchiveInfo;

use strict;
use BackupPC::CGI::Lib qw(:all);

sub action
{
    my $Privileged = CheckPermission($In{host});
    my $host = $1 if ( $In{host} =~ /(.*)/ );
    my $num  = $In{num};
    my $i;

    if ( !$Privileged ) {
        ErrorExit($Lang->{Only_privileged_users_can_view_archive_information});
    }
    #
    # Find the requested archive
    #
    my @Archives = $bpc->ArchiveInfoRead($host);
    for ( $i = 0 ; $i < @Archives ; $i++ ) {
        last if ( $Archives[$i]{num} == $num );
    }
    if ( $i >= @Archives ) {
        ErrorExit(eval("qq{$Lang->{Archive_number__num_for_host__does_not_exist}}"));
    }

    %ArchiveReq = ();
    do "$TopDir/pc/$host/ArchiveInfo.$Archives[$i]{num}"
	    if ( -f "$TopDir/pc/$host/ArchiveInfo.$Archives[$i]{num}" );

    my $startTime = timeStamp2($Archives[$i]{startTime});
    my $reqTime   = timeStamp2($ArchiveReq{reqTime});
    my $dur       = $Archives[$i]{endTime} - $Archives[$i]{startTime};
    $dur          = 1 if ( $dur <= 0 );
    my $duration  = sprintf("%.1f", $dur / 60);

    my $HostListStr = "";
    my $counter=0;
    foreach my $f ( @{$ArchiveReq{HostList}} ) {
	$HostListStr .= <<EOF;
<tr><td>$f</td><td>@{$ArchiveReq{BackupList}}[$counter]</td></tr>
EOF
        $counter++;
    }

    my $content = eval("qq{$Lang->{Archive___num_details_for__host2 }}");
    Header(eval("qq{$Lang->{Archive___num_details_for__host}}"), $content, 1);
    Trailer();
}

1;
