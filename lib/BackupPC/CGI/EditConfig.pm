#============================================================= -*-perl-*-
#
# BackupPC::CGI::EditConfig package
#
# DESCRIPTION
#
#   This module implements the EditConfig action for the CGI interface.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2004  Craig Barratt
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
# Version 3.0.0alpha, released 23 Jan 2006.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

package BackupPC::CGI::EditConfig;

use strict;
use BackupPC::CGI::Lib qw(:all);
use BackupPC::Config::Meta qw(:all);
use BackupPC::Storage;
use Data::Dumper;

our %ConfigMenu = (
    server => {
        text  => "CfgEdit_Title_Server",
        param => [
            {text => "CfgEdit_Title_General_Parameters"},
            {name => "ServerHost"},
            {name => "BackupPCUser"},
            {name => "BackupPCUserVerify"},
            {name => "MaxOldLogFiles"},
            {name => "TrashCleanSleepSec"},

            {text => "CfgEdit_Title_Wakeup_Schedule"},
            {name => "WakeupSchedule"},

            {text => "CfgEdit_Title_Concurrent_Jobs"},
            {name => "MaxBackups"},
            {name => "MaxUserBackups"},
            {name => "MaxPendingCmds"},
            {name => "MaxBackupPCNightlyJobs"},
            {name => "BackupPCNightlyPeriod"},

            {text => "CfgEdit_Title_Pool_Filesystem_Limits"},
	    {name => "DfCmd"},
	    {name => "DfMaxUsagePct"},
	    {name => "HardLinkMax"},

            {text => "CfgEdit_Title_Other_Parameters"},
	    {name => "UmaskMode"},
	    {name => "MyPath"},
            {name => "DHCPAddressRanges"},
            {name => "PerlModuleLoad"},
            {name => "ServerInitdPath"},
            {name => "ServerInitdStartCmd"},

            {text => "CfgEdit_Title_Remote_Apache_Settings"},
            {name => "ServerPort"},
            {name => "ServerMesgSecret"},

            {text => "CfgEdit_Title_Program_Paths"},
	    {name => "SshPath"},
	    {name => "NmbLookupPath"},
	    {name => "PingPath"},
	    {name => "DfPath"},
	    {name => "SplitPath"},
	    {name => "ParPath"},
	    {name => "CatPath"},
	    {name => "GzipPath"},
	    {name => "Bzip2Path"},

            {text => "CfgEdit_Title_Install_Paths"},
            {name => "TopDir"},
            {name => "ConfDir"},
            {name => "LogDir"},
	    {name => "CgiDir"},
	    {name => "InstallDir"},
        ],
    },
    email => {
        text  => "CfgEdit_Title_Email",
        param => [
            {text => "CfgEdit_Title_Email_settings"},
            {name => "SendmailPath"},
            {name => "EMailNotifyMinDays"},
            {name => "EMailFromUserName"},
            {name => "EMailAdminUserName"},
            {name => "EMailUserDestDomain"},

            {text => "CfgEdit_Title_Email_User_Messages"},
	    {name => "EMailNoBackupEverSubj"},
	    {name => "EMailNoBackupEverMesg"},
	    {name => "EMailNotifyOldBackupDays"},
	    {name => "EMailNoBackupRecentSubj"},
	    {name => "EMailNoBackupRecentMesg"},
	    {name => "EMailNotifyOldOutlookDays"},
	    {name => "EMailOutlookBackupSubj"},
	    {name => "EMailOutlookBackupMesg"},
	    {name => "EMailHeaders"},
        ],
    },
    cgi => {
        text => "CfgEdit_Title_CGI",
        param => [
	    {text => "CfgEdit_Title_Admin_Privileges"},
	    {name => "CgiAdminUserGroup"},
	    {name => "CgiAdminUsers"},

	    {text => "CfgEdit_Title_Page_Rendering"},
	    {name => "Language"},
	    {name => "CgiNavBarAdminAllHosts"},
	    {name => "CgiSearchBoxEnable"},
	    {name => "CgiNavBarLinks"},
	    {name => "CgiStatusHilightColor"},
	    {name => "CgiDateFormatMMDD"},
	    {name => "CgiHeaders"},
	    {name => "CgiExt2ContentType"},
	    {name => "CgiCSSFile"},

	    {text => "CfgEdit_Title_Paths"},
	    {name => "CgiURL"},
	    {name => "CgiImageDir"},
	    {name => "CgiImageDirURL"},

	    {text => "CfgEdit_Title_User_URLs"},
	    {name => "CgiUserHomePageCheck"},
	    {name => "CgiUserUrlCreate"},

	    {text => "CfgEdit_Title_User_Config_Editing"},
	    {name => "CgiUserConfigEditEnable"},
	    {name => "CgiUserConfigEdit"},
        ],
    },
    xfer => {
        text => "CfgEdit_Title_Xfer",
        param => [
            {text => "CfgEdit_Title_Xfer_Settings"},
            {name => "XferMethod", onchangeSubmit => 1},
            {name => "XferLogLevel"},
            {name => "ClientCharset"},

            {text => "CfgEdit_Title_Smb_Settings",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; } },
            {name => "SmbShareName",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; } },
            {name => "SmbShareUserName",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; } },
            {name => "SmbSharePasswd",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; } },

            {text => "CfgEdit_Title_Tar_Settings",
                visible => sub { return $_[0]->{XferMethod} eq "tar"; } },
            {name => "TarShareName",
                visible => sub { return $_[0]->{XferMethod} eq "tar"; } },

            {text => "CfgEdit_Title_Rsync_Settings",
                visible => sub { return $_[0]->{XferMethod} eq "rsync"; } },
            {text => "CfgEdit_Title_Rsyncd_Settings",
                visible => sub { return $_[0]->{XferMethod} eq "rsyncd"; } },
            {name => "RsyncShareName",
                visible => sub { return $_[0]->{XferMethod} =~ /rsync/; } },
            {name => "RsyncdUserName",
                visible => sub { return $_[0]->{XferMethod} eq "rsyncd"; } },
            {name => "RsyncdPasswd",
                visible => sub { return $_[0]->{XferMethod} eq "rsyncd"; } },
            {name => "RsyncdAuthRequired",
                visible => sub { return $_[0]->{XferMethod} eq "rsyncd"; } },
            {name => "RsyncCsumCacheVerifyProb",
                visible => sub { return $_[0]->{XferMethod} =~ /rsync/; } },

            {text => "CfgEdit_Title_BackupPCd_Settings",
                visible => sub { return $_[0]->{XferMethod} eq "backuppcd"; } },
            {name => "BackupPCdShareName",
                visible => sub { return $_[0]->{XferMethod} eq "backuppcd"; } },
            {name => "BackupPCdPath",
                visible => sub { return $_[0]->{XferMethod} eq "backuppcd"; } },
            {name => "BackupPCdCmd",
                visible => sub { return $_[0]->{XferMethod} eq "backuppcd"; } },
            {name => "BackupPCdRestoreCmd",
                visible => sub { return $_[0]->{XferMethod} eq "backuppcd"; } },

            {text => "CfgEdit_Title_Archive_Settings",
                visible => sub { return $_[0]->{XferMethod} eq "archive"; } },
            {name => "ArchiveDest",
                visible => sub { return $_[0]->{XferMethod} eq "archive"; } },
            {name => "ArchiveComp",
                visible => sub { return $_[0]->{XferMethod} eq "archive"; } },
            {name => "ArchivePar",
                visible => sub { return $_[0]->{XferMethod} eq "archive"; } },
            {name => "ArchiveSplit",
                visible => sub { return $_[0]->{XferMethod} eq "archive"; } },

            {text => "CfgEdit_Title_Include_Exclude",
                visible => sub { return $_[0]->{XferMethod} ne "archive"; } },
            {name => "BackupFilesOnly",
                visible => sub { return $_[0]->{XferMethod} ne "archive"; } },
            {name => "BackupFilesExclude",
                visible => sub { return $_[0]->{XferMethod} ne "archive"; } },

            {text => "CfgEdit_Title_Smb_Paths_Commands",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; } },
            {name => "SmbClientPath",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; } },
            {name => "SmbClientFullCmd",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; } },
            {name => "SmbClientIncrCmd",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; } },
            {name => "SmbClientRestoreCmd",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; } },

            {text => "CfgEdit_Title_Tar_Paths_Commands",
                visible => sub { return $_[0]->{XferMethod} eq "tar"; } },
            {name => "TarClientPath",
                visible => sub { return $_[0]->{XferMethod} eq "tar"; } },
            {name => "TarClientCmd",
                visible => sub { return $_[0]->{XferMethod} eq "tar"; } },
            {name => "TarFullArgs",
                visible => sub { return $_[0]->{XferMethod} eq "tar"; } },
            {name => "TarIncrArgs",
                visible => sub { return $_[0]->{XferMethod} eq "tar"; } },
            {name => "TarClientRestoreCmd",
                visible => sub { return $_[0]->{XferMethod} eq "tar"; } },

            {text => "CfgEdit_Title_Rsync_Paths_Commands_Args",
                visible => sub { return $_[0]->{XferMethod} eq "rsync"; } },
            {text => "CfgEdit_Title_Rsyncd_Port_Args",
                visible => sub { return $_[0]->{XferMethod} eq "rsyncd"; } },
            {name => "RsyncClientPath",
                visible => sub { return $_[0]->{XferMethod} eq "rsync"; } },
            {name => "RsyncClientCmd",
                visible => sub { return $_[0]->{XferMethod} eq "rsync"; } },
            {name => "RsyncClientRestoreCmd",
                visible => sub { return $_[0]->{XferMethod} eq "rsync"; } },
            {name => "RsyncdClientPort",
                visible => sub { return $_[0]->{XferMethod} eq "rsyncd"; } },
            {name => "RsyncArgs",
                visible => sub { return $_[0]->{XferMethod} =~ /rsync/; } },
            {name => "RsyncRestoreArgs",
                visible => sub { return $_[0]->{XferMethod} =~ /rsync/; } },

            {text => "CfgEdit_Title_Archive_Paths_Commands",
                visible => sub { return $_[0]->{XferMethod} eq "archive"; } },
            {name => "ArchiveClientCmd",
                visible => sub { return $_[0]->{XferMethod} eq "archive"; } },

        ],
    },
    schedule => {
        text => "CfgEdit_Title_Schedule",
        param => [
	    {text => "CfgEdit_Title_Full_Backups"},
	    {name => "FullPeriod"},
	    {name => "FullKeepCnt"},
	    {name => "FullKeepCntMin"},
	    {name => "FullAgeMax"},

	    {text => "CfgEdit_Title_Incremental_Backups"},
	    {name => "IncrPeriod"},
	    {name => "IncrKeepCnt"},
	    {name => "IncrKeepCntMin"},
	    {name => "IncrAgeMax"},
	    {name => "IncrFill"},

	    {text => "CfgEdit_Title_Blackouts"},
            {name => "BlackoutBadPingLimit"},
            {name => "BlackoutGoodCnt"},
            {name => "BlackoutPeriods"},

	    {text => "CfgEdit_Title_Other"},
	    {name => "PartialAgeMax"},
	    {name => "RestoreInfoKeepCnt"},
	    {name => "ArchiveInfoKeepCnt"},
	    {name => "BackupZeroFilesIsFatal"},
	],
    },
    backup => {
        text => "CfgEdit_Title_Backup_Settings",
        param => [
	    {text => "CfgEdit_Title_Client_Lookup"},
	    {name => "ClientNameAlias"},
	    {name => "NmbLookupCmd"},
	    {name => "NmbLookupFindHostCmd"},
	    {name => "FixedIPNetBiosNameCheck"},
	    {name => "PingCmd"},
	    {name => "PingMaxMsec"},
	    
	    {text => "CfgEdit_Title_Other"},
	    {name => "ClientTimeout"},
	    {name => "MaxOldPerPCLogFiles"},
	    {name => "CompressLevel"},

	    {text => "CfgEdit_Title_User_Commands"},
	    {name => "DumpPreUserCmd"},
	    {name => "DumpPostUserCmd"},
	    {name => "DumpPreShareCmd"},
	    {name => "DumpPostShareCmd"},
	    {name => "RestorePreUserCmd"},
	    {name => "RestorePostUserCmd"},
	    {name => "ArchivePreUserCmd"},
	    {name => "ArchivePostUserCmd"},
	],
    },
    hosts => {
        text => "CfgEdit_Title_Hosts",
        param => [
	    {text    => "CfgEdit_Title_Hosts"},
	    {name    => "Hosts",
             comment => "CfgEdit_Hosts_Comment"},
        ],
    },
);

