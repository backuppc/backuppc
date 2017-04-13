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
$Lang{Stop_Dequeue_Archive} = "Ukon�it/Odstranit z Fronty Archivaci";
$Lang{Start_Full_Backup} = "Spustit �pln� Z�lohov�n�";
$Lang{Start_Incr_Backup} = "Spustit Inkremeta�n� Z�lohov�n�";
$Lang{Stop_Dequeue_Backup} = "Ukon�it/Odstranit z Fronty Z�lohov�n�";
$Lang{Restore} = "Obnovit";
$Lang{Type_full} = "�pln�";
$Lang{Type_incr} = "inkrementa�n�";

# -----

$Lang{Only_privileged_users_can_view_admin_options} = "Pouze opr�vn�n� u�ivatel� maj� p��stup k administra�n�mu nastaven�.";
$Lang{H_Admin_Options} = "BackupPC Server: Administra�n� nastaven�";
$Lang{Admin_Options} = "Administra�n� nastaven�";
$Lang{Admin_Options_Page} = <<EOF;
\${h1(qq{$Lang{Admin_Options}})}
<br>
\${h2("Kontrola Serveru")}
<form name="ReloadForm" action="\$MyURL" method="get">
<input type="hidden" name="action" value="">
<table class="tableStnd">
  <tr><td>Znovu nahr�t konfiguraci serveru:<td><input type="button" value="Reload"
     onClick="document.ReloadForm.action.value='Reload';
              document.ReloadForm.submit();">
</table>
</form>
<!--
\${h2("Konfigurace serveru")}
<ul>
  <li><i>Jin� nastaven� mohou b�t zde ... nap�,</i>
  <li>Editace konfigurace serveru
</ul>
-->
EOF

$Lang{Unable_to_connect_to_BackupPC_server} = "Nen� mo�n� se p�ipojit k BackupPC serveru";
$Lang{Unable_to_connect_to_BackupPC_server_error_message} = <<EOF;
Tento CGI skript (\$MyURL) se nen� schopn� p�ipojit k BackupPC
server na \$Conf{ServerHost} port \$Conf{ServerPort}.<br>
Chyba: \$err.<br>
Je mo�n�, �e BackupPC server nen� spu�t�n nebo je chyba v konfiguraci.
Pros�m oznamte to syst�mov�mu administr�torovi.
EOF

$Lang{Admin_Start_Server} = <<EOF;
\${h1(qq{$Lang{Unable_to_connect_to_BackupPC_server}})}
<form action="\$MyURL" method="get">
BackupPC server na <tt>\$Conf{ServerHost}</tt> port <tt>\$Conf{ServerPort}</tt>
nen� moment�ln� spu�t�n (mo�n� jste ho ukon�il nebo je�t� nespustil).<br>
Chceste ho spustit?
<input type="hidden" name="action" value="startServer">
<input type="submit" value="Spustit Server" name="ignore">
</form>
EOF

# -----

$Lang{H_BackupPC_Server_Status} = "Status Serveru BackupPC";

