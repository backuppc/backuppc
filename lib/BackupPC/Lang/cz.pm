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

$Lang{Start_Archive} = "Spustit Archivaci";
$Lang{Stop_Dequeue_Archive} = "Ukonèit/Odstranit z Fronty Archivaci";
$Lang{Start_Full_Backup} = "Spustit Úplné Zálohování";
$Lang{Start_Incr_Backup} = "Spustit Inkremetaèní Zálohování";
$Lang{Stop_Dequeue_Backup} = "Ukonèit/Odstranit z Fronty Zálohování";
$Lang{Restore} = "Obnovit";
$Lang{Type_full} = "úplnı";
$Lang{Type_incr} = "inkrementaèní";

# -----

$Lang{Only_privileged_users_can_view_admin_options} = "Pouze oprávnìní uivatelé mají pøístup k administraènímu nastavení.";
$Lang{H_Admin_Options} = "BackupPC Server: Administraèní nastavení";
$Lang{Admin_Options} = "Administraèní nastavení";
$Lang{Admin_Options_Page} = <<EOF;
\${h1(qq{$Lang{Admin_Options}})}
<br>
\${h2("Kontrola Serveru")}
<form name="ReloadForm" action="\$MyURL" method="get">
<input type="hidden" name="action" value="">
<table class="tableStnd">
  <tr><td>Znovu nahrát konfiguraci serveru:<td><input type="button" value="Reload"
     onClick="document.ReloadForm.action.value='Reload';
              document.ReloadForm.submit();">
</table>
</form>
<!--
\${h2("Konfigurace serveru")}
<ul>
  <li><i>Jiná nastavení mohou bıt zde ... napø,</i>
  <li>Editace konfigurace serveru
</ul>
-->
EOF

$Lang{Unable_to_connect_to_BackupPC_server} = "Není moné se pøipojit k BackupPC serveru";
$Lang{Unable_to_connect_to_BackupPC_server_error_message} = <<EOF;
Tento CGI skript (\$MyURL) se není schopnı pøipojit k BackupPC
server na \$Conf{ServerHost} port \$Conf{ServerPort}.<br>
Chyba: \$err.<br>
Je moné, e BackupPC server není spuštìn nebo je chyba v konfiguraci.
Prosím oznamte to systémovému administrátorovi.
EOF

$Lang{Admin_Start_Server} = <<EOF;
\${h1(qq{$Lang{Unable_to_connect_to_BackupPC_server}})}
<form action="\$MyURL" method="get">
BackupPC server na <tt>\$Conf{ServerHost}</tt> port <tt>\$Conf{ServerPort}</tt>
není momentálnì spuštìn (moná jste ho ukonèil nebo ještì nespustil).<br>
Chceste ho spustit?
<input type="hidden" name="action" value="startServer">
<input type="submit" value="Spustit Server" name="ignore">
</form>
EOF

# -----

$Lang{H_BackupPC_Server_Status} = "Status Serveru BackupPC";