sub action
{
    my $pc_dir = "$TopDir/pc";
    my($content, $contentHidden, $newConf, $override, $mainConf, $hostConf);
    my $errors = {};

    my $host = $In{host};
    my $menu = $In{menu} || "server";
    my $hosts_path = $Hosts;
    my $config_path = $host eq "" ? "$TopDir/conf/config.pl"
                                  : "$TopDir/pc/$host/config.pl";

    my $Privileged = CheckPermission($host)
                       && ($PrivAdmin || $Conf{CgiUserConfigEditEnable});
    my $userHost = 1 if ( defined($host) );
    my $debugText;

    if ( !$Privileged ) {
        ErrorExit(eval("qq{$Lang->{Only_privileged_users_can_edit_config_files}}"));
    }

    if ( defined($In{menu}) || $In{editAction} eq $Lang->{CfgEdit_Button_Save} ) {
	$errors = errorCheck();
	if ( %$errors ) {
	    #
	    # If there are errors, then go back to the same menu
	    #
	    $In{editAction} = "";
            $In{newMenu} = "";
	}
        if ( (my $var = $In{overrideUncheck}) ne "" ) {
            #
            # a compound variable was unchecked; delete extra
            # variables to make the shape the same.
            #
            #print STDERR Dumper(\%In);
            foreach my $v ( keys(%In) ) {
                next if ( $v !~ /^v_z_(\Q$var\E(_z_.*|$))/ );
                delete($In{$v}) if ( !defined($In{"orig_z_$1"}) );
            }
            delete($In{"vflds.$var"});
        }

        ($newConf, $override) = inputParse($bpc, $userHost);
	$override = undef if ( $host eq "" );

    } else {
	#
	# First time: pick up the current config settings
	#
	$mainConf = $bpc->ConfigDataRead();
	if ( $host ne "" ) {
	    $hostConf = $bpc->ConfigDataRead($host);
	    $override = {};
	    foreach my $param ( keys(%$hostConf) ) {
		$override->{$param} = 1;
	    }
	} else {
            my $hostInfo = $bpc->HostInfoRead();
	    $hostConf = {};
            $mainConf->{Hosts} = [map($hostInfo->{$_}, sort(keys(%$hostInfo)))];
	}
	$newConf = { %$mainConf, %$hostConf };
    }

    if ( $In{editAction} ne $Lang->{CfgEdit_Button_Save} && $In{newMenu} ne ""
		    && defined($ConfigMenu{$In{newMenu}}) ) {
        $menu = $In{newMenu};
    }

    my %menuDisable;
    if ( $userHost ) {
        #
        # For a non-admin user editing the host config, we need to
        # figure out which subsets of the menu tree will be visible,
        # based on what is enabled.  Admin users can edit all the
        # available per-host settings.
        #
        foreach my $m ( keys(%ConfigMenu) ) {
            my $enabled = 0;
            my $text = -1;
            my $n = 0;
            my @mask = ();

            foreach my $paramInfo ( @{$ConfigMenu{$m}{param}} ) {
                my $param = $paramInfo->{name};
                if ( defined($paramInfo->{text}) ) {
                    $text = $n;
                    $mask[$text] = 1;
                } else {
                    if ( $bpc->{Conf}{CgiUserConfigEdit}{$param}
                          || (defined($bpc->{Conf}{CgiUserConfigEdit}{$param})
                                && $PrivAdmin) ) {
                        $mask[$text] = 0 if ( $text >= 0 );
                        $mask[$n] = 0;
                        $enabled ||= 1;
                    } else {
                        $mask[$n] = 1;
                    }
                }
                $n++;
            }
            $menuDisable{$m}{mask} = \@mask;
            $menuDisable{$m}{top}  = !$enabled;
        }
        if ( $menuDisable{$menu}{top} ) {
            #
            # Find an enabled menu if the current menu is empty
            #
            foreach my $m ( sort(keys(%menuDisable)) ) {
                if ( !$menuDisable{$m}{top} ) {
                    $menu = $m;
                    last;
                }
            }
        }
    }

    my $groupText;
    foreach my $m ( keys(%ConfigMenu) ) {
        next if ( $menuDisable{$m}{top} );
	my $text = eval("qq($Lang->{$ConfigMenu{$m}{text}})");
        if ( $m eq $menu ) {
            $groupText .= <<EOF;
<td class="editTabSel"><a href="javascript:menuSubmit('$m')"><b>$text</b></a></td>
EOF
        } else {
            $groupText .= <<EOF;
<td class="editTabNoSel"><a href="javascript:menuSubmit('$m')">$text</a></td>
EOF
        }
    }

    if ( $host eq "" ) {
	$content .= eval("qq($Lang->{CfgEdit_Header_Main})");
    } else {
	$content .= eval("qq($Lang->{CfgEdit_Header_Host})");
    }

    my $saveDisplay = "block";
    $saveDisplay = "none" if ( !$In{modified}
                          || $In{editAction} eq $Lang->{CfgEdit_Button_Save} );
    #
    # Add action and host to the URL so the nav bar link is
    # highlighted
    #
    my $url = "$MyURL?action=editConfig";
    $url .= "&host=$host" if ( $host ne "" );
    $content .= <<EOF;
<table border="0" cellpadding="2">
<tr>$groupText</tr>
<tr>
<form method="post" name="form1" action="$url">
<input type="hidden" name="host" value="$host">
<input type="hidden" name="menu" value="$menu">
<input type="hidden" name="newMenu" value="">
<input type="hidden" name="modified" value="$In{modified}">
<input type="hidden" name="deleteVar" value="">
<input type="hidden" name="insertVar" value="">
<input type="hidden" name="overrideUncheck" value="">
<input type="hidden" name="addVar" value="">
<input type="hidden" name="action" value="editConfig">
<input type="submit" class="editSaveButton" style="display: $saveDisplay" name="editAction" value="${EscHTML($Lang->{CfgEdit_Button_Save})}">

<script language="javascript" type="text/javascript">
<!--

    function deleteSubmit(varName)
    {
        document.form1.deleteVar.value = varName;
	document.form1.modified.value = 1;
        document.form1.submit();
        return;
    }

    function insertSubmit(varName)
    {
        document.form1.insertVar.value = varName;
	document.form1.modified.value = 1;
        document.form1.submit();
        return;
    }

    function addSubmit(varName, checkKey)
    {
        if ( checkKey
            && eval("document.form1.addVarKey_" + varName + ".value") == "" ) {
            alert("New key must be non-empty");
            return;
        }
        document.form1.addVar.value = varName;
	document.form1.modified.value = 1;
        document.form1.submit();
        return;
    }

    function menuSubmit(menuName)
    {
        document.form1.newMenu.value = menuName;
        document.form1.submit();
    }

    function varChange(varName)
    {
	document.form1.editAction.style.display = "block";
	document.form1.modified.value = 1;
    }

    function checkboxChange(varName)
    {
	document.form1.editAction.style.display = "block";
	document.form1.modified.value = 1;
	// Do nothing if the checkbox is now set
        if ( eval("document.form1.override_" + varName + ".checked") ) {
	    return false;
	}
	var allVars = {};
	var varRE  = new RegExp("^v_z_(" + varName + ".*)");
	var origRE = new RegExp("^orig_z_(" + varName + ".*)");
        for ( var i = 0 ; i < document.form1.elements.length ; i++ ) {
	    var e = document.form1.elements[i];
	    var re;
	    if ( (re = varRE.exec(e.name)) != null ) {
		if ( allVars[re[1]] == null ) {
		    allVars[re[1]] = 0;
		}
		allVars[re[1]]++;
		//debugMsg("found v_z_ match with " + re[1]);
		//debugMsg("allVars[" + re[1] + "] = " + allVars[re[1]]);
	    } else if ( (re = origRE.exec(e.name)) != null ) {
		if ( allVars[re[1]] == null ) {
		    allVars[re[1]] = 0;
		}
		allVars[re[1]]--;
		//debugMsg("allVars[" + re[1] + "] = " + allVars[re[1]]);
	    }
	}
	var sameShape = 1;
	for ( v in allVars ) {
	    if ( allVars[v] != 0 ) {
		//debugMsg("Not the same shape because of " + v);
		sameShape = 0;
	    } else {
                // copy the original variable values
		//debugMsg("setting " + v);
		eval("document.form1.v_z_" + v + ".value = document.form1.orig_z_" + v + ".value");
            }
	}
	if ( sameShape ) {
	    return true;
	} else {
            // need to rebuild the form since the compound variable
            // has changed shape
            document.form1.overrideUncheck.value = varName;
	    document.form1.submit();
	    return false;
	}
    }

    function checkboxSet(varName)
    {
	document.form1.editAction.style.display = "block";
	document.form1.modified.value = 1;
        eval("document.form1.override_" + varName + ".checked = 1;");
        return false;
    }

    var debugCounter = 0;
    function debugMsg(msg)
    {
	debugCounter++;
	var t = document.createTextNode(debugCounter + ": " + msg);
	var br = document.createElement("br");
	var debug = document.getElementById("debug");
	debug.appendChild(t);
	debug.appendChild(br);
    }

    function displayHelp(varName)
    {
	var help = document.getElementById("id_" + varName);
	help.style.display = help.style.display == "block" ? "none" : "block";
    }

//-->
</script>

<span id="debug">$debugText</span>

EOF

    $content .= <<EOF;
<table border="1" cellspacing="0">
EOF

    my $doneParam = {};

    #
    # There is a special case of the user deleting just the field
    # that has the error(s).  So if the delete variable is a match
    # or parent to all the errors then ignore the errors.
    #
    if ( $In{deleteVar} ne "" && %$errors > 0 ) {
        my $matchAll = 1;
        foreach my $v ( keys(%$errors) ) {
            if ( $v ne $In{deleteVar} && $v !~ /^\Q$In{deleteVar}_z_/ ) {
                $matchAll = 0;
                last;
            }
        }
        $errors = {} if ( $matchAll );
    }

    my $isError = %$errors;

    if ( !$isError && $In{editAction} eq $Lang->{CfgEdit_Button_Save} ) {
        my($mesg, $err);
	if ( $host ne "" ) {
	    $hostConf = $bpc->ConfigDataRead($host) if ( !defined($hostConf) );
            my %hostConf2 = %$hostConf;
	    foreach my $param ( keys(%$newConf) ) {
                if ( $override->{$param} ) {
                    $hostConf->{$param} = $newConf->{$param}
                } else {
                    delete($hostConf->{$param});
                }
	    }
            $mesg = configDiffMesg($host, \%hostConf2, $hostConf);
	    $err .= $bpc->ConfigDataWrite($host, $hostConf);
	} else {
	    $mainConf = $bpc->ConfigDataRead() if ( !defined($mainConf) );

            my $hostsSave = [];
            my($hostsNew, $allHosts, $copyConf);
            foreach my $entry ( @{$newConf->{Hosts}} ) {
                next if ( $entry->{host} eq "" );
                $allHosts->{$entry->{host}} = 1;
                $allHosts->{$1} = 1 if ( $entry->{host} =~ /(.+?)\s*=/ );
            }
            foreach my $entry ( @{$newConf->{Hosts}} ) {
                next if ( $entry->{host} eq ""
                           || defined($hostsNew->{$entry->{host}}) );
                if ( $entry->{host} =~ /(.+?)\s*=\s*(.+)/ ) {
                    if ( defined($allHosts->{$2}) ) {
                        $entry->{host} = $1;
                        $copyConf->{$1} = $2;
                    } else {
                        my $fullHost = $entry->{host};
                        my $copyHost = $2;
                        $err .= eval("qq($Lang->{CfgEdit_Error_Copy_host_does_not_exist})");
                    }
                }
                push(@$hostsSave, $entry);
                $hostsNew->{$entry->{host}} = $entry;
            }
            ($mesg, my $hostChange) = hostsDiffMesg($hostsNew);
            $bpc->HostInfoWrite($hostsNew) if ( $hostChange );
            foreach my $host ( keys(%$copyConf) ) {
                my $confData = $bpc->ConfigDataRead($copyConf->{$host});
                my $fromHost = $copyConf->{$host};
                $err  .= $bpc->ConfigDataWrite($host, $confData);
                $mesg .= eval("qq($Lang->{CfgEdit_Log_Copy_host_config})");
            }

            delete($newConf->{Hosts});
            $mesg .= configDiffMesg(undef, $mainConf, $newConf);
	    $mainConf = { %$mainConf, %$newConf };
	    $err .= $bpc->ConfigDataWrite(undef, $mainConf);
            $newConf->{Hosts} = $hostsSave;
	}
        if ( defined($err) ) {
            $content .= <<EOF;
<tr><td colspan="2" class="border"><span class="editError">$err</span></td></tr>
EOF
        }
        $bpc->ServerConnect();
        if ( $mesg ne "" ) {
            (my $mesgBR = $mesg) =~ s/\n/<br>\n/g;
            $content .= <<EOF;
<tr><td colspan="2" class="border"><span class="editComment">$mesgBR</span></td></tr>
EOF
            foreach my $str ( split(/\n/, $mesg) ) {
                $bpc->ServerMesg("log $str") if ( $str ne "" );
            }
        }
        #
        # Tell the server to reload, unless we only changed
        # a client config
        #
        $bpc->ServerMesg("server reload") if ( $host eq "" );
    }

    my @mask = @{$menuDisable{$menu}{mask} || []};

    foreach my $paramInfo ( @{$ConfigMenu{$menu}{param}} ) {

        my $param    = $paramInfo->{name};
        my $disabled = shift(@mask);

        next if ( $disabled || $menuDisable{$menu}{top} );
        if ( ref($paramInfo->{visible}) eq "CODE"
                        && !&{$paramInfo->{visible}}($newConf) ) {
            next;
        }

	if ( defined($paramInfo->{text}) ) {
            my $text = eval("qq($Lang->{$paramInfo->{text}})");
	    $content .= <<EOF;
<tr><td colspan="2" class="editHeader">$text</td></tr>
EOF
	    next;
	}

	#
	# TODO: get parameter documentation
	#
	my $comment = "";
	#$comment =~ s/\'//g;
	#$comment =~ s/\"//g;
        #$comment =~ s/\n/ /g;

        $doneParam->{$param} = 1;

        $content .= fieldEditBuild($ConfigMeta{$param},
                              $param,
                              $newConf->{$param},
                              $errors,
                              0,
                              $comment,
                              $isError,
                              $paramInfo->{onchangeSubmit},
		              defined($override) ? $param : undef,
			      defined($override) ? $override->{$param} : undef
                        );
        if ( defined($paramInfo->{comment}) ) {
            my $topDir = $bpc->TopDir;
            my $text = eval("qq($Lang->{$paramInfo->{comment}})");
	    $content .= <<EOF;
<tr><td colspan="2" class="editComment">$text</td></tr>
EOF
        }
    }

    #
    # Emit any remaining errors - should not happen
    #
    foreach my $param ( sort(keys(%$errors)) ) {
	$content .= <<EOF;
<tr><td colspan="2" class="border"><span class="editError">$errors->{$param}</span></td></tr>
EOF
	delete($errors->{$param});
    }

    $content .= <<EOF;
</table>
EOF

    #
    # Emit all the remaining editable config settings as hidden values
    #
    foreach my $param ( keys(%ConfigMeta) ) {
        next if ( $doneParam->{$param} );
        next if ( $userHost
                      && (!defined($bpc->{Conf}{CgiUserConfigEdit}{$param})
                         || (!$PrivAdmin
                             && !$bpc->{Conf}{CgiUserConfigEdit}{$param})) );
        $content .= fieldHiddenBuild($ConfigMeta{$param},
                            $param,
                            $newConf->{$param},
                            "v"
                        );
        if ( defined($override) ) {
            $content .= <<EOF;
<input type="hidden" name="override_$param" value="$override->{$param}">
EOF
        }
        $doneParam->{$param} = 1;
    }

    if ( defined($In{menu}) || $In{editAction} eq $Lang->{CfgEdit_Button_Save} ) {
        if ( $In{editAction} eq $Lang->{CfgEdit_Button_Save}
                && !$userHost ) {
            #
            # Emit the new settings as orig_z_ parameters
            #
            $doneParam = {};
            foreach my $param ( keys(%ConfigMeta) ) {
                next if ( $doneParam->{$param} );
                next if ( $userHost
                          && (!defined($bpc->{Conf}{CgiUserConfigEdit}{$param})
                             || (!$PrivAdmin
                                && !$bpc->{Conf}{CgiUserConfigEdit}{$param})) );
                $contentHidden .= fieldHiddenBuild($ConfigMeta{$param},
                                        $param,
                                        $newConf->{$param},
                                        "orig",
                                    );
                $doneParam->{$param} = 1;
                $In{modified} = 0;
            }
        } else {
            #
            # Just switching menus: copy all the orig_z_ input parameters
            #
            foreach my $var ( keys(%In) ) {
                next if ( $var !~ /^orig_z_/ );
                $contentHidden .= <<EOF;
<input type="hidden" name="$var" value="${EscHTML($In{$var})}">
EOF
            }
	}
    } else {
	#
	# First time: emit all the original config settings
	#
	$doneParam = {};
        foreach my $param ( keys(%ConfigMeta) ) {
            next if ( $doneParam->{$param} );
            next if ( $userHost
                          && (!defined($bpc->{Conf}{CgiUserConfigEdit}{$param})
                             || (!$PrivAdmin
                                && !$bpc->{Conf}{CgiUserConfigEdit}{$param})) );
            $contentHidden .= fieldHiddenBuild($ConfigMeta{$param},
                                    $param,
                                    $mainConf->{$param},
                                    "orig",
                                );
            $doneParam->{$param} = 1;
	}
    }

    $content .= <<EOF;
$contentHidden
</form>
</tr>
</table>
EOF

    Header("Config Edit", $content);
    Trailer();
}

