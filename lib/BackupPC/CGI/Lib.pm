#============================================================= -*-perl-*-
#
# BackupPC::CGI::Lib package
#
# DESCRIPTION
#
#   This library defines a BackupPC::Lib class and a variety of utility
#   functions used by BackupPC.
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

package BackupPC::CGI::Lib;

use strict;
use BackupPC::Lib;

require Exporter;

use vars qw( @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );

use vars qw($Cgi %In $MyURL $User %Conf $TopDir $LogDir $BinDir $bpc);
use vars qw(%Status %Info %Jobs @BgQueue @UserQueue @CmdQueue
            %QueueLen %StatusHost);
use vars qw($Hosts $HostsMTime $ConfigMTime $PrivAdmin);
use vars qw(%UserEmailInfo $UserEmailInfoMTime %RestoreReq %ArchiveReq);
use vars qw($Lang);

@ISA = qw(Exporter);

@EXPORT    = qw( );

@EXPORT_OK = qw(
		    timeStamp2
		    HostLink
		    UserLink
		    EscHTML
		    EscURI
		    ErrorExit
		    ServerConnect
		    GetStatusInfo
		    ReadUserEmailInfo
		    CheckPermission
		    GetUserHosts
		    ConfirmIPAddress
		    Header
		    Trailer
		    NavSectionTitle
		    NavSectionStart
		    NavSectionEnd
		    NavLink
		    h1
		    h2
		    $Cgi %In $MyURL $User %Conf $TopDir $LogDir $BinDir $bpc
		    %Status %Info %Jobs @BgQueue @UserQueue @CmdQueue
		    %QueueLen %StatusHost
		    $Hosts $HostsMTime $ConfigMTime $PrivAdmin
		    %UserEmailInfo $UserEmailInfoMTime %RestoreReq %ArchiveReq
		    $Lang
             );

%EXPORT_TAGS = (
    'all'    => [ @EXPORT_OK ],
);

sub NewRequest
{
    $Cgi = new CGI;
    %In = $Cgi->Vars;

    if ( !defined($bpc) ) {
	ErrorExit($Lang->{BackupPC__Lib__new_failed__check_apache_error_log})
	    if ( !($bpc = BackupPC::Lib->new(undef, undef, undef, 1)) );
	$TopDir = $bpc->TopDir();
	$LogDir = $bpc->LogDir();
	$BinDir = $bpc->BinDir();
	%Conf   = $bpc->Conf();
	$Lang   = $bpc->Lang();
	$ConfigMTime = $bpc->ConfigMTime();
        umask($Conf{UmaskMode});
    } elsif ( $bpc->ConfigMTime() != $ConfigMTime ) {
        $bpc->ConfigRead();
	$TopDir = $bpc->TopDir();
	$LogDir = $bpc->LogDir();
	$BinDir = $bpc->BinDir();
        %Conf   = $bpc->Conf();
        $Lang   = $bpc->Lang();
        $ConfigMTime = $bpc->ConfigMTime();
        umask($Conf{UmaskMode});
    }

    #
    # Default REMOTE_USER so in a miminal installation the user
    # has a sensible default.
    #
    $ENV{REMOTE_USER} = $Conf{BackupPCUser} if ( $ENV{REMOTE_USER} eq "" );

    #
    # We require that Apache pass in $ENV{SCRIPT_NAME} and $ENV{REMOTE_USER}.
    # The latter requires .ht_access style authentication.  Replace this
    # code if you are using some other type of authentication, and have
    # a different way of getting the user name.
    #
    $MyURL  = $ENV{SCRIPT_NAME};
    $User   = $ENV{REMOTE_USER};

    #
    # Handle LDAP uid=user when using mod_authz_ldap and otherwise untaint
    #
    $User   = $1 if ( $User =~ /uid=([^,]+)/i || $User =~ /(.*)/ );

    #
    # Clean up %ENV for taint checking
    #
    delete @ENV{qw(IFS CDPATH ENV BASH_ENV)};
    $ENV{PATH} = $Conf{MyPath};

    #
    # Verify we are running as the correct user
    #
    if ( $Conf{BackupPCUserVerify}
	    && $> != (my $uid = (getpwnam($Conf{BackupPCUser}))[2]) ) {
	ErrorExit(eval("qq{$Lang->{Wrong_user__my_userid_is___}}"), <<EOF);
This script needs to run as the user specified in \$Conf{BackupPCUser},
which is set to $Conf{BackupPCUser}.
<p>
This is an installation problem.  If you are using mod_perl then
it appears that Apache is not running as user $Conf{BackupPCUser}.
If you are not using mod_perl, then most like setuid is not working
properly on BackupPC_Admin.  Check the permissions on
$Conf{CgiDir}/BackupPC_Admin and look at the documentation.
EOF
    }

    if ( !defined($Hosts) || $bpc->HostsMTime() != $HostsMTime ) {
	$HostsMTime = $bpc->HostsMTime();
	$Hosts = $bpc->HostInfoRead();

	# turn moreUsers list into a hash for quick lookups
	foreach my $host (keys %$Hosts) {
	   $Hosts->{$host}{moreUsers} =
	       {map {$_, 1} split(",", $Hosts->{$host}{moreUsers}) }
	}
    }

    #
    # Untaint the host name
    #
    if ( $In{host} =~ /^([\w.\s-]+)$/ ) {
	$In{host} = $1;
    } else {
	delete($In{host});
    }
}

