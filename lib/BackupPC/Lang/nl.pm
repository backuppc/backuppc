#!/bin/perl

#my %lang;
#use strict;
#File:  nl.pm       version 1.0.2
# --------------------------------

$Lang{Start_Archive} = "Start Archivering";
$Lang{Stop_Dequeue_Archive} = "Stop/Annuleer Archivering";
$Lang{Start_Full_Backup} = "Start volledige backup";
$Lang{Start_Incr_Backup} = "Start stapsgewijze backup";
$Lang{Stop_Dequeue_Backup} = "Stop/Annuleer backup";
$Lang{Restore} = "Terugplaatsen";

$Lang{Type_full} = "volledig";
$Lang{Type_incr} = "incrementeel";

# -----

$Lang{Only_privileged_users_can_view_admin_options} = "Alleen gebruikers met bijzondere rechten kunnen admin.-opties bekijken.";
$Lang{H_Admin_Options} = "BackupPC Server: Admin Opties";
$Lang{Admin_Options} = "Admin Opties";
$Lang{Admin_Options_Page} = <<EOF;
\${h1(qq{$Lang{Admin_Options}})}
<br>
\${h2("Controle van de server")}
<form action="\$MyURL" method="get">
<table>
  <!--<tr><td>Stop de server:<td><input type="submit" name="action" value="Stop">-->
  <tr><td>Herlaad de configuratie van de server:<td><input type="submit" name="action" value="Herlaad">
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
$Lang{Unable_to_connect_to_BackupPC_server} = "Verbinding met de BackupPC server niet mogelijk",
            "Dit CGI script (\$MyURL) kan geen verbinding maken met de BackupPC-server"
          . " op \$Conf{ServerHost} poort \$Conf{ServerPort}."
          . " De foutmelding was: \$err.",
            "Mogelijk draait de BackupPC server niet of is er een "
          . " configuratiefout.  Gelieve dit te melden aan uw systeembeheerder.";
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
        <li>\$numBgQueue wachtende backupaanvragen sedert laatste geplande wakeup,
        <li>\$numUserQueue wachtende backupaanvragen van gebruikers,
        <li>\$numCmdQueue wachtende aanvragen op commando,
        \$poolInfo
        <li>De backupschijf werd het laatst aangevuld tot \$Info{DUlastValue}%
            op (\$DUlastTime), het maximum van vandaag is \$Info{DUDailyMax}% (\$DUmaxTime)
            en het maximum van gisteren was \$Info{DUDailyMaxPrev}%.
    </ul>
</ul>
eof

$Lang{BackupPC_Server_Status} = <<EOF;
\${h1(qq{$Lang{H_BackupPC_Server_Status}})}

<p>
\$generalInfo

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
    </tr>
\$jobStr
</table>
<p>