sub fieldHiddenBuild
{
    my($type, $varName, $varValue, $prefix) = @_;
    my $content;

    $type = { type => $type } if ( ref($type) ne "HASH" );

    if ( $type->{type} eq "list" ) {
        $varValue = [] if ( !defined($varValue) );
        $varValue = [$varValue] if ( ref($varValue) ne "ARRAY" );

        for ( my $i = 0 ; $i < @$varValue ; $i++ ) {
            $content .= fieldHiddenBuild($type->{child}, "${varName}_z_$i",
                                         $varValue->[$i], $prefix);
        }
    } elsif ( $type->{type} eq "hash" || $type->{type} eq "horizHash" ) {
        $varValue = {} if ( ref($varValue) ne "HASH" );
        my(@order, $childType);

        if ( defined($type->{order}) ) {
            @order = @{$type->{order}};
        } elsif ( defined($type->{child}) ) {
            @order = sort(keys(%{$type->{child}}));
        } else {
            @order = sort(keys(%$varValue));
        }

        foreach my $fld ( @order ) {
            if ( defined($type->{child}) ) {
                $childType = $type->{child}{$fld};
            } else {
                $childType = $type->{childType};
                #
                # emit list of fields since they are user-defined
                # rather than hard-coded
                #
                $content .= <<EOF;
<input type="hidden" name="vflds.$varName" value="${EscHTML($fld)}">
EOF
            }
            $content .= fieldHiddenBuild($childType, "${varName}_z_$fld",
                                         $varValue->{$fld}, $prefix);
        }
    } elsif ( $type->{type} eq "shortlist" ) {
	$varValue = [$varValue] if ( ref($varValue) ne "ARRAY" );
	$varValue = join(", ", @$varValue);
        $content .= <<EOF;
<input type="hidden" name="${prefix}_z_$varName" value="${EscHTML($varValue)}">
EOF
    } else {
        $content .= <<EOF;
<input type="hidden" name="${prefix}_z_$varName" value="${EscHTML($varValue)}">
EOF
    }
    return $content;
}