$Lang{BackupPC_Server_Status_General_Info}= <<EOF;
\${h2(\"Obecné Informace o Serveru\")}

<ul>
<li> PID serveru je \$Info{pid},  na hostu \$Conf{ServerHost},
     verze \$Info{Version}, spuštìnı \$serverStartTime.
<li> Vygenerování stavu : \$now.
<li> Nahrání konfigurace : \$configLoadTime.
<li> PC bude pøíštì ve frontì : \$nextWakeupTime.
<li> Další informace:
    <ul>
        <li>\$numBgQueue nevyøízenıch ádostí o zálohu z posledního naplánované probuzení,
        <li>\$numUserQueue nevyøízenıch ádostí o zálohu od uivatelù,
        <li>\$numCmdQueue pending command requests,
        \$poolInfo
        <li>Pool file system was recently at \$Info{DUlastValue}%
            (\$DUlastTime), today\'s max is \$Info{DUDailyMax}% (\$DUmaxTime)
            and yesterday\'s max was \$Info{DUDailyMaxPrev}%.
    </ul>
</ul>
EOF

$Lang{BackupPC_Server_Status} = <<EOF;
\${h1(qq{$Lang{H_BackupPC_Server_Status}})}

<p>
\${h2("Probíhající úlohy")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td> Host </td>
    <td> Typ </td>
    <td> Uivatel </td>
    <td> Spuštìno </td>
    <td> Pøíkaz </td>
    <td align="center"> PID </td>
    <td align="center"> Xfer PID </td>
    <td align="center"> Status </td>
    <td align="center"> Count </td>
    </tr>
\$jobStr
</table>

<p>
\$generalInfo

\${h2("Selhání, která vyadují pozornost")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> Host </td>
    <td align="center"> Typ </td>
    <td align="center"> Uivatel </td>
    <td align="center"> Poslední pokus </td>
    <td align="center"> Detaily </td>
    <td align="center"> Èas chyby </td>
    <td> Poslední chyba (jiná ne ádnı ping) </td></tr>
\$statusStr
</table>
EOF

# --------------------------------
$Lang{BackupPC__Server_Summary} = "BackupPC: Vıpis Hostù";
$Lang{BackupPC__Archive} = "BackupPC: Archiv";
$Lang{BackupPC_Summary} = <<EOF;

\${h1(qq{$Lang{BackupPC__Server_Summary}})}
<p>
<ul>
<li>Tento stav byl vygenerován v \$now.
<li>Stav úloištì je \$Info{DUlastValue}%
    (\$DUlastTime), dnešní maximum je \$Info{DUDailyMax}% (\$DUmaxTime)
        a vèerejší maximum bylo \$Info{DUDailyMaxPrev}%.
</ul>
</p>

\${h2("Hosté s úspìšnì provedenımi zálohami")}
<p>
\$hostCntGood hostù bylo úspìšnì zálohováno, v celkové velikost:
<ul>
<li> \$fullTot úplnıch záloh v celkové velitosti \${fullSizeTot}GiB
     (pøed kompresí),
<li> \$incrTot inkementaèních záloh v celkové velikosti \${incrSizeTot}GiB
     (pøed kompresí).
</ul>
</p>
<table class="sortable" id="host_summary_backups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> Host </td>
    <td align="center"> Uivatel </td>
    <td align="center"> #Plnı </td>
    <td align="center"> Plnı Èas (dní) </td>
    <td align="center"> Plnı Velikost (GiB) </td>
    <td align="center"> Rychlost (MB/s) </td>
    <td align="center"> #Inkr </td>
    <td align="center"> Inkr èas (dní) </td>
    <td align="center"> Poslední Záloha (dní) </td>
    <td align="center"> Stav </td>
    <td align="center"> #Xfer chyb </td>
    <td align="center"> Poslední pokus </td></tr>
\$strGood
</table>
<br><br>
\${h2("Hosté s ádnımi provedenımi zálohami")}
<p>
\$hostCntNone hostù s ádnımi zálohani.
<p>
<table class="sortable" id="host_summary_nobackups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> Host </td>
    <td align="center"> Uivatel </td>
    <td align="center"> #Plnı </td>
    <td align="center"> Plnı Èas (dní) </td>
    <td align="center"> Plnı Velikost (GiB) </td>
    <td align="center"> Rychlost (MB/s) </td>
    <td align="center"> #Inkr </td>
    <td align="center"> Inkr èas (dní) </td>
    <td align="center"> Poslední Záloha (dní) </td>
    <td align="center"> Stav </td>
    <td align="center"> #Xfer chyb </td>
    <td align="center"> Poslední pokus </td></tr>
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

\$hostCntGood hostù, kteøí byli zálohováni v celkové velikosti \${fullSizeTot}GiB
<p>
<form name="form1" method="post" action="\$MyURL">
<input type="hidden" name="fcbMax" value="\$checkBoxCnt">
<input type="hidden" name="type" value="1">
<input type="hidden" name="host" value="\${EscHTML(\$archHost)}">
<input type="hidden" name="action" value="Archive">
<table class="tableStnd" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td align=center> Host</td>
    <td align="center"> Uivatel </td>
    <td align="center"> Velikost zálohy </td>
\$strGood
\$checkAllHosts
</table>
</form>
<p>

EOF

$Lang{BackupPC_Archive2} = <<EOF;
\${h1(qq{$Lang{BackupPC__Archive}})}
Nasledující hosté se chystají k archivaci
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
    <td colspan=2><input type="submit" value="Start the Archive" name="ignore"></td>
</tr>
</form>
</table>
EOF

$Lang{BackupPC_Archive2_location} = <<EOF;
<tr>
    <td>Umístìní Archivu</td>
    <td><input type="text" value="\$ArchiveDest" name="archive_device"></td>
</tr>
EOF

$Lang{BackupPC_Archive2_compression} = <<EOF;
<tr>
    <td>Komprese</td>
    <td>
    <input type="radio" value="0" name="compression" \$ArchiveCompNone>None<br>
    <input type="radio" value="1" name="compression" \$ArchiveCompGzip>gzip<br>
    <input type="radio" value="2" name="compression" \$ArchiveCompBzip2>bzip2
    </td>
</tr>
EOF

$Lang{BackupPC_Archive2_parity} = <<EOF;
<tr>
    <td>Procent paritních dat (0 = vypnuté, 5 = typické)</td>
    <td><input type="numeric" value="\$ArchivePar" name="par"></td>
</tr>
EOF

$Lang{BackupPC_Archive2_split} = <<EOF;
<tr>
    <td>Rozdìlit vıstup na</td>
    <td><input type="numeric" value="\$ArchiveSplit" name="splitsize">Megabytes</td>
</tr>
EOF

# -----------------------------------
$Lang{Pool_Stat} = <<EOF;
        <li>V úloišti je \${poolSize}GiB zahrnujíc \$info->{"\${name}FileCnt"} souborù
            a \$info->{"\${name}DirCnt"} adresáøù (od \$poolTime),
        <li>Hashování úloištì dává \$info->{"\${name}FileCntRep"} opakujících se
        souborù s nejdelším øetìzem \$info->{"\${name}FileRepMax"},
        <li>Noèní úklid úloištì odstranil \$info->{"\${name}FileCntRm"} souborù
            velikosti \${poolRmSize}GiB (kolem \$poolTime),
EOF

# --------------------------------
$Lang{BackupPC__Backup_Requested_on__host} = "BackupPC:  Záloha vyádána na \$host";
# --------------------------------
$Lang{REPLY_FROM_SERVER} = <<EOF;
\${h1(\$str)}
<p>
Odpovìï serveru na: \$reply
<p>
Vra se na <a href="\$MyURL?host=\$host">domovskou stránku \$host</a>.
EOF
# --------------------------------
$Lang{BackupPC__Start_Backup_Confirm_on__host} = "BackupPC: Zaèátek zálohy potvrzen na \$host";
# --------------------------------
$Lang{Are_you_sure_start} = <<EOF;
\${h1("Are you sure?")}
<p>
Chystáte se spustit \$type zálohu na \$host.

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="hostIP" value="\$ipAddr">
<input type="hidden" name="doit" value="1">
<input type="hidden" name="action" value="">
Opravdu to chcete provést?
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="No" name="ignore">
</form>
EOF
# --------------------------------
$Lang{BackupPC__Stop_Backup_Confirm_on__host} = "BackupPC: Ukonèit potvrzení kopie na \$host";
# --------------------------------
$Lang{Are_you_sure_stop} = <<EOF;

\${h1("Jste si jistı?")}

<p>
Chystáte se ukonèit/vyøadit z fronty zálohování na \$host;

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host"   value="\$host">
<input type="hidden" name="doit"   value="1">
<input type="hidden" name="action" value="">
Prosím, nezaèínejte jiné zálohování
<input type="text" name="backoff" size="10" value="\$backoff"> hodin.
<p>
Opravdu to chcete provést?
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="No" name="ignore">
</form>

EOF
# --------------------------------
$Lang{Only_privileged_users_can_view_queues_} = "Pouze oprávnìní uivatelé mají pøistup k frontám.";
# --------------------------------
$Lang{Only_privileged_users_can_archive} = "Pouze oprávnìní uivatelé mohou archivovat.";
# --------------------------------
$Lang{BackupPC__Queue_Summary} = "BackupPC: Pøehled front";
# --------------------------------
$Lang{Backup_Queue_Summary} = <<EOF;
\${h1("Pøehled fronty zálohování")}
<br><br>
\${h2("Pøehled fronty uivatelù")}
<p>
Následující uivatelé jsou momentálnì ve frontì:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Host </td>
    <td> Èas do </td>
    <td> Uivatel </td></tr>
\$strUser
</table>
<br><br>

\${h2("Souhrn fronty v pozadí")}
<p>
Následující ádosti v pozadí jsou momentálnì ve frontì:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Host </td>
    <td> Èas do </td>
    <td> Uivatel </td></tr>
\$strBg
</table>
<br><br>
\${h2("Souhrn fronty pøíkazù")}
<p>
Následující pøíkazy jsou momentálnì ve frontì:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Host </td>
    <td> Èas do </td>
    <td> Uivatel </td>
    <td> Pøíkaz </td></tr>
\$strCmd
</table>
EOF

# --------------------------------
$Lang{Backup_PC__Log_File__file} = "BackupPC: Soubor \$file";
$Lang{Log_File__file__comment} = <<EOF;
\${h1("Soubor \$file \$comment")}
<p>
EOF
# --------------------------------
$Lang{Contents_of_log_file} = <<EOF;
Obsah souboru <tt>\$file</tt>, modifikován \$mtimeStr \$comment
EOF

# --------------------------------
$Lang{skipped__skipped_lines} = "[ pøeskoèeno \$skipped øádkù ]\n";
# --------------------------------
$Lang{_pre___Can_t_open_log_file__file} = "<pre>\nNení moné otevøít log soubor \$file\n";

# --------------------------------
$Lang{BackupPC__Log_File_History} = "BackupPC: Historie Log Souboru";
$Lang{Log_File_History__hdr} = <<EOF;
\${h1("Historie Log Souboru \$hdr")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Soubor </td>
    <td align="center"> Velikost </td>
    <td align="center"> Èas modifikace </td></tr>
\$str
</table>
EOF

# -------------------------------
$Lang{Recent_Email_Summary} = <<EOF;
\${h1("Pøehled nedávnıch emailù (Øazeno zpìtnì)")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Pøíjemce </td>
    <td align="center"> Odesílatel </td>
    <td align="center"> Èas </td>
    <td align="center"> Pøedmìt </td></tr>
\$str
</table>
EOF
 

# ------------------------------
$Lang{Browse_backup__num_for__host} = "BackupPC: Prohlíet zálohu \$num pro \$host";

# ------------------------------
$Lang{Restore_Options_for__host} = "BackupPC: Obnovit nastavení pro \$host";
$Lang{Restore_Options_for__host2} = <<EOF;
\${h1("Obnovit nastavení pro \$host")}
<p>
Vybral jste následující soubory/adresáøe z
èásti \$share, záloha èíslo #\$num:
<ul>
\$fileListStr
</ul>
</p><p>
Pro obnovení tìchto souborù/adresáøù máte tøi monosti.
Vyberte si, prosím, jednu z následujících moností.
</p>
\${h2("Monost 1: Pøímá obnova")}
<p>
EOF

$Lang{Restore_Options_for__host_Option1} = <<EOF;
Mùete spustit obnovení tìchto souborù do
<b>\$directHost</b>.
</p><p>
<b>Varování:</b> jakıkoliv existující soubor, kterı odpovída tìm,
které máte vybrány bude smazán!
</p>
<form action="\$MyURL" method="post" name="direct">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="3">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<table class="tableStnd" border="0">
<tr>
    <td>Obnovit souboru do hosta</td>
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
	 <!--<a href="javascript:myOpen('\$MyURL?action=findShares&host='+document.direct.hostDest.options.value)">Hledej dostupné èásti (NENÍ IMPLEMENTOVÁNO)</a>--></td>
</tr><tr>
    <td>Obnovení souborù do èásti</td>
    <td><input type="text" size="40" value="\${EscHTML(\$share)}"
	 name="shareDest"></td>
</tr><tr>
    <td>Obnovit soubory v adresáøi<br>(vztahující se k èásti)</td>
    <td valign="top"><input type="text" size="40" maxlength="256"
	value="\${EscHTML(\$pathHdr)}" name="pathHdr"></td>
</tr><tr>
    <td><input type="submit" value="Start Restore" name="ignore"></td>
</table>
</form>
EOF

$Lang{Restore_Options_for__host_Option1_disabled} = <<EOF;
Pøímé obnovení bylo zakázáno pro hosta \${EscHTML(\$hostDest)}.
Vyberte si, prosím, jednu z moností obnovy.
EOF

# ------------------------------
$Lang{Option_2__Download_Zip_archive} = <<EOF;
<p>
\${h2("Monost 2: Stáhnout Zip archiv")}
<p>
Mùete stáhnout Zip archiv obsahující všechny soubory/adresáøe, které
jste vybral.  Poté mùete pouít aplikaci, napø. WinZip, k zobrazení
nebp rozbalení nìkterého z tìchto souborù.
</p><p>
<b>Varování:</b> v závislosti na tom, které soubory/adresáøe jste vybral,
tento archiv mùe bıt velmi velkı.  Vytvoøení a pøenos archivu mùe trvat
minuty, a budete potøebovat dostatek místa na lokálním disku.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="2">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Vytvoøit archiv relativní
k \${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(jinak bude archiv obsahovat plnou cestu).
<br>
<table class="tableStnd" border="0">
<tr>
    <td>Komprese (0=off, 1=rychlá,...,9=nejlepší)</td>
    <td><input type="text" size="6" value="5" name="compressLevel"></td>
</tr><tr>
    <td>Code page (e.g. cp866)</td>
    <td><input type="text" size="6" value="utf8" name="codePage"></td>
</tr>
</table>
<br>
<input type="submit" value="Stáhnout Zip soubor" name="ignore">
</form>
EOF

# ------------------------------

$Lang{Option_2__Download_Zip_archive2} = <<EOF;
<p>
\${h2("Monost 2: Stánout Zip archiv")}
<p>
Archive::Zip není nainstalován, èili nebude moné stáhnout
zip archiv.
Poádejte systémového administrátora o instalaci Archive::Zip z
<a href="http://www.cpan.org">www.cpan.org</a>.
</p>
EOF


# ------------------------------
$Lang{Option_3__Download_Zip_archive} = <<EOF;
\${h2("Monost 3: Stáhnout Tar archiv")}
<p>
Mùete stáhnout Tar archiv obsahující všechny soubory/adresáøe, které
jste vybral.  Poté mùete pouít aplikaci, napø. tar nebo WinZip, k zobrazení
nebp rozbalení nìkterého z tìchto souborù.
</p><p>
<b>Varování:</b> v závislosti na tom, které soubory/adresáøe jste vybral,
tento archiv mùe bıt velmi velkı.  Vytvoøení a pøenos archivu mùe trvat
minuty, a budete potøebovat dostatek místa na lokálním disku.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="1">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Vytvoø archiv relativní
k \${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(jinak bude archiv obsahovat plnou cestu).
<br>
<input type="submit" value="Stánout Tar soubor" name="ignore">
</form>
EOF


# ------------------------------
$Lang{Restore_Confirm_on__host} = "BackupPC: Potvrzení obnovení na \$host";

$Lang{Are_you_sure} = <<EOF;
\${h1("Jsi si jistı?")}
<p>
Chystáte se zahájit obnovu pøímo do poèítaèe \$In{hostDest}.
Následující soubory budou obnoveny do èásti \$In{shareDest}, ze
zálohy èíslo \$num:
<p>
<table class="tableStnd" border>
<tr class="tableheader"><td>Originální soubor/adresáø</td><td>Bude obnoven do</td></tr>
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
Obravdu to chceš provést?
<input type="button" value="\$Lang->{Restore}"
 onClick="document.RestoreForm.action.value='Restore';
          document.RestoreForm.submit();">
<input type="submit" value="No" name="ignore">
</form>
EOF


# --------------------------
$Lang{Restore_Requested_on__hostDest} = "BackupPC: Obnovit vyádané na \$hostDest";
$Lang{Reply_from_server_was___reply} = <<EOF;
\${h1(\$str)}
<p>
Odpovìï od serveru: \$reply
<p>
Jít zpìt na <a href="\$MyURL?host=\$hostDest">domovská stránka \$hostDest</a>.
EOF

$Lang{BackupPC_Archive_Reply_from_server} = <<EOF;
\${h1(\$str)}
<p>
Odpovìï od serveru: \$reply
EOF


# -------------------------
$Lang{Host__host_Backup_Summary} = "BackupPC: Pøehled záloh hosta \$host";

$Lang{Host__host_Backup_Summary2} = <<EOF;
\${h1("Pøehled záloh hosta \$host")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>
</p>
\${h2("User Actions")}
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
\${h2("Pøehled záloh")}
<p>
Kliknìte na èíslo zálohy pro prohlíení a obnovení zálohy.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> Backup# </td>
    <td align="center"> Typ </td>
    <td align="center"> Vyplnìno </td>
    <td align="center"> Úroveò </td>
    <td align="center"> Datum spuštìní </td>
    <td align="center"> Doba trvání/minuty </td>
    <td align="center"> Doba/dny </td>
    <td align="center"> Cesta serveru zálohy </td>
</tr>
\$str
</table>
<p>

\$restoreStr
</p>
<br><br>
\${h2("Pøehled Xfer chyb")}
<br><br>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Backup# </td>
    <td align="center"> Typ </td>
    <td align="center"> Pohled </td>
    <td align="center"> #Xfer chyby </td>
    <td align="center"> #špatné soubory </td>
    <td align="center"> #špatné èásti </td>
    <td align="center"> #tar chyby </td>
</tr>
\$errStr
</table>
<br><br>

\${h2("File Size/Count Reuse Summary")}
<p>
Existující soubory jsou ty, které jsou ji v úloišti; nové jsou pøidané
do úloištì.
Prázné soubory a SMB chyby nejsou poèítány.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="2" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> Celkovì </td>
    <td align="center" colspan="2"> Existující soubory </td>
    <td align="center" colspan="2"> Nové soubory </td>
</tr>
<tr class="tableheader">
    <td align="center"> Záloha # </td>
    <td align="center"> Typ </td>
    <td align="center"> #Soubory </td>
    <td align="center"> Velikost/MB </td>
    <td align="center"> MB/sec </td>
    <td align="center"> #Soubory </td>
    <td align="center"> Velikost/MB </td>
    <td align="center"> #Soubory </td>
    <td align="center"> Velikost/MB </td>
</tr>
\$sizeStr
</table>
<br><br>

\${h2("Pøehled kompresí")}
<p>
Vıkon komprese pro soubory, které jsou ji v úloišti a pro novì
zkomprimované soubory.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="3" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> Existující soubory </td>
    <td align="center" colspan="3"> Nové soubory </td>
</tr>
<tr class="tableheader"><td align="center"> Záloha # </td>
    <td align="center"> Typ </td>
    <td align="center"> Úroveò komprese </td>
    <td align="center"> Velikost/MB </td>
    <td align="center"> Komprese/MB </td>
    <td align="center"> Komprese </td>
    <td align="center"> Velikost/MB </td>
    <td align="center"> Komprese/MB </td>
    <td align="center"> Komprese </td>
</tr>
\$compStr
</table>
<br><br>
EOF

$Lang{Host__host_Archive_Summary} = "BackupPC: Pøehled archivù hosta \$host ";
$Lang{Host__host_Archive_Summary2} = <<EOF;
\${h1("Pøehled archivù hosta \$host")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>

\${h2("Uivatelské akce")}
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
$Lang{Error} = "BackupPC: Chyba";
$Lang{Error____head} = <<EOF;
\${h1("Chyba: \$head")}
<p>\$mesg</p>
EOF

# -------------------------
$Lang{NavSectionTitle_} = "Server";

# -------------------------
$Lang{Backup_browse_for__host} = <<EOF;
\${h1("Prohlíení záloh pro \$host")}

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
<li> Prohlííte zálohu #\$num, která byla spuštìna kolem \$backupTime
        (\$backupAge dní zpìt),
\$filledBackup
<li> Zadej adresáø: <input type="text" name="dir" size="50" maxlength="4096" value="\${EscHTML(\$dir)}"> <input type="submit" value="\$Lang->{Go}" name="Submit">
<li> Klikni na adresáø níe a pokraèuj do nìj,
<li> Klikni na soubor níe a obnov ho,
<li> Mùeš vidìt zálohu <a href="\$MyURL?action=dirHistory&host=\${EscURI(\$host)}&share=\$shareURI&dir=\$pathURI">history</a> aktuálního adresáøe.
</ul>
</form>

\${h2("Obsah \$dirDisplay")}
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
$Lang{DirHistory_backup_for__host} = "BackupPC: Historie záloh adresáøù pro \$host";

#
# These two strings are used to build the links for directories and
# file versions.  Files are appended with a version number.
#
$Lang{DirHistory_dirLink}  = "adres";
$Lang{DirHistory_fileLink} = "v";

$Lang{DirHistory_for__host} = <<EOF;
\${h1("Historie záloh adresáøù pro \$host")}
<p>
Tato obrazovka zobrazuje kadou unikátní verzi souboru
ze všech záloh:
<ul>
<li> Klikni na èíslo zálohy k návratu do prohlíeèe záloh,
<li> Klikni na odkaz adresáøe (\$Lang->{DirHistory_dirLink}) k pøechodu do
     nìj,
<li> Klikni na odkaz verze souboru (\$Lang->{DirHistory_fileLink}0,
     \$Lang->{DirHistory_fileLink}1, ...) k jeho staení,
<li> Soubory se stejnım obsahem v rùznıch zálohách mají stejné
     èíslo verze,
<li> Soubory nebo adresáøe, které nejsou ve vybrané záloze 
     nejsou oznaèeny.
<li> Soubory zobrazené se stejnım èíslem verze mohou mít rozdílné atributy.
     Vyber èíslo zálohy k zobrazení atributù souboru.
</ul>

\${h2("Historie \$dirDisplay")}

<br>
<table border cellspacing="2" cellpadding="3">
<tr class="fviewheader"><td>Èíslo zálohy</td>\$backupNumStr</tr>
<tr class="fviewheader"><td>Èas zálohy</td>\$backupTimeStr</tr>
\$fileStr
</table>
EOF

# ------------------------------
$Lang{Restore___num_details_for__host} = "BackupPC: Obnovit #\$num detailù pro \$host";

$Lang{Restore___num_details_for__host2} = <<EOF;
\${h1("Obnovit #\$num Detailù pro \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="90%">
<tr><td class="tableheader"> Èíslo </td><td class="border"> \$Restores[\$i]{num} </td></tr>
<tr><td class="tableheader"> Vyádal </td><td class="border"> \$RestoreReq{user} </td></tr>
<tr><td class="tableheader"> Èas vyádání </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> Vısledek </td><td class="border"> \$Restores[\$i]{result} </td></tr>
<tr><td class="tableheader"> Chybová zpráva </td><td class="border"> \$Restores[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> Zdrojovı host </td><td class="border"> \$RestoreReq{hostSrc} </td></tr>
<tr><td class="tableheader"> Èíslo zdrojové zálohy </td><td class="border"> \$RestoreReq{num} </td></tr>
<tr><td class="tableheader"> Zdrojová èást </td><td class="border"> \$RestoreReq{shareSrc} </td></tr>
<tr><td class="tableheader"> Cílovı host </td><td class="border"> \$RestoreReq{hostDest} </td></tr>
<tr><td class="tableheader"> Cílová èást </td><td class="border"> \$RestoreReq{shareDest} </td></tr>
<tr><td class="tableheader"> Èas spuštìní </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Doba trvání </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> Poèet souborù </td><td class="border"> \$Restores[\$i]{nFiles} </td></tr>
<tr><td class="tableheader"> Celková velikost </td><td class="border"> \${MB} MB </td></tr>
<tr><td class="tableheader"> Pøenosová rychlost </td><td class="border"> \$MBperSec MB/sec </td></tr>
<tr><td class="tableheader"> TarCreate chyb </td><td class="border"> \$Restores[\$i]{tarCreateErrs} </td></tr>
<tr><td class="tableheader"> Xfer chyb </td><td class="border"> \$Restores[\$i]{xferErrs} </td></tr>
<tr><td class="tableheader"> Xfer log soubor </td><td class="border">
<a href="\$MyURL?action=view&type=RestoreLOG&num=\$Restores[\$i]{num}&host=\$host">View</a>,
<a href="\$MyURL?action=view&type=RestoreErr&num=\$Restores[\$i]{num}&host=\$host">Errors</a>
</tr></tr>
</table>
</p>
\${h1("Seznam souborù/adresáøù")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="100%">
<tr class="tableheader"><td>Originální soubor/adresáø</td><td>Obnoven do</td></tr>
\$fileListStr
</table>
EOF

# ------------------------------
$Lang{Archive___num_details_for__host} = "BackupPC: Archivovat #\$num detailù pro \$host";

$Lang{Archive___num_details_for__host2 } = <<EOF;
\${h1("Archivovat #\$num Detailù pro \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr><td class="tableheader"> Èíslo </td><td class="border"> \$Archives[\$i]{num} </td></tr>
<tr><td class="tableheader"> Vyádal </td><td class="border"> \$ArchiveReq{user} </td></tr>
<tr><td class="tableheader"> Èas vyádání </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> Odpovìd </td><td class="border"> \$Archives[\$i]{result} </td></tr>
<tr><td class="tableheader"> Chybová zpráva </td><td class="border"> \$Archives[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> Èas spustìní </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Dpba trvání </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> Xfer log soubor </td><td class="border">
<a href="\$MyURL?action=view&type=ArchiveLOG&num=\$Archives[\$i]{num}&host=\$host">View</a>,
<a href="\$MyURL?action=view&type=ArchiveErr&num=\$Archives[\$i]{num}&host=\$host">Errors</a>
</tr></tr>
</table>
<p>
\${h1("Seznam hostù")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td>Host</td><td>Èíslo kopie</td></tr>
\$HostListStr
</table>
EOF

# -----------------------------------
$Lang{Email_Summary} = "BackupPC: Souhrn emailù";

# -----------------------------------
#  !! ERROR messages !!
# -----------------------------------
$Lang{BackupPC__Lib__new_failed__check_apache_error_log} = "BackupPC::Lib->new failed: zkontroluj apache error_log\n";
$Lang{Wrong_user__my_userid_is___} =  
              "Špatnı uivatel: moje userid je \$>, místo \$uid"
            . "(\$Conf{BackupPCUser})\n";
# $Lang{Only_privileged_users_can_view_PC_summaries} = "Pouze oprávnìní uivatelé jsou oprávnìni prohlíet souhrny PC.";
$Lang{Only_privileged_users_can_stop_or_start_backups} = 
                  "Pouze oprávnìní uivatelé mohou ukonèit nebo spustit zálohování na"
		. " \${EscHTML(\$host)}.";
$Lang{Invalid_number__num} = "Špatné èíslo \${EscHTML(\$In{num})}";
$Lang{Unable_to_open__file__configuration_problem} = "Nepodaøilo se otevøít \$file: problém konfigurace?";
$Lang{Only_privileged_users_can_view_log_or_config_files} = "Pouze oprávnìní uivatelé mají pøístup k log a konfiguraèním souborùm.";
$Lang{Only_privileged_users_can_view_log_files} = "Pouze oprávnìní uivatelé mají pøístup k log souborùm.";
$Lang{Only_privileged_users_can_view_email_summaries} = "Pouze oprávnìní uivatelé mají pøístup k souhrnu emailù.";
$Lang{Only_privileged_users_can_browse_backup_files} = "Pouze oprávnìní uivatelé mohou prohlíet soubory záloh"
                . " pro host \${EscHTML(\$In{host})}.";
$Lang{Empty_host_name} = "Prázdné jméno hosta.";
$Lang{Directory___EscHTML} = "Adresáø \${EscHTML(\"\$TopDir/pc/\$host/\$num\")}"
		    . " je prázdnı";
$Lang{Can_t_browse_bad_directory_name2} = "Není moné prohlíet - špatnı název adresáøe"
	            . " \${EscHTML(\$relDir)}";
$Lang{Only_privileged_users_can_restore_backup_files} = "Pouze oprávnìní uivatelé mohou obnovovat soubory zálohy"
                . " pro hosta \${EscHTML(\$In{host})}.";
$Lang{Bad_host_name} = "Špatné jméno hosta \${EscHTML(\$host)}";
$Lang{You_haven_t_selected_any_files__please_go_Back_to} = "Nevybral jste ádnı soubor; prosím jdìte Zpìt k"
                . " vıbìru souborù.";
$Lang{You_haven_t_selected_any_hosts} = "Nevybral jste ádného hosta; prosím jdìte Zpìt k"
                . " vıbìru hostù.";
$Lang{Nice_try__but_you_can_t_put} = "Nelze umístit \'..\' do názvu souboru";
$Lang{Host__doesn_t_exist} = "Host \${EscHTML(\$In{hostDest})} neexistuje";
$Lang{You_don_t_have_permission_to_restore_onto_host} = "Nemáte oprávnìní k obnovì na"
		    . " \${EscHTML(\$In{hostDest})}";
$Lang{Can_t_open_create__openPath} = "Nelze otevøít nebo vytvoøit "
		. "\${EscHTML(\"\$openPath\")}";
$Lang{Only_privileged_users_can_restore_backup_files2} = "Pouze oprávnìní uivatelé mohou obnovovat soubory zálohy"
                . " pro hosta \${EscHTML(\$host)}.";
$Lang{Empty_host_name} = "Prázdné jméno hosta";
$Lang{Unknown_host_or_user} = "Neznámı host nebo uivatel \${EscHTML(\$host)}";
$Lang{Only_privileged_users_can_view_information_about} = "Pouze oprávnìní uivatelé mají pøístup k informacím o"
                . " hostu \${EscHTML(\$host)}." ;
$Lang{Only_privileged_users_can_view_archive_information} = "Pouze oprávnìní uivatelé mají pøístup k informacím o archivaci.";
$Lang{Only_privileged_users_can_view_restore_information} = "Pouze oprávnìní uivatelé mají pøístup k informacím o obnovì.";
$Lang{Restore_number__num_for_host__does_not_exist} = "Èíslo obnovení \$num pro hosta \${EscHTML(\$host)}"
	        . " neexsituje.";
$Lang{Archive_number__num_for_host__does_not_exist} = "Èíslo archivu \$num pro hosta \${EscHTML(\$host)}"
                . " neexsituje.";
$Lang{Can_t_find_IP_address_for} = "Nelze nalézt IP adresu pro \${EscHTML(\$host)}";
$Lang{host_is_a_DHCP_host} = <<EOF;
\$host je DHCP host, and není známa jeho IP adresa.  Zkontrolováno
netbios jméno \$ENV{REMOTE_ADDR}\$tryIP, a zjištìno, e zaøízení 
není \$host.
<p>
Dokud nebude vidìt \$host na vybrané DHCP adrese, mùete pouze
spustit ádost z pøímo klientského zaøízení.
EOF

# ------------------------------------
# !! Server Mesg !!
# ------------------------------------

$Lang{Backup_requested_on_DHCP__host} = "Záloha vyádána z DHCP \$host (\$In{hostIP}) uivatelem"
		                      . " \$User z \$ENV{REMOTE_ADDR}";
$Lang{Backup_requested_on__host_by__User} = "Záloha vyádána z \$host uivatelem \$User";
$Lang{Backup_stopped_dequeued_on__host_by__User} = "Záloha ukonèena/vyøazena z fronty z \$host uivatelem \$User";
$Lang{Restore_requested_to_host__hostDest__backup___num} = "Obnova vyádána na hosta \$hostDest, obnova #\$num,"
	     . " uivatelem \$User z \$ENV{REMOTE_ADDR}";
$Lang{Archive_requested} = "Archivace vyádána uivatelem \$User z \$ENV{REMOTE_ADDR}";

# -------------------------------------------------
# ------- Stuff that was forgotten ----------------
# -------------------------------------------------

$Lang{Status} = "Stav";
$Lang{PC_Summary} = "Souhrn hostù";
$Lang{LOG_file} = "LOG soubor";
$Lang{LOG_files} = "LOG soubory";
$Lang{Old_LOGs} = "Staré LOGy";
$Lang{Email_summary} = "Souhrn emailù";
$Lang{Config_file} = "Konfiguraèní soubor";
# $Lang{Hosts_file} = "Hosts soubor";
$Lang{Current_queues} = "Aktuální fronty";
$Lang{Documentation} = "Dokumentace";

#$Lang{Host_or_User_name} = "<small>Jméno uivatele nebo hosta:</small>";
$Lang{Go} = "Jdi";
$Lang{Hosts} = "Hosts";
$Lang{Select_a_host} = "Vyber hosta...";

$Lang{There_have_been_no_archives} = "<h2> Nebyli ádné archivy </h2>\n";
$Lang{This_PC_has_never_been_backed_up} = "<h2> Toto PC nebylo nikdy zálohováno!! </h2>\n";
$Lang{This_PC_is_used_by} = "<li>Toto PC je pouíváno uivatelem \${UserLink(\$user)}";

$Lang{Extracting_only_Errors} = "(Rozbalování chyb)";
$Lang{XferLOG} = "XferLOG";
$Lang{Errors}  = "Chyby";

# ------------
$Lang{Last_email_sent_to__was_at___subject} = <<EOF;
<li>Poslední email odeslán uivately \${UserLink(\$user)} byl v \$mailTime, pøedmìt "\$subj".
EOF
# ------------
$Lang{The_command_cmd_is_currently_running_for_started} = <<EOF;
<li>Pøíkaz \$cmd je aktuálnì vykonáván pro \$host, spuštìn v \$startTime.
EOF

# -----------
$Lang{Host_host_is_queued_on_the_background_queue_will_be_backed_up_soon} = <<EOF;
<li>Host \$host èeká ve frontì na pozadí (bude brzy zálohován).
EOF

# ----------
$Lang{Host_host_is_queued_on_the_user_queue__will_be_backed_up_soon} = <<EOF;
<li>Host \$host èeká ve frontì uivatelù (bude brzy zálohován).
EOF

# ---------
$Lang{A_command_for_host_is_on_the_command_queue_will_run_soon} = <<EOF;
<li>Pøíkaz pro \$host èeká ve frontì pøíkazù (bude brzy spuštìn).
EOF

# --------
$Lang{Last_status_is_state_StatusHost_state_reason_as_of_startTime} = <<EOF;
<li>Poslední stav \"\$Lang->{\$StatusHost{state}}\"\$reason v èase \$startTime.
EOF

# --------
$Lang{Last_error_is____EscHTML_StatusHost_error} = <<EOF;
<li>Poslední chyba je \"\${EscHTML(\$StatusHost{error})}\".
EOF

# ------
$Lang{Pings_to_host_have_failed_StatusHost_deadCnt__consecutive_times} = <<EOF;
<li>Pingy na \$host selhaly \$StatusHost{deadCnt} za sebou.
EOF

# -----
$Lang{Prior_to_that__pings} = "Pøedchozí pingy";

# -----
$Lang{priorStr_to_host_have_succeeded_StatusHostaliveCnt_consecutive_times} = <<EOF;
<li>\$priorStr na \$host byli úspìšné \$StatusHost{aliveCnt}
         za sebou.
EOF

$Lang{Because__host_has_been_on_the_network_at_least__Conf_BlackoutGoodCnt_consecutive_times___} = <<EOF;
<li>Protoe \$host byl na síti alespoò \$Conf{BlackoutGoodCnt}
za sebou, nebude zálohován z \$blackoutStr.
EOF

$Lang{__time0_to__time1_on__days} = "\$t0 to \$t1 on \$days";

$Lang{Backups_are_deferred_for_hours_hours_change_this_number} = <<EOF;
<li>Zálohy byli odloeny na \$hours hodin
(<a href=\"\$MyURL?action=Stop_Dequeue_Backup&host=\$host\">zmìn toto èíslo</a>).
EOF

$Lang{tryIP} = " a \$StatusHost{dhcpHostIP}";

# $Lang{Host_Inhost} = "Host \$In{host}";

$Lang{checkAll} = <<EOF;
<tr><td class="fviewborder">
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;Select all
</td><td colspan="5" align="center" class="fviewborder">
<input type="submit" name="Submit" value="Restore selected files">
</td></tr>
EOF

$Lang{checkAllHosts} = <<EOF;
<tr><td class="fviewborder">
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;Select all
</td><td colspan="2" align="center" class="fviewborder">
<input type="submit" name="Submit" value="Archive selected hosts">
</td></tr>
EOF

$Lang{fileHeader} = <<EOF;
    <tr class="fviewheader"><td align=center> Jméno</td>
       <td align="center"> Typ</td>
       <td align="center"> Mód</td>
       <td align="center"> #</td>
       <td align="center"> Velikost</td>
       <td align="center"> Datum zmìny</td>
    </tr>
EOF

$Lang{Home} = "Doma";
$Lang{Browse} = "Prohlíení záloh";
$Lang{Last_bad_XferLOG} = "Poslední špatnı XferLOG";
$Lang{Last_bad_XferLOG_errors_only} = "Poslední špatnı XferLOG (chyb&nbsp;pouze)";

$Lang{This_display_is_merged_with_backup} = <<EOF;
<li> Toto zobrazení je slouèeno se zálohou #\$numF.
EOF

$Lang{Visit_this_directory_in_backup} = <<EOF;
<li> Vyberte zálohu, kterou si pøejete zobrazit: <select onChange="window.location=this.value">\$otherDirs </select>
EOF

$Lang{Restore_Summary} = <<EOF;
\${h2("Obnovit souhrn")}
<p>
Klikni na obnovení pro více detailù.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Obnovení # </td>
    <td align="center"> Vısledek </td>
    <td align="right"> Datum spuštení</td>
    <td align="right"> Doba trvání/minuty</td>
    <td align="right"> #souborù </td>
    <td align="right"> MB </td>
    <td align="right"> #tar chyb </td>
    <td align="right"> #xferErrs </td>
</tr>
\$restoreStr
</table>
<p>
EOF

$Lang{Archive_Summary} = <<EOF;
\${h2("Souhrn archivù")}
<p>
Klikni na èíslo archivu pro více detailù.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Archiv# </td>
    <td align="center"> Vısledek </td>
    <td align="right"> Datum spuštení</td>
    <td align="right"> Doba trvání/minuty</td>
</tr>
\$ArchiveStr
</table>
<p>
EOF

$Lang{BackupPC__Documentation} = "BackupPC: Documentace";

$Lang{No} = "ne";
$Lang{Yes} = "ano";

$Lang{The_directory_is_empty} = <<EOF;
<tr><td bgcolor="#ffffff">Adresáø \$dirDisplay je prázdnı
</td></tr>
EOF

#$Lang{on} = "zapnout";
$Lang{off} = "vypnout";

$Lang{backupType_full}    = "plnı";
$Lang{backupType_incr}    = "inkr";
$Lang{backupType_active}  = "active";
$Lang{backupType_partial} = "èásteènı";

$Lang{failed} = "neúspìšnı";
$Lang{success} = "úspìšnı";
$Lang{and} = "a";

# ------
# Hosts states and reasons
$Lang{Status_idle} = "neèinnı";
$Lang{Status_backup_starting} = "záloha se spouští";
$Lang{Status_backup_in_progress} = "záloha probíhá";
$Lang{Status_restore_starting} = "obnovení se spouští";
$Lang{Status_restore_in_progress} = "obnovení probíhá";
$Lang{Status_admin_pending} = "link èeká";
$Lang{Status_admin_running} = "link bìí";

$Lang{Reason_backup_done}    = "hotovo";
$Lang{Reason_restore_done}   = "obnovení dokonèeno";
$Lang{Reason_archive_done}   = "archivace dokonèena";
$Lang{Reason_nothing_to_do}  = "neèinnı";
$Lang{Reason_backup_failed}  = "zálohování selhalo";
$Lang{Reason_restore_failed} = "obnovení selhalo";
$Lang{Reason_archive_failed} = "archivace selhala";
$Lang{Reason_no_ping}        = "ádnı ping";
$Lang{Reason_backup_canceled_by_user}  = "zálohování zrušeno uivatelem";
$Lang{Reason_restore_canceled_by_user} = "obnovení zrušeno uivatelem";
$Lang{Reason_archive_canceled_by_user} = "archivace zrušena uivatelem";
$Lang{Disabled_OnlyManualBackups}  = "automatické zálohování zakázáno";  
$Lang{Disabled_AllBackupsDisabled} = "zakázáno";                  


# ---------
# Email messages

# No backup ever
$Lang{EMailNoBackupEverSubj} = "BackupPC: adné zálohy hosta \$host se nezdaøili";
$Lang{EMailNoBackupEverMesg} = <<'EOF';
To: $user$domain
cc:
Pøedmìt: $subj
$headers
Dear $userName,

Vaše PC ($host) nebylo nikdy úspìšnì zálohováno naším
zálohovacím softwarem.  Zálohování PC by mìlo bıt spuštìno 
automaticky, kdy je Vaše PC pøipojeno do sítì. Mel by jste
kontaktovat Vaši podporu pokud:

  - Vaše PC bylo pravidelnì pøipojováno do sítì, zøejmì
    je nìjakı probém v nastavení nebo konfiguraci, kterı zabraòuje
    zálohování.

  - Nechcete Vaše PC zálohovat a chcete pøestat dostávat tyto zprávy.

Ujistìte se, e je Vaše PC pøipojeno do sítì, a budete pøíštì v kanceláøi.

S pozdravem,
BackupPC Genie
http://backuppc.sourceforge.net
EOF

# No recent backup
$Lang{EMailNoBackupRecentSubj} = "BackupPC: ádné nové zálohy pro \$host";
$Lang{EMailNoBackupRecentMesg} = <<'EOF';
To: $user$domain
cc:
Pøedmìt: $subj
$headers
Drahı $userName,

Vaše PC ($host) nebylo úspìšnì zálohovıno ji $days dní.
Vaše PC bylo korektnì zálohováno $numBackups krát od $firstTime 
do dne pøed $days dny.  Zálohování PC by se mìlo spustit automaticky,
kdy je Vaše PC pøipojeno do sítì.

Pokud bylo Vaše PC pøipojeno do sítì více ne nìkolik hodin v prùbìhu
posledních $days dní, mìl by jste kontaktovat Vaši podporu k zjištìní,
proè zálohování nefunguje.

Pokud jste mimo kanceláø, nemùete udìlat nic jiného ne zkopírovat kritické
soubory na jiná media. Mìl by jste mít na pamìti, e všechny soubory vytvoøené
nebo zmìnìné v posledních $days dnech (i s všemi novımi emaily a pøílohami) 
nebudou moci bıti obnoveny, pokud se disk ve Vašem poèítaèi poškodí.

S pozdravem,
BackupPC Genie
http://backuppc.sourceforge.net
EOF

# Old Outlook files
$Lang{EMailOutlookBackupSubj} = "BackupPC: Soubory programu Outlook na \$host je nutné zálohovat";
$Lang{EMailOutlookBackupMesg} = <<'EOF';
To: $user$domain
cc:
Pøedmìt: $subj
$headers
Drahı $userName,

Soubory programu Outlook na Vašem PC mají $howLong.
Tyto soubory obsahují všechny Vaše emaily, pøílohy, kontakty a informace v           
kalendáøi.  Vaše PC bylo naposled korektnì zálohováno $numBackups krát od
$firstTime do $lastTime. Nicménì Outlook zamkne všechny svoje soubory kdy
je spuštìn a znemoòuje jejich zálohování.

Doporuèujeme Vám zálohovat soubory Outlooku, kdy jste pøipojen do sítì tak,
e ukonèíte program Outlook a všechny ostatní aplikace a ve vašem prohlíeèi
otevøete tuto adresu:

    $CgiURL?host=$host               

Vyberte "Spustit inkrementaèní zálohování" dvakrát ke spuštení nového 
zálohování. Mùete vybrat "Návrat na $host page" a poté stiknout "obnovit"
ke zjištìní stavu zálohování. Dokonèení mùe trvat nìkolik minut.

S pozdravem,
BackupPC Genie
http://backuppc.sourceforge.net
EOF

$Lang{howLong_not_been_backed_up} = "nebylo zálohováno úspìšnì";
$Lang{howLong_not_been_backed_up_for_days_days} = "nebylo zálohováno \$days dní";

#######################################################################
# RSS strings
#######################################################################
$Lang{RSS_Doc_Title}       = "BackupPC Server";
$Lang{RSS_Doc_Description} = "RSS kanál BackupPC";
$Lang{RSS_Host_Summary}    = <<EOF;
Poèet plnıch: \$fullCnt;
Èas plnıch/dní: \$fullAge;
Celková velikost/GiB: \$fullSize;
Rychlost MB/sec: \$fullRate;
Poèet inkr: \$incrCnt;
Èas inkr/Dní: \$incrAge;
Stav: \$host_state;
Poslední pokus: \$host_last_attempt;
EOF

#######################################################################
# Configuration editor strings
#######################################################################

$Lang{Only_privileged_users_can_edit_config_files} = "Pouze oprávnìní uivatelé mohou editovat konfikuraci.";
$Lang{CfgEdit_Edit_Config} = "Editovat konfiguraci";
$Lang{CfgEdit_Edit_Hosts}  = "Editovat Hosty";

$Lang{CfgEdit_Title_Server} = "Server";
$Lang{CfgEdit_Title_General_Parameters} = "Hlavní parametry";
$Lang{CfgEdit_Title_Wakeup_Schedule} = "Plán probuzení";
$Lang{CfgEdit_Title_Concurrent_Jobs} = "Rovnocenné úlohy";
$Lang{CfgEdit_Title_Pool_Filesystem_Limits} = "Limity úloištì";
$Lang{CfgEdit_Title_Other_Parameters} = "Ostatní paramtery";
$Lang{CfgEdit_Title_Remote_Apache_Settings} = "Vzdálené nastavení Apache";
$Lang{CfgEdit_Title_Program_Paths} = "Cesty programu";
$Lang{CfgEdit_Title_Install_Paths} = "Instalaèní cesty";
$Lang{CfgEdit_Title_Email} = "Email";
$Lang{CfgEdit_Title_Email_settings} = "Nastavení emailu";
$Lang{CfgEdit_Title_Email_User_Messages} = "Nastavení emailu uivatelùm";
$Lang{CfgEdit_Title_CGI} = "CGI";
$Lang{CfgEdit_Title_Admin_Privileges} = "Administraèní práva";
$Lang{CfgEdit_Title_Page_Rendering} = "Renderování stránky";
$Lang{CfgEdit_Title_Paths} = "Cesty";
$Lang{CfgEdit_Title_User_URLs} = "Uivatelské URL";
$Lang{CfgEdit_Title_User_Config_Editing} = "Editace konfigurace uivatelù";
$Lang{CfgEdit_Title_Xfer} = "Xfer";
$Lang{CfgEdit_Title_Xfer_Settings} = "Nastavení Xfer";
$Lang{CfgEdit_Title_Ftp_Settings} = "Nastavení FTP";
$Lang{CfgEdit_Title_Smb_Settings} = "Nastavení Smb";
$Lang{CfgEdit_Title_Tar_Settings} = "Nastavení Tar";
$Lang{CfgEdit_Title_Rsync_Settings} = "Nastavení Rsync";
$Lang{CfgEdit_Title_Rsyncd_Settings} = "Nastavení Rsyncd";
$Lang{CfgEdit_Title_Archive_Settings} = "Nastavení Archivace";
$Lang{CfgEdit_Title_Include_Exclude} = "Zahrnout/Vylouèit";
$Lang{CfgEdit_Title_Smb_Paths_Commands} = "Smb Cesty/Pøíkazy";
$Lang{CfgEdit_Title_Tar_Paths_Commands} = "Tar Cesty/Pøíkazy";
$Lang{CfgEdit_Title_Rsync_Paths_Commands_Args} = "Rsync  Cesty/Pøíkazy/Argumenty";
$Lang{CfgEdit_Title_Rsyncd_Port_Args} = "Rsyncd Port/Argumenty";
$Lang{CfgEdit_Title_Archive_Paths_Commands} = "Archivace Cesty/Pøíkazy";
$Lang{CfgEdit_Title_Schedule} = "Plán";
$Lang{CfgEdit_Title_Full_Backups} = "Plné zálohy";
$Lang{CfgEdit_Title_Incremental_Backups} = "Inkrementaèní zálohy";
$Lang{CfgEdit_Title_Blackouts} = "Pøetíení";
$Lang{CfgEdit_Title_Other} = "Ostatní";
$Lang{CfgEdit_Title_Backup_Settings} = "Nastavení zálohování";
$Lang{CfgEdit_Title_Client_Lookup} = "Vyhledávání klientùp";
$Lang{CfgEdit_Title_User_Commands} = "Uivatelské pøíkazy";
$Lang{CfgEdit_Title_Hosts} = "Hosti";

$Lang{CfgEdit_Hosts_Comment} = <<EOF;
K pøidání nového hosta, vyberte Pøidat a zadejte jméno. Pro
konfiguraci hosta z jiného hosta, zadejte jméno hosta jako
NEWHOST=COPYHOST. To pøepíše existující konfiguraci pro NEWHOST.  
Tento postup mùete pouít i pto existujícího hosta.
Hosta smaete stisknutím tlaèítka delete. Pøidání, smazání a kopírování
konfigurace nanabude platnosti dokud nedojde k stisknutí tlaèítka Uloit 
ádná ze záloh smazanıch hostù nebude odstranìna, tedy pokud omylem
so if you accidently delete a host, simply re-add it.  To completely
smaete hostovy zálohy, musíte ruènì smazat soubory v \$topDir/pc/HOST
EOF

$Lang{CfgEdit_Header_Main} = <<EOF;
\${h1("Hlavní editor konfigurace")}
EOF

$Lang{CfgEdit_Header_Host} = <<EOF;
\${h1("Editor konfigurace hosta \$host")}
<p>
Poznámka: oznaète Pøepsat, pokud chcete modifikovat hodnotu
specifickou pro tohoto hosta.
<p>
EOF

$Lang{CfgEdit_Button_Save}     = "Uloit";
$Lang{CfgEdit_Button_Insert}   = "Vloit";
$Lang{CfgEdit_Button_Delete}   = "Smazat";
$Lang{CfgEdit_Button_Add}      = "Pøidat";
$Lang{CfgEdit_Button_Override} = "Pøepsat";
$Lang{CfgEdit_Button_New_Key}  = "Novı klíè";

$Lang{CfgEdit_Error_No_Save}
            = "Chyba: Neuloeno z dùvody chyb";
$Lang{CfgEdit_Error__must_be_an_integer}
            = "Chyba: \$var musí bıt celé èíslo";
$Lang{CfgEdit_Error__must_be_real_valued_number}
            = "Chyba: \$var musí bıt reálné èíslo";
$Lang{CfgEdit_Error__entry__must_be_an_integer}
            = "Chyba: vstup \$var \$k musí bıt celé èíslo";
$Lang{CfgEdit_Error__entry__must_be_real_valued_number}
            = "Chyba: vstup \$var \$k musí bıt reálné èíslo";
$Lang{CfgEdit_Error__must_be_executable_program}
            = "Chyba: \$var musí bıt správná cesta";
$Lang{CfgEdit_Error__must_be_valid_option}
            = "Chyba: \$var musí bıt správná monost";
$Lang{CfgEdit_Error_Copy_host_does_not_exist}
            = "Kopie hosta \$copyHost neexistuje; vytváøím novı název hosta \$fullHost. Smate tohota hosta, pokud to není to, co jste chtìl.";

$Lang{CfgEdit_Log_Copy_host_config}
            = "\$User zkopíroval konfiguraci z hosta \$fromHost do \$host\n";
$Lang{CfgEdit_Log_Delete_param}
            = "\$User smazal \$p z \$conf\n";
$Lang{CfgEdit_Log_Add_param_value}
            = "\$User pøidal \$p do \$conf, nastavil na \$value\n";
$Lang{CfgEdit_Log_Change_param_value}
            = "\$User zmìnil \$p v \$conf do \$valueNew z \$valueOld\n";
$Lang{CfgEdit_Log_Host_Delete}
            = "\$User smazal hosta \$host\n";
$Lang{CfgEdit_Log_Host_Change}
            = "\$User host \$host zmìnil \$key z \$valueOld na \$valueNew\n";
$Lang{CfgEdit_Log_Host_Add}
            = "\$User pøidal host \$host: \$value\n";
  
#end of lang_cz.pm
