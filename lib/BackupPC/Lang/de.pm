#!/bin/perl -T
#
# by Manfred Herrmann (V1.1) (some typo errors + 3 new strings)
# CVS-> Revision ???
#
#my %lang;

#use strict;

# --------------------------------

$Lang{Start_Full_Backup} = "Starte Backup vollständig";
$Lang{Start_Incr_Backup} = "Starte Backup incrementell";
$Lang{Stop_Dequeue_Backup} = "Stoppen/Aussetzen Backup";
$Lang{Restore} = "Wiederherstellung";

# -----

$Lang{H_BackupPC_Server_Status} = "BackupServer Server Status";

$Lang{BackupPC_Server_Status}= <<EOF;
\${h1(qq{$Lang{H_BackupPC_Server_Status}})}

<p>
\${h2(\"Allgemeine Server Information\")}

<ul>
<li> Die Server Prozess ID (PID) ist \$Info{pid},  auf Computer \$Conf{ServerHost},
     Version \$Info{Version}, gestartet am \$serverStartTime.
<li> Dieser Status wurde am \$now generiert.
<li> Computer werden am \$nextWakeupTime auf neue Aufträge geprüft.
<li> Weitere Informationen:
    <ul>
        <li>\$numBgQueue wartende backup Aufträge der letzten Prüfung,
        <li>\$numUserQueue wartende Aufträge von Benutzern,
        <li>\$numCmdQueue wartende Kommando Aufträge.
        \$poolInfo
        <li>Das Pool Filesystem (Backup-Speicherplatz) ist zu \$Info{DUlastValue}%
            (\$DUlastTime) gefüllt, das Maximum-Heute ist \$Info{DUDailyMax}% (\$DUmaxTime)
            und Maximum-Gestern war \$Info{DUDailyMaxPrev}%. (Hinweis: sollten ca. 70% überschritten werden, so
	    ist evtl. bald eine Erweiterung des Backup-Speichers erforderlich. Planung erforderlich?)
    </ul>
</ul>

\${h2("Aktuell laufende Aufträge")}
<p>
<table border>
<tr><td> Computer </td>
    <td> Typ </td>
    <td> User </td>
    <td> Startzeit </td>
    <td> Kommando </td>
    <td align="center"> PID </td>
    <td align="center"> Transport PID </td>
    </tr>
\$jobStr
</table>
<p>

\${h2("Fehler, die näher analysiert werden müssen!")}
<p>
<table border>
<tr><td align="center"> Computer </td>
    <td align="center"> Typ </td>
    <td align="center"> User </td>
    <td align="center"> letzter Versuch </td>
    <td align="center"> Details </td>
    <td align="center"> Fehlerzeit </td>
    <td> Letzter Fehler (außer "kein ping") </td></tr>
\$statusStr
</table>
EOF

# --------------------------------
$Lang{BackupPC__Server_Summary} = "BackupServer: Übersicht";
$Lang{BackupPC_Summary}=<<EOF;

\${h1(qq{$Lang{BackupPC__Server_Summary}})}
<p>
Dieser Status wurde generiert am \$now.
<p>

\${h2("Computer mit erfolgreichen Backups")}
<p>
Es gibt \$hostCntGood Computer die erfolgreich gesichert wurden, mit insgesamt:
<ul>
<li> \$fullTot Voll Backups, Gesamtgröße \${fullSizeTot}GB
     (vor pooling und Komprimierung),
<li> \$incrTot Incrementelle Backups, Gesamtgröße \${incrSizeTot}GB
     (vor pooling und Komprimierung).
</ul>
<table border>
<tr><td> Computer </td>
    <td align="center"> User </td>
    <td align="center"> #Voll </td>
    <td align="center"> Alter/Tage </td>
    <td align="center"> Größe/GB </td>
    <td align="center"> MB/sec </td>
    <td align="center"> #Incr </td>
    <td align="center"> Alter/Tage </td>
    <td align="center"> Status </td>
    <td align="center"> Letzte Aktion </td></tr>
\$strGood
</table>
<p>

\${h2("Computer ohne Backups")}
<p>
Es gibt \$hostCntNone Computer ohne Backups !!!.
<p>
<table border>
<tr><td> Computer </td>
    <td align="center"> User </td>
    <td align="center"> #Voll </td>
    <td align="center"> Alter/Tage </td>
    <td align="center"> Größe/GB </td>
    <td align="center"> MB/sec </td>
    <td align="center"> #Incr </td>
    <td align="center"> Alter/Tage </td>
    <td align="center"> Status </td>
    <td align="center"> Letzter Versuch </td></tr>
\$strNone
</table>
EOF

# -----------------------------------
$Lang{Pool_Stat} = <<EOF;
        <li>Der Pool hat eine Größe von \${poolSize}GB und enthält \$info->{"\${name}FileCnt"} Dateien und \$info->{"\${name}DirCnt"} Verzeichnisse (Stand \$poolTime).
        <li>Das "Pool hashing" ergibt \$info->{"\${name}FileCntRep"} wiederholte
            Dateien mit der längsten Verkettung von \$info->{"\${name}FileRepMax"}.
        <li>Die nächtliche Bereinigung entfernte \$info->{"\${name}FileCntRm"} Dateien mit
            einer Größe von \${poolRmSize}GB (um ca. \$poolTime).
EOF

# --------------------------------
$Lang{BackupPC__Backup_Requested_on__host} = "BackupServer: Backup Auftrag für \$host";
# --------------------------------
$Lang{REPLY_FROM_SERVER} = <<EOF;
\${h1(\$str)}
<p>
Die Antwort des Servers war: \$reply
<p>
Gehe zurück zur <a href="\$MyURL?host=\$host">\$host home page</a>.
EOF
# --------------------------------
$Lang{BackupPC__Start_Backup_Confirm_on__host} = "BackupServer: Starte Backup Bestätigung für \$host";
# --------------------------------
$Lang{Are_you_sure_start} = <<EOF;
\${h1("Sind Sie sicher?")}
<p>
Sie starten ein \$type Backup für \$host.

<form action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="hostIP" value="\$ipAddr">
<input type="hidden" name="doit" value="1">
Möchten Sie das wirklich tun?
<input type="submit" value="\$In{action}" name="action">
<input type="submit" value="Nein" name="">
</form>
EOF
# --------------------------------
$Lang{BackupPC__Stop_Backup_Confirm_on__host} = "BackupServer: Beende Backup Bestätigung für \$host";
# --------------------------------
$Lang{Are_you_sure_stop} = <<EOF;

\${h1("Sind Sie sicher?")}

<p>
Sie werden Backups abbrechen bzw. Aufträge löschen für Computer \$host;

<form action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="doit" value="1">
Zusätzlich bitte keine Backups starten für die Dauer von 
<input type="text" name="backoff" size="10" value="\$backoff"> Stunden.
<p>
Möchten Sie das wirklich tun?
<input type="submit" value="\$In{action}" name="action">
<input type="submit" value="Nein" name="">
</form>

EOF
# --------------------------------
$Lang{Only_privileged_users_can_view_queues_} = "Nur berechtigte User können die Warteschlangen einsehen.";
# --------------------------------
$Lang{BackupPC__Queue_Summary} = "BackupServer: Warteschlangen Übersicht";
# --------------------------------
$Lang{Backup_Queue_Summary} = <<EOF;
\${h1("Backup Warteschlangen Übersicht")}
<p>
\${h2("User Warteschlange Übersicht")}
<p>
Die folgenden User Aufträge sind eingereiht:
<table border>
<tr><td> Computer </td>
    <td> Uhrzeit </td>
    <td> User </td></tr>
\$strUser
</table>
<p>

\${h2("Hintergrund Warteschlange Übersicht")}
<p>
Die folgenden Hintergrund Aufträge sind eingereiht:
<table border>
<tr><td> Computer </td>
    <td> Uhrzeit </td>
    <td> User </td></tr>
\$strBg
</table>
<p>

\${h2("Kommando Warteschlange Übersicht")}
<p>
Die folgenden Kommando Aufträge sind eingereiht:
<table border>
<tr><td> Computer </td>
    <td> Uhrzeit </td>
    <td> User </td>
    <td> Kommando </td></tr>
\$strCmd
</table>
EOF

# --------------------------------
$Lang{Backup_PC__Log_File__file} = "BackupServer: LOG Datei \$file";
$Lang{Log_File__file__comment} = <<EOF;
\${h1("LOG Datei \$file \$comment")}
<p>
EOF
# --------------------------------
$Lang{Contents_of_log_file} = <<EOF;
Inhalt der LOG Datei <tt>\$file</tt>, verändert am \$mtimeStr \$comment
EOF

# --------------------------------
$Lang{skipped__skipped_lines} = "[ überspringe \$skipped Zeilen ]\n";
# --------------------------------
$Lang{_pre___Can_t_open_log_file__file} = "<pre>\nKann LOG Datei nicht öffnen \$file\n";

# --------------------------------
$Lang{BackupPC__Log_File_History} = "BackupServer: LOG Datei Historie";
$Lang{Log_File_History__hdr} = <<EOF;
\${h1("LOG Datei Historie \$hdr")}
<p>
<table border>
<tr><td align="center"> Datei </td>
    <td align="center"> Größe </td>
    <td align="center"> letzte Änderung </td></tr>
\$str
</table>
EOF

# -------------------------------
$Lang{Recent_Email_Summary} = <<EOF;
\${h1("Letzte e-mail Übersicht (Sortierung nach Zeitpunkt)")}
<p>
<table border>
<tr><td align="center"> Empfänger </td>
    <td align="center"> Computer </td>
    <td align="center"> Zeitpunkt </td>
    <td align="center"> Titel </td></tr>
\$str
</table>
EOF
 

# ------------------------------
$Lang{Browse_backup__num_for__host} = "BackupServer: Browsen des Backups \$num für Computer \$host";

# ------------------------------
$Lang{Restore_Options_for__host} = "BackupServer: Restore Optionen für \$host";
$Lang{Restore_Options_for__host2} = <<EOF;
<p>
Sie haben die folgenden Dateien/Verzeichnisse von Freigabe \$share selektiert, von Backup Nummer #\$num:
<ul>
\$fileListStr
</ul>
<p>
Sie haben drei verschiedene Möglichkeiten zur Wiederherstellung (Restore) der Dateien/Verzeichnisse.
Bitte wählen Sie eine der folgenden Möglichkeiten:.
<p>
\${h2("Möglichkeit 1: Direct Restore")}
<p>
Sie können diese Wiederherstellung starten um die Dateien/Verzeichnisse direkt auf den Computer  
\$host wiederherzustellen. Alternativ können Sie einen anderen Computer und/oder Freigabe als Ziel angeben.
<p>
<b><font color="#FF0000">Warnung:</font></b> alle aktuell existierenden Dateien/Verzeichnisse die bereits vorhanden sind
werden überschrieben! (Tip: alternativ eine spezielle Freigabe erstellen mit schreibrecht für den
Backup-User und die wiederhergestellten Dateien/Verzeichnisse durch Stichproben prüfen, ob die beabsichtigte
Wiederherstellung korrekt ist) 

<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="3">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<table border="0">
<tr>
    <td>Restore auf Computer</td>
    <td><input type="text" size="40" value="\${EscHTML(\$host)}"
	 name="hostDest"></td>
</tr><tr>
    <td>Restore auf Freigabe</td>
    <td><input type="text" size="40" value="\${EscHTML(\$share)}"
	 name="shareDest"></td>
</tr><tr>
    <td>Restore in Unterverzeichnis<br>(relativ zur Freigabe)</td>
    <td valign="top"><input type="text" size="40" maxlength="256"
	value="\${EscHTML(\$pathHdr)}" name="pathHdr"></td>
</tr><tr>
    <td><input type="submit" value="Start Restore" name=""></td>
</table>
</form>
EOF

# ------------------------------
$Lang{Option_2__Download_Zip_archive} = <<EOF;

\${h2("Möglichkeit 2: Download als Zip Archiv Datei")}
<p>
Sie können eine ZIP Archiv Datei downloaden, die alle selektierten Dateien/Verzeichnisse
enthält. Mit einer lokalen Anwendung (z.B. WinZIP, WinXP-ZIP-Ordner...) können Sie dann
beliebige Dateien entpacken. 
<p>
<b><font color="#FF0000">Warnung:</font></b> Abhängig von der Anzahl und Größe der selektierten
Dateien/Verzeichnisse kann die ZIP Archiv Datei extrem groß bzw. zu groß werden. Der Download kann
sehr lange dauern und der Speicherplatz auf Ihrem PC muß ausreichen. Selektieren Sie
evtl. die Dateien/Verzeichnisse erneut und lassen sehr große und unnötige Dateien weg.  
<p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="2">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Archiv relativ zu Pfad
 \${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(andernfalls enthält die Archiv Datei vollständige Pfade).
<br>
Kompression (0=aus, 1=schnelle,...,9=höchste)
<input type="text" size="6" value="5" name="compressLevel">
<br>
<input type="submit" value="Download Zip Datei" name="">
</form>
EOF

# ------------------------------

$Lang{Option_2__Download_Zip_archive2} = <<EOF;
\${h2("Möglichkeit 2: Download als Zip Archiv Datei")}
<p>
Archive::Zip is not installed so you will not be able to download a
zip archive.
Please ask your system adminstrator to install Archive::Zip from
<a href="http://www.cpan.org">www.cpan.org</a>.
<p>
EOF


# ------------------------------
$Lang{Option_3__Download_Zip_archive} = <<EOF;
\${h2("Möglichkeit 3: Download als Tar Archiv Datei")}
<p>
Sie können eine Tar Archiv Datei downloaden, die alle selektierten Dateien/Verzeichnisse
enthält. Mit einer lokalen Anwendung (z.B. tar, WinZIP...) können Sie dann
beliebige Dateien entpacken.
<p>
<b><font color="#FF0000">Warnung:</font></b> Abhängig von der Anzahl und Größe der selektierten
Dateien/Verzeichnisse kann die Tar Archiv Datei extrem groß bzw. zu groß werden. Der Download kann
sehr lange dauern und der Speicherplatz auf Ihrem PC muß ausreichen. Selektieren Sie
evtl. die Dateien/Verzeichnisse erneut und lassen sehr große und unnötige Dateien weg.  
<p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="1">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Archiv relativ zu Pfad
 \${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(andernfalls enthält die Archiv Datei vollständige Pfade).
<br>
<input type="submit" value="Download Tar Datei" name="">
</form>
EOF


# ------------------------------
$Lang{Restore_Confirm_on__host} = "BackupServer: Restore Confirm on \$host";

$Lang{Are_you_sure} = <<EOF;
\${h1("Sind Sie sicher?")}
<p>
Sie starten eine direkte Wiederherstellung auf den Computer \$In{hostDest}.
Die folgenden Dateien werden auf die Freigabe \$In{shareDest} wiederhergestellt, vom
Backup Nummer \$num:
<p>
<table border>
<tr><td>Original Datei/Verzeichnis</td><td>Wird wiederhergestellt nach</td></tr>
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
Wollen Sie das wirklich tun?
<input type="submit" value="\$In{action}" name="action">
<input type="submit" value="Nein" name="">
</form>
EOF


# --------------------------
$Lang{Restore_Requested_on__hostDest} = "BackupServer: Wiederherstellung beauftragt auf Computer \$hostDest";
$Lang{Reply_from_server_was___reply} = <<EOF;
\${h1(\$str)}
<p>
Die Antwort des BackupServers war: \$reply
<p>
Zurück zur <a href="\$MyURL?host=\$hostDest">\$hostDest home page</a>.
EOF

# -------------------------
$Lang{Host__host_Backup_Summary} = "BackupServer: Computer \$host Backup Übersicht";

$Lang{Host__host_Backup_Summary2} = <<EOF;
\${h1("Computer \$host Backup Übersicht")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>

\${h2("User Aktionen")}
<p>
<form action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
\$startIncrStr
<input type="submit" value="$Lang{Start_Full_Backup}" name="action">
<input type="submit" value="$Lang{Stop_Dequeue_Backup}" name="action">
</form>

\${h2("Backup Übersicht")}
<p>
Klicken Sie auf die Backup-Nummer um Dateien zu browsen und bei Bedarf wiederherzustellen.
<table border>
<tr><td align="center"> Backup# </td>
    <td align="center"> Typ </td>
    <td align="center"> Filled </td>
    <td align="center"> Start Zeitpunkt </td>
    <td align="center"> Dauer/mins </td>
    <td align="center"> Alter/Tage </td>
    <td align="center"> Server Backup Pfad </td>
</tr>
\$str
</table>
<p>

\$restoreStr

\${h2("Xfer Fehler Übersicht - bitte kontrollieren")}
<p>
<table border>
<tr><td align="center"> Backup# </td>
    <td align="center"> Typ </td>
    <td align="center"> Anzeigen </td>
    <td align="center"> #Xfer Fehler </td>
    <td align="center"> #Dateifehler </td>
    <td align="center"> #Freigabefehler </td>
    <td align="center"> #tar Fehler </td>
</tr>
\$errStr
</table>
<p>

\${h2("Datei Größe/Anzahl Wiederverwendungs Übersicht")}
<p>
"Bestehende Dateien" bedeutet bereits im Pool vorhanden.<BR> 
"Neue Dateien" bedeutet neu zum Pool hinzugefügt.<BR>
Leere Dateien und Datei-Fehler sind nicht in den Summen enthalten.
<table border>
<tr><td colspan="2"></td>
    <td align="center" colspan="3"> Gesamt </td>
    <td align="center" colspan="2"> Bestehende Dateien </td>
    <td align="center" colspan="2"> Neue Dateien </td>
</tr>
<tr>
    <td align="center"> Backup# </td>
    <td align="center"> Typ </td>
    <td align="center"> #Dateien </td>
    <td align="center"> Größe/MB </td>
    <td align="center"> MB/sec </td>
    <td align="center"> #Dateien </td>
    <td align="center"> Größe/MB </td>
    <td align="center"> #Dateien </td>
    <td align="center"> Größe/MB </td>
</tr>
\$sizeStr
</table>
<p>

\${h2("Kompression Übersicht")}
<p>
Kompressionsergebnisse für bereits im Backup-Pool vorhandene und für neu komprimierte Dateien.
<table border>
<tr><td colspan="3"></td>
    <td align="center" colspan="3"> vorhandene Dateien </td>
    <td align="center" colspan="3"> neue Dateien </td>
</tr>
<tr><td align="center"> Backup# </td>
    <td align="center"> Typ </td>
    <td align="center"> Comp Level </td>
    <td align="center"> Größe/MB </td>
    <td align="center"> Comp/MB </td>
    <td align="center"> Comp </td>
    <td align="center"> Größe/MB </td>
    <td align="center"> Comp/MB </td>
    <td align="center"> Comp </td>
</tr>
\$compStr
</table>
<p>
EOF

# -------------------------
$Lang{Error} = "BackupServer: Fehler";
$Lang{Error____head} = <<EOF;
\${h1("Fehler: \$head")}
<p>\$mesg</p>
EOF

# -------------------------
$Lang{NavSectionTitle_} = "Server";

# -------------------------
$Lang{Backup_browse_for__host} = <<EOF;
\${h1("Backup browsen von Computer \$host")}

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
<li> Sie browsen das Backup #\$num, erstellt am \$backupTime
        (vor \$backupAge Tagen),
\$filledBackup
<li> Klicken Sie auf ein Verzeichnis um dieses zu durchsuchen.
<li> Klicken Sie auf eine Datei um diese per download wiederherzustellen.
</ul>

\${h2("Inhalt von \${EscHTML(\$dirDisplay)}")}
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
<input type="submit" name="Submit" value="Restore der Selektion">
-->
</td></tr></table>
</form>
EOF

# ------------------------------
$Lang{Restore___num_details_for__host} = "BackupServer: Restore #\$num Details für Computer \$host";

$Lang{Restore___num_details_for__host2 } = <<EOF;
\${h1("Restore #\$num Details für Computer \$host")}
<p>
<table border>
<tr><td> Nummer </td><td> \$Restores[\$i]{num} </td></tr>
<tr><td> beauftragt von </td><td> \$RestoreReq{user} </td></tr>
<tr><td> Auftrag Zeitpunkt </td><td> \$reqTime </td></tr>
<tr><td> Ergebnis </td><td> \$Restores[\$i]{result} </td></tr>
<tr><td> Fehlermeldung </td><td> \$Restores[\$i]{errorMsg} </td></tr>
<tr><td> Quelle Computer </td><td> \$RestoreReq{hostSrc} </td></tr>
<tr><td> Quelle Backup Nr. </td><td> \$RestoreReq{num} </td></tr>
<tr><td> Quelle Freigabe </td><td> \$RestoreReq{shareSrc} </td></tr>
<tr><td> Ziel Computer </td><td> \$RestoreReq{hostDest} </td></tr>
<tr><td> Ziel Freigabe </td><td> \$RestoreReq{shareDest} </td></tr>
<tr><td> Start Zeitpunkt </td><td> \$startTime </td></tr>
<tr><td> Dauer </td><td> \$duration min </td></tr>
<tr><td> Anzahl Dateien </td><td> \$Restores[\$i]{nFiles} </td></tr>
<tr><td> Größe gesamt </td><td> \${MB} MB </td></tr>
<tr><td> Transferrate </td><td> \$MBperSec MB/sec </td></tr>
<tr><td> TarCreate Fehler </td><td> \$Restores[\$i]{tarCreateErrs} </td></tr>
<tr><td> Xfer Fehler </td><td> \$Restores[\$i]{xferErrs} </td></tr>
<tr><td> Xfer LOG Datei </td><td>
<a href="\$MyURL?action=view&type=RestoreLOG&num=\$Restores[\$i]{num}&host=\$host">Anzeigen</a>,
<a href="\$MyURL?action=view&type=RestoreErr&num=\$Restores[\$i]{num}&host=\$host">Fehler</a>
</tr></tr>
</table>
<p>
\${h1("Datei/Verzeichnis Liste")}
<p>
<table border>
<tr><td>Original Datei/Verzeichnis</td><td>wiederhergestellt nach</td></tr>
\$fileListStr
</table>
EOF

# -----------------------------------
$Lang{Email_Summary} = "BackupServer: e-mail Übersicht";

# -----------------------------------
#  !! ERROR messages !!
# -----------------------------------
$Lang{BackupPC__Lib__new_failed__check_apache_error_log} = "BackupPC::Lib->new failed: überprüfen Sie die apache error_log\n";
$Lang{Wrong_user__my_userid_is___} =  
              "Falscher User: meine userid ist \$>, anstatt \$uid"
            . "(\$Conf{BackupPCUser})\n";
$Lang{Only_privileged_users_can_view_PC_summaries} = "Nur berechtigte User können die Computer Übersicht einsehen.";
$Lang{Only_privileged_users_can_stop_or_start_backups} = 
                  "Nur berechtigte User können Backups starten und stoppen für"
		. " \${EscHTML(\$host)}.";
$Lang{Invalid_number__num} = "ungültige Nummer \$num";
$Lang{Unable_to_open__file__configuration_problem} = "kann Datei nicht öffnen \$file: Konfigurationsproblem?";
$Lang{Only_privileged_users_can_view_log_or_config_files} = "Nur berechtigte User können LOG oder config Dateien einsehen.";
$Lang{Only_privileged_users_can_view_log_files} = "Nur berechtigte User können LOG Dateien einsehen.";
$Lang{Only_privileged_users_can_view_email_summaries} = "Nur berechtigte User können die Email Übersicht einsehen.";
$Lang{Only_privileged_users_can_browse_backup_files} = "Nur berechtigte User können Backup Dateien browsen"
                . " für computer \${EscHTML(\$In{host})}.";
$Lang{Empty_host_name} = "Empty host name.";
$Lang{Directory___EscHTML} = "Verzeichnis \${EscHTML(\"\$TopDir/pc/\$host/\$num\")}"
		    . " ist leer";
$Lang{Can_t_browse_bad_directory_name2} = "Kann fehlerhaften Verzeichnisnamen nicht browsen"
	            . " \${EscHTML(\$relDir)}";
$Lang{Only_privileged_users_can_restore_backup_files} = "Nur berechtigte User können Dateien wiederherstellen"
                . " für Computer \${EscHTML(\$In{host})}.";
$Lang{Bad_host_name} = "Falscher Computer Name \${EscHTML(\$host)}";
$Lang{You_haven_t_selected_any_files__please_go_Back_to} = "Sie haben keine Dateien selektiert; bitte gehen Sie zurück um"
                . " Dateien zu selektieren.";
$Lang{Nice_try__but_you_can_t_put} = "Sie dürfen \'..\' nicht in Dateinamen verwenden";
$Lang{Host__doesn_t_exist} = "Computer \${EscHTML(\$In{hostDest})} existiert nicht";
$Lang{You_don_t_have_permission_to_restore_onto_host} = "Sie haben keine Berechtigung zum Restore auf Computer"
		    . " \${EscHTML(\$In{hostDest})}";
$Lang{Can_t_open_create} = "Kann Datei nicht öffnen oder erstellen "
                    . "\${EscHTML(\"\$TopDir/pc/\$hostDest/\$reqFileName\")}";
$Lang{Only_privileged_users_can_restore_backup_files2} = "Nur berechtigte Benutzer dürfen Backup und Restore von Dateien"
                . " für Computer \${EscHTML(\$host)} durchführen.";
$Lang{Empty_host_name} = "leerer Computer Name";
$Lang{Unknown_host_or_user} = "Unbekannter Computer oder User \${EscHTML(\$host)}";
$Lang{Only_privileged_users_can_view_information_about} = "Nur berechtigte User können Informationen sehen über"
                . " Computer \${EscHTML(\$host)}." ;
$Lang{Only_privileged_users_can_view_restore_information} = "Nur berechtigte User können Restore Informationen einsehen.";
$Lang{Restore_number__num_for_host__does_not_exist} = "Restore Nummer \$num für Computer \${EscHTML(\$host)} existiert"
	        . " nicht.";

$Lang{Unable_to_connect_to_BackupPC_server} = "Kann keine Verbindung zu BackupPC server herstellen",
            "Dieses CGI script (\$MyURL) kann keine Verbindung zu BackupPC"
          . " server auf \$Conf{ServerHost} port \$Conf{ServerPort} herstellen.  Der Fehler"
          . " war: \$err.",
            "Möglicherweise ist der BackupPC server Prozess nicht gestartet oder es besteht ein"
          . " Konfigurationsfehler.  Bitte teilen Sie diese Fehlermeldung dem Systemadministrator mit.";

$Lang{Can_t_find_IP_address_for} = "Kann IP-Adresse für \${EscHTML(\$host)} nicht finden";
$Lang{host_is_a_DHCP_host} = <<EOF;
\$host ist ein DHCP Computer und ich kenne seine IP-Adresse nicht.  Ich prüfte den
netbios Namen von \$ENV{REMOTE_ADDR}\$tryIP und erkannte, dass es nicht der Computer \$host ist.
<p>
Solange bis ich \$host mit einer DHCP-Adresse sehe, können Sie diesen Auftrag nur
vom diesem Client Computer aus starten.
EOF

########################
# ok you can do it then
########################

$Lang{Backup_requested_on_DHCP__host} = "Backup angefordert für DHCP Computer \$host (\$In{hostIP}) durch"
		                      . " \$User von \$ENV{REMOTE_ADDR}";

$Lang{Backup_requested_on__host_by__User} = "Backup angefordert für \$host durch \$User";
$Lang{Backup_stopped_dequeued_on__host_by__User} = "Backup gestoppt/gelöscht für \$host durch \$User";

$Lang{Restore_requested_to_host__hostDest__backup___num} = "Restore beauftragt nach Computer \$hostDest, von Backup #\$num,"
	     . " durch User \$User von Client \$ENV{REMOTE_ADDR}";

# -------------------------------------------------
# ------- Stuff that was forgotten ----------------
# -------------------------------------------------

$Lang{Status} = "Status";
$Lang{PC_Summary} = "Computer Übersicht";
$Lang{LOG_file} = "LOG Datei";
$Lang{Old_LOGs} = "Alte LOGs";
$Lang{Email_summary} = "Email Übersicht";
$Lang{Config_file} = "Config Datei";
$Lang{Hosts_file} = "Hosts Datei";
$Lang{Current_queues} = "Warteschlangen";
$Lang{Documentation} = "Dokumentation";

$Lang{Host_or_User_name} = "<small>Computer oder User Name:</small>";
$Lang{Go} = "gehe zu";
$Lang{Hosts} = "Computer";

$Lang{This_PC_has_never_been_backed_up} = "<h2> Dieser Computer wurde nie gesichert!! </h2>\n";
$Lang{This_PC_is_used_by} = "<li>Dieser Computer wird betreut von \${UserLink(\$user)}";

$Lang{Extracting_only_Errors} = "(nur Fehler anzeigen)";
$Lang{XferLOG} = "XferLOG";
$Lang{Errors}  = "Fehler";

# ------------
$Lang{Last_email_sent_to__was_at___subject} = <<EOF;
<li>Letzte e-mail gesendet an \${UserLink(\$user)} am  \$mailTime, Titel "\$subj".
EOF
# ------------
$Lang{The_command_cmd_is_currently_running_for_started} = <<EOF;
<li>Das Kommando \$cmd wird gerade für Computer \$host ausgeführt, gestartet am \$startTime.
EOF

# -----------
$Lang{Host_host_is_queued_on_the_background_queue_will_be_backed_up_soon} = <<EOF;
<li>Computer \$host ist in die Hintergrund-Warteschlange eingereiht (Backup wird bald gestartet).
EOF

# ----------
$Lang{Host_host_is_queued_on_the_user_queue__will_be_backed_up_soon} = <<EOF;
<li>Computer \$host ist in die User-Warteschlange eingereiht (Backup wird bald gestartet).
EOF

# ---------
$Lang{A_command_for_host_is_on_the_command_queue_will_run_soon} = <<EOF;
<li>Ein Kommando für Computer \$host ist in der Kommando-Warteschlange (wird bald ausgeführt).
EOF

# --------
$Lang{Last_status_is_state_StatusHost_state_reason_as_of_startTime} = <<EOF;
<li>Letzter Status ist \"\$Lang->{\$StatusHost{state}}\"\$reason vom \$startTime.
EOF

# --------
$Lang{Last_error_is____EscHTML_StatusHost_error} = <<EOF;
<li>Letzter Fehler ist \"\${EscHTML(\$StatusHost{error})}\".
EOF

# ------
$Lang{Pings_to_host_have_failed_StatusHost_deadCnt__consecutive_times} = <<EOF;
<li>Pings zu Computer \$host sind \$StatusHost{deadCnt} mal fehlgeschlagen.
EOF

# -----
$Lang{Prior_to_that__pings} = "vorher, Pings";

# -----
$Lang{priorStr_to_host_have_succeeded_StatusHostaliveCnt_consecutive_times} = <<EOF;
<li>\$priorStr zu Computer \$host \$StatusHost{aliveCnt}
        mal fortlaufend erfolgreich.
EOF

$Lang{Because__host_has_been_on_the_network_at_least__Conf_BlackoutGoodCnt_consecutive_times___} = <<EOF;
<li>Da Computer \$host mindestens \$Conf{BlackoutGoodCnt}
mal fortlaufend erreichbar war, wird er in der Zeit von \$t0 bis \$t1 am \$days nicht gesichert. (Die Sicherung
erfolgt automatisch außerhalb der konfigurierten Betriebszeit)
EOF

$Lang{Backups_are_deferred_for_hours_hours_change_this_number} = <<EOF;
<li>Backups sind für die nächsten \$hours Stunden deaktiviert.
(<a href=\"\$MyURL?action=Stoppen/Aussetzen%20Backup&host=\$host\">diese Zeit ändern</a>).
EOF

$Lang{tryIP} = " und \$StatusHost{dhcpHostIP}";

$Lang{Host_Inhost} = "Computer \$In{host}";

$Lang{checkAll} = <<EOF;
<tr bgcolor="#ffffcc"><td>
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;alles auswählen
</td><td colspan="5" align="center">
<input type="submit" name="Submit" value="Restore der Selektion">
</td></tr>
EOF

$Lang{fileHeader} = <<EOF;
    <tr bgcolor="\$Conf{CgiHeaderBgColor}"><td align=center> Name</td>
       <td align="center"> Typ</td>
       <td align="center"> Rechte</td>
       <td align="center"> Backup#</td>
       <td align="center"> Größe</td>
       <td align="center"> letzte Änderung</td>
    </tr>
EOF

$Lang{Home} = "Home";
$Lang{Last_bad_XferLOG} = "Letzte bad XferLOG";
$Lang{Last_bad_XferLOG_errors_only} = "Letzte bad XferLOG (nur&nbsp;Fehler)";

$Lang{This_display_is_merged_with_backup} = <<EOF;
<li> Diese Liste ist mit Backup #\$numF verbunden.
EOF

$Lang{Visit_this_directory_in_backup} = <<EOF;
<li> Dieses Verzeichnis in Backup #\$otherDirs browsen.
EOF

$Lang{Restore_Summary} = <<EOF;
\${h2("Restore Übersicht")}
<p>
Klicken Sie auf die Restore Nummer (Restore#) für mehr Details.
<table border>
<tr><td align="center"> Restore# </td>
    <td align="center"> Ergebnis </td>
    <td align="right"> Start Zeitpunkt</td>
    <td align="right"> Dauer/mins</td>
    <td align="right"> #Dateien </td>
    <td align="right"> Größe/MB </td>
    <td align="right"> #tar Fehler </td>
    <td align="right"> #Xfer Fehler </td>
</tr>
\$restoreStr
</table>
<p>
EOF

$Lang{BackupPC__Documentation} = "BackupServer: Dokumentation";

$Lang{No} = "nein";
$Lang{Yes} = "ja";

$Lang{The_directory_is_empty} = <<EOF;
<tr><td bgcolor="#ffffff">Das Verzeichnis \${EscHTML(\$dirDisplay)} ist leer.
</td></tr>
EOF

#$Lang{on} = "on";
$Lang{off} = "aus";

$Lang{full} = "voll";
$Lang{incremental} = "incr";

$Lang{failed} = "fehler";
$Lang{success} = "erfolgreich";
$Lang{and} = "und";

# ------
# Hosts states and reasons
$Lang{Status_idle} = "wartet";
$Lang{Status_backup_starting} = "Backup startet";
$Lang{Status_backup_in_progress} = "Backup läuft";
$Lang{Status_restore_starting} = "Restore startet";
$Lang{Status_restore_in_progress} = "Restore läuft";
$Lang{Status_link_pending} = "Link steht an";
$Lang{Status_link_running} = "Link läuft";

$Lang{Reason_backup_done} = "Backup durchgeführt";
$Lang{Reason_restore_done} = "Restore durchgeführt";
$Lang{Reason_nothing_to_do} = "kein Auftrag";
$Lang{Reason_backup_failed} = "Backup Fehler";
$Lang{Reason_restore_failed} = "Restore Fehler";
$Lang{Reason_no_ping} = "nicht erreichbar";
$Lang{Reason_backup_canceled_by_user} = "Abbruch durch User";
$Lang{Reason_restore_canceled_by_user} = "Abbruch durch User";

# ---------
# Email messages

# No backup ever
$Lang{EMailNoBackupEverSubj} = "BackupServer: keine Backups von \$host waren erfolgreich";
$Lang{EMailNoBackupEverMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj

Hallo $userName,

Ihr Computer ($host) wurde durch den BackupServer noch nie erfolgreich gesichert.

Backups sollten automatisch erfolgen, wenn Ihr Computer am Netzwerk angeschlossen ist.
Sie sollten Ihren Backup-Betreuer oder den IT-Dienstleister kontaktieren, wenn:

  - Ihr Computer regelmäßig am Netzwerk angeschlossen ist. Dann handelt es sich
    um ein Installations- bzw. Konfigurationsproblem, was die Durchführung von
    automatischen Backups verhindert.

  - Wenn Sie kein automatisches Backup des Computers brauchen und diese e-mail nicht
    mehr erhalten möchten.

Andernfalls sollten Sie sicherstellen, daß Ihr Computer regelmäßig korrekt am Netzwerk
angeschlossen wird.

Mit freundlichen Grüßen,
Ihr BackupServer
http://backuppc.sourceforge.net
http://www.zipptec.de
EOF

# No recent backup
$Lang{EMailNoBackupRecentSubj} = "BackupServer: keine neuen Backups für Computer \$host";
$Lang{EMailNoBackupRecentMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj

Hallo $userName,

Ihr Computer ($host) wurde seit $days Tagen nicht mehr erfolgreich gesichert.

Ihr Computer wurde von vor $firstTime Tagen bis vor $days Tagen $numBackups mal
erfolgreich gesichert.
Backups sollten automatisch erfolgen, wenn Ihr Computer am Netzwerk angeschlossen ist.

Wenn Ihr Computer in den letzten $days Tagen mehr als ein paar Stunden am
Netzwerk angeschlossen war, sollten Sie Ihren Backup-Betreuer oder
den IT-Dienstleister kontaktieren um die Ursache zu ermitteln und zu beheben.
Andernfalls, wenn Sie z. B. lange Zeit nicht im Büro sind, können Sie höchstens
manuell Ihre Dateien sichern (evtl. kopieren auf eine externe Festplatte).

Bitte denken Sie daran, dass alle in den letzten $days Tagen geänderten Dateien (z. B.
auch e-mails und Anhänge oder Datenbankeinträge) verloren gehen falls Ihre
Festplatte einen crash erleidet oder Dateien durch versehentliches Löschen oder
Virenbefall unbrauchbar werden.

Mit freundlichen Grüßen,
Ihr BackupServer
http://backuppc.sourceforge.net
http://www.zipptec.de
EOF

# Old Outlook files
$Lang{EMailOutlookBackupSubj} = "BackupServer: Outlook Dateien auf Computer \$host - Sicherung erforderlich";
$Lang{EMailOutlookBackupMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj

Hallo $userName,

die Outlook Dateien auf Ihrem Computer wurden $howLong Tage nicht gesichert.
Diese Dateien enthalten Ihre e-mails, Anhänge, Adressen und Kalender.

Ihr Computer wurde zwar $numBackups mal seit $firstTime Tagen bis vor $lastTime Tagen
gesichert. Allerdings sperrt Outlook den Zugriff auf diese Dateien.

Es wird folgendes Vorgehen empfohlen:

1. Der Computer muss an das BackupServer Netzwerk angeschlossen sein.
2. Beenden Sie das Outlook Programm.
3. Starten Sie ein incrementelles Backup mit dem Internet-Browser hier: 

    $CgiURL?host=$host               

    Name und Passwort eingeben und dann 2 mal nacheinander
    auf "Starte Backup incrementell" klicken
    Klicken Sie auf "Gehe zurück zur ...home page" und beobachten Sie
    den Status des Backup-Vorgangs (Browser von Zeit zu Zeit aktualisieren).
    Das sollte je nach Dateigröße nur eine kurze Zeit dauern.
    

Mit freundlichen Grüßen,
Ihr BackupServer
http://backuppc.sourceforge.net
http://www.zipptec.de
EOF

$Lang{howLong_not_been_backed_up} = "Backup nicht erfolgreich";
$Lang{howLong_not_been_backed_up_for_days_days} = "kein Backup seit \$days Tagen";

#end of lang_de.pm