sub fieldEditBuild
{
    my($type, $varName, $varValue, $errors, $level, $comment, $isError,
       $onchangeSubmit, $overrideVar, $overrideSet) = @_;

    my $content;
    my $size = 50 - 10 * $level;
    $type = { type => $type } if ( ref($type) ne "HASH" );

    $size = $type->{size} if ( defined($type->{size}) );

    #
    # These fragments allow inline conent to be turned on and off
    #
    # <tr><td colspan="2"><span id="id_$varName" style="display: none" class="editComment">$comment</span></td></tr>
    # <tr><td class="border"><a href="javascript: displayHelp('$varName')">$varName</a>
    #

    if ( $level == 0 ) {
        my $lcVarName = lc($varName);
	$content .= <<EOF;
<tr><td class="border"><a href="?action=view&type=docs#item_%24conf%7b$lcVarName%7d">$varName</a>
EOF
	if ( defined($overrideVar) ) {
	    my $override_checked = "";
	    if ( !$isError && $In{deleteVar}      =~ /^\Q${varName}_z_/
		   || !$isError && $In{insertVar} =~ /^\Q${varName}\E(_z_|$)/
		   || !$isError && $In{addVar}    =~ /^\Q${varName}\E(_z_|$)/ ) {
		$overrideSet = 1;
	    }
	    if ( $overrideSet ) {
		$override_checked = "checked";
	    }
            $content .= <<EOF;
<br><input type="checkbox" name="override_$varName" $override_checked value="1" onClick="checkboxChange('$varName')">\&nbsp;${EscHTML($Lang->{CfgEdit_Button_Override})}
EOF
	}
	$content .= "</td>\n";
    }

    if ( $type->{type} eq "list" ) {
        $content .= "<td class=\"border\">\n";
        $varValue = [] if ( !defined($varValue) );
        $varValue = [$varValue] if ( ref($varValue) ne "ARRAY" );
        if ( !$isError && $In{deleteVar} =~ /^\Q${varName}_z_\E(\d+)$/
                && $1 < @$varValue ) {
            #
            # User deleted entry in this array
            #
            splice(@$varValue, $1, 1) if ( @$varValue > 1 || $type->{emptyOk} );
            $In{deleteVar} = "";
        }
        if ( !$isError && $In{insertVar} =~ /^\Q${varName}_z_\E(\d+)$/
                && $1 < @$varValue ) {
            #
            # User inserted entry in this array
            #
            splice(@$varValue, $1, 0, "")
                        if ( @$varValue > 1 || $type->{emptyOk} );
            $In{insertVar} = "";
        }
        if ( !$isError && $In{addVar} eq $varName ) {
            #
            # User added entry to this array
            #
            push(@$varValue, undef);
            $In{addVar} = "";
        }
        $content .= "<table border=\"1\" cellspacing=\"0\">\n";

        if ( ref($type) eq "HASH" && ref($type->{child}) eq "HASH"
                    && $type->{child}{type} eq "horizHash" ) {
            my @order;
            if ( defined($type->{child}{order}) ) {
                @order = @{$type->{child}{order}};
            } else {
                @order = sort(keys(%{$type->{child}{child}}));
            }
            $content .= "<tr><td class=\"border\"></td>\n";
            for ( my $i = 0 ; $i < @order ; $i++ ) {
                $content .= "<td>$order[$i]</td>\n";
            }
            $content .= "</tr>\n";
            for ( my $i = 0 ; $i < @$varValue ; $i++ ) {
                if ( @$varValue > 1 || $type->{emptyOk} ) {
                    $content .= <<EOF;
<td class="border">
<input type="button" name="del_${varName}_z_$i" value="${EscHTML($Lang->{CfgEdit_Button_Delete})}"
    onClick="deleteSubmit('${varName}_z_$i')">
</td>
EOF
                }
                $content .= fieldEditBuild($type->{child}, "${varName}_z_$i",
                                  $varValue->[$i], $errors, $level + 1, undef,
                                  $isError, $onchangeSubmit,
                                  $overrideVar, $overrideSet);
                $content .= "</tr>\n";
            }
        } else {
            for ( my $i = 0 ; $i < @$varValue ; $i++ ) {
                $content .= <<EOF;
<tr><td class="border">
<input type="button" name="ins_${varName}_z_$i" value="${EscHTML($Lang->{CfgEdit_Button_Insert})}"
    onClick="insertSubmit('${varName}_z_$i')">
EOF
                if ( @$varValue > 1 || $type->{emptyOk} ) {
                    $content .= <<EOF;
<input type="button" name="del_${varName}_z_$i" value="${EscHTML($Lang->{CfgEdit_Button_Delete})}"
    onClick="deleteSubmit('${varName}_z_$i')">
EOF
                }
                $content .= "</td>\n";
                $content .= fieldEditBuild($type->{child}, "${varName}_z_$i",
                                    $varValue->[$i], $errors, $level + 1, undef,
                                    $isError, $onchangeSubmit,
                                    $overrideVar, $overrideSet);
                $content .= "</tr>\n";
            }
        }
        $content .= <<EOF;
<tr><td class="border"><input type="button" name="add_$varName" value="${EscHTML($Lang->{CfgEdit_Button_Add})}"
    onClick="addSubmit('$varName')"></td></tr>
</table>
EOF
        $content .= "</td>\n";
    } elsif ( $type->{type} eq "hash" ) {
        $content .= "<td class=\"border\">\n";
        $content .= "<table border=\"1\" cellspacing=\"0\">\n";
        $varValue = {} if ( ref($varValue) ne "HASH" );

        if ( !$isError && !$type->{noKeyEdit}
                        && $In{deleteVar} !~ /^\Q${varName}_z_\E.*_z_/
                        && $In{deleteVar} =~ /^\Q${varName}_z_\E(\w+)$/ ) {
            #
            # User deleted entry in this hash
            #
            delete($varValue->{$1}) if ( keys(%$varValue) > 1
					    || $type->{emptyOk} );
            $In{deleteVar} = "";
        }
        if ( !$isError && !defined($type->{child})
                        && $In{addVar} eq $varName ) {
            #
            # User added entry to this array
            #
            $varValue->{$In{"addVarKey_$varName"}} = ""
                        if ( !defined($varValue->{$In{"addVarKey_$varName"}}) );
            $In{addVar} = "";
        }
        my(@order, $childType);

        if ( defined($type->{order}) ) {
            @order = @{$type->{order}};
        } elsif ( defined($type->{child}) ) {
            @order = sort(keys(%{$type->{child}}));
        } else {
            @order = sort(keys(%$varValue));
        }

        foreach my $fld ( @order ) {
            $content .= <<EOF;
<tr><td class="border">$fld
EOF
            if ( !$type->{noKeyEdit}
		    && (keys(%$varValue) > 1 || $type->{emptyOk}) ) {
                $content .= <<EOF;
<input type="submit" name="del_${varName}_z_$fld" value="${EscHTML($Lang->{CfgEdit_Button_Delete})}"
        onClick="deleteSubmit('${varName}_z_$fld')">
EOF
            }
            if ( defined($type->{child}) ) {
                $childType = $type->{child}{$fld};
            } else {
                $childType = $type->{childType};
                #
                # emit list of fields since they are user-defined
                # rather than hard-coded
                #
                $content .= <<EOF;
<input type="hidden" name="vflds.$varName" value="${EscHTML($fld)}">
EOF
            }
            $content .= "</td>\n";
            $content .= fieldEditBuild($childType, "${varName}_z_$fld",
                            $varValue->{$fld}, $errors, $level + 1, undef,
			    $isError, $onchangeSubmit,
			    $overrideVar, $overrideSet);
            $content .= "</tr>\n";
        }

        if ( !$type->{noKeyEdit} ) {
            $content .= <<EOF;
<tr><td class="border" colspan="2">
New key: <input type="text" name="addVarKey_$varName" size="20" maxlength="256" value="">
<input type="button" name="add_$varName" value="${EscHTML($Lang->{CfgEdit_Button_Add})}" onClick="addSubmit('$varName', 1)">
</td></tr>
EOF
        }
        $content .= "</table>\n";
        $content .= "</td>\n";
    } elsif ( $type->{type} eq "horizHash" ) {
        $varValue = {} if ( ref($varValue) ne "HASH" );
        my(@order, $childType);

        if ( defined($type->{order}) ) {
            @order = @{$type->{order}};
        } elsif ( defined($type->{child}) ) {
            @order = sort(keys(%{$type->{child}}));
        } else {
            @order = sort(keys(%$varValue));
        }

        foreach my $fld ( @order ) {
            if ( defined($type->{child}) ) {
                $childType = $type->{child}{$fld};
            } else {
                $childType = $type->{childType};
                #
                # emit list of fields since they are user-defined
                # rather than hard-coded
                #
                $content .= <<EOF;
<input type="hidden" name="vflds.$varName" value="${EscHTML($fld)}">
EOF
            }
            $content .= fieldEditBuild($childType, "${varName}_z_$fld",
                            $varValue->{$fld}, $errors, $level + 1, undef,
			    $isError, $onchangeSubmit,
			    $overrideVar, $overrideSet);
        }
    } else {
        $content .= "<td class=\"border\">\n";
        if ( $isError ) {
            #
            # If there was an error, we use the original post values
            # in %In, rather than the parsed values in $varValue.
            # This is so that the user's erroneous input is preserved.
            #
            $varValue = $In{"v_z_$varName"} if ( defined($In{"v_z_$varName"}) );
        }
        if ( defined($errors->{$varName}) ) {
            $content .= <<EOF;
<span class="editError">$errors->{$varName}</span><br>
EOF
	    delete($errors->{$varName});
        }
        my $onChange;
	if ( defined($overrideVar) ) {
            $onChange .= "checkboxSet('$overrideVar');";
	} else {
            $onChange .= "varChange('$overrideVar');";
	}
        if ( $onchangeSubmit ) {
            $onChange .= "document.form1.submit();";
        }
	if ( $onChange ne "" ) {
            $onChange = " onChange=\"$onChange\"";
	}
        if ( $varValue !~ /\n/ &&
		($type->{type} eq "integer"
		    || $type->{type} eq "string"
		    || $type->{type} eq "execPath"
		    || $type->{type} eq "shortlist"
		    || $type->{type} eq "float") ) {
            # simple input box
	    if ( $type->{type} eq "shortlist" ) {
		$varValue = [$varValue] if ( ref($varValue) ne "ARRAY" );
		$varValue = join(", ", @$varValue);
	    }
            my $textType = ($varName =~ /Passwd/) ? "password" : "text";
            $content .= <<EOF;
<input type="$textType" name="v_z_$varName" size="$size" maxlength="256" value="${EscHTML($varValue)}"$onChange>
EOF
        } elsif ( $type->{type} eq "boolean" ) {
            # checkbox
            my $checked = "checked" if ( $varValue );
            $content .= <<EOF;
<input type="checkbox" name="v_z_$varName" $checked value="1"$onChange>
EOF
        } elsif ( $type->{type} eq "select" ) {
            $content .= <<EOF;
<select name="v_z_$varName"$onChange>
EOF
            foreach my $option ( @{$type->{values}} ) {
                my $sel = " selected" if ( $varValue eq $option );
                $content .= "<option$sel>$option</option>\n";
            }
            $content .= "</select>\n";
        } else {
            # multi-line text area - count number of lines
	    my $rowCnt = $varValue =~ tr/\n//;
	    $rowCnt = 1 if ( $rowCnt < 1 );
            $content .= <<EOF;
<textarea name="v_z_$varName" cols="$size" rows="$rowCnt"$onChange>${EscHTML($varValue)}</textarea>
EOF
        }
        $content .= "</td>\n";
    }
    return $content;
}

