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

$Lang{Start_Archive} = "Démarrer l'archivage";
$Lang{Stop_Dequeue_Archive} = "Arrêt/Mise en attente de l'archivage";
$Lang{Start_Full_Backup} = "Démarrer la sauvegarde complète";
$Lang{Start_Incr_Backup} = "Démarrer la sauvegarde incrémentielle";
$Lang{Stop_Dequeue_Backup} = "Arrêter/annuler la sauvegarde";
$Lang{Restore} = "Restaurer";

$Lang{Type_full} = "complète";
$Lang{Type_incr} = "incrémentielle";

# -----

$Lang{Only_privileged_users_can_view_admin_options} = "Seuls les utilisateurs privilégiés peuvent voir les options d'administration.";
$Lang{H_Admin_Options} = "BackupPC: Options d'administration";
$Lang{Admin_Options} = "Options d'administration";
$Lang{Admin_Options_Page} = <<EOF;
\${h1(qq{$Lang{Admin_Options}})}
<br>
\${h2("Contrôle du serveur")}
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
y ait une erreur de configuration. Veuillez contacter votre administrateur système.
EOF

$Lang{Admin_Start_Server} = <<EOF;
\${h1(qq{$Lang{Unable_to_connect_to_BackupPC_server}})}
<form action="\$MyURL" method="get">
Le serveur BackupPC sur <tt>\$Conf{ServerHost}</tt>, port <tt>\$Conf{ServerPort}</tt>
n'est pas en fonction (vous l'avez peut-être arrêté, ou vous ne l'avez pas encore démarré).<br>
Voulez-vous le démarrer ?
<input type="hidden" name="action" value="startServer">
<input type="submit" value="Démarrer le serveur" name="ignore">
</form>
EOF

# -----

$Lang{H_BackupPC_Server_Status} = "État du serveur BackupPC";

