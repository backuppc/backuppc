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
# Version 2.1.0beta2pl1, released 30 May 2004.
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
        text  => "Server",
        param => [
            {text => "General Parameters"},
            {name => "ServerHost"},
            {name => "BackupPCUser"},
            {name => "BackupPCUserVerify"},
            {name => "MaxOldLogFiles"},
            {name => "TrashCleanSleepSec"},

            {text => "Wakeup Schedule"},
            {name => "WakeupSchedule"},

            {text => "Concurrent Jobs"},
            {name => "MaxBackups"},
            {name => "MaxUserBackups"},
            {name => "MaxPendingCmds"},
            {name => "MaxBackupPCNightlyJobs"},
            {name => "BackupPCNightlyPeriod"},

            {text => "Pool Filesystem Limits"},
	    {name => "DfCmd"},
	    {name => "DfMaxUsagePct"},
	    {name => "HardLinkMax"},

            {text => "Other Parameters"},
	    {name => "UmaskMode"},
	    {name => "MyPath"},
            {name => "DHCPAddressRanges"},
            {name => "PerlModuleLoad"},
            {name => "ServerInitdPath"},
            {name => "ServerInitdStartCmd"},

            {text => "Remote Apache Settings"},
            {name => "ServerPort"},
            {name => "ServerMesgSecret"},

            {text => "Program Paths"},
	    {name => "SshPath"},
	    {name => "NmbLookupPath"},
	    {name => "PingPath"},
	    {name => "DfPath"},
	    {name => "SplitPath"},
	    {name => "ParPath"},
	    {name => "CatPath"},
	    {name => "GzipPath"},
	    {name => "Bzip2Path"},

            {text => "Install Paths"},
	    {name => "CgiDir"},
	    {name => "InstallDir"},
        ],
    },
    email => {
        text  => "Email",
        param => [
            {text => "Email settings"},
            {name => "SendmailPath"},
            {name => "EMailNotifyMinDays"},
            {name => "EMailFromUserName"},
            {name => "EMailAdminUserName"},
            {name => "EMailUserDestDomain"},

            {text => "Email User Messages"},
	    {name => "EMailNoBackupEverSubj"},
	    {name => "EMailNoBackupEverMesg"},
	    {name => "EMailNotifyOldBackupDays"},
	    {name => "EMailNoBackupRecentSubj"},
	    {name => "EMailNoBackupRecentMesg"},
	    {name => "EMailNotifyOldOutlookDays"},
	    {name => "EMailOutlookBackupSubj"},
	    {name => "EMailOutlookBackupMesg"},
        ],
    },
    cgi => {
        text => "CGI",
        param => [
	    {text => "Admin Privileges"},
	    {name => "CgiAdminUserGroup"},
	    {name => "CgiAdminUsers"},

	    {text => "Config Editing"},
	    {name => "CgiUserConfigEdit"},

	    {text => "Page Rendering"},
	    {name => "Language"},
	    {name => "CgiNavBarAdminAllHosts"},
	    {name => "CgiSearchBoxEnable"},
	    {name => "CgiNavBarLinks"},
	    {name => "CgiStatusHilightColor"},
	    {name => "CgiDateFormatMMDD"},
	    {name => "CgiHeaders"},
	    {name => "CgiExt2ContentType"},
	    {name => "CgiCSSFile"},

	    {text => "Paths"},
	    {name => "CgiURL"},
	    {name => "CgiImageDir"},
	    {name => "CgiImageDirURL"},

	    {text => "User URLs"},
	    {name => "CgiUserHomePageCheck"},
	    {name => "CgiUserUrlCreate"},

        ],
    },
    xfer => {
        text => "Xfer",
        param => [
            {text => "Xfer Settings"},
            {name => "XferMethod", onchangeSubmit => 1},
            {name => "XferLogLevel"},

            {text => "Smb Settings",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; } },
            {name => "SmbShareName",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; } },
            {name => "SmbShareUserName",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; } },
            {name => "SmbSharePasswd",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; } },

            {text => "Tar Settings",
                visible => sub { return $_[0]->{XferMethod} eq "tar"; } },
            {name => "TarShareName",
                visible => sub { return $_[0]->{XferMethod} eq "tar"; } },

            {text => "Rsync Settings",
                visible => sub { return $_[0]->{XferMethod} eq "rsync"; } },
            {text => "Rsyncd Settings",
                visible => sub { return $_[0]->{XferMethod} eq "rsyncd"; } },
            {name => "RsyncShareName",
                visible => sub { return $_[0]->{XferMethod} =~ /rsync/; } },
            {name => "RsyncdPasswd",
                visible => sub { return $_[0]->{XferMethod} eq "rsyncd"; } },
            {name => "RsyncdAuthRequired",
                visible => sub { return $_[0]->{XferMethod} eq "rsyncd"; } },
            {name => "RsyncCsumCacheVerifyProb",
                visible => sub { return $_[0]->{XferMethod} =~ /rsync/; } },

            {text => "Archive Settings",
                visible => sub { return $_[0]->{XferMethod} eq "archive"; } },
            {name => "ArchiveDest",
                visible => sub { return $_[0]->{XferMethod} eq "archive"; } },
            {name => "ArchiveComp",
                visible => sub { return $_[0]->{XferMethod} eq "archive"; } },
            {name => "ArchivePar",
                visible => sub { return $_[0]->{XferMethod} eq "archive"; } },
            {name => "ArchiveSplit",
                visible => sub { return $_[0]->{XferMethod} eq "archive"; } },

            {text => "Include/Exclude",
                visible => sub { return $_[0]->{XferMethod} ne "archive"; } },
            {name => "BackupFilesOnly",
                visible => sub { return $_[0]->{XferMethod} ne "archive"; } },
            {name => "BackupFilesExclude",
                visible => sub { return $_[0]->{XferMethod} ne "archive"; } },

            {text => "Smb Paths/Commands",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; } },
            {name => "SmbClientPath",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; } },
            {name => "SmbClientFullCmd",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; } },
            {name => "SmbClientIncrCmd",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; } },
            {name => "SmbClientRestoreCmd",
                visible => sub { return $_[0]->{XferMethod} eq "smb"; } },

            {text => "Tar Paths/Commands",
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

            {text => "Rsync Paths/Commands/Args",
                visible => sub { return $_[0]->{XferMethod} eq "rsync"; } },
            {text => "Rsyncd Port/Args",
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

            {text => "Archive Paths/Commands",
                visible => sub { return $_[0]->{XferMethod} eq "archive"; } },
            {name => "ArchiveClientCmd",
                visible => sub { return $_[0]->{XferMethod} eq "archive"; } },

        ],
    },
    schedule => {
        text => "Schedule",
        param => [
	    {text => "Full Backups"},
	    {name => "FullPeriod"},
	    {name => "FullKeepCnt"},
	    {name => "FullKeepCntMin"},
	    {name => "FullAgeMax"},

	    {text => "Incremental Backups"},
	    {name => "IncrPeriod"},
	    {name => "IncrKeepCnt"},
	    {name => "IncrKeepCntMin"},
	    {name => "IncrAgeMax"},
	    {name => "IncrFill"},

	    {text => "Blackouts"},
            {name => "BlackoutBadPingLimit"},
            {name => "BlackoutGoodCnt"},
            {name => "BlackoutPeriods"},

	    {text => "Other"},
	    {name => "PartialAgeMax"},
	    {name => "RestoreInfoKeepCnt"},
	    {name => "ArchiveInfoKeepCnt"},
	    {name => "BackupZeroFilesIsFatal"},
	],
    },
    backup => {
        text => "Backup Settings",
        param => [
	    {text => "Client Lookup"},
	    {name => "ClientNameAlias"},
	    {name => "NmbLookupCmd"},
	    {name => "NmbLookupFindHostCmd"},
	    {name => "FixedIPNetBiosNameCheck"},
	    {name => "PingCmd"},
	    {name => "PingMaxMsec"},
	    
	    {text => "Other"},
	    {name => "ClientTimeout"},
	    {name => "MaxOldPerPCLogFiles"},
	    {name => "CompressLevel"},

	    {text => "User Commands"},
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

    my $Privileged = CheckPermission();
    my $userHost = 1 if ( $Privileged && !$PrivAdmin && defined($host) );

    if ( !$Privileged ) {
        #ErrorExit(eval("qq{$Lang->{Only_privileged_users_can_edit_config_files}}"));
        ErrorExit("Only_privileged_users_can_edit_config_files");
    }

    if ( defined($In{menu}) || $In{editAction} eq "Save" ) {
	$errors = errorCheck();
	if ( %$errors ) {
	    #
	    # If there are errors, then go back to the same menu
	    #
	    $In{editAction} = "";
            $In{newMenu} = "";
	}
        ($newConf, $override) = inputParse($bpc, $userHost);
	$override = undef if ( $host eq "" );

	#
	# Copy all the orig_ input parameters
	#
	foreach my $var ( keys(%In) ) {
	    next if ( $var !~ /^orig_/ );
	    $contentHidden .= <<EOF;
<input type="hidden" name="$var" value="${EscHTML($In{$var})}">
EOF
	}
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
	    $hostConf = {};
	}
	$newConf = { %$mainConf, %$hostConf };

	#
	# Emit all the original config settings
	#
	my $doneParam = {};
        foreach my $param ( keys(%ConfigMeta) ) {
            next if ( $doneParam->{$param} );
            next if ( $userHost && !$bpc->{Conf}{CgiUserConfigEdit}{$param} );
            $contentHidden .= fieldHiddenBuild($ConfigMeta{$param},
                                    $param,
                                    $mainConf->{$param},
                                    "orig",
                                );
            $doneParam->{$param} = 1;
	}

    }

    if ( $In{editAction} ne "Save" && $In{newMenu} ne ""
		    && defined($ConfigMenu{$In{newMenu}}) ) {
        $menu = $In{newMenu};
    }

    my %menuDisable;
    if ( $userHost ) {
        #
        # For a non-admin user editing the host config, we need to
        # figure out which subsets of the menu tree will be visible,
        # based on what is enabled
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
                    if ( $bpc->{Conf}{CgiUserConfigEdit}{$param} ) {
                        $mask[$text] = 0 if ( $text >= 0 );
                        $mask[$n] = 0;
                        $enabled = 1;
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
	my $text = $ConfigMenu{$m}{text};
        if ( $m eq $menu ) {
            $groupText .= <<EOF;
<td bgcolor="grey"><a href="javascript:menuSubmit('$m')"><b>$text</b></a></td>
EOF
        } else {
            $groupText .= <<EOF;
<td><a href="javascript:menuSubmit('$m')">$text</a></td>
EOF
        }
    }

    if ( $host eq "" ) {
	$content .= <<EOF;
${h1("Main Configuration Editor")}
EOF
    } else {
	$content .= <<EOF;
${h1("Host $host Configuration Editor")}
<p>
Note: Check Override if you want to modify a value specific to this host.
EOF
    }

    my $saveDisplay = "block";
    $saveDisplay = "none" if ( !$In{modified} );
    $content .= <<EOF;
<table border="0" cellpadding="2">
<tr>$groupText</tr>
<tr>
<form method="post" name="form1" action="$MyURL">
<input type="hidden" name="host" value="$host">
<input type="hidden" name="menu" value="$menu">
<input type="hidden" name="newMenu" value="">
<input type="hidden" name="modified" value="$In{modified}">
<input type="hidden" name="deleteVar" value="">
<input type="hidden" name="insertVar" value="">
<input type="hidden" name="addVar" value="">
<input type="hidden" name="action" value="editConfig">
<input type="submit" style="display: $saveDisplay" name="editAction" value="Save">
$contentHidden

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
        if ( checkKey && document.form1.addVarKey.value == "" ) {
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
	var varRE  = new RegExp("^v_(" + varName + ".*)");
	var origRE = new RegExp("^orig_(" + varName + ".*)");
        for ( var i = 0 ; i < document.form1.elements.length ; i++ ) {
	    var e = document.form1.elements[i];
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
	    }
	}
	if ( sameShape ) {
	    for ( v in allVars ) {
		//debugMsg("setting " + v);
		eval("document.form1.v_" + v + ".value = document.form1.orig_" + v + ".value");
	    }
	    return true;
	} else {
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

<span id="debug"></span>

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
            if ( $v ne $In{deleteVar} && $v !~ /^\Q$In{deleteVar}_/ ) {
                $matchAll = 0;
                last;
            }
        }
        $errors = {} if ( $matchAll );
    }

    my $isError = %$errors;

    if ( !$isError && $In{editAction} eq "Save" ) {
        my $mesg;
	if ( $host ne "" ) {
	    $hostConf = $bpc->ConfigDataRead($host) if ( !defined($hostConf) );
            $mesg = configDiffMesg($host, $hostConf, $newConf);
	    foreach my $param ( %$newConf ) {
		$hostConf->{$param} = $newConf->{$param}
				if ( $override->{param} );
	    }
	    $bpc->ConfigDataWrite($host, $hostConf);
	} else {
	    $mainConf = $bpc->ConfigDataRead() if ( !defined($mainConf) );
            $mesg = configDiffMesg(undef, $mainConf, $newConf);
	    $mainConf = { %$mainConf, %$newConf };
	    $bpc->ConfigDataWrite(undef, $mainConf);
	}
        if ( $mesg ne "" ) {
            $bpc->ServerConnect();
            foreach my $str ( split(/\n/, $mesg) ) {
                $bpc->ServerMesg($str);
            }
        }
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

	if ( defined(my $text = $paramInfo->{text}) ) {
	    $content .= <<EOF;
<tr><td colspan="2" class="editHeader">$text</td></tr>
EOF
	    next;
	}

	#
	# TODO: get parameter documentation
	#
	my $comment = "";
	$comment =~ s/\'//g;
	$comment =~ s/\"//g;
        $comment =~ s/\n/ /g;

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
    }

    #
    # Emit any remaining errors - should not happen
    #
    foreach my $param ( sort(keys(%$errors)) ) {
	$content .= <<EOF;
<tr><td colspan="2" class="border">$errors->{$param}</td></tr>
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
        next if ( $userHost && !$bpc->{Conf}{CgiUserConfigEdit}{$param} );
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

    $content .= <<EOF;
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
            $content .= fieldHiddenBuild($type->{child}, "${varName}_$i",
                                         $varValue->[$i], $prefix);
        }
    } elsif ( $type->{type} eq "hash" ) {
        $varValue = {} if ( ref($varValue) ne "HASH" );
        my(@order, $childType);

        if ( defined($type->{child}) ) {
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
            $content .= fieldHiddenBuild($childType, "${varName}_$fld",
                                         $varValue->{$fld}, $prefix);
        }
    } elsif ( $type->{type} eq "shortlist" ) {
	$varValue = [$varValue] if ( ref($varValue) ne "ARRAY" );
	$varValue = join(", ", @$varValue);
        $content .= <<EOF;
<input type="hidden" name="${prefix}_$varName" value="${EscHTML($varValue)}">
EOF
    } else {
        $content .= <<EOF;
<input type="hidden" name="${prefix}_$varName" value="${EscHTML($varValue)}">
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

    if ( $level == 0 ) {
	$content .= <<EOF;
<tr id="id_$varName" class="optionalComment"><td colspan="2">$comment</td></tr>
<tr><td class="border"><a href="javascript: displayHelp('$varName')">$varName</a>
EOF
	if ( defined($overrideVar) ) {
	    my $override_checked = "";
	    if ( !$isError && $In{deleteVar}       =~ /^\Q${varName}_/
		    || !$isError && $In{insertVar} =~ /^\Q${varName}\E(_|$)/
		    || !$isError && $In{addVar}    =~ /^\Q${varName}\E(_|$)/ ) {
		$overrideSet = 1;
	    }
	    if ( $overrideSet ) {
		$override_checked = "checked";
	    }
            $content .= <<EOF;
<br><input type="checkbox" name="override_$varName" $override_checked value="1" onClick="checkboxChange('$varName')">\&nbsp;Override
EOF
	}
	$content .= "</td>\n";
    }

    $content .= "<td class=\"border\">\n";
    if ( $type->{type} eq "list" ) {
        $varValue = [] if ( !defined($varValue) );
        $varValue = [$varValue] if ( ref($varValue) ne "ARRAY" );
        if ( !$isError && $In{deleteVar} =~ /^\Q${varName}_\E(\d+)$/
                && $1 < @$varValue ) {
            #
            # User deleted entry in this array
            #
            splice(@$varValue, $1, 1) if ( @$varValue > 1 || $type->{emptyOk} );
            $In{deleteVar} = "";
        }
        if ( !$isError && $In{insertVar} =~ /^\Q${varName}_\E(\d+)$/
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

        for ( my $i = 0 ; $i < @$varValue ; $i++ ) {
            $content .= "<tr><td class=\"border\">\n";
	    if ( @$varValue > 1 || $type->{emptyOk} ) {
		$content .= <<EOF;
<input type="button" name="ins_${varName}_$i" value="Insert"
    onClick="insertSubmit('${varName}_$i')">
<input type="button" name="del_${varName}_$i" value="Delete"
    onClick="deleteSubmit('${varName}_$i')">
EOF
	    }
            $content .= "</td>\n";
            $content .= fieldEditBuild($type->{child}, "${varName}_$i",
                                $varValue->[$i], $errors, $level + 1, undef,
				$isError, $onchangeSubmit,
				$overrideVar, $overrideSet);
            $content .= "</tr>\n";
        }
        $content .= <<EOF;
<tr><td class="border"><input type="button" name="add_$varName" value="Add"
    onClick="addSubmit('$varName')"></td></tr>
</table>
EOF
    } elsif ( $type->{type} eq "hash" ) {
        $content .= "<table border=\"1\" cellspacing=\"0\">\n";
        $varValue = {} if ( ref($varValue) ne "HASH" );

        if ( !$isError && !$type->{noKeyEdit}
                        && $In{deleteVar} =~ /^\Q${varName}_\E(\w+)$/ ) {
            #
            # User deleted entry in this array
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
            $varValue->{$In{addVarKey}} = ""
                            if ( !defined($varValue->{$In{addVarKey}}) );
            $In{addVar} = "";
        }
        my(@order, $childType);

        if ( defined($type->{child}) ) {
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
<input type="submit" name="del_${varName}_$fld" value="Delete"
        onClick="deleteSubmit('${varName}_$fld')">
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
            $content .= fieldEditBuild($childType, "${varName}_$fld",
                            $varValue->{$fld}, $errors, $level + 1, undef,
			    $isError, $onchangeSubmit,
			    $overrideVar, $overrideSet);
            $content .= "</tr>\n";
        }

        if ( !$type->{noKeyEdit} ) {
            $content .= <<EOF;
<tr><td class="border" colspan="2">
New key: <input type="text" name="addVarKey" size="20" maxlength="256" value="">
<input type="button" name="add_$varName" value="Add" onClick="addSubmit('$varName', 1)">
</td></tr>
EOF
        }
        $content .= "</table>\n";
    } else {
        if ( $isError ) {
            #
            # If there was an error, we use the original post values
            # in %In, rather than the parsed values in $varValue.
            # This is so that the user's erroneous input is preserved.
            #
            $varValue = $In{"v_$varName"} if ( defined($In{"v_$varName"}) );
        }
        if ( defined($errors->{$varName}) ) {
            $content .= <<EOF;
$errors->{$varName}<br>
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
		    || $type->{type} eq "shortlist"
		    || $type->{type} eq "float") ) {
            # simple input box
	    if ( $type->{type} eq "shortlist" ) {
		$varValue = [$varValue] if ( ref($varValue) ne "ARRAY" );
		$varValue = join(", ", @$varValue);
	    }
            $content .= <<EOF;
<input type="text" name="v_$varName" size="$size" maxlength="256" value="${EscHTML($varValue)}"$onChange>
EOF
        } elsif ( $type->{type} eq "boolean" ) {
            # checkbox
            my $checked = "checked" if ( $varValue );
            $content .= <<EOF;
<input type="checkbox" name="v_$varName" $checked value="1">
EOF
        } elsif ( $type->{type} eq "select" ) {
            $content .= <<EOF;
<select name="v_$varName"$onChange>
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
<textarea name="v_$varName" cols="$size" rows="$rowCnt"$onChange>${EscHTML($varValue)}</textarea>
EOF
        }
    }
    $content .= "</td>\n";
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
            last if ( fieldErrorCheck($type->{child}, "${varName}_$i", $errors) );
        }
    } elsif ( $type->{type} eq "hash" ) {
        my(@order, $childType);
        my $ret;

        if ( defined($type->{child}) ) {
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
            $ret ||= fieldErrorCheck($childType, "${varName}_$fld", $errors);
        }
        return $ret;
    } else {
        return 1 if ( !exists($In{"v_$varName"}) );

        if ( $type->{type} eq "integer"
                || $type->{type} eq "boolean" ) {
            if ( $In{"v_$varName"} !~ /^-?\d+\s*$/s
			    && $In{"v_$varName"} ne "" ) {
                $errors->{$varName} = "Error: $varName must be an integer";
            }
        } elsif ( $type->{type} eq "float" ) {
            if ( $In{"v_$varName"} !~ /^-?\d*(\.\d*)?\s*$/s
			    && $In{"v_$varName"} ne "" ) {
                $errors->{$varName}
                        = "Error: $varName must be a real-valued number";
            }
        } elsif ( $type->{type} eq "shortlist" ) {
	    my @vals = split(/[,\s]+/, $In{"v_$varName"});
	    for ( my $i = 0 ; $i < @vals ; $i++ ) {
		if ( $type->{child} eq "integer"
			&& $vals[$i] !~ /^-?\d+\s*$/s
			&& $vals[$i] ne "" ) {
		    my $k = $i + 1;
		    $errors->{$varName} = "Error: $varName entry $k must"
					. " be an integer";
		} elsif ( $type->{child} eq "float"
			&& $vals[$i] !~ /^-?\d*(\.\d*)?\s*$/s
			&& $vals[$i] ne "" ) {
		    my $k = $i + 1;
		    $errors->{$varName} = "Error: $varName entry $k must"
					. " be a real-valued number";
		}
	    }
        } elsif ( $type->{type} eq "select" ) {
            my $match = 0;
            foreach my $option ( @{$type->{values}} ) {
                if ( $In{"v_$varName"} eq $option ) {
                    $match = 1;
                    last;
                }
            }
            $errors->{$varName} = "Error: $varName must be a valid option"
                            if ( !$match );
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
        next if ( $userHost && !$bpc->{Conf}{CgiUserConfigEdit}{$param} );
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
            last if ( fieldInputParse($type->{child}, "${varName}_$i", \$val) );
            push(@$$value, $val);
        }
        $$value = undef if ( $type->{undefIfEmpty} && @$$value == 0 );
    } elsif ( $type->{type} eq "hash" ) {
        my(@order, $childType);
        my $ret;
        $$value = {};

        if ( defined($type->{child}) ) {
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
            $ret ||= fieldInputParse($childType, "${varName}_$fld", \$val);
            last if ( $ret );
            $$value->{$fld} = $val;
        }
        return $ret;
    } else {
        if ( $type->{type} eq "boolean" ) {
            $$value = 0 + $In{"v_$varName"};
        } elsif ( !exists($In{"v_$varName"}) ) {
            return 1;
        }

        if ( $type->{type} eq "integer" ) {
            $$value = 0 + $In{"v_$varName"};
        } elsif ( $type->{type} eq "float" ) {
            $$value = 0 + $In{"v_$varName"};
        } elsif ( $type->{type} eq "shortlist" ) {
            $$value = [split(/[,\s]+/, $In{"v_$varName"})];
            if ( $type->{child} eq "float"
                    || $type->{child} eq "integer"
                    || $type->{child} eq "boolean" ) {
                foreach ( @$$value ) {
                    $_ += 0;
                }
            }
        } else {
            $$value = $In{"v_$varName"};
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
            $mesg .= "log Deleted $p from $conf\n";
        } elsif ( !exists($oldConf->{$p}) && exists($newConf->{$p}) ) {
            my $dump = Data::Dumper->new([$newConf->{$p}]);
            $dump->Indent(0);
            $dump->Sortkeys(1);
            $dump->Terse(1);
            my $value = $dump->Dump;
            $mesg .= "log Added $p to $conf, set to $value\n";
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

            $mesg .= "log Changed $p in $conf to $valueNew from $valueOld\n"
                                    if ( $valueOld ne $valueNew );
        }
    }
    return $mesg;
}

1;