sub errorCheck
{
    my $errors = {};

    foreach my $param ( keys(%ConfigMeta) ) {
        fieldErrorCheck($ConfigMeta{$param}, $param, $errors);
    }
    return $errors;
}

sub fieldErrorCheck
{
    my($type, $varName, $errors) = @_;

    $type = { type => $type } if ( ref($type) ne "HASH" );

    if ( $type->{type} eq "list" ) {
        for ( my $i = 0 ; ; $i++ ) {
            last if ( fieldErrorCheck($type->{child}, "${varName}_z_$i", $errors) );
        }
    } elsif ( $type->{type} eq "hash" || $type->{type} eq "horizHash" ) {
        my(@order, $childType);
        my $ret;

        if ( defined($type->{order}) ) {
            @order = @{$type->{order}};
        } elsif ( defined($type->{child}) ) {
            @order = sort(keys(%{$type->{child}}));
        } else {
            @order = split(/\0/, $In{"vflds.$varName"});
        }
        foreach my $fld ( @order ) {
            if ( defined($type->{child}) ) {
                $childType = $type->{child}{$fld};
            } else {
                $childType = $type->{childType};
            }
            $ret ||= fieldErrorCheck($childType, "${varName}_z_$fld", $errors);
        }
        return $ret;
    } else {
        $In{"v_z_$varName"} = "0" if ( $type->{type} eq "boolean"
                                        && $In{"v_z_$varName"} eq "" );

        return 1 if ( !exists($In{"v_z_$varName"}) );

        (my $var = $varName) =~ s/_z_/./g;

        if ( $type->{type} eq "integer"
                || $type->{type} eq "boolean" ) {
            if ( $In{"v_z_$varName"} !~ /^-?\d+\s*$/s
			    && $In{"v_z_$varName"} ne "" ) {
                $errors->{$varName} = eval("qq{$Lang->{CfgEdit_Error__must_be_an_integer}}");
            }
        } elsif ( $type->{type} eq "float" ) {
            if ( $In{"v_z_$varName"} !~ /^-?\d*(\.\d*)?\s*$/s
			    && $In{"v_z_$varName"} ne "" ) {
                $errors->{$varName}
                        = eval("qq{$Lang->{CfgEdit_Error__must_be_real_valued_number}}");
            }
        } elsif ( $type->{type} eq "shortlist" ) {
	    my @vals = split(/[,\s]+/, $In{"v_z_$varName"});
	    for ( my $i = 0 ; $i < @vals ; $i++ ) {
		if ( $type->{child} eq "integer"
			&& $vals[$i] !~ /^-?\d+\s*$/s
			&& $vals[$i] ne "" ) {
		    my $k = $i + 1;
		    $errors->{$varName} = eval("qq{$Lang->{CfgEdit_Error__entry__must_be_an_integer}}");
		} elsif ( $type->{child} eq "float"
			&& $vals[$i] !~ /^-?\d*(\.\d*)?\s*$/s
			&& $vals[$i] ne "" ) {
		    my $k = $i + 1;
		    $errors->{$varName} = eval("qq{$Lang->{CfgEdit_Error__entry__must_be_real_valued_number}}");
		}
	    }
        } elsif ( $type->{type} eq "select" ) {
            my $match = 0;
            foreach my $option ( @{$type->{values}} ) {
                if ( $In{"v_z_$varName"} eq $option ) {
                    $match = 1;
                    last;
                }
            }
            $errors->{$varName} = eval("qq{$Lang->{CfgEdit_Error__must_be_valid_option}}")
                            if ( !$match );
        } elsif ( $type->{type} eq "execPath" ) {
            if ( $In{"v_z_$varName"} ne "" && !-x $In{"v_z_$varName"} ) {
                $errors->{$varName} = eval("qq{$Lang->{CfgEdit_Error__must_be_executable_program}}");
            }
        } else {
            #
            # $type->{type} eq "string": no error checking
            #
        }
    }
    return 0;
}

