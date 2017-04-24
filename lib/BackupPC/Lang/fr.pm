#!/usr/bin/perl
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

# --------------------------------

$Lang{Start_Archive} = "D�marrer l'archivage";
$Lang{Stop_Dequeue_Archive} = "Arr�t/Mise en attente de l'archivage";
$Lang{Start_Full_Backup} = "D�marrer la sauvegarde compl�te";
$Lang{Start_Incr_Backup} = "D�marrer la sauvegarde incr�mentielle";
$Lang{Stop_Dequeue_Backup} = "Arr�ter/annuler la sauvegarde";
$Lang{Restore} = "Restaurer";

$Lang{Type_full} = "compl�te";
$Lang{Type_incr} = "incr�mentielle";

# -----

$Lang{Only_privileged_users_can_view_admin_options} = "Seuls les utilisateurs privil�gi�s peuvent voir les options d'administration.";
$Lang{H_Admin_Options} = "BackupPC: Options d'administration";
$Lang{Admin_Options} = "Options d'administration";
$Lang{Admin_Options_Page} = <<EOF;
\${h1(qq{$Lang{Admin_Options}})}
<br>
\${h2("Contr�le du serveur")}
<form name="ReloadForm" action="\$MyURL" method="get">
<input type="hidden" name="action" value="">
<table class="tableStnd">
  <tr><td>Recharger la configuration:<td><input type="button" value="Recharger"
     onClick="document.ReloadForm.action.value='Reload';
              document.ReloadForm.submit();">
</table>
</form>
<!--
\${h2("Server Configuration")}
<ul>
  <li><i>Other options can go here... e.g.,</i>
  <li>Edit server configuration
</ul>
-->
EOF

$Lang{Unable_to_connect_to_BackupPC_server} = "Impossible de se connecter au serveur BackupPC";
$Lang{Unable_to_connect_to_BackupPC_server_error_message} = <<EOF;
Ce script CGI (\$MyURL) est incapable de se connecter au serveur BackupPC
sur \$Conf{ServerHost} au port \$Conf{ServerPort}.<br>
L'erreur est: \$err.<br>
Il est possible que le serveur BackupPC ne fonctionne pas actuellement ou qu'il
y ait une erreur de configuration. Veuillez contacter votre administrateur syst�me.
EOF

$Lang{Admin_Start_Server} = <<EOF;
\${h1(qq{$Lang{Unable_to_connect_to_BackupPC_server}})}
<form action="\$MyURL" method="get">
Le serveur BackupPC sur <tt>\$Conf{ServerHost}</tt>, port <tt>\$Conf{ServerPort}</tt>
n'est pas en fonction (vous l'avez peut-�tre arr�t�, ou vous ne l'avez pas encore d�marr�).<br>
Voulez-vous le d�marrer ?
<input type="hidden" name="action" value="startServer">
<input type="submit" value="D�marrer le serveur" name="ignore">
</form>
EOF

# -----

$Lang{H_BackupPC_Server_Status} = "�tat du serveur BackupPC";

