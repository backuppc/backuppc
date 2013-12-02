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

#File:  nl.pm       version 1.5
# --------------------------------

$Lang{Start_Archive} = "Start Archivering";
$Lang{Stop_Dequeue_Archive} = "Stop/Annuleer Archivering";
$Lang{Start_Full_Backup} = "Start volledige backup";
$Lang{Start_Incr_Backup} = "Start incrementele backup";
$Lang{Stop_Dequeue_Backup} = "Stop/Annuleer backup";
$Lang{Restore} = "Herstellen";

$Lang{Type_full} = "volledig";
$Lang{Type_incr} = "incrementeel";

# -----

$Lang{Only_privileged_users_can_view_admin_options} = "Alleen gebruikers met bijzondere rechten kunnen admin.-opties bekijken.";
$Lang{H_Admin_Options} = "BackupPC Server: Admin Opties";
$Lang{Admin_Options} = "Admin Opties";
$Lang{Admin_Options_Page} = <<EOF;
\${h1(qq{$Lang{Admin_Options}})}
<br>
\${h2("Besturing van de server")}
<form name="ReloadForm" action="\$MyURL" method="get">
<input type="hidden" name="action" value="">
<table class="tableStnd">
  <tr><td>Herlaad de configuratie van de server:<td><input type="button" value="Herlaad"
     onClick="document.ReloadForm.action.value='Reload';
              document.ReloadForm.submit();">
</table>
</form>
<!--
\${h2("Configuratie van de server")}
<ul>
  <li><i>Andere opties kunnen hier komen ... vb.,</i>
  <li>Wijzig configuratie van de server
</ul>
-->
EOF

$Lang{Unable_to_connect_to_BackupPC_server} = "Verbinding met de BackupPC server is mislukt";
$Lang{Unable_to_connect_to_BackupPC_server_error_message} = <<EOF;
Dit CGI script (\$MyURL) kon geen verbinding maken met de BackupPC-server
op \$Conf{ServerHost} poort \$Conf{ServerPort}.<br>
De foutmelding was: \$err.<br>
Mogelijk draait de BackupPC server niet of is er een
configuratiefout.  Gelieve dit te melden aan uw systeembeheerder.
EOF

$Lang{Admin_Start_Server} = <<EOF;
\${h1(qq{$Lang{Unable_to_connect_to_BackupPC_server}})}
<form action="\$MyURL" method="get">
De BackupPC-server op <tt>\$Conf{ServerHost}</tt> poort <tt>\$Conf{ServerPort}</tt>
werkt momenteel niet (misschien hebt u hem juist gestopt, of nog niet gestart).<br>
Wilt u de server nu starten?
<input type="hidden" name="action" value="startServer">
<input type="submit" value="Start Server" name="ignore">
</form>
EOF

# -----

$Lang{H_BackupPC_Server_Status} = "Overzicht BackupPC Server";

