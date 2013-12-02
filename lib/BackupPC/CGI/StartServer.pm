#============================================================= -*-perl-*-
#
# BackupPC::CGI::StartServer package
#
# DESCRIPTION
#
#   This module implements the StartServer action for the CGI interface.
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

package BackupPC::CGI::StartServer;

use strict;
use BackupPC::CGI::Lib qw(:all);

sub action
{
    if ( -f $Conf{ServerInitdPath}
      && $bpc->{Conf}{ServerInitdStartCmd} ne ""
      && !$bpc->ServerOK() ) {
        my $args = {
            serverInitdPath => $bpc->{Conf}{ServerInitdPath},
            sshPath         => $bpc->{Conf}{SshPath},
            serverHost      => $bpc->{Conf}{ServerHost},
        };
        my $serverInitdStartCmd = $bpc->cmdVarSubstitute($bpc->{Conf}{ServerInitdStartCmd}, $args);
        $bpc->cmdSystemOrEval($serverInitdStartCmd, undef, $args);
        for ( my $i = 0; $i < 10; $i++ ) {
            last unless ( $bpc->ServerConnect($Conf{ServerHost}, $Conf{ServerPort}) );
            sleep(1);
        }
        $bpc->ServerDisconnect();
    }
    print $Cgi->redirect($MyURL);
}

1;
