#!/usr/bin/perl -w

#my %lang;
#use strict;

# --------------------------------

$Lang{Start_Full_Backup} = "D�marrer sauvegarde compl�te";
$Lang{Start_Incr_Backup} = "D�part de la sauvegarde incr�mentale";
$Lang{Stop_Dequeue_Backup} = "Arr�ter/annuler sauvegarde";
$Lang{Restore} = "Restore";

# -----

$Lang{H_BackupPC_Server_Status} = "Status du serveur BackupPC";
$Lang{BackupPC_Server_Status}= <<EOF;

\${h1(qq{$Lang{H_BackupPC_Server_Status}})}
<p>
\${h2(\"Informations G�n�rales du serveur\")}

<ul>
<li> Le PID du serveur est \$Info{pid}, sur l\'h�te \$Conf{ServerHost},
     version \$Info{Version}, d�marr� le \$serverStartTime.
<li> Ce rapport � �t� g�n�r� le \$now.
<li> La prochaine file d\'attente sera remplie le \$nextWakeupTime.
<li> Autres info:
    <ul>
        <li>\$numBgQueue demandes de sauvegardes en attente depuis le dernier r�veil automatique,
        <li>\$numUserQueue requ�tes de sauvegardes utilisateur en attente,
        <li>\$numCmdQueue requ�tes de commandes en attente,
        \$poolInfo
        <li>L\'espace de stockage a �t� r�cemment rempli � \$Info{DUlastValue}%
            (\$DUlastTime), le maximum d\'aujourd\'hui est \$Info{DUDailyMax}% (\$DUmaxTime)
            et hier le maximum �tait \$Info{DUDailyMaxPrev}%.
    </ul>
</ul>

\${h2("Travaux en cours d'ex�cution")}
<p>
<table border>
<tr><td> H�te </td>
    <td> Type </td>
    <td> Utilisateur </td>
    <td> Date de d�part </td>
    <td> Commande </td>
    <td align="center"> PID </td>
    <td> Xfer PID </td>
    \$tarPidHdr</tr>
\$jobStr
</table>
<p>

\${h2("�checs qui demandent de l'attention")}
<p>
<table border>
<tr><td align="center"> H�te </td>
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
$Lang{BackupPC__Server_Summary} = "BackupPC: R�sum� du serveur";
$Lang{BackupPC_Summary}=<<EOF;

\${h1(qq{$Lang{BackupPC__Server_Summary}})}
<p>
Ce statut a �t� g�n�r� le \$now.
<p>

\${h2("H�tes avec de bonnes sauvegardes")}
<p>
Il y a \$hostCntGood h�tes ayant �t� sauvegard�s, avec un total de :
<ul>
<li> \$fullTot sauvegardes compl�tes de tailles cumul�es \${fullSizeTot} Go
     (pr�c�dant le hachage et la compression),
<li> \$incrTot sauvegardes incr�mentales de tailles cumul�es \${incrSizeTot} Go
     (pr�c�dant le hachage et la compression).
</ul>
<table border>
<tr><td> H�te </td>
    <td align="center"> Utilisateur </td>
    <td align="center"> nb compl�tes </td>
    <td align="center"> compl�tes �ge/Jours </td>
    <td align="center"> compl�tes Taille/Go </td>
    <td align="center"> Vitesse Mo/sec </td>
    <td align="center"> nb incr�mentales </td>
    <td align="center"> Incr Age/Jours </td>
    <td align="center"> �tat actuel</td>
    <td align="center"> Derni�re tentative </td></tr>
\$strGood
</table>
<p>

\${h2("H�tes sans sauvegardes")}
<p>
Il y a \$hostCntNone h�tes sans sauvegardes.
<p>
<table border>
<tr><td> H�te </td>
    <td align="center"> Utilisateur </td>
    <td align="center"> Nb compl�tes </td>
    <td align="center"> Compl�tes Age/jour </td>
    <td align="center"> Compl�tes Taille/Go </td>
    <td align="center"> Vitesse Mo/sec </td>
    <td align="center"> Nb incr�mentales </td>
    <td align="center"> Incr�mentales Age/jours </td>
    <td align="center"> �tat actuel </td>
    <td align="center"> Derni�re tentative </td></tr>
\$strNone
</table>
EOF

# -----------------------------------
$Lang{Pool_Stat} = <<EOF;
        <li>Le disque dispose de \${poolSize} Go avec \$info->{"\${name}FileCnt"} fichiers
            et \$info->{"\${name}DirCnt"} repertoires (depuis le \$poolTime),
        <li>Le hachage des fichiers donne \$info->{"\${name}FileCntRep"} fichiers r�p�t�s
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
La r�ponse du serveur a �t�: \$reply
<p>
Retourner � la page d\'accueil de <a href="\$MyURL?host=\$host">\$host</a>.
EOF
# --------------------------------
$Lang{BackupPC__Start_Backup_Confirm_on__host} = "BackupPC: Confirmation du d�part de la sauvegarde de \$host";
# --------------------------------
$Lang{Are_you_sure_start} = <<EOF;
\${h1("�tes vous sur")}
<p>
Vous allez bient�t d�marrer une sauvegarde <i>\$type</i> depuis \$host.

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
$Lang{BackupPC__Stop_Backup_Confirm_on__host} = "BackupPC: Confirmer l\'arr�t de la sauvegarde sur \$host";
# --------------------------------
$Lang{Are_you_sure_stop} = <<EOF;

\${h1("�tes vous sur ?")}

<p>
Vous �tes sur le point d\'arr�ter/supprimer de la file les sauvegardes de \$host;

<form action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="doit" value="1">
En outre, pri�re de ne pas d�marrer d\'autres sauvegarde avant
<input type="text" name="backoff" size="10" value="\$backoff"> heures.
<p>
Voulez vous vraiment le faire ?
<input type="submit" value="\$In{action}" name="action">
<input type="submit" value="Non" name="">
</form>

EOF
# --------------------------------
$Lang{Only_privileged_users_can_view_queues_} = "Seuls les utilisateurs privil�gi�s peuvent voir les files.";
# --------------------------------
$Lang{BackupPC__Queue_Summary} = "BackupPC: R�sum� de la file";
# --------------------------------
$Lang{Backup_Queue_Summary} = <<EOF;
\${h1("R�sum� de la file")}
<p>
\${h2("R�sum� des files des utilisateurs")}
<p>
Les demandes utilisateurs suivantes sont actuellement en attente :
<table border>
<tr><td> H�te </td>
    <td> Temps Requis </td>
    <td> Utilisateur </td></tr>
\$strUser
</table>
<p>

\${h2("R�sum� de la file en arri�re plan")}
<p>
Les demandes en arri�re plan suivantes sont actuellement en attente :
<table border>
<tr><td> H�te </td>
    <td> Temps requis </td>
    <td> Utilisateur </td></tr>
\$strBg
</table>
<p>

\${h2("R�sum� de la file d\'attente des commandes")}
<p>
Les demandes de commande suivantes sont actuellement en attente :
<table border>
<tr><td> H�tes </td>
    <td> Temps Requis </td>
    <td> Utilisateur </td>
    <td> Commande </td></tr>
\$strCmd
</table>
EOF
# --------------------------------
$Lang{Backup_PC__Log_File__file} = "BackupPC: Fichier de log \$file";
$Lang{Log_File__file__comment} = <<EOF;
"Fichier de log \$file \$comment";
<p>
EOF
# --------------------------------
$Lang{Contents_of_log_file} = <<EOF;
Contenu du fichier de log <tt>\$file</tt>, modifi� le \$mtimeStr \$comment
EOF

# --------------------------------
$Lang{skipped__skipped_lines} = "[ \$skipped lignes saut�es ]\n";
# --------------------------------
$Lang{_pre___Can_t_open_log_file__file} = "<pre>\nNe peut pas ouvrir le fichier de log \$file\n";

# --------------------------------
$Lang{BackupPC__Log_File_History} = "BackupPC: Historique du fichier de log";
$Lang{Log_File_History__hdr} = <<EOF;
\${h1("Historique du fichier de log \$hdr")}
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
\${h1("R�sum� des emails r�cents (Du plus r�cent au plus vieux)")}
<p>
<table border>
<tr><td align="center"> Recipient </td> <!-- FIXME -->
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
<p>
Vous avez s�lectionn� les fichiers/repertoires suivants depuis le partage 
\$share, sauvegarde num�ro \$num:
<ul>
\$fileListStr
</ul>
<p>
Vous avez trois choix pour restaurer ces fichiers/repertoires.
Veuillez s�lectionner une des options suivantes.
<p>
\${h2("Option 1: Restauration directe")}
<p>
Vous pouvez d�marrer une restauration qui va restaurer ces fichiers 
directement sur \$host.
<p>
<b>Attention:</b>
tout les fichiers correspondant � ceux que vous avez s�lectionn�s vont �tre effac�s !

<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscapeHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="3">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<table border="0">
<tr>
    <td>Restaurer les fichiers vers l\'h�te</td>
    <td><input type="text" size="40" value="\${EscapeHTML(\$host)}"
	 name="hostDest"></td>
</tr><tr>
    <td>Restaurer les fichiers vers le partage</td>
    <td><input type="text" size="40" value="\${EscapeHTML(\$share)}"
	 name="shareDest"></td>
</tr><tr>
    <td>Restaurer les fichiers du r�pertoire<br>(relatif au partage)</td>
    <td valign="top"><input type="text" size="40" maxlength="256"
	value="\${EscapeHTML(\$pathHdr)}" name="pathHdr"></td>
</tr><tr>
    <td><input type="submit" value="D�marrer la restauration" name=""></td>
</table>
</form>
EOF


# ------------------------------
$Lang{Option_2__Download_Zip_archive} = <<EOF;

\${h2("Option 2: T�l�charger l\'archive compress�e")}
<p>
Vous pouvez t�l�charger une archive zipp�e contenant tous les fichiers/r�pertoires que vous 
avez s�lectionn�s. Vous pouvez utiliser une application locale, comme <i>Winzip</i>, pour 
voir ou extraire n\'importe quel fichier.
<p>
<b>Attention:</b> en fonction de quels fichiers/r�pertoires vous avez s�lectionn�,
cette archive peut devenir tr�s tr�s large.  Cela peut prendre plusieurs minutes pour cr�er
et transf�rer cette archive, et vous aurez besoin d\'assez d\'espace disque pour le stocker.
<p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscapeHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="2">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Faire l\'archive relative �
\${EscapeHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(Autrement l\'archive contiendra les chemins complets).
<br>
Compression (0=d�sactiv�e, 1=rapide,...,9=meilleure)
<input type="text" size="6" value="5" name="compressLevel">
<br>
<input type="submit" value="T�l�charger le fichier zipp�" name="">
</form>
EOF


# ------------------------------

$Lang{Option_2__Download_Zip_archive2} = <<EOF;
\${h2("Option 2: T�l�charger une archive zipp�e")}
<p>
Vous pouvez t�l�charger une archive zipp�e, mais Archive::Zip n\'est pas
install�. Vous pouvez demander � votre administrateur syst�me d\'installer 
Archive::Zip depuis <a href="http://www.cpan.org">www.cpan.org</a>.
<p>
EOF


# ------------------------------
$Lang{Option_3__Download_Zip_archive} = <<EOF;
\${h2("Option 3: T�l�charger une archive tar")}
<p>

Vous pouvez t�l�charger une archive Tar contenant tous les fichiers/r�pertoires 
que vous avez s�lectionn�s. Vous pouvez alors utiliser une application locale, 
comme <i>tar</i> ou <i>winzip</i> pour voir ou extraire n\'importe quel fichier.
<p>
<b>Attention:</b> en fonction des fichiers/r�pertoires que vous avez s�lectionn�s,
cette archive peut devenir tr�s tr�s large.  Cela peut prendre beaucoup de temps 
(plusieurs minutes) pour cr�er et transf�rer l\'archive, et vous aurez besoin de beaucoup
d\'espace disque local pour le stocker.
<p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscapeHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="1">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Faire l\'archive relative �
\${EscapeHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(Autrement l\'archive contiendra des chemins absolus).
<br>
<input type="submit" value="T�l�charger le fichier Tar" name="">
</form>
EOF



# ------------------------------
$Lang{Restore_Confirm_on__host} = "BackupPC: Confirmation de restauration sur \$host";

$Lang{Are_you_sure} = <<EOF;
\${h1("�tes-vous sur ?")}
<p>
Vous �tes sur le point de d�marrer une restauration directement sur la machine 
\$In{hostDest}.
Les fichiers suivants vont �tre restaur�s dans le partage \$In{shareDest}, depuis
la sauvegarde num�ro \$num:
<p>
<table border>
<tr><td>Fichier/R�pertoire original</td><td>Va �tre restaur� �</td></tr>
\$fileListStr
</table>

<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscapeHTML(\$host)}">
<input type="hidden" name="hostDest" value="\${EscapeHTML(\$In{hostDest})}">
<input type="hidden" name="shareDest" value="\${EscapeHTML(\$In{shareDest})}">
<input type="hidden" name="pathHdr" value="\${EscapeHTML(\$In{pathHdr})}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="4">
\$hiddenStr
Voulez-vous vraiment le faire ?
<input type="submit" value="\$In{action}" name="action">
<input type="submit" value="Non" name="">
</form>
EOF

# --------------------------
$Lang{Restore_Requested_on__hostDest} = "BackupPC: Restauration demand�e sur \$hostDest";
$Lang{Reply_from_server_was___reply} = <<EOF;
\${h1(\$str)}
<p>
La r�ponse du serveur est: \$reply
<p>
Retourner � la page d\'acceuil de <a href="\$MyURL?host=\$hostDest">\$hostDest </a>.
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

\${h2("Actions de l\'utilisateur")}
<p>
<form action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
\$startIncrStr
<input type="submit" value="$Lang{Start_Full_Backup}" name="action">
<input type="submit" value="$Lang{Stop_Dequeue_Backup}" name="action">
</form>

\${h2("R�sum� de la sauvegarde")}
<p>
Cliquer sur le num�ro de l\'archive pour naviguer et restaurer les fichiers de sauvegarde.
<table border>
<tr><td align="center"> Sauvegarde n� </td>
    <td align="center"> Type </td>
    <td align="center"> termin�e </td> 
    <td align="center"> Date de d�marrage </td>
    <td align="center"> Dur�e/mins </td>
    <td align="center"> Age/jours </td>
    <td align="center"> Chemin d\'acc�s sauvegarde sur serveur </td>
</tr>
\$str
</table>
<p>

\$restoreStr

\${h2("R�sum� des erreurs de transfert")}
<p>
<table border>
<tr><td align="center"> Nb sauvegarde </td>
    <td align="center"> Type </td>
    <td align="center"> View </td> <!-- FIXME -->
    <td align="center"> Nb erreurs transfert </td>
    <td align="center"> Nb mauvais fichiers </td>
    <td align="center"> Nb mauvais partages </td>
    <td align="center"> Nb erreurs tar </td>
</tr>
\$errStr
</table>
<p>

\${h2("R�sum� de Taille fichier/Nombre de r�utilisations")}
<p>
    Les fichiers existants sont ceux qui sont d�j� sur le serveur; 
Les nouveaux fichiers sont ceux qui ont �t� ajout�s au serveur.
Les fichiers vides et les erreurs de SMB ne sont pas comptabilis�s parmis
les nouveaux et les r�utilis�s.

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
    <td align="center"> Taille/MB </td>
    <td align="center"> Nb de Fichiers </td>
    <td align="center"> Taille/Mo </td>
</tr>
\$sizeStr
</table>
<p>

\${h2("R�sum� de la compression")}
<p>

Performance de compression pour les fichiers d�j� sur le serveur et
r�cemment compress�s.

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
    <td align="center"> Comp </td>
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
<li> Vous naviguez dans la sauvegarde n�\$num, qui a commenc� vers \$backupTime
        (il y a \$backupAge jours),
\$filledBackup
<li> Cliquer dans un r�pertoire ci-dessous pour naviguer dedans,
<li> Cliquer dans un fichier ci-dessous pour le restaurer..
</ul>

\${h2("Contenu de \${EscapeHTML(\$dirDisplay)}")}
<form name="form1" method="post" action="\$MyURL">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="host" value="\$host">
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

# FIXME
$Lang{Restore___num_details_for__host} = "BackupPC: Restore #\$num details for \$host"; 

$Lang{Restore___num_details_for__host2 } = <<EOF;

# FIXME
\${h1("Restore #\$num Details for \$host")} 
<p>
<table border>
<tr><td> Number </td><td> \$Restores[\$i]{num} </td></tr>
<tr><td> Requested by </td><td> \$RestoreReq{user} </td></tr>
<tr><td> Request time </td><td> \$reqTime </td></tr>
<tr><td> Result </td><td> \$Restores[\$i]{result} </td></tr>
<tr><td> Error Message </td><td> \$Restores[\$i]{errorMsg} </td></tr>
<tr><td> Source host </td><td> \$RestoreReq{hostSrc} </td></tr>
<tr><td> Source backup num </td><td> \$RestoreReq{num} </td></tr>
<tr><td> Source share </td><td> \$RestoreReq{shareSrc} </td></tr>
<tr><td> Destination host </td><td> \$RestoreReq{hostDest} </td></tr>
<tr><td> Destination share </td><td> \$RestoreReq{shareDest} </td></tr>
<tr><td> Start time </td><td> \$startTime </td></tr>
<tr><td> Duration </td><td> \$duration min </td></tr>
<tr><td> Number of files </td><td> \$Restores[\$i]{nFiles} </td></tr>
<tr><td> Total size </td><td> \${MB} Mo </td></tr>
<tr><td> Transfer rate </td><td> \$MBperSec Mo/sec </td></tr>
<tr><td> TarCreate errors </td><td> \$Restores[\$i]{tarCreateErrs} </td></tr>
<tr><td> Xfer errors </td><td> \$Restores[\$i]{xferErrs} </td></tr>
<tr><td> Xfer log file </td><td>
<a href="\$MyURL?action=view&type=RestoreLOG&num=\$Restores[\$i]{num}&host=\$host">View</a>, <!-- FIXME -->
<a href="\$MyURL?action=view&type=RestoreErr&num=\$Restores[\$i]{num}&host=\$host">Erreurs</a>
</tr></tr>
</table>
<p>
\${h1("Liste Fichiers/R�pertoires")}
<p>
<table border>
<tr><td>Fichier/r�pertoire original</td><td>Restaur� vers</td></tr>
\$fileListStr
</table>
EOF


# -----------------------------------
$Lang{Email_Summary} = "BackupPC: R�sum� du courrier �lectronique";

# -----------------------------------
#  !! ERROR messages !!
# -----------------------------------

$Lang{BackupPC__Lib__new_failed__check_apache_error_log} = "BackupPC::Lib->new a �chou�: regardez le "
    ."fichier error_log d\'apache\n";
$Lang{Wrong_user__my_userid_is___} =  
              "Mauvais utilisateur: mon userid est \$>, � la place de \$uid"
            . "(\$Conf{BackupPCUser})\n";
$Lang{Only_privileged_users_can_view_PC_summaries} = "Seuls les utilisateurs privil�gi�s peuvent "
    . "voir les r�sum�s des PC.";
$Lang{Only_privileged_users_can_stop_or_start_backups} = 
                  "Seuls les utilisateurs privil�gi�s peuvent arr�ter ou d�marrer des sauvegardes sur"
		. " \${EscapeHTML(\$host)}.";
$Lang{Invalid_number__num} = "Num�ro invalide \$num";
$Lang{Unable_to_open__file__configuration_problem} = "Impossible d\'ouvrir \$file: un probl�me de configuration ?";
$Lang{Only_privileged_users_can_view_log_or_config_files} = "Seuls les utilisateurs privil�gi�s peuvent voir "
    ."les log ou les fichiers de configuration.";
$Lang{Only_privileged_users_can_view_log_files} = "Seuls les utilisateurs privil�gi�s peuvent voir les fichiers de log.";
$Lang{Only_privileged_users_can_view_email_summaries} = "Seuls les utilisateurs privil�gi�s peuvent "
    ."voir les compte-rendu des courriers �lectroniques.";
$Lang{Only_privileged_users_can_browse_backup_files} = "Seuls les utilisateurs privil�gi�s peuvent parcourir "
                . "les fichiers de sauvegarde pour l'h�te \${EscapeHTML(\$In{host})}.";
$Lang{Empty_host_name} = "Nom d\'h�te vide.";
$Lang{Can_t_browse_bad_directory_name} = "Ne peut pas parcourir " 
	            . " \${EscapeHTML(\"\$TopDir/pc/\$host/\$num\")}:"
                    . " mauvais nom de r�pertoire";
$Lang{Directory___EscapeHTML} = "Le r�pertoire \${EscapeHTML(\"\$TopDir/pc/\$host/\$num\")}"
		    . " est vide";
$Lang{Can_t_browse_bad_directory_name2} = "Ne peut pas parcourir "
	            . " \${EscapeHTML(\$fullDir)}:"
                    . " mauvais nom de r�pertoire";
$Lang{Only_privileged_users_can_restore_backup_files} = "Seuls les utilisateurs privil�gi�s peuvent restaurer "
                . " des fichiers de sauvegarde"
                . " pour l\'h�te \${EscapeHTML(\$In{host})}.";
$Lang{Bad_host_name} = "Mauvais nom d\'h�te \${EscapeHTML(\$host)}";
$Lang{You_haven_t_selected_any_files__please_go_Back_to} = "Vous n'avez s�lectionn� aucun fichier; "
    . "vous pouvez revenir en arri�re pour s�lectionner des fichiers.";
$Lang{Nice_try__but_you_can_t_put} = "Bien tent�, mais vous ne pouvez pas mettre \'..\' dans"
                                   . " n\'importe quel nom de fichier.";
$Lang{Can_t_fork_for_tar_restore} = "Ne peut pas se dupliquer (fork) pour la restauration par tar";
$Lang{Can_t_fork_for_zip_restore} = "Ne peut pas se dupliquer (fork) pour la restauration par zip";
$Lang{Host__doesn_t_exist} = "L'h�te \${EscapeHTML(\$In{hostDest})} n\'existe pas.";
$Lang{You_don_t_have_permission_to_restore_onto_host} = "Vous n\'avez pas la permission de restaurer sur l\'h�te"
		    . " \${EscapeHTML(\$In{hostDest})}";
$Lang{Can_t_open_create} = "Ne peut pas ouvrir/cr�er "
                    . "\${EscapeHTML(\"\$TopDir/pc/\$hostDest/\$reqFileName\")}";
$Lang{Only_privileged_users_can_restore_backup_files2} = "Seuls les utilisateurs privil�gi�s peuvent restaurer"
                . " des fichiers de sauvegarde"
                . " pour l\'h�te \${EscapeHTML(\$host)}.";
$Lang{Empty_host_name} = "Nom d\'h�te vide";
$Lang{Can_t_restore_bad_file} = "Ne peut pas restaurer le fichier corrompu \${EscapeHTML(\$fullPath)}";
$Lang{Unknown_host_or_user} = "\${EscapeHTML(\$host)}, h�te ou utilisateur inconnu.";
$Lang{Only_privileged_users_can_view_information_about} = "Seuls les utilisateurs privil�gi�s peuvent acc�der aux "
                . " informations sur l\'h�te \${EscapeHTML(\$host)}." ;
$Lang{Only_privileged_users_can_view_restore_information} = "Seuls les utilisateurs privil�gi�s peuvent restaurer "
    ."des informations.";
$Lang{Restore_number__num_for_host__does_not_exist} = "Restauration num�ro \$num de l\'h�te \${EscapeHTML(\$host)} n\'"
    . "existe pas";

$Lang{Unable_to_connect_to_BackupPC_server} = "Impossible de se connecter au server BackupPC."
          . "Ce script CGI (\$MyURL) ne peut pas se connecter au serveur  BackupPC"
          . " sur \$Conf{ServerHost} via le port \$Conf{ServerPort}.  L\'erreur est la"
          . " suivante: \$err.",
            "Peut �tre BackupPC n\'a pas �t� lanc� ou il y a une erreur "
          . " de configuration. Vous pouvez faire suivre ce message � votre administrateur syst�me.";

$Lang{Can_t_find_IP_address_for} = "Ne peut pas trouver d\'adresse IP pour \${EscapeHTML(\$host)}";

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

# Ne pas m�langer $reply et $str cf vers ligne: 248

$Lang{Backup_requested_on_DHCP__host} = "Demande de sauvegarde sur l\'h�te \$host (\$In{hostIP}) par"
		                      . " \$User depuis \$ENV{REMOTE_ADDR}";
$Lang{Backup_requested_on__host_by__User} = "Sauvegarde demand�e sur \$host par \$User";
$Lang{Backup_stopped_dequeued_on__host_by__User} = "Sauvegarde Arr�t�e/d�programm�e pour \$host par \$User";

$Lang{log_Can_t_fork_for_tar_restore_request_by__User} = "log Ne peut pas se dupliquer (fork)"
    . " pour la restauration tar demand�e par \$User";
$Lang{log_User__User_downloaded_tar_archive_for__host} = "log L\'utilisateur \$User a t�l�charg� "
                           . "l\'archive tar pour \$host,"
                           . " sauvegarde \$num; Les fichiers �taient: "
			   . " \${join(\", \", \@fileListTrim)}";
$Lang{log_Can_t_fork_for_zip_restore_request_by__User} = "log Ne peut pas se dupliquer (fork)"
    . "pour la restauration zip demand�e par \$User";
$Lang{log_User__User_downloaded_zip_archive_for__host}= "log L\'utilisateur \$User a t�l�charg� "
                           . "l\'archive zip pour \$host,"
                           . " Sauvegarde \$num; Les fichiers �taient: "
                           . "\${join(\", \", \@fileListTrim)}";
$Lang{Restore_requested_to_host__hostDest__backup___num} = "Restauration demand�e pour l\'h�te \$hostDest, "
             . "sauvegarde n� \$num,"
	     . " par \$User depuis \$ENV{REMOTE_ADDR}";

##########################
##########################

#$Lang{backup__In_hostIP___host} = "Sauvegarde \$In{hostIP} \$host"
#                                . " \$User \$doFull";
#
#$Lang{backup__host__host__User__doFull} = "backup \$host \$host \$User \$doFull";
#$Lang{restore__ipAddr} = "Restauration \$ipAddr"
#                       . " \$hostDest \$User \$reqFileName";
#$Lang{stop__host__User__In_backoff} = "Arr�t \$host \$User \$In{backoff}";


# -------------------------------------------------
# ------- Stuff that was forgotten ----------------
# -------------------------------------------------

$Lang{Status} = "Status";
$Lang{PC_Summary} = "Bilan du PC";
$Lang{LOG_file} = "Fichier de LOG";
$Lang{Old_LOGs} = "Vieux LOGs";
$Lang{Email_summary} = "R�sum� des emails";
$Lang{Config_file} = "Fichier de configuration";
$Lang{Hosts_file} = "Fichiers des h�tes";
$Lang{Current_queues} = "Files actuelles";
$Lang{Documentation} = "Documentation";

$Lang{Host_or_User_name} = "<small>H�te ou Nom d\'utilisateur:</small>";
$Lang{Go} = "Chercher";
$Lang{Hosts} = "H�tes";

$Lang{This_PC_has_never_been_backed_up} = "<h2> Ce PC n'a jamais �t� sauvegard� !! </h2>\n";
$Lang{This_PC_is_used_by} = "<li>Ce PC est utilis� par \${UserLink(\$user)}";

# ------------
$Lang{Last_email_sent_to__was_at___subject} = <<EOF;
<li>Dernier email envoy� � \${UserLink(\$user)} le \$mailTime, avait comme sujet "\$subj".
EOF
# ------------
$Lang{The_command_cmd_is_currently_running_for_started} = <<EOF;
<li>La commande \$cmd s\'ex�cute actuellement sur \$host, d�marr�e le \$startTime.
EOF

# -----------
$Lang{Host_host_is_queued_on_the_background_queue_will_be_backed_up_soon} = <<EOF;
<li>L\'h�te \$host se trouve dans la liste d\'attente d\'arri�re plan (sera sauvegard� bient�t).
EOF

# ----------
$Lang{Host_host_is_queued_on_the_user_queue__will_be_backed_up_soon} = <<EOF;
<li>L\'h�te \$host se trouve dans la liste d\'attente utilisateur (sera sauvegard� bient�t).
EOF

# ---------
$Lang{A_command_for_host_is_on_the_command_queue_will_run_soon} = <<EOF;
<li>Une commande pour l\'h�te \$host est dans la liste d\'attente des commandes (sera lanc� bient�t).
EOF

# --------
$Lang{Last_status_is_state_StatusHost_state_reason_as_of_startTime} = <<EOF;
<li>L\'�tat courant est \"\$StatusHost{state}\"\$reason <!-- FIXME -->
    � compter du \$startTime.
EOF

# --------
$Lang{Last_error_is____EscapeHTML_StatusHost_error} = <<EOF;
<li>La derni�re erreur est \"\${EscapeHTML(\$StatusHost{error})}\"
EOF

# ------
$Lang{Pings_to_host_have_failed_StatusHost_deadCnt__consecutive_times} = <<EOF;
<li>Les pings vers \$host ont �chou�s \$StatusHost{deadCnt} fois cons�cutives.
EOF

# -----
$Lang{Prior_to_that__pings} = "Avant cela, pings";

# -----
$Lang{priorStr_to_host_have_succeeded_StatusHostaliveCnt_consecutive_times} = <<EOF;
<li>Les \$priorStr vers \$host ont r�ussi \$StatusHost{aliveCnt} fois cons�cutives.
EOF

$Lang{Because__host_has_been_on_the_network_at_least__Conf_BlackoutGoodCnt_consecutive_times___} = <<EOF;
<li>Du fait que \$host a �t� pr�sent sur le r�seau au moins \$Conf{BlackoutGoodCnt}
fois cons�cutives, il ne sera pas sauvegard� de \$t0 � \$t1 pendant \$days.
EOF

$Lang{Backups_are_deferred_for_hours_hours_change_this_number} = <<EOF;
<li>Les sauvegardes sont report�es pour \$hours heures
(<a href=\"\$MyURL?action=Stop/Dequeue%20Backup&host=\$host\">changer ce nombre</a>).
EOF

$Lang{info_jobs_hosts_queueLen} = "info t�ches h�tes queueLen";  # FIXME

$Lang{tryIP} = " et \$StatusHost{dhcpHostIP}";

$Lang{Host_Inhost} = "H�te \$In{host}";

$Lang{checkAll} = <<EOF;
<tr bgcolor="#ffffcc"><td>
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;Tout s�lectionner
</td><td colspan="4" align="center">
<input type="submit" name="Submit" value="Restaure les fichiers s�lectionn�s">
</td></tr>
EOF

$Lang{fileHeader} = <<EOF;
    <tr bgcolor="\$Conf{CgiHeaderBgColor}"><td align=center> Nom</td>
       <td align="center"> Type</td>
       <td align="center"> Mode</td>
       <td align="center"> Taille</td>
       <td align="center"> Date modification</td>
    </tr>
EOF

$Lang{Home} = "Accueil";
$Lang{Last_bad_XferLOG} = "Dernier bilan transmissions �chou�es";
$Lang{Last_bad_XferLOG_errors_only} = "Dernier bilan transmissions �chou�es (erreurs&nbsp;seulement)";

$Lang{This_display_is_merged_with_backup} = <<EOF;
<li> Cet affichage est regroup� avec la sauvegarde n�\$numF, la plus r�cente copie int�grale.
EOF

$Lang{Restore_Summary} = <<EOF;
\${h2("R�sum� de la restauration")}
<p>
Cliquer sur le num�ro de restauration pour plus de d�tails.
<table border>
<tr><td align="center"> Sauvegarde n� </td>
    <td align="center"> R�sultat </td>
    <td align="right"> Date de d�part</td>
    <td align="right"> Dur�e/mins</td>
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
<tr><td bgcolor="#ffffff">Le repertoire \${EscapeHTML(\$dirDisplay)} est vide
</td></tr>
EOF

$Lang{on} = "actif";
$Lang{off} = "inactif";

$Lang{full} = "complet";
$Lang{incremental} = "incr�mental";

$Lang{failed} = "�chec";
$Lang{success} = "succ�s";
$Lang{and} = "et";

#end of lang_fr.pm