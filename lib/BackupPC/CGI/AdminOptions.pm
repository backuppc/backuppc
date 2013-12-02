#============================================================= -*-perl-*-
#
# BackupPC::CGI::AdminOptions package
#
# DESCRIPTION
#
#   This module implements the AdminOptions action for the CGI interface.
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

package BackupPC::CGI::AdminOptions;

use strict;
use BackupPC::CGI::Lib qw(:all);

sub action
{
    unless ( CheckPermission() ) {
        ErrorExit($Lang->{Only_privileged_users_can_view_admin_options});
    }
    my $content = eval("qq{$Lang->{Admin_Options_Page}}");
    Header(eval("qq{$Lang->{H_Admin_Options}}"), $content);
    Trailer();
}

1;