\${h2("Mislukkingen die aandacht vragen")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> Machine </td>
    <td align="center"> Type </td>
    <td align="center"> Gebruiker </td>
    <td align="center"> Laatste poging </td>
    <td align="center"> Details </td>
    <td align="center"> Fouttijd </td>
    <td> Laaste fout (verschillend van 'geen ping') </td></tr>
\$statusStr
</table>
EOF

# --------------------------------
$Lang{BackupPC__Server_Summary} = "BackupPC: Server overzicht";
$Lang{BackupPC__Archive} = "BackupPC: Archivering";
$Lang{BackupPC_Summary}=<<EOF;

\${h1(qq{$Lang{BackupPC__Server_Summary}})}
<p>
Dit overzicht dateert van \$now.
</p>

\${h2("Machine(s) met geslaagde backups")}
<p>
Er zijn \$hostCntGood hosts gebackupt, wat een totaal geeft van:
<ul>
<li> \$fullTot volledige backups met een totale grootte van \${fullSizeTot}GB
     (vóór definitief wegschrijven en compressie),
<li> \$incrTot oplopende backups met een totale grootte van \${incrSizeTot}GB
     (vóór definitief wegschrijven en compressie).
</ul>
</p>
<table class="tableStnd" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> Machine </td>
    <td align="center"> Gebruiker </td>
    <td align="center"> Aantal Voll. </td>
    <td align="center"> Voll.Lftd/dagen </td>
    <td align="center"> Voll.Grootte/GB </td>
    <td align="center"> Snelheid MB/sec </td>
    <td align="center"> Aantal Incr. </td>
    <td align="center"> Incr.Lftd/dagen </td>
    <td align="center"> Status </td>
    <td align="center"> Laatste poging</td></tr>
\$strGood
</table>
<br><br>
\${h2("Hosts zonder backups")}
<p>
Er zijn \$hostCntNone hosts zonder backup.
<p>
<table class="tableStnd" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> Machine </td>
    <td align="center"> Gebruiker </td>
    <td align="center"> tal Voll. </td>
    <td align="center"> Voll.Lftd/dagen </td>
    <td align="center"> Voll.Grootte/GB </td>
    <td align="center"> Snelheid MB/sec </td>
    <td align="center"> tal Incr. </td>
    <td align="center"> Incr.Lftd/dagen </td>
    <td align="center"> Status </td>
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

Er zijn \$hostCntGood machines gebackupt die een totale grootte vertegenwoordigen van \${fullSizeTot}GB
<p>
<form name="form1" method="post" action="\$MyURL">
<input type="hidden" name="fcbMax" value="\$checkBoxCnt">
<input type="hidden" name="type" value="1">
<input type="hidden" name="host" value="\${EscHTML(\$archHost)}">
<input type="hidden" name="action" value="Archive">
<table class="tableStnd" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td align=center> Machine</td>
    <td align="center"> Gebruiker </td>
    <td align="center"> grootte backup </td>
\$strGood
\$checkAllHosts
</table>
</form>
<p>

EOF

$Lang{BackupPC_Archive2} = <<EOF;
\${h1(qq{$Lang{BackupPC__Archive}})}
Klaar om volgende machines te archiveren
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
    <td colspan=2><input type="submit" value="Start de archivering" name=""></td>
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
        <li>Gebruikte backupschijfruimte is \${poolSize}GB groot en bevat \$info->{"\${name}FileCnt"} bestanden
            en \$info->{"\${name}DirCnt"} mappen (op \$poolTime),
        <li>Schijfruimte bevat \$info->{"\${name}FileCntRep"} identieke 
            bestanden (langste reeks is \$info->{"\${name}FileRepMax"},
        <li>Nachtelijke opruiming verwijderde \$info->{"\${name}FileCntRm"} bestanden
            met een grootte van \${poolRmSize}GB (ongeveer \$poolTime),
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

<form action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="hostIP" value="\$ipAddr">
<input type="hidden" name="doit" value="1">
Wilt u dat nu doen?
<input type="submit" value="\$In{action}" name="action">
<input type="submit" value="Neen" name="">
</form>
EOF
# --------------------------------
$Lang{BackupPC__Stop_Backup_Confirm_on__host} = "BackupPC: Bevestiging de annulering van de backup van \$host";
# --------------------------------
$Lang{Are_you_sure_stop} = <<EOF;

\${h1("Bent u zeker?")}

<p>
Met deze actie annuleert u de backup van pc \$host of haalt u de opdracht uit de wachtrij;

<form action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="doit" value="1">
Start bovendien geen andere backup gedurende
<input type="text" name="backoff" size="10" value="\$backoff"> uur/uren.
<p>
Wilt u dit nu bevestigen?
<input type="submit" value="\$In{action}" name="action">
<input type="submit" value="Neen" name="">
</form>

EOF
# --------------------------------
$Lang{Only_privileged_users_can_view_queues_} = "Enkel bevoorrechte gebruikers kunnen de wachtrij bekijken.";
# --------------------------------
$Lang{Only_privileged_users_can_archive} = "Enkel bevoorechte gebruikers kunnen archiveren.";
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
$Lang{Backup_PC__Log_File__file} = "BackupPC: Logbestand \$file";
$Lang{Log_File__file__comment} = <<EOF;
\${h1("Logbestand \$file \$comment")}
<p>
EOF
# --------------------------------
$Lang{Contents_of_log_file} = <<EOF;
Inhoud van logbestand <tt>\$file</tt>, gewijzigd \$mtimeStr \$comment
EOF

# --------------------------------
$Lang{skipped__skipped_lines} = "[  \$skipped lijnen overgeslagen ]\n";
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
$Lang{Restore_Options_for__host} = "BackupPC: Opties voor het terugplaatsen van bestanden van machine \$host";
$Lang{Restore_Options_for__host2} = <<EOF;
\${h1("Opties voor het terugplaatsen van bestanden van machine \$host")}
<p>
U hebt de volgende bestanden/mappen geselecteerd uit
 \$share, backup nummer #\$num:
<ul>
\$fileListStr
</ul>
</p><p>
Er zijn drie mogelijkheden om deze bestanden/mappen terug te plaatsen.
Gelieve een van de onderstaande mogelijkheden te kiezen.
</p>
\${h2("Optie 1: Rechtstreeks terugplaatsen")}
<p>
EOF

$Lang{Restore_Options_for__host_Option1} = <<EOF;
U kan deze bestanden rechtstreeks terugplaatsen op pc
\$host.
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
<table border="0">
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
    <td><input type="submit" value="Terugplaatsen starten" name=""></td>
</table>
</form>
EOF

$Lang{Restore_Options_for__host_Option1_disabled} = <<EOF;
Rechtstreeks terugplaatsen is gedeactiveerd voor machine \${EscHTML(\$hostDest)}.
Gelieve een van de andere herstelopties te kiezen.
eof

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
Compressie (0=uit, 1=snel,...,9=hoogst)
<input type="text" size="6" value="5" name="compressLevel">
<br>
<input type="submit" value="Download Zip-bestand" name="">
</form>
EOF

# ------------------------------

$Lang{Option_2__Download_Zip_archive2} = <<EOF;
<p>
\${h2("Optie 2: Download Zip-bestand")}
<p>
Archive::Zip is niet geïnstalleerd op de backupPC-server en het is
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
<input type="submit" value="Download Tar-bestand" name="">
</form>
EOF


# ------------------------------
$Lang{Restore_Confirm_on__host} = "BackupPC: Bevestig terugplaatsen voor machine \$host";

$Lang{Are_you_sure} = <<EOF;
\${h1("Bent u zeker?")}
<p>
U hebt gevraagd om bestanden rechtstreeks terug te zetten op de machine \$In{hostDest}.
De volgende bestanden zullen teruggeplaatst worden in share \$In{shareDest}, 
uit backup nummer \$num:
<p>
<table border>
<tr><td>Oorspronkelijk bestand/map</td><td>zal teruggeplaatst worden in</td></tr>
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
Is dit wat u wilt doen? Gelieve te bevestigen.
<input type="submit" value="\$In{action}" name="action">
<input type="submit" value="Neen" name="">
</form>
EOF


# --------------------------
$Lang{Restore_Requested_on__hostDest} = "BackupPC: Terugplaatsen gevraagd van machine \$hostDest";
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
\${h1("Overzicht backup van machine \$host")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>
</p>
\${h2("Acties door de gebruiker")}
<p>
<form action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
\$startIncrStr
<input type="submit" value="$Lang{Start_Full_Backup}" name="action">
<input type="submit" value="$Lang{Stop_Dequeue_Backup}" name="action">
</form>
</p>
\${h2("Overzicht backup")}
<p>
Klik op het backupnummer om de inhoud te bekijken of om bestanden terug te plaatsen.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> backup nr.</td>
    <td align="center"> Type </td>
    <td align="center"> Aangevuld </td>
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
    <td align="center"> backup nr. </td>
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
<form action="\$MyURL" method="get">
<input type="hidden" name="archivehost" value="\$host">
<input type="hidden" name="host" value="\$host">
<input type="submit" value="$Lang{Start_Archive}" name="action">
<input type="submit" value="$Lang{Stop_Dequeue_Archive}" name="action">
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

\${h2("Inhoud van \${EscHTML(\$dirDisplay)}")}
<form name="form1" method="post" action="\$MyURL">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="share" value="\${EscHTML(\$share)}">
<input type="hidden" name="fcbMax" value="\$checkBoxCnt">
<input type="hidden" name="action" value="$Lang{Restore}">
<br>
<table width="100%">
<tr><td valign="top">
    <br><table align="center" border="0" cellpadding="0" cellspacing="0" bgcolor="#ffffff">
    \$dirStr
    </table>
</td><td width="3%">
</td><td valign="top">
    <br>
        <table border="0" width="100%" align="left" cellpadding="3" cellspacing="1">
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

\${h2("Geschiedenis van \${EscHTML(\$dirDisplay)}")}

<br>
<table cellspacing="2" cellpadding="3">
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
<tr><td class="tableheader"> Overdrachtsratio </td><td class="border"> \$MBperSec MB/sec </td></tr>
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
<tr class="tableheader"><td>Oorspronkelijk bestand/map</td><td>Teruggeplaatst naar</td></tr>
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
\${h1("Lijst machines")}
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
$Lang{Invalid_number__num} = "Ongeldig of onjuist nummer \$num";
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
$Lang{Only_privileged_users_can_restore_backup_files} = "Enkel gebruikers met bijzondere rechten kunnen backupbestanden"
                . " van machine \${EscHTML(\$In{host})} terugplaatsen.";
$Lang{Bad_host_name} = "Foutieve of ongeldige machinenaam \${EscHTML(\$host)}";
$Lang{You_haven_t_selected_any_files__please_go_Back_to} = "U hebt geen enkel bestand geselecteerd. Gelieve terug te gaan en"
                . " selecteer een of meerdere bestanden.";
$Lang{You_haven_t_selected_any_hosts} = "U hebt geen machine geselecteerd. Gelieve terug te gaan om"
                . " een machine te selecteren.";
$Lang{Nice_try__but_you_can_t_put} = "Goed geprobeerd, maar u kan geen \'..\' in de bestandsnamen plaatsen";
$Lang{Host__doesn_t_exist} = "Machine \${EscHTML(\$In{hostDest})} bestaat niet.";
$Lang{You_don_t_have_permission_to_restore_onto_host} = "U beschikt niet over de juiste rechten om bestanden terug te plaatsen naar machine "
		    . " \${EscHTML(\$In{hostDest})}";
$Lang{Can_t_open_create} = "Ik kan "
                    . "\${EscHTML(\"\$TopDir/pc/\$hostDest/\$reqFileName\")} niet openen of aanmaken";
$Lang{Only_privileged_users_can_restore_backup_files2} = "Alleen gebruikers met bijzondere rechten kunnen bestanden terugplaatsen"
                . " naar machine \${EscHTML(\$host)}.";
$Lang{Empty_host_name} = "Lege machinenaam";
$Lang{Unknown_host_or_user} = "Onbekende machine of gebruiker \${EscHTML(\$host)}";
$Lang{Only_privileged_users_can_view_information_about} = "Enkel gebruikers met bijzondere rechten kunnen informatie over"
                . " machine \${EscHTML(\$host)} bekijken." ;
$Lang{Only_privileged_users_can_view_archive_information} = "Enkel gebruikers met bijzondere rechten kunnen archiveringsinformatie bekijken.";
$Lang{Only_privileged_users_can_view_restore_information} = "Enkel gebruikers met bijzondere rechten kunnen herstelinformatie bekijken.";
$Lang{Restore_number__num_for_host__does_not_exist} = "Terugplaatsing nr.\$num van machine \${EscHTML(\$host)}"
	        . " bestaat niet.";
$Lang{Archive_number__num_for_host__does_not_exist} = "Archiveringsnr. \$num van machine \${EscHTML(\$host)}"
                . " bestaat niet.";
$Lang{Can_t_find_IP_address_for} = "Ik kan het IP-nummer van \${EscHTML(\$host)} niet vinden.";
$Lang{host_is_a_DHCP_host} = <<EOF;
\$host is een DHCP-machine en ik ken zijn IP-nummer niet. Ik controleerde de
netbios-naam van \$ENV{REMOTE_ADDR}\$tryIP, en ontdekte dat die machine
niet dezelfde machine als \$host is.
<p>
In afwachting dat ik machine \$host op een welbepaald DHCP-adres terugvind, kan u
deze aanvraag enkel doen vanaf die machine zelf.
EOF

# ------------------------------------
# !! Server Mesg !!
# ------------------------------------

$Lang{Backup_requested_on_DHCP__host} = "backup aangevraagd van DHCP \$host (\$In{hostIP}) door"
		                      . " \$User vanaf \$ENV{REMOTE_ADDR}";
$Lang{Backup_requested_on__host_by__User} = "backup aangevraagd van \$host door \$User";
$Lang{Backup_stopped_dequeued_on__host_by__User} = "backup geannuleerd van \$host door \$User";
$Lang{Restore_requested_to_host__hostDest__backup___num} = "Terugplaatsing aangevraagd naar machine \$hostDest, backup nr.\$num,"
	     . " door \$User vanaf \$ENV{REMOTE_ADDR}";
$Lang{Archive_requested} = "Archivering aangevraagd door \$User vanaf \$ENV{REMOTE_ADDR}";

# -------------------------------------------------
# ------- Stuff that was forgotten ----------------
# -------------------------------------------------

$Lang{Status} = "Status";
$Lang{PC_Summary} = "PC overzicht";
$Lang{LOG_file} = "LOG-bestand";
$Lang{LOG_files} = "LOG-bestanden";
$Lang{Old_LOGs} = "Oude LOGs";
$Lang{Email_summary} = "E-mailoverzicht";
$Lang{Config_file} = "Configuratiebest.";
$Lang{Hosts_file} = "Hosts-bestand";
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
(<a href=\"\$MyURL?action=\${EscURI(\$Lang->{Stop_Dequeue_Archive})}&host=\$host\">Wijzig dit aantal</a>).
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
$Lang{Browse} = "Bekijke backups";
$Lang{Last_bad_XferLOG} = "Laaste overdr.LOG met fouten";
$Lang{Last_bad_XferLOG_errors_only} = "Laaste overdr.LOG (enkel foutmeldingen)";

$Lang{This_display_is_merged_with_backup} = <<EOF;
<li> Dit overzicht is samengevoegd met backup #\$numF.
EOF

$Lang{Visit_this_directory_in_backup} = <<EOF;
<li> Selecteer de backup die u wil bekijken: <select onChange="window.location=this.value">\$otherDirs </select>
EOF

$Lang{Restore_Summary} = <<EOF;
\${h2("Overzicht terugplaatsingen")}
<p>
Klik op het terugplaatsingsnummer voor meer details.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Terugplaatsing nr.</td>
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
<tr><td bgcolor="#ffffff">De map/directory \${EscHTML(\$dirDisplay)} is leeg
</td></tr>
EOF

#$Lang{on} = "aan";
$Lang{off} = "uit";

$Lang{backupType_full}    = "volledig";
$Lang{backupType_incr}    = "incrementeel";
$Lang{backupType_partial} = "gedeeltelijk";

$Lang{failed} = "mislukt";
$Lang{success} = "succesvol";
$Lang{and} = "en";

# ------
# Hosts states and reasons
$Lang{Status_idle} = "in rust";
$Lang{Status_backup_starting} = "backup start";
$Lang{Status_backup_in_progress} = "backup bezig";
$Lang{Status_restore_starting} = "terugplaatsen start";
$Lang{Status_restore_in_progress} = "terugplaatsen bezig";
$Lang{Status_link_pending} = "wacht op linken";
$Lang{Status_link_running} = "linken is bezig";

$Lang{Reason_backup_done} = "backup voltooid";
$Lang{Reason_restore_done} = "terugplaatsen voltooid";
$Lang{Reason_archive_done}   = "archivering voltooid";
$Lang{Reason_nothing_to_do} = "niets te doen";
$Lang{Reason_backup_failed} = "backup mislukt";
$Lang{Reason_restore_failed} = "terugplaatsen mislukt";
$Lang{Reason_archive_failed} = "archivering mislukt";
$Lang{Reason_no_ping} = "geen ping";
$Lang{Reason_backup_canceled_by_user} = "backup geannuleerd door gebruiker";
$Lang{Reason_restore_canceled_by_user} = "terugplaatsen geannuleerd door gebruiker";
$Lang{Reason_archive_canceled_by_user} = "archivering geannuleerd door gebruiker";

# ---------
# Email messages

# No backup ever
$Lang{EMailNoBackupEverSubj} = "BackupPC: Er werd (nog) geen backup gemaakt van pc \$host";
$Lang{EMailNoBackupEverMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj

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

Beste $userName,

Er is reeds gedurende $days dagen geen backup meer gemaakt van uw pc ($host).
Er zijn ondertussen van uw pc $numbackups gemaakt sinds $firstTime.
De laatste backup dateert van $days geleden.
PC backups zouden automatisch moeten gebeuren als uw pc verbonden
is met het netwerk. 

Als uw pc gedurende geruime tijd (meer dan een paar uur) verbonden
was met het netwerk gedurende de laatste $days dagen, kan u het beste
contact opnemen van uw systeembeheerder. Vraag hem of haar om uit te
zoeken waarom er geen backups meer genomen worden van uw pc.

Anderzijds, als deze pc of notebook zich momenteel niet in het netwerk
bevindt dan kan u hieraan weinig doen behalve van belangrijke bestanden
handmatig een copy nemen op een ander medium (CD,diskette, tape,andere pc,...)
U dient te weten dat *geen enkel bestand* dat u aanmaakte of wijzigde in de
laatste $days dagen teruggeplaatst zal kunnen worden in geval de harde schijf
van uw pc zou crashen. Hierin zijn nieuwe e-mail en bijlagen inbegrepen.


Met vriendelijke groeten,
BackupPC Genie
http://backuppc.sourceforge.net
eof

# Old Outlook files
$Lang{EMailOutlookBackupSubj} = "BackupPC: Outlookbestanden op pc \$host moeten gebackupt worden";
$Lang{EMailOutlookBackupMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj

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

#end of lang_nl.pm