sub timeStamp2
{
    my $now = $_[0] == 0 ? time : $_[0];
    my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)
              = localtime($now);
    $mon++;
    if ( $Conf{CgiDateFormatMMDD} == 2 ) {
        $year += 1900;
        return sprintf("%04d-%02d-%02d %02d:%02d", $year, $mon, $mday, $hour, $min);
    } elsif ( $Conf{CgiDateFormatMMDD} ) {
        #
        # Add the year if the time is more than 330 days ago
        #
        if ( time - $now > 330 * 24 * 3600 ) {
            $year -= 100;
            return sprintf("$mon/$mday/%02d %02d:%02d", $year, $hour, $min);
        } else {
        return sprintf("$mon/$mday %02d:%02d", $hour, $min);
        }
    } else {
        #
        # Add the year if the time is more than 330 days ago
        #
        if ( time - $now > 330 * 24 * 3600 ) {
            $year -= 100;
            return sprintf("$mday/$mon/%02d %02d:%02d", $year, $hour, $min);
    } else {
        return sprintf("$mday/$mon %02d:%02d", $hour, $min);
    }
    }
}

sub HostLink
{
    my($host) = @_;
    my($s);
    if ( defined($Hosts->{$host}) || defined($Status{$host}) ) {
        $s = "<a href=\"$MyURL?host=${EscURI($host)}\">$host</a>";
    } else {
        $s = $host;
    }
    return \$s;
}

sub UserLink
{
    my($user) = @_;
    my($s);

    return \$user if ( $user eq ""
                    || $Conf{CgiUserUrlCreate} eq "" );
    if ( $Conf{CgiUserHomePageCheck} eq ""
            || -f sprintf($Conf{CgiUserHomePageCheck}, $user, $user, $user) ) {
        $s = "<a href=\""
             . sprintf($Conf{CgiUserUrlCreate}, $user, $user, $user)
             . "\">$user</a>";
    } else {
        $s = $user;
    }
    return \$s;
}

sub EscHTML
{
    my($s) = @_;
    $s =~ s/&/&amp;/g;
    $s =~ s/\"/&quot;/g;
    $s =~ s/>/&gt;/g;
    $s =~ s/</&lt;/g;
    ### $s =~ s{([^[:print:]])}{sprintf("&\#x%02X;", ord($1));}eg;
    return \$s;
}

sub EscURI
{
    my($s) = @_;
    $s =~ s{([^\w.\/-])}{sprintf("%%%02X", ord($1));}eg;
    return \$s;
}

sub ErrorExit
{
    my(@mesg) = @_;
    my($head) = shift(@mesg);
    my($mesg) = join("</p>\n<p>", @mesg);

    if ( !defined($ENV{REMOTE_USER}) ) {
	$mesg .= <<EOF;
<p>
Note: \$ENV{REMOTE_USER} is not set, which could mean there is an
installation problem.  BackupPC_Admin expects Apache to authenticate
the user and pass their user name into this script as the REMOTE_USER
environment variable.  See the documentation.
EOF
    }

    $bpc->ServerMesg("log User $User (host=$In{host}) got CGI error: $head")
                            if ( defined($bpc) );
    if ( !defined($Lang->{Error}) ) {
        $mesg = <<EOF if ( !defined($mesg) );
There is some problem with the BackupPC installation.
Please check the permissions on BackupPC_Admin.
EOF
        my $content = <<EOF;
${h1("Error: Unable to read config.pl or language strings!!")}
<p>$mesg</p>
EOF
        Header("BackupPC: Error", $content);
	Trailer();
    } else {
        my $content = eval("qq{$Lang->{Error____head}}");
        Header(eval("qq{$Lang->{Error}}"), $content);
	Trailer();
    }
    exit(1);
}

