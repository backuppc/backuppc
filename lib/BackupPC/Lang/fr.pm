#!/bin/perl -T

#my %lang;
#use strict;

# --------------------------------

$Lang{Start_Full_Backup} = "Démarrer la sauvegarde complète";
$Lang{Start_Incr_Backup} = "Démarrer la sauvegarde incrémentale";
$Lang{Stop_Dequeue_Backup} = "Arrêter/annuler la sauvegarde";
$Lang{Restore} = "Restaurer";

# -----

$Lang{H_BackupPC_Server_Status} = "Status du serveur BackupPC";
$Lang{BackupPC_Server_Status}= <<EOF;

\${h1(qq{$Lang{H_BackupPC_Server_Status}})}
<p>
\${h2(\"Informations générales du serveur\")}

<ul>
<li> Le PID du serveur est \$Info{pid}, sur l\'hôte \$Conf{ServerHost},
     version \$Info{Version}, démarré le \$serverStartTime.
<li> Ce rapport à été généré le \$now.
<li> La prochaine file d\'attente sera remplie le \$nextWakeupTime.
<li> Autres infos:
    <ul>
        <li>\$numBgQueue demandes de sauvegardes en attente depuis le dernier réveil automatique,
        <li>\$numUserQueue requêtes de sauvegardes utilisateur en attente,
        <li>\$numCmdQueue requêtes de commandes en attente,
        \$poolInfo
        <li>L\'espace de stockage a été récemment rempli à \$Info{DUlastValue}%
            (\$DUlastTime), le maximum d\'aujourd\'hui est \$Info{DUDailyMax}% (\$DUmaxTime)
            et hier le maximum était \$Info{DUDailyMaxPrev}%.
    </ul>
</ul>

\${h2("Travaux en cours d'exécution")}
<p>
<table border>
<tr><td> Hôte </td>
    <td> Type </td>
    <td> Utilisateur </td>
    <td> Date de départ </td>
    <td> Commande </td>
    <td align="center"> PID </td>
    <td align="center"> PID du transfert </td>
    </tr>
\$jobStr
</table>
<p>

\${h2("Échecs qui demandent de l'attention")}
<p>
<table border>
<tr><td align="center"> Hôte </td>
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
$Lang{BackupPC__Server_Summary} = "BackupPC: Résumé du serveur";
$Lang{BackupPC_Summary}=<<EOF;

\${h1(qq{$Lang{BackupPC__Server_Summary}})}
<p>
Ce statut a été généré le \$now.
<p>

\${h2("Hôtes avec de bonnes sauvegardes")}
<p>
Il y a \$hostCntGood hôtes ayant été sauvegardés, pour un total de :
<ul>
<li> \$fullTot sauvegardes complètes de tailles cumulées de \${fullSizeTot} Go
     (précédant la mise en commun et la compression),
<li> \$incrTot sauvegardes incrémentales de tailles cumulées de \${incrSizeTot} Go
     (précédant la mise en commun et la compression).
</ul>
<table border>
<tr><td> Hôte </td>
    <td align="center"> Utilisateur </td>
    <td align="center"> Nb complètes </td>
    <td align="center"> Complètes Âge/Jours </td>
    <td align="center"> Complètes Taille/Go </td>
    <td align="center"> Vitesse Mo/sec </td>
    <td align="center"> Nb incrémentales </td>
    <td align="center"> Incrémentales Âge/Jours </td>
    <td align="center"> État actuel </td>
    <td align="center"> Dernière tentative </td></tr>
\$strGood
</table>
<p>

\${h2("Hôtes sans sauvegardes")}
<p>
Il y a \$hostCntNone hôtes sans sauvegardes.
<p>
<table border>
<tr><td> Hôte </td>
    <td align="center"> Utilisateur </td>
    <td align="center"> Nb complètes </td>
    <td align="center"> Complètes Âge/jour </td>
    <td align="center"> Complètes Taille/Go </td>
    <td align="center"> Vitesse Mo/sec </td>
    <td align="center"> Nb incrémentales </td>
    <td align="center"> Incrémentales Âge/jours </td>
    <td align="center"> État actuel </td>
    <td align="center"> Dernière tentative </td></tr>
\$strNone
</table>
EOF

# -----------------------------------
$Lang{Pool_Stat} = <<EOF;
        <li>La mise en commun est constituée de \$info->{"\${name}FileCnt"} fichiers
            et \$info->{"\${name}DirCnt"} repertoires représentant \${poolSize} Go (depuis le \$poolTime),
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
La réponse du serveur a été: \$reply
<p>
Retourner à la page d\'accueil de <a href="\$MyURL?host=\$host">\$host</a>.
EOF
# --------------------------------
$Lang{BackupPC__Start_Backup_Confirm_on__host} = "BackupPC: Confirmation du départ de la sauvegarde de \$host";
# --------------------------------
$Lang{Are_you_sure_start} = <<EOF;
\${h1("Êtes vous certain ?")}
<p>
Vous allez bientôt démarrer une sauvegarde <i>\$type</i> depuis \$host.

<form action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="hostIP" value="\$ipAddr">
<input type="hidden" name="doit" value="1">
Voulez vous vraiment le faire ?
<input type="submit" value="\$In{action}" name="action">
<input type="submit" value="Non" name="">
</form>
EOF
# --------------------------------
$Lang{BackupPC__Stop_Backup_Confirm_on__host} = "BackupPC: Confirmer l\'arrêt de la sauvegarde sur \$host";
# --------------------------------
$Lang{Are_you_sure_stop} = <<EOF;

\${h1("Êtes vous certain ?")}

<p>
Vous êtes sur le point d\'arrêter/supprimer de la file les sauvegardes de \$host;

<form action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="doit" value="1">
En outre, prière de ne pas démarrer d\'autres sauvegarde pour
<input type="text" name="backoff" size="10" value="\$backoff"> heures.
<p>
Voulez vous vraiment le faire ?
<input type="submit" value="\$In{action}" name="action">
<input type="submit" value="Non" name="">
</form>

EOF
# --------------------------------
$Lang{Only_privileged_users_can_view_queues_} = "Seuls les utilisateurs privilégiés peuvent voir les files.";
# --------------------------------
$Lang{BackupPC__Queue_Summary} = "BackupPC: Résumé de la file";
# --------------------------------
$Lang{Backup_Queue_Summary} = <<EOF;
\${h1("Résumé de la file")}
<p>
\${h2("Résumé des files des utilisateurs")}
<p>
Les demandes utilisateurs suivantes sont actuellement en attente :
<table border>
<tr><td> Hôte </td>
    <td> Temps Requis </td>
    <td> Utilisateur </td></tr>
\$strUser
</table>
<p>

\${h2("Résumé de la file en arrière plan")}
<p>
Les demandes en arrière plan suivantes sont actuellement en attente :
<table border>
<tr><td> Hôte </td>
    <td> Temps requis </td>
    <td> Utilisateur </td></tr>
\$strBg
</table>
<p>

\${h2("Résumé de la file d\'attente des commandes")}
<p>
Les demandes de commande suivantes sont actuellement en attente :
<table border>
<tr><td> Hôtes </td>
    <td> Temps Requis </td>
    <td> Utilisateur </td>
    <td> Commande </td></tr>
\$strCmd
</table>
EOF
# --------------------------------
$Lang{Backup_PC__Log_File__file} = "BackupPC: Fichier journal \$file";
$Lang{Log_File__file__comment} = <<EOF;
\${h1("Fichier journal \$file \$comment")}
<p>
EOF
# --------------------------------
$Lang{Contents_of_log_file} = <<EOF;
Contenu du fichier journal <tt>\$file</tt>, modifié le \$mtimeStr \$comment
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
<table border>
<tr><td align="center"> Fichier </td>
    <td align="center"> Taille </td>
    <td align="center"> Date de modification </td></tr>
\$str
</table>
EOF

# -------------------------------
$Lang{Recent_Email_Summary} = <<EOF;
\${h1("Résumé des courriels récents (Du plus récent au plus vieux)")}
<p>
<table border>
<tr><td align="center"> Destinataire </td>
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
<p>
Vous avez sélectionné les fichiers/repertoires suivants depuis le partage \$share, sauvegarde numéro \$num:
<ul>
\$fileListStr
</ul>
<p>
Vous avez trois choix pour restaurer ces fichiers/repertoires.
Veuillez sélectionner une des options suivantes.
<p>
\${h2("Option 1: Restauration directe")}
<p>
Vous pouvez démarrer une restauration de ces fichiers 
directement sur \$host.
<p>
<b>Attention:</b>
tous les fichiers correspondant à ceux que vous avez sélectionnés vont être effacés !

<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="3">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<table border="0">
<tr>
    <td>Restaurer les fichiers vers l\'hôte</td>
    <td><input type="text" size="40" value="\${EscHTML(\$host)}"
	 name="hostDest"></td>
</tr><tr>
    <td>Restaurer les fichiers vers le partage</td>
    <td><input type="text" size="40" value="\${EscHTML(\$share)}"
	 name="shareDest"></td>
</tr><tr>
    <td>Restaurer les fichiers du répertoire<br>(relatif au partage)</td>
    <td valign="top"><input type="text" size="40" maxlength="256"
	value="\${EscHTML(\$pathHdr)}" name="pathHdr"></td>
</tr><tr>
    <td><input type="submit" value="Démarrer la restauration" name=""></td>
</table>
</form>
EOF


# ------------------------------
$Lang{Option_2__Download_Zip_archive} = <<EOF;

\${h2("Option 2: Télécharger une archive Zip")}
<p>
Vous pouvez télécharger une archive compressée (.zip) contenant tous les fichiers/répertoires que vous 
avez sélectionnés. Vous pouvez utiliser une application locale, comme Winzip, pour voir ou extraire n\'importe quel fichier.
<p>
<b>Attention:</b> en fonction de quels fichiers/répertoires vous avez sélectionné,
cette archive peut devenir très très large.  Cela peut prendre plusieurs minutes pour créer
et transférer cette archive, et vous aurez besoin d\'assez d\'espace disque pour le stocker.
<p>
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
Compression (0=désactivée, 1=rapide,...,9=meilleure)
<input type="text" size="6" value="5" name="compressLevel">
<br>
<input type="submit" value="Télécharger le fichier Zip" name="">
</form>
EOF


# ------------------------------

$Lang{Option_2__Download_Zip_archive2} = <<EOF;
\${h2("Option 2: Télécharger une archive Zip")}
<p>
Vous ne pouvez pas télécharger d'archive zip, car Archive::Zip n\'est pas
installé. Veuillez demander à votre administrateur système d\'installer 
Archive::Zip depuis <a href="http://www.cpan.org">www.cpan.org</a>.
<p>
EOF


# ------------------------------
$Lang{Option_3__Download_Zip_archive} = <<EOF;
\${h2("Option 3: Télécharger une archive tar")}
<p>

Vous pouvez télécharger une archive Tar contenant tous les fichiers/répertoires 
que vous avez sélectionnés. Vous pourrez alors utiliser une application locale, 
comme tar ou winzip pour voir ou extraire n\'importe quel fichier.
<p>
<b>Attention:</b> en fonction des fichiers/répertoires que vous avez sélectionnés,
cette archive peut devenir très très large.  Cela peut prendre plusieurs minutes
pour créer et transférer l\'archive, et vous aurez besoin d'assez
d\'espace disque local pour la stocker.
<p>
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
<input type="submit" value="Télécharger le fichier Tar" name="">
</form>
EOF



# ------------------------------
$Lang{Restore_Confirm_on__host} = "BackupPC: Confirmation de restauration sur \$host";

$Lang{Are_you_sure} = <<EOF;
\${h1("Êtes-vous sur ?")}
<p>
Vous êtes sur le point de démarrer une restauration directement sur la machine \$In{hostDest}. Les fichiers suivants vont être restaurés dans le partage \$In{shareDest}, depuis la sauvegarde numéro \$num:
<p>
<table border>
<tr><td>Fichier/Répertoire original</td><td>Va être restauré à</td></tr>
\$fileListStr
</table>

<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="hostDest" value="\${EscHTML(\$In{hostDest})}">
<input type="hidden" name="shareDest" value="\${EscHTML(\$In{shareDest})}">
<input type="hidden" name="pathHdr" value="\${EscHTML(\$In{pathHdr})}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="4">
\$hiddenStr
Voulez-vous vraiment le faire ?
<input type="submit" value="\$In{action}" name="action">
<input type="submit" value="Non" name="">
</form>
EOF

# --------------------------
$Lang{Restore_Requested_on__hostDest} = "BackupPC: Restauration demandée sur \$hostDest";
$Lang{Reply_from_server_was___reply} = <<EOF;
\${h1(\$str)}
<p>
La réponse du serveur est: \$reply
<p>
Retourner à la page d\'accueil de <a href="\$MyURL?host=\$hostDest">\$hostDest </a>.
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

\${h2("Actions de l\'utilisateur")}
<p>
<form action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
\$startIncrStr
<input type="submit" value="$Lang{Start_Full_Backup}" name="action">
<input type="submit" value="$Lang{Stop_Dequeue_Backup}" name="action">
</form>

\${h2("Résumé de la sauvegarde")}
<p>
Cliquer sur le numéro de l\'archive pour naviguer et restaurer les fichiers de sauvegarde.
<table border>
<tr><td align="center"> Sauvegarde n° </td>
    <td align="center"> Type </td>
    <td align="center"> Fusionnée </td> 
    <td align="center"> Date de démarrage </td>
    <td align="center"> Durée/mins </td>
    <td align="center"> Âge/jours </td>
    <td align="center"> Chemin d\'accès de la sauvegarde sur le serveur </td>
</tr>
\$str
</table>
<p>

\$restoreStr

\${h2("Résumé des erreurs de transfert")}
<p>
<table border>
<tr><td align="center"> Nb sauvegarde </td>
    <td align="center"> Type </td>
    <td align="center"> Voir </td>
    <td align="center"> Nb erreurs transfert </td>
    <td align="center"> Nb mauvais fichiers </td>
    <td align="center"> Nb mauvais partages </td>
    <td align="center"> Nb erreurs tar </td>
</tr>
\$errStr
</table>
<p>

\${h2("Récapitulatif de la taille des fichier et du nombre de réutilisations")}
<p>
    Les fichiers existants sont ceux qui sont déjà sur le serveur; 
Les nouveaux fichiers sont ceux qui ont été ajoutés au serveur.
Les fichiers vides et les erreurs de SMB ne sont pas comptabilisés parmis les nouveaux et les réutilisés.

<table border>
<tr><td colspan="2"></td>
    <td align="center" colspan="3"> Totaux </td>
    <td align="center" colspan="2"> Fichiers existants </td>
    <td align="center" colspan="2"> Nouveaux fichiers </td>
</tr>
<tr>
    <td align="center"> Nb de sauvegarde  </td>
    <td align="center"> Type </td>
    <td align="center"> Nb de Fichiers </td>
    <td align="center"> Taille/Mo </td>
    <td align="center"> Mo/sec </td>
    <td align="center"> Nb de Fichiers </td>
    <td align="center"> Taille/Mo </td>
    <td align="center"> Nb de Fichiers </td>
    <td align="center"> Taille/Mo </td>
</tr>
\$sizeStr
</table>
<p>

\${h2("Résumé de la compression")}
<p>

Performance de la compression pour les fichiers déjà sur le serveur et
récemment compressés.

<table border>
<tr><td colspan="3"></td>
    <td align="center" colspan="3"> Fichiers existants </td>
    <td align="center" colspan="3"> Nouveaux fichiers </td>
</tr>
<tr><td align="center"> Nb de sauvegardes </td>
    <td align="center"> Type </td>
    <td align="center"> Niveau de Compression </td>
    <td align="center"> Taille/Mo </td>
    <td align="center"> Comp/Mo </td>
    <td align="center"> Compression </td>
    <td align="center"> Taille/Mo </td>
    <td align="center"> Comp/Mo </td>
    <td align="center"> Compression </td>
</tr>
\$compStr
</table>
<p>
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
\${h1("Navigation dans la sauvegarde pour \$host")}

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

<ul>
<li> Vous naviguez dans la sauvegarde n°\$num, qui a commencé vers \$backupTime
        (il y a \$backupAge jours),
\$filledBackup
<li> Cliquer dans un répertoire ci-dessous pour y naviguer,
<li> Cliquer dans un fichier ci-dessous pour le restaurer,
<li> Vous pouvez voir l'<a href="\$MyURL?action=dirHistory&host=\${EscURI(\$host)}&share=\$shareURI&dir=\$pathURI">historique</a> de sauvegarde du répertoire courant.
</ul>

\${h2("Contenu de \${EscHTML(\$dirDisplay)}")}
<form name="form1" method="post" action="\$MyURL">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="share" value="\${EscHTML(\$share)}">
<input type="hidden" name="fcbMax" value="\$checkBoxCnt">
<input type="hidden" name="action" value="$Lang{Restore}">
<br>
<table>
<tr><td valign="top">
    <!--Navigate here:-->
    <br><table align="center" border="0" cellpadding="0" cellspacing="0" bgcolor="#ffffff">
    \$dirStr
    </table>
</td><td width="3%">
</td><td valign="top">
    <!--Restore files here:-->
    <br>
    <table cellpadding="0" cellspacing="0" bgcolor="#333333"><tr><td>
        <table border="0" width="100%" align="left" cellpadding="2" cellspacing="1">
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
</td></tr></table>
</form>
EOF

# ------------------------------
$Lang{DirHistory_backup_for__host} = "BackupPC: Historique de sauvegarde des répertoires de \$host";

$Lang{DirHistory_for__host} = <<EOF;
\${h1("Historique de sauvegarde pour \$host")}

Voici les versions des fichiers pour toutes les sauvegardes:
<ul>
<li> Cliquez sur un numéro de sauvegarde pour revenir à la navigation de sauvegarde,
<li> Cliquez sur un répertoire pour naviguer dans celui-ci,
<li> Cliquez sur une version d'un fichier pour la télécharger.
</ul>

\${h2("Historique de \${EscHTML(\$dirDisplay)}")}

<br>
<table border>
<tr><td>No. de sauvegarde</td>\$backupNumStr</tr>
<tr><td>Date</td>\$backupTimeStr</tr>
\$fileStr
</table>
EOF

# ------------------------------
$Lang{Restore___num_details_for__host} = "BackupPC: Détails de la restauration n° \$num pour \$host"; 

$Lang{Restore___num_details_for__host2 } = <<EOF;
\${h1("Détails de la restauration n° \$num pour \$host")} 
<p>
<table border>
<tr><td> Numéro </td><td> \$Restores[\$i]{num} </td></tr>
<tr><td> Demandée par </td><td> \$RestoreReq{user} </td></tr>
<tr><td> Demandée à </td><td> \$reqTime </td></tr>
<tr><td> Résultat </td><td> \$Restores[\$i]{result} </td></tr>
<tr><td> Message d'erreur </td><td> \$Restores[\$i]{errorMsg} </td></tr>
<tr><td> Hôte source </td><td> \$RestoreReq{hostSrc} </td></tr>
<tr><td> N° de sauvegarde </td><td> \$RestoreReq{num} </td></tr>
<tr><td> Partition source </td><td> \$RestoreReq{shareSrc} </td></tr>
<tr><td> Hôte de destination </td><td> \$RestoreReq{hostDest} </td></tr>
<tr><td> Partition de destination </td><td> \$RestoreReq{shareDest} </td></tr>
<tr><td> Début </td><td> \$startTime </td></tr>
<tr><td> Durée </td><td> \$duration min </td></tr>
<tr><td> Nombre de fichier </td><td> \$Restores[\$i]{nFiles} </td></tr>
<tr><td> Grosseur totale </td><td> \${MB} Mo </td></tr>
<tr><td> Taux de transfert </td><td> \$MBperSec Mo/sec </td></tr>
<tr><td> Erreurs de TarCreate </td><td> \$Restores[\$i]{tarCreateErrs} </td></tr>
<tr><td> Erreurs de transfert </td><td> \$Restores[\$i]{xferErrs} </td></tr>
<tr><td> Journal de transfert </td><td>
<a href="\$MyURL?action=view&type=RestoreLOG&num=\$Restores[\$i]{num}&host=\$host">Visionner</a>,
<a href="\$MyURL?action=view&type=RestoreErr&num=\$Restores[\$i]{num}&host=\$host">Erreurs</a>
</tr></tr>
</table>
<p>
\${h1("Liste des Fichiers/Répertoires")}
<p>
<table border>
<tr><td>Fichier/répertoire original</td><td>Restauré vers</td></tr>
\$fileListStr
</table>
EOF


# -----------------------------------
$Lang{Email_Summary} = "BackupPC: Résumé du courriel";

# -----------------------------------
#  !! ERROR messages !!
# -----------------------------------

$Lang{BackupPC__Lib__new_failed__check_apache_error_log} = "BackupPC::Lib->new a échoué: regardez le "
    ."fichier error_log d\'apache\n";
$Lang{Wrong_user__my_userid_is___} =  
              "Mauvais utilisateur: mon userid est \$>, à la place de \$uid (\$Conf{BackupPCUser})\n";
$Lang{Only_privileged_users_can_view_PC_summaries} = "Seuls les utilisateurs privilégiés peuvent voir les résumés des PC.";
$Lang{Only_privileged_users_can_stop_or_start_backups} = 
                  "Seuls les utilisateurs privilégiés peuvent arrêter ou démarrer des sauvegardes sur \${EscHTML(\$host)}.";
$Lang{Invalid_number__num} = "Numéro invalide \$num";
$Lang{Unable_to_open__file__configuration_problem} = "Impossible d\'ouvrir \$file: problème de configuration ?";
$Lang{Only_privileged_users_can_view_log_or_config_files} = "Seuls les utilisateurs privilégiés peuvent voir les fichier de jounal ou les fichiers de configuration.";
$Lang{Only_privileged_users_can_view_log_files} = "Seuls les utilisateurs privilégiés peuvent voir les fichiers de journal.";
$Lang{Only_privileged_users_can_view_email_summaries} = "Seuls les utilisateurs privilégiés peuvent voir les compte-rendu des courriels.";
$Lang{Only_privileged_users_can_browse_backup_files} = "Seuls les utilisateurs privilégiés peuvent parcourir les fichiers de sauvegarde pour l'hôte \${EscHTML(\$In{host})}.";
$Lang{Empty_host_name} = "Nom d\'hôte vide.";
$Lang{Directory___EscHTML} = "Le répertoire \${EscHTML(\"\$TopDir/pc/\$host/\$num\")}"
		    . " est vide";
$Lang{Can_t_browse_bad_directory_name2} = "Ne peut pas parcourir "
	            . " \${EscHTML(\$relDir)}:"
                    . " mauvais nom de répertoire";
$Lang{Only_privileged_users_can_restore_backup_files} = "Seuls les utilisateurs privilégiés peuvent restaurer "
                . " des fichiers de sauvegarde"
                . " pour l\'hôte \${EscHTML(\$In{host})}.";
$Lang{Bad_host_name} = "Mauvais nom d\'hôte \${EscHTML(\$host)}";
$Lang{You_haven_t_selected_any_files__please_go_Back_to} = "Vous n'avez sélectionné aucun fichier; "
    . "vous pouvez revenir en arrière pour sélectionner des fichiers.";
$Lang{Nice_try__but_you_can_t_put} = "Bien tenté, mais vous ne pouvez pas mettre \'..\' dans"
                                   . " n\'importe quel nom de fichier.";
$Lang{Host__doesn_t_exist} = "L'hôte \${EscHTML(\$In{hostDest})} n\'existe pas.";
$Lang{You_don_t_have_permission_to_restore_onto_host} = "Vous n\'avez pas la permission de restaurer sur l\'hôte"
		    . " \${EscHTML(\$In{hostDest})}";
$Lang{Can_t_open_create} = "Ne peut pas ouvrir/créer ". "\${EscHTML(\"\$TopDir/pc/\$hostDest/\$reqFileName\")}";
$Lang{Only_privileged_users_can_restore_backup_files2} = "Seuls les utilisateurs privilégiés peuvent restaurer"
                . " des fichiers de sauvegarde"
                . " pour l\'hôte \${EscHTML(\$host)}.";
$Lang{Empty_host_name} = "Nom d\'hôte vide";
$Lang{Unknown_host_or_user} = "\${EscHTML(\$host)}, hôte ou utilisateur inconnu.";
$Lang{Only_privileged_users_can_view_information_about} = "Seuls les utilisateurs privilégiés peuvent accéder aux "
                . " informations sur l\'hôte \${EscHTML(\$host)}." ;
$Lang{Only_privileged_users_can_view_restore_information} = "Seuls les utilisateurs privilégiés peuvent restaurer "
    ."des informations.";
$Lang{Restore_number__num_for_host__does_not_exist} = "Restauration numéro \$num de l\'hôte \${EscHTML(\$host)} n\'existe pas";

$Lang{Unable_to_connect_to_BackupPC_server} = "Impossible de se connecter au server BackupPC."
          . "Ce script CGI (\$MyURL) ne peut pas se connecter au serveur  BackupPC"
          . " sur \$Conf{ServerHost} via le port \$Conf{ServerPort}.  L\'erreur est la"
          . " suivante: \$err.",
            "Peut-être que BackupPC n\'a pas été lancé ou il y a une erreur "
          . " de configuration. Veuillez faire suivre ce message à votre administrateur système.";

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

# Ne pas mélanger $reply et $str cf vers ligne: 248

$Lang{Backup_requested_on_DHCP__host} = "Demande de sauvegarde sur l\'hôte \$host (\$In{hostIP}) par"
		                      . " \$User depuis \$ENV{REMOTE_ADDR}";
$Lang{Backup_requested_on__host_by__User} = "Sauvegarde demandée sur \$host par \$User";
$Lang{Backup_stopped_dequeued_on__host_by__User} = "Sauvegarde Arrêtée/déprogrammée pour \$host par \$User";

$Lang{Restore_requested_to_host__hostDest__backup___num} = "Restauration demandée pour l\'hôte \$hostDest, "
             . "sauvegarde n° \$num,"
	     . " par \$User depuis \$ENV{REMOTE_ADDR}";

# -------------------------------------------------
# ------- Stuff that was forgotten ----------------
# -------------------------------------------------

$Lang{Status} = "Status";
$Lang{PC_Summary} = "Bilan des PC";
$Lang{LOG_file} = "Fichier journal";
$Lang{Old_LOGs} = "Vieux journaux";
$Lang{Email_summary} = "Résumé des courriels";
$Lang{Config_file} = "Fichier de configuration";
$Lang{Hosts_file} = "Fichiers des hôtes";
$Lang{Current_queues} = "Files actuelles";
$Lang{Documentation} = "Documentation";

$Lang{Host_or_User_name} = "<small>Hôte ou Nom d\'utilisateur:</small>";
$Lang{Go} = "Chercher";
$Lang{Hosts} = "Hôtes";

$Lang{This_PC_has_never_been_backed_up} = "<h2> Ce PC n'a jamais été sauvegardé !! </h2>\n";
$Lang{This_PC_is_used_by} = "<li>Ce PC est utilisé par \${UserLink(\$user)}";

$Lang{Extracting_only_Errors} = "(Extraction des erreurs seulement)";
$Lang{XferLOG} = "JournalXfer";
$Lang{Errors}  = "Erreurs";

# ------------
$Lang{Last_email_sent_to__was_at___subject} = <<EOF;
<li>Dernier email envoyé à \${UserLink(\$user)} le \$mailTime, avait comme sujet "\$subj".
EOF
# ------------
$Lang{The_command_cmd_is_currently_running_for_started} = <<EOF;
<li>La commande \$cmd s\'exécute actuellement sur \$host, démarrée le \$startTime.
EOF

# -----------
$Lang{Host_host_is_queued_on_the_background_queue_will_be_backed_up_soon} = <<EOF;
<li>L\'hôte \$host se trouve dans la liste d\'attente d\'arrière plan (sera sauvegardé bientôt).
EOF

# ----------
$Lang{Host_host_is_queued_on_the_user_queue__will_be_backed_up_soon} = <<EOF;
<li>L\'hôte \$host se trouve dans la liste d\'attente utilisateur (sera sauvegardé bientôt).
EOF

# ---------
$Lang{A_command_for_host_is_on_the_command_queue_will_run_soon} = <<EOF;
<li>Une commande pour l\'hôte \$host est dans la liste d\'attente des commandes (sera lancé bientôt).
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
<li>Les pings vers \$host ont échoués \$StatusHost{deadCnt} fois consécutives.
EOF

# -----
$Lang{Prior_to_that__pings} = "Avant cela, pings";

# -----
$Lang{priorStr_to_host_have_succeeded_StatusHostaliveCnt_consecutive_times} = <<EOF;
<li>Les \$priorStr vers \$host ont réussi \$StatusHost{aliveCnt} fois consécutives.
EOF

$Lang{Because__host_has_been_on_the_network_at_least__Conf_BlackoutGoodCnt_consecutive_times___} = <<EOF;
<li>Du fait que \$host a été présent sur le réseau au moins \$Conf{BlackoutGoodCnt}
fois consécutives, il ne sera pas sauvegardé de \$t0 à \$t1 pendant \$days.
EOF

$Lang{Backups_are_deferred_for_hours_hours_change_this_number} = <<EOF;
<li>Les sauvegardes sont reportées pour \$hours heures
(<a href=\"\$MyURL?action=Stop/Dequeue%20Backup&host=\$host\">changer ce nombre</a>).
EOF

$Lang{tryIP} = " et \$StatusHost{dhcpHostIP}";

$Lang{Host_Inhost} = "Hôte \$In{host}";

$Lang{checkAll} = <<EOF;
<tr bgcolor="#ffffcc"><td>
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;Tout sélectionner
</td><td colspan="5" align="center">
<input type="submit" name="Submit" value="Restaurer les fichiers sélectionnés">
</td></tr>
EOF

$Lang{fileHeader} = <<EOF;
    <tr bgcolor="\$Conf{CgiHeaderBgColor}"><td align=center> Nom</td>
       <td align="center"> Type</td>
       <td align="center"> Mode</td>
       <td align="center"> n°</td>
       <td align="center"> Taille</td>
       <td align="center"> Date de modification</td>
    </tr>
EOF

$Lang{Home} = "Accueil";
$Lang{Last_bad_XferLOG} = "Dernier bilan des transferts échouées";
$Lang{Last_bad_XferLOG_errors_only} = "Dernier bilan des transferts échouées (erreurs&nbsp;seulement)";

$Lang{This_display_is_merged_with_backup} = <<EOF;
<li> Cet affichage est fusionné avec la sauvegarde n°\$numF, la plus récente copie intégrale.
EOF

$Lang{Visit_this_directory_in_backup} = <<EOF;
<li> Explorer ce répertoire dans la sauvegarde no \$otherDirs.
EOF


$Lang{Restore_Summary} = <<EOF;
\${h2("Résumé de la restauration")}
<p>
Cliquer sur le numéro de restauration pour plus de détails.
<table border>
<tr><td align="center"> Sauvegarde n° </td>
    <td align="center"> Résultat </td>
    <td align="right"> Date de départ</td>
    <td align="right"> Durée/mins</td>
    <td align="right"> Nb fichiers </td>
    <td align="right"> Mo </td>
    <td align="right"> Nb errs tar </td>
    <td align="right"> Nb errs trans </td>
</tr>
\$restoreStr
</table>
<p>
EOF

$Lang{BackupPC__Documentation} = "BackupPC: Documentation";

$Lang{No} = "non";
$Lang{Yes} = "oui";

$Lang{The_directory_is_empty} = <<EOF;
<tr><td bgcolor="#ffffff">Le repertoire \${EscHTML(\$dirDisplay)} est vide
</td></tr>
EOF

#$Lang{on} = "actif";
$Lang{off} = "inactif";

$Lang{full} = "complet";
$Lang{incremental} = "incrémental";

$Lang{failed} = "échec";
$Lang{success} = "succès";
$Lang{and} = "et";

# ------
# Hosts states and reasons
$Lang{Status_idle} = "inactif";
$Lang{Status_backup_starting} = "début de la sauvegarde";
$Lang{Status_backup_in_progress} = "sauvegarde en cours";
$Lang{Status_restore_starting} = "début de la restoration";
$Lang{Status_restore_in_progress} = "restoration en cours";
$Lang{Status_link_pending} = "en attente de l'édition de liens";
$Lang{Status_link_running} = "édition de liens en cours";

$Lang{Reason_backup_done} = "sauvegarde terminée";
$Lang{Reason_restore_done} = "restauration terminée";
$Lang{Reason_nothing_to_do} = "rien à faire";
$Lang{Reason_backup_failed} = "la sauvegarde a échouée";
$Lang{Reason_restore_failed} = "la restauration a échouée";
$Lang{Reason_no_ping} = "pas de ping";
$Lang{Reason_backup_canceled_by_user} = "sauvegarde annulée par l'utilisateur";
$Lang{Reason_restore_canceled_by_user} = "restauration annulée par l'utilisateur";

# ---------
# Email messages

# No backup ever
$Lang{EMailNoBackupEverSubj} = "BackupPC: aucune sauvegarde de \$host n'a réussi";
$Lang{EMailNoBackupEverMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj

$userName,

Notre logiciel de copies de sécurité n'a jamais réussi à
prendre de sauvegarde de votre ordinateur ($host). Les sauvegardes
devraient normallement survenir lorsque votre ordinateur est connecté
au réseau. Vous devriez contacter le support informatique si:

  - Votre ordinateur est régulièrement connecté au réseau, ce qui
    signifie qu'il y aurait un problème de configuration
    empêchant les sauvegardes de s'effectuer.

  - Vous ne voulez pas qu'il y ait de copies de sécurité de
    votre ordinateur ni ne voulez recevoir d'autres messages
    comme celui-ci.

Autrement, veuillez vous assurer que votre ordinateur est connecté
au réseau lorsque ce sera possible.

Merci de votre attention,
BackupPC Genie
http://backuppc.sourceforge.net
EOF

# No recent backup
$Lang{EMailNoBackupRecentSubj} = "BackupPC: auncune sauvegarde récente de \$host";
$Lang{EMailNoBackupRecentMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj

$userName,

Aucune sauvegarde de votre ordinateur n'a été effectuée depuis $days
jours. $numBackups sauvegardes ont étés effectuées du $firstTime
jusqu'il y à $days jours. Les sauvegardes devraient normallement
survenir lorsque votre ordinateur est connecté au réseau.

Si votre ordinateur a été connecté au réseau plus de quelques heures
durant les derniers $days jours, vous devriez contacter votre support
informatique pour savoir pourquoi les sauvegardes ne s'effectuent pas.

Autrement, si vous êtes en dehors du bureau, il n'y a pas d'autres
choses que vous pouvez faire, à part faire des copies de vos fichiers
importants sur d'autres media. Vous devez réaliser que tout fichier crée
ou modifié durant les $days derniers jours (incluant les courriels et
les fichiers attachés) ne pourra être restauré si une problème survient
avec votre ordinateur.

Merci de votre attention,
BackupPC Genie
http://backuppc.sourceforge.net
EOF

# Old Outlook files
$Lang{EMailOutlookBackupSubj} = "BackupPC: Les fichiers de Outlook sur \$host doivent êtes sauvegardés";
$Lang{EMailOutlookBackupMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj

$userName,

Les fichiers Outlook sur votre ordinateur n'ont $howLong. Ces fichiers
contiennent tous vos courriels, fichiers attachés, carnets d'adresses et
calendriers. $numBackups sauvegardes ont étés effectuées du $firstTime
au $lastTime.  Par contre, Outlook bloque ses fichiers lorsqu'il est
ouvert, ce qui empêche de les sauvegarder.

Il est recommendé d'effectuer une sauvegarde de vos fichiers Outlook
quand vous serez connecté au réseau en quittant Outlook et tout autre
application, et en visitant ce lien avec votre fureteur web:

    $CgiURL?host=$host               

Choisissez "Démarrer la sauvegarde incrémentale" deux fois afin
d'effectuer une nouvelle sauvegarde. Vous pouvez ensuite choisir
"Retourner à la page de $host" et appuyer sur "Recharger" dans votre
fureteur avec de vérifier le bon fonctionnement de la sauvegarde. La
sauvegarde devrait prendre quelques minutes à s'effectuer.

Merci de votre attention,
BackupPC Genie
http://backuppc.sourceforge.net
EOF

$Lang{howLong_not_been_backed_up} = "jamais étés sauvegardés";
$Lang{howLong_not_been_backed_up_for_days_days} = "pas été sauvegardés depuis \$days jours";

#end of lang_fr.pm
