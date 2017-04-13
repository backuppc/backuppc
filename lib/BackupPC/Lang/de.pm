#!/usr/bin/perl
#
# by Ralph Passgang <ralph@debianbase.de> (13.11.2006 for V3.0.0)
# by Ralph Passgang <ralph@debianbase.de> (30.06.2006 for V3.0.0)
# by Ralph Passgang <ralph@debianbase.de> (07.06.2004 for V2.1.0beta3)
# by Ralph Passgang <ralph@debianbase.de> (06.05.2004 for V2.1.0beta2)
# by Manfred Herrmann (11.03.2004 for V2.1.0beta0)
# by Manfred Herrmann (V1.1) (some typo errors + 3 new strings)
# CVS-> Revision ???
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

$Lang{Start_Archive} = "Archivierung starten";
$Lang{Stop_Dequeue_Archive} = "Archivierung stoppen";
$Lang{Start_Full_Backup} = "Starte vollst�ndiges Backup";
$Lang{Start_Incr_Backup} = "Starte inkrementelles Backup";
$Lang{Stop_Dequeue_Backup} = "Backup Stoppen/Aussetzen";
$Lang{Restore} = "Wiederherstellen";

$Lang{Type_full} = "voll";
$Lang{Type_incr} = "inkrementell";

# -----

$Lang{Only_privileged_users_can_view_admin_options} = "Nur privilegierte Nutzer k�nnen die Administrationsoptionen einsehen.";
$Lang{H_Admin_Options} = "BackupPC: Server Administrationsoptionen";
$Lang{Admin_Options} = "Admin Optionen";
$Lang{Admin_Options_Page} = <<EOF;
\${h1(qq{$Lang{Admin_Options}})}
<br>
\${h2("Server Steuerung")}
<form name="ReloadForm" action="\$MyURL" method="get">
<input type="hidden" name="action" value="">
<table class="tableStnd">
  <tr><td>Server Konfiguration neu laden:<td><input type="button" value="Reload"
     onClick="document.ReloadForm.action.value='Reload';
              document.ReloadForm.submit();">
</table>
</form>
<!--
\${h2("Server Konfiguration")}
<ul>
  <li><i>Andere Optionen sind hier m�glich ... z.B.</i>
  <li>Serverkonfiguration editieren
</ul>
-->
EOF

$Lang{Unable_to_connect_to_BackupPC_server} = "Kann keine Verbindung zu dem BackupPC Server herstellen!";
$Lang{Unable_to_connect_to_BackupPC_server_error_message} = <<EOF;
Dieses CGI Script (\$MyURL) kann keine Verbindung zu dem BackupPC Server
auf \$Conf{ServerHost} Port \$Conf{ServerPort} herstellen.<br>
Der Fehler war: \$err.<br>
M�glicherweise ist der BackupPC Server Prozess nicht gestartet oder es besteht ein
Konfigurationsfehler. Bitte teilen Sie diese Fehlermeldung dem Systemadministrator mit.
EOF

$Lang{Admin_Start_Server} = <<EOF;
\${h1(qq{$Lang{Unable_to_connect_to_BackupPC_server}})}
<form action="\$MyURL" method="get">
Der BackupPC Server auf <tt>\$Conf{ServerHost}</tt> Port <tt>\$Conf{ServerPort}</tt>
ist momentan nicht aktiv (m�glicherweise wurde er gestoppt, oder noch nicht gestartet).<br>
M�chten Sie den Server starten?
<input type="hidden" name="action" value="startServer">
<input type="submit" value="Start Server" name="ignore">
</form>
EOF

# -----

$Lang{H_BackupPC_Server_Status} = "BackupPC Serverstatus";

$Lang{BackupPC_Server_Status_General_Info}= <<EOF;

