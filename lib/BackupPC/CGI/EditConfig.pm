#============================================================= -*-perl-*-
#
# BackupPC::CGI::EditConfig package
#
# DESCRIPTION
#
#   This module implements the EditConfig action for the CGI interface.
#
# AUTHOR
#   Craig Barratt
#
# COPYRIGHT
#   Copyright (C) 2005-2025  Craig Barratt
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
# 16 Oct 2025, for release with
# Version 4.4.1.
#
# See https://backuppc.github.io/backuppc/
#
#========================================================================

package BackupPC::CGI::EditConfig;

use strict;
use BackupPC::CGI::Lib     qw(:all);
use BackupPC::Config::Meta qw(:all);
use BackupPC::Storage;
use Data::Dumper;
use Encode;

my $debugText = "";

our %ConfigMenu = (
    server => {
        text  => "CfgEdit_Title_Server",
        param => [
            {text => "CfgEdit_Title_General_Parameters"},
            {name => "ServerHost"},
            {name => "PoolV3Enabled"},
            {name => "BackupPCUser"},
            {name => "BackupPCUserVerify"},
            {name => "MaxOldLogFiles"},

            {text => "CfgEdit_Title_Wakeup_Schedule"},
            {name => "WakeupSchedule"},

            {text => "CfgEdit_Title_Concurrent_Jobs"},
            {name => "MaxBackups"},
            {name => "MaxUserBackups"},
            {name => "MaxPendingCmds"},
            {name => "MaxBackupPCNightlyJobs"},
            {name => "BackupPCNightlyPeriod"},
            {name => "PoolSizeNightlyUpdatePeriod"},
            {name => "PoolNightlyDigestCheckPercent"},

            {text => "CfgEdit_Title_Pool_Filesystem_Limits"},
            {name => "DfCmd"},
            {name => "DfMaxUsagePct"},
            {name => "DfInodeUsageCmd"},
            {name => "DfMaxInodeUsagePct"},
            {name => "HardLinkMax"},

            {text => "CfgEdit_Title_Other_Parameters"},
            {name => "UmaskMode"},
            {name => "MyPath"},
            {name => "DHCPAddressRanges"},
            {name => "CmdQueueNice"},
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
            {name => "Ping6Path"},
            {name => "DfPath"},
            {name => "SplitPath"},
            {name => "ParPath"},
            {name => "CatPath"},
            {name => "GzipPath"},
            {name => "Bzip2Path"},
            {name => "RrdToolPath"},

            {text => "CfgEdit_Title_Install_Paths"},
            #
            # Can only edit TopDir and LogDir if we are in FHS mode.
            # Otherwise they are hardcoded in lib/BackupPC/Lib.pm.
            #
            {
                name    => "TopDir",
                visible => sub { return $_[1]->useFHS(); }
            },
            {
                name    => "LogDir",
                visible => sub { return $_[1]->useFHS(); }
            },
            {
                name    => "RunDir",
                visible => sub { return $_[1]->useFHS(); }
            },
            {name => "CgiDir"},
            #
            # Cannot edit ConfDir or InstallDir, since the real value is hardcoded in
            # lib/BackupPC/Lib.pm.
            # {name => "ConfDir"},
            # {name => "InstallDir"},
            #
        ],
    },
    email => {
        text  => "CfgEdit_Title_Email",
        param => [
            {text => "CfgEdit_Title_Email_settings"},
            {name => "SendmailPath"},
            {name => "SendmailArgs"},
            {name => "EMailNotifyMinDays"},
            {name => "EMailFromUserName"},
            {name => "EMailAdminUserName"},
            {name => "EMailAdminSubject"},
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
        text  => "CfgEdit_Title_CGI",
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
            {name => "SCGIServerPort"},
            {name => "CgiURL"},
            {name => "CgiImageDir"},
            {name => "CgiImageDirURL"},

            {text => "CfgEdit_Title_User_URLs"},
            {name => "CgiUserHomePageCheck"},
            {name => "CgiUserUrlCreate"},

            {text => "CfgEdit_Title_User_Config_Editing"},
            {name => "CgiUserDeleteBackupEnable"},
            {name => "CgiUserConfigEditEnable"},
            {name => "CgiUserConfigEdit"},
        ],
    },
    xfer => {
        text  => "CfgEdit_Title_Xfer",
        param => [
            {text => "CfgEdit_Title_Xfer_Settings"},
            {name => "XferMethod", onchangeSubmit => 1},
            {name => "XferLogLevel"},
            {name => "ClientCharset"},
            {name => "ClientCharsetLegacy"},
            {name => "ClientShareName2Path"},
            {name => "RefCntFsck"},

            ### Smb Settings
            {
                text    => "CfgEdit_Title_Smb_Settings",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; }
            },
            {
                name    => "SmbShareName",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; }
            },
            {
                name    => "SmbShareUserName",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; }
            },
            {
                name    => "SmbSharePasswd",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; }
            },

            ### Tar Settings
            {
                text    => "CfgEdit_Title_Tar_Settings",
                visible => sub { return $_[0]->{XferMethod} eq "tar"; }
            },
            {
                name    => "TarShareName",
                visible => sub { return $_[0]->{XferMethod} eq "tar"; }
            },

            ### Rsync Settings
            {
                text    => "CfgEdit_Title_Rsync_Settings",
                visible => sub { return $_[0]->{XferMethod} eq "rsync"; }
            },
            {
                text    => "CfgEdit_Title_Rsyncd_Settings",
                visible => sub { return $_[0]->{XferMethod} eq "rsyncd"; }
            },
            {
                name    => "RsyncShareName",
                visible => sub { return $_[0]->{XferMethod} =~ /rsync/; }
            },
            {
                name    => "RsyncdUserName",
                visible => sub { return $_[0]->{XferMethod} eq "rsyncd"; }
            },
            {
                name    => "RsyncdPasswd",
                visible => sub { return $_[0]->{XferMethod} eq "rsyncd"; }
            },

            ### Ftp Settings
            {
                text    => "CfgEdit_Title_Ftp_Settings",
                visible => sub { return $_[0]->{XferMethod} eq "ftp"; }
            },
            {
                name    => "FtpShareName",
                visible => sub { return $_[0]->{XferMethod} eq "ftp"; }
            },
            {
                name    => "FtpUserName",
                visible => sub { return $_[0]->{XferMethod} eq "ftp"; }
            },
            {
                name    => "FtpPasswd",
                visible => sub { return $_[0]->{XferMethod} eq "ftp"; }
            },
            {
                name    => "FtpPassive",
                visible => sub { return $_[0]->{XferMethod} eq "ftp"; }
            },
            {
                name    => "FtpBlockSize",
                visible => sub { return $_[0]->{XferMethod} eq "ftp"; }
            },
            {
                name    => "FtpPort",
                visible => sub { return $_[0]->{XferMethod} eq "ftp"; }
            },
            {
                name    => "FtpTimeout",
                visible => sub { return $_[0]->{XferMethod} eq "ftp"; }
            },
            {
                name    => "FtpFollowSymlinks",
                visible => sub { return $_[0]->{XferMethod} eq "ftp"; }
            },

            ### Archive Settings
            {
                text    => "CfgEdit_Title_Archive_Settings",
                visible => sub { return $_[0]->{XferMethod} eq "archive"; }
            },
            {
                name    => "ArchiveDest",
                visible => sub { return $_[0]->{XferMethod} eq "archive"; }
            },
            {
                name    => "ArchiveComp",
                visible => sub { return $_[0]->{XferMethod} eq "archive"; }
            },
            {
                name    => "ArchivePar",
                visible => sub { return $_[0]->{XferMethod} eq "archive"; }
            },
            {
                name    => "ArchiveSplit",
                visible => sub { return $_[0]->{XferMethod} eq "archive"; }
            },

            ### Include/Exclude Settings
            {
                text    => "CfgEdit_Title_Include_Exclude",
                visible => sub { return $_[0]->{XferMethod} ne "archive"; }
            },
            {
                name    => "BackupFilesOnly",
                visible => sub { return $_[0]->{XferMethod} ne "archive"; }
            },
            {
                name    => "BackupFilesExclude",
                visible => sub { return $_[0]->{XferMethod} ne "archive"; }
            },

            ### Samba paths and commands
            {
                text    => "CfgEdit_Title_Smb_Paths_Commands",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; }
            },
            {
                name    => "SmbClientPath",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; }
            },
            {
                name    => "SmbClientFullCmd",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; }
            },
            {
                name    => "SmbClientIncrCmd",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; }
            },
            {
                name    => "SmbClientRestoreCmd",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; }
            },

            ### Tar paths and commands
            {
                text    => "CfgEdit_Title_Tar_Paths_Commands",
                visible => sub { return $_[0]->{XferMethod} eq "tar"; }
            },
            {
                name    => "TarClientPath",
                visible => sub { return $_[0]->{XferMethod} eq "tar"; }
            },
            {
                name    => "TarClientCmd",
                visible => sub { return $_[0]->{XferMethod} eq "tar"; }
            },
            {
                name    => "TarFullArgs",
                visible => sub { return $_[0]->{XferMethod} eq "tar"; }
            },
            {
                name    => "TarIncrArgs",
                visible => sub { return $_[0]->{XferMethod} eq "tar"; }
            },
            {
                name    => "TarClientRestoreCmd",
                visible => sub { return $_[0]->{XferMethod} eq "tar"; }
            },

            ### Rsync paths and commands
            {
                text    => "CfgEdit_Title_Rsync_Paths_Commands_Args",
                visible => sub { return $_[0]->{XferMethod} eq "rsync"; }
            },
            {
                text    => "CfgEdit_Title_Rsyncd_Port_Args",
                visible => sub { return $_[0]->{XferMethod} eq "rsyncd"; }
            },
            {
                name    => "RsyncBackupPCPath",
                visible => sub { return $_[0]->{XferMethod} =~ /rsync/; }
            },
            {
                name    => "RsyncClientPath",
                visible => sub { return $_[0]->{XferMethod} eq "rsync"; }
            },
            {
                name    => "RsyncdSsh",
                visible => sub { return $_[0]->{XferMethod} eq "rsyncd"; }
            },
            {
                name    => "RsyncSshArgs",
                visible => sub {
                    return $_[0]->{XferMethod} eq "rsync"
                      || ($_[0]->{XferMethod} eq "rsyncd" && $_[0]->{RsyncdSsh});
                }
            },
            {
                name    => "RsyncdClientPort",
                visible => sub { return $_[0]->{XferMethod} eq "rsyncd"; }
            },
            {
                name    => "RsyncArgs",
                visible => sub { return $_[0]->{XferMethod} =~ /rsync/; }
            },
            {
                name    => "RsyncArgsExtra",
                visible => sub { return $_[0]->{XferMethod} =~ /rsync/; }
            },
            {
                name    => "RsyncFullArgsExtra",
                visible => sub { return $_[0]->{XferMethod} =~ /rsync/; }
            },
            {
                name    => "RsyncIncrArgsExtra",
                visible => sub { return $_[0]->{XferMethod} =~ /rsync/; }
            },
            {
                name    => "RsyncRestoreArgs",
                visible => sub { return $_[0]->{XferMethod} =~ /rsync/; }
            },
            {
                name    => "RsyncRestoreArgsExtra",
                visible => sub { return $_[0]->{XferMethod} =~ /rsync/; }
            },

            ### Archive paths and commands
            {
                text    => "CfgEdit_Title_Archive_Paths_Commands",
                visible => sub { return $_[0]->{XferMethod} eq "archive"; }
            },
            {
                name    => "ArchiveClientCmd",
                visible => sub { return $_[0]->{XferMethod} eq "archive"; }
            },

        ],
    },
    schedule => {
        text  => "CfgEdit_Title_Schedule",
        param => [
            {text => "CfgEdit_Title_Full_Backups"},
            {name => "FullPeriod"},
            {name => "FillCycle"},
            {name => "FullKeepCnt"},
            {name => "FullKeepCntMin"},
            {name => "FullAgeMax"},

            {text => "CfgEdit_Title_Incremental_Backups"},
            {name => "IncrPeriod"},
            {name => "IncrKeepCnt"},
            {name => "IncrKeepCntMin"},
            {name => "IncrAgeMax"},

            {text => "CfgEdit_Title_Blackouts"},
            {name => "BackupsDisable"},
            {name => "BlackoutBadPingLimit"},
            {name => "BlackoutGoodCnt"},
            {name => "BlackoutPeriods"},

            {text => "CfgEdit_Title_Other"},
            {name => "RestoreInfoKeepCnt"},
            {name => "ArchiveInfoKeepCnt"},
            {name => "BackupZeroFilesIsFatal"},
        ],
    },
    backup => {
        text  => "CfgEdit_Title_Backup_Settings",
        param => [
            {text => "CfgEdit_Title_Client_Lookup"},
            {name => "ClientNameAlias"},
            {name => "NmbLookupCmd"},
            {name => "NmbLookupFindHostCmd"},
            {name => "FixedIPNetBiosNameCheck"},
            {name => "PingCmd"},
            {name => "PingMaxMsec"},

            {text => "CfgEdit_Title_Other"},
            {name => "ClientComment"},
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
            {name => "UserCmdCheckStatus"},
        ],
    },
    hosts => {
        text  => "CfgEdit_Title_Hosts",
        param => [
            {text => "CfgEdit_Title_Hosts"},
            {
                name    => "Hosts",
                comment => "CfgEdit_Hosts_Comment"
            },
        ],
    },
);