sub inputParse
{
    my($bpc, $userHost) = @_;
    my $conf     = {};
    my $override = {};

    foreach my $param ( keys(%ConfigMeta) ) {
        my $value;
        next if ( $userHost
                      && (!defined($bpc->{Conf}{CgiUserConfigEdit}{$param})
                         || (!$PrivAdmin
                            && !$bpc->{Conf}{CgiUserConfigEdit}{$param})) );
        fieldInputParse($ConfigMeta{$param}, $param, \$value);
        $conf->{$param}     = $value;
        $override->{$param} = $In{"override_$param"};
    }
    return ($conf, $override);
}

sub fieldInputParse
{
    my($type, $varName, $value) = @_;

    $type = { type => $type } if ( ref($type) ne "HASH" );

    if ( $type->{type} eq "list" ) {
        $$value = [];
        for ( my $i = 0 ; ; $i++ ) {
            my $val;
            last if ( fieldInputParse($type->{child}, "${varName}_z_$i", \$val) );
            push(@$$value, $val);
        }
        $$value = undef if ( $type->{undefIfEmpty} && @$$value == 0 );
    } elsif ( $type->{type} eq "hash" || $type->{type} eq "horizHash" ) {
        my(@order, $childType);
        my $ret;
        $$value = {};

        if ( defined($type->{order}) ) {
            @order = @{$type->{order}};
        } elsif ( defined($type->{child}) ) {
            @order = sort(keys(%{$type->{child}}));
        } else {
            @order = split(/\0/, $In{"vflds.$varName"});
        }

        foreach my $fld ( @order ) {
            my $val;
            if ( defined($type->{child}) ) {
                $childType = $type->{child}{$fld};
            } else {
                $childType = $type->{childType};
            }
            $ret ||= fieldInputParse($childType, "${varName}_z_$fld", \$val);
            last if ( $ret );
            $$value->{$fld} = $val;
        }
        return $ret;
    } else {
        if ( $type->{type} eq "boolean" ) {
            $$value = 0 + $In{"v_z_$varName"};
        } elsif ( !exists($In{"v_z_$varName"}) ) {
            return 1;
        }

        if ( $type->{type} eq "integer" ) {
            $$value = 0 + $In{"v_z_$varName"};
        } elsif ( $type->{type} eq "float" ) {
            $$value = 0 + $In{"v_z_$varName"};
        } elsif ( $type->{type} eq "shortlist" ) {
            $$value = [split(/[,\s]+/, $In{"v_z_$varName"})];
            if ( $type->{child} eq "float"
                    || $type->{child} eq "integer"
                    || $type->{child} eq "boolean" ) {
                foreach ( @$$value ) {
                    $_ += 0;
                }
            }
        } else {
            $$value = $In{"v_z_$varName"};
            $$value =~ s/\r\n/\n/g;
        }
        $$value = undef if ( $type->{undefIfEmpty} && $$value eq "" );
    }
    return 0;
}