sub ServerConnect
{
    #
    # Verify that the server connection is ok
    #
    return if ( $bpc->ServerOK() );
    $bpc->ServerDisconnect();
    if ( my $err = $bpc->ServerConnect($Conf{ServerHost}, $Conf{ServerPort}) ) {
        if ( CheckPermission() 
          && -f $Conf{ServerInitdPath}
          && $Conf{ServerInitdStartCmd} ne "" ) {
            my $content = eval("qq{$Lang->{Admin_Start_Server}}");
            Header(eval("qq{$Lang->{Unable_to_connect_to_BackupPC_server}}"), $content);
            Trailer();
            exit(1);
        } else {
            ErrorExit(eval("qq{$Lang->{Unable_to_connect_to_BackupPC_server}}"),
                      eval("qq{$Lang->{Unable_to_connect_to_BackupPC_server_error_message}}"));
        }
    }
}

sub GetStatusInfo
{
    my($status) = @_;
    ServerConnect();
    %Status = ()     if ( $status =~ /\bhosts\b/ );
    %StatusHost = () if ( $status =~ /\bhost\(/ );
    my $reply = $bpc->ServerMesg("status $status");
    $reply = $1 if ( $reply =~ /(.*)/s );
    eval($reply);
    # ignore status related to admin jobs
    if ( $status =~ /\bhosts\b/ ) {
	foreach my $host ( grep(/admin/, keys(%Status)) ) {
	    delete($Status{$host}) if ( $bpc->isAdminJob($host) );
	}
        delete($Status{$bpc->scgiJob});
    }
}

sub ReadUserEmailInfo
{
    if ( (stat("$LogDir/UserEmailInfo.pl"))[9] != $UserEmailInfoMTime ) {
        do "$LogDir/UserEmailInfo.pl";
        $UserEmailInfoMTime = (stat("$LogDir/UserEmailInfo.pl"))[9];
    }
}

#
# Check if the user is privileged.  A privileged user can access
# any information (backup files, logs, status pages etc).
#
# A user is privileged if they belong to the group
# $Conf{CgiAdminUserGroup}, or they are in $Conf{CgiAdminUsers}
# or they are the user assigned to a host in the host file.
#
sub CheckPermission
{
    my($host) = @_;
    my $Privileged = 0;

    return 0 if ( $User eq "" && $Conf{CgiAdminUsers} ne "*"
	       || $host ne "" && !defined($Hosts->{$host}) );
    if ( $Conf{CgiAdminUserGroup} ne "" ) {
        my($n,$p,$gid,$mem) = getgrnam($Conf{CgiAdminUserGroup});
        $Privileged ||= ($mem =~ /\b\Q$User\E\b/);
    }
    if ( $Conf{CgiAdminUsers} ne "" ) {
        $Privileged ||= ($Conf{CgiAdminUsers} =~ /\b\Q$User\E\b/);
        $Privileged ||= $Conf{CgiAdminUsers} eq "*";
    }
    $PrivAdmin = $Privileged;
    return $Privileged if ( !defined($host) );

    $Privileged ||= $User eq $Hosts->{$host}{user};
    $Privileged ||= defined($Hosts->{$host}{moreUsers}{$User});
    return $Privileged;
}

#
# Returns the list of hosts that should appear in the navigation bar
# for this user.  If $getAll is set, the admin gets all the hosts.
# Otherwise, regular users get hosts for which they are the user or
# are listed in the moreUsers column in the hosts file.
#
sub GetUserHosts
{
    my($getAll) = @_;
    my @hosts;

    if ( $getAll && CheckPermission() ) {
        @hosts = sort keys %$Hosts;
    } else {
        @hosts = sort grep { $Hosts->{$_}{user} eq $User ||
                       defined($Hosts->{$_}{moreUsers}{$User}) } keys(%$Hosts);
    }
    return @hosts;
}

#
# Given a host name tries to find the IP address.  For non-dhcp hosts
# we just return the host name.  For dhcp hosts we check the address
# the user is using ($ENV{REMOTE_ADDR}) and also the last-known IP
# address for $host.  (Later we should replace this with a broadcast
# nmblookup.)
#
sub ConfirmIPAddress
{
    my($host) = @_;
    my $ipAddr = $host;

    if ( defined($Hosts->{$host}) && $Hosts->{$host}{dhcp}
	       && $ENV{REMOTE_ADDR} =~ /^(\d+[\.\d]*)$/ ) {
	$ipAddr = $1;
	my($netBiosHost, $netBiosUser) = $bpc->NetBiosInfoGet($ipAddr);
	if ( $netBiosHost ne $host ) {
	    my($tryIP);
	    GetStatusInfo("host(${EscURI($host)})");
	    if ( defined($StatusHost{dhcpHostIP})
			&& $StatusHost{dhcpHostIP} ne $ipAddr ) {
		$tryIP = eval("qq{$Lang->{tryIP}}");
		($netBiosHost, $netBiosUser)
			= $bpc->NetBiosInfoGet($StatusHost{dhcpHostIP});
	    }
	    if ( $netBiosHost ne $host ) {
		ErrorExit(eval("qq{$Lang->{Can_t_find_IP_address_for}}"),
		          eval("qq{$Lang->{host_is_a_DHCP_host}}"));
	    }
	    $ipAddr = $StatusHost{dhcpHostIP};
	}
    }
    return $ipAddr;
}

###########################################################################
# HTML layout subroutines
###########################################################################

sub Header
{
    my($title, $content, $noBrowse, $contentSub, $contentPost) = @_;
    my @adminLinks = (
        { link => "",                      name => $Lang->{Status}},
        { link => "?action=summary",       name => $Lang->{PC_Summary}},
        { link => "?action=editConfig",    name => $Lang->{CfgEdit_Edit_Config},
                                           priv => 1},
        { link => "?action=editConfig&newMenu=hosts",
                                           name => $Lang->{CfgEdit_Edit_Hosts},
                                           priv => 1},
        { link => "?action=adminOpts",     name => $Lang->{Admin_Options},
                                           priv => 1},
        { link => "?action=view&type=LOG", name => $Lang->{LOG_file},
                                           priv => 1},
        { link => "?action=LOGlist",       name => $Lang->{Old_LOGs},
                                           priv => 1},
        { link => "?action=emailSummary",  name => $Lang->{Email_summary},
                                           priv => 1},
        { link => "?action=queue",         name => $Lang->{Current_queues},
                                           priv => 1},
        @{$Conf{CgiNavBarLinks} || []},
    );
    my $host = $In{host};

    binmode(STDOUT, ":utf8");
    print $Cgi->header(-charset => "utf-8");
    print <<EOF;
<!doctype html public "-//W3C//DTD HTML 4.01 Transitional//EN">
<html><head>
<title>$title</title>
<link rel=stylesheet type="text/css" href="$Conf{CgiImageDirURL}/$Conf{CgiCSSFile}" title="CSSFile">
<link rel=icon href="$Conf{CgiImageDirURL}/favicon.ico" type="image/x-icon">
$Conf{CgiHeaders}
<script src="$Conf{CgiImageDirURL}/sorttable.js"></script>
</head><body onLoad="document.getElementById('NavMenu').style.height=document.body.scrollHeight">
<a href="http://backuppc.sourceforge.net"><img src="$Conf{CgiImageDirURL}/logo.gif" hspace="5" vspace="7" border="0"></a><br>
EOF

    if ( defined($Hosts) && defined($host) && defined($Hosts->{$host}) ) {
	print "<div class=\"NavMenu\">";
	NavSectionTitle("${EscHTML($host)}");
	print <<EOF;
</div>
<div class="NavMenu">
EOF
	NavLink("?host=${EscURI($host)}",
		"$host $Lang->{Home}", " class=\"navbar\"");
	NavLink("?action=browse&host=${EscURI($host)}",
		$Lang->{Browse}, " class=\"navbar\"") if ( !$noBrowse );
	NavLink("?action=view&type=LOG&host=${EscURI($host)}",
		$Lang->{LOG_file}, " class=\"navbar\"");
	NavLink("?action=LOGlist&host=${EscURI($host)}",
		$Lang->{LOG_files}, " class=\"navbar\"");
	if ( -f "$TopDir/pc/$host/SmbLOG.bad"
		    || -f "$TopDir/pc/$host/SmbLOG.bad.z"
		    || -f "$TopDir/pc/$host/XferLOG.bad"
		    || -f "$TopDir/pc/$host/XferLOG.bad.z" ) {
	   NavLink("?action=view&type=XferLOGbad&host=${EscURI($host)}",
		    $Lang->{Last_bad_XferLOG}, " class=\"navbar\"");
	   NavLink("?action=view&type=XferErrbad&host=${EscURI($host)}",
		    $Lang->{Last_bad_XferLOG_errors_only},
		    " class=\"navbar\"");
	}
        if ( $Conf{CgiUserConfigEditEnable} || $PrivAdmin ) {
            NavLink("?action=editConfig&host=${EscURI($host)}",
                    $Lang->{CfgEdit_Edit_Config}, " class=\"navbar\"");
        } elsif ( -f "$TopDir/pc/$host/config.pl"
                    || ($host ne "config" && -f "$TopDir/conf/$host.pl") ) {
            NavLink("?action=view&type=config&host=${EscURI($host)}",
                    $Lang->{Config_file}, " class=\"navbar\"");
        }
	print "</div>\n";
    }
    print("<div id=\"Content\">\n$content\n");
    if ( defined($contentSub) && ref($contentSub) eq "CODE" ) {
	while ( (my $s = &$contentSub()) ne "" ) {
	    print($s);
	}
    }
    print($contentPost) if ( defined($contentPost) );
    print <<EOF;
<br><br><br>
</div>
<div class="NavMenu" id="NavMenu" style="height:100%">
EOF
    my $hostSelectbox = "<option value=\"#\">$Lang->{Select_a_host}</option>";
    my @hosts = GetUserHosts($Conf{CgiNavBarAdminAllHosts});
    NavSectionTitle($Lang->{Hosts});
    if ( defined($Hosts) && %$Hosts > 0 && @hosts ) {
        foreach my $host ( @hosts ) {
	    NavLink("?host=${EscURI($host)}", $host)
		    if ( @hosts < $Conf{CgiNavBarAdminAllHosts} );
	    my $sel = " selected" if ( $host eq $In{host} );
	    $hostSelectbox .= "<option value=\"?host=${EscURI($host)}\"$sel>"
			    . "$host</option>";
        }
    }
    if ( @hosts >= $Conf{CgiNavBarAdminAllHosts} ) {
        print <<EOF;
<br>
<select onChange="document.location=this.value">
$hostSelectbox
</select>
<br><br>
EOF
    }
    if ( $Conf{CgiSearchBoxEnable} ) {
        print <<EOF;
<form action="$MyURL" method="get">
    <input type="text" name="host" size="14" maxlength="64">
    <input type="hidden" name="action" value="hostInfo"><input type="submit" value="$Lang->{Go}" name="ignore">
    </form>
EOF
    }
    NavSectionTitle($Lang->{NavSectionTitle_});
    foreach my $l ( @adminLinks ) {
        if ( $PrivAdmin || !$l->{priv} ) {
            my $txt = $l->{lname} ne "" ? $Lang->{$l->{lname}} : $l->{name};
            NavLink($l->{link}, $txt);
        }
    }

    print <<EOF;
<br><br><br>
</div>
EOF
}

sub Trailer
{
    print <<EOF;
</body></html>
EOF
}


sub NavSectionTitle
{
    my($head) = @_;
    print <<EOF;
<div class="NavTitle">$head</div>
EOF
}

sub NavSectionStart
{
}

sub NavSectionEnd
{
}

sub NavLink
{
    my($link, $text) = @_;
    if ( defined($link) ) {
        my($class);
        $class = " class=\"NavCurrent\""
                if ( length($link) && $ENV{REQUEST_URI} =~ /\Q$link\E$/
                    || $link eq "" && $ENV{REQUEST_URI} !~ /\?/ );
        $link = "$MyURL$link" if ( $link eq "" || $link =~ /^\?/ );
        print <<EOF;
<a href="$link"$class>$text</a>
EOF
    } else {
        print <<EOF;
$text<br>
EOF
    }
}

sub h1
{
    my($str) = @_;
    return \<<EOF;
<div class="h1">$str</div>
EOF
}

sub h2
{
    my($str) = @_;
    return \<<EOF;
<div class="h2">$str</div>
EOF
}