$Lang{BackupPC_Server_Status_General_Info}= <<EOF;
\${h2(\"Informations générales du serveur\")}

<ul>
<li> Le PID du serveur est \$Info{pid}, sur l\'hôte \$Conf{ServerHost},
     version \$Info{Version}, démarré le \$serverStartTime.
<li> Ce rapport a été généré le \$now.
<li> La configuration a été chargée pour la dernière fois à \$configLoadTime.
<li> La prochaine file d\'attente sera remplie à \$nextWakeupTime.
<li> Autres infos:
    <ul>
        <li>\$numBgQueue demandes de sauvegardes en attente depuis le dernier réveil automatique,
        <li>\$numUserQueue requêtes de sauvegardes utilisateur en attente,
        <li>\$numCmdQueue requêtes de commandes en attente,
        \$poolInfo
        <li>L\'espace de stockage a été récemment rempli à \$Info{DUlastValue}%
            (\$DUlastTime), le maximum aujourd\'hui a été de \$Info{DUDailyMax}% (\$DUmaxTime)
            et hier le maximum était de \$Info{DUDailyMaxPrev}%.
    </ul>
</ul>
EOF

$Lang{BackupPC_Server_Status} = <<EOF;
\${h1(qq{$Lang{H_BackupPC_Server_Status}})}

<p>
\${h2("Travaux en cours d'exécution")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td> Hôte </td>
    <td> Type </td>
    <td> Utilisateur </td>
    <td> Date de départ </td>
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

\${h2("Échecs qui demandent de l'attention")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> Hôte </td>
    <td align="center"> Type </td>
    <td align="center"> Utilisateur </td>
    <td align="center"> Dernier essai </td>
    <td align="center"> Détails </td>
    <td align="center"> Date d\'erreur </td>
    <td> Dernière erreur (autre que pas de ping) </td></tr>
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
<li>Ce statut a été généré le \$now.
<li>L\'espace de stockage a été récemment rempli à \$Info{DUlastValue}%
    (\$DUlastTime), le maximum aujourd\'hui a été de \$Info{DUDailyMax}% (\$DUmaxTime)
    et hier le maximum était de \$Info{DUDailyMaxPrev}%.
</ul>
</p>

\${h2("Hôtes avec de bonnes sauvegardes")}
<p>
Il y a \$hostCntGood hôtes ayant été sauvegardés, pour un total de :
<ul>
<li> \$fullTot sauvegardes complètes de tailles cumulées de \${fullSizeTot} Go
     (précédant la mise en commun et la compression),
<li> \$incrTot sauvegardes incrémentielles de tailles cumulées de \${incrSizeTot} Go
     (précédant la mise en commun et la compression).
</ul>
</p>
<table class="sortable" id="host_summary_backups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> Hôte </td>
    <td align="center"> Utilisateur </td>
    <td align="center"> Nb complètes </td>
    <td align="center"> Complètes Âge (jours) </td>
    <td align="center"> Complètes Taille (Go) </td>
    <td align="center"> Vitesse (Mo/s) </td>
    <td align="center"> Nb incrémentielles </td>
    <td align="center"> Incrémentielles Âge (jours) </td>
    <td align="center"> Dernière sauvegarde (jours) </td>
    <td align="center"> État actuel </td>
    <td align="center"> Nb erreurs transfert </td>
    <td align="center"> Dernière tentative </td></tr>
\$strGood
</table>
<br><br>
\${h2("Hôtes sans sauvegardes")}
<p>
Il y a \$hostCntNone hôtes sans sauvegardes.
<p>
<table class="sortable" id="host_summary_nobackups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> Hôte </td>
    <td align="center"> Utilisateur </td>
    <td align="center"> Nb complètes </td>
    <td align="center"> Complètes Âge (jours) </td>
    <td align="center"> Complètes Taille (Go) </td>
    <td align="center"> Vitesse (Mo/s) </td>
    <td align="center"> Nb incrémentielles </td>
    <td align="center"> Incrémentielles Âge (jours) </td>
    <td align="center"> Dernière sauvegarde (jours) </td>
    <td align="center"> État actuel </td>
    <td align="center"> Nb erreurs transfert </td>
    <td align="center"> Dernière tentative </td></tr>
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

Il y a \$hostCntGood hôtes qui ont été sauvegardés, représentant \${fullSizeTot} Go
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
Prêt à démarrer l'archivage des hôtes suivants
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
    <td colspan=2><input type="submit" value="Démarrer l'archivage" name="ignore"></td>
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
    <td>Pourcentage des données de parité (0 = désactivé, 5 = typique)</td>
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
        <li>La mise en commun est constituée de \$info->{"\${name}FileCnt"} fichiers
            et \$info->{"\${name}DirCnt"} répertoires représentant \${poolSize} Go (depuis le \$poolTime),
        <li>Le hachage de mise en commun des fichiers donne \$info->{"\${name}FileCntRep"} fichiers répétés
            avec comme plus longue chaîne \$info->{"\${name}FileRepMax"},
        <li>Le nettoyage nocturne a effacé \$info->{"\${name}FileCntRm"} fichiers, soit
            \${poolRmSize} Go (vers \$poolTime),
EOF

# -----------------------------------
$Lang{BackupPC__Backup_Requested_on__host} = "BackupPC: Sauvegarde demandée sur \$host";
# --------------------------------
$Lang{REPLY_FROM_SERVER} = <<EOF;
\${h1(\$str)}
<p>
La réponse du serveur a été : \$reply
<p>
Retourner à la page d\'accueil de <a href="\$MyURL?host=\$host">\$host</a>.
EOF
# --------------------------------
$Lang{BackupPC__Start_Backup_Confirm_on__host} = "BackupPC: Confirmation du démarrage de la sauvegarde de \$host";
# --------------------------------
$Lang{Are_you_sure_start} = <<EOF;
\${h1("Êtes-vous certain ?")}
<p>
Vous allez bientôt démarrer une sauvegarde \$type depuis \$host.

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
$Lang{BackupPC__Stop_Backup_Confirm_on__host} = "BackupPC: Confirmer l\'arrêt de la sauvegarde sur \$host";
# --------------------------------
$Lang{Are_you_sure_stop} = <<EOF;

\${h1("Êtes-vous certain ?")}

<p>
Vous êtes sur le point d\'arrêter/supprimer de la file les sauvegardes de \$host;

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host"   value="\$host">
<input type="hidden" name="doit"   value="1">
<input type="hidden" name="action" value="">
En outre, prière de ne pas démarrer d\'autre sauvegarde pendant
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
$Lang{Only_privileged_users_can_view_queues_} = "Seuls les utilisateurs privilégiés peuvent voir les files.";
# --------------------------------
$Lang{Only_privileged_users_can_archive} = "Seuls les utilisateurs privilégiés peuvent archiver.";
# --------------------------------
$Lang{BackupPC__Queue_Summary} = "BackupPC: Résumé de la file";
# --------------------------------
$Lang{Backup_Queue_Summary} = <<EOF;
\${h1("Résumé de la file")}
<br><br>
\${h2("Résumé des files des utilisateurs")}
<p>
Les demandes utilisateurs suivantes sont actuellement en attente :
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Hôte </td>
    <td> Temps Requis </td>
    <td> Utilisateur </td></tr>
\$strUser
</table>
<br><br>

\${h2("Résumé de la file en arrière plan")}
<p>
Les demandes en arrière plan suivantes sont actuellement en attente :
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Hôte </td>
    <td> Temps requis </td>
    <td> Utilisateur </td></tr>
\$strBg
</table>
<br><br>
\${h2("Résumé de la file d\'attente des commandes")}
<p>
Les demandes de commande suivantes sont actuellement en attente :
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Hôtes </td>
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
Contenu du fichier <tt>\$file</tt>, modifié le \$mtimeStr \$comment
EOF

# --------------------------------
$Lang{skipped__skipped_lines} = "[ \$skipped lignes sautées ]\n";
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
\${h1("Résumé des courriels récents (du plus récent au plus vieux)")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Destinataire </td>
    <td align="center"> Hôte </td>
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
Vous avez sélectionné les fichiers/répertoires suivants depuis
le partage \$share, sauvegarde numéro \$num:
<ul>
\$fileListStr
</ul>
</p><p>
Vous avez trois choix pour restaurer ces fichiers/répertoires.
Veuillez sélectionner une des options suivantes.
</p>
\${h2("Option 1: Restauration directe")}
<p>
EOF

$Lang{Restore_Options_for__host_Option1} = <<EOF;
Vous pouvez démarrer une restauration de ces fichiers 
directement sur <b>\$directHost</b>.
</p><p>
<b>Attention:</b>
tous les fichiers correspondant à ceux que vous avez sélectionnés vont être écrasés !
</p>
<form action="\$MyURL" method="post" name="direct">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="3">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<table class="tableStnd" border="0">
<tr>
    <td>Restaure les fichiers vers l'hôte</td>
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
    <td>Restaurer les fichiers du répertoire<br>(relatif au partage)</td>
    <td valign="top"><input type="text" size="40" maxlength="256"
	value="\${EscHTML(\$pathHdr)}" name="pathHdr"></td>
</tr><tr>
    <td><input type="submit" value="Démarrer la restauration" name="ignore"></td>
</table>
</form>
EOF

$Lang{Restore_Options_for__host_Option1_disabled} = <<EOF;
La restauration directe a été désactivée pour l'hôte \${EscHTML(\$hostDest)}.
Veuillez choisir une autre option.
EOF

# ------------------------------
$Lang{Option_2__Download_Zip_archive} = <<EOF;
<p>
\${h2("Option 2: Télécharger une archive Zip")}
<p>
Vous pouvez télécharger une archive compressée (.zip) contenant tous les fichiers/répertoires que vous 
avez sélectionnés. Vous pouvez utiliser une application locale, comme Winzip, pour voir ou extraire n\'importe quel fichier.
</p><p>
<b>Attention:</b> en fonction des fichiers/répertoires que vous avez sélectionnés,
cette archive peut devenir très très volumineuse. Cela peut prendre plusieurs minutes pour créer
et transférer cette archive, et vous aurez besoin d\'assez d\'espace disque pour la stocker.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="2">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Faire l\'archive relative à
\${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(Autrement l\'archive contiendra les chemins complets).
<br>
<table class="tableStnd" border="0">
<tr>
    <td>Compression (0=désactivée, 1=rapide,...,9=meilleure)</td>
    <td><input type="text" size="6" value="5" name="compressLevel"></td>
</tr><tr>
    <td>Code page (e.g. cp866)</td>
    <td><input type="text" size="6" value="utf8" name="codePage"></td>
</tr>
</table>
<br>
<input type="submit" value="Télécharger le fichier Zip" name="ignore">
</form>
EOF


# ------------------------------

$Lang{Option_2__Download_Zip_archive2} = <<EOF;
<p>
\${h2("Option 2: Télécharger une archive Zip")}
<p>
Vous ne pouvez pas télécharger d'archive zip, car Archive::Zip n\'est pas
installé. 
Veuillez demander à votre administrateur système d\'installer 
Archive::Zip depuis <a href="http://www.cpan.org">www.cpan.org</a>.
</p>
EOF


# ------------------------------
$Lang{Option_3__Download_Zip_archive} = <<EOF;
\${h2("Option 3: Télécharger une archive tar")}
<p>
Vous pouvez télécharger une archive Tar contenant tous les fichiers/répertoires 
que vous avez sélectionnés. Vous pourrez alors utiliser une application locale, 
comme tar ou winzip pour voir ou extraire n\'importe quel fichier.
</p><p>
<b>Attention:</b> en fonction des fichiers/répertoires que vous avez sélectionnés,
cette archive peut devenir très très volumineuse.  Cela peut prendre plusieurs minutes
pour créer et transférer l\'archive, et vous aurez besoin d\'assez
d\'espace disque local pour la stocker.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="1">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Faire l\'archive relative à
\${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(Autrement l\'archive contiendra des chemins absolus).
<br>
<input type="submit" value="Télécharger le fichier Tar" name="ignore">
</form>
EOF


# ------------------------------
$Lang{Restore_Confirm_on__host} = "BackupPC: Confirmation de restauration sur \$host";

$Lang{Are_you_sure} = <<EOF;
\${h1("Êtes-vous sûr ?")}
<p>
Vous êtes sur le point de démarrer une restauration directement sur 
la machine \$In{hostDest}. Les fichiers suivants vont être restaurés 
dans le partage \$In{shareDest}, depuis la sauvegarde numéro \$num:
<p>
<table class="tableStnd" border>
<tr class="tableheader"><td>Fichier/Répertoire original</td><td>Va être restauré à</td></tr>
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
$Lang{Restore_Requested_on__hostDest} = "BackupPC: Restauration demandée sur \$hostDest";
$Lang{Reply_from_server_was___reply} = <<EOF;
\${h1(\$str)}
<p>
La réponse du serveur est : \$reply
<p>
Retourner à la page d\'accueil de <a href="\$MyURL?host=\$hostDest">\$hostDest </a>.
EOF

$Lang{BackupPC_Archive_Reply_from_server} = <<EOF;
\${h1(\$str)}
<p>
La réponse du serveur est : \$reply
EOF


# -------------------------
$Lang{Host__host_Backup_Summary} = "BackupPC: Résumé de la sauvegarde de l\'hôte \$host ";

$Lang{Host__host_Backup_Summary2} = <<EOF;
\${h1("Résumé de la sauvegarde de l\'hôte \$host ")}
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
\${h2("Résumé de la sauvegarde")}
<p>
Cliquer sur le numéro de l\'archive pour naviguer et restaurer les fichiers de sauvegarde.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> Sauvegarde n° </td>
    <td align="center"> Type </td>
    <td align="center"> Fusionnée </td> 
    <td align="center"> Niveau </td>
    <td align="center"> Date de démarrage </td>
    <td align="center"> Durée (min) </td>
    <td align="center"> Âge (jours) </td>
    <td align="center"> Chemin d\'accès de la sauvegarde sur le serveur </td>
</tr>
\$str
</table>
<p>

\$restoreStr
</p>
<br><br>
\${h2("Résumé des erreurs de transfert")}
<br><br>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Sauvegarde n° </td>
    <td align="center"> Type </td>
    <td align="center"> Voir </td>
    <td align="center"> Nb erreurs transfert </td>
    <td align="center"> Nb mauvais fichiers </td>
    <td align="center"> Nb mauvais partages </td>
    <td align="center"> Nb erreurs tar </td>
</tr>
\$errStr
</table>
<br><br>

\${h2("Récapitulatif de la taille des fichier et du nombre de réutilisations")}
<p>
Les fichiers existants sont ceux qui sont déjà sur le serveur; 
Les nouveaux fichiers sont ceux qui ont été ajoutés au serveur.
Les fichiers vides et les erreurs de SMB ne sont pas comptabilisés dans les fichiers nouveaux ou réutilisés.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="2" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> Totaux </td>
    <td align="center" colspan="2"> Fichiers existants </td>
    <td align="center" colspan="2"> Nouveaux fichiers </td>
</tr>
<tr class="tableheader">
    <td align="center"> Sauvegarde n° </td>
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
<br><br>

\${h2("Résumé de la compression")}
<p>
Performance de la compression pour les fichiers déjà sur le serveur et
récemment compressés.
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
    <td align="center"> Taille compressée (Mo) </td>
    <td align="center"> Compression </td>
    <td align="center"> Taille (Mo) </td>
    <td align="center"> Taille compressée (Mo) </td>
    <td align="center"> Compression </td>
</tr>
\$compStr
</table>
<br><br>
EOF

$Lang{Host__host_Archive_Summary} = "BackupPC: Résumé de l'archivage pour l'hôte \$host";
$Lang{Host__host_Archive_Summary2} = <<EOF;
\${h1("Résumé de l\'archivage pour l\'hôte \$host")}
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
<li> Vous naviguez dans la sauvegarde n°\$num, qui a commencé vers \$backupTime
        (il y a \$backupAge jours),
\$filledBackup
<li> Entrez le répertoire: <input type="text" name="dir" size="50" maxlength="4096" value="\${EscHTML(\$dir)}"> <input type="submit" value="\$Lang->{Go}" name="Submit">
<li> Cliquer sur un répertoire ci-dessous pour y naviguer,
<li> Cliquer sur un fichier ci-dessous pour le restaurer,
<li> Vous pouvez voir l'<a href="\$MyURL?action=dirHistory&host=\${EscURI(\$host)}&share=\$shareURI&dir=\$pathURI">historique</a> des différentes sauvegardes du répertoire courant.
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
$Lang{DirHistory_backup_for__host} = "BackupPC: Historique des sauvegardes du répertoire courant pour \$host";

#
# These two strings are used to build the links for directories and
# file versions.  Files are appended with a version number.
#
$Lang{DirHistory_dirLink}  = "rep";
$Lang{DirHistory_fileLink} = "v";

$Lang{DirHistory_for__host} = <<EOF;
\${h1("Historique des sauvegardes du répertoire courant pour \$host")}
<p>
Cette page montre toutes les version disponibles des fichiers sauvegardés pour le répertoire courant :
<ul>
<li> Cliquez sur un numéro de sauvegarde pour revenir à la navigation de sauvegarde,
<li> Cliquez sur un répertoire (\$Lang->{DirHistory_dirLink}) pour naviguer
     dans celui-ci.
<li> Cliquez sur une version d'un fichier (\$Lang->{DirHistory_fileLink}0,
     \$Lang->{DirHistory_fileLink}1, ...) pour le télécharger.
<li> Les fichiers avec des contenus identiques pour plusieurs sauvegardes ont 
     le même numéro de version.
<li> Les fichiers qui ne sont pas présents sur une sauvegarde en particulier 
     sont représentés par une boîte vide.
<li> Les fichiers montrés avec la même version peuvent avoir des attributs différents. 
     Choisissez le numéro de sauvegarde pour voir les attributs de fichiers.
</ul>

\${h2("Historique de \$dirDisplay")}

<br>
<table border cellspacing="2" cellpadding="3">
<tr class="fviewheader"><td>Numéro de sauvegarde</td>\$backupNumStr</tr>
<tr class="fviewheader"><td>Date</td>\$backupTimeStr</tr>
\$fileStr
</table>
EOF

# ------------------------------
$Lang{Restore___num_details_for__host} = "BackupPC: Détails de la restauration n°\$num pour \$host"; 

$Lang{Restore___num_details_for__host2} = <<EOF;
\${h1("Détails de la restauration n°\$num pour \$host")} 
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="90%">
<tr><td class="tableheader"> Numéro </td><td class="border"> \$Restores[\$i]{num} </td></tr>
<tr><td class="tableheader"> Demandée par </td><td class="border"> \$RestoreReq{user} </td></tr>
<tr><td class="tableheader"> Demandée à </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> Résultat </td><td class="border"> \$Restores[\$i]{result} </td></tr>
<tr><td class="tableheader"> Message d'erreur </td><td class="border"> \$Restores[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> Hôte source </td><td class="border"> \$RestoreReq{hostSrc} </td></tr>
<tr><td class="tableheader"> N° de sauvegarde </td><td class="border"> \$RestoreReq{num} </td></tr>
<tr><td class="tableheader"> Partition source </td><td class="border"> \$RestoreReq{shareSrc} </td></tr>
<tr><td class="tableheader"> Hôte de destination </td><td class="border"> \$RestoreReq{hostDest} </td></tr>
<tr><td class="tableheader"> Partition de destination </td><td class="border"> \$RestoreReq{shareDest} </td></tr>
<tr><td class="tableheader"> Début </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Durée </td><td class="border"> \$duration min </td></tr>
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
\${h1("Liste des Fichiers/Répertoires")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="100%">
<tr class="tableheader"><td>Fichier/répertoire original</td><td>Restauré vers</td></tr>
\$fileListStr
</table>
EOF

# ------------------------------
$Lang{Archive___num_details_for__host} = "BackupPC: Détails de l'archivage n°\$num pour \$host";

$Lang{Archive___num_details_for__host2 } = <<EOF;
\${h1("Détails de l'archivage n°\$num pour \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr><td class="tableheader"> Numéro </td><td class="border"> \$Archives[\$i]{num} </td></tr>
<tr><td class="tableheader"> Demandé par </td><td class="border"> \$ArchiveReq{user} </td></tr>
<tr><td class="tableheader"> Heure de demande </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> Résultat </td><td class="border"> \$Archives[\$i]{result} </td></tr>
<tr><td class="tableheader"> Message d'erreur </td><td class="border"> \$Archives[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> Heure de début </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Durée </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> Journal de transfert </td><td class="border">
<a href="\$MyURL?action=view&type=ArchiveLOG&num=\$Archives[\$i]{num}&host=\$host">Voir</a>,
<a href="\$MyURL?action=view&type=ArchiveErr&num=\$Archives[\$i]{num}&host=\$host">Erreurs</a>
</tr></tr>
</table>
<p>
\${h1("Liste de hôtes")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td>Host</td><td>Numéro de sauvegarde</td></tr>
\$HostListStr
</table>
EOF

# -----------------------------------
$Lang{Email_Summary} = "BackupPC: Résumé du courriel";

# -----------------------------------
#  !! ERROR messages !!
# -----------------------------------
$Lang{BackupPC__Lib__new_failed__check_apache_error_log} = "BackupPC::Lib->new a échoué: regardez le fichier error_log d\'apache\n";
$Lang{Wrong_user__my_userid_is___} =  
              "Mauvais utilisateur: mon userid est \$>, à la place de \$uid "
              . "(\$Conf{BackupPCUser})\n";
#$Lang{Only_privileged_users_can_view_PC_summaries} = "Seuls les utilisateurs privilégiés peuvent voir les résumés des machines.";
$Lang{Only_privileged_users_can_stop_or_start_backups} = 
                  "Seuls les utilisateurs privilégiés peuvent arrêter ou démarrer des sauvegardes sur "
                  . " \${EscHTML(\$host)}.";
$Lang{Invalid_number__num} = "Numéro invalide \${EscHTML(\$In{num})}";
$Lang{Unable_to_open__file__configuration_problem} = "Impossible d\'ouvrir \$file : problème de configuration ?";
$Lang{Only_privileged_users_can_view_log_or_config_files} = "Seuls les utilisateurs privilégiés peuvent voir les fichiers de journal ou les fichiers de configuration.";
$Lang{Only_privileged_users_can_view_log_files} = "Seuls les utilisateurs privilégiés peuvent voir les fichiers de journal.";
$Lang{Only_privileged_users_can_view_email_summaries} = "Seuls les utilisateurs privilégiés peuvent voir les compte-rendus des courriels.";
$Lang{Only_privileged_users_can_browse_backup_files} = "Seuls les utilisateurs privilégiés peuvent parcourir les fichiers de sauvegarde"
                 . " pour l'hôte \${EscHTML(\$In{host})}.";
$Lang{Empty_host_name} = "Nom d\'hôte vide.";
$Lang{Directory___EscHTML} = "Le répertoire \${EscHTML(\"\$TopDir/pc/\$host/\$num\")}"
		    . " est vide";
$Lang{Can_t_browse_bad_directory_name2} = "Ne peut pas parcourir "
	            . " \${EscHTML(\$relDir)} : mauvais nom de répertoire";
$Lang{Only_privileged_users_can_restore_backup_files} = "Seuls les utilisateurs privilégiés peuvent restaurer "
                . " des fichiers de sauvegarde pour l\'hôte \${EscHTML(\$In{host})}.";
$Lang{Bad_host_name} = "Mauvais nom d\'hôte \${EscHTML(\$host)}";
$Lang{You_haven_t_selected_any_files__please_go_Back_to} = "Vous n\'avez sélectionné aucun fichier ; "
    . "vous pouvez revenir en arrière pour sélectionner des fichiers.";
$Lang{You_haven_t_selected_any_hosts} = "Vous n\'avez sélectionné aucun hôte ; veuillez retourner à la page précédente pour"
                . " faire la sélection d\'un hôte.";
$Lang{Nice_try__but_you_can_t_put} = "Bien tenté, mais vous ne pouvez pas mettre \'..\' dans un nom de fichier.";
$Lang{Host__doesn_t_exist} = "L'hôte \${EscHTML(\$In{hostDest})} n\'existe pas.";
$Lang{You_don_t_have_permission_to_restore_onto_host} = "Vous n\'avez pas la permission de restaurer sur l\'hôte"
		    . " \${EscHTML(\$In{hostDest})}";
$Lang{Can_t_open_create__openPath} = "Ne peut pas ouvrir/créer "
		. "\${EscHTML(\"\$openPath\")}";
$Lang{Only_privileged_users_can_restore_backup_files2} = "Seuls les utilisateurs privilégiés peuvent restaurer"
                . " des fichiers de sauvegarde pour l\'hôte \${EscHTML(\$host)}.";
$Lang{Empty_host_name} = "Nom d\'hôte vide";
$Lang{Unknown_host_or_user} = "\${EscHTML(\$host)}, hôte ou utilisateur inconnu.";
$Lang{Only_privileged_users_can_view_information_about} = "Seuls les utilisateurs privilégiés peuvent accéder aux "
                . " informations sur l\'hôte \${EscHTML(\$host)}." ;
$Lang{Only_privileged_users_can_view_archive_information} = "Seuls les utilisateurs privilégiés peuvent voir les informations d'archivage.";
$Lang{Only_privileged_users_can_view_restore_information} = "Seuls les utilisateurs privilégiés peuvent restaurer des informations.";
$Lang{Restore_number__num_for_host__does_not_exist} = "La restauration numéro \$num de l\'hôte \${EscHTML(\$host)} n\'existe pas";

$Lang{Archive_number__num_for_host__does_not_exist} = "L\'archive n°\$num pour l\'hôte \${EscHTML(\$host)} n\'existe pas.";

$Lang{Can_t_find_IP_address_for} = "Ne peut pas trouver d\'adresse IP pour \${EscHTML(\$host)}";
$Lang{host_is_a_DHCP_host} = <<EOF;
L\'hôte est un serveur DHCP, et je ne connais pas son adresse IP. J\'ai 
vérifié le nom netbios de \$ENV{REMOTE_ADDR}\$tryIP, et j\'ai trouvé que 
cette machine n\'est pas \$host.
<p>
Tant que je ne verrai pas \$host à une adresse DHCP particulière, vous 
ne pourrez démarrer cette requête que depuis la machine elle même.
EOF

# ------------------------------------
# !! Server Mesg !!
# ------------------------------------

$Lang{Backup_requested_on_DHCP__host} = "Demande de sauvegarde sur l\'hôte \$host (\$In{hostIP}) par"
		                      . " \$User depuis \$ENV{REMOTE_ADDR}";
$Lang{Backup_requested_on__host_by__User} = "Sauvegarde demandée sur \$host par \$User";
$Lang{Backup_stopped_dequeued_on__host_by__User} = "Sauvegarde arrêtée/déprogrammée pour \$host par \$User";
$Lang{Restore_requested_to_host__hostDest__backup___num} = "Restauration demandée pour l\'hôte \$hostDest, "
             . "sauvegarde n°\$num, par \$User depuis \$ENV{REMOTE_ADDR}";
$Lang{Archive_requested} = "Archivage demandé par \$User de \$ENV{REMOTE_ADDR}";

# -------------------------------------------------
# ------- Stuff that was forgotten ----------------
# -------------------------------------------------

$Lang{Status} = "État";
$Lang{PC_Summary} = "Bilan des machines";
$Lang{LOG_file} = "Fichier journal";
$Lang{LOG_files} = "Fichiers journaux";
$Lang{Old_LOGs} = "Vieux journaux";
$Lang{Email_summary} = "Résumé des courriels";
$Lang{Config_file} = "Fichier de configuration";
# $Lang{Hosts_file} = "Fichiers des hôtes";
$Lang{Current_queues} = "Files actuelles";
$Lang{Documentation} = "Documentation";

#$Lang{Host_or_User_name} = "<small>Hôte ou Nom d\'utilisateur:</small>";
$Lang{Go} = "Chercher";
$Lang{Hosts} = "Hôtes";
$Lang{Select_a_host} = "Choisissez un hôte...";

$Lang{There_have_been_no_archives} = "<h2> Il n'y a pas d'archives </h2>\n";
$Lang{This_PC_has_never_been_backed_up} = "<h2> Cette machine n'a jamais été sauvegardée !! </h2>\n";
$Lang{This_PC_is_used_by} = "<li>Cette machine est utilisée par \${UserLink(\$user)}";

$Lang{Extracting_only_Errors} = "(Extraction des erreurs seulement)";
$Lang{XferLOG} = "JournalXfer";
$Lang{Errors}  = "Erreurs";

# ------------
$Lang{Last_email_sent_to__was_at___subject} = <<EOF;
<li>Le dernier courriel envoyé à \${UserLink(\$user)} le \$mailTime, avait comme sujet "\$subj".
EOF
# ------------
$Lang{The_command_cmd_is_currently_running_for_started} = <<EOF;
<li>La commande \$cmd s\'exécute actuellement sur \$host, démarrée le \$startTime.
EOF

# -----------
$Lang{Host_host_is_queued_on_the_background_queue_will_be_backed_up_soon} = <<EOF;
<li>L\'hôte \$host se trouve dans la liste d\'attente d\'arrière plan (il sera sauvegardé bientôt).
EOF

# ----------
$Lang{Host_host_is_queued_on_the_user_queue__will_be_backed_up_soon} = <<EOF;
<li>L\'hôte \$host se trouve dans la liste d\'attente utilisateur (il sera sauvegardé bientôt).
EOF

# ---------
$Lang{A_command_for_host_is_on_the_command_queue_will_run_soon} = <<EOF;
<li>Une commande pour l\'hôte \$host est dans la liste d\'attente des commandes (sera lancée bientôt).
EOF

# --------
$Lang{Last_status_is_state_StatusHost_state_reason_as_of_startTime} = <<EOF;
<li>L\'état courant est \"\$Lang->{\$StatusHost{state}}\"\$reason depuis \$startTime.
EOF

# --------
$Lang{Last_error_is____EscHTML_StatusHost_error} = <<EOF;
<li>La dernière erreur est \"\${EscHTML(\$StatusHost{error})}\".
EOF

# ------
$Lang{Pings_to_host_have_failed_StatusHost_deadCnt__consecutive_times} = <<EOF;
<li>Les pings vers \$host ont échoué \$StatusHost{deadCnt} fois consécutives.
EOF

# -----
$Lang{Prior_to_that__pings} = "Avant cela, les pings";

# -----
$Lang{priorStr_to_host_have_succeeded_StatusHostaliveCnt_consecutive_times} = <<EOF;
<li>Les \$priorStr vers \$host ont réussi \$StatusHost{aliveCnt} 
            fois consécutives.
EOF

$Lang{Because__host_has_been_on_the_network_at_least__Conf_BlackoutGoodCnt_consecutive_times___} = <<EOF;
<li>\$host a été présent sur le réseau au moins \$Conf{BlackoutGoodCnt}
fois consécutives, il ne sera donc pas sauvegardé de \$blackoutStr.
EOF

$Lang{__time0_to__time1_on__days} = "\$t0 à \$t1 pendant \$days";

$Lang{Backups_are_deferred_for_hours_hours_change_this_number} = <<EOF;
<li>Les sauvegardes sont reportées pour \$hours heures
(<a href=\"\$MyURL?action=Stop_Dequeue_Backup&host=\$host\">changer ce nombre</a>).
EOF

$Lang{tryIP} = " et \$StatusHost{dhcpHostIP}";

# $Lang{Host_Inhost} = "Hôte \$In{host}";

$Lang{checkAll} = <<EOF;
<tr><td class="fviewborder">
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;Tout sélectionner
</td><td colspan="5" align="center" class="fviewborder">
<input type="submit" name="Submit" value="Restaurer les fichiers sélectionnés">
</td></tr>
EOF

$Lang{checkAllHosts} = <<EOF;
<tr><td class="fviewborder">
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;Tout sélectionner
</td><td colspan="2" align="center" class="fviewborder">
<input type="submit" name="Submit" value="Archiver les machines sélectionnées">
</td></tr>
EOF

$Lang{fileHeader} = <<EOF;
    <tr class="fviewheader"><td align=center> Nom</td>
       <td align="center"> Type</td>
       <td align="center"> Mode</td>
       <td align="center"> n°</td>
       <td align="center"> Taille</td>
       <td align="center"> Date de modification</td>
    </tr>
EOF

$Lang{Home} = "Accueil";
$Lang{Browse} = "Explorer les sauvegardes";
$Lang{Last_bad_XferLOG} = "Bilan des derniers transferts échoués";
$Lang{Last_bad_XferLOG_errors_only} = "Bilan des derniers transferts échoués (erreurs seulement)";

$Lang{This_display_is_merged_with_backup} = <<EOF;
<li> Cet affichage est fusionné avec la sauvegarde n°\$numF, la plus récente copie intégrale.
EOF

$Lang{Visit_this_directory_in_backup} = <<EOF;
<li> Choisissez la sauvegarde que vous désirez voir : <select onChange="window.location=this.value">\$otherDirs </select>
EOF

$Lang{Restore_Summary} = <<EOF;
\${h2("Résumé de la restauration")}
<p>
Cliquer sur le numéro de restauration pour plus de détails.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Sauvegarde n° </td>
    <td align="center"> Résultat </td>
    <td align="right"> Date de départ</td>
    <td align="right"> Durée (min)</td>
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
\${h2("Résumé de l'archive")}
<p>
Cliquez sur le numéro de l'archive pour plus de détails.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> No. Archive </td>
    <td align="center">Résultat</td>
    <td align="right">Date début</td>
    <td align="right">Durée (min)</td>
</tr>
\$ArchiveStr
</table>
<p>
EOF

$Lang{BackupPC__Documentation} = "BackupPC: Documentation";

$Lang{No} = "non";
$Lang{Yes} = "oui";

$Lang{The_directory_is_empty} = <<EOF;
<tr><td bgcolor="#ffffff">Le répertoire \$dirDisplay est vide
</td></tr>
EOF

#$Lang{on} = "actif";
$Lang{off} = "inactif";

$Lang{backupType_full}    = "complète";
$Lang{backupType_incr}    = "incrémentielle";
$Lang{backupType_active}  = "active";
$Lang{backupType_partial} = "partielle";

$Lang{failed} = "échec";
$Lang{success} = "succès";
$Lang{and} = "et";

# ------
# Hosts states and reasons
$Lang{Status_idle} = "inactif";
$Lang{Status_backup_starting} = "début de la sauvegarde";
$Lang{Status_backup_in_progress} = "sauvegarde en cours";
$Lang{Status_restore_starting} = "début de la restauration";
$Lang{Status_restore_in_progress} = "restauration en cours";
$Lang{Status_admin_pending} = "en attente de l'édition de liens";
$Lang{Status_admin_running} = "édition de liens en cours";

$Lang{Reason_backup_done}    = "sauvegarde terminée";
$Lang{Reason_restore_done}   = "restauration terminée";
$Lang{Reason_archive_done}   = "archivage terminé";
$Lang{Reason_nothing_to_do}  = "rien à faire";
$Lang{Reason_backup_failed}  = "la sauvegarde a échoué";
$Lang{Reason_restore_failed} = "la restauration a échoué";
$Lang{Reason_archive_failed} = "l'archivage a échoué";
$Lang{Reason_no_ping}        = "pas de ping";
$Lang{Reason_backup_canceled_by_user}  = "sauvegarde annulée par l'utilisateur";
$Lang{Reason_restore_canceled_by_user} = "restauration annulée par l'utilisateur";
$Lang{Reason_archive_canceled_by_user} = "archivage annulé par l'utilisateur";
$Lang{Disabled_OnlyManualBackups}  = "auto désactivé";  
$Lang{Disabled_AllBackupsDisabled} = "désactivé";                  

# ---------
# Email messages

# No backup ever
$Lang{EMailNoBackupEverSubj} = "BackupPC: aucune sauvegarde de \$host n'a réussi";
$Lang{EMailNoBackupEverMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
$userName,

Notre logiciel de copies de sécurité n'a jamais réussi à
effectuer la sauvegarde de votre ordinateur ($host). Les sauvegardes
devraient normalement survenir lorsque votre ordinateur est connecté
au réseau. Vous devriez contacter le responsable informatique si :

  - Votre ordinateur est régulièrement connecté au réseau, ce qui
    signifie qu'il y aurait un problème de configuration
    empêchant les sauvegardes de s'effectuer.

  - Vous ne voulez pas qu'il y ait de sauvegardes de
    votre ordinateur ni ne voulez recevoir d'autres messages
    comme celui-ci.

Dans le cas contraire, veuillez vous assurer dès que possible que votre 
ordinateur est correctement connecté au réseau.

Merci de votre attention,
BackupPC Génie
http://backuppc.sourceforge.net
EOF

# No recent backup
$Lang{EMailNoBackupRecentSubj} = "BackupPC: aucune sauvegarde récente de \$host";
$Lang{EMailNoBackupRecentMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
$userName,

Aucune sauvegarde de votre ordinateur n'a été effectuée depuis $days
jours. $numBackups sauvegardes ont étés effectuées du $firstTime
jusqu'à il y a $days jours. Les sauvegardes devraient normalement
survenir lorsque votre ordinateur est connecté au réseau.

Si votre ordinateur a effectivement été connecté au réseau plus de 
quelques heures durant les derniers $days jours, vous devriez 
contacter votre responsable informatique pour savoir pourquoi les 
sauvegardes ne s'effectuent pas correctement.

Autrement, si vous êtes en dehors du bureau, il n'y a pas d'autre
chose que vous pouvez faire, à part faire des copies de vos fichiers
importants sur d'autres medias. Vous devez réaliser que tout fichier crée
ou modifié durant les $days derniers jours (incluant les courriels et
les fichiers attachés) ne pourra pas être restauré si un problème survient
avec votre ordinateur.

Merci de votre attention,
BackupPC Génie
http://backuppc.sourceforge.net
EOF

# Old Outlook files
$Lang{EMailOutlookBackupSubj} = "BackupPC: Les fichiers de Outlook sur \$host doivent être sauvegardés";
$Lang{EMailOutlookBackupMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
$userName,

Les fichiers Outlook sur votre ordinateur n'ont $howLong. Ces fichiers
contiennent tous vos courriels, fichiers attachés, carnets d'adresses et
calendriers. $numBackups sauvegardes ont étés effectuées du $firstTime
au $lastTime.  Par contre, Outlook bloque ses fichiers lorsqu'il est
ouvert, ce qui empêche de les sauvegarder.

Il est recommandé d'effectuer une sauvegarde de vos fichiers Outlook
quand vous serez connecté au réseau en quittant Outlook et toute autre
application, et en visitant ce lien avec votre navigateur web:

    $CgiURL?host=$host               

Choisissez "Démarrer la sauvegarde incrémentielle" deux fois afin
d'effectuer une nouvelle sauvegarde. Vous pouvez ensuite choisir
"Retourner à la page de $host" et appuyer sur "Recharger" dans votre
navigateur avec de vérifier le bon fonctionnement de la sauvegarde. La
sauvegarde devrait prendre quelques minutes à s'effectuer.

Merci de votre attention,
BackupPC Génie
http://backuppc.sourceforge.net
EOF

$Lang{howLong_not_been_backed_up} = "jamais été sauvegardés";
$Lang{howLong_not_been_backed_up_for_days_days} = "pas été sauvegardés depuis \$days jours";

#######################################################################
# RSS strings
#######################################################################
$Lang{RSS_Doc_Title}       = "BackupPC Server";
$Lang{RSS_Doc_Description} = "RSS feed for BackupPC";
$Lang{RSS_Host_Summary}    = <<EOF;
Nb complètes : \$fullCnt;
Complètes Âge (jours) : \$fullAge;
Complètes Taille (Go) : \$fullSize;
Vitesse (Mo/s) : \$fullRate;
Nb incrémentielles : \$incrCnt;
Incrémentielles Âge (jours) : \$incrAge;
État actuel : \$host_state;
Dernière tentative : \$host_last_attempt;
EOF

#######################################################################
# Configuration editor strings
#######################################################################

$Lang{Only_privileged_users_can_edit_config_files} = "Seuls les utilisateurs privilégiés peuvent modifier les paramètres de configuration.";
$Lang{CfgEdit_Edit_Config} = "Modifier la configuration";
$Lang{CfgEdit_Edit_Hosts}  = "Modifier les machines";

$Lang{CfgEdit_Title_Server} = "Serveur";
$Lang{CfgEdit_Title_General_Parameters} = "Paramètres généraux";
$Lang{CfgEdit_Title_Wakeup_Schedule} = "Horaire des réveils";
$Lang{CfgEdit_Title_Concurrent_Jobs} = "Tâches concurrentes";
$Lang{CfgEdit_Title_Pool_Filesystem_Limits} = "Limites du système de fichiers";
$Lang{CfgEdit_Title_Other_Parameters} = "Autres paramètres";
$Lang{CfgEdit_Title_Remote_Apache_Settings} = "Options d'Apache à distance";
$Lang{CfgEdit_Title_Program_Paths} = "Chemins des programmes";
$Lang{CfgEdit_Title_Install_Paths} = "Chemins d'installation";
$Lang{CfgEdit_Title_Email} = "Courriel";
$Lang{CfgEdit_Title_Email_settings} = "Paramètres de courriel";
$Lang{CfgEdit_Title_Email_User_Messages} = "Messages des usagers par courriel";
$Lang{CfgEdit_Title_CGI} = "CGI";
$Lang{CfgEdit_Title_Admin_Privileges} = "Privilèges administrateur";
$Lang{CfgEdit_Title_Page_Rendering} = "Rendu des pages";
$Lang{CfgEdit_Title_Paths} = "Chemins";
$Lang{CfgEdit_Title_User_URLs} = "URL des usagers";
$Lang{CfgEdit_Title_User_Config_Editing} = "Modifications des configurations des usagers";
$Lang{CfgEdit_Title_Xfer} = "Xfer";
$Lang{CfgEdit_Title_Xfer_Settings} = "Paramètres des transfers";
$Lang{CfgEdit_Title_Ftp_Settings} = "Paramètres de FTP";
$Lang{CfgEdit_Title_Smb_Settings} = "Paramètres de Smb";
$Lang{CfgEdit_Title_Tar_Settings} = "Paramètres de Tar";
$Lang{CfgEdit_Title_Rsync_Settings} = "Paramètres de Rsync";
$Lang{CfgEdit_Title_Rsyncd_Settings} = "Paramètres de Rsyncd";
$Lang{CfgEdit_Title_Archive_Settings} = "Paramètres d'archivage";
$Lang{CfgEdit_Title_Include_Exclude} = "Inclure/Exclure";
$Lang{CfgEdit_Title_Smb_Paths_Commands} = "Chemins/Commandes Smb";
$Lang{CfgEdit_Title_Tar_Paths_Commands} = "Chemins/Commandes Tar";
$Lang{CfgEdit_Title_Rsync_Paths_Commands_Args} = "Chemins/Commandes/Args Rsync";
$Lang{CfgEdit_Title_Rsyncd_Port_Args} = "Port/Args Rsyncd";
$Lang{CfgEdit_Title_Archive_Paths_Commands} = "Chemins/Commandes d'archivage";
$Lang{CfgEdit_Title_Schedule} = "Horaire";
$Lang{CfgEdit_Title_Full_Backups} = "Sauvegardes complètes";
$Lang{CfgEdit_Title_Incremental_Backups} = "Sauvegardes incrémentielles";
$Lang{CfgEdit_Title_Blackouts} = "Suspension";
$Lang{CfgEdit_Title_Other} = "Divers";
$Lang{CfgEdit_Title_Backup_Settings} = "Paramètres de sauvegarde";
$Lang{CfgEdit_Title_Client_Lookup} = "Consultation des clients";
$Lang{CfgEdit_Title_User_Commands} = "Commandes des usagers";
$Lang{CfgEdit_Title_Hosts} = "Machines";

$Lang{CfgEdit_Hosts_Comment} = <<EOF;
Pour ajouter une machine, choisissez Ajouter et entrez ensuite le nom. Pour faire
une copie de la configuration d'une autre machine, entrer le nom de la machine
comme NOUVEAU=ACOPIER. Cela va écraser toute configuration par défaut pour
cette machine. Vous pouvez aussi faire cela pour une machine existante.
Pour détruire une machine, cliquer sur le bouton Détruire. Les ajouts, 
destructions et modifications ne prennent effet que lorsque que vous cliquez 
sur le bouton Sauvegarder. Aucune des sauvegardes des machines ne sera
détruite, donc si vous effacez une machine par erreur, créez-la à nouveau. Pour
détruire les sauvegardes d'une machine, vous devez effacer les fichiers 
manuellement dans \$topDir/pc/HOST
EOF

$Lang{CfgEdit_Header_Main} = <<EOF;
\${h1("Éditeur de configuration")}
EOF

$Lang{CfgEdit_Header_Host} = <<EOF;
\${h1("Éditeur de la configuration de \$host")}
<p>
Note: Cochez Écraser pour modifier une valeur spécifique à cette machine.
<p>
EOF

$Lang{CfgEdit_Button_Save}     = "Sauvegarder";
$Lang{CfgEdit_Button_Insert}   = "Insérer";
$Lang{CfgEdit_Button_Delete}   = "Détruire";
$Lang{CfgEdit_Button_Add}      = "Ajouter";
$Lang{CfgEdit_Button_Override} = "Écraser";
$Lang{CfgEdit_Button_New_Key}  = "Nouvelle clé";

$Lang{CfgEdit_Error_No_Save}
            = "Erreur: Pas de sauvegarde à cause d'erreurs.";
$Lang{CfgEdit_Error__must_be_an_integer}
            = "Erreur: \$var doit être un nombre entier";
$Lang{CfgEdit_Error__must_be_real_valued_number}
            = "Erreur: \$var doit être un nombre réel";
$Lang{CfgEdit_Error__entry__must_be_an_integer}
            = "Erreur: l'entrée \$k de \$var doit être un nombre entier";
$Lang{CfgEdit_Error__entry__must_be_real_valued_number}
            = "Erreur: l'entrée \$k de \$var doit être un nombre réel";
$Lang{CfgEdit_Error__must_be_executable_program}
            = "Erreur: \$var doit être un chemin exécutable";
$Lang{CfgEdit_Error__must_be_valid_option}
            = "Erreur: \$var doit être une option valide";
$Lang{CfgEdit_Error_Copy_host_does_not_exist}
            = "La machine \$copyHost ne peut être copiée, car elle n'existe pas ; création d'une machine nommée \$fullHost.  Détruisez cette machine si ce n'est pas ce que vous vouliez.";

$Lang{CfgEdit_Log_Copy_host_config}
            = "\$User a copié la config de \$fromHost à \$host\n";
$Lang{CfgEdit_Log_Delete_param}
            = "\$User a détruit \$p de \$conf\n";
$Lang{CfgEdit_Log_Add_param_value}
            = "\$User a ajouté \$p à \$conf en fixant sa valeur à \$value\n";
$Lang{CfgEdit_Log_Change_param_value}
            = "\$User a changé \$p dans \$conf de \$valueOld à \$valueNew\n";
$Lang{CfgEdit_Log_Host_Delete}
            = "\$User a détruit la machine \$host\n";
$Lang{CfgEdit_Log_Host_Change}
            = "\$User a changé \$key de \$valueOld à \$valueNew sur \$host\n";
$Lang{CfgEdit_Log_Host_Add}
            = "\$User a jouté la machine \$host: \$value\n";
  
#end of lang_fr.pm