sub action
{
    my $pc_dir = "$TopDir/pc";
    my($content, $contentHidden, $newConf, $override, $mainConf, $hostConf);
    my $errors = {};

    my $host       = $In{host};
    my $menu       = $In{menu} || "server";
    my $hosts_path = $Hosts;
    my $config_path =
      $host eq ""
      ? "$TopDir/conf/config.pl"
      : "$TopDir/pc/$host/config.pl";

    my $Privileged = CheckPermission($host)
      && ($PrivAdmin || $Conf{CgiUserConfigEditEnable});
    my $userHost = 1 if ( defined($host) );

    $debugText = "";

    if ( !$Privileged ) {
        ErrorExit(eval("qq{$Lang->{Only_privileged_users_can_edit_config_files}}"));
    }

    if ( defined($In{menu}) || $In{saveAction} eq "Save" ) {
        $errors = errorCheck();
        if ( %$errors ) {
            #
            # If there are errors, then go back to the same menu
            #
            $In{saveAction} = "";

            #$In{newMenu} = "";
        }
        if ( (my $var = $In{overrideUncheck}) ne "" ) {
            #
            # a compound variable was unchecked; delete or
            # add extra variables to make the shape the same.
            #
            #print STDERR Dumper(\%In);
            foreach my $v ( sort(keys(%In)) ) {
                if ( $v =~ /^v_((zZ_|flds_)\Q$var\E(_zZ_.*|$))/ ) {
                    delete($In{$v}) if ( !defined($In{"orig_$1"}) );
                }
                if ( $v =~ /^orig_((zZ_|flds_)\Q$var\E(_zZ_.*|$))/ ) {
                    $In{"v_$1"} = $In{$v};
                }
            }

            #delete($In{"v_flds_$var"});
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
            foreach my $param ( sort(keys(%$hostConf)) ) {
                $override->{$param} = 1;
            }
        } else {
            my $hostInfo = $bpc->HostInfoRead();
            $hostConf = {};
            $mainConf->{Hosts} = [map($hostInfo->{$_}, sort(keys(%$hostInfo)))];
        }
        $newConf = {%$mainConf, %$hostConf};
    }

    if ( $In{saveAction} ne "Save" && $In{newMenu} ne "" && defined($ConfigMenu{$In{newMenu}}) ) {
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
        foreach my $m ( sort(keys(%ConfigMenu)) ) {
            my $enabled = 0;
            my $text    = -1;
            my $n       = 0;
            my @mask    = ();

            foreach my $paramInfo ( @{$ConfigMenu{$m}{param}} ) {
                my $param = $paramInfo->{name};
                if ( defined($paramInfo->{text}) ) {
                    $mask[$n] = 1;
                    if ( ref($paramInfo->{visible}) ne "CODE" || &{$paramInfo->{visible}}($newConf, $bpc) ) {
                        $text = $n;
                    }
                } else {
                    if (
                        $bpc->{Conf}{CgiUserConfigEdit}{$param}
                        || (defined($bpc->{Conf}{CgiUserConfigEdit}{$param})
                            && $PrivAdmin)
                    ) {
                        $mask[$text] = 0 if ( $text >= 0 );
                        $mask[$n]    = 0;
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
    foreach my $m ( sort(keys(%ConfigMenu)) ) {
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

    my $saveStyle = "";
    my $saveColor = "#ff0000";

    if ( $In{modified} && $In{saveAction} ne "Save" && !%$errors ) {
        $saveStyle = "style=\"color:$saveColor\"";
    } else {
        $In{modified} = 0;
    }

    #
    # Add action and host to the URL so the nav bar link is
    # highlighted
    #
    my $url = "$MyURL?action=editConfig";
    $url     .= "&host=$host" if ( $host ne "" );
    $content .= <<EOF;
<table class="tbl-EditConfig-tabs tbl-tab-$menu" border="0" cellpadding="2">
<tr>$groupText</tr>
<tr>
<form method="post" name="editForm" action="$url">
<input type="hidden" name="host" value="$host">
<input type="hidden" name="menu" value="$menu">
<input type="hidden" name="newMenu" value="">
<input type="hidden" name="modified" value="$In{modified}">
<input type="hidden" name="deleteVar" value="">
<input type="hidden" name="insertVar" value="">
<input type="hidden" name="overrideUncheck" value="">
<input type="hidden" name="addVar" value="">
<input type="hidden" name="action" value="editConfig">
<input type="hidden" name="saveAction" value="">
<input type="button" class="editSaveButton" name="editAction"
    value="${EscHTML($Lang->{CfgEdit_Button_Save})}" $saveStyle
    onClick="saveSubmit();">
<p>

<script language="javascript" type="text/javascript">
<!--

    function saveSubmit()
    {
        if ( document.editForm.modified.value != 0 ) {
            document.editForm.saveAction.value = 'Save';
            document.editForm.submit();
        }
        return false;
    }

    function deleteSubmit(varName)
    {
        document.editForm.deleteVar.value = varName;
	document.editForm.modified.value = 1;
        document.editForm.submit();
        return;
    }

    function insertSubmit(varName)
    {
        document.editForm.insertVar.value = varName;
	document.editForm.modified.value = 1;
        document.editForm.submit();
        return;
    }

    function addSubmit(varName, checkKey)
    {
        if ( checkKey
            && eval("document.editForm.addVarKey_" + varName + ".value") == "" ) {
            alert("New key must be non-empty");
            return;
        }
        document.editForm.addVar.value = varName;
	document.editForm.modified.value = 1;
        document.editForm.submit();
        return;
    }

    function menuSubmit(menuName)
    {
        document.editForm.newMenu.value = menuName;
        document.editForm.submit();
    }

    function varChange(varName)
    {
	document.editForm.modified.value = 1;
        document.editForm.editAction.style.color = '$saveColor';
    }

    function checkboxChange(varName)
    {
	document.editForm.modified.value = 1;
        document.editForm.editAction.style.color = '$saveColor';
	// Do nothing if the checkbox is now set
        if ( eval("document.editForm.override_" + varName + ".checked") ) {
	    return false;
	}
	var allVars = {};
	var varRE  = new RegExp("^v_((zZ_|flds_)" + varName + ".*)");
	var origRE = new RegExp("^orig_((zZ_|flds_)" + varName + ".*)");
	var fldsRE = new RegExp("^flds_");
        for ( var i = 0 ; i < document.editForm.elements.length ; i++ ) {
	    var e = document.editForm.elements[i];
	    var re;
	    if ( (re = varRE.exec(e.name)) != null ) {
		if ( allVars[re[1]] == null ) {
		    allVars[re[1]] = 0;
		}
		allVars[re[1]]++;
		//debugMsg("found v_ match with " + re[1]);
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
                break;
            }
            if ( fldsRE.exec(v) != null ) {
                // always rebuild a compound variable
		sameShape = 0;
                break;
            }
        }
	if ( sameShape ) {
            for ( v in allVars ) {
                // copy the original variable values
		//debugMsg("setting " + v);
		eval("document.editForm.v_" + v + ".value = document.editForm.orig_" + v + ".value");
            }
	    return true;
	} else {
            // need to rebuild the form since the compound variable
            // has changed shape
            document.editForm.overrideUncheck.value = varName;
	    document.editForm.submit();
	    return false;
	}
    }

    function checkboxSet(varName)
    {
	document.editForm.modified.value = 1;
        document.editForm.editAction.style.color = '$saveColor';
        eval("document.editForm.override_" + varName + ".checked = 1;");
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
EOF

    $content .= <<EOF;
<table class="tbl-EditConfig-settings tbl-settings-$menu" border="1" cellpadding="0">
EOF

    my $doneParam = {};
    my $tblContent;

    #
    # There is a special case of the user deleting just the field
    # that has the error(s).  So if the delete variable is a match
    # or parent to all the errors then ignore the errors.
    #
    if ( $In{deleteVar} ne "" && %$errors > 0 ) {
        my $matchAll = 1;
        foreach my $v ( keys(%$errors) ) {
            if ( $v ne $In{deleteVar} && $v !~ /^\Q$In{deleteVar}_zZ_/ ) {
                $matchAll = 0;
                last;
            }
        }
        $errors = {} if ( $matchAll );
    }

    my $isError = %$errors;

    if ( !$isError && $In{saveAction} eq "Save" ) {
        my($mesg, $err);
        if ( $host ne "" ) {
            $hostConf = $bpc->ConfigDataRead($host) if ( !defined($hostConf) );
            my %hostConf2 = %$hostConf;
            foreach my $param ( sort(keys(%$newConf)) ) {
                if ( $override->{$param} ) {
                    $hostConf->{$param} = $newConf->{$param};
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
                next if ( $entry->{host} eq "" || defined($hostsNew->{lc($entry->{host})}) );
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
                $hostsNew->{lc($entry->{host})} = $entry;
            }
            ($mesg, my $hostChange) = hostsDiffMesg($hostsNew);
            $bpc->HostInfoWrite($hostsNew) if ( $hostChange );
            foreach my $host ( sort(keys(%$copyConf)) ) {
                #
                # Currently host names are forced to lc when they
                # are read from the hosts file.  Therefore we need
                # to force the from and to hosts to lc.
                #
                my $confData = $bpc->ConfigDataRead(lc($copyConf->{$host}));
                my $fromHost = $copyConf->{$host};
                $err  .= $bpc->ConfigDataWrite(lc($host), $confData);
                $mesg .= eval("qq($Lang->{CfgEdit_Log_Copy_host_config})");
            }

            delete($newConf->{Hosts});
            $mesg .= configDiffMesg(undef, $mainConf, $newConf);
            $mainConf = {%$mainConf, %$newConf};
            $err .= $bpc->ConfigDataWrite(undef, $mainConf);
            $newConf->{Hosts} = $hostsSave;
        }
        if ( defined($err) ) {
            $tblContent .= <<EOF;
<tr><td colspan="2" class="border"><span class="editError">$err</span></td></tr>
EOF
        }
        $bpc->ServerConnect();
        if ( $mesg ne "" ) {
            (my $mesgBR = $mesg) =~ s/\n/<br>\n/g;

            # uncomment this if you want the changes to be displayed
            #            $tblContent .= <<EOF;
            #<tr><td colspan="2" class="border"><span class="editComment">$mesgBR</span></td></tr>
            #EOF
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
        if ( ref($paramInfo->{visible}) eq "CODE" && !&{$paramInfo->{visible}}($newConf, $bpc) ) {
            next;
        }

        if ( defined($paramInfo->{text}) ) {
            my $text = eval("qq($Lang->{$paramInfo->{text}})");
            $tblContent .= <<EOF;
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

        $tblContent .= fieldEditBuild(
            $ConfigMeta{$param}, $param, $newConf->{$param}, $errors, 0, $comment, $isError,
            $paramInfo->{onchangeSubmit},
            defined($override) ? $param              : undef,
            defined($override) ? $override->{$param} : undef
        );
        if ( defined($paramInfo->{comment}) ) {
            my $topDir = $bpc->TopDir;
            my $text   = eval("qq($Lang->{$paramInfo->{comment}})");
            $tblContent .= <<EOF;
<tr><td colspan="2" class="editComment">$text</td></tr>
EOF
        }
    }

    #
    # Emit a summary of all the errors
    #
    my $errorTxt;

    if ( %$errors ) {
        $errorTxt .= <<EOF;
<tr><td colspan="2" class="border"><span class="editError">$Lang->{CfgEdit_Error_No_Save}</span></td></tr>
EOF
    }

    foreach my $param ( sort(keys(%$errors)) ) {
        $errorTxt .= <<EOF;
<tr><td colspan="2" class="border"><span class="editError">$errors->{$param}</span></td></tr>
EOF
    }

    $content .= <<EOF;
$errorTxt
$tblContent
</table>
<span id="debug"><pre>$debugText</pre></span>
EOF

    #
    # Emit all the remaining editable config settings as hidden values
    #
    foreach my $param ( sort(keys(%ConfigMeta)) ) {
        next if ( $doneParam->{$param} );
        next
          if (
            $userHost
            && (
                !defined($bpc->{Conf}{CgiUserConfigEdit}{$param})
                || (   !$PrivAdmin
                    && !$bpc->{Conf}{CgiUserConfigEdit}{$param})
            )
          );
        $content .= fieldHiddenBuild($ConfigMeta{$param}, $param, $newConf->{$param}, "v");
        if ( defined($override) ) {
            $content .= <<EOF;
<input type="hidden" name="override_$param" value="$override->{$param}">
EOF
        }
        $doneParam->{$param} = 1;
    }

    if ( defined($In{menu}) || $In{saveAction} eq "Save" ) {
        if ( $In{saveAction} eq "Save" && !$userHost ) {
            #
            # Emit the new settings as orig_zZ_ parameters
            #
            $doneParam = {};
            foreach my $param ( sort(keys(%ConfigMeta)) ) {
                next if ( $doneParam->{$param} );
                next
                  if (
                    $userHost
                    && (
                        !defined($bpc->{Conf}{CgiUserConfigEdit}{$param})
                        || (   !$PrivAdmin
                            && !$bpc->{Conf}{CgiUserConfigEdit}{$param})
                    )
                  );
                $contentHidden .= fieldHiddenBuild($ConfigMeta{$param}, $param, $newConf->{$param}, "orig");
                $doneParam->{$param} = 1;
                $In{modified} = 0;
            }
        } else {
            #
            # Just switching menus: copy all the orig_zZ_ input parameters
            #
            foreach my $var ( sort(keys(%In)) ) {
                if ( $var =~ /^orig_(zZ_|flds_)/ ) {
                    my $val = decode_utf8($In{$var});
                    $contentHidden .= <<EOF;
<input type="hidden" name="$var" value="${EscHTML($val)}">
EOF
                }
            }
        }
    } else {
        #
        # First time: emit all the original config settings
        #
        $doneParam = {};
        foreach my $param ( sort(keys(%ConfigMeta)) ) {
            next if ( $doneParam->{$param} );
            next
              if (
                $userHost
                && (
                    !defined($bpc->{Conf}{CgiUserConfigEdit}{$param})
                    || (   !$PrivAdmin
                        && !$bpc->{Conf}{CgiUserConfigEdit}{$param})
                )
              );
            $contentHidden .= fieldHiddenBuild($ConfigMeta{$param}, $param, $mainConf->{$param}, "orig");
            $doneParam->{$param} = 1;
        }
    }

    $content .= <<EOF;
$contentHidden
</form>
</tr>
</table>
EOF

    Header("EditConfig $menu", "Config Edit", $content);
    Trailer();
}

sub fieldHiddenBuild
{
    my($type, $varName, $varValue, $prefix) = @_;
    my $content;

    $type = {type => $type} if ( ref($type) ne "HASH" );

    if ( $type->{type} eq "list" ) {
        $varValue = []          if ( !defined($varValue) );
        $varValue = [$varValue] if ( ref($varValue) ne "ARRAY" );

        for ( my $i = 0 ; $i < @$varValue ; $i++ ) {
            $content .= fieldHiddenBuild($type->{child}, "${varName}_zZ_$i", $varValue->[$i], $prefix);
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

        for ( my $fldNum = 0 ; $fldNum < @order ; $fldNum++ ) {
            my $fld = $order[$fldNum];
            if ( defined($type->{child}) ) {
                $childType = $type->{child}{$fld};
            } else {
                $childType = $type->{childType};
                #
                # emit list of fields since they are user-defined
                # rather than hard-coded
                #
                $content .= <<EOF;
<input type="hidden" name="${prefix}_flds_${varName}_zZ_$fldNum" value="${EscHTML($fld)}">
EOF
            }
            $content .= fieldHiddenBuild($childType, "${varName}_zZ_$fldNum", $varValue->{$fld}, $prefix);
        }
    } elsif ( $type->{type} eq "shortlist" ) {
        $varValue = [$varValue] if ( ref($varValue) ne "ARRAY" );
        $varValue = join(", ", @$varValue);
        $content .= <<EOF;
<input type="hidden" name="${prefix}_zZ_$varName" value="${EscHTML($varValue)}">
EOF
    } else {
        $content .= <<EOF;
<input type="hidden" name="${prefix}_zZ_$varName" value="${EscHTML($varValue)}">
EOF
    }
    return $content;
}

sub fieldEditBuild
{
    my($type, $varName, $varValue, $errors, $level, $comment, $isError, $onchangeSubmit, $overrideVar, $overrideSet) =
      @_;

    my $content;
    my $size = 50 - 10 * $level;
    $type = {type => $type} if ( ref($type) ne "HASH" );

    $size = $type->{size} if ( defined($type->{size}) );

    #
    # These fragments allow inline content to be turned on and off
    #
    # <tr><td colspan="2"><span id="id_$varName" style="display: none" class="editComment">$comment</span></td></tr>
    # <tr><td class="border"><a href="javascript: displayHelp('$varName')">$varName</a>
    #

    if ( $level == 0 ) {
        my $lcVarName = lc($varName);
        $content .= <<EOF;
<tr><td class="border"><a href="?action=view&type=docs#_conf_${lcVarName}_">$varName</a>
EOF
        if ( defined($overrideVar) ) {
            my $override_checked = "";
            if (   !$isError && $In{deleteVar} =~ /^\Q${varName}_zZ_/
                || !$isError && $In{insertVar} =~ /^\Q${varName}\E(_zZ_|$)/
                || !$isError && $In{addVar}    =~ /^\Q${varName}\E(_zZ_|$)/ ) {
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

    (my $varClass = $varName) =~ s/_zZ_.+//;
    my $permitListAdd = 1;
    if ( $type->{type} eq "list" ) {
        $content .= "<td class=\"border\">\n";
        $varValue = []          if ( !defined($varValue) );
        $varValue = [$varValue] if ( ref($varValue) ne "ARRAY" );
        if ( !$isError && $In{deleteVar} =~ /^\Q${varName}_zZ_\E(\d+)$/ && $1 < @$varValue ) {
            #
            # User deleted entry in this array
            #
            splice(@$varValue, $1, 1) if ( @$varValue > 1 || $type->{emptyOk} );
            $In{deleteVar} = "";
        }
        if ( !$isError && $In{insertVar} =~ /^\Q${varName}_zZ_\E(\d+)$/ && $1 < @$varValue ) {
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
        $content .= "<table border=\"1\" cellspacing=\"0\" class=\"editSubTable editSubTable-$varClass\">\n";
        my $colspan;

        if ( ref($type) eq "HASH" && ref($type->{child}) eq "HASH" && $type->{child}{type} eq "horizHash" ) {
            my @order;
            if ( defined($type->{child}{order}) ) {
                @order = @{$type->{child}{order}};
            } else {
                @order = sort(keys(%{$type->{child}{child}}));
            }
            $content .= "<tr><td class=\"border\"></td>\n";
            for ( my $i = 0 ; $i < @order ; $i++ ) {
                $content .= "<td class=\"tableheader\">$order[$i]</td>\n";
            }
            $colspan = @order + 1;
            $content .= "</tr>\n";
            for ( my $i = 0 ; $i < @$varValue ; $i++ ) {
                if ( @$varValue > 1 || $type->{emptyOk} ) {
                    $content .= <<EOF;
<tr><td class="border hasButtons">
<input type="button" name="del_${varName}_zZ_$i" value="${EscHTML($Lang->{CfgEdit_Button_Delete})}"
    onClick="deleteSubmit('${varName}_zZ_$i')">
</td>
EOF
                }
                $content .= fieldEditBuild(
                    $type->{child}, "${varName}_zZ_$i", $varValue->[$i], $errors,
                    $level + 1,     undef,              $isError,        $onchangeSubmit,
                    $overrideVar,   $overrideSet
                );
                $content .= "</tr>\n";
            }
        } else {
            my $insertValue = ${EscHTML($Lang->{CfgEdit_Button_Insert})};
            my $deleteValue = ${EscHTML($Lang->{CfgEdit_Button_Delete})};
            for ( my $i = 0 ; $i < @$varValue ; $i++ ) {
                # 2025.10.16: Disable 'Insert' and 'Add' buttons if the permitted maximum
                # number of elements is reached. Fixes Github issue #509.  == GWH ==
                my $insertSubmit = "insertSubmit('${varName}_zZ_$i')";
                # One day we may also for some reason want to prevent 'Delete' for
                # certain elements( such as the first element of RsyncSshArgs).
                my $deleteSubmit = "deleteSubmit('${varName}_zZ_$i')";
                if ( $type->{maxElements} && (@$varValue >= $type->{maxElements}) ) {
                    $permitListAdd = 0;
                    $insertSubmit = "void(0)";
                    $insertValue = "             ";
                }
                $content .= <<EOF;
<tr><td class="border hasButtons">
<input type="button" name="ins_${varName}_zZ_$i" value="$insertValue" onClick="$insertSubmit">
EOF
                if ( @$varValue > 1 || $type->{emptyOk} ) {
                    $content .= <<EOF;
<input type="button" name="del_${varName}_zZ_$i" value="$deleteValue" onClick="$deleteSubmit">
EOF
                }
                $content .= "</td>\n";
                $content .= fieldEditBuild(
                    $type->{child}, "${varName}_zZ_$i", $varValue->[$i], $errors,
                    $level + 1,     undef,              $isError,        $onchangeSubmit,
                    $overrideVar,   $overrideSet
                );
                $content .= "</tr>\n";
            }
            $colspan = 2;
        }
        if( $permitListAdd )
        {
            $content .= <<EOF;
<tr><td class="border hasButtons" colspan="$colspan"><input type="button" name="add_$varName" value="${EscHTML($Lang->{CfgEdit_Button_Add})}" onClick="addSubmit('$varName')"></td></tr>
EOF
        }
        $content .= "</table></td>\n";
    } elsif ( $type->{type} eq "hash" ) {
        $content .= "<td class=\"border\">\n";
        $content .= "<table border=\"1\" cellspacing=\"0\" class=\"editSubTable editSubTable-$varClass\">\n";
        $varValue = {} if ( ref($varValue) ne "HASH" );

        if (   !$isError
            && !$type->{noKeyEdit}
            && $In{deleteVar} !~ /^\Q${varName}_zZ_\E.*_zZ_/
            && $In{deleteVar} =~ /^\Q${varName}_zZ_\E(.*)$/ ) {
            #
            # User deleted entry in this hash
            #
            delete($varValue->{$1}) if ( keys(%$varValue) > 1 || $type->{emptyOk} );
            $In{deleteVar} = "";
        }
        if ( !$isError && !defined($type->{child}) && $In{addVar} eq $varName ) {
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

        for ( my $fldNum = 0 ; $fldNum < @order ; $fldNum++ ) {
            my $fld = $order[$fldNum];
            $content .= <<EOF;
<tr><td class="border hasButtons">$fld
EOF
            if ( !$type->{noKeyEdit}
                && (keys(%$varValue) > 1 || $type->{emptyOk}) ) {
                $content .= <<EOF;
<input type="button" name="del_${varName}_zZ_$fld" value="${EscHTML($Lang->{CfgEdit_Button_Delete})}"
        onClick="deleteSubmit('${varName}_zZ_$fld')">
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
<input type="hidden" name="v_flds_${varName}_zZ_$fldNum" value="${EscHTML($fld)}">
EOF
            }
            $content .= "</td>\n";
            $content .= fieldEditBuild(
                $childType,   "${varName}_zZ_$fldNum", $varValue->{$fld}, $errors,
                $level + 1,   undef,                   $isError,          $onchangeSubmit,
                $overrideVar, $overrideSet
            );
            $content .= "</tr>\n";
        }

        if ( !$type->{noKeyEdit} ) {
            my $keyText = defined($type->{keyText}) ? $Lang->{$type->{keyText}} : $Lang->{CfgEdit_Button_New_Key};
            $content .= <<EOF;
<tr><td class="border hasButtons" colspan="2">
$keyText: <input type="text" class="editTextInput" name="addVarKey_$varName" size="20" maxlength="256" value="">
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

        for ( my $fldNum = 0 ; $fldNum < @order ; $fldNum++ ) {
            my $fld = $order[$fldNum];
            if ( defined($type->{child}) ) {
                $childType = $type->{child}{$fld};
            } else {
                $childType = $type->{childType};
                #
                # emit list of fields since they are user-defined
                # rather than hard-coded
                #
                $content .= <<EOF;
<input type="hidden" name="v_flds_${varName}_zZ_$fldNum" value="${EscHTML($fld)}">
EOF
            }
            $content .= fieldEditBuild(
                $childType,   "${varName}_zZ_$fldNum", $varValue->{$fld}, $errors,
                $level + 1,   undef,                   $isError,          $onchangeSubmit,
                $overrideVar, $overrideSet
            );
        }
    } else {
        $content .= "<td class=\"border\">\n";
        if ( $isError ) {
            #
            # If there was an error, we use the original post values
            # in %In, rather than the parsed values in $varValue.
            # This is so that the user's erroneous input is preserved.
            #
            $varValue = $In{"v_zZ_$varName"} if ( defined($In{"v_zZ_$varName"}) );
        }
        if ( defined($errors->{$varName}) ) {
            $content .= <<EOF;
<span class="editError">$errors->{$varName}</span><br>
EOF
        }
        my $onChange;
        if ( defined($overrideVar) ) {
            $onChange .= "checkboxSet('$overrideVar');";
        } else {
            $onChange .= "varChange('$varName');";
        }
        if ( $onchangeSubmit ) {
            $onChange .= "document.editForm.submit();";
        }
        if ( $onChange ne "" ) {
            $onChange = " onChange=\"$onChange\"";
        }
        if (
            $varValue !~ /\n/
            && (   $type->{type} eq "integer"
                || $type->{type} eq "string"
                || $type->{type} eq "execPath"
                || $type->{type} eq "shortlist"
                || $type->{type} eq "float")
        ) {
            # simple input box
            if ( $type->{type} eq "shortlist" ) {
                $varValue = [$varValue] if ( ref($varValue) ne "ARRAY" );
                $varValue = join(", ", @$varValue);
            }
            my $textType = ($varName =~ /Passwd/) ? "password" : "text";
            $content .= <<EOF;
<input type="$textType" class="editTextInput" name="v_zZ_$varName" size="$size" maxlength="4096" value="${EscHTML($varValue)}"$onChange>
EOF
        } elsif ( $type->{type} eq "boolean" ) {

            # checkbox
            my $checked = "checked" if ( $varValue );
            $content .= <<EOF;
<input type="checkbox" name="v_zZ_$varName" $checked value="1"$onChange>
EOF
        } elsif ( $type->{type} eq "select" ) {
            $content .= <<EOF;
<select name="v_zZ_$varName"$onChange>
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
<textarea name="v_zZ_$varName" class="editTextArea" cols="$size" rows="$rowCnt"$onChange>${EscHTML($varValue)}</textarea>
EOF
        }
        $content .= "</td>\n";
    }
    return $content;
}

sub errorCheck
{
    my $errors = {};

    foreach my $param ( sort(keys(%ConfigMeta)) ) {
        fieldErrorCheck($ConfigMeta{$param}, $param, $errors);
    }
    return $errors;
}

sub fieldErrorCheck
{
    my($type, $varName, $errors) = @_;

    $type = {type => $type} if ( ref($type) ne "HASH" );

    if ( $type->{type} eq "list" ) {
        for ( my $i = 0 ; ; $i++ ) {
            last if ( fieldErrorCheck($type->{child}, "${varName}_zZ_$i", $errors) );
        }
    } elsif ( $type->{type} eq "hash" || $type->{type} eq "horizHash" ) {
        my(@order, $childType);
        my $ret;

        if ( defined($type->{order}) ) {
            @order = @{$type->{order}};
        } elsif ( defined($type->{child}) ) {
            @order = sort(keys(%{$type->{child}}));
        } else {
            for ( my $fldNum = 0 ; ; $fldNum++ ) {
                last if ( !defined($In{"v_flds_${varName}_zZ_$fldNum"}) );
                push(@order, $In{"v_flds_${varName}_zZ_$fldNum"});
            }
        }
        for ( my $fldNum = 0 ; $fldNum < @order ; $fldNum++ ) {
            my $fld = $order[$fldNum];
            if ( defined($type->{child}) ) {
                $childType = $type->{child}{$fld};
            } else {
                $childType = $type->{childType};
            }
            $ret ||= fieldErrorCheck($childType, "${varName}_zZ_$fldNum", $errors);
        }
        return $ret;
    } else {
        $In{"v_zZ_$varName"} = "0" if ( $type->{type} eq "boolean" && $In{"v_zZ_$varName"} eq "" );

        return 1 if ( !exists($In{"v_zZ_$varName"}) );

        (my $var = $varName) =~ s/_zZ_/./g;

        if ( $type->{type} eq "integer" || $type->{type} eq "boolean" ) {
            if ( $In{"v_zZ_$varName"} !~ /^-?\d+\s*$/s && $In{"v_zZ_$varName"} ne "" ) {
                $errors->{$varName} = eval("qq{$Lang->{CfgEdit_Error__must_be_an_integer}}");
            }
        } elsif ( $type->{type} eq "float" ) {
            if ( $In{"v_zZ_$varName"} !~ /^-?\d*(\.\d*)?\s*$/s && $In{"v_zZ_$varName"} ne "" ) {
                $errors->{$varName} = eval("qq{$Lang->{CfgEdit_Error__must_be_real_valued_number}}");
            }
        } elsif ( $type->{type} eq "shortlist" ) {
            my @vals = split(/[,\s]+/, $In{"v_zZ_$varName"});
            for ( my $i = 0 ; $i < @vals ; $i++ ) {
                if ( $type->{child} eq "integer" && $vals[$i] !~ /^-?\d+\s*$/s && $vals[$i] ne "" ) {
                    my $k = $i + 1;
                    $errors->{$varName} = eval("qq{$Lang->{CfgEdit_Error__entry__must_be_an_integer}}");
                } elsif ( $type->{child} eq "float" && $vals[$i] !~ /^-?\d*(\.\d*)?\s*$/s && $vals[$i] ne "" ) {
                    my $k = $i + 1;
                    $errors->{$varName} = eval("qq{$Lang->{CfgEdit_Error__entry__must_be_real_valued_number}}");
                }
            }
        } elsif ( $type->{type} eq "select" ) {
            my $match = 0;
            foreach my $option ( @{$type->{values}} ) {
                if ( $In{"v_zZ_$varName"} eq $option ) {
                    $match = 1;
                    last;
                }
            }
            $errors->{$varName} = eval("qq{$Lang->{CfgEdit_Error__must_be_valid_option}}")
              if ( !$match );
        } elsif ( $type->{type} eq "execPath" ) {
            if ( $In{"v_zZ_$varName"} ne "" && !-x $In{"v_zZ_$varName"} ) {
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

    foreach my $param ( sort(keys(%ConfigMeta)) ) {
        my $value;
        next
          if (
            $userHost
            && (
                !defined($bpc->{Conf}{CgiUserConfigEdit}{$param})
                || (   !$PrivAdmin
                    && !$bpc->{Conf}{CgiUserConfigEdit}{$param})
            )
          );
        fieldInputParse($ConfigMeta{$param}, $param, \$value);
        $conf->{$param}     = $value;
        $override->{$param} = $In{"override_$param"};
    }
    return ($conf, $override);
}

sub fieldInputParse
{
    my($type, $varName, $value) = @_;

    $type = {type => $type} if ( ref($type) ne "HASH" );

    if ( $type->{type} eq "list" ) {
        $$value = [];
        for ( my $i = 0 ; ; $i++ ) {
            my $val;
            last if ( fieldInputParse($type->{child}, "${varName}_zZ_$i", \$val) );
            # 2025.10.16: Prevent adding elements if it would exceed a (possibly undefined) limit.
            # If maxElements is undefined (or the limit is set to 0) then no limit is effected.
            # Not strictly necessary if the buttons have been diabled as above. == GWH ==
            if ( !$type->{maxElements} or ($i < $type->{maxElements}) )
            {
                print( STDERR "EditConfig.pm: Pushing value [$val] to [$varName] array\n" );
                push(@$$value, $val);
            }
            else
            {
                print( STDERR "EditConfig.pm: Refusing to push element index [$i] to [$varName] array\n" );
            }
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
            for ( my $fldNum = 0 ; ; $fldNum++ ) {
                last if ( !defined($In{"v_flds_${varName}_zZ_$fldNum"}) );
                push(@order, $In{"v_flds_${varName}_zZ_$fldNum"});
            }
        }

        for ( my $fldNum = 0 ; $fldNum < @order ; $fldNum++ ) {
            my $fld = $order[$fldNum];
            my $val;
            if ( defined($type->{child}) ) {
                $childType = $type->{child}{$fld};
            } else {
                $childType = $type->{childType};
            }
            $ret ||= fieldInputParse($childType, "${varName}_zZ_$fldNum", \$val);
            last if ( $ret );
            $$value->{$fld} = $val;
        }
        return $ret;
    } else {
        if ( $type->{type} eq "boolean" ) {
            $$value = 0 + $In{"v_zZ_$varName"};
        } elsif ( !exists($In{"v_zZ_$varName"}) ) {
            return 1;
        }

        my $v = $In{"v_zZ_$varName"};

        if ( $type->{type} eq "integer" ) {
            if ( $v =~ /^-?\d+\s*$/s || $v eq "" ) {
                $$value = 0 + $v;
            } else {

                # error value - keep in string form
                $$value = $v;
            }
        } elsif ( $type->{type} eq "float" ) {
            if ( $v =~ /^-?\d*(\.\d*)?\s*$/s || $v eq "" ) {
                $$value = 0 + $v;
            } else {

                # error value - keep in string form
                $$value = $v;
            }
        } elsif ( $type->{type} eq "shortlist" ) {
            $$value = [split(/[,\s]+/, $v)];
            if ( $type->{child} eq "float" ) {
                foreach ( @$$value ) {
                    if ( /^-?\d*(\.\d*)?\s*$/s || $v eq "" ) {
                        $_ += 0;
                    }
                }
            } elsif ( $type->{child} eq "integer" || $type->{child} eq "boolean" ) {
                foreach ( @$$value ) {
                    if ( /^-?\d+\s*$/s || $v eq "" ) {
                        $_ += 0;
                    }
                }
            }
        } else {
            $$value = decode_utf8($In{"v_zZ_$varName"});
            $$value =~ s/\r\n/\n/g;

            # remove leading space from exec paths
            $$value =~ s/^\s+// if ( $type->{type} eq "execPath" );
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

    foreach my $p ( sort(keys(%ConfigMeta)) ) {
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
            if ( $p =~ /Passwd/ || $p =~ /Secret/ ) {
                $value = "'*'";
            }

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

            next if ( $valueOld2 eq $valueNew2 );

            $valueNew =~ s/\n/\\n/g;
            $valueOld =~ s/\n/\\n/g;
            $valueNew =~ s/\r/\\r/g;
            $valueOld =~ s/\r/\\r/g;
            if ( $p =~ /Passwd/ || $p =~ /Secret/ ) {
                $valueNew = "'*'";
                $valueOld = "'*'";
            }

            $mesg .= eval("qq($Lang->{CfgEdit_Log_Change_param_value})");
        }
    }
    return $mesg;
}

sub hostsDiffMesg
{
    my($hostsNew) = @_;
    my $hostsOld = $bpc->HostInfoRead();
    my($mesg, $hostChange);

    foreach my $host ( sort(keys(%$hostsOld)) ) {
        if ( !defined($hostsNew->{$host}) ) {
            $mesg .= eval("qq($Lang->{CfgEdit_Log_Host_Delete})");
            $hostChange++;
            next;
        }
        foreach my $key ( sort(keys(%{$hostsNew->{$host}})) ) {
            next if ( $hostsNew->{$host}{$key} eq $hostsOld->{$host}{$key} );
            my $valueOld = $hostsOld->{$host}{$key};
            my $valueNew = $hostsNew->{$host}{$key};
            $mesg .= eval("qq($Lang->{CfgEdit_Log_Host_Change})");
            $hostChange++;
        }
    }

    foreach my $host ( sort(keys(%$hostsNew)) ) {
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