\${h2(\"Allgemeine Serverinformationen\")}

<ul>
<li>Die Server Prozess ID (PID) ist \$Info{pid}, auf Computer \$Conf{ServerHost},
     Version \$Info{Version}, gestartet am \$serverStartTime.
<li> Dieser Status wurde am \$now generiert.
<li> Die Konfiguration wurde am \$configLoadTime neu geladen.
<li> Computer werden am \$nextWakeupTime auf neue Auftr�ge gepr�ft.
<li> Weitere Informationen:
    <ul>
        <li>\$numBgQueue wartende Backup Auftr�ge der letzten Pr�fung,
        <li>\$numUserQueue wartende Auftr�ge von Benutzern,
        <li>\$numCmdQueue wartende Kommando Auftr�ge.
        \$poolInfo
        <li>Das Pool Filesystem (Backup-Speicherplatz) ist zu \$Info{DUlastValue}%
            (\$DUlastTime) voll, das Maximum heute ist \$Info{DUDailyMax}% (\$DUmaxTime)
            und das Maximum gestern war \$Info{DUDailyMaxPrev}%. (Hinweis: Sollten ca. 70% �berschritten werden, so
	    ist evtl. bald eine Erweiterung des Backupspeichers erforderlich. Ist weitere Planung n�tig?)
    </ul>
</ul>
EOF

$Lang{BackupPC_Server_Status} = <<EOF;

\${h1(qq{$Lang{H_BackupPC_Server_Status}})}

<p>
\${h2("Zur Zeit aktive Auftr�ge")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td> Computer </td>
    <td> Typ </td>
    <td> Benutzer </td>
    <td> Startzeit </td>
    <td> Kommando </td>
    <td align="center"> PID </td>
    <td align="center"> Transport PID </td>
    <td align="center"> Status </td>
    <td align="center"> Count </td>
    </tr>
\$jobStr
</table>

<p>
\$generalInfo

\${h2("Fehler, die n�her analysiert werden m�ssen!")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> Computer </td>
    <td align="center"> Typ </td>
    <td align="center"> Benutzer </td>
    <td align="center"> letzter Versuch </td>
    <td align="center"> Details </td>
    <td align="center"> Fehlerzeit </td>
    <td> Letzter Fehler (ausser "kein ping") </td></tr>
\$statusStr
</table>
EOF

# --------------------------------
$Lang{BackupPC__Server_Summary} = "BackupPC: Computer�bersicht";
$Lang{BackupPC__Archive} = "BackupPC: Archivierung";
$Lang{BackupPC_Summary}=<<EOF;

\${h1(qq{$Lang{BackupPC__Server_Summary}})}
<p>
<ul>
<li>Dieser Status wurde am \$now generiert.
<li>Das Pool Filesystem (Backup-Speicherplatz) ist zu \$Info{DUlastValue}%
    (\$DUlastTime) voll, das Maximum heute ist \$Info{DUDailyMax}% (\$DUmaxTime)
    und das Maximum gestern war \$Info{DUDailyMaxPrev}%. (Hinweis: Sollten ca. 70% �berschritten werden, so
    ist evtl. bald eine Erweiterung des Backupspeichers erforderlich. Ist weitere Planung n�tig?)
</ul>
</p>

\${h2("Computer mit erfolgreichen Backups")}
<p>
Es gibt \$hostCntGood Computer die erfolgreich gesichert wurden, mit insgesamt:
<ul>
<li> \$fullTot Volle Backups, Gesamtgr��e \${fullSizeTot}GiB
     (vor Pooling und Komprimierung),
<li> \$incrTot Inkrementelle Backups, Gesamtgr��e \${incrSizeTot}GiB
     (vor Pooling und Komprimierung).
</ul>
</p>
<table class="sortable" id="host_summary_backups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> Computer </td>
    <td align="center"> Benutzer </td>
    <td align="center"> #Voll </td>
    <td align="center"> Alter (Tage) </td>
    <td align="center"> Gr��e (GiB) </td>
    <td align="center"> MB/sek </td>
    <td align="center"> #Inkr </td>
    <td align="center"> Alter (Tage) </td>
    <td align="center"> Letzes Backup (Tage) </td>
    <td align="center"> Status </td>
    <td align="center"> #Xfer Fehler </td>
    <td align="center"> Letzte Aktion </td></tr>
\$strGood
</table>
\${h2("Computer ohne Backups")}
<p>
Es gibt \$hostCntNone Computer ohne Backups !!!
<p>
<table class="sortable" id="host_summary_nobackups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> Computer </td>
    <td align="center"> Benutzer </td>
    <td align="center"> #Voll </td>
    <td align="center"> Alter (Tage) </td>
    <td align="center"> Gr��e (GiB) </td>
    <td align="center"> MB/sek </td>
    <td align="center"> #Inkr </td>
    <td align="center"> Alter (Tage) </td>
    <td align="center"> Letztes Backup (Tage) </td>
    <td align="center"> Status </td>
    <td align="center"> #Xfer Fehler </td>
    <td align="center"> Letzter Versuch </td></tr>
\$strNone
</table>
EOF

$Lang{BackupPC_Archive} = <<EOF;
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
Es gibt \$hostCntGood Computer die gesichert wurden, mit insgesamt \${fullSizeTot}GiB
<p>
<form name="form1" method="post" action="\$MyURL">
<input type="hidden" name="fcbMax" value="\$checkBoxCnt">
<input type="hidden" name="type" value="1">
<input type="hidden" name="host" value="\${EscHTML(\$archHost)}">
<input type="hidden" name="action" value="Archive">
<table class="tableStnd" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td align=center>Computer</td>
    <td align="center"> Benutzer </td>
    <td align="center"> Backup Gr��e </td>
\$strGood
\$checkAllHosts
</table>
</form>
<p>

EOF

$Lang{BackupPC_Archive2} = <<EOF;
\${h1(qq{$Lang{BackupPC__Archive}})}
Archivierung der folgenden Computer
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
    <td colspan=2><input type="submit" value="Archivierung starten" name="ignore"></td>
</tr>
</form>
</table>
EOF

$Lang{BackupPC_Archive2_location} = <<EOF;
<tr>
    <td>Archivierungsort/Ger�t</td>
    <td><input type="text" value="\$ArchiveDest" name="archive_device"></td>
</tr>
EOF

$Lang{BackupPC_Archive2_compression} = <<EOF;
<tr>
    <td>Kompression</td>
    <td>
    <input type="radio" value="0" name="compression" \$ArchiveCompNone>None<br>
    <input type="radio" value="1" name="compression" \$ArchiveCompGzip>gzip<br>
    <input type="radio" value="2" name="compression" \$ArchiveCompBzip2>bzip2
    </td>
</tr>
EOF

$Lang{BackupPC_Archive2_parity} = <<EOF;
<tr>
    <td>Prozentsatz Parit�tsdaten (0 = keine, 5 = Standard)</td>
    <td><input type="numeric" value="\$ArchivePar" name="par"></td>
</tr>
EOF

$Lang{BackupPC_Archive2_split} = <<EOF;
<tr>
    <td>Aufteilen in</td>
    <td><input type="numeric" value="\$ArchiveSplit" name="splitsize"> Megabytes</td>
</tr>
EOF

# -----------------------------------
$Lang{Pool_Stat} = <<EOF;
        <li>Der Pool hat eine Gr��e von \${poolSize}GiB und enth�lt \$info->{"\${name}FileCnt"} Dateien und \$info->{"\${name}DirCnt"} Verzeichnisse (Stand \$poolTime).
        <li>Das "Pool hashing" ergibt \$info->{"\${name}FileCntRep"} wiederholte
            Dateien mit der l�ngsten Verkettung von \$info->{"\${name}FileRepMax"}.
        <li>Die n�chtliche Bereinigung entfernte \$info->{"\${name}FileCntRm"} Dateien mit
            einer Gr��e von \${poolRmSize}GiB (um ca. \$poolTime).
EOF

# --------------------------------
$Lang{BackupPC__Backup_Requested_on__host} = "BackupPC: Backupauftrag f�r \$host";
# --------------------------------
$Lang{REPLY_FROM_SERVER} = <<EOF;
\${h1(\$str)}
<p>
Die Antwort des Servers war: \$reply
<p>
Gehe zur�ck zur <a href="\$MyURL?host=\$host">\$host Hauptseite</a>.
EOF
# --------------------------------
$Lang{BackupPC__Start_Backup_Confirm_on__host} = "BackupPC: Starte Backup von \$host";
# --------------------------------
$Lang{Are_you_sure_start} = <<EOF;
\${h1("Sind Sie sicher?")}
<p>
Sie starten ein \$type Backup f�r \$host.

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="hostIP" value="\$ipAddr">
<input type="hidden" name="doit" value="1">
<input type="hidden" name="action" value="">
M�chten Sie das wirklich tun?
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="Nein" name="ignore">
</form>
EOF
# --------------------------------
$Lang{BackupPC__Stop_Backup_Confirm_on__host} = "BackupPC: Beende Backup von \$host";
# --------------------------------
$Lang{Are_you_sure_stop} = <<EOF;

\${h1("Sind Sie sicher?")}

<p>
Sie werden Backups abbrechen bzw. Auftr�ge l�schen f�r Computer \$host;

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host"   value="\$host">
<input type="hidden" name="doit"   value="1">
<input type="hidden" name="action" value="">
Zus�tzlich bitte keine Backups starten f�r die Dauer von 
<input type="text" name="backoff" size="10" value="\$backoff"> Stunden.
<p>
M�chten Sie das wirklich tun?
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="Nein" name="ignore">
</form>

EOF
# --------------------------------
$Lang{Only_privileged_users_can_view_queues_} = "Nur berechtigte Benutzer k�nnen die Warteschlangen einsehen.";
# --------------------------------
$Lang{Only_privileged_users_can_archive} = "Nur berechtigte Benutzer k�nnnen archivieren.";
# --------------------------------
$Lang{BackupPC__Queue_Summary} = "BackupPC: Warteschlange �bersicht";
# --------------------------------
$Lang{Backup_Queue_Summary} = <<EOF;
\${h1("Backup Warteschlangen�bersicht")}
<br><br>
\${h2("�bersicht Benutzerauftr�ge in der Warteschlange")}
<p>
Die folgenden Benutzerauftr�ge sind eingereiht:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Computer </td>
    <td> Uhrzeit </td>
    <td> Benutzer </td></tr>
\$strUser
</table>
<br><br>

\${h2("�bersicht Hintergrundauftr�ge in der Warteschlange")}
<p>
Die folgenden Hintergrundauftr�ge sind eingereiht:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Computer </td>
    <td> Uhrzeit </td>
    <td> Benutzer </td></tr>
\$strBg
</table>
<br><br>
\${h2("�bersicht Kommandoauftr�ge in der Warteschlange")}
<p>
Die folgenden Kommandoauftr�ge sind eingereiht:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Computer </td>
    <td> Uhrzeit </td>
    <td> Benutzer </td>
    <td> Kommando </td></tr>
\$strCmd
</table>
EOF

# --------------------------------
$Lang{Backup_PC__Log_File__file} = "BackupPC: Datei \$file";
$Lang{Log_File__file__comment} = <<EOF;
\${h1("Datei \$file \$comment")}
<p>
EOF
# --------------------------------
$Lang{Contents_of_log_file} = <<EOF;
Inhalt der Datei <tt>\$file</tt>, ver�ndert am \$mtimeStr \$comment
EOF

# --------------------------------
$Lang{skipped__skipped_lines} = "[ �berspringe \$skipped Zeilen ]\n";
# --------------------------------
$Lang{_pre___Can_t_open_log_file__file} = "<pre>\nKann LOG Datei nicht �ffnen \$file\n";

# --------------------------------
$Lang{BackupPC__Log_File_History} = "BackupPC: LOG Datei Historie";
$Lang{Log_File_History__hdr} = <<EOF;
\${h1("LOG Datei Historie \$hdr")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Datei </td>
    <td align="center"> Gr��e </td>
    <td align="center"> letzte �nderung </td></tr>
\$str
</table>
EOF

# -------------------------------
$Lang{Recent_Email_Summary} = <<EOF;
\${h1("�bersicht der letzten eMails (Sortierung nach Zeitpunkt)")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Empf�nger </td>
    <td align="center"> Computer </td>
    <td align="center"> Zeitpunkt </td>
    <td align="center"> Betreff </td></tr>
\$str
</table>
EOF
 

# ------------------------------
$Lang{Browse_backup__num_for__host} = "BackupPC: Durchsuchen des Backups \$num f�r Computer \$host";

# ------------------------------
$Lang{Restore_Options_for__host} = "BackupPC: Wiederherstellungsoptionen f�r \$host";
$Lang{Restore_Options_for__host2} = <<EOF;
\${h1("Restore Optionen f�r \$host")}
<p>
Sie haben die folgenden Dateien/Verzeichnisse aus der Freigabe \$share des Backups mit der Nummer #\$num selektiert:
<ul>
\$fileListStr
</ul>
</p><p>
Sie haben drei verschiedene M�glichkeiten zur Wiederherstellung (Restore) der Dateien/Verzeichnisse.
Bitte w�hlen Sie eine der folgenden M�glichkeiten:.
</p>
\${h2("M�glichkeit 1: Direkte Wiederherstellung")}
<p>
EOF

$Lang{Restore_Options_for__host_Option1} = <<EOF;
Sie k�nnen diese Wiederherstellung starten um die Dateien/Verzeichnisse direkt auf den Computer <b>\$directHost</b> wiederherzustellen. 
Alternativ k�nnen Sie einen anderen Computer und/oder Freigabe als Ziel angeben.
</p><p>
<b>Warnung:</b> alle aktuell existierenden Dateien/Verzeichnisse, die bereits vorhanden sind,
werden �berschrieben! (Tip: Alternativ eine spezielle Freigabe erstellen mit Schreibrecht f�r den
Backup-Benutzer und die wiederhergestellten Dateien/Verzeichnisse durch Stichproben pr�fen, ob die beabsichtigte
Wiederherstellung korrekt ist.) 
</p>
<form action="\$MyURL" method="post" name="direct">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="3">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<table class="tableStnd" border="0">
<tr>
    <td>Restore auf Computer</td>
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
         <!--<a href="javascript:myOpen('\$MyURL?action=findShares&host='+document.direct.hostDest.options.value)">Suche nach verf�gbaren Freigaben (NICHT IMPLEMENTIERT)</a>--></td>
</tr><tr>
    <td>Restore auf Freigabe</td>
    <td><input type="text" size="40" value="\${EscHTML(\$share)}"
	 name="shareDest"></td>
</tr><tr>
    <td>Restore in Unterverzeichnis<br>(relativ zur Freigabe)</td>
    <td valign="top"><input type="text" size="40" maxlength="256"
	value="\${EscHTML(\$pathHdr)}" name="pathHdr"></td>
</tr><tr>
    <td><input type="submit" value="Wiederherstellung starten" name="ignore"></td>
</table>
</form>
EOF

$Lang{Restore_Options_for__host_Option1_disabled} = <<EOF;
Direkte Wiederherstellung ist deaktiviert f�r Computer: \${EscHTML(\$hostDest)}.
Bitte w�hlen Sie eine andere Wiederherstellungsoption.
EOF

# ------------------------------
$Lang{Option_2__Download_Zip_archive} = <<EOF;
<p>
\${h2("M�glichkeit 2: Download als Zip Archiv")}
<p>
Sie k�nnen eine ZIP Archivdatei downloaden, die alle selektierten Dateien/Verzeichnisse
enth�lt. Mit einer lokalen Anwendung (z.B. WinZIP, WinXP-ZIP-Ordner...) k�nnen Sie dann
beliebige Dateien entpacken. 
</p><p>
<b>Warnung:</b> Abh�ngig von der Anzahl und Gr��e der selektierten
Dateien/Verzeichnisse kann die ZIP Archiv Datei extrem gro� bzw. zu gro� werden. Der Download kann
sehr lange dauern und der Speicherplatz auf Ihrem PC mu� ausreichen. Selektieren Sie
evtl. die Dateien/Verzeichnisse erneut und lassen sehr gro�e und unn�tige Dateien weg.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="2">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Archiv relativ zu Pfad
 \${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(andernfalls enth�lt die Archiv Datei vollst�ndige Pfade).
<br>
<table class="tableStnd" border="0">
<tr>
    <td>Kompression (0=aus, 1=schnelle,...,9=h�chste)</td>
    <td><input type="text" size="6" value="5" name="compressLevel"></td>
</tr><tr>
    <td>Code page (e.g. cp866)</td>
    <td><input type="text" size="6" value="utf8" name="codePage"></td>
</tr>
</table>
<br>
<input type="submit" value="Zip Datei downloaden" name="ignore">
</form>
EOF

# ------------------------------

$Lang{Option_2__Download_Zip_archive2} = <<EOF;
<p>
\${h2("M�glichkeit 2: Download als Zip Archiv")}
<p>
Archive::Zip ist nicht installiert. Der Download als Zip Archiv Datei ist daher nicht m�glich.
Bitte lassen Sie bei Bedarf von Ihrem Administrator die Perl-Erweiterung Archive::Zip von 
<a href="http://www.cpan.org">www.cpan.org</a> installieren. Vielen Dank!
</p>
EOF


# ------------------------------
$Lang{Option_3__Download_Zip_archive} = <<EOF;
\${h2("M�glichkeit 3: Download als Tar Archiv")}
<p>
Sie k�nnen eine Tar Archivdatei downloaden, die alle selektierten Dateien/Verzeichnisse
enth�lt. Mit einer lokalen Anwendung (z.B. tar, WinZIP...) k�nnen Sie dann
beliebige Dateien entpacken.
</p><p>
<b>Warnung:</b> Abh�ngig von der Anzahl und Gr��e der selektierten
Dateien/Verzeichnisse kann die Tar-Archiv Datei extrem gro� bzw. zu gro� werden. Der Download kann
sehr lange dauern und der Speicherplatz auf Ihrem PC mu� ausreichen. Selektieren Sie
evtl. die Dateien/Verzeichnisse erneut und lassen sehr gro�e und unn�tige Dateien weg.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="1">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Archiv relativ zu Pfad
 \${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(andernfalls enth�lt die Archiv Datei vollst�ndige Pfade).
<br>
<input type="submit" value="Tar Datei downloaden" name="ignore">
</form>
EOF


# ------------------------------
$Lang{Restore_Confirm_on__host} = "BackupPC: Best�tigung f�r die Wiederherstellung auf \$host";

$Lang{Are_you_sure} = <<EOF;
\${h1("Sind Sie sicher?")}
<p>
Sie starten eine direkte Wiederherstellung auf den Computer \$In{hostDest}.
Die folgenden Dateien werden auf die Freigabe \$In{shareDest} wiederhergestellt, von
dem Backup mit der Nummer \$num:
<p>
<table class="tableStnd" border>
<tr class="tableheader"><td>Original Datei/Verzeichnis:</td><td>Wird wiederhergestellt nach:</td></tr>
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
Wollen Sie das wirklich tun?
<input type="button" value="\$Lang->{Restore}"
 onClick="document.RestoreForm.action.value='Restore';
          document.RestoreForm.submit();">
<input type="submit" value="No" name="ignore">
</form>
EOF


# --------------------------
$Lang{Restore_Requested_on__hostDest} = "BackupPC: Wiederherstellung beauftragt auf Computer \$hostDest";
$Lang{Reply_from_server_was___reply} = <<EOF;
\${h1(\$str)}
<p>
Die Antwort des Servers war: \$reply
<p>
Zur�ck zur <a href="\$MyURL?host=\$hostDest">\$hostDest Hauptseite</a>.
EOF

$Lang{BackupPC_Archive_Reply_from_server} = <<EOF;
\${h1(\$str)}
<p>
Die Antwort des Server war: \$reply
EOF

# -------------------------
$Lang{Host__host_Backup_Summary} = "BackupServer: Computer \$host Backup�bersicht";

$Lang{Host__host_Backup_Summary2} = <<EOF;
\${h1("Computer \$host Backup�bersicht")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>
</p>
\${h2("Benutzeraktionen")}
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
\${h2("Backup�bersicht")}
<p>
Klicken Sie auf die Backupnummer um die Dateien zu durchsuchen und bei Bedarf wiederherzustellen.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> Backup# </td>
    <td align="center"> Typ </td>
    <td align="center"> gef�llt </td>
    <td align="center"> Level </td>
    <td align="center"> Start Zeitpunkt </td>
    <td align="center"> Dauer/min </td>
    <td align="center"> Alter/Tage </td>
    <td align="center"> Serverbackuppfad </td>
</tr>
\$str
</table>
<p>

\$restoreStr
</p>
\${h2("Xfer Fehler �bersicht - bitte kontrollieren")}
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Backup# </td>
    <td align="center"> Typ </td>
    <td align="center"> Anzeigen </td>
    <td align="center"> #Xfer Fehler </td>
    <td align="center"> #Dateifehler </td>
    <td align="center"> #Freigabefehler </td>
    <td align="center"> #tar Fehler </td>
</tr>
\$errStr
</table>

\${h2("Datei Gr��e/Anzahl Wiederverwendungs�bersicht")}
<p>
"Bestehende Dateien" bedeutet bereits im Pool vorhanden.
"Neue Dateien" bedeutet neu zum Pool hinzugef�gt.
Leere Dateien und eventuelle Dateifehler sind nicht in den Summen enthalten.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="2" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> Gesamt </td>
    <td align="center" colspan="2"> bestehende Dateien </td>
    <td align="center" colspan="2"> neue Dateien </td>
</tr>
<tr class="tableheader">
    <td align="center"> Backup# </td>
    <td align="center"> Typ </td>
    <td align="center"> #Dateien </td>
    <td align="center"> Gr��e/MB </td>
    <td align="center"> MB/sec </td>
    <td align="center"> #Dateien </td>
    <td align="center"> Gr��e/MB </td>
    <td align="center"> #Dateien </td>
    <td align="center"> Gr��e/MB </td>
</tr>
\$sizeStr
</table>

\${h2("Kompressions �bersicht")}
<p>
Kompressionsergebnisse f�r bereits im Backup-Pool vorhandene und f�r neu komprimierte Dateien.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="3" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> vorhandene Dateien </td>
    <td align="center" colspan="3"> neue Dateien </td>
</tr>
<tr class="tableheader"><td align="center"> Backup# </td>
    <td align="center"> Typ </td>
    <td align="center"> Komp Level </td>
    <td align="center"> Gr��e/MB </td>
    <td align="center"> Komp/MB </td>
    <td align="center"> Komp </td>
    <td align="center"> Gr��e/MB </td>
    <td align="center"> Komp/MB </td>
    <td align="center"> Komp </td>
</tr>
\$compStr
</table>
EOF

$Lang{Host__host_Archive_Summary} = "BackupPC: Host \$host Archiv�bersicht";
$Lang{Host__host_Archive_Summary2} = <<EOF;
\${h1("Host \$host Archiv�bersicht")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>

\${h2("Benutzeraktionen")}
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
$Lang{Error} = "BackupServer: Fehler";
$Lang{Error____head} = <<EOF;
\${h1("Fehler: \$head")}
<p>\$mesg</p>
EOF

# -------------------------
$Lang{NavSectionTitle_} = "Server";

# -------------------------
$Lang{Backup_browse_for__host} = <<EOF;
\${h1("Backup durchsuchen f�r den Computer \$host")}

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
<li>Sie browsen das Backup #\$num, erstellt am \$backupTime
        (vor \$backupAge Tagen),
\$filledBackup
<li> Verzeichnis eingeben: <input type="text" name="dir" size="50" maxlength="4096" value="\${EscHTML(\$dir)}"> <input type="submit" value="\$Lang->{Go}" name="Submit">
<li> Klicken Sie auf ein Verzeichnis um dieses zu durchsuchen.
<li> Klicken Sie auf eine Datei um diese per Download wiederherzustellen.
<li> Einsehen der Backup <a href="\$MyURL?action=dirHistory&host=\${EscURI(\$host)}&share=\$shareURI&dir=\$pathURI">Historie</a> des aktuellen Verzeichnisses.
</ul>
</form>

\${h2("Inhalt von \$dirDisplay")}
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
<input type="submit" name="Submit" value="Selektion wiederherstellen">
-->
</form>
EOF

# ------------------------------
$Lang{DirHistory_backup_for__host} = "BackupPC: Verzeichnishistorie f�r \$host";

#
# These two strings are used to build the links for directories and
# file versions.  Files are appended with a version number.
#
$Lang{DirHistory_dirLink}  = "Verzeichnis";
$Lang{DirHistory_fileLink} = "V";

$Lang{DirHistory_for__host} = <<EOF;
\${h1("Verzeichnis Sicherungshistorie f�r \$host")}
<p>
Diese Ansicht zeigt alle unterschiedlichen Versionen der Dateien in den Datensicherungen:
<ul>
<li> Klicken Sie auf eine Datensicherungsnummer f�r die Datensicherungs�bersicht.
<li> W�hlen Sie hier auf einen Verzeichnis Namen: (\$Lang->{DirHistory_dirLink}) um Verzeichnisse anzuzeigen.
<li> Klicken Sie auf eine Dateiversion (\$Lang->{DirHistory_fileLink}0,
     \$Lang->{DirHistory_fileLink}1, ...) f�r einen Download der Datei.
<li> Dateien mit dem gleichen Inhalt in verschiedenen Datensicherungen haben die gleiche Versionsnummer.
<li> Dateien oder Verzeichnisse, die in einer Datensicherung nicht vorhanden sind, haben dort keinen Eintrag.
<li> Dateien mit der gleichen Version k�nnen unterschiedliche Attribute haben. W�hlen Sie die Datensicherungsnummer um die Attribute anzuzeigen.
</ul>

\${h2("Historie von \$dirDisplay")}

<br>
<table border cellspacing="2" cellpadding="3">
<tr class="fviewheader"><td>Datensicherungnummer</td>\$backupNumStr</tr>
<tr class="fviewheader"><td>Sicherungszeitpunkt</td>\$backupTimeStr</tr>
\$fileStr
</table>
EOF

# ------------------------------
$Lang{Restore___num_details_for__host} = "BackupPC: Restore #\$num Details f�r Computer \$host";

$Lang{Restore___num_details_for__host2} = <<EOF;
\${h1("Restore #\$num Details f�r Computer \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="90%">
<tr><td class="tableheader"> Nummer </td><td class="border"> \$Restores[\$i]{num} </td></tr>
<tr><td class="tableheader"> beauftragt von </td><td class="border"> \$RestoreReq{user} </td></tr>
<tr><td class="tableheader"> Auftrag Zeitpunkt </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> Ergebnis </td><td class="border"> \$Restores[\$i]{result} </td></tr>
<tr><td class="tableheader"> Fehlermeldung </td><td class="border"> \$Restores[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> Quelle Computer </td><td class="border"> \$RestoreReq{hostSrc} </td></tr>
<tr><td class="tableheader"> Quelle Backup Nr. </td><td class="border"> \$RestoreReq{num} </td></tr>
<tr><td class="tableheader"> Quelle Freigabe </td><td class="border"> \$RestoreReq{shareSrc} </td></tr>
<tr><td class="tableheader"> Ziel Computer </td><td class="border"> \$RestoreReq{hostDest} </td></tr>
<tr><td class="tableheader"> Ziel Freigabe </td><td class="border"> \$RestoreReq{shareDest} </td></tr>
<tr><td class="tableheader"> Start Zeitpunkt </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Dauer </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> Anzahl Dateien </td><td class="border"> \$Restores[\$i]{nFiles} </td></tr>
<tr><td class="tableheader"> Gr��e gesamt </td><td class="border"> \${MB} MB </td></tr>
<tr><td class="tableheader"> Transferrate </td><td class="border"> \$MBperSec MB/sec </td></tr>
<tr><td class="tableheader"> TarCreate Fehler </td><td class="border"> \$Restores[\$i]{tarCreateErrs} </td></tr>
<tr><td class="tableheader"> Xfer Fehler </td><td class="border"> \$Restores[\$i]{xferErrs} </td></tr>
<tr><td class="tableheader"> Xfer LOG Datei </td><td class="border">
<a href="\$MyURL?action=view&type=RestoreLOG&num=\$Restores[\$i]{num}&host=\$host">Anzeigen</a>,
<a href="\$MyURL?action=view&type=RestoreErr&num=\$Restores[\$i]{num}&host=\$host">Fehler</a>
</tr></tr>
</table>
</p>
\${h1("Datei/Verzeichnis Liste")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="100%">
<tr class="tableheader"><td>Original Datei/Verzeichnis</td><td>wiederhergestellt nach</td></tr>
\$fileListStr
</table>
EOF

# ------------------------------
$Lang{Archive___num_details_for__host} = "BackupPC: Archiv #\$num Details f�r \$host";

$Lang{Archive___num_details_for__host2 } = <<EOF;
\${h1("Archiv #\$num Details f�r \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr><td class="tableheader"> Nummer </td><td class="border"> \$Archives[\$i]{num} </td></tr>
<tr><td class="tableheader"> beauftragt von </td><td class="border"> \$ArchiveReq{user} </td></tr>
<tr><td class="tableheader"> Auftrag Zeitpunkt</td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> Ergebnis </td><td class="border"> \$Archives[\$i]{result} </td></tr>
<tr><td class="tableheader"> Fehlermeldung </td><td class="border"> \$Archives[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> Start Zeitpunkt </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Dauer </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> Xfer LOG Datei </td><td class="border">
<a href="\$MyURL?action=view&type=ArchiveLOG&num=\$Archives[\$i]{num}&host=\$host">Anzeigen</a>,
<a href="\$MyURL?action=view&type=ArchiveErr&num=\$Archives[\$i]{num}&host=\$host">Fehler</a>
</tr></tr>
</table>
<p>
\${h1("Computerliste")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td>Computer</td><td>Datensicherungsnummer</td></tr>
\$HostListStr
</table>
EOF

# -----------------------------------
$Lang{Email_Summary} = "BackupPC: Email�bersicht";

# -----------------------------------
#  !! ERROR messages !!
# -----------------------------------
$Lang{BackupPC__Lib__new_failed__check_apache_error_log} = "BackupPC::Lib->new failed: �berpr�fen Sie das Apache error_log\n";
$Lang{Wrong_user__my_userid_is___} =  
              "Falscher Benutzer: Meine userid ist \$>, anstelle \$uid"
            . "(\$Conf{BackupPCUser})\n";
# $Lang{Only_privileged_users_can_view_PC_summaries} = "Nur berechtigte Benutzer k�nnen die Computer �bersicht einsehen.";
$Lang{Only_privileged_users_can_stop_or_start_backups} = 
                  "Nur berechtigte Benutzer k�nnen Backups starten und stoppen f�r"
		. " \${EscHTML(\$host)}.";
$Lang{Invalid_number__num} = "ung�ltige Nummer \${EscHTML(\$In{num})}";
$Lang{Unable_to_open__file__configuration_problem} = "kann Datei nicht �ffnen \$file: Konfigurationsproblem?";
$Lang{Only_privileged_users_can_view_log_or_config_files} = "Nur berechtigte Benutzer k�nnen Log oder Config Dateien einsehen.";
$Lang{Only_privileged_users_can_view_log_files} = "Nur berechtigte Benutzer k�nnen LOG Dateien einsehen.";
$Lang{Only_privileged_users_can_view_email_summaries} = "Nur berechtigte Benutzer k�nnen die Email �bersicht einsehen.";
$Lang{Only_privileged_users_can_browse_backup_files} = "Nur berechtigte Benutzer k�nnen Backup Dateien durchsuchen"
                . " f�r computer \${EscHTML(\$In{host})}.";
$Lang{Empty_host_name} = "Kein Hostname.";
$Lang{Directory___EscHTML} = "Verzeichnis \${EscHTML(\"\$TopDir/pc/\$host/\$num\")}"
		    . " ist leer";
$Lang{Can_t_browse_bad_directory_name2} = "Kann fehlerhaften Verzeichnisnamen nicht durchsuchen"
	            . " \${EscHTML(\$relDir)}";
$Lang{Only_privileged_users_can_restore_backup_files} = "Nur berechtigte Benutzer k�nnen Dateien wiederherstellen"
                . " f�r Computer \${EscHTML(\$In{host})}.";
$Lang{Bad_host_name} = "Falscher Computer Name \${EscHTML(\$host)}";
$Lang{You_haven_t_selected_any_files__please_go_Back_to} = "Sie haben keine Dateien selektiert; bitte gehen Sie zur�ck um"
                . " Dateien zu selektieren.";
$Lang{You_haven_t_selected_any_hosts} = "Sie haben keinen Computer gew�hlt, bitte zur�ck gehen um einen auszuw�hlen.";
$Lang{Nice_try__but_you_can_t_put} = "Sie d�rfen \'..\' nicht in Dateinamen verwenden";
$Lang{Host__doesn_t_exist} = "Computer \${EscHTML(\$In{hostDest})} existiert nicht";
$Lang{You_don_t_have_permission_to_restore_onto_host} = "Sie haben keine Berechtigung zum Restore auf Computer"
		    . " \${EscHTML(\$In{hostDest})}";
$Lang{Can_t_open_create__openPath} = "Kann Datei nicht �ffnen oder erstellen "
		. "\${EscHTML(\"\$openPath\")}";
$Lang{Only_privileged_users_can_restore_backup_files2} = "Nur berechtigte Benutzer d�rfen Backup und Restore von Dateien"
                . " f�r Computer \${EscHTML(\$host)} durchf�hren.";
$Lang{Empty_host_name} = "leerer Computer Name";
$Lang{Unknown_host_or_user} = "Unbekannter Computer oder Benutzer \${EscHTML(\$host)}";
$Lang{Only_privileged_users_can_view_information_about} = "Nur berechtigte Benutzer k�nnen Informationen sehen �ber"
                . " Computer \${EscHTML(\$host)}." ;
$Lang{Only_privileged_users_can_view_archive_information} = "Nur berechtigte Benutzer k�nnen Archiv Informationen einsehen.";
$Lang{Only_privileged_users_can_view_restore_information} = "Nur berechtigte Benutzer k�nnen Restore Informationen einsehen.";
$Lang{Restore_number__num_for_host__does_not_exist} = "Restore Nummer \$num f�r Computer \${EscHTML(\$host)} existiert"
	        . " nicht.";
$Lang{Archive_number__num_for_host__does_not_exist} = "Archiv Nummer \$num f�r Computer \${EscHTML(\$host)} existiert"
                . " nicht.";
$Lang{Can_t_find_IP_address_for} = "Kann IP-Adresse f�r \${EscHTML(\$host)} nicht finden";
$Lang{host_is_a_DHCP_host} = <<EOF;
\$host ist ein DHCP Computer und ich kenne seine IP-Adresse nicht.  Ich pr�fte den
netbios Namen von \$ENV{REMOTE_ADDR}\$tryIP und erkannte, dass es nicht der Computer \$host ist.
<p>
Solange bis ich \$host mit einer DHCP-Adresse sehe, k�nnen Sie diesen Auftrag nur
vom diesem Client Computer aus starten.
EOF

# ------------------------------------
# !! Server Mesg !!
# ------------------------------------

$Lang{Backup_requested_on_DHCP__host} = "Backup angefordert f�r DHCP Computer \$host (\$In{hostIP}) durch"
		                      . " \$User von \$ENV{REMOTE_ADDR}";
$Lang{Backup_requested_on__host_by__User} = "Backup angefordert f�r \$host durch \$User";
$Lang{Backup_stopped_dequeued_on__host_by__User} = "Backup gestoppt/gel�scht f�r \$host durch \$User";
$Lang{Restore_requested_to_host__hostDest__backup___num} = "Restore beauftragt nach Computer \$hostDest, von Backup #\$num,"
	     . " durch User \$User von Client \$ENV{REMOTE_ADDR}";
$Lang{Archive_requested} = "Archivierung beauftragt durch \$User von \$ENV{REMOTE_ADDR}";

# -------------------------------------------------
# ------- Stuff that was forgotten ----------------
# -------------------------------------------------

$Lang{Status} = "Status";
$Lang{PC_Summary} = "Computer�bersicht";
$Lang{LOG_file} = "LOG Datei";
$Lang{LOG_files} = "LOG Dateien";
$Lang{Old_LOGs} = "Alte LOG Dateien";
$Lang{Email_summary} = "Email�bersicht";
$Lang{Config_file} = "Konfigurationsdatei";
# $Lang{Hosts_file} = "Hosts Datei";
$Lang{Current_queues} = "Warteschlangen";
$Lang{Documentation} = "Dokumentation";

#$Lang{Host_or_User_name} = "<small>Computer oder Benutzer Name:</small>";
$Lang{Go} = "gehe zu";
$Lang{Hosts} = "Computer";
$Lang{Select_a_host} = "Computer ausw�hlen...";

$Lang{There_have_been_no_archives} = "<h2> Es existieren keine Archive </h2>\n";
$Lang{This_PC_has_never_been_backed_up} = "<h2> Dieser Computer wurde nie gesichert! </h2>\n";
$Lang{This_PC_is_used_by} = "<li>Dieser Computer wird betreut von \${UserLink(\$user)}";

$Lang{Extracting_only_Errors} = "(nur Fehler anzeigen)";
$Lang{XferLOG} = "XferLOG";
$Lang{Errors}  = "Fehler";

# ------------
$Lang{Last_email_sent_to__was_at___subject} = <<EOF;
<li>Letzte eMail gesendet an \${UserLink(\$user)} am  \$mailTime, Titel "\$subj".
EOF
# ------------
$Lang{The_command_cmd_is_currently_running_for_started} = <<EOF;
<li>Das Kommando \$cmd wird gerade f�r Computer \$host ausgef�hrt, gestartet am \$startTime.
EOF

# -----------
$Lang{Host_host_is_queued_on_the_background_queue_will_be_backed_up_soon} = <<EOF;
<li>Computer \$host ist in die Hintergrundwarteschlange eingereiht (Backup wird bald gestartet).
EOF

# ----------
$Lang{Host_host_is_queued_on_the_user_queue__will_be_backed_up_soon} = <<EOF;
<li>Computer \$host ist in die Benutzerwarteschlange eingereiht (Backup wird bald gestartet).
EOF

# ---------
$Lang{A_command_for_host_is_on_the_command_queue_will_run_soon} = <<EOF;
<li>Ein Kommando f�r Computer \$host ist in der Kommandowarteschlange (wird bald ausgef�hrt).
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
<li>\$priorStr zu Computer \$host waren \$StatusHost{aliveCnt}
        mal fortlaufend erfolgreich.
EOF

$Lang{Because__host_has_been_on_the_network_at_least__Conf_BlackoutGoodCnt_consecutive_times___} = <<EOF;
<li>Da Computer \$host mindestens \$Conf{BlackoutGoodCnt}
mal fortlaufend erreichbar war, wird er in der Zeit von \$blackoutStr nicht gesichert. (Die Sicherung
erfolgt automatisch au�erhalb der konfigurierten Betriebszeit)
EOF

$Lang{__time0_to__time1_on__days} = "\$t0 bis \$t1 am \$days";

$Lang{Backups_are_deferred_for_hours_hours_change_this_number} = <<EOF;
<li>Backups sind f�r die n�chsten \$hours Stunden deaktiviert.
(<a href=\"\$MyURL?action=Stop_Dequeue_Backup&host=\$host\">diese Zeit �ndern</a>).
EOF

$Lang{tryIP} = " und \$StatusHost{dhcpHostIP}";

#$Lang{Host_Inhost} = "Computer \$In{host}";

$Lang{checkAll} = <<EOF;
<tr><td class="fviewborder">
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;alles ausw�hlen
</td><td colspan="5" align="center" class="fviewborder">
<input type="submit" name="Submit" value="Selektion wiederherstellen">
</td></tr>
EOF

$Lang{checkAllHosts} = <<EOF;
<tr><td class="fviewborder">
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;alle ausw�hlen
</td><td colspan="2" align="center" class="fviewborder">
<input type="submit" name="Submit" value="Gew�hlte Computer archivieren">
</td></tr>
EOF

$Lang{fileHeader} = <<EOF;
    <tr class="fviewheader"><td align=center> Name</td>
       <td align="center"> Typ</td>
       <td align="center"> Rechte</td>
       <td align="center"> Backup#</td>
       <td align="center"> Gr��e</td>
       <td align="center"> letzte �nderung</td>
    </tr>
EOF

$Lang{Home} = "Hauptseite";
$Lang{Browse} = "Datensicherungen anzeigen";
$Lang{Last_bad_XferLOG} = "Letztes fehlerhafte XferLOG";
$Lang{Last_bad_XferLOG_errors_only} = "Letztes fehlerhafte XferLOG (nur&nbsp;Fehler)";

$Lang{This_display_is_merged_with_backup} = <<EOF;
<li> Diese Liste ist mit Backup #\$numF verbunden.
EOF

$Lang{Visit_this_directory_in_backup} = <<EOF;
<li> W�hlen Sie die anzuzeigende Datensicherung: <select onChange="window.location=this.value">\$otherDirs </select>
EOF

$Lang{Restore_Summary} = <<EOF;
\${h2("Restore �bersicht")}
<p>
Klicken Sie auf die Restore Nummer (Restore#) f�r mehr Details.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Restore# </td>
    <td align="center"> Ergebnis </td>
    <td align="right"> Start Zeitpunkt</td>
    <td align="right"> Dauer/min </td>
    <td align="right"> #Dateien </td>
    <td align="right"> Gr��e/MB </td>
    <td align="right"> #tar Fehler </td>
    <td align="right"> #Xfer Fehler </td>
</tr>
\$restoreStr
</table>
<p>
EOF

$Lang{Archive_Summary} = <<EOF;
\${h2("Archiv �bersicht")}
<p>
Klicken Sie auf die Archiv Nummer um die Details anzuzeigen.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Archiv# </td>
    <td align="center"> Ergebnis </td>
    <td align="right"> Start Zeitpunkt</td>
    <td align="right"> Dauer/min.</td>
</tr>
\$ArchiveStr
</table>
<p>
EOF

$Lang{BackupPC__Documentation} = "BackupPC: Dokumentation";

$Lang{No} = "nein";
$Lang{Yes} = "ja";

$Lang{The_directory_is_empty} = <<EOF;
<tr><td bgcolor="#ffffff">Das Verzeichnis \$dirDisplay ist leer.
</td></tr>
EOF

#$Lang{on} = "an";
$Lang{off} = "aus";

$Lang{backupType_full}    = "voll";
$Lang{backupType_incr}    = "inkrementell";
$Lang{backupType_active}  = "active";
$Lang{backupType_partial} = "unvollst�ndig";

$Lang{failed} = "fehler";
$Lang{success} = "erfolgreich";
$Lang{and} = "und";

# ------
# Hosts states and reasons
$Lang{Status_idle} = "wartet";
$Lang{Status_backup_starting} = "Backup startet";
$Lang{Status_backup_in_progress} = "Backup l�uft";
$Lang{Status_restore_starting} = "Restore startet";
$Lang{Status_restore_in_progress} = "Restore l�uft";
$Lang{Status_admin_pending} = "Link steht an";
$Lang{Status_admin_running} = "Link l�uft";

$Lang{Reason_backup_done} = "Backup durchgef�hrt";
$Lang{Reason_restore_done} = "Restore durchgef�hrt";
$Lang{Reason_archive_done} = "Archivierung durchgef�hrt";
$Lang{Reason_nothing_to_do} = "kein Auftrag";
$Lang{Reason_backup_failed} = "Backup Fehler";
$Lang{Reason_restore_failed} = "Restore Fehler";
$Lang{Reason_archive_failed} = "Archivierung Fehler";
$Lang{Reason_no_ping} = "nicht erreichbar";
$Lang{Reason_backup_canceled_by_user} = "Abbruch durch Benutzer";
$Lang{Reason_restore_canceled_by_user} = "Abbruch durch Benutzer";
$Lang{Reason_archive_canceled_by_user} = "Archivierung abgebrochen durch Benutzer";
$Lang{Disabled_OnlyManualBackups}  = "autom. deaktiviert";
$Lang{Disabled_AllBackupsDisabled} = "deaktiviert";

# ---------
# Email messages

# No backup ever
$Lang{EMailNoBackupEverSubj} = "BackupPC: keine Backups von \$host waren erfolgreich";
$Lang{EMailNoBackupEverMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
Hallo $userName,

Ihr Computer ($host) wurde durch den Backup Server noch nie erfolgreich gesichert.

Backups sollten automatisch erfolgen, wenn Ihr Computer am Netzwerk angeschlossen ist.
Sie sollten Ihren Backup-Betreuer oder den IT-Dienstleister kontaktieren, wenn:

  - Ihr Computer regelm��ig am Netzwerk angeschlossen ist. Dann handelt es sich
    um ein Installations- bzw. Konfigurationsproblem, was die Durchf�hrung von
    automatischen Backups verhindert.

  - Wenn Sie kein automatisches Backup des Computers brauchen und diese e-mail nicht
    mehr erhalten m�chten.

Andernfalls sollten Sie sicherstellen, da� Ihr Computer regelm��ig korrekt am Netzwerk
angeschlossen wird.

Mit freundlichen Gr��en,
Ihr BackupPC Server
http://backuppc.sourceforge.net
EOF

# No recent backup
$Lang{EMailNoBackupRecentSubj} = "BackupPC: keine neuen Backups f�r Computer \$host";
$Lang{EMailNoBackupRecentMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
Hallo $userName,

Ihr Computer ($host) wurde seit $days Tagen nicht mehr erfolgreich gesichert.

Ihr Computer wurde von vor $firstTime Tagen bis vor $days Tagen $numBackups mal
erfolgreich gesichert.
Backups sollten automatisch erfolgen, wenn Ihr Computer am Netzwerk angeschlossen ist.

Wenn Ihr Computer in den letzten $days Tagen mehr als ein paar Stunden am
Netzwerk angeschlossen war, sollten Sie Ihren Backup-Betreuer oder
den IT-Dienstleister kontaktieren um die Ursache zu ermitteln und zu beheben.
Andernfalls, wenn Sie z.B. lange Zeit nicht im B�ro sind, k�nnen Sie h�chstens
manuell Ihre Dateien sichern (evtl. kopieren auf eine externe Festplatte).

Bitte denken Sie daran, dass alle in den letzten $days Tagen ge�nderten Dateien (z.B.
auch Emails und Anh�nge oder Datenbankeintr�ge) verloren gehen falls Ihre
Festplatte ausf�llt oder Dateien durch versehentliches L�schen oder
Virenbefall unbrauchbar werden.

Mit freundlichen Gr��en,
Ihr BackupPC Server
http://backuppc.sourceforge.net
EOF

# Old Outlook files
$Lang{EMailOutlookBackupSubj} = "BackupServer: Outlook-Dateien auf Computer \$host - Sicherung erforderlich";
$Lang{EMailOutlookBackupMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
Hallo $userName,

die Outlook Dateien auf Ihrem Computer wurden $howLong Tage nicht gesichert.
Diese Dateien enthalten Ihre Emails, Anh�nge, Adressen und Kalender.

Ihr Computer wurde zwar $numBackups mal seit $firstTime Tagen bis vor $lastTime Tagen
gesichert. Allerdings sperrt Outlook den Zugriff auf diese Dateien.

Es wird folgendes Vorgehen empfohlen:

1. Der Computer muss an das BackupServer Netzwerk angeschlossen sein.
2. Beenden Sie das Outlook Programm.
3. Starten Sie ein inkrementelles Backup mit dem Internet-Browser hier: 

    $CgiURL?host=$host               

    Name und Passwort eingeben und dann 2 mal nacheinander
    auf "Starte inkrementelles Backup" klicken
    Klicken Sie auf "Gehe zur�ck zur ...Hauptseite" und beobachten Sie
    den Status des Backupvorgangs (Browser von Zeit zu Zeit aktualisieren).
    Das sollte je nach Dateigr��e nur eine kurze Zeit dauern.
    

Mit freundlichen Gr��en,
Ihr BackupPC Server
http://backuppc.sourceforge.net
EOF

$Lang{howLong_not_been_backed_up} = "Backup nicht erfolgreich";
$Lang{howLong_not_been_backed_up_for_days_days} = "Kein Backup seit \$days Tagen";

#######################################################################
# RSS strings
#######################################################################
$Lang{RSS_Doc_Title}       = "BackupPC Server";
$Lang{RSS_Doc_Description} = "RSS Feed f�r BackupPC";
$Lang{RSS_Host_Summary}    = <<EOF;
#Voll: \$fullCnt;
Alter/Tagen: \$fullAge;
Gr��e/GiB: \$fullSize;
MB/sek: \$fullRate;
#Inkr: \$incrCnt;
Alter/Tage: \$incrAge;
Status: \$host_state;
Letzte Aktion: \$host_last_attempt;
EOF

#######################################################################
# Configuration editor strings
#######################################################################

$Lang{Only_privileged_users_can_edit_config_files} = "Nur privilegierte Nutzer k�nnen die Administrationsoptionen �ndern.";
$Lang{CfgEdit_Edit_Config} = "Konfiguration �ndern";
$Lang{CfgEdit_Edit_Hosts}  = "Hosts �ndern";

$Lang{CfgEdit_Title_Server} = "Server";
$Lang{CfgEdit_Title_General_Parameters} = "Allgemeine Einstellungen";
$Lang{CfgEdit_Title_Wakeup_Schedule} = "Aktivierungsplan";
$Lang{CfgEdit_Title_Concurrent_Jobs} = "gleichzeitige Auftr�ge";
$Lang{CfgEdit_Title_Pool_Filesystem_Limits} = "Pooldateisystem Begrenzungen";
$Lang{CfgEdit_Title_Other_Parameters} = "Andere Einstellungen";
$Lang{CfgEdit_Title_Remote_Apache_Settings} = "Apache Remote Einstellungen";
$Lang{CfgEdit_Title_Program_Paths} = "Programmpfade";
$Lang{CfgEdit_Title_Install_Paths} = "Installationspfade";
$Lang{CfgEdit_Title_Email} = "Email";
$Lang{CfgEdit_Title_Email_settings} = "Email Einstellungen";
$Lang{CfgEdit_Title_Email_User_Messages} = "Email Benutzernachrichten";
$Lang{CfgEdit_Title_CGI} = "CGI";
$Lang{CfgEdit_Title_Admin_Privileges} = "Admininistrationsprivilegien";
$Lang{CfgEdit_Title_Page_Rendering} = "Seitenrendering";
$Lang{CfgEdit_Title_Paths} = "Pfade";
$Lang{CfgEdit_Title_User_URLs} = "Benutzer URLs";
$Lang{CfgEdit_Title_User_Config_Editing} = "Benutzerkonfiguration �ndern";
$Lang{CfgEdit_Title_Xfer} = "Xfer";
$Lang{CfgEdit_Title_Xfer_Settings} = "Xfer Einstellungen";
$Lang{CfgEdit_Title_Ftp_Settings} = "FTP Einstellungen";
$Lang{CfgEdit_Title_Smb_Settings} = "Smb Einstellungen";
$Lang{CfgEdit_Title_Tar_Settings} = "Tar Einstellungen";
$Lang{CfgEdit_Title_Rsync_Settings} = "Rsync Einstellungen";
$Lang{CfgEdit_Title_Rsyncd_Settings} = "Rsyncd Einstellungen";
$Lang{CfgEdit_Title_Archive_Settings} = "Archive Einstellungen";
$Lang{CfgEdit_Title_Include_Exclude} = "Include/Exclude";
$Lang{CfgEdit_Title_Smb_Paths_Commands} = "Smb Pfade/Kommandos";
$Lang{CfgEdit_Title_Tar_Paths_Commands} = "Tar Pfade/Kommandos";
$Lang{CfgEdit_Title_Rsync_Paths_Commands_Args} = "Rsync Pfade/Kommandos/Argumente";
$Lang{CfgEdit_Title_Rsyncd_Port_Args} = "Rsyncd Port/Argumente";
$Lang{CfgEdit_Title_Archive_Paths_Commands} = "Archive Pfade/Kommandos";
$Lang{CfgEdit_Title_Schedule} = "Backupplan";
$Lang{CfgEdit_Title_Full_Backups} = "volle Backups";
$Lang{CfgEdit_Title_Incremental_Backups} = "inkrementelle Backups";
$Lang{CfgEdit_Title_Blackouts} = "Blackouts";
$Lang{CfgEdit_Title_Other} = "Andere";
$Lang{CfgEdit_Title_Backup_Settings} = "Backup Einstellungen";
$Lang{CfgEdit_Title_Client_Lookup} = "Aufl�sen des Klienten";
$Lang{CfgEdit_Title_User_Commands} = "Benutzer Kommandos";
$Lang{CfgEdit_Title_Hosts} = "Hosts";

$Lang{CfgEdit_Hosts_Comment} = <<EOF;
Um einen neuen Hosts hinzuzuf�gen, w�hle Hinzuf�gen und gib 
dann den Namen ein. Um mit der Konfigurationvorlage eines anderen Hosts
zu beginnen, gib als Namen NEWHOST=COPYHOST ein. Dies wird alle
bereits bestehenden hostspezifischen Einstellungen f�r NEWHOST
mit den Werten von COPYHOST �berschreiben. Du kannst dies auch f�r einen bereits 
bestehenden Hosts machen. Um einen Host zu l�schen, w�hle den L�schen Knopf.
Das Hinzuf�gen, L�schen und Kopieren von Konfigurationen pro Host
wird erst durch w�hlen von Speichern aktiviert. Bereits bestehende
Backups werden beim L�schen eines Hosts nicht mitgel�scht. Nach einem
erneuten Anlegen des selben Hosts sind alle alten Backups wieder verf�gbar.
Um Backups vollst�ndig zu entfernen m�ssen die Dateien unter \$topDir/pc/HOST
gel�scht werden.
EOF

$Lang{CfgEdit_Header_Main} = <<EOF;
\${h1("Allgemeiner Konfigurationseditor")}
EOF

$Lang{CfgEdit_Header_Host} = <<EOF;
\${h1("Host \$host Konfigurationseditor")}
<p>
Beachte: W�hle �berschreiben, wenn du einen computerspezifischen Wert ver�ndern willst 
<p>
EOF

$Lang{CfgEdit_Button_Save}     = "Speichern";
$Lang{CfgEdit_Button_Insert}   = "Einf�gen";
$Lang{CfgEdit_Button_Delete}   = "L�schen";
$Lang{CfgEdit_Button_Add}      = "Hinzuf�gen";
$Lang{CfgEdit_Button_Override} = "�berschreiben";
$Lang{CfgEdit_Button_New_Key}  = "Neuer Schl�ssel";
$Lang{CfgEdit_Button_New_Share} = "New ShareName or '*'";

$Lang{CfgEdit_Error_No_Save}
            = "Wegen Fehlern nicht gesichert";
$Lang{CfgEdit_Error__must_be_an_integer}
            = "Error: \$var muss eine Zahl sein";
$Lang{CfgEdit_Error__must_be_real_valued_number}
            = "Error: \$var muss eine ganze Zahl sein";
$Lang{CfgEdit_Error__entry__must_be_an_integer}
            = "Error: \$var Eintrag \$k muss eine Zahl sein";
$Lang{CfgEdit_Error__entry__must_be_real_valued_number}
            = "Error: \$var Eintrag \$k muss eine ganze Zahl sein";
$Lang{CfgEdit_Error__must_be_executable_program}
            = "Error: \$var muss ein g�ltiger ausf�hrbarer Pfad sein";
$Lang{CfgEdit_Error__must_be_valid_option}
            = "Error: \$var muss eine g�ltige Option sein";
$Lang{CfgEdit_Error_Copy_host_does_not_exist}
            = "Ursprungs Host \$copyHost existiert nicht; Erstelle den vollen Hostnamen \$fullHost.  L�sche den Host wenn das nicht war, was du wolltest.";

$Lang{CfgEdit_Log_Copy_host_config}
            = "\$User hat die Konfig von host \$fromHost zu \$host kopiert\n";
$Lang{CfgEdit_Log_Delete_param}
            = "\$User hat \$p von \$conf gel�scht\n";
$Lang{CfgEdit_Log_Add_param_value}
            = "\$User hat \$p zu \$conf hinzugef�gt und den Wert \$value gegeben\n";
$Lang{CfgEdit_Log_Change_param_value}
            = "\$User �nderte \$p in \$conf zu \$valueNew von \$valueOld\n";
$Lang{CfgEdit_Log_Host_Delete}
            = "\$User hat den Host \$host gel�scht\n";
$Lang{CfgEdit_Log_Host_Change}
            = "\$User Host \$host hat den Schl�ssel \$key von \$valueOld zu \$valueNew ge�ndert\n";
$Lang{CfgEdit_Log_Host_Add}
            = "\$User hat den Host \$host: \$value hinzugef�gt\n";
  
#end of lang_de.pm