sub configDiffMesg
{
    my($host, $oldConf, $newConf) = @_;
    my $mesg;
    my $conf;

    if ( $host ne "" ) {
        $conf = "host $host config";
    } else {
        $conf = "main config";
    }

    foreach my $p ( keys(%ConfigMeta) ) {
        if ( !exists($oldConf->{$p}) && !exists($newConf->{$p}) ) {
            next;
        } elsif ( exists($oldConf->{$p}) && !exists($newConf->{$p}) ) {
            $mesg .= eval("qq($Lang->{CfgEdit_Log_Delete_param})");
        } elsif ( !exists($oldConf->{$p}) && exists($newConf->{$p}) ) {
            my $dump = Data::Dumper->new([$newConf->{$p}]);
            $dump->Indent(0);
            $dump->Sortkeys(1);
            $dump->Terse(1);
            my $value = $dump->Dump;
            $value =~ s/\n/\\n/g;
            $value =~ s/\r/\\r/g;
            $mesg .= eval("qq($Lang->{CfgEdit_Log_Add_param_value})");
        } else {
            my $dump = Data::Dumper->new([$newConf->{$p}]);
            $dump->Indent(0);
            $dump->Sortkeys(1);
            $dump->Terse(1);
            my $valueNew = $dump->Dump;

            my $v = $oldConf->{$p};
            if ( ref($newConf->{$p}) eq "ARRAY" && ref($v) eq "" ) {
                $v = [$v];
            }
            $dump = Data::Dumper->new([$v]);
            $dump->Indent(0);
            $dump->Sortkeys(1);
            $dump->Terse(1);
            my $valueOld = $dump->Dump;

            (my $valueNew2 = $valueNew) =~ s/['\n\r]//g;
            (my $valueOld2 = $valueOld) =~ s/['\n\r]//g;
            $valueNew =~ s/\n/\\n/g;
            $valueOld =~ s/\n/\\n/g;
            $valueNew =~ s/\r/\\r/g;
            $valueOld =~ s/\r/\\r/g;
            $mesg .= eval("qq($Lang->{CfgEdit_Log_Change_param_value})")
                                    if ( $valueOld2 ne $valueNew2 );
        }
    }
    return $mesg;
}

sub hostsDiffMesg
{
    my($hostsNew) = @_;
    my $hostsOld = $bpc->HostInfoRead();
    my($mesg, $hostChange);

    foreach my $host ( keys(%$hostsOld) ) {
        if ( !defined($hostsNew->{$host}) ) {
            $mesg .= eval("qq($Lang->{CfgEdit_Log_Host_Delete})");
            $hostChange++;
            next;
        }
        foreach my $key ( keys(%{$hostsNew->{$host}}) ) {
            next if ( $hostsNew->{$host}{$key} eq $hostsOld->{$host}{$key} );
            my $valueOld = $hostsOld->{$host}{$key};
            my $valueNew = $hostsNew->{$host}{$key};
            $mesg .= eval("qq($Lang->{CfgEdit_Log_Host_Change})");
            $hostChange++;
        }
    }

    foreach my $host ( keys(%$hostsNew) ) {
        next if ( defined($hostsOld->{$host}) );
        my $dump = Data::Dumper->new([$hostsNew->{$host}]);
        $dump->Indent(0);
        $dump->Sortkeys(1);
        $dump->Terse(1);
        my $value = $dump->Dump;
        $value =~ s/\n/\\n/g;
        $value =~ s/\r/\\r/g;
        $mesg .= eval("qq($Lang->{CfgEdit_Log_Host_Add})");
        $hostChange++;
    }
    return ($mesg, $hostChange);
}

1;