$Lang{BackupPC_Server_Status_General_Info}= <<EOF;
\${h2(\"Obecn� Informace o Serveru\")}

<ul>
<li> PID serveru je \$Info{pid},  na hostu \$Conf{ServerHost},
     verze \$Info{Version}, spu�t�n� \$serverStartTime.
<li> Vygenerov�n� stavu : \$now.
<li> Nahr�n� konfigurace : \$configLoadTime.
<li> PC bude p��t� ve front� : \$nextWakeupTime.
<li> Dal�� informace:
    <ul>
        <li>\$numBgQueue nevy��zen�ch ��dost� o z�lohu z posledn�ho napl�novan� probuzen�,
        <li>\$numUserQueue nevy��zen�ch ��dost� o z�lohu od u�ivatel�,
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
\${h2("Prob�haj�c� �lohy")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td> Host </td>
    <td> Typ </td>
    <td> U�ivatel </td>
    <td> Spu�t�no </td>
    <td> P��kaz </td>
    <td align="center"> PID </td>
    <td align="center"> Xfer PID </td>
    <td align="center"> Status </td>
    <td align="center"> Count </td>
    </tr>
\$jobStr
</table>

<p>
\$generalInfo

\${h2("Selh�n�, kter� vy�aduj� pozornost")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> Host </td>
    <td align="center"> Typ </td>
    <td align="center"> U�ivatel </td>
    <td align="center"> Posledn� pokus </td>
    <td align="center"> Detaily </td>
    <td align="center"> �as chyby </td>
    <td> Posledn� chyba (jin� ne� ��dn� ping) </td></tr>
\$statusStr
</table>
EOF

# --------------------------------
$Lang{BackupPC__Server_Summary} = "BackupPC: V�pis Host�";
$Lang{BackupPC__Archive} = "BackupPC: Archiv";
$Lang{BackupPC_Summary} = <<EOF;

\${h1(qq{$Lang{BackupPC__Server_Summary}})}
<p>
<ul>
<li>Tento stav byl vygenerov�n v \$now.
<li>Stav �lo�i�t� je \$Info{DUlastValue}%
    (\$DUlastTime), dne�n� maximum je \$Info{DUDailyMax}% (\$DUmaxTime)
        a v�erej�� maximum bylo \$Info{DUDailyMaxPrev}%.
</ul>
</p>

\${h2("Host� s �sp�n� proveden�mi z�lohami")}
<p>
\$hostCntGood host� bylo �sp�n� z�lohov�no, v celkov� velikost:
<ul>
<li> \$fullTot �pln�ch z�loh v celkov� velitosti \${fullSizeTot}GiB
     (p�ed kompres�),
<li> \$incrTot inkementa�n�ch z�loh v celkov� velikosti \${incrSizeTot}GiB
     (p�ed kompres�).
</ul>
</p>
<table class="sortable" id="host_summary_backups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> Host </td>
    <td align="center"> U�ivatel </td>
    <td align="center"> #Pln� </td>
    <td align="center"> Pln� �as (dn�) </td>
    <td align="center"> Pln� Velikost (GiB) </td>
    <td align="center"> Rychlost (MB/s) </td>
    <td align="center"> #Inkr </td>
    <td align="center"> Inkr �as (dn�) </td>
    <td align="center"> Posledn� Z�loha (dn�) </td>
    <td align="center"> Stav </td>
    <td align="center"> #Xfer chyb </td>
    <td align="center"> Posledn� pokus </td></tr>
\$strGood
</table>
\${h2("Host� s ��dn�mi proveden�mi z�lohami")}
<p>
\$hostCntNone host� s ��dn�mi z�lohani.
<p>
<table class="sortable" id="host_summary_nobackups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> Host </td>
    <td align="center"> U�ivatel </td>
    <td align="center"> #Pln� </td>
    <td align="center"> Pln� �as (dn�) </td>
    <td align="center"> Pln� Velikost (GiB) </td>
    <td align="center"> Rychlost (MB/s) </td>
    <td align="center"> #Inkr </td>
    <td align="center"> Inkr �as (dn�) </td>
    <td align="center"> Posledn� Z�loha (dn�) </td>
    <td align="center"> Stav </td>
    <td align="center"> #Xfer chyb </td>
    <td align="center"> Posledn� pokus </td></tr>
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

\$hostCntGood host�, kte�� byli z�lohov�ni v celkov� velikosti \${fullSizeTot}GiB
<p>
<form name="form1" method="post" action="\$MyURL">
<input type="hidden" name="fcbMax" value="\$checkBoxCnt">
<input type="hidden" name="type" value="1">
<input type="hidden" name="host" value="\${EscHTML(\$archHost)}">
<input type="hidden" name="action" value="Archive">
<table class="tableStnd" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td align=center> Host</td>
    <td align="center"> U�ivatel </td>
    <td align="center"> Velikost z�lohy </td>
\$strGood
\$checkAllHosts
</table>
</form>
<p>

EOF

$Lang{BackupPC_Archive2} = <<EOF;
\${h1(qq{$Lang{BackupPC__Archive}})}
Nasleduj�c� host� se chystaj� k archivaci
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
    <td>Um�st�n� Archivu</td>
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
    <td>Procent paritn�ch dat (0 = vypnut�, 5 = typick�)</td>
    <td><input type="numeric" value="\$ArchivePar" name="par"></td>
</tr>
EOF

$Lang{BackupPC_Archive2_split} = <<EOF;
<tr>
    <td>Rozd�lit v�stup na</td>
    <td><input type="numeric" value="\$ArchiveSplit" name="splitsize">Megabytes</td>
</tr>
EOF

# -----------------------------------
$Lang{Pool_Stat} = <<EOF;
        <li>V �lo�i�ti je \${poolSize}GiB zahrnuj�c \$info->{"\${name}FileCnt"} soubor�
            a \$info->{"\${name}DirCnt"} adres��� (od \$poolTime),
        <li>Hashov�n� �lo�i�t� d�v� \$info->{"\${name}FileCntRep"} opakuj�c�ch se
        soubor� s nejdel��m �et�zem \$info->{"\${name}FileRepMax"},
        <li>No�n� �klid �lo�i�t� odstranil \$info->{"\${name}FileCntRm"} soubor�
            velikosti \${poolRmSize}GiB (kolem \$poolTime),
EOF

# --------------------------------
$Lang{BackupPC__Backup_Requested_on__host} = "BackupPC:  Z�loha vy��d�na na \$host";
# --------------------------------
$Lang{REPLY_FROM_SERVER} = <<EOF;
\${h1(\$str)}
<p>
Odpov�� serveru na: \$reply
<p>
Vra� se na <a href="\$MyURL?host=\$host">domovskou str�nku \$host</a>.
EOF
# --------------------------------
$Lang{BackupPC__Start_Backup_Confirm_on__host} = "BackupPC: Za��tek z�lohy potvrzen na \$host";
# --------------------------------
$Lang{Are_you_sure_start} = <<EOF;
\${h1("Are you sure?")}
<p>
Chyst�te se spustit \$type z�lohu na \$host.

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="hostIP" value="\$ipAddr">
<input type="hidden" name="doit" value="1">
<input type="hidden" name="action" value="">
Opravdu to chcete prov�st?
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="No" name="ignore">
</form>
EOF
# --------------------------------
$Lang{BackupPC__Stop_Backup_Confirm_on__host} = "BackupPC: Ukon�it potvrzen� kopie na \$host";
# --------------------------------
$Lang{Are_you_sure_stop} = <<EOF;

\${h1("Jste si jist�?")}

<p>
Chyst�te se ukon�it/vy�adit z fronty z�lohov�n� na \$host;

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host"   value="\$host">
<input type="hidden" name="doit"   value="1">
<input type="hidden" name="action" value="">
Pros�m, neza��nejte jin� z�lohov�n�
<input type="text" name="backoff" size="10" value="\$backoff"> hodin.
<p>
Opravdu to chcete prov�st?
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="No" name="ignore">
</form>

EOF
# --------------------------------
$Lang{Only_privileged_users_can_view_queues_} = "Pouze opr�vn�n� u�ivatel� maj� p�istup k front�m.";
# --------------------------------
$Lang{Only_privileged_users_can_archive} = "Pouze opr�vn�n� u�ivatel� mohou archivovat.";
# --------------------------------
$Lang{BackupPC__Queue_Summary} = "BackupPC: P�ehled front";
# --------------------------------
$Lang{Backup_Queue_Summary} = <<EOF;
\${h1("P�ehled fronty z�lohov�n�")}
<br><br>
\${h2("P�ehled fronty u�ivatel�")}
<p>
N�sleduj�c� u�ivatel� jsou moment�ln� ve front�:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Host </td>
    <td> �as do </td>
    <td> U�ivatel </td></tr>
\$strUser
</table>
<br><br>

\${h2("Souhrn fronty v pozad�")}
<p>
N�sleduj�c� ��dosti v pozad� jsou moment�ln� ve front�:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Host </td>
    <td> �as do </td>
    <td> U�ivatel </td></tr>
\$strBg
</table>
<br><br>
\${h2("Souhrn fronty p��kaz�")}
<p>
N�sleduj�c� p��kazy jsou moment�ln� ve front�:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Host </td>
    <td> �as do </td>
    <td> U�ivatel </td>
    <td> P��kaz </td></tr>
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
Obsah souboru <tt>\$file</tt>, modifikov�n \$mtimeStr \$comment
EOF

# --------------------------------
$Lang{skipped__skipped_lines} = "[ p�esko�eno \$skipped ��dk� ]\n";
# --------------------------------
$Lang{_pre___Can_t_open_log_file__file} = "<pre>\nNen� mo�n� otev��t log soubor \$file\n";

# --------------------------------
$Lang{BackupPC__Log_File_History} = "BackupPC: Historie Log Souboru";
$Lang{Log_File_History__hdr} = <<EOF;
\${h1("Historie Log Souboru \$hdr")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Soubor </td>
    <td align="center"> Velikost </td>
    <td align="center"> �as modifikace </td></tr>
\$str
</table>
EOF

# -------------------------------
$Lang{Recent_Email_Summary} = <<EOF;
\${h1("P�ehled ned�vn�ch email� (�azeno zp�tn�)")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> P��jemce </td>
    <td align="center"> Odes�latel </td>
    <td align="center"> �as </td>
    <td align="center"> P�edm�t </td></tr>
\$str
</table>
EOF
 

# ------------------------------
$Lang{Browse_backup__num_for__host} = "BackupPC: Prohl�et z�lohu \$num pro \$host";

# ------------------------------
$Lang{Restore_Options_for__host} = "BackupPC: Obnovit nastaven� pro \$host";
$Lang{Restore_Options_for__host2} = <<EOF;
\${h1("Obnovit nastaven� pro \$host")}
<p>
Vybral jste n�sleduj�c� soubory/adres��e z
��sti \$share, z�loha ��slo #\$num:
<ul>
\$fileListStr
</ul>
</p><p>
Pro obnoven� t�chto soubor�/adres��� m�te t�i mo�nosti.
Vyberte si, pros�m, jednu z n�sleduj�c�ch mo�nost�.
</p>
\${h2("Mo�nost 1: P��m� obnova")}
<p>
EOF

$Lang{Restore_Options_for__host_Option1} = <<EOF;
M��ete spustit obnoven� t�chto soubor� do
<b>\$directHost</b>.
</p><p>
<b>Varov�n�:</b> jak�koliv existuj�c� soubor, kter� odpov�da t�m,
kter� m�te vybr�ny bude smaz�n!
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
	 <!--<a href="javascript:myOpen('\$MyURL?action=findShares&host='+document.direct.hostDest.options.value)">Hledej dostupn� ��sti (NEN� IMPLEMENTOV�NO)</a>--></td>
</tr><tr>
    <td>Obnoven� soubor� do ��sti</td>
    <td><input type="text" size="40" value="\${EscHTML(\$share)}"
	 name="shareDest"></td>
</tr><tr>
    <td>Obnovit soubory v adres��i<br>(vztahuj�c� se k ��sti)</td>
    <td valign="top"><input type="text" size="40" maxlength="256"
	value="\${EscHTML(\$pathHdr)}" name="pathHdr"></td>
</tr><tr>
    <td><input type="submit" value="Start Restore" name="ignore"></td>
</table>
</form>
EOF

$Lang{Restore_Options_for__host_Option1_disabled} = <<EOF;
P��m� obnoven� bylo zak�z�no pro hosta \${EscHTML(\$hostDest)}.
Vyberte si, pros�m, jednu z mo�nost� obnovy.
EOF

# ------------------------------
$Lang{Option_2__Download_Zip_archive} = <<EOF;
<p>
\${h2("Mo�nost 2: St�hnout Zip archiv")}
<p>
M��ete st�hnout Zip archiv obsahuj�c� v�echny soubory/adres��e, kter�
jste vybral.  Pot� m��ete pou��t aplikaci, nap�. WinZip, k zobrazen�
nebp rozbalen� n�kter�ho z t�chto soubor�.
</p><p>
<b>Varov�n�:</b> v z�vislosti na tom, kter� soubory/adres��e jste vybral,
tento archiv m��e b�t velmi velk�.  Vytvo�en� a p�enos archivu m��e trvat
minuty, a budete pot�ebovat dostatek m�sta na lok�ln�m disku.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="2">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Vytvo�it archiv relativn�
k \${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(jinak bude archiv obsahovat plnou cestu).
<br>
<table class="tableStnd" border="0">
<tr>
    <td>Komprese (0=off, 1=rychl�,...,9=nejlep��)</td>
    <td><input type="text" size="6" value="5" name="compressLevel"></td>
</tr><tr>
    <td>Code page (e.g. cp866)</td>
    <td><input type="text" size="6" value="utf8" name="codePage"></td>
</tr>
</table>
<br>
<input type="submit" value="St�hnout Zip soubor" name="ignore">
</form>
EOF

# ------------------------------

$Lang{Option_2__Download_Zip_archive2} = <<EOF;
<p>
\${h2("Mo�nost 2: St�nout Zip archiv")}
<p>
Archive::Zip nen� nainstalov�n, �ili nebude mo�n� st�hnout
zip archiv.
Po��dejte syst�mov�ho administr�tora o instalaci Archive::Zip z
<a href="http://www.cpan.org">www.cpan.org</a>.
</p>
EOF


# ------------------------------
$Lang{Option_3__Download_Zip_archive} = <<EOF;
\${h2("Mo�nost 3: St�hnout Tar archiv")}
<p>
M��ete st�hnout Tar archiv obsahuj�c� v�echny soubory/adres��e, kter�
jste vybral.  Pot� m��ete pou��t aplikaci, nap�. tar nebo WinZip, k zobrazen�
nebp rozbalen� n�kter�ho z t�chto soubor�.
</p><p>
<b>Varov�n�:</b> v z�vislosti na tom, kter� soubory/adres��e jste vybral,
tento archiv m��e b�t velmi velk�.  Vytvo�en� a p�enos archivu m��e trvat
minuty, a budete pot�ebovat dostatek m�sta na lok�ln�m disku.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="1">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Vytvo� archiv relativn�
k \${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(jinak bude archiv obsahovat plnou cestu).
<br>
<input type="submit" value="St�nout Tar soubor" name="ignore">
</form>
EOF


# ------------------------------
$Lang{Restore_Confirm_on__host} = "BackupPC: Potvrzen� obnoven� na \$host";

$Lang{Are_you_sure} = <<EOF;
\${h1("Jsi si jist�?")}
<p>
Chyst�te se zah�jit obnovu p��mo do po��ta�e \$In{hostDest}.
N�sleduj�c� soubory budou obnoveny do ��sti \$In{shareDest}, ze
z�lohy ��slo \$num:
<p>
<table class="tableStnd" border>
<tr class="tableheader"><td>Origin�ln� soubor/adres��</td><td>Bude obnoven do</td></tr>
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
Obravdu to chce� prov�st?
<input type="button" value="\$Lang->{Restore}"
 onClick="document.RestoreForm.action.value='Restore';
          document.RestoreForm.submit();">
<input type="submit" value="No" name="ignore">
</form>
EOF


# --------------------------
$Lang{Restore_Requested_on__hostDest} = "BackupPC: Obnovit vy��dan� na \$hostDest";
$Lang{Reply_from_server_was___reply} = <<EOF;
\${h1(\$str)}
<p>
Odpov�� od serveru: \$reply
<p>
J�t zp�t na <a href="\$MyURL?host=\$hostDest">domovsk� str�nka \$hostDest</a>.
EOF

$Lang{BackupPC_Archive_Reply_from_server} = <<EOF;
\${h1(\$str)}
<p>
Odpov�� od serveru: \$reply
EOF


# -------------------------
$Lang{Host__host_Backup_Summary} = "BackupPC: P�ehled z�loh hosta \$host";

$Lang{Host__host_Backup_Summary2} = <<EOF;
\${h1("P�ehled z�loh hosta \$host")}
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
\${h2("P�ehled z�loh")}
<p>
Klikn�te na ��slo z�lohy pro prohl�en� a obnoven� z�lohy.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> Backup# </td>
    <td align="center"> Typ </td>
    <td align="center"> Vypln�no </td>
    <td align="center"> �rove� </td>
    <td align="center"> Datum spu�t�n� </td>
    <td align="center"> Doba trv�n�/minuty </td>
    <td align="center"> Doba/dny </td>
    <td align="center"> Cesta serveru z�lohy </td>
</tr>
\$str
</table>
<p>

\$restoreStr
</p>
\${h2("P�ehled Xfer chyb")}
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Backup# </td>
    <td align="center"> Typ </td>
    <td align="center"> Pohled </td>
    <td align="center"> #Xfer chyby </td>
    <td align="center"> #�patn� soubory </td>
    <td align="center"> #�patn� ��sti </td>
    <td align="center"> #tar chyby </td>
</tr>
\$errStr
</table>

\${h2("File Size/Count Reuse Summary")}
<p>
Existuj�c� soubory jsou ty, kter� jsou ji� v �lo�i�ti; nov� jsou p�idan�
do �lo�i�t�.
Pr�zn� soubory a SMB chyby nejsou po��t�ny.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="2" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> Celkov� </td>
    <td align="center" colspan="2"> Existuj�c� soubory </td>
    <td align="center" colspan="2"> Nov� soubory </td>
</tr>
<tr class="tableheader">
    <td align="center"> Z�loha # </td>
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

\${h2("P�ehled kompres�")}
<p>
V�kon komprese pro soubory, kter� jsou ji� v �lo�i�ti a pro nov�
zkomprimovan� soubory.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="3" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> Existuj�c� soubory </td>
    <td align="center" colspan="3"> Nov� soubory </td>
</tr>
<tr class="tableheader"><td align="center"> Z�loha # </td>
    <td align="center"> Typ </td>
    <td align="center"> �rove� komprese </td>
    <td align="center"> Velikost/MB </td>
    <td align="center"> Komprese/MB </td>
    <td align="center"> Komprese </td>
    <td align="center"> Velikost/MB </td>
    <td align="center"> Komprese/MB </td>
    <td align="center"> Komprese </td>
</tr>
\$compStr
</table>
EOF

$Lang{Host__host_Archive_Summary} = "BackupPC: P�ehled archiv� hosta \$host ";
$Lang{Host__host_Archive_Summary2} = <<EOF;
\${h1("P�ehled archiv� hosta \$host")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>

\${h2("U�ivatelsk� akce")}
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
\${h1("Prohl�en� z�loh pro \$host")}

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
<li> Prohl��te z�lohu #\$num, kter� byla spu�t�na kolem \$backupTime
        (\$backupAge dn� zp�t),
\$filledBackup
<li> Zadej adres��: <input type="text" name="dir" size="50" maxlength="4096" value="\${EscHTML(\$dir)}"> <input type="submit" value="\$Lang->{Go}" name="Submit">
<li> Klikni na adres�� n�e a pokra�uj do n�j,
<li> Klikni na soubor n�e a obnov ho,
<li> M��e� vid�t z�lohu <a href="\$MyURL?action=dirHistory&host=\${EscURI(\$host)}&share=\$shareURI&dir=\$pathURI">history</a> aktu�ln�ho adres��e.
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
$Lang{DirHistory_backup_for__host} = "BackupPC: Historie z�loh adres��� pro \$host";

#
# These two strings are used to build the links for directories and
# file versions.  Files are appended with a version number.
#
$Lang{DirHistory_dirLink}  = "adres";
$Lang{DirHistory_fileLink} = "v";

$Lang{DirHistory_for__host} = <<EOF;
\${h1("Historie z�loh adres��� pro \$host")}
<p>
Tato obrazovka zobrazuje ka�dou unik�tn� verzi souboru
ze v�ech z�loh:
<ul>
<li> Klikni na ��slo z�lohy k n�vratu do prohl�e�e z�loh,
<li> Klikni na odkaz adres��e (\$Lang->{DirHistory_dirLink}) k p�echodu do
     n�j,
<li> Klikni na odkaz verze souboru (\$Lang->{DirHistory_fileLink}0,
     \$Lang->{DirHistory_fileLink}1, ...) k jeho sta�en�,
<li> Soubory se stejn�m obsahem v r�zn�ch z�loh�ch maj� stejn�
     ��slo verze,
<li> Soubory nebo adres��e, kter� nejsou ve vybran� z�loze 
     nejsou ozna�eny.
<li> Soubory zobrazen� se stejn�m ��slem verze mohou m�t rozd�ln� atributy.
     Vyber ��slo z�lohy k zobrazen� atribut� souboru.
</ul>

\${h2("Historie \$dirDisplay")}

<br>
<table border cellspacing="2" cellpadding="3">
<tr class="fviewheader"><td>��slo z�lohy</td>\$backupNumStr</tr>
<tr class="fviewheader"><td>�as z�lohy</td>\$backupTimeStr</tr>
\$fileStr
</table>
EOF

# ------------------------------
$Lang{Restore___num_details_for__host} = "BackupPC: Obnovit #\$num detail� pro \$host";

$Lang{Restore___num_details_for__host2} = <<EOF;
\${h1("Obnovit #\$num Detail� pro \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="90%">
<tr><td class="tableheader"> ��slo </td><td class="border"> \$Restores[\$i]{num} </td></tr>
<tr><td class="tableheader"> Vy��dal </td><td class="border"> \$RestoreReq{user} </td></tr>
<tr><td class="tableheader"> �as vy��d�n� </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> V�sledek </td><td class="border"> \$Restores[\$i]{result} </td></tr>
<tr><td class="tableheader"> Chybov� zpr�va </td><td class="border"> \$Restores[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> Zdrojov� host </td><td class="border"> \$RestoreReq{hostSrc} </td></tr>
<tr><td class="tableheader"> ��slo zdrojov� z�lohy </td><td class="border"> \$RestoreReq{num} </td></tr>
<tr><td class="tableheader"> Zdrojov� ��st </td><td class="border"> \$RestoreReq{shareSrc} </td></tr>
<tr><td class="tableheader"> C�lov� host </td><td class="border"> \$RestoreReq{hostDest} </td></tr>
<tr><td class="tableheader"> C�lov� ��st </td><td class="border"> \$RestoreReq{shareDest} </td></tr>
<tr><td class="tableheader"> �as spu�t�n� </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Doba trv�n� </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> Po�et soubor� </td><td class="border"> \$Restores[\$i]{nFiles} </td></tr>
<tr><td class="tableheader"> Celkov� velikost </td><td class="border"> \${MB} MB </td></tr>
<tr><td class="tableheader"> P�enosov� rychlost </td><td class="border"> \$MBperSec MB/sec </td></tr>
<tr><td class="tableheader"> TarCreate chyb </td><td class="border"> \$Restores[\$i]{tarCreateErrs} </td></tr>
<tr><td class="tableheader"> Xfer chyb </td><td class="border"> \$Restores[\$i]{xferErrs} </td></tr>
<tr><td class="tableheader"> Xfer log soubor </td><td class="border">
<a href="\$MyURL?action=view&type=RestoreLOG&num=\$Restores[\$i]{num}&host=\$host">View</a>,
<a href="\$MyURL?action=view&type=RestoreErr&num=\$Restores[\$i]{num}&host=\$host">Errors</a>
</tr></tr>
</table>
</p>
\${h1("Seznam soubor�/adres���")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="100%">
<tr class="tableheader"><td>Origin�ln� soubor/adres��</td><td>Obnoven do</td></tr>
\$fileListStr
</table>
EOF

# ------------------------------
$Lang{Archive___num_details_for__host} = "BackupPC: Archivovat #\$num detail� pro \$host";

$Lang{Archive___num_details_for__host2 } = <<EOF;
\${h1("Archivovat #\$num Detail� pro \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr><td class="tableheader"> ��slo </td><td class="border"> \$Archives[\$i]{num} </td></tr>
<tr><td class="tableheader"> Vy��dal </td><td class="border"> \$ArchiveReq{user} </td></tr>
<tr><td class="tableheader"> �as vy��d�n� </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> Odpov�d </td><td class="border"> \$Archives[\$i]{result} </td></tr>
<tr><td class="tableheader"> Chybov� zpr�va </td><td class="border"> \$Archives[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> �as spust�n� </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Dpba trv�n� </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> Xfer log soubor </td><td class="border">
<a href="\$MyURL?action=view&type=ArchiveLOG&num=\$Archives[\$i]{num}&host=\$host">View</a>,
<a href="\$MyURL?action=view&type=ArchiveErr&num=\$Archives[\$i]{num}&host=\$host">Errors</a>
</tr></tr>
</table>
<p>
\${h1("Seznam host�")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td>Host</td><td>��slo kopie</td></tr>
\$HostListStr
</table>
EOF

# -----------------------------------
$Lang{Email_Summary} = "BackupPC: Souhrn email�";

# -----------------------------------
#  !! ERROR messages !!
# -----------------------------------
$Lang{BackupPC__Lib__new_failed__check_apache_error_log} = "BackupPC::Lib->new failed: zkontroluj apache error_log\n";
$Lang{Wrong_user__my_userid_is___} =  
              "�patn� u�ivatel: moje userid je \$>, m�sto \$uid"
            . "(\$Conf{BackupPCUser})\n";
# $Lang{Only_privileged_users_can_view_PC_summaries} = "Pouze opr�vn�n� u�ivatel� jsou opr�vn�ni prohl�et souhrny PC.";
$Lang{Only_privileged_users_can_stop_or_start_backups} = 
                  "Pouze opr�vn�n� u�ivatel� mohou ukon�it nebo spustit z�lohov�n� na"
		. " \${EscHTML(\$host)}.";
$Lang{Invalid_number__num} = "�patn� ��slo \${EscHTML(\$In{num})}";
$Lang{Unable_to_open__file__configuration_problem} = "Nepoda�ilo se otev��t \$file: probl�m konfigurace?";
$Lang{Only_privileged_users_can_view_log_or_config_files} = "Pouze opr�vn�n� u�ivatel� maj� p��stup k log a konfigura�n�m soubor�m.";
$Lang{Only_privileged_users_can_view_log_files} = "Pouze opr�vn�n� u�ivatel� maj� p��stup k log soubor�m.";
$Lang{Only_privileged_users_can_view_email_summaries} = "Pouze opr�vn�n� u�ivatel� maj� p��stup k souhrnu email�.";
$Lang{Only_privileged_users_can_browse_backup_files} = "Pouze opr�vn�n� u�ivatel� mohou prohl�et soubory z�loh"
                . " pro host \${EscHTML(\$In{host})}.";
$Lang{Empty_host_name} = "Pr�zdn� jm�no hosta.";
$Lang{Directory___EscHTML} = "Adres�� \${EscHTML(\"\$TopDir/pc/\$host/\$num\")}"
		    . " je pr�zdn�";
$Lang{Can_t_browse_bad_directory_name2} = "Nen� mo�n� prohl�et - �patn� n�zev adres��e"
	            . " \${EscHTML(\$relDir)}";
$Lang{Only_privileged_users_can_restore_backup_files} = "Pouze opr�vn�n� u�ivatel� mohou obnovovat soubory z�lohy"
                . " pro hosta \${EscHTML(\$In{host})}.";
$Lang{Bad_host_name} = "�patn� jm�no hosta \${EscHTML(\$host)}";
$Lang{You_haven_t_selected_any_files__please_go_Back_to} = "Nevybral jste ��dn� soubor; pros�m jd�te Zp�t k"
                . " v�b�ru soubor�.";
$Lang{You_haven_t_selected_any_hosts} = "Nevybral jste ��dn�ho hosta; pros�m jd�te Zp�t k"
                . " v�b�ru host�.";
$Lang{Nice_try__but_you_can_t_put} = "Nelze um�stit \'..\' do n�zvu souboru";
$Lang{Host__doesn_t_exist} = "Host \${EscHTML(\$In{hostDest})} neexistuje";
$Lang{You_don_t_have_permission_to_restore_onto_host} = "Nem�te opr�vn�n� k obnov� na"
		    . " \${EscHTML(\$In{hostDest})}";
$Lang{Can_t_open_create__openPath} = "Nelze otev��t nebo vytvo�it "
		. "\${EscHTML(\"\$openPath\")}";
$Lang{Only_privileged_users_can_restore_backup_files2} = "Pouze opr�vn�n� u�ivatel� mohou obnovovat soubory z�lohy"
                . " pro hosta \${EscHTML(\$host)}.";
$Lang{Empty_host_name} = "Pr�zdn� jm�no hosta";
$Lang{Unknown_host_or_user} = "Nezn�m� host nebo u�ivatel \${EscHTML(\$host)}";
$Lang{Only_privileged_users_can_view_information_about} = "Pouze opr�vn�n� u�ivatel� maj� p��stup k informac�m o"
                . " hostu \${EscHTML(\$host)}." ;
$Lang{Only_privileged_users_can_view_archive_information} = "Pouze opr�vn�n� u�ivatel� maj� p��stup k informac�m o archivaci.";
$Lang{Only_privileged_users_can_view_restore_information} = "Pouze opr�vn�n� u�ivatel� maj� p��stup k informac�m o obnov�.";
$Lang{Restore_number__num_for_host__does_not_exist} = "��slo obnoven� \$num pro hosta \${EscHTML(\$host)}"
	        . " neexsituje.";
$Lang{Archive_number__num_for_host__does_not_exist} = "��slo archivu \$num pro hosta \${EscHTML(\$host)}"
                . " neexsituje.";
$Lang{Can_t_find_IP_address_for} = "Nelze nal�zt IP adresu pro \${EscHTML(\$host)}";
$Lang{host_is_a_DHCP_host} = <<EOF;
\$host je DHCP host, and nen� zn�ma jeho IP adresa.  Zkontrolov�no
netbios jm�no \$ENV{REMOTE_ADDR}\$tryIP, a zji�t�no, �e za��zen� 
nen� \$host.
<p>
Dokud nebude vid�t \$host na vybran� DHCP adrese, m��ete pouze
spustit ��dost z p��mo klientsk�ho za��zen�.
EOF

# ------------------------------------
# !! Server Mesg !!
# ------------------------------------

$Lang{Backup_requested_on_DHCP__host} = "Z�loha vy��d�na z DHCP \$host (\$In{hostIP}) u�ivatelem"
		                      . " \$User z \$ENV{REMOTE_ADDR}";
$Lang{Backup_requested_on__host_by__User} = "Z�loha vy��d�na z \$host u�ivatelem \$User";
$Lang{Backup_stopped_dequeued_on__host_by__User} = "Z�loha ukon�ena/vy�azena z fronty z \$host u�ivatelem \$User";
$Lang{Restore_requested_to_host__hostDest__backup___num} = "Obnova vy��d�na na hosta \$hostDest, obnova #\$num,"
	     . " u�ivatelem \$User z \$ENV{REMOTE_ADDR}";
$Lang{Archive_requested} = "Archivace vy��d�na u�ivatelem \$User z \$ENV{REMOTE_ADDR}";

# -------------------------------------------------
# ------- Stuff that was forgotten ----------------
# -------------------------------------------------

$Lang{Status} = "Stav";
$Lang{PC_Summary} = "Souhrn host�";
$Lang{LOG_file} = "LOG soubor";
$Lang{LOG_files} = "LOG soubory";
$Lang{Old_LOGs} = "Star� LOGy";
$Lang{Email_summary} = "Souhrn email�";
$Lang{Config_file} = "Konfigura�n� soubor";
# $Lang{Hosts_file} = "Hosts soubor";
$Lang{Current_queues} = "Aktu�ln� fronty";
$Lang{Documentation} = "Dokumentace";

#$Lang{Host_or_User_name} = "<small>Jm�no u�ivatele nebo hosta:</small>";
$Lang{Go} = "Jdi";
$Lang{Hosts} = "Hosts";
$Lang{Select_a_host} = "Vyber hosta...";

$Lang{There_have_been_no_archives} = "<h2> Nebyli ��dn� archivy </h2>\n";
$Lang{This_PC_has_never_been_backed_up} = "<h2> Toto PC nebylo nikdy z�lohov�no!! </h2>\n";
$Lang{This_PC_is_used_by} = "<li>Toto PC je pou��v�no u�ivatelem \${UserLink(\$user)}";

$Lang{Extracting_only_Errors} = "(Rozbalov�n� chyb)";
$Lang{XferLOG} = "XferLOG";
$Lang{Errors}  = "Chyby";

# ------------
$Lang{Last_email_sent_to__was_at___subject} = <<EOF;
<li>Posledn� email odesl�n u�ivately \${UserLink(\$user)} byl v \$mailTime, p�edm�t "\$subj".
EOF
# ------------
$Lang{The_command_cmd_is_currently_running_for_started} = <<EOF;
<li>P��kaz \$cmd je aktu�ln� vykon�v�n pro \$host, spu�t�n v \$startTime.
EOF

# -----------
$Lang{Host_host_is_queued_on_the_background_queue_will_be_backed_up_soon} = <<EOF;
<li>Host \$host �ek� ve front� na pozad� (bude brzy z�lohov�n).
EOF

# ----------
$Lang{Host_host_is_queued_on_the_user_queue__will_be_backed_up_soon} = <<EOF;
<li>Host \$host �ek� ve front� u�ivatel� (bude brzy z�lohov�n).
EOF

# ---------
$Lang{A_command_for_host_is_on_the_command_queue_will_run_soon} = <<EOF;
<li>P��kaz pro \$host �ek� ve front� p��kaz� (bude brzy spu�t�n).
EOF

# --------
$Lang{Last_status_is_state_StatusHost_state_reason_as_of_startTime} = <<EOF;
<li>Posledn� stav \"\$Lang->{\$StatusHost{state}}\"\$reason v �ase \$startTime.
EOF

# --------
$Lang{Last_error_is____EscHTML_StatusHost_error} = <<EOF;
<li>Posledn� chyba je \"\${EscHTML(\$StatusHost{error})}\".
EOF

# ------
$Lang{Pings_to_host_have_failed_StatusHost_deadCnt__consecutive_times} = <<EOF;
<li>Pingy na \$host selhaly \$StatusHost{deadCnt} za sebou.
EOF

# -----
$Lang{Prior_to_that__pings} = "P�edchoz� pingy";

# -----
$Lang{priorStr_to_host_have_succeeded_StatusHostaliveCnt_consecutive_times} = <<EOF;
<li>\$priorStr na \$host byli �sp�n� \$StatusHost{aliveCnt}
         za sebou.
EOF

$Lang{Because__host_has_been_on_the_network_at_least__Conf_BlackoutGoodCnt_consecutive_times___} = <<EOF;
<li>Proto�e \$host byl na s�ti alespo� \$Conf{BlackoutGoodCnt}
za sebou, nebude z�lohov�n z \$blackoutStr.
EOF

$Lang{__time0_to__time1_on__days} = "\$t0 to \$t1 on \$days";

$Lang{Backups_are_deferred_for_hours_hours_change_this_number} = <<EOF;
<li>Z�lohy byli odlo�eny na \$hours hodin
(<a href=\"\$MyURL?action=Stop_Dequeue_Backup&host=\$host\">zm�n toto ��slo</a>).
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
    <tr class="fviewheader"><td align=center> Jm�no</td>
       <td align="center"> Typ</td>
       <td align="center"> M�d</td>
       <td align="center"> #</td>
       <td align="center"> Velikost</td>
       <td align="center"> Datum zm�ny</td>
    </tr>
EOF

$Lang{Home} = "Doma";
$Lang{Browse} = "Prohl�en� z�loh";
$Lang{Last_bad_XferLOG} = "Posledn� �patn� XferLOG";
$Lang{Last_bad_XferLOG_errors_only} = "Posledn� �patn� XferLOG (chyb&nbsp;pouze)";

$Lang{This_display_is_merged_with_backup} = <<EOF;
<li> Toto zobrazen� je slou�eno se z�lohou #\$numF.
EOF

$Lang{Visit_this_directory_in_backup} = <<EOF;
<li> Vyberte z�lohu, kterou si p�ejete zobrazit: <select onChange="window.location=this.value">\$otherDirs </select>
EOF

$Lang{Restore_Summary} = <<EOF;
\${h2("Obnovit souhrn")}
<p>
Klikni na obnoven� pro v�ce detail�.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Obnoven� # </td>
    <td align="center"> V�sledek </td>
    <td align="right"> Datum spu�ten�</td>
    <td align="right"> Doba trv�n�/minuty</td>
    <td align="right"> #soubor� </td>
    <td align="right"> MB </td>
    <td align="right"> #tar chyb </td>
    <td align="right"> #xferErrs </td>
</tr>
\$restoreStr
</table>
<p>
EOF

$Lang{Archive_Summary} = <<EOF;
\${h2("Souhrn archiv�")}
<p>
Klikni na ��slo archivu pro v�ce detail�.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Archiv# </td>
    <td align="center"> V�sledek </td>
    <td align="right"> Datum spu�ten�</td>
    <td align="right"> Doba trv�n�/minuty</td>
</tr>
\$ArchiveStr
</table>
<p>
EOF

$Lang{BackupPC__Documentation} = "BackupPC: Documentace";

$Lang{No} = "ne";
$Lang{Yes} = "ano";

$Lang{The_directory_is_empty} = <<EOF;
<tr><td bgcolor="#ffffff">Adres�� \$dirDisplay je pr�zdn�
</td></tr>
EOF

#$Lang{on} = "zapnout";
$Lang{off} = "vypnout";

$Lang{backupType_full}    = "pln�";
$Lang{backupType_incr}    = "inkr";
$Lang{backupType_active}  = "active";
$Lang{backupType_partial} = "��ste�n�";

$Lang{failed} = "ne�sp�n�";
$Lang{success} = "�sp�n�";
$Lang{and} = "a";

# ------
# Hosts states and reasons
$Lang{Status_idle} = "ne�inn�";
$Lang{Status_backup_starting} = "z�loha se spou�t�";
$Lang{Status_backup_in_progress} = "z�loha prob�h�";
$Lang{Status_restore_starting} = "obnoven� se spou�t�";
$Lang{Status_restore_in_progress} = "obnoven� prob�h�";
$Lang{Status_admin_pending} = "link �ek�";
$Lang{Status_admin_running} = "link b��";

$Lang{Reason_backup_done}    = "hotovo";
$Lang{Reason_restore_done}   = "obnoven� dokon�eno";
$Lang{Reason_archive_done}   = "archivace dokon�ena";
$Lang{Reason_nothing_to_do}  = "ne�inn�";
$Lang{Reason_backup_failed}  = "z�lohov�n� selhalo";
$Lang{Reason_restore_failed} = "obnoven� selhalo";
$Lang{Reason_archive_failed} = "archivace selhala";
$Lang{Reason_no_ping}        = "��dn� ping";
$Lang{Reason_backup_canceled_by_user}  = "z�lohov�n� zru�eno u�ivatelem";
$Lang{Reason_restore_canceled_by_user} = "obnoven� zru�eno u�ivatelem";
$Lang{Reason_archive_canceled_by_user} = "archivace zru�ena u�ivatelem";
$Lang{Disabled_OnlyManualBackups}  = "automatick� z�lohov�n� zak�z�no";  
$Lang{Disabled_AllBackupsDisabled} = "zak�z�no";                  


# ---------
# Email messages

# No backup ever
$Lang{EMailNoBackupEverSubj} = "BackupPC: �adn� z�lohy hosta \$host se nezda�ili";
$Lang{EMailNoBackupEverMesg} = <<'EOF';
To: $user$domain
cc:
P�edm�t: $subj
$headers
Dear $userName,

Va�e PC ($host) nebylo nikdy �sp�n� z�lohov�no na��m
z�lohovac�m softwarem.  Z�lohov�n� PC by m�lo b�t spu�t�no 
automaticky, kdy� je Va�e PC p�ipojeno do s�t�. Mel by jste
kontaktovat Va�i podporu pokud:

  - Va�e PC bylo pravideln� p�ipojov�no do s�t�, z�ejm�
    je n�jak� prob�m v nastaven� nebo konfiguraci, kter� zabra�uje
    z�lohov�n�.

  - Nechcete Va�e PC z�lohovat a chcete p�estat dost�vat tyto zpr�vy.

Ujist�te se, �e je Va�e PC p�ipojeno do s�t�, a� budete p��t� v kancel��i.

S pozdravem,
BackupPC Genie
http://backuppc.sourceforge.net
EOF

# No recent backup
$Lang{EMailNoBackupRecentSubj} = "BackupPC: ��dn� nov� z�lohy pro \$host";
$Lang{EMailNoBackupRecentMesg} = <<'EOF';
To: $user$domain
cc:
P�edm�t: $subj
$headers
Drah� $userName,

Va�e PC ($host) nebylo �sp�n� z�lohov�no ji� $days dn�.
Va�e PC bylo korektn� z�lohov�no $numBackups kr�t od $firstTime 
do dne p�ed $days dny.  Z�lohov�n� PC by se m�lo spustit automaticky,
kdy� je Va�e PC p�ipojeno do s�t�.

Pokud bylo Va�e PC p�ipojeno do s�t� v�ce ne� n�kolik hodin v pr�b�hu
posledn�ch $days dn�, m�l by jste kontaktovat Va�i podporu k zji�t�n�,
pro� z�lohov�n� nefunguje.

Pokud jste mimo kancel��, nem��ete ud�lat nic jin�ho ne� zkop�rovat kritick�
soubory na jin� media. M�l by jste m�t na pam�ti, �e v�echny soubory vytvo�en�
nebo zm�n�n� v posledn�ch $days dnech (i s v�emi nov�mi emaily a p��lohami) 
nebudou moci b�ti obnoveny, pokud se disk ve Va�em po��ta�i po�kod�.

S pozdravem,
BackupPC Genie
http://backuppc.sourceforge.net
EOF

# Old Outlook files
$Lang{EMailOutlookBackupSubj} = "BackupPC: Soubory programu Outlook na \$host je nutn� z�lohovat";
$Lang{EMailOutlookBackupMesg} = <<'EOF';
To: $user$domain
cc:
P�edm�t: $subj
$headers
Drah� $userName,

Soubory programu Outlook na Va�em PC maj� $howLong.
Tyto soubory obsahuj� v�echny Va�e emaily, p��lohy, kontakty a informace v           
kalend��i.  Va�e PC bylo naposled korektn� z�lohov�no $numBackups kr�t od
$firstTime do $lastTime. Nicm�n� Outlook zamkne v�echny svoje soubory kdy�
je spu�t�n a znemo��uje jejich z�lohov�n�.

Doporu�ujeme V�m z�lohovat soubory Outlooku, kdy� jste p�ipojen do s�t� tak,
�e ukon��te program Outlook a v�echny ostatn� aplikace a ve va�em prohl�e�i
otev�ete tuto adresu:

    $CgiURL?host=$host               

Vyberte "Spustit inkrementa�n� z�lohov�n�" dvakr�t ke spu�ten� nov�ho 
z�lohov�n�. M��ete vybrat "N�vrat na $host page" a pot� stiknout "obnovit"
ke zji�t�n� stavu z�lohov�n�. Dokon�en� m��e trvat n�kolik minut.

S pozdravem,
BackupPC Genie
http://backuppc.sourceforge.net
EOF

$Lang{howLong_not_been_backed_up} = "nebylo z�lohov�no �sp�n�";
$Lang{howLong_not_been_backed_up_for_days_days} = "nebylo z�lohov�no \$days dn�";

#######################################################################
# RSS strings
#######################################################################
$Lang{RSS_Doc_Title}       = "BackupPC Server";
$Lang{RSS_Doc_Description} = "RSS kan�l BackupPC";
$Lang{RSS_Host_Summary}    = <<EOF;
Po�et pln�ch: \$fullCnt;
�as pln�ch/dn�: \$fullAge;
Celkov� velikost/GiB: \$fullSize;
Rychlost MB/sec: \$fullRate;
Po�et inkr: \$incrCnt;
�as inkr/Dn�: \$incrAge;
Stav: \$host_state;
Posledn� pokus: \$host_last_attempt;
EOF

#######################################################################
# Configuration editor strings
#######################################################################

$Lang{Only_privileged_users_can_edit_config_files} = "Pouze opr�vn�n� u�ivatel� mohou editovat konfikuraci.";
$Lang{CfgEdit_Edit_Config} = "Editovat konfiguraci";
$Lang{CfgEdit_Edit_Hosts}  = "Editovat Hosty";

$Lang{CfgEdit_Title_Server} = "Server";
$Lang{CfgEdit_Title_General_Parameters} = "Hlavn� parametry";
$Lang{CfgEdit_Title_Wakeup_Schedule} = "Pl�n probuzen�";
$Lang{CfgEdit_Title_Concurrent_Jobs} = "Rovnocenn� �lohy";
$Lang{CfgEdit_Title_Pool_Filesystem_Limits} = "Limity �lo�i�t�";
$Lang{CfgEdit_Title_Other_Parameters} = "Ostatn� paramtery";
$Lang{CfgEdit_Title_Remote_Apache_Settings} = "Vzd�len� nastaven� Apache";
$Lang{CfgEdit_Title_Program_Paths} = "Cesty programu";
$Lang{CfgEdit_Title_Install_Paths} = "Instala�n� cesty";
$Lang{CfgEdit_Title_Email} = "Email";
$Lang{CfgEdit_Title_Email_settings} = "Nastaven� emailu";
$Lang{CfgEdit_Title_Email_User_Messages} = "Nastaven� emailu u�ivatel�m";
$Lang{CfgEdit_Title_CGI} = "CGI";
$Lang{CfgEdit_Title_Admin_Privileges} = "Administra�n� pr�va";
$Lang{CfgEdit_Title_Page_Rendering} = "Renderov�n� str�nky";
$Lang{CfgEdit_Title_Paths} = "Cesty";
$Lang{CfgEdit_Title_User_URLs} = "U�ivatelsk� URL";
$Lang{CfgEdit_Title_User_Config_Editing} = "Editace konfigurace u�ivatel�";
$Lang{CfgEdit_Title_Xfer} = "Xfer";
$Lang{CfgEdit_Title_Xfer_Settings} = "Nastaven� Xfer";
$Lang{CfgEdit_Title_Ftp_Settings} = "Nastaven� FTP";
$Lang{CfgEdit_Title_Smb_Settings} = "Nastaven� Smb";
$Lang{CfgEdit_Title_Tar_Settings} = "Nastaven� Tar";
$Lang{CfgEdit_Title_Rsync_Settings} = "Nastaven� Rsync";
$Lang{CfgEdit_Title_Rsyncd_Settings} = "Nastaven� Rsyncd";
$Lang{CfgEdit_Title_Archive_Settings} = "Nastaven� Archivace";
$Lang{CfgEdit_Title_Include_Exclude} = "Zahrnout/Vylou�it";
$Lang{CfgEdit_Title_Smb_Paths_Commands} = "Smb Cesty/P��kazy";
$Lang{CfgEdit_Title_Tar_Paths_Commands} = "Tar Cesty/P��kazy";
$Lang{CfgEdit_Title_Rsync_Paths_Commands_Args} = "Rsync  Cesty/P��kazy/Argumenty";
$Lang{CfgEdit_Title_Rsyncd_Port_Args} = "Rsyncd Port/Argumenty";
$Lang{CfgEdit_Title_Archive_Paths_Commands} = "Archivace Cesty/P��kazy";
$Lang{CfgEdit_Title_Schedule} = "Pl�n";
$Lang{CfgEdit_Title_Full_Backups} = "Pln� z�lohy";
$Lang{CfgEdit_Title_Incremental_Backups} = "Inkrementa�n� z�lohy";
$Lang{CfgEdit_Title_Blackouts} = "P�et�en�";
$Lang{CfgEdit_Title_Other} = "Ostatn�";
$Lang{CfgEdit_Title_Backup_Settings} = "Nastaven� z�lohov�n�";
$Lang{CfgEdit_Title_Client_Lookup} = "Vyhled�v�n� klient�p";
$Lang{CfgEdit_Title_User_Commands} = "U�ivatelsk� p��kazy";
$Lang{CfgEdit_Title_Hosts} = "Hosti";

$Lang{CfgEdit_Hosts_Comment} = <<EOF;
K p�id�n� nov�ho hosta, vyberte P�idat a zadejte jm�no. Pro
konfiguraci hosta z jin�ho hosta, zadejte jm�no hosta jako
NEWHOST=COPYHOST. To p�ep�e existuj�c� konfiguraci pro NEWHOST.  
Tento postup m��ete pou��t i pto existuj�c�ho hosta.
Hosta sma�ete stisknut�m tla��tka delete. P�id�n�, smaz�n� a kop�rov�n�
konfigurace nanabude platnosti dokud nedojde k stisknut� tla��tka Ulo�it 
��dn� ze z�loh smazan�ch host� nebude odstran�na, tedy pokud omylem
so if you accidently delete a host, simply re-add it.  To completely
sma�ete hostovy z�lohy, mus�te ru�n� smazat soubory v \$topDir/pc/HOST
EOF

$Lang{CfgEdit_Header_Main} = <<EOF;
\${h1("Hlavn� editor konfigurace")}
EOF

$Lang{CfgEdit_Header_Host} = <<EOF;
\${h1("Editor konfigurace hosta \$host")}
<p>
Pozn�mka: ozna�te P�epsat, pokud chcete modifikovat hodnotu
specifickou pro tohoto hosta.
<p>
EOF

$Lang{CfgEdit_Button_Save}     = "Ulo�it";
$Lang{CfgEdit_Button_Insert}   = "Vlo�it";
$Lang{CfgEdit_Button_Delete}   = "Smazat";
$Lang{CfgEdit_Button_Add}      = "P�idat";
$Lang{CfgEdit_Button_Override} = "P�epsat";
$Lang{CfgEdit_Button_New_Key}  = "Nov� kl��";
$Lang{CfgEdit_Button_New_Share} = "New ShareName or '*'";

$Lang{CfgEdit_Error_No_Save}
            = "Chyba: Neulo�eno z d�vody chyb";
$Lang{CfgEdit_Error__must_be_an_integer}
            = "Chyba: \$var mus� b�t cel� ��slo";
$Lang{CfgEdit_Error__must_be_real_valued_number}
            = "Chyba: \$var mus� b�t re�ln� ��slo";
$Lang{CfgEdit_Error__entry__must_be_an_integer}
            = "Chyba: vstup \$var \$k mus� b�t cel� ��slo";
$Lang{CfgEdit_Error__entry__must_be_real_valued_number}
            = "Chyba: vstup \$var \$k mus� b�t re�ln� ��slo";
$Lang{CfgEdit_Error__must_be_executable_program}
            = "Chyba: \$var mus� b�t spr�vn� cesta";
$Lang{CfgEdit_Error__must_be_valid_option}
            = "Chyba: \$var mus� b�t spr�vn� mo�nost";
$Lang{CfgEdit_Error_Copy_host_does_not_exist}
            = "Kopie hosta \$copyHost neexistuje; vytv���m nov� n�zev hosta \$fullHost. Sma�te tohota hosta, pokud to nen� to, co jste cht�l.";

$Lang{CfgEdit_Log_Copy_host_config}
            = "\$User zkop�roval konfiguraci z hosta \$fromHost do \$host\n";
$Lang{CfgEdit_Log_Delete_param}
            = "\$User smazal \$p z \$conf\n";
$Lang{CfgEdit_Log_Add_param_value}
            = "\$User p�idal \$p do \$conf, nastavil na \$value\n";
$Lang{CfgEdit_Log_Change_param_value}
            = "\$User zm�nil \$p v \$conf do \$valueNew z \$valueOld\n";
$Lang{CfgEdit_Log_Host_Delete}
            = "\$User smazal hosta \$host\n";
$Lang{CfgEdit_Log_Host_Change}
            = "\$User host \$host zm�nil \$key z \$valueOld na \$valueNew\n";
$Lang{CfgEdit_Log_Host_Add}
            = "\$User p�idal host \$host: \$value\n";
  
#end of lang_cz.pm