$Lang{BackupPC_Server_Status_General_Info}= <<EOF;
\${h2(\"Informations g�n�rales du serveur\")}

<ul>
<li> Le PID du serveur est \$Info{pid}, sur l\'h�te \$Conf{ServerHost},
     version \$Info{Version}, d�marr� le \$serverStartTime.
<li> Ce rapport a �t� g�n�r� le \$now.
<li> La configuration a �t� charg�e pour la derni�re fois � \$configLoadTime.
<li> La prochaine file d\'attente sera remplie � \$nextWakeupTime.
<li> Autres infos:
    <ul>
        <li>\$numBgQueue demandes de sauvegardes en attente depuis le dernier r�veil automatique,
        <li>\$numUserQueue requ�tes de sauvegardes utilisateur en attente,
        <li>\$numCmdQueue requ�tes de commandes en attente,
        \$poolInfo
        <li>L\'espace de stockage a �t� r�cemment rempli � \$Info{DUlastValue}%
            (\$DUlastTime), le maximum aujourd\'hui a �t� de \$Info{DUDailyMax}% (\$DUmaxTime)
            et hier le maximum �tait de \$Info{DUDailyMaxPrev}%.
    </ul>
</ul>
EOF

$Lang{BackupPC_Server_Status} = <<EOF;
\${h1(qq{$Lang{H_BackupPC_Server_Status}})}

<p>
\${h2("Travaux en cours d'ex�cution")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td> H�te </td>
    <td> Type </td>
    <td> Utilisateur </td>
    <td> Date de d�part </td>
    <td> Commande </td>
    <td align="center"> PID </td>
    <td align="center"> PID du transfert </td>
    <td align="center"> Status </td>
    <td align="center"> Count </td>
    </tr>
\$jobStr
</table>

<p>
\$generalInfo

\${h2("�checs qui demandent de l'attention")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> H�te </td>
    <td align="center"> Type </td>
    <td align="center"> Utilisateur </td>
    <td align="center"> Dernier essai </td>
    <td align="center"> D�tails </td>
    <td align="center"> Date d\'erreur </td>
    <td> Derni�re erreur (autre que pas de ping) </td></tr>
\$statusStr
</table>
EOF

# --------------------------------
$Lang{BackupPC__Server_Summary} = "BackupPC: Bilan des machines";
$Lang{BackupPC__Archive} = "BackupPC: Archivage";
$Lang{BackupPC_Summary}=<<EOF;

\${h1(qq{$Lang{BackupPC__Server_Summary}})}
<p>
<ul>
<li>Ce statut a �t� g�n�r� le \$now.
<li>L\'espace de stockage a �t� r�cemment rempli � \$Info{DUlastValue}%
    (\$DUlastTime), le maximum aujourd\'hui a �t� de \$Info{DUDailyMax}% (\$DUmaxTime)
    et hier le maximum �tait de \$Info{DUDailyMaxPrev}%.
</ul>
</p>

\${h2("H�tes avec de bonnes sauvegardes")}
<p>
Il y a \$hostCntGood h�tes ayant �t� sauvegard�s, pour un total de :
<ul>
<li> \$fullTot sauvegardes compl�tes de tailles cumul�es de \${fullSizeTot} Go
     (pr�c�dant la mise en commun et la compression),
<li> \$incrTot sauvegardes incr�mentielles de tailles cumul�es de \${incrSizeTot} Go
     (pr�c�dant la mise en commun et la compression).
</ul>
</p>
<table class="sortable" id="host_summary_backups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> H�te </td>
    <td align="center"> Utilisateur </td>
    <td align="center"> Nb compl�tes </td>
    <td align="center"> Compl�tes �ge (jours) </td>
    <td align="center"> Compl�tes Taille (Go) </td>
    <td align="center"> Vitesse (Mo/s) </td>
    <td align="center"> Nb incr�mentielles </td>
    <td align="center"> Incr�mentielles �ge (jours) </td>
    <td align="center"> Derni�re sauvegarde (jours) </td>
    <td align="center"> �tat actuel </td>
    <td align="center"> Nb erreurs transfert </td>
    <td align="center"> Derni�re tentative </td></tr>
\$strGood
</table>
\${h2("H�tes sans sauvegardes")}
<p>
Il y a \$hostCntNone h�tes sans sauvegardes.
<p>
<table class="sortable" id="host_summary_nobackups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> H�te </td>
    <td align="center"> Utilisateur </td>
    <td align="center"> Nb compl�tes </td>
    <td align="center"> Compl�tes �ge (jours) </td>
    <td align="center"> Compl�tes Taille (Go) </td>
    <td align="center"> Vitesse (Mo/s) </td>
    <td align="center"> Nb incr�mentielles </td>
    <td align="center"> Incr�mentielles �ge (jours) </td>
    <td align="center"> Derni�re sauvegarde (jours) </td>
    <td align="center"> �tat actuel </td>
    <td align="center"> Nb erreurs transfert </td>
    <td align="center"> Derni�re tentative </td></tr>
\$strNone
</table>
EOF

$Lang{BackupPC_Archive}=<<EOF;
\${h1(qq{$Lang{BackupPC__Archive}})}
<script language="javascript" type="text/javascript">
<!--

    function checkAll(location)
    {
      for (var i=0;i<document.form1.elements.length;i++)
      {
        var e = document.form1.elements[i];
        if ((e.checked || !e.checked) && e.name != \'all\') {
            if (eval("document.form1."+location+".checked")) {
                e.checked = true;
            } else {
                e.checked = false;
            }
        }
      }
    }

    function toggleThis(checkbox)
    {
       var cb = eval("document.form1."+checkbox);
       cb.checked = !cb.checked;
    }

//-->
</script>

Il y a \$hostCntGood h�tes qui ont �t� sauvegard�s, repr�sentant \${fullSizeTot} Go
<p>
<form name="form1" method="post" action="\$MyURL">
<input type="hidden" name="fcbMax" value="\$checkBoxCnt">
<input type="hidden" name="type" value="1">
<input type="hidden" name="host" value="\${EscHTML(\$archHost)}">
<input type="hidden" name="action" value="Archive">
<table class="tableStnd" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td align=center> Host</td>
    <td align="center"> Utilisateur </td>
    <td align="center"> Taille </td>
\$strGood
\$checkAllHosts
</table>
</form>
<p>

EOF

$Lang{BackupPC_Archive2}=<<EOF;
\${h1(qq{$Lang{BackupPC__Archive}})}
Pr�t � d�marrer l'archivage des h�tes suivants
<ul>
\$HostListStr
</ul>
<form action="\$MyURL" method="post">
\$hiddenStr
<input type="hidden" name="action" value="Archive">
<input type="hidden" name="host" value="\${EscHTML(\$archHost)}">
<input type="hidden" name="type" value="2">
<input type="hidden" value="0" name="archive_type">
<table class="tableStnd" border cellspacing="1" cellpadding="3">
\$paramStr
<tr>
    <td colspan=2><input type="submit" value="D�marrer l'archivage" name="ignore"></td>
</tr>
</form>
</table>
EOF

$Lang{BackupPC_Archive2_location} = <<EOF;
<tr>
    <td>Dispositif/Localisation de l'archive</td>
    <td><input type="text" value="\$ArchiveDest" name="archive_device"></td>
</tr>
EOF

$Lang{BackupPC_Archive2_compression} = <<EOF;
<tr>
    <td>Compression</td>
    <td>
    <input type="radio" value="0" name="compression" \$ArchiveCompNone>Aucune<br>
    <input type="radio" value="1" name="compression" \$ArchiveCompGzip>gzip<br>
    <input type="radio" value="2" name="compression" \$ArchiveCompBzip2>bzip2
    </td>
</tr>
EOF

$Lang{BackupPC_Archive2_parity} = <<EOF;
<tr>
    <td>Pourcentage des donn�es de parit� (0 = d�sactiv�, 5 = typique)</td>
    <td><input type="numeric" value="\$ArchivePar" name="par"></td>
</tr>
EOF

$Lang{BackupPC_Archive2_split} = <<EOF;
<tr>
    <td>Scinder le fichier en fichiers de</td>
    <td><input type="numeric" value="\$ArchiveSplit" name="splitsize"> Mo</td>
</tr>
EOF

# -----------------------------------
$Lang{Pool_Stat} = <<EOF;
        <li>La mise en commun est constitu�e de \$info->{"\${name}FileCnt"} fichiers
            et \$info->{"\${name}DirCnt"} r�pertoires repr�sentant \${poolSize} Go (depuis le \$poolTime),
        <li>Le hachage de mise en commun des fichiers donne \$info->{"\${name}FileCntRep"} fichiers r�p�t�s
            avec comme plus longue cha�ne \$info->{"\${name}FileRepMax"},
        <li>Le nettoyage nocturne a effac� \$info->{"\${name}FileCntRm"} fichiers, soit
            \${poolRmSize} Go (vers \$poolTime),
EOF

# -----------------------------------
$Lang{BackupPC__Backup_Requested_on__host} = "BackupPC: Sauvegarde demand�e sur \$host";
# --------------------------------
$Lang{REPLY_FROM_SERVER} = <<EOF;
\${h1(\$str)}
<p>
La r�ponse du serveur a �t� : \$reply
<p>
Retourner � la page d\'accueil de <a href="\$MyURL?host=\$host">\$host</a>.
EOF
# --------------------------------
$Lang{BackupPC__Start_Backup_Confirm_on__host} = "BackupPC: Confirmation du d�marrage de la sauvegarde de \$host";
# --------------------------------
$Lang{Are_you_sure_start} = <<EOF;
\${h1("�tes-vous certain ?")}
<p>
Vous allez bient�t d�marrer une sauvegarde \$type depuis \$host.

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="hostIP" value="\$ipAddr">
<input type="hidden" name="doit" value="1">
<input type="hidden" name="action" value="">
Voulez-vous vraiment le faire ?
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="Non" name="ignore">
</form>
EOF
# --------------------------------
$Lang{BackupPC__Stop_Backup_Confirm_on__host} = "BackupPC: Confirmer l\'arr�t de la sauvegarde sur \$host";
# --------------------------------
$Lang{Are_you_sure_stop} = <<EOF;

\${h1("�tes-vous certain ?")}

<p>
Vous �tes sur le point d\'arr�ter/supprimer de la file les sauvegardes de \$host;

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host"   value="\$host">
<input type="hidden" name="doit"   value="1">
<input type="hidden" name="action" value="">
En outre, pri�re de ne pas d�marrer d\'autre sauvegarde pendant
<input type="text" name="backoff" size="10" value="\$backoff"> heures.
<p>
Voulez-vous vraiment le faire ?
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="Non" name="ignore">
</form>

EOF
# --------------------------------
$Lang{Only_privileged_users_can_view_queues_} = "Seuls les utilisateurs privil�gi�s peuvent voir les files.";
# --------------------------------
$Lang{Only_privileged_users_can_archive} = "Seuls les utilisateurs privil�gi�s peuvent archiver.";
# --------------------------------
$Lang{BackupPC__Queue_Summary} = "BackupPC: R�sum� de la file";
# --------------------------------
$Lang{Backup_Queue_Summary} = <<EOF;
\${h1("R�sum� de la file")}
\${h2("R�sum� des files des utilisateurs")}
<p>
Les demandes utilisateurs suivantes sont actuellement en attente :
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> H�te </td>
    <td> Temps Requis </td>
    <td> Utilisateur </td></tr>
\$strUser
</table>

\${h2("R�sum� de la file en arri�re plan")}
<p>
Les demandes en arri�re plan suivantes sont actuellement en attente :
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> H�te </td>
    <td> Temps requis </td>
    <td> Utilisateur </td></tr>
\$strBg
</table>
\${h2("R�sum� de la file d\'attente des commandes")}
<p>
Les demandes de commande suivantes sont actuellement en attente :
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> H�tes </td>
    <td> Temps Requis </td>
    <td> Utilisateur </td>
    <td> Commande </td></tr>
\$strCmd
</table>
EOF

# --------------------------------
$Lang{Backup_PC__Log_File__file} = "BackupPC: Fichier \$file";
$Lang{Log_File__file__comment} = <<EOF;
\${h1("Fichier \$file \$comment")}
<p>
EOF
# --------------------------------
$Lang{Contents_of_log_file} = <<EOF;
Contenu du fichier <tt>\$file</tt>, modifi� le \$mtimeStr \$comment
EOF

# --------------------------------
$Lang{skipped__skipped_lines} = "[ \$skipped lignes saut�es ]\n";
# --------------------------------
$Lang{_pre___Can_t_open_log_file__file} = "<pre>\nNe peut pas ouvrir le fichier journal \$file\n";

# --------------------------------
$Lang{BackupPC__Log_File_History} = "BackupPC: Historique du fichier journal";
$Lang{Log_File_History__hdr} = <<EOF;
\${h1("Historique du fichier journal \$hdr")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Fichier </td>
    <td align="center"> Taille </td>
    <td align="center"> Date de modification </td></tr>
\$str
</table>
EOF

# -------------------------------
$Lang{Recent_Email_Summary} = <<EOF;
\${h1("R�sum� des courriels r�cents (du plus r�cent au plus vieux)")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Destinataire </td>
    <td align="center"> H�te </td>
    <td align="center"> Date </td>
    <td align="center"> Sujet </td></tr>
\$str
</table>
EOF


# ------------------------------
$Lang{Browse_backup__num_for__host} = "BackupPC: Navigation dans la sauvegarde \$num de \$host";

# ------------------------------
$Lang{Restore_Options_for__host} = "BackupPC: Options de restauration sur \$host";
$Lang{Restore_Options_for__host2} = <<EOF;
\${h1("Options de restauration sur \$host")}
<p>
Vous avez s�lectionn� les fichiers/r�pertoires suivants depuis
le partage \$share, sauvegarde num�ro \$num:
<ul>
\$fileListStr
</ul>
</p><p>
Vous avez trois choix pour restaurer ces fichiers/r�pertoires.
Veuillez s�lectionner une des options suivantes.
</p>
\${h2("Option 1: Restauration directe")}
<p>
EOF

$Lang{Restore_Options_for__host_Option1} = <<EOF;
Vous pouvez d�marrer une restauration de ces fichiers 
directement sur <b>\$directHost</b>.
</p><p>
<b>Attention:</b>
tous les fichiers correspondant � ceux que vous avez s�lectionn�s vont �tre �cras�s !
</p>
<form action="\$MyURL" method="post" name="direct">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="3">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<table class="tableStnd" border="0">
<tr>
    <td>Restaure les fichiers vers l'h�te</td>
    <td><!--<input type="text" size="40" value="\${EscHTML(\$host)}"
	 name="hostDest">-->
	 <select name="hostDest" onChange="document.direct.shareDest.value=''">
	 \$hostDestSel
	 </select>
	 <script language="Javascript">
	 function myOpen(URL) {
		window.open(URL,'','width=500,height=400');
	}
	 </script>
	 <!--<a href="javascript:myOpen('\$MyURL?action=findShares&host='+document.direct.hostDest.options.value)">Chercher les partitions disponibles (NON IMPLANTE)</a>--></td>
</tr><tr>
    <td>Restaurer les fichiers vers le partage</td>
    <td><input type="text" size="40" value="\${EscHTML(\$share)}"
	 name="shareDest"></td>
</tr><tr>
    <td>Restaurer les fichiers du r�pertoire<br>(relatif au partage)</td>
    <td valign="top"><input type="text" size="40" maxlength="256"
	value="\${EscHTML(\$pathHdr)}" name="pathHdr"></td>
</tr><tr>
    <td><input type="submit" value="D�marrer la restauration" name="ignore"></td>
</table>
</form>
EOF

$Lang{Restore_Options_for__host_Option1_disabled} = <<EOF;
La restauration directe a �t� d�sactiv�e pour l'h�te \${EscHTML(\$hostDest)}.
Veuillez choisir une autre option.
EOF

# ------------------------------
$Lang{Option_2__Download_Zip_archive} = <<EOF;
<p>
\${h2("Option 2: T�l�charger une archive Zip")}
<p>
Vous pouvez t�l�charger une archive compress�e (.zip) contenant tous les fichiers/r�pertoires que vous 
avez s�lectionn�s. Vous pouvez utiliser une application locale, comme Winzip, pour voir ou extraire n\'importe quel fichier.
</p><p>
<b>Attention:</b> en fonction des fichiers/r�pertoires que vous avez s�lectionn�s,
cette archive peut devenir tr�s tr�s volumineuse. Cela peut prendre plusieurs minutes pour cr�er
et transf�rer cette archive, et vous aurez besoin d\'assez d\'espace disque pour la stocker.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="2">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Faire l\'archive relative �
\${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(Autrement l\'archive contiendra les chemins complets).
<br>
<table class="tableStnd" border="0">
<tr>
    <td>Compression (0=d�sactiv�e, 1=rapide,...,9=meilleure)</td>
    <td><input type="text" size="6" value="5" name="compressLevel"></td>
</tr><tr>
    <td>Code page (e.g. cp866)</td>
    <td><input type="text" size="6" value="utf8" name="codePage"></td>
</tr>
</table>
<br>
<input type="submit" value="T�l�charger le fichier Zip" name="ignore">
</form>
EOF


# ------------------------------

$Lang{Option_2__Download_Zip_archive2} = <<EOF;
<p>
\${h2("Option 2: T�l�charger une archive Zip")}
<p>
Vous ne pouvez pas t�l�charger d'archive zip, car Archive::Zip n\'est pas
install�. 
Veuillez demander � votre administrateur syst�me d\'installer 
Archive::Zip depuis <a href="http://www.cpan.org">www.cpan.org</a>.
</p>
EOF


# ------------------------------
$Lang{Option_3__Download_Zip_archive} = <<EOF;
\${h2("Option 3: T�l�charger une archive tar")}
<p>
Vous pouvez t�l�charger une archive Tar contenant tous les fichiers/r�pertoires 
que vous avez s�lectionn�s. Vous pourrez alors utiliser une application locale, 
comme tar ou winzip pour voir ou extraire n\'importe quel fichier.
</p><p>
<b>Attention:</b> en fonction des fichiers/r�pertoires que vous avez s�lectionn�s,
cette archive peut devenir tr�s tr�s volumineuse.  Cela peut prendre plusieurs minutes
pour cr�er et transf�rer l\'archive, et vous aurez besoin d\'assez
d\'espace disque local pour la stocker.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="1">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Faire l\'archive relative �
\${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(Autrement l\'archive contiendra des chemins absolus).
<br>
<input type="submit" value="T�l�charger le fichier Tar" name="ignore">
</form>
EOF


# ------------------------------
$Lang{Restore_Confirm_on__host} = "BackupPC: Confirmation de restauration sur \$host";

$Lang{Are_you_sure} = <<EOF;
\${h1("�tes-vous s�r ?")}
<p>
Vous �tes sur le point de d�marrer une restauration directement sur 
la machine \$In{hostDest}. Les fichiers suivants vont �tre restaur�s 
dans le partage \$In{shareDest}, depuis la sauvegarde num�ro \$num:
<p>
<table class="tableStnd" border>
<tr class="tableheader"><td>Fichier/R�pertoire original</td><td>Va �tre restaur� �</td></tr>
\$fileListStr
</table>

<form name="RestoreForm" action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="hostDest" value="\${EscHTML(\$In{hostDest})}">
<input type="hidden" name="shareDest" value="\${EscHTML(\$In{shareDest})}">
<input type="hidden" name="pathHdr" value="\${EscHTML(\$In{pathHdr})}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="4">
<input type="hidden" name="action" value="">
\$hiddenStr
Voulez-vous vraiment le faire ?
<input type="button" value="\$Lang->{Restore}"
 onClick="document.RestoreForm.action.value='Restore';
          document.RestoreForm.submit();">
<input type="submit" value="No" name="ignore">
</form>
EOF

# --------------------------
$Lang{Restore_Requested_on__hostDest} = "BackupPC: Restauration demand�e sur \$hostDest";
$Lang{Reply_from_server_was___reply} = <<EOF;
\${h1(\$str)}
<p>
La r�ponse du serveur est : \$reply
<p>
Retourner � la page d\'accueil de <a href="\$MyURL?host=\$hostDest">\$hostDest </a>.
EOF

$Lang{BackupPC_Archive_Reply_from_server} = <<EOF;
\${h1(\$str)}
<p>
La r�ponse du serveur est : \$reply
EOF


# -------------------------
$Lang{Host__host_Backup_Summary} = "BackupPC: R�sum� de la sauvegarde de l\'h�te \$host ";

$Lang{Host__host_Backup_Summary2} = <<EOF;
\${h1("R�sum� de la sauvegarde de l\'h�te \$host ")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>
</p>
\${h2("Actions de l\'utilisateur")}
<p>
<form name="StartStopForm" action="\$MyURL" method="get">
<input type="hidden" name="host"   value="\$host">
<input type="hidden" name="action" value="">
\$startIncrStr
<input type="button" value="\$Lang->{Start_Full_Backup}"
 onClick="document.StartStopForm.action.value='Start_Full_Backup';
          document.StartStopForm.submit();">
<input type="button" value="\$Lang->{Stop_Dequeue_Backup}"
 onClick="document.StartStopForm.action.value='Stop_Dequeue_Backup';
          document.StartStopForm.submit();">
</form>
</p>
\${h2("R�sum� de la sauvegarde")}
<p>
Cliquer sur le num�ro de l\'archive pour naviguer et restaurer les fichiers de sauvegarde.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> Sauvegarde n� </td>
    <td align="center"> Type </td>
    <td align="center"> Fusionn�e </td> 
    <td align="center"> Niveau </td>
    <td align="center"> Date de d�marrage </td>
    <td align="center"> Dur�e (min) </td>
    <td align="center"> �ge (jours) </td>
    <td align="center"> Chemin d\'acc�s de la sauvegarde sur le serveur </td>
</tr>
\$str
</table>
<p>

\$restoreStr
</p>
\${h2("R�sum� des erreurs de transfert")}
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Sauvegarde n� </td>
    <td align="center"> Type </td>
    <td align="center"> Voir </td>
    <td align="center"> Nb erreurs transfert </td>
    <td align="center"> Nb mauvais fichiers </td>
    <td align="center"> Nb mauvais partages </td>
    <td align="center"> Nb erreurs tar </td>
</tr>
\$errStr
</table>

\${h2("R�capitulatif de la taille des fichier et du nombre de r�utilisations")}
<p>
Les fichiers existants sont ceux qui sont d�j� sur le serveur; 
Les nouveaux fichiers sont ceux qui ont �t� ajout�s au serveur.
Les fichiers vides et les erreurs de SMB ne sont pas comptabilis�s dans les fichiers nouveaux ou r�utilis�s.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="2" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> Totaux </td>
    <td align="center" colspan="2"> Fichiers existants </td>
    <td align="center" colspan="2"> Nouveaux fichiers </td>
</tr>
<tr class="tableheader">
    <td align="center"> Sauvegarde n� </td>
    <td align="center"> Type </td>
    <td align="center"> Nb de Fichiers </td>
    <td align="center"> Taille (Mo) </td>
    <td align="center"> Mo/s </td>
    <td align="center"> Nb de Fichiers </td>
    <td align="center"> Taille (Mo) </td>
    <td align="center"> Nb de Fichiers </td>
    <td align="center"> Taille (Mo) </td>
</tr>
\$sizeStr
</table>

\${h2("R�sum� de la compression")}
<p>
Performance de la compression pour les fichiers d�j� sur le serveur et
r�cemment compress�s.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="3" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> Fichiers existants </td>
    <td align="center" colspan="3"> Nouveaux fichiers </td>
</tr>
<tr class="tableheader"><td align="center"> Nb de sauvegardes </td>
    <td align="center"> Type </td>
    <td align="center"> Niveau de Compression </td>
    <td align="center"> Taille (Mo) </td>
    <td align="center"> Taille compress�e (Mo) </td>
    <td align="center"> Compression </td>
    <td align="center"> Taille (Mo) </td>
    <td align="center"> Taille compress�e (Mo) </td>
    <td align="center"> Compression </td>
</tr>
\$compStr
</table>
EOF

$Lang{Host__host_Archive_Summary} = "BackupPC: R�sum� de l'archivage pour l'h�te \$host";
$Lang{Host__host_Archive_Summary2} = <<EOF;
\${h1("R�sum� de l\'archivage pour l\'h�te \$host")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>

\${h2("User Actions")}
<p>
<form name="StartStopForm" action="\$MyURL" method="get">
<input type="hidden" name="archivehost" value="\$host">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="action" value="">
<input type="button" value="\$Lang->{Start_Archive}"
 onClick="document.StartStopForm.action.value='Start_Archive';
          document.StartStopForm.submit();">
<input type="button" value="\$Lang->{Stop_Dequeue_Archive}"
 onClick="document.StartStopForm.action.value='Stop_Dequeue_Archive';
          document.StartStopForm.submit();">
</form>


\$ArchiveStr

EOF

# -------------------------
$Lang{Error} = "BackupPC: Erreur";
$Lang{Error____head} = <<EOF;
\${h1("Erreur: \$head")}
<p>\$mesg</p>
EOF

# -------------------------
$Lang{NavSectionTitle_} = "Serveur";

# -------------------------
$Lang{Backup_browse_for__host} = <<EOF;
\${h1("Navigation dans la sauvegarde de \$host")}

<script language="javascript" type="text/javascript">
<!--

    function checkAll(location)
    {
      for (var i=0;i<document.form1.elements.length;i++)
      {
        var e = document.form1.elements[i];
        if ((e.checked || !e.checked) && e.name != \'all\') {
            if (eval("document.form1."+location+".checked")) {
            	e.checked = true;
            } else {
            	e.checked = false;
            }
        }
      }
    }
    
    function toggleThis(checkbox)
    {
       var cb = eval("document.form1."+checkbox);
       cb.checked = !cb.checked;	
    }

//-->
</script>

<form name="form0" method="post" action="\$MyURL">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="share" value="\${EscHTML(\$share)}">
<input type="hidden" name="action" value="browse">
<ul>
<li> Vous naviguez dans la sauvegarde n�\$num, qui a commenc� vers \$backupTime
        (il y a \$backupAge jours),
\$filledBackup
<li> Entrez le r�pertoire: <input type="text" name="dir" size="50" maxlength="4096" value="\${EscHTML(\$dir)}"> <input type="submit" value="\$Lang->{Go}" name="Submit">
<li> Cliquer sur un r�pertoire ci-dessous pour y naviguer,
<li> Cliquer sur un fichier ci-dessous pour le restaurer,
<li> Vous pouvez voir l'<a href="\$MyURL?action=dirHistory&host=\${EscURI(\$host)}&share=\$shareURI&dir=\$pathURI">historique</a> des diff�rentes sauvegardes du r�pertoire courant.
</ul>
</form>

\${h2("Contenu de \$dirDisplay")}
<form name="form1" method="post" action="\$MyURL">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="share" value="\${EscHTML(\$share)}">
<input type="hidden" name="fcbMax" value="\$checkBoxCnt">
<input type="hidden" name="action" value="Restore">
<br>
<table width="100%">
<tr><td valign="top" width="30%">
    <table align="left" border="0" cellpadding="0" cellspacing="0" bgcolor="#ffffff">
    \$dirStr
    </table>
</td><td width="3%">
</td><td valign="top">
    <br>
        <table border width="100%" align="left" cellpadding="3" cellspacing="1">
        \$fileHeader
        \$topCheckAll
        \$fileStr
        \$checkAll
        </table>
    </td></tr></table>
<br>
<!--
This is now in the checkAll row
<input type="submit" name="Submit" value="Restore selected files">
-->
</form>
EOF

# ------------------------------
$Lang{DirHistory_backup_for__host} = "BackupPC: Historique des sauvegardes du r�pertoire courant pour \$host";

#
# These two strings are used to build the links for directories and
# file versions.  Files are appended with a version number.
#
$Lang{DirHistory_dirLink}  = "rep";
$Lang{DirHistory_fileLink} = "v";

$Lang{DirHistory_for__host} = <<EOF;
\${h1("Historique des sauvegardes du r�pertoire courant pour \$host")}
<p>
Cette page montre toutes les version disponibles des fichiers sauvegard�s pour le r�pertoire courant :
<ul>
<li> Cliquez sur un num�ro de sauvegarde pour revenir � la navigation de sauvegarde,
<li> Cliquez sur un r�pertoire (\$Lang->{DirHistory_dirLink}) pour naviguer
     dans celui-ci.
<li> Cliquez sur une version d'un fichier (\$Lang->{DirHistory_fileLink}0,
     \$Lang->{DirHistory_fileLink}1, ...) pour le t�l�charger.
<li> Les fichiers avec des contenus identiques pour plusieurs sauvegardes ont 
     le m�me num�ro de version.
<li> Les fichiers qui ne sont pas pr�sents sur une sauvegarde en particulier 
     sont repr�sent�s par une bo�te vide.
<li> Les fichiers montr�s avec la m�me version peuvent avoir des attributs diff�rents. 
     Choisissez le num�ro de sauvegarde pour voir les attributs de fichiers.
</ul>

\${h2("Historique de \$dirDisplay")}

<br>
<table border cellspacing="2" cellpadding="3">
<tr class="fviewheader"><td>Num�ro de sauvegarde</td>\$backupNumStr</tr>
<tr class="fviewheader"><td>Date</td>\$backupTimeStr</tr>
\$fileStr
</table>
EOF

# ------------------------------
$Lang{Restore___num_details_for__host} = "BackupPC: D�tails de la restauration n�\$num pour \$host"; 

$Lang{Restore___num_details_for__host2} = <<EOF;
\${h1("D�tails de la restauration n�\$num pour \$host")} 
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="90%">
<tr><td class="tableheader"> Num�ro </td><td class="border"> \$Restores[\$i]{num} </td></tr>
<tr><td class="tableheader"> Demand�e par </td><td class="border"> \$RestoreReq{user} </td></tr>
<tr><td class="tableheader"> Demand�e � </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> R�sultat </td><td class="border"> \$Restores[\$i]{result} </td></tr>
<tr><td class="tableheader"> Message d'erreur </td><td class="border"> \$Restores[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> H�te source </td><td class="border"> \$RestoreReq{hostSrc} </td></tr>
<tr><td class="tableheader"> N� de sauvegarde </td><td class="border"> \$RestoreReq{num} </td></tr>
<tr><td class="tableheader"> Partition source </td><td class="border"> \$RestoreReq{shareSrc} </td></tr>
<tr><td class="tableheader"> H�te de destination </td><td class="border"> \$RestoreReq{hostDest} </td></tr>
<tr><td class="tableheader"> Partition de destination </td><td class="border"> \$RestoreReq{shareDest} </td></tr>
<tr><td class="tableheader"> D�but </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Dur�e </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> Nombre de fichiers </td><td class="border"> \$Restores[\$i]{nFiles} </td></tr>
<tr><td class="tableheader"> Taille totale </td><td class="border"> \${MB} Mo </td></tr>
<tr><td class="tableheader"> Taux de transfert </td><td class="border"> \$MBperSec Mo/s </td></tr>
<tr><td class="tableheader"> Erreurs de TarCreate </td><td class="border"> \$Restores[\$i]{tarCreateErrs} </td></tr>
<tr><td class="tableheader"> Erreurs de transfert </td><td class="border"> \$Restores[\$i]{xferErrs} </td></tr>
<tr><td class="tableheader"> Journal de transfert </td><td class="border">
<a href="\$MyURL?action=view&type=RestoreLOG&num=\$Restores[\$i]{num}&host=\$host">Visionner</a>,
<a href="\$MyURL?action=view&type=RestoreErr&num=\$Restores[\$i]{num}&host=\$host">Erreurs</a>
</tr></tr>
</table>
</p>
\${h1("Liste des Fichiers/R�pertoires")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="100%">
<tr class="tableheader"><td>Fichier/r�pertoire original</td><td>Restaur� vers</td></tr>
\$fileListStr
</table>
EOF

# ------------------------------
$Lang{Archive___num_details_for__host} = "BackupPC: D�tails de l'archivage n�\$num pour \$host";

$Lang{Archive___num_details_for__host2 } = <<EOF;
\${h1("D�tails de l'archivage n�\$num pour \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr><td class="tableheader"> Num�ro </td><td class="border"> \$Archives[\$i]{num} </td></tr>
<tr><td class="tableheader"> Demand� par </td><td class="border"> \$ArchiveReq{user} </td></tr>
<tr><td class="tableheader"> Heure de demande </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> R�sultat </td><td class="border"> \$Archives[\$i]{result} </td></tr>
<tr><td class="tableheader"> Message d'erreur </td><td class="border"> \$Archives[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> Heure de d�but </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Dur�e </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> Journal de transfert </td><td class="border">
<a href="\$MyURL?action=view&type=ArchiveLOG&num=\$Archives[\$i]{num}&host=\$host">Voir</a>,
<a href="\$MyURL?action=view&type=ArchiveErr&num=\$Archives[\$i]{num}&host=\$host">Erreurs</a>
</tr></tr>
</table>
<p>
\${h1("Liste de h�tes")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td>Host</td><td>Num�ro de sauvegarde</td></tr>
\$HostListStr
</table>
EOF

# -----------------------------------
$Lang{Email_Summary} = "BackupPC: R�sum� du courriel";

# -----------------------------------
#  !! ERROR messages !!
# -----------------------------------
$Lang{BackupPC__Lib__new_failed__check_apache_error_log} = "BackupPC::Lib->new a �chou�: regardez le fichier error_log d\'apache\n";
$Lang{Wrong_user__my_userid_is___} =  
              "Mauvais utilisateur: mon userid est \$>, � la place de \$uid "
              . "(\$Conf{BackupPCUser})\n";
#$Lang{Only_privileged_users_can_view_PC_summaries} = "Seuls les utilisateurs privil�gi�s peuvent voir les r�sum�s des machines.";
$Lang{Only_privileged_users_can_stop_or_start_backups} = 
                  "Seuls les utilisateurs privil�gi�s peuvent arr�ter ou d�marrer des sauvegardes sur "
                  . " \${EscHTML(\$host)}.";
$Lang{Invalid_number__num} = "Num�ro invalide \${EscHTML(\$In{num})}";
$Lang{Unable_to_open__file__configuration_problem} = "Impossible d\'ouvrir \$file : probl�me de configuration ?";
$Lang{Only_privileged_users_can_view_log_or_config_files} = "Seuls les utilisateurs privil�gi�s peuvent voir les fichiers de journal ou les fichiers de configuration.";
$Lang{Only_privileged_users_can_view_log_files} = "Seuls les utilisateurs privil�gi�s peuvent voir les fichiers de journal.";
$Lang{Only_privileged_users_can_view_email_summaries} = "Seuls les utilisateurs privil�gi�s peuvent voir les compte-rendus des courriels.";
$Lang{Only_privileged_users_can_browse_backup_files} = "Seuls les utilisateurs privil�gi�s peuvent parcourir les fichiers de sauvegarde"
                 . " pour l'h�te \${EscHTML(\$In{host})}.";
$Lang{Empty_host_name} = "Nom d\'h�te vide.";
$Lang{Directory___EscHTML} = "Le r�pertoire \${EscHTML(\"\$TopDir/pc/\$host/\$num\")}"
		    . " est vide";
$Lang{Can_t_browse_bad_directory_name2} = "Ne peut pas parcourir "
	            . " \${EscHTML(\$relDir)} : mauvais nom de r�pertoire";
$Lang{Only_privileged_users_can_restore_backup_files} = "Seuls les utilisateurs privil�gi�s peuvent restaurer "
                . " des fichiers de sauvegarde pour l\'h�te \${EscHTML(\$In{host})}.";
$Lang{Bad_host_name} = "Mauvais nom d\'h�te \${EscHTML(\$host)}";
$Lang{You_haven_t_selected_any_files__please_go_Back_to} = "Vous n\'avez s�lectionn� aucun fichier ; "
    . "vous pouvez revenir en arri�re pour s�lectionner des fichiers.";
$Lang{You_haven_t_selected_any_hosts} = "Vous n\'avez s�lectionn� aucun h�te ; veuillez retourner � la page pr�c�dente pour"
                . " faire la s�lection d\'un h�te.";
$Lang{Nice_try__but_you_can_t_put} = "Bien tent�, mais vous ne pouvez pas mettre \'..\' dans un nom de fichier.";
$Lang{Host__doesn_t_exist} = "L'h�te \${EscHTML(\$In{hostDest})} n\'existe pas.";
$Lang{You_don_t_have_permission_to_restore_onto_host} = "Vous n\'avez pas la permission de restaurer sur l\'h�te"
		    . " \${EscHTML(\$In{hostDest})}";
$Lang{Can_t_open_create__openPath} = "Ne peut pas ouvrir/cr�er "
		. "\${EscHTML(\"\$openPath\")}";
$Lang{Only_privileged_users_can_restore_backup_files2} = "Seuls les utilisateurs privil�gi�s peuvent restaurer"
                . " des fichiers de sauvegarde pour l\'h�te \${EscHTML(\$host)}.";
$Lang{Empty_host_name} = "Nom d\'h�te vide";
$Lang{Unknown_host_or_user} = "\${EscHTML(\$host)}, h�te ou utilisateur inconnu.";
$Lang{Only_privileged_users_can_view_information_about} = "Seuls les utilisateurs privil�gi�s peuvent acc�der aux "
                . " informations sur l\'h�te \${EscHTML(\$host)}." ;
$Lang{Only_privileged_users_can_view_archive_information} = "Seuls les utilisateurs privil�gi�s peuvent voir les informations d'archivage.";
$Lang{Only_privileged_users_can_view_restore_information} = "Seuls les utilisateurs privil�gi�s peuvent restaurer des informations.";
$Lang{Restore_number__num_for_host__does_not_exist} = "La restauration num�ro \$num de l\'h�te \${EscHTML(\$host)} n\'existe pas";

$Lang{Archive_number__num_for_host__does_not_exist} = "L\'archive n�\$num pour l\'h�te \${EscHTML(\$host)} n\'existe pas.";

$Lang{Can_t_find_IP_address_for} = "Ne peut pas trouver d\'adresse IP pour \${EscHTML(\$host)}";
$Lang{host_is_a_DHCP_host} = <<EOF;
L\'h�te est un serveur DHCP, et je ne connais pas son adresse IP. J\'ai 
v�rifi� le nom netbios de \$ENV{REMOTE_ADDR}\$tryIP, et j\'ai trouv� que 
cette machine n\'est pas \$host.
<p>
Tant que je ne verrai pas \$host � une adresse DHCP particuli�re, vous 
ne pourrez d�marrer cette requ�te que depuis la machine elle m�me.
EOF

# ------------------------------------
# !! Server Mesg !!
# ------------------------------------

$Lang{Backup_requested_on_DHCP__host} = "Demande de sauvegarde sur l\'h�te \$host (\$In{hostIP}) par"
		                      . " \$User depuis \$ENV{REMOTE_ADDR}";
$Lang{Backup_requested_on__host_by__User} = "Sauvegarde demand�e sur \$host par \$User";
$Lang{Backup_stopped_dequeued_on__host_by__User} = "Sauvegarde arr�t�e/d�programm�e pour \$host par \$User";
$Lang{Restore_requested_to_host__hostDest__backup___num} = "Restauration demand�e pour l\'h�te \$hostDest, "
             . "sauvegarde n�\$num, par \$User depuis \$ENV{REMOTE_ADDR}";
$Lang{Archive_requested} = "Archivage demand� par \$User de \$ENV{REMOTE_ADDR}";

# -------------------------------------------------
# ------- Stuff that was forgotten ----------------
# -------------------------------------------------

$Lang{Status} = "�tat";
$Lang{PC_Summary} = "Bilan des machines";
$Lang{LOG_file} = "Fichier journal";
$Lang{LOG_files} = "Fichiers journaux";
$Lang{Old_LOGs} = "Vieux journaux";
$Lang{Email_summary} = "R�sum� des courriels";
$Lang{Config_file} = "Fichier de configuration";
# $Lang{Hosts_file} = "Fichiers des h�tes";
$Lang{Current_queues} = "Files actuelles";
$Lang{Documentation} = "Documentation";

#$Lang{Host_or_User_name} = "<small>H�te ou Nom d\'utilisateur:</small>";
$Lang{Go} = "Chercher";
$Lang{Hosts} = "H�tes";
$Lang{Select_a_host} = "Choisissez un h�te...";

$Lang{There_have_been_no_archives} = "<h2> Il n'y a pas d'archives </h2>\n";
$Lang{This_PC_has_never_been_backed_up} = "<h2> Cette machine n'a jamais �t� sauvegard�e !! </h2>\n";
$Lang{This_PC_is_used_by} = "<li>Cette machine est utilis�e par \${UserLink(\$user)}";

$Lang{Extracting_only_Errors} = "(Extraction des erreurs seulement)";
$Lang{XferLOG} = "JournalXfer";
$Lang{Errors}  = "Erreurs";

# ------------
$Lang{Last_email_sent_to__was_at___subject} = <<EOF;
<li>Le dernier courriel envoy� � \${UserLink(\$user)} le \$mailTime, avait comme sujet "\$subj".
EOF
# ------------
$Lang{The_command_cmd_is_currently_running_for_started} = <<EOF;
<li>La commande \$cmd s\'ex�cute actuellement sur \$host, d�marr�e le \$startTime.
EOF

# -----------
$Lang{Host_host_is_queued_on_the_background_queue_will_be_backed_up_soon} = <<EOF;
<li>L\'h�te \$host se trouve dans la liste d\'attente d\'arri�re plan (il sera sauvegard� bient�t).
EOF

# ----------
$Lang{Host_host_is_queued_on_the_user_queue__will_be_backed_up_soon} = <<EOF;
<li>L\'h�te \$host se trouve dans la liste d\'attente utilisateur (il sera sauvegard� bient�t).
EOF

# ---------
$Lang{A_command_for_host_is_on_the_command_queue_will_run_soon} = <<EOF;
<li>Une commande pour l\'h�te \$host est dans la liste d\'attente des commandes (sera lanc�e bient�t).
EOF

# --------
$Lang{Last_status_is_state_StatusHost_state_reason_as_of_startTime} = <<EOF;
<li>L\'�tat courant est \"\$Lang->{\$StatusHost{state}}\"\$reason depuis \$startTime.
EOF

# --------
$Lang{Last_error_is____EscHTML_StatusHost_error} = <<EOF;
<li>La derni�re erreur est \"\${EscHTML(\$StatusHost{error})}\".
EOF

# ------
$Lang{Pings_to_host_have_failed_StatusHost_deadCnt__consecutive_times} = <<EOF;
<li>Les pings vers \$host ont �chou� \$StatusHost{deadCnt} fois cons�cutives.
EOF

# -----
$Lang{Prior_to_that__pings} = "Avant cela, les pings";

# -----
$Lang{priorStr_to_host_have_succeeded_StatusHostaliveCnt_consecutive_times} = <<EOF;
<li>Les \$priorStr vers \$host ont r�ussi \$StatusHost{aliveCnt} 
            fois cons�cutives.
EOF

$Lang{Because__host_has_been_on_the_network_at_least__Conf_BlackoutGoodCnt_consecutive_times___} = <<EOF;
<li>\$host a �t� pr�sent sur le r�seau au moins \$Conf{BlackoutGoodCnt}
fois cons�cutives, il ne sera donc pas sauvegard� de \$blackoutStr.
EOF

$Lang{__time0_to__time1_on__days} = "\$t0 � \$t1 pendant \$days";

$Lang{Backups_are_deferred_for_hours_hours_change_this_number} = <<EOF;
<li>Les sauvegardes sont report�es pour \$hours heures
(<a href=\"\$MyURL?action=Stop_Dequeue_Backup&host=\$host\">changer ce nombre</a>).
EOF

$Lang{tryIP} = " et \$StatusHost{dhcpHostIP}";

# $Lang{Host_Inhost} = "H�te \$In{host}";

$Lang{checkAll} = <<EOF;
<tr><td class="fviewborder">
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;Tout s�lectionner
</td><td colspan="5" align="center" class="fviewborder">
<input type="submit" name="Submit" value="Restaurer les fichiers s�lectionn�s">
</td></tr>
EOF

$Lang{checkAllHosts} = <<EOF;
<tr><td class="fviewborder">
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;Tout s�lectionner
</td><td colspan="2" align="center" class="fviewborder">
<input type="submit" name="Submit" value="Archiver les machines s�lectionn�es">
</td></tr>
EOF

$Lang{fileHeader} = <<EOF;
    <tr class="fviewheader"><td align=center> Nom</td>
       <td align="center"> Type</td>
       <td align="center"> Mode</td>
       <td align="center"> n�</td>
       <td align="center"> Taille</td>
       <td align="center"> Date de modification</td>
    </tr>
EOF

$Lang{Home} = "Accueil";
$Lang{Browse} = "Explorer les sauvegardes";
$Lang{Last_bad_XferLOG} = "Bilan des derniers transferts �chou�s";
$Lang{Last_bad_XferLOG_errors_only} = "Bilan des derniers transferts �chou�s (erreurs seulement)";

$Lang{This_display_is_merged_with_backup} = <<EOF;
<li> Cet affichage est fusionn� avec la sauvegarde n�\$numF, la plus r�cente copie int�grale.
EOF

$Lang{Visit_this_directory_in_backup} = <<EOF;
<li> Choisissez la sauvegarde que vous d�sirez voir : <select onChange="window.location=this.value">\$otherDirs </select>
EOF

$Lang{Restore_Summary} = <<EOF;
\${h2("R�sum� de la restauration")}
<p>
Cliquer sur le num�ro de restauration pour plus de d�tails.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Sauvegarde n� </td>
    <td align="center"> R�sultat </td>
    <td align="right"> Date de d�part</td>
    <td align="right"> Dur�e (min)</td>
    <td align="right"> Nb fichiers </td>
    <td align="right"> Taille (Mo) </td>
    <td align="right"> Nb errs tar </td>
    <td align="right"> Nb errs trans </td>
</tr>
\$restoreStr
</table>
<p>
EOF

$Lang{Archive_Summary} = <<EOF;
\${h2("R�sum� de l'archive")}
<p>
Cliquez sur le num�ro de l'archive pour plus de d�tails.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> No. Archive </td>
    <td align="center">R�sultat</td>
    <td align="right">Date d�but</td>
    <td align="right">Dur�e (min)</td>
</tr>
\$ArchiveStr
</table>
<p>
EOF

$Lang{BackupPC__Documentation} = "BackupPC: Documentation";

$Lang{No} = "non";
$Lang{Yes} = "oui";

$Lang{The_directory_is_empty} = <<EOF;
<tr><td bgcolor="#ffffff">Le r�pertoire \$dirDisplay est vide
</td></tr>
EOF

#$Lang{on} = "actif";
$Lang{off} = "inactif";

$Lang{backupType_full}    = "compl�te";
$Lang{backupType_incr}    = "incr�mentielle";
$Lang{backupType_active}  = "active";
$Lang{backupType_partial} = "partielle";

$Lang{failed} = "�chec";
$Lang{success} = "succ�s";
$Lang{and} = "et";

# ------
# Hosts states and reasons
$Lang{Status_idle} = "inactif";
$Lang{Status_backup_starting} = "d�but de la sauvegarde";
$Lang{Status_backup_in_progress} = "sauvegarde en cours";
$Lang{Status_restore_starting} = "d�but de la restauration";
$Lang{Status_restore_in_progress} = "restauration en cours";
$Lang{Status_admin_pending} = "en attente de l'�dition de liens";
$Lang{Status_admin_running} = "�dition de liens en cours";

$Lang{Reason_backup_done}    = "sauvegarde termin�e";
$Lang{Reason_restore_done}   = "restauration termin�e";
$Lang{Reason_archive_done}   = "archivage termin�";
$Lang{Reason_nothing_to_do}  = "rien � faire";
$Lang{Reason_backup_failed}  = "la sauvegarde a �chou�";
$Lang{Reason_restore_failed} = "la restauration a �chou�";
$Lang{Reason_archive_failed} = "l'archivage a �chou�";
$Lang{Reason_no_ping}        = "pas de ping";
$Lang{Reason_backup_canceled_by_user}  = "sauvegarde annul�e par l'utilisateur";
$Lang{Reason_restore_canceled_by_user} = "restauration annul�e par l'utilisateur";
$Lang{Reason_archive_canceled_by_user} = "archivage annul� par l'utilisateur";
$Lang{Disabled_OnlyManualBackups}  = "auto d�sactiv�";  
$Lang{Disabled_AllBackupsDisabled} = "d�sactiv�";                  

# ---------
# Email messages

# No backup ever
$Lang{EMailNoBackupEverSubj} = "BackupPC: aucune sauvegarde de \$host n'a r�ussi";
$Lang{EMailNoBackupEverMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
$userName,

Notre logiciel de copies de s�curit� n'a jamais r�ussi �
effectuer la sauvegarde de votre ordinateur ($host). Les sauvegardes
devraient normalement survenir lorsque votre ordinateur est connect�
au r�seau. Vous devriez contacter le responsable informatique si :

  - Votre ordinateur est r�guli�rement connect� au r�seau, ce qui
    signifie qu'il y aurait un probl�me de configuration
    emp�chant les sauvegardes de s'effectuer.

  - Vous ne voulez pas qu'il y ait de sauvegardes de
    votre ordinateur ni ne voulez recevoir d'autres messages
    comme celui-ci.

Dans le cas contraire, veuillez vous assurer d�s que possible que votre 
ordinateur est correctement connect� au r�seau.

Merci de votre attention,
BackupPC G�nie
http://backuppc.sourceforge.net
EOF

# No recent backup
$Lang{EMailNoBackupRecentSubj} = "BackupPC: aucune sauvegarde r�cente de \$host";
$Lang{EMailNoBackupRecentMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
$userName,

Aucune sauvegarde de votre ordinateur n'a �t� effectu�e depuis $days
jours. $numBackups sauvegardes ont �t�s effectu�es du $firstTime
jusqu'� il y a $days jours. Les sauvegardes devraient normalement
survenir lorsque votre ordinateur est connect� au r�seau.

Si votre ordinateur a effectivement �t� connect� au r�seau plus de 
quelques heures durant les derniers $days jours, vous devriez 
contacter votre responsable informatique pour savoir pourquoi les 
sauvegardes ne s'effectuent pas correctement.

Autrement, si vous �tes en dehors du bureau, il n'y a pas d'autre
chose que vous pouvez faire, � part faire des copies de vos fichiers
importants sur d'autres medias. Vous devez r�aliser que tout fichier cr�e
ou modifi� durant les $days derniers jours (incluant les courriels et
les fichiers attach�s) ne pourra pas �tre restaur� si un probl�me survient
avec votre ordinateur.

Merci de votre attention,
BackupPC G�nie
http://backuppc.sourceforge.net
EOF

# Old Outlook files
$Lang{EMailOutlookBackupSubj} = "BackupPC: Les fichiers de Outlook sur \$host doivent �tre sauvegard�s";
$Lang{EMailOutlookBackupMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
$userName,

Les fichiers Outlook sur votre ordinateur n'ont $howLong. Ces fichiers
contiennent tous vos courriels, fichiers attach�s, carnets d'adresses et
calendriers. $numBackups sauvegardes ont �t�s effectu�es du $firstTime
au $lastTime.  Par contre, Outlook bloque ses fichiers lorsqu'il est
ouvert, ce qui emp�che de les sauvegarder.

Il est recommand� d'effectuer une sauvegarde de vos fichiers Outlook
quand vous serez connect� au r�seau en quittant Outlook et toute autre
application, et en visitant ce lien avec votre navigateur web:

    $CgiURL?host=$host               

Choisissez "D�marrer la sauvegarde incr�mentielle" deux fois afin
d'effectuer une nouvelle sauvegarde. Vous pouvez ensuite choisir
"Retourner � la page de $host" et appuyer sur "Recharger" dans votre
navigateur avec de v�rifier le bon fonctionnement de la sauvegarde. La
sauvegarde devrait prendre quelques minutes � s'effectuer.

Merci de votre attention,
BackupPC G�nie
http://backuppc.sourceforge.net
EOF

$Lang{howLong_not_been_backed_up} = "jamais �t� sauvegard�s";
$Lang{howLong_not_been_backed_up_for_days_days} = "pas �t� sauvegard�s depuis \$days jours";

#######################################################################
# RSS strings
#######################################################################
$Lang{RSS_Doc_Title}       = "BackupPC Server";
$Lang{RSS_Doc_Description} = "RSS feed for BackupPC";
$Lang{RSS_Host_Summary}    = <<EOF;
Nb compl�tes : \$fullCnt;
Compl�tes �ge (jours) : \$fullAge;
Compl�tes Taille (Go) : \$fullSize;
Vitesse (Mo/s) : \$fullRate;
Nb incr�mentielles : \$incrCnt;
Incr�mentielles �ge (jours) : \$incrAge;
�tat actuel : \$host_state;
Derni�re tentative : \$host_last_attempt;
EOF

#######################################################################
# Configuration editor strings
#######################################################################

$Lang{Only_privileged_users_can_edit_config_files} = "Seuls les utilisateurs privil�gi�s peuvent modifier les param�tres de configuration.";
$Lang{CfgEdit_Edit_Config} = "Modifier la configuration";
$Lang{CfgEdit_Edit_Hosts}  = "Modifier les machines";

$Lang{CfgEdit_Title_Server} = "Serveur";
$Lang{CfgEdit_Title_General_Parameters} = "Param�tres g�n�raux";
$Lang{CfgEdit_Title_Wakeup_Schedule} = "Horaire des r�veils";
$Lang{CfgEdit_Title_Concurrent_Jobs} = "T�ches concurrentes";
$Lang{CfgEdit_Title_Pool_Filesystem_Limits} = "Limites du syst�me de fichiers";
$Lang{CfgEdit_Title_Other_Parameters} = "Autres param�tres";
$Lang{CfgEdit_Title_Remote_Apache_Settings} = "Options d'Apache � distance";
$Lang{CfgEdit_Title_Program_Paths} = "Chemins des programmes";
$Lang{CfgEdit_Title_Install_Paths} = "Chemins d'installation";
$Lang{CfgEdit_Title_Email} = "Courriel";
$Lang{CfgEdit_Title_Email_settings} = "Param�tres de courriel";
$Lang{CfgEdit_Title_Email_User_Messages} = "Messages des usagers par courriel";
$Lang{CfgEdit_Title_CGI} = "CGI";
$Lang{CfgEdit_Title_Admin_Privileges} = "Privil�ges administrateur";
$Lang{CfgEdit_Title_Page_Rendering} = "Rendu des pages";
$Lang{CfgEdit_Title_Paths} = "Chemins";
$Lang{CfgEdit_Title_User_URLs} = "URL des usagers";
$Lang{CfgEdit_Title_User_Config_Editing} = "Modifications des configurations des usagers";
$Lang{CfgEdit_Title_Xfer} = "Xfer";
$Lang{CfgEdit_Title_Xfer_Settings} = "Param�tres des transfers";
$Lang{CfgEdit_Title_Ftp_Settings} = "Param�tres de FTP";
$Lang{CfgEdit_Title_Smb_Settings} = "Param�tres de Smb";
$Lang{CfgEdit_Title_Tar_Settings} = "Param�tres de Tar";
$Lang{CfgEdit_Title_Rsync_Settings} = "Param�tres de Rsync";
$Lang{CfgEdit_Title_Rsyncd_Settings} = "Param�tres de Rsyncd";
$Lang{CfgEdit_Title_Archive_Settings} = "Param�tres d'archivage";
$Lang{CfgEdit_Title_Include_Exclude} = "Inclure/Exclure";
$Lang{CfgEdit_Title_Smb_Paths_Commands} = "Chemins/Commandes Smb";
$Lang{CfgEdit_Title_Tar_Paths_Commands} = "Chemins/Commandes Tar";
$Lang{CfgEdit_Title_Rsync_Paths_Commands_Args} = "Chemins/Commandes/Args Rsync";
$Lang{CfgEdit_Title_Rsyncd_Port_Args} = "Port/Args Rsyncd";
$Lang{CfgEdit_Title_Archive_Paths_Commands} = "Chemins/Commandes d'archivage";
$Lang{CfgEdit_Title_Schedule} = "Horaire";
$Lang{CfgEdit_Title_Full_Backups} = "Sauvegardes compl�tes";
$Lang{CfgEdit_Title_Incremental_Backups} = "Sauvegardes incr�mentielles";
$Lang{CfgEdit_Title_Blackouts} = "Suspension";
$Lang{CfgEdit_Title_Other} = "Divers";
$Lang{CfgEdit_Title_Backup_Settings} = "Param�tres de sauvegarde";
$Lang{CfgEdit_Title_Client_Lookup} = "Consultation des clients";
$Lang{CfgEdit_Title_User_Commands} = "Commandes des usagers";
$Lang{CfgEdit_Title_Hosts} = "Machines";

$Lang{CfgEdit_Hosts_Comment} = <<EOF;
Pour ajouter une machine, choisissez Ajouter et entrez ensuite le nom. Pour faire
une copie de la configuration d'une autre machine, entrer le nom de la machine
comme NOUVEAU=ACOPIER. Cela va �craser toute configuration par d�faut pour
cette machine. Vous pouvez aussi faire cela pour une machine existante.
Pour d�truire une machine, cliquer sur le bouton D�truire. Les ajouts, 
destructions et modifications ne prennent effet que lorsque que vous cliquez 
sur le bouton Sauvegarder. Aucune des sauvegardes des machines ne sera
d�truite, donc si vous effacez une machine par erreur, cr�ez-la � nouveau. Pour
d�truire les sauvegardes d'une machine, vous devez effacer les fichiers 
manuellement dans \$topDir/pc/HOST
EOF

$Lang{CfgEdit_Header_Main} = <<EOF;
\${h1("�diteur de configuration")}
EOF

$Lang{CfgEdit_Header_Host} = <<EOF;
\${h1("�diteur de la configuration de \$host")}
<p>
Note: Cochez �craser pour modifier une valeur sp�cifique � cette machine.
<p>
EOF

$Lang{CfgEdit_Button_Save}     = "Sauvegarder";
$Lang{CfgEdit_Button_Insert}   = "Ins�rer";
$Lang{CfgEdit_Button_Delete}   = "D�truire";
$Lang{CfgEdit_Button_Add}      = "Ajouter";
$Lang{CfgEdit_Button_Override} = "�craser";
$Lang{CfgEdit_Button_New_Key}  = "Nouvelle cl�";
$Lang{CfgEdit_Button_New_Share} = "New ShareName or '*'";

$Lang{CfgEdit_Error_No_Save}
            = "Erreur: Pas de sauvegarde � cause d'erreurs.";
$Lang{CfgEdit_Error__must_be_an_integer}
            = "Erreur: \$var doit �tre un nombre entier";
$Lang{CfgEdit_Error__must_be_real_valued_number}
            = "Erreur: \$var doit �tre un nombre r�el";
$Lang{CfgEdit_Error__entry__must_be_an_integer}
            = "Erreur: l'entr�e \$k de \$var doit �tre un nombre entier";
$Lang{CfgEdit_Error__entry__must_be_real_valued_number}
            = "Erreur: l'entr�e \$k de \$var doit �tre un nombre r�el";
$Lang{CfgEdit_Error__must_be_executable_program}
            = "Erreur: \$var doit �tre un chemin ex�cutable";
$Lang{CfgEdit_Error__must_be_valid_option}
            = "Erreur: \$var doit �tre une option valide";
$Lang{CfgEdit_Error_Copy_host_does_not_exist}
            = "La machine \$copyHost ne peut �tre copi�e, car elle n'existe pas ; cr�ation d'une machine nomm�e \$fullHost.  D�truisez cette machine si ce n'est pas ce que vous vouliez.";

$Lang{CfgEdit_Log_Copy_host_config}
            = "\$User a copi� la config de \$fromHost � \$host\n";
$Lang{CfgEdit_Log_Delete_param}
            = "\$User a d�truit \$p de \$conf\n";
$Lang{CfgEdit_Log_Add_param_value}
            = "\$User a ajout� \$p � \$conf en fixant sa valeur � \$value\n";
$Lang{CfgEdit_Log_Change_param_value}
            = "\$User a chang� \$p dans \$conf de \$valueOld � \$valueNew\n";
$Lang{CfgEdit_Log_Host_Delete}
            = "\$User a d�truit la machine \$host\n";
$Lang{CfgEdit_Log_Host_Change}
            = "\$User a chang� \$key de \$valueOld � \$valueNew sur \$host\n";
$Lang{CfgEdit_Log_Host_Add}
            = "\$User a jout� la machine \$host: \$value\n";
  
#end of lang_fr.pm