$Lang{BackupPC_Server_Status_General_Info}= <<EOF;
\${h2(\"Algemene Serverinformatie\")}

<ul>
<li> De PID (procesidentificatie) van de server is \$Info{pid},  op machine \$Conf{ServerHost},
     versie \$Info{Version}, gestart op \$serverStartTime.
<li> Dit overzicht werd gemaakt op \$now.
<li> De configuratie werd het laatst ingelezen op \$configLoadTime.
<li> Volgende backupsessie start op \$nextWakeupTime.
<li> Andere informatie:
    <ul>
        <li>\$numBgQueue wachtende backupaanvragen sinds laatste geplande wakeup,
        <li>\$numUserQueue wachtende backupaanvragen van gebruikers,
        <li>\$numCmdQueue wachtende opdrachten,
        \$poolInfo
        <li>Het backup filesystem werd recentelijk aangevuld voor \$Info{DUlastValue}%
            op (\$DUlastTime), het maximum van vandaag is \$Info{DUDailyMax}% (\$DUmaxTime)
            en het maximum van gisteren was \$Info{DUDailyMaxPrev}%.
    </ul>
</ul>
EOF

$Lang{BackupPC_Server_Status} = <<EOF;
\${h1(qq{$Lang{H_BackupPC_Server_Status}})}

<p>
\${h2("Momenteel lopende jobs")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td> Machine </td>
    <td> Type </td>
    <td> Gebruiker </td>
    <td> Starttijd </td>
    <td> Opdracht </td>
    <td align="center"> PID </td>
    <td align="center"> PID vd overdracht </td>
    <td align="center"> Status </td>
    <td align="center"> Count </td>
    </tr>
\$jobStr
</table>

<p>
\$generalInfo

\${h2("Opgetreden fouten die aandacht vragen")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> Machine </td>
    <td align="center"> Type </td>
    <td align="center"> Gebruiker </td>
    <td align="center"> Laatste poging </td>
    <td align="center"> Details </td>
    <td align="center"> Fouttijd </td>
    <td> Laatste fout (verschillend van 'geen ping') </td></tr>
\$statusStr
</table>
EOF

# --------------------------------
$Lang{BackupPC__Server_Summary} = "BackupPC: Overzicht machines";
$Lang{BackupPC__Archive} = "BackupPC: Archivering";
$Lang{BackupPC_Summary}=<<EOF;

\${h1(qq{$Lang{BackupPC__Server_Summary}})}
<p>
<ul>
<li>Dit overzicht dateert van \$now.
<li>Het backup filesystem werd recentelijk aangevuld voor \$Info{DUlastValue}%
     op (\$DUlastTime), het maximum van vandaag is \$Info{DUDailyMax}% (\$DUmaxTime)
     en het maximum van gisteren was \$Info{DUDailyMaxPrev}%.
</ul>
</p>

\${h2("Machine(s) met geslaagde backups")}
<p>
Er zijn \$hostCntGood hosts gebackupt, wat een totaal geeft van:
<ul>
<li> \$fullTot volledige backups met een totale grootte van \${fullSizeTot}GiB
     (voor samenvoegen),
<li> \$incrTot oplopende backups met een totale grootte van \${incrSizeTot}GiB
     (voor samenvoegen).
</ul>
</p>
<table class="sortable" id="host_summary_backups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> Machine </td>
    <td align="center"> Gebruiker </td>
    <td align="center"> Aantal Voll. </td>
    <td align="center"> Voll.Lftd (dagen) </td>
    <td align="center"> Voll.Grootte (GiB) </td>
    <td align="center"> Snelheid (MB/sec) </td>
    <td align="center"> Aantal Incr. </td>
    <td align="center"> Incr.Lftd (dagen) </td>
    <td align="center"> Vorige Backup (dagen) </td>
    <td align="center"> Status </td>
    <td align="center"> Aantal fouten </td>
    <td align="center"> Laatste poging</td></tr>
\$strGood
</table>
<br><br>
\${h2("Hosts zonder backups")}
<p>
Er zijn \$hostCntNone hosts zonder backup.
<p>
<table class="sortable" id="host_summary_nobackups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> Machine </td>
    <td align="center"> Gebruiker </td>
    <td align="center"> Aantal Voll. </td>
    <td align="center"> Voll.Lftd (dagen) </td>
    <td align="center"> Voll.Grootte (GiB) </td>
    <td align="center"> Snelheid (MB/sec) </td>
    <td align="center"> Aantal Incr. </td>
    <td align="center"> Incr.Lftd (dagen) </td>
    <td align="center"> Vorige Backup (dagen) </td>
    <td align="center"> Status </td>
    <td align="center"> Aantal fouten </td>
    <td align="center"> Laatste poging </td></tr>
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

Er zijn \$hostCntGood machines gebackupt die een totale grootte vertegenwoordigen van \${fullSizeTot}GiB
<p>
<form name="form1" method="post" action="\$MyURL">
<input type="hidden" name="fcbMax" value="\$checkBoxCnt">
<input type="hidden" name="type" value="1">
<input type="hidden" name="host" value="\${EscHTML(\$archHost)}">
<input type="hidden" name="action" value="Archive">
<table class="tableStnd" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td align=center> Machine</td>
    <td align="center"> Gebruiker </td>
    <td align="center"> Backupgrootte </td>
\$strGood
\$checkAllHosts
</table>
</form>
<p>

EOF

$Lang{BackupPC_Archive2} = <<EOF;
\${h1(qq{$Lang{BackupPC__Archive}})}
Klaar om de volgende machines te archiveren
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
    <td colspan=2><input type="submit" value="Start de archivering" name="ignore"></td>
</tr>
</form>
</table>
EOF

$Lang{BackupPC_Archive2_location} = <<EOF;
<tr>
    <td>Plaats van archivering /device</td>
    <td><input type="text" value="\$ArchiveDest" name="archive_device"></td>
</tr>
EOF

$Lang{BackupPC_Archive2_compression} = <<EOF;
<tr>
    <td>Compressie</td>
    <td>
    <input type="radio" value="0" name="compression" \$ArchiveCompNone>Geen<br>
    <input type="radio" value="1" name="compression" \$ArchiveCompGzip>gzip<br>
    <input type="radio" value="2" name="compression" \$ArchiveCompBzip2>bzip2
    </td>
</tr>
EOF

$Lang{BackupPC_Archive2_parity} = <<EOF;
<tr>
    <td>Pariteitspercentage (0 = geen, 5 = standaard)</td>
    <td><input type="numeric" value="\$ArchivePar" name="par"></td>
</tr>
EOF

$Lang{BackupPC_Archive2_split} = <<EOF;
<tr>
    <td>Opdelen (splitsen) in</td>
    <td><input type="numeric" value="\$ArchiveSplit" name="splitsize">Megabytes</td>
</tr>
EOF

# -----------------------------------
$Lang{Pool_Stat} = <<EOF;
        <li>Gebruikte backupschijfruimte is \${poolSize}GiB groot en bevat \$info->{"\${name}FileCnt"} bestanden
            en \$info->{"\${name}DirCnt"} mappen (op \$poolTime),
        <li>Schijfruimte bevat \$info->{"\${name}FileCntRep"} bestanden
            met identieke hashcodes
            (langste reeks is \$info->{"\${name}FileRepMax"},
        <li>Nachtelijke opruiming verwijderde \$info->{"\${name}FileCntRm"} bestanden
            met een grootte van \${poolRmSize}GiB (ongeveer \$poolTime),
EOF

# --------------------------------
$Lang{BackupPC__Backup_Requested_on__host} = "BackupPC: backup aangevraagd van \$host";
# --------------------------------
$Lang{REPLY_FROM_SERVER} = <<EOF;
\${h1(\$str)}
<p>
Antwoord van server was: \$reply
<p>
Terug naar <a href="\$MyURL?host=\$host">\$host hoofdpagina</a>.
EOF
# --------------------------------
$Lang{BackupPC__Start_Backup_Confirm_on__host} = "BackupPC: Bevestiging start van de backup van \$host";
# --------------------------------
$Lang{Are_you_sure_start} = <<EOF;
\${h1("Weet u het zeker?")}
<p>
Met deze actie start u een \$type backup van machine \$host.

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="hostIP" value="\$ipAddr">
<input type="hidden" name="doit" value="1">
<input type="hidden" name="action" value="">
Wilt u dat nu doen?
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="Neen" name="ignore">
</form>
EOF
# --------------------------------
$Lang{BackupPC__Stop_Backup_Confirm_on__host} = "BackupPC: Bevestiging de annulering van de backup van \$host";
# --------------------------------
$Lang{Are_you_sure_stop} = <<EOF;

\${h1("Weet u het zeker?")}

<p>
Met deze actie annuleert u de backup van pc \$host of haalt u de opdracht uit de wachtrij;

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host"   value="\$host">
<input type="hidden" name="doit"   value="1">
<input type="hidden" name="action" value="">
Start bovendien geen andere backup gedurende
<input type="text" name="backoff" size="10" value="\$backoff"> uur/uren.
<p>
Wilt u dit nu bevestigen?
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="Neen" name="ignore">
</form>

EOF
# --------------------------------
$Lang{Only_privileged_users_can_view_queues_} = "Enkel gebruikers met bijzondere rechten kunnen de wachtrij bekijken.";
# --------------------------------
$Lang{Only_privileged_users_can_archive} = "Enkel gebruikers met bijzondere rechten kunnen archiveren.";
# --------------------------------
$Lang{BackupPC__Queue_Summary} = "BackupPC: overzicht wachtrij";
# --------------------------------
$Lang{Backup_Queue_Summary} = <<EOF;
\${h1("Overzicht Wachtrij backup")}
<br><br>
\${h2("Overzicht Wachtrij: Gebruikers")}
<p>
Deze aanvragen van gebruikers staan momenteel in de wachtrij:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Machine </td>
    <td> Aanvraagtijd </td>
    <td> Gebruiker </td></tr>
\$strUser
</table>
<br><br>

\${h2("Overzicht Wachtrij: in achtergrond")}
<p>
Deze aanvragen voor backups in de achtergrond staan momenteel in de wachtrij:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Machine </td>
    <td> Aanvraagtijd </td>
    <td> Gebruiker </td></tr>
\$strBg
</table>
<br><br>
\${h2("Overzicht Wachtrij: Opdrachten")}
<p>
Deze aanvragen via opdracht staan momenteel in de wachtrij:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Machine </td>
    <td> Aanvraagtijd </td>
    <td> Gebruiker </td>
    <td> Opdracht </td></tr>
\$strCmd
</table>
EOF

# --------------------------------
$Lang{Backup_PC__Log_File__file} = "BackupPC: Bestand \$file";
$Lang{Log_File__file__comment} = <<EOF;
\${h1("Bestand \$file \$comment")}
<p>
EOF
# --------------------------------
$Lang{Contents_of_log_file} = <<EOF;
Inhoud van bestand <tt>\$file</tt>, gewijzigd \$mtimeStr \$comment
EOF

# --------------------------------
$Lang{skipped__skipped_lines} = "[  \$skipped regels overgeslagen ]\n";
# --------------------------------
$Lang{_pre___Can_t_open_log_file__file} = "<pre>\nKan het logbestand \$file niet openen \n";

# --------------------------------
$Lang{BackupPC__Log_File_History} = "BackupPC: Geschiedenis Logbestand";
$Lang{Log_File_History__hdr} = <<EOF;
\${h1("Geschiedenis Logbestand \$hdr")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Bestand </td>
    <td align="center"> Grootte </td>
    <td align="center"> Laatste wijziging </td></tr>
\$str
</table>
EOF

# -------------------------------
$Lang{Recent_Email_Summary} = <<EOF;
\${h1("Overzicht recente e-mail (Omgekeerde volgorde)")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Bestemming </td>
    <td align="center"> Machine </td>
    <td align="center"> Tijd </td>
    <td align="center"> Onderwerp </td></tr>
\$str
</table>
EOF
 

# ------------------------------
$Lang{Browse_backup__num_for__host} = "BackupPC: Overzicht backup nummer \$num van pc \$host";

# ------------------------------
$Lang{Restore_Options_for__host} = "BackupPC: Opties voor het herstellen van bestanden van machine \$host";
$Lang{Restore_Options_for__host2} = <<EOF;
\${h1("Opties voor het herstellen van bestanden van machine \$host")}
<p>
U hebt de volgende bestanden/mappen geselecteerd uit
 \$share, backup nummer #\$num:
<ul>
\$fileListStr
</ul>
</p><p>
Er zijn drie mogelijkheden om deze bestanden/mappen terug te herstellen.
Gelieve een van de onderstaande mogelijkheden te kiezen.
</p>
\${h2("Optie 1: Rechtstreeks herstellen")}
<p>
EOF

$Lang{Restore_Options_for__host_Option1} = <<EOF;
U kan deze bestanden rechtstreeks herstellen naar pc
<b>\$directHost</b>.
</p><p>
<b>Waarschuwing:</b> bestaande bestanden met dezelfde naam zullen 
overschreven worden!
</p>
<form action="\$MyURL" method="post" name="direct">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="3">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<table class="tableStnd" border="0">
<tr>
    <td>Zet de bestanden terug naar de pc</td>
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
	 <!--<a href="javascript:myOpen('\$MyURL?action=findShares&host='+document.direct.hostDest.options.value)">Zoeken naar beschikbare gedeelde mappen (NIET ONDERSTEUND)</a>--></td>
</tr><tr>
    <td>Plaats de bestanden terug in de map (share)</td>
    <td><input type="text" size="40" value="\${EscHTML(\$share)}"
	 name="shareDest"></td>
</tr><tr>
    <td>Plaats de bestanden onder de map<br>(relatief tov share)</td>
    <td valign="top"><input type="text" size="40" maxlength="256"
	value="\${EscHTML(\$pathHdr)}" name="pathHdr"></td>
</tr><tr>
    <td><input type="submit" value="Herstellen starten" name="ignore"></td>
</table>
</form>
EOF

$Lang{Restore_Options_for__host_Option1_disabled} = <<EOF;
Rechtstreeks herstellen is gedeactiveerd voor machine \${EscHTML(\$hostDest)}.
Gelieve een van de andere opties voor het herstellen te kiezen.
EOF

# ------------------------------
$Lang{Option_2__Download_Zip_archive} = <<EOF;
<p>
\${h2("Optie 2: Download een Zip-bestand")}
<p>
U kan een Zip-bestand downloaden dat al de bestanden/mappen bevat die u hebt
geselecteerd. U kan dan een applicatie op uw pc, zoals WinZip,
gebruiken om de bestanden te bekijken of uit te pakken.
</p><p>
<b>Waarschuwing:</b> Afhankelijk van welke bestanden u geselecteerd hebt,
kan dit zip-bestand zeer zeer groot zijn. Het kan meerdere minuten duren
om dit bestand aan te maken en het te downloaden. Uw pc moet ook over voldoende
harde schijfruimte beschikken om het bestand te kunnen bevatten.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="2">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Maak het zip-archief relatief
aan \${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(in het andere geval zal het archiefbestand volledige padnamen bevatten).
<br>
<table class="tableStnd" border="0">
<tr>
    <td>Compressie (0=uit, 1=snel,...,9=hoogst)</td>
    <td><input type="text" size="6" value="5" name="compressLevel"></td>
</tr><tr>
    <td>Code page (e.g. cp866)</td>
    <td><input type="text" size="6" value="utf8" name="codePage"></td>
</tr>
</table>
<br>
<input type="submit" value="Download Zip-bestand" name="ignore">
</form>
EOF

# ------------------------------

$Lang{Option_2__Download_Zip_archive2} = <<EOF;
<p>
\${h2("Optie 2: Download Zip-bestand")}
<p>
Archive::Zip is niet ge&iuml;nstalleerd op de backupPC-server en het is
dus niet mogelijk om een Zip-bestand te downloaden.
Gelieve aan uw systeembeheerder te vragen om Archive::Zip te downloaden van
<a href="http://www.cpan.org">www.cpan.org</a> en te installeren.
</p>
EOF


# ------------------------------
$Lang{Option_3__Download_Zip_archive} = <<EOF;
\${h2("Optie 3: Download Tar-bestand")}
<p>
U kan een tar-bestand downloaden dat alle bestanden/mappen bevat die u
geselecteerd hebt. U kan dan een applicatie op uw pc, zoals tar of WinZip, 
gebruiken om de bestanden te bekijken of uit te pakken.
</p><p>
<b>Waarschuwing:</b> Afhankelijk van welke bestanden/mappen u geselecteerd hebt
kan dit bestand zeer, zeer groot worden. Het kan verscheidene minuten duren
om het tar-bestand de maken en te downloaden. Uw pc dient over voldoende vrije
schijfruimte te beschikken om het bestand op te slaan.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="1">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Maak het tar-archief relatief
aan \${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(anders zal het tar-archief volledige padnamen bevatten).
<br>
<input type="submit" value="Download Tar-bestand" name="ignore">
</form>
EOF


# ------------------------------
$Lang{Restore_Confirm_on__host} = "BackupPC: Bevestig herstellen voor machine \$host";

$Lang{Are_you_sure} = <<EOF;
\${h1("Weet u het zeker?")}
<p>
U hebt gevraagd om bestanden rechtstreeks terug te zetten op de machine \$In{hostDest}.
De volgende bestanden zullen hersteld worden in share \$In{shareDest}, 
uit backup nummer \$num:
<p>
<table class="tableStnd" border>
<tr class="tableheader"><td>Oorspronkelijk bestand/map</td><td>zal hersteld worden in</td></tr>
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
Is dit wat u wilt doen? Gelieve te bevestigen.
<input type="button" value="\$Lang->{Restore}"
 onClick="document.RestoreForm.action.value='Restore';
          document.RestoreForm.submit();">
<input type="submit" value="No" name="ignore">
</form>
EOF


# --------------------------
$Lang{Restore_Requested_on__hostDest} = "BackupPC: Herstellen aangevraagd van machine \$hostDest";
$Lang{Reply_from_server_was___reply} = <<EOF;
\${h1(\$str)}
<p>
Het antwoord van de server was: \$reply
<p>
Ga terug naar <a href="\$MyURL?host=\$hostDest">\$hostDest homepagina</a>.
EOF

$Lang{BackupPC_Archive_Reply_from_server} = <<EOF;
\${h1(\$str)}
<p>
Het antwoord van de server was: \$reply
EOF


# -------------------------
$Lang{Host__host_Backup_Summary} = "BackupPC: Overzicht backup van machine \$host";

$Lang{Host__host_Backup_Summary2} = <<EOF;
\${h1("Overzicht backups van machine \$host")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>
</p>
\${h2("Acties door de gebruiker")}
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
\${h2("Backup overzicht")}
<p>
Klik op het backupnummer om de inhoud te bekijken of om bestanden te herstellen.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> backup nr.</td>
    <td align="center"> Type </td>
    <td align="center"> Aangevuld </td>
    <td align="center"> Niveau </td>
    <td align="center"> Startdatum </td>
    <td align="center"> Duurtijd in min. </td>
    <td align="center"> Lftd. in dagen </td>
    <td align="center"> Plaats op de server </td>
</tr>
\$str
</table>
<p>

\$restoreStr
</p>
<br><br>
\${h2("Overzicht van fouten tijdens overdracht")}
<br><br>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> backup nr. </td>
    <td align="center"> Type </td>
    <td align="center"> Bekijken </td>
    <td align="center"> Aantal fouten </td>
    <td align="center"> Aantal foutieve bestanden </td>
    <td align="center"> Aantal foutieve \'shares\' </td>
    <td align="center"> Aantal tar-fouten </td>
</tr>
\$errStr
</table>
<br><br>

\${h2("Overzicht bestandsgrootte en hergebruik")}
<p>
Bestaande bestanden zijn bestanden die reeds aanwezig waren op de backupschijf.
Nieuwe bestanden zijn bestanden die aan de schijf zijn toegevoegd.
Lege bestanden en SMB-fouten worden niet geteld in de aantallen \'hergebruik\' en \'nieuw\'.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="2" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> Totalen </td>
    <td align="center" colspan="2"> Bestaande bestanden </td>
    <td align="center" colspan="2"> Nieuwe bestanden </td>
</tr>
<tr class="tableheader">
    <td align="center"> Backup nr. </td>
    <td align="center"> Type </td>
    <td align="center"> Aantal best.</td>
    <td align="center"> Grootte in MB </td>
    <td align="center"> MB/sec </td>
    <td align="center"> Aantal best.</td>
    <td align="center"> Grootte in MB </td>
    <td align="center"> Aantal best. </td>
    <td align="center"> Grootte in MB </td>
</tr>
\$sizeStr
</table>
<br><br>

\${h2("Overzicht compressie")}
<p>
Compressie van bestanden die reeds op schijf stonden en van nieuw
gecomprimeerde bestanden.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="3" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> Bestaande bestanden </td>
    <td align="center" colspan="3"> Nieuwe bestanden </td>
</tr>
<tr class="tableheader"><td align="center"> backup nr. </td>
    <td align="center"> Type </td>
    <td align="center"> Comp.niveau </td>
    <td align="center"> Grootte in MB </td>
    <td align="center"> Comp.in MB </td>
    <td align="center"> Comp. </td>
    <td align="center"> Grootte in MB </td>
    <td align="center"> Comp.in MB </td>
    <td align="center"> Comp. </td>
</tr>
\$compStr
</table>
<br><br>
EOF

$Lang{Host__host_Archive_Summary} = "BackupPC: Overzicht archivering machine \$host";
$Lang{Host__host_Archive_Summary2} = <<EOF;
\${h1("Overzicht archivering machine \$host")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>

\${h2("Acties van de gebruiker")}
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
$Lang{Error} = "BackupPC: Fout";
$Lang{Error____head} = <<EOF;
\${h1("Fout: \$head")}
<p>\$mesg</p>
EOF

# -------------------------
$Lang{NavSectionTitle_} = "Server";

# -------------------------
$Lang{Backup_browse_for__host} = <<EOF;
\${h1("Backup bekijken van \$host")}

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
<li> U bekijkt nu backup nummer \$num, die gestart werd rond \$backupTime
        (\$backupAge dagen geleden),
\$filledBackup
<li> Ga naar map: <input type="text" name="dir" size="50" maxlength="4096" value="\${EscHTML(\$dir)}"> <input type="submit" value="\$Lang->{Go}" name="Submit">
<li> Klik op een map hieronder om de inhoud van die map te bekijken,
<li> Klik op een bestand hieronder om dat bestand terug te zetten.
<li> U kan de <a href="\$MyURL?action=dirHistory&host=\${EscURI(\$host)}&share=\$shareURI&dir=\$pathURI">backupgeschiedenis</a> bekijken van de huidige map.
</ul>
</form>

\${h2("Inhoud van \$dirDisplay")}
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
$Lang{DirHistory_backup_for__host} = "BackupPC: Geschiedenis van een map van backup van \$host";

#
# These two strings are used to build the links for directories and
# file versions.  Files are appended with a version number.
#
$Lang{DirHistory_dirLink}  = "map";
$Lang{DirHistory_fileLink} = "v";

$Lang{DirHistory_for__host} = <<EOF;
\${h1("Historiek van een map van backup van \$host")}
<p>
Deze geschiedenis toont elke unieke versie van de bestanden over
alle backups heen:
<ul>
<li> Klik op een backupnummer om terug te keren naar het overzicht van de backup,
<li> Klik op een map-link (\$Lang->{DirHistory_dirLink}) om door
     die map te bladeren,
<li> Klik op de versie-link van een bestand (\$Lang->{DirHistory_fileLink}0,
     \$Lang->{DirHistory_fileLink}1, ...) om dat bestand te downloaden,
<li> Bestanden met dezelfde inhoud maar in verschillende backups hebben
     hetzelfde versienummer,
<li> Bestanden of mappen die in een bepaalde backup niet aanwezig zijn hebben
     een lege cel.
<li> Bestanden met hetzelfde versienummer kunnen wel verschillende attributen 
     (eigenaar,lees- of schrijfrechten) hebben.Selecteer het backupnummer om
     de attributen van het bestand te bekijken.
</ul>

\${h2("Geschiedenis van \$dirDisplay")}

<br>
<table border cellspacing="2" cellpadding="3">
<tr class="fviewheader"><td>backup nummer</td>\$backupNumStr</tr>
<tr class="fviewheader"><td>backup moment</td>\$backupTimeStr</tr>
\$fileStr
</table>
EOF
# ------------------------------
$Lang{Restore___num_details_for__host} = "BackupPC: Details van herstel nr. #\$num van machine \$host";

$Lang{Restore___num_details_for__host2} = <<EOF;
\${h1("Details van herstel nr. #\$num van machine \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="90%">
<tr><td class="tableheader"> Nummer </td><td class="border"> \$Restores[\$i]{num} </td></tr>
<tr><td class="tableheader"> Aangevraagd door </td><td class="border"> \$RestoreReq{user} </td></tr>
<tr><td class="tableheader"> Aanvraagtijd </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> Resultaat </td><td class="border"> \$Restores[\$i]{result} </td></tr>
<tr><td class="tableheader"> Foutmelding </td><td class="border"> \$Restores[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> Bronmachine </td><td class="border"> \$RestoreReq{hostSrc} </td></tr>
<tr><td class="tableheader"> Bron backupnr. </td><td class="border"> \$RestoreReq{num} </td></tr>
<tr><td class="tableheader"> Bron share </td><td class="border"> \$RestoreReq{shareSrc} </td></tr>
<tr><td class="tableheader"> Bestemmingsmachine </td><td class="border"> \$RestoreReq{hostDest} </td></tr>
<tr><td class="tableheader"> Bestemmingsshare </td><td class="border"> \$RestoreReq{shareDest} </td></tr>
<tr><td class="tableheader"> Starttijd </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Duur </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> Aantal bestanden </td><td class="border"> \$Restores[\$i]{nFiles} </td></tr>
<tr><td class="tableheader"> Totale grootte </td><td class="border"> \${MB} MB </td></tr>
<tr><td class="tableheader"> Overdrachtssnelheid </td><td class="border"> \$MBperSec MB/sec </td></tr>
<tr><td class="tableheader"> TarCreate fouten </td><td class="border"> \$Restores[\$i]{tarCreateErrs} </td></tr>
<tr><td class="tableheader"> Overdrachtsfouten </td><td class="border"> \$Restores[\$i]{xferErrs} </td></tr>
<tr><td class="tableheader"> Logbestand overdracht </td><td class="border">
<a href="\$MyURL?action=view&type=RestoreLOG&num=\$Restores[\$i]{num}&host=\$host">Bekijken</a>,
<a href="\$MyURL?action=view&type=RestoreErr&num=\$Restores[\$i]{num}&host=\$host">Fouten</a>
</tr></tr>
</table>
</p>
\${h1("Lijst bestanden/mappen")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="100%">
<tr class="tableheader"><td>Oorspronkelijk bestand/map</td><td>hersteld naar</td></tr>
\$fileListStr
</table>
EOF

# -----------------------------------
$Lang{Archive___num_details_for__host} = "BackupPC: Details van archivering nr. \$num van \$host";

$Lang{Archive___num_details_for__host2 } = <<EOF;
\${h1("Details van archivering nr. \$num van \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr><td class="tableheader"> Nummer </td><td class="border"> \$Archives[\$i]{num} </td></tr>
<tr><td class="tableheader"> Aangevraagd door </td><td class="border"> \$ArchiveReq{user} </td></tr>
<tr><td class="tableheader"> Aanvraagtijd </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> Resultaat </td><td class="border"> \$Archives[\$i]{result} </td></tr>
<tr><td class="tableheader"> Foutmelding </td><td class="border"> \$Archives[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> Starttijd </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Duur </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> Logbestand overdracht </td><td class="border">
<a href="\$MyURL?action=view&type=ArchiveLOG&num=\$Archives[\$i]{num}&host=\$host">Bekijken</a>,
<a href="\$MyURL?action=view&type=ArchiveErr&num=\$Archives[\$i]{num}&host=\$host">Fouten</a>
</tr></tr>
</table>
<p>
\${h1("Machinelijst")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td>Machine</td><td>backup nr.</td></tr>
\$HostListStr
</table>
EOF

# -----------------------------------
$Lang{Email_Summary} = "BackupPC: Overzicht E-mail";

# -----------------------------------
#  !! ERROR messages !!
# -----------------------------------
$Lang{BackupPC__Lib__new_failed__check_apache_error_log} = "BackupPC::Lib->new mislukt: controleer de apache error_log\n";
$Lang{Wrong_user__my_userid_is___} =  
              "Foutieve gebruiker: mijn userid is \$>, in plaats van \$uid"
            . "(\$Conf{BackupPCUser})\n";
# $Lang{Only_privileged_users_can_view_PC_summaries} = "Enkel gebruikers met bijzondere rechten kunnen PC-overzichten bekijken.";
$Lang{Only_privileged_users_can_stop_or_start_backups} = 
		  "Enkel gebruikers met bijzondere rechten kunnen backups stoppen of starten van machine"
		. " \${EscHTML(\$host)}.";
$Lang{Invalid_number__num} = "Ongeldig of onjuist nummer \${EscHTML(\$In{num})}";
$Lang{Unable_to_open__file__configuration_problem} = "Ik kan \$file niet openen: misschien problemen met de configuratie?";
$Lang{Only_privileged_users_can_view_log_or_config_files} = "Enkel gebruikers met bijzondere rechten kunnen log- of configuratiebestanden bekijken.";
$Lang{Only_privileged_users_can_view_log_files} = "Enkel gebruikers met bijzondere rechten kunnen logbestanden bekijken.";
$Lang{Only_privileged_users_can_view_email_summaries} = "Enkel gebruikers met bijzondere rechten kunnen het e-mailoverzicht bekijken.";
$Lang{Only_privileged_users_can_browse_backup_files} = "Enkel gebruikers met bijzondere rechten kunnen de backup "
                . "van machine \${EscHTML(\$In{host})} bekijken.";
$Lang{Empty_host_name} = "Geen of lege machinenaam.";
$Lang{Directory___EscHTML} = "Map \${EscHTML(\"\$TopDir/pc/\$host/\$num\")}"
		    . " is leeg";
$Lang{Can_t_browse_bad_directory_name2} = "Kan niet bladeren door foutieve mapnaam"
	            . " \${EscHTML(\$relDir)}";
$Lang{Only_privileged_users_can_restore_backup_files} = "Enkel gebruikers met bijzondere rechten kunnen backups"
                . " van machine \${EscHTML(\$In{host})} terugzetten.";
$Lang{Bad_host_name} = "Foutieve of ongeldige machinenaam \${EscHTML(\$host)}";
$Lang{You_haven_t_selected_any_files__please_go_Back_to} = "U hebt geen enkel bestand geselecteerd. Gelieve terug te gaan en"
                . " selecteer een of meerdere bestanden.";
$Lang{You_haven_t_selected_any_hosts} = "U hebt geen machine geselecteerd. Gelieve terug te gaan om"
                . " een machine te selecteren.";
$Lang{Nice_try__but_you_can_t_put} = "Leuk geprobeerd, maar u kan geen \'..\' in de bestandsnamen plaatsen";
$Lang{Host__doesn_t_exist} = "Machine \${EscHTML(\$In{hostDest})} bestaat niet.";
$Lang{You_don_t_have_permission_to_restore_onto_host} = "U beschikt niet over de juiste rechten om bestanden te herstellen naar machine "
		    . " \${EscHTML(\$In{hostDest})}";
$Lang{Can_t_open_create__openPath} = "Ik kan "
		. "\${EscHTML(\"\$openPath\")} niet openen of aanmaken";
$Lang{Only_privileged_users_can_restore_backup_files2} = "Alleen gebruikers met bijzondere rechten kunnen bestanden herstellen"
                . " naar machine \${EscHTML(\$host)}.";
$Lang{Empty_host_name} = "Lege machinenaam";
$Lang{Unknown_host_or_user} = "Onbekende machine of gebruiker \${EscHTML(\$host)}";
$Lang{Only_privileged_users_can_view_information_about} = "Enkel gebruikers met bijzondere rechten kunnen informatie over"
                . " machine \${EscHTML(\$host)} bekijken." ;
$Lang{Only_privileged_users_can_view_archive_information} = "Enkel gebruikers met bijzondere rechten kunnen archiveringsinformatie bekijken.";
$Lang{Only_privileged_users_can_view_restore_information} = "Enkel gebruikers met bijzondere rechten kunnen herstelinformatie bekijken.";
$Lang{Restore_number__num_for_host__does_not_exist} = "Herstel nr.\$num van machine \${EscHTML(\$host)}"
	        . " bestaat niet.";
$Lang{Archive_number__num_for_host__does_not_exist} = "Archiveringsnr. \$num van machine \${EscHTML(\$host)}"
                . " bestaat niet.";
$Lang{Can_t_find_IP_address_for} = "Ik kan het IP-adres van \${EscHTML(\$host)} niet vinden.";
$Lang{host_is_a_DHCP_host} = <<EOF;
\$host is een DHCP-machine en ik ken zijn IP-adres niet. Ik controleerde de
netbios-naam van \$ENV{REMOTE_ADDR}\$tryIP, en ontdekte dat die machine
niet dezelfde machine als \$host is.
<p>
In afwachting dat ik machine \$host op een bepaald DHCP-adres terugvind, kan u
deze aanvraag enkel doen vanaf die machine zelf.
EOF

# ------------------------------------
# !! Server Mesg !!
# ------------------------------------

$Lang{Backup_requested_on_DHCP__host} = "backup aangevraagd van DHCP \$host (\$In{hostIP}) door"
		                      . " \$User vanaf \$ENV{REMOTE_ADDR}";
$Lang{Backup_requested_on__host_by__User} = "backup aangevraagd van \$host door \$User";
$Lang{Backup_stopped_dequeued_on__host_by__User} = "backup geannuleerd van \$host door \$User";
$Lang{Restore_requested_to_host__hostDest__backup___num} = "Herstel aangevraagd voor machine \$hostDest, backup nr.\$num,"
	     . " door \$User vanaf \$ENV{REMOTE_ADDR}";
$Lang{Archive_requested} = "Archivering aangevraagd door \$User vanaf \$ENV{REMOTE_ADDR}";

# -------------------------------------------------
# ------- Stuff that was forgotten ----------------
# -------------------------------------------------

$Lang{Status} = "Status";
$Lang{PC_Summary} = "Overzicht machine";
$Lang{LOG_file} = "LOG-bestand";
$Lang{LOG_files} = "LOG-bestanden";
$Lang{Old_LOGs} = "Oude LOGs";
$Lang{Email_summary} = "E-mailoverzicht";
$Lang{Config_file} = "Configuratiebest.";
# $Lang{Hosts_file} = "Hosts-bestand";
$Lang{Current_queues} = "Huidige wachtrij";
$Lang{Documentation} = "Documentatie";

#$Lang{Host_or_User_name} = "<small>Machine of gebruikersnaam:</small>";
$Lang{Go} = "Start";
$Lang{Hosts} = "Machines";
$Lang{Select_a_host} = "Selecteer een machine...";

$Lang{There_have_been_no_archives} = "<h2> Er waren (nog) geen archiveringen </h2>\n";
$Lang{This_PC_has_never_been_backed_up} = "<h2> Deze PC werd (nog) nooit gebackupt !! </h2>\n";
$Lang{This_PC_is_used_by} = "<li>Deze PC wordt gebruikt door \${UserLink(\$user)}";

$Lang{Extracting_only_Errors} = "(Enkel de foutmeldingen)";
$Lang{XferLOG} = "OverdrachtsLOG";
$Lang{Errors}  = "Foutmeldingen";

# ------------
$Lang{Last_email_sent_to__was_at___subject} = <<EOF;
<li>Meest recente e-mail die gezonden werd naar \${UserLink(\$user)} was op \$mailTime, onderwerp: "\$subj".
EOF
# ------------
$Lang{The_command_cmd_is_currently_running_for_started} = <<EOF;
<li>De opdracht \$cmd loopt momenteel voor machine \$host sedert \$startTime.
EOF

# -----------
$Lang{Host_host_is_queued_on_the_background_queue_will_be_backed_up_soon} = <<EOF;
<li>Machine \$host staat klaar in de wachtrij \'achtergrond\' (backup zal weldra starten).
EOF

# ----------
$Lang{Host_host_is_queued_on_the_user_queue__will_be_backed_up_soon} = <<EOF;
<li>Machine \$host staat in de gebruikers-wachtrij (backup zal weldra starten).
EOF

# ---------
$Lang{A_command_for_host_is_on_the_command_queue_will_run_soon} = <<EOF;
<li>Een opdracht voor machine \$host staat in de opdrachtenwachtrij (opdracht zal weldra starten).
EOF

# --------
$Lang{Last_status_is_state_StatusHost_state_reason_as_of_startTime} = <<EOF;
<li>Meest recente status is \"\$Lang->{\$StatusHost{state}}\"\$reason sedert \$startTime.
EOF

# --------
$Lang{Last_error_is____EscHTML_StatusHost_error} = <<EOF;
<li>Meest recente foutmelding was \"\${EscHTML(\$StatusHost{error})}\".
EOF

# ------
$Lang{Pings_to_host_have_failed_StatusHost_deadCnt__consecutive_times} = <<EOF;
<li>Pings naar machine \$host zijn \$StatusHost{deadCnt} opeenvolgende keren mislukt.
EOF

# -----
$Lang{Prior_to_that__pings} = "Daarvoor, pings";

# -----
$Lang{priorStr_to_host_have_succeeded_StatusHostaliveCnt_consecutive_times} = <<EOF;
<li>\$priorStr naar machine \$host zijn \$StatusHost{aliveCnt} opeenvolgende keren geslaagd.

EOF

$Lang{Because__host_has_been_on_the_network_at_least__Conf_BlackoutGoodCnt_consecutive_times___} = <<EOF;
<li>Omdat machine \$host op het netwerk was gedurende minstens \$Conf{BlackoutGoodCnt}
opeenvolgende keren, zal hij niet gebackupt worden van \$blackoutStr
EOF

$Lang{__time0_to__time1_on__days} = "\$t0 tot \$t1 op \$days.";

$Lang{Backups_are_deferred_for_hours_hours_change_this_number} = <<EOF;
<li>backups zijn \$hours uren uitgesteld
(<a href=\"\$MyURL?action=Stop_Dequeue_Backup&host=\$host\">Wijzig dit aantal</a>).
EOF

$Lang{tryIP} = " en \$StatusHost{dhcpHostIP}";

# $Lang{Host_Inhost} = "Machine \$In{host}";

$Lang{checkAll} = <<EOF;
<tr><td class="fviewborder">
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;Selecteer alles
</td><td colspan="5" align="center" class="fviewborder">
<input type="submit" name="Submit" value="Plaats geselecteerde bestanden terug">
</td></tr>
EOF

$Lang{checkAllHosts} = <<EOF;
<tr><td class="fviewborder">
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;Selecteer alles
</td><td colspan="2" align="center" class="fviewborder">
<input type="submit" name="Submit" value="Archiveer de geselecteerde hosts">
</td></tr>
EOF

$Lang{fileHeader} = <<EOF;
   <tr class="fviewheader"><td align=center> Naam</td>
       <td align="center"> Type</td>
       <td align="center"> Mode</td>
       <td align="center"> Nr.</td>
       <td align="center"> Grootte</td>
       <td align="center"> Wijziging</td>
    </tr>
EOF

$Lang{Home} = "Home";
$Lang{Browse} = "Bekijken backups";
$Lang{Last_bad_XferLOG} = "Laaste overdr.LOG met fouten";
$Lang{Last_bad_XferLOG_errors_only} = "Laaste overdr.LOG (enkel foutmeldingen)";

$Lang{This_display_is_merged_with_backup} = <<EOF;
<li> Dit overzicht is samengevoegd met backup #\$numF.
EOF

$Lang{Visit_this_directory_in_backup} = <<EOF;
<li> Selecteer de backup die u wil bekijken: <select onChange="window.location=this.value">\$otherDirs </select>
EOF

$Lang{Restore_Summary} = <<EOF;
\${h2("Overzicht herstellingen")}
<p>
Klik op het nummer voor meer details.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Herstel nr.</td>
    <td align="center"> Resultaat </td>
    <td align="right"> Startdatum</td>
    <td align="right"> Duur(min.)</td>
    <td align="right"> Aantal best. </td>
    <td align="right"> MB </td>
    <td align="right"> Aantal tar-fouten</td>
    <td align="right"> Aantal Overdr.fouten</td>
</tr>
\$restoreStr
</table>
<p>
EOF

$Lang{Archive_Summary} = <<EOF;
\${h2("Overzicht archiveringen")}
<p>
Klik op het archiveringsnummer voor meer details.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Archiveringsnr.</td>
    <td align="center"> Resultaat </td>
    <td align="right"> Startdatum</td>
    <td align="right"> Duur/min</td>
</tr>
\$ArchiveStr
</table>
<p>
EOF

$Lang{BackupPC__Documentation} = "BackupPC: Documentatie";

$Lang{No} = "nee";
$Lang{Yes} = "ja";

$Lang{The_directory_is_empty} = <<EOF;
<tr><td bgcolor="#ffffff">De map/directory \$dirDisplay is leeg
</td></tr>
EOF

#$Lang{on} = "aan";
$Lang{off} = "uit";

$Lang{backupType_full}    = "volledig";
$Lang{backupType_incr}    = "incrementeel";
$Lang{backupType_active}  = "active";
$Lang{backupType_partial} = "gedeeltelijk";

$Lang{failed} = "mislukt";
$Lang{success} = "succesvol";
$Lang{and} = "en";

# ------
# Hosts states and reasons
$Lang{Status_idle} = "inactief";
$Lang{Status_backup_starting} = "backup start";
$Lang{Status_backup_in_progress} = "backup bezig";
$Lang{Status_restore_starting} = "herstel start";
$Lang{Status_restore_in_progress} = "herstel bezig";
$Lang{Status_admin_pending} = "wacht op linken";
$Lang{Status_admin_running} = "linken is bezig";

$Lang{Reason_backup_done} = "backup voltooid";
$Lang{Reason_restore_done} = "herstel voltooid";
$Lang{Reason_archive_done}   = "archivering voltooid";
$Lang{Reason_nothing_to_do} = "niets te doen";
$Lang{Reason_backup_failed} = "backup mislukt";
$Lang{Reason_restore_failed} = "herstel mislukt";
$Lang{Reason_archive_failed} = "archivering mislukt";
$Lang{Reason_no_ping} = "geen ping";
$Lang{Reason_backup_canceled_by_user} = "backup geannuleerd door gebruiker";
$Lang{Reason_restore_canceled_by_user} = "herstellen geannuleerd door gebruiker";
$Lang{Reason_archive_canceled_by_user} = "archivering geannuleerd door gebruiker";
$Lang{Disabled_OnlyManualBackups}  = "auto uitgeschakeld";  
$Lang{Disabled_AllBackupsDisabled} = "uitgeschakeld";                  

# ---------
# Email messages

# No backup ever
$Lang{EMailNoBackupEverSubj} = "BackupPC: Er werd (nog) geen backup gemaakt van pc \$host";
$Lang{EMailNoBackupEverMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
Beste $userName,

Uw pc ($host) is tot op heden nog nooit succesvol gebackupt door
onze PC backup software. PC backups zouden automatisch moeten gebeuren
als uw pc verbonden is met het netwerk. 
U kan best contact opnemen met de systeembeheerder als:

  - Uw pc regelmatig en normaal verbonden was met het netwerk.
    Mogelijk is er immers een configuratie of setupfout waardoor
    backups niet mogelijk waren/zijn.
  
  - U helemaal geen backup wenst van deze pc en u wil dat er
    hierover geen e-mail meer gezonden worden

In andere gevallen dient u er voor te zorgen dat uw pc zo spoedig 
mogelijk verbonden wordt met het netwerk.
In geval van twijfel of voor hulp kan u contact opnemen met de
systeembeheerder.

Met vriendelijke groeten,
BackupPC Genie
http://backuppc.sourceforge.net
EOF

# No recent backup
$Lang{EMailNoBackupRecentSubj} = "BackupPC: er zijn recentelijk geen backups (meer) gemaakt van pc \$host";
$Lang{EMailNoBackupRecentMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
Beste $userName,

Er is reeds gedurende $days dagen geen backup meer gemaakt van uw pc ($host).
Er zijn ondertussen van uw pc $numBackups backups gemaakt sinds $firstTime dagen geleden.
De laatste backup dateert van $days dagen geleden.
PC backups zouden automatisch moeten gebeuren als uw pc verbonden
is met het netwerk. 

Als uw pc gedurende geruime tijd (meer dan een paar uur) verbonden
was met het netwerk gedurende de laatste $days dagen, kan u het beste
contact opnemen van uw systeembeheerder. Vraag hem of haar om uit te
zoeken waarom er geen backups meer gemaakt worden van uw pc.

Anderzijds, als deze pc of notebook zich momenteel niet in het netwerk
bevindt dan kan u hieraan weinig anders doen behalve van belangrijke bestanden
handmatig een kopie te maken op een ander medium (CD, diskette, tape, andere pc,...)
U dient te weten dat *geen enkel bestand* dat u aanmaakte of wijzigde in de
laatste $days dagen hersteld zal kunnen worden in geval de harde schijf
van uw pc zou crashen. Hierin zijn nieuwe e-mail en bijlagen inbegrepen.


Met vriendelijke groeten,
BackupPC Genie
http://backuppc.sourceforge.net
EOF

# Old Outlook files
$Lang{EMailOutlookBackupSubj} = "BackupPC: Outlookbestanden op pc \$host moeten gebackupt worden";
$Lang{EMailOutlookBackupMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
Beste $userName,

De Outlookbestanden van uw pc zijn $howlong.

Deze bestanden bevatten al uw e-mail, bijlagen, contactadressen en agenda.

Uw pc werd reeds $numBackups keer succesvol gebackupt sinds $firstTime
tot $lastTime dagen geleden.
Helaas, wanneer Outlook geopend is, worden al de bijhorende bestanden
ontoegankelijk gemaakt voor andere programma's, inclusief het programma backupPC.
Hierdoor kon van deze bestanden geen backup gemaakt worden.

Als u nu verbonden bent met het netwerk, wordt U aangeraden om een 
backup te maken van de Outlookbestanden. Dat kan op volgende manier:
- Sluit Outlook 
- Sluit bij voorkeur ook alle andere toepassingen
- open uw browser en ga naar deze link:

    $CgiURL?host=$host               

- Kies dan voor "Start incrementele backup" tweemaal om zo een incrementele backup te starten.

U kan klikken op de link "Terug naar $host pagina" en vervolgens op "vernieuwen"
om de status van de backup te bekijken. Het zou slechts enkele ogenblikken mogen
vragen vooraleer de backup volledig is.

Met vriendelijke groeten,
BackupPC Genie
http://backuppc.sourceforge.net
EOF

$Lang{howLong_not_been_backed_up} = "(nog) niet succesvol gebackupt";
$Lang{howLong_not_been_backed_up_for_days_days} = "reeds sedert \$days dagen niet gebackupt";

#######################################################################
# RSS strings
#######################################################################
$Lang{RSS_Doc_Title}       = "BackupPC Server";
$Lang{RSS_Doc_Description} = "RSS feed for BackupPC";
$Lang{RSS_Host_Summary}    = <<EOF;
Aantal Voll.: \$fullCnt;
Voll.Lftd/dagen: \$fullAge;
Voll.Grootte/GiB: \$fullSize;
Snelheid MB/sec: \$fullRate;
Aantal Incr.: \$incrCnt;
Incr.Lftd/dagen: \$incrAge;
Status: \$host_state;
Laatste poging: \$host_last_attempt;
EOF

#######################################################################
# Configuration editor strings 
#######################################################################

$Lang{Only_privileged_users_can_edit_config_files} = "Enkel gebruikers met bijzondere rechten kunnen de configuratie wijzigen.";
$Lang{CfgEdit_Edit_Config} = "Wijzig Configuratie";
$Lang{CfgEdit_Edit_Hosts}  = "Wijzig Machines";

$Lang{CfgEdit_Title_Server} = "Server";
$Lang{CfgEdit_Title_General_Parameters} = "Algemene Parameters";
$Lang{CfgEdit_Title_Wakeup_Schedule} = "Wakeup planning";
$Lang{CfgEdit_Title_Concurrent_Jobs} = "Parallelle Jobs";
$Lang{CfgEdit_Title_Pool_Filesystem_Limits} = "Pool Bestandssysteem Limieten";
$Lang{CfgEdit_Title_Other_Parameters} = "Andere Parameters";
$Lang{CfgEdit_Title_Remote_Apache_Settings} = "Remote Apache Instellingen";
$Lang{CfgEdit_Title_Program_Paths} = "Programmapaden";
$Lang{CfgEdit_Title_Install_Paths} = "Installatiepaden";
$Lang{CfgEdit_Title_Email} = "Email";
$Lang{CfgEdit_Title_Email_settings} = "Email instellingen";
$Lang{CfgEdit_Title_Email_User_Messages} = "Emailberichten Gebruikers";
$Lang{CfgEdit_Title_CGI} = "CGI";
$Lang{CfgEdit_Title_Admin_Privileges} = "Admin rechten";
$Lang{CfgEdit_Title_Page_Rendering} = "Pagina opbouw";
$Lang{CfgEdit_Title_Paths} = "Paden";
$Lang{CfgEdit_Title_User_URLs} = "Gebruiker URLs";
$Lang{CfgEdit_Title_User_Config_Editing} = "Wijzigen gebruikersconfiguratie";
$Lang{CfgEdit_Title_Xfer} = "Overdracht";
$Lang{CfgEdit_Title_Xfer_Settings} = "Overdracht instellingen";
$Lang{CfgEdit_Title_Ftp_Settings} = "FTP instellingen";
$Lang{CfgEdit_Title_Smb_Settings} = "Smb instellingen";
$Lang{CfgEdit_Title_Tar_Settings} = "Tar instellingen";
$Lang{CfgEdit_Title_Rsync_Settings} = "Rsync instellingen";
$Lang{CfgEdit_Title_Rsyncd_Settings} = "Rsyncd instellingen";
$Lang{CfgEdit_Title_Archive_Settings} = "Archivering instellingen";
$Lang{CfgEdit_Title_Include_Exclude} = "Inclusief/Exclusief";
$Lang{CfgEdit_Title_Smb_Paths_Commands} = "Smb Pad/Opdrachten";
$Lang{CfgEdit_Title_Tar_Paths_Commands} = "Tar Pad/Opdrachten";
$Lang{CfgEdit_Title_Rsync_Paths_Commands_Args} = "Rsync Pad/Opdrachten/Parameters";
$Lang{CfgEdit_Title_Rsyncd_Port_Args} = "Rsyncd Poort/Parameters";
$Lang{CfgEdit_Title_Archive_Paths_Commands} = "Archivering Pad/Opdrachten";
$Lang{CfgEdit_Title_Schedule} = "Planning";
$Lang{CfgEdit_Title_Full_Backups} = "Volledige Backups";
$Lang{CfgEdit_Title_Incremental_Backups} = "Incrementele Backups";
$Lang{CfgEdit_Title_Blackouts} = "Blackouts";
$Lang{CfgEdit_Title_Other} = "Andere";
$Lang{CfgEdit_Title_Backup_Settings} = "Backup instellingen";
$Lang{CfgEdit_Title_Client_Lookup} = "Cli&euml;nt locatie";
$Lang{CfgEdit_Title_User_Commands} = "Opdrachten van gebruiker";
$Lang{CfgEdit_Title_Hosts} = "Machines";

$Lang{CfgEdit_Hosts_Comment} = <<eof;
Om een nieuwe machine toe te voegen: selecteer 'Toevoegen' en geef de naam op.
Om met de machine-specifieke configuratie van een andere machine als basis te gebruiken: 
Geef de naam van de machine als NIEUWE_MACHINE=TE_KOPIEREN_MACHINE.
Dit zal de een reeds bestaande machine-specifieke configuratie voor 
NIEUWE_MACHINE overschrijven. Je kan dit ook doen voor een reeds bestaande machine.
Om een machine te verwijderen: klik op de de Verwijderen-knop.
Bij 'Toevoegen', 'Verwijderen' en 'Kopi&euml;ren' van instellingen, worden de 
wijzigingen pas effectief nadat je op 'Bewaren' hebt geklikt.
Backups van gewiste machines worden niet verwijderd.
Als je dus per vergissing een machine hebt verwijderd, kan je deze 
eenvoudig opnieuw toevoegen. Om de backups van een machine volledig
te verwijderen, moet je de bestanden verwijderen in de map
\$topdir/pc/MACHINE
eof

$Lang{CfgEdit_Header_Main} = <<EOF;
\${h1("Bewerken globale instellingen")}
EOF

$Lang{CfgEdit_Header_Host} = <<EOF;
\${h1("Bewerken specifieke configuratie van machine \$host ")}
<p>
NB: Selecteer 'Overschrijven' als je een waarde wil wijzigen specifiek voor deze machine.
<p>
EOF

$Lang{CfgEdit_Button_Save}     = "Bewaren";
$Lang{CfgEdit_Button_Insert}   = "Invoegen";
$Lang{CfgEdit_Button_Delete}   = "Verwijderen";
$Lang{CfgEdit_Button_Add}      = "Toevoegen";
$Lang{CfgEdit_Button_Override} = "Overschrijven";
$Lang{CfgEdit_Button_New_Key}  = "Nieuwe sleutel";

$Lang{CfgEdit_Error_No_Save}
            = "Fout: niet bewaard ten gevolge van fouten";
$Lang{CfgEdit_Error__must_be_an_integer}
            = "Fout: \$var moet een geheel getal zijn";
$Lang{CfgEdit_Error__must_be_real_valued_number}
            = "Fout: \$var moet een re&euml;le waarde (nummer) zijn";
$Lang{CfgEdit_Error__entry__must_be_an_integer}
            = "Fout: \$var ingave \$k moet een geheel getal zijn";
$Lang{CfgEdit_Error__entry__must_be_real_valued_number}
            = "Fout: \$var ingave \$k moet een re&euml;le waarde (nummer) zijn";
$Lang{CfgEdit_Error__must_be_executable_program}
            = "Fout: \$var moet een geldig uitvoerbaar pad zijn";
$Lang{CfgEdit_Error__must_be_valid_option}
            = "Fout: \$var is geen geldige optie";
$Lang{CfgEdit_Error_Copy_host_does_not_exist}
	    = "Te kopi&euml;ren machine \$copyHost bestaat niet; Machine \$fullHost wordt aangemaakt. Verwijder deze machine indien dit niet is wat je wil.";
            
$Lang{CfgEdit_Log_Copy_host_config}
	    = "\$User kopieerde de instellingen van machine \$fromHost naar \$host\n";
$Lang{CfgEdit_Log_Delete_param}
            = "\$User verwijderde \$p van \$conf\n";
$Lang{CfgEdit_Log_Add_param_value}
            = "\$User voegde \$p toe aan \$conf, met waarde \$value\n";
$Lang{CfgEdit_Log_Change_param_value}
            = "\$User wijzigde \$p in \$conf van \$valueOld naar \$valueNew \n";
$Lang{CfgEdit_Log_Host_Delete}
            = "\$User verwijderde machine \$host\n";
$Lang{CfgEdit_Log_Host_Change}
            = "\$User machine \$host wijzigde \$key van \$valueOld naar \$valueNew\n";
$Lang{CfgEdit_Log_Host_Add}
            = "\$User voegde machine \$host toe: \$value\n";
  
#end of lang_nl.pm

