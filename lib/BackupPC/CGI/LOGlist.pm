#============================================================= -*-perl-*-
#
# BackupPC::CGI::LOGlist package
#
# DESCRIPTION
#
#   This module implements the LOGlist action for the CGI interface.
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

package BackupPC::CGI::LOGlist;

use strict;
use BackupPC::CGI::Lib qw(:all);

sub action
{
    my $Privileged = CheckPermission($In{host});

    if ( !$Privileged ) {
        ErrorExit($Lang->{Only_privileged_users_can_view_log_files});
    }
    my $host = $In{host};
    my($url0, $hdr, $root, $str);
    if ( $host ne "" ) {
        $root = "$TopDir/pc/$host/LOG";
        $url0 = "&host=${EscURI($host)}";
        $hdr = "for host $host";
    } else {
        $root = "$TopDir/log/LOG";
        $url0 = "";
        $hdr = "";
    }
    for ( my $i = -1 ; ; $i++ ) {
        my $url1 = "";
        my $file = $root;
        if ( $i >= 0 ) {
            $file .= ".$i";
            $url1 = "&num=$i";
        }
        $file .= ".z" if ( !-f $file && -f "$file.z" );
        last if ( !-f $file );
        my $mtimeStr = $bpc->timeStamp((stat($file))[9], 1);
        my $size     = (stat($file))[7];
        $str .= <<EOF;
<tr><td> <a href="$MyURL?action=view&type=LOG$url0$url1"><tt>$file</tt></a> </td>
    <td align="right"> $size </td>
    <td> $mtimeStr </td></tr>
EOF
    }
    my $content = eval("qq{$Lang->{Log_File_History__hdr}}");
    Header($Lang->{BackupPC__Log_File_History}, $content);
    Trailer();
}

1;
