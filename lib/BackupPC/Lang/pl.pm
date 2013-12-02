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

use utf8;

# --------------------------------

$Lang{Start_Archive} = "Zacznij Archiwizację";
$Lang{Stop_Dequeue_Archive} = "Zatrzymaj/Odkolejkuj Archiwizację";
$Lang{Start_Full_Backup} = "Zacznij Pełną Kopię Bezpieczeństwa";
$Lang{Start_Incr_Backup} = "Zacznij Inkrementacyjną Kopię Bezpieczeństwa";
$Lang{Stop_Dequeue_Backup} = "Zatrzymaj/Odkolejkuj Kopię Bezpieczeństwa";
$Lang{Restore} = "Przywróć";

$Lang{Type_full} = "pełny";
$Lang{Type_incr} = "inkrementacyjny";

# -----

$Lang{Only_privileged_users_can_view_admin_options} = "Tylko uprzywilejowani użytkownicy mogą oglądać opcje administracyjne";
$Lang{H_Admin_Options} = "Serwer BackupPC: Opcje Administracyjne";
$Lang{Admin_Options} = "Opcje Administracyjne";
$Lang{Admin_Options_Page} = <<EOF;
\${h1(qq{$Lang{Admin_Options}})}
<br>
\${h2("Kontrola Serwera")}
<form name="ReloadForm" action="\$MyURL" method="get">
<input type="hidden" name="action" value="">
<table class="tableStnd">
  <tr><td>Wczytaj ponownie konfigurację serwera:<td><input type="button" value="Reload"
     onClick="document.ReloadForm.action.value='Reload';
              document.ReloadForm.submit();">
</table>
</form>
<!--
\${h2("Konfiguracja Serwera")}
<ul>
  <li><i>Inne opcje mogą być tu ... . tzn,</i>
  <li>Edytuj Konfigurację Serwera
</ul>
-->
EOF

$Lang{Unable_to_connect_to_BackupPC_server} = "Nie można połączyć się z serwerem BackupPC";
$Lang{Unable_to_connect_to_BackupPC_server_error_message} = <<EOF;
Ten skrypt CGI (\$MyURL) nie może połączyć się z BackupPC
serwer na \$Conf{ServerHost} porcie \$Conf{ServerPort}.<br>
Błąd to: \$err.<br>
Możliwe ,że serwer BackupPC nie jest uruchomiony albo że występuje
błąd w konfiguracji.  Proszę powiadomić o tym swojego Administratora.
EOF

$Lang{Admin_Start_Server} = <<EOF;
\${h1(qq{$Lang{Unable_to_connect_to_BackupPC_server}})}
<form action="\$MyURL" method="get">
Serwer BackupPC na <tt>\$Conf{ServerHost}</tt> porcie <tt>\$Conf{ServerPort}</tt>
nie działa (może tylko go wyłączyłeś, albo po prostu nie wlaczyłeś).<br>
Czy chcesz go włączyć?
<input type="hidden" name="action" value="startServer">
<input type="submit" value="Uruchom Serwer" name="ignore">
</form>
EOF

# -----

$Lang{H_BackupPC_Server_Status} = "Status Serwera BackupPC";

$Lang{BackupPC_Server_Status_General_Info}= <<EOF;
\${h2(\"Informacje Ogólne Serwera\")}

<ul>
<li> PID serwera to \$Info{pid},  na hoście \$Conf{ServerHost},
     wersja \$Info{Version}, włączony \$serverStartTime.
<li> WYgenerowanie statusu : \$now.
<li> Ostatnie ładowanie konfiguracji : \$configLoadTime.
<li> Następne kolejkowanie : \$nextWakeupTime.
<li> Inne Informacje:
    <ul>
        <li>\$numBgQueue oczekujących żądań kopii bezpieczeństwa od czasu ostatniego zaplanowanego działania,
        <li>\$numUserQueue oczekujacych żądań kopii bezpieczeństwa od uzytkowników,
        <li>\$numCmdQueue oczekujących poleceń do wykonania,
        \$poolInfo
        <li>Ostatni obszar systemu plików to \$Info{DUlastValue}%
            (\$DUlastTime), dzisiejsza maksymalna wartość to \$Info{DUDailyMax}% (\$DUmaxTime)
            a wczorajszy był \$Info{DUDailyMaxPrev}%.
    </ul>
</ul>
EOF

$Lang{BackupPC_Server_Status} = <<EOF;
\${h1(qq{$Lang{H_BackupPC_Server_Status}})}

<p>
\${h2("Aktualnie Działające Prace")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td> Host </td>
    <td> Typ </td>
    <td> Użytkownik </td>
    <td> Początek </td>
    <td> Polecenie </td>
    <td align="center"> PID </td>
    <td align="center"> Xfer PID </td>
    <td align="center"> Status </td>
    <td align="center"> Count </td>
    </tr>
\$jobStr
</table>

<p>
\$generalInfo

\${h2("Błędy które wymagają uwagi")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> Host </td>
    <td align="center"> Typ </td>
    <td align="center"> Użytkownik </td>
    <td align="center"> Ostatnia próba </td>
    <td align="center"> Detale </td>
    <td align="center"> Czas </td>
    <td> Ostatni błąd (inny niż brak połączenia(pingu)) </td></tr>
\$statusStr
</table>
EOF

# --------------------------------
$Lang{BackupPC__Server_Summary} = "BackupPC: Wyciąg Hostow";
$Lang{BackupPC__Archive} = "BackupPC: Archiwum";
$Lang{BackupPC_Summary} = <<EOF;

\${h1(qq{$Lang{BackupPC__Server_Summary}})}
<p>
<ul>
<li>Ten status został wygenerowany o \$now.
<li>Ostatni obszar systemu plików to \$Info{DUlastValue}%
    (\$DUlastTime), dzisiejsza maksymalna wartość to \$Info{DUDailyMax}% (\$DUmaxTime)
    a wczorajszy był \$Info{DUDailyMaxPrev}%.
</ul>
</p>

\${h2("Hosty z bezbłędnie wykonaną kopią bezpieczeństwa ")}
<p>
Jest \$hostCntGood hostów które zostaly zabezpieczone, na całkowita liczbę:
<ul>
<li> \$fullTot pełnych kopi bezpieczeństwa na pełną sumę \${fullSizeTot}GiB
     (przed kompresją),
<li> \$incrTot inkrementalnych kopi bezpieczeństwa na pełną sume \${incrSizeTot}GiB
     (przed kompresją).
</ul>
</p>
<table class="sortable" id="host_summary_backups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> Host </td>
    <td align="center"> Użytwkonik </td>
    <td align="center"> #Pełny </td>
    <td align="center"> Pełny Wiek (dni) </td>
    <td align="center"> Pełny Rozmiar (GiB) </td>
    <td align="center"> Prędkość (MB/s) </td>
    <td align="center"> #Inkr </td>
    <td align="center"> Wiek Inkr (dni) </td>
    <td align="center"> Ostatnia kopia bezpieczeństwa (dni) </td>
    <td align="center"> Status </td>
    <td align="center"> #Xfer  błędó</td>
    <td align="center"> Ostatnia próba </td></tr>
\$strGood
</table>
<br><br>
\${h2("Hosty bez wykonanej kopii bezpieczeństwa")}
<p>
Jest \$hostCntNone hostów bez kopii bezpieczeństwa.
<p>
<table class="sortable" id="host_summary_nobackups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> Host </td>
    <td align="center"> Użytkonik </td>
    <td align="center"> #Pełny </td>
    <td align="center"> Pełny Wiek (dni </td>
    <td align="center"> Pełny Rozmiar (GiB) </td>
    <td align="center"> Prędkość (MB/s) </td>
    <td align="center"> #Inkr </td>
    <td align="center"> Wiek Inkr (dni) </td>
    <td align="center"> Ostatnia kopia bezpieczeństwa (dni) </td>
    <td align="center"> Status </td>
    <td align="center"> #Xfer  błędó</td>
    <td align="center"> Ostatnia próba </td></tr>
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

Jest \$hostCntGood hostów które mają kopie bezpieczeństwa na sumę \${fullSizeTot}GiB
<p>
<form name="form1" method="post" action="\$MyURL">
<input type="hidden" name="fcbMax" value="\$checkBoxCnt">
<input type="hidden" name="type" value="1">
<input type="hidden" name="host" value="\${EscHTML(\$archHost)}">
<input type="hidden" name="action" value="Archive">
<table class="tableStnd" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td align=center> Host</td>
    <td align="center"> Uzytkownik </td>
    <td align="center"> Rozmiar Kopii Bezpieczeństwa </td>
\$strGood
\$checkAllHosts
</table>
</form>
<p>

EOF

$Lang{BackupPC_Archive2} = <<EOF;
\${h1(qq{$Lang{BackupPC__Archive}})}
Przystępuje do archiwizacji następujących hostów 
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
    <td>Lokalizacja Archiwum</td>
    <td><input type="text" value="\$ArchiveDest" name="archive_device"></td>
</tr>
EOF

$Lang{BackupPC_Archive2_compression} = <<EOF;
<tr>
    <td>Kompresja</td>
    <td>
    <input type="radio" value="0" name="compression" \$ArchiveCompNone>None<br>
    <input type="radio" value="1" name="compression" \$ArchiveCompGzip>gzip<br>
    <input type="radio" value="2" name="compression" \$ArchiveCompBzip2>bzip2
    </td>
</tr>
EOF

$Lang{BackupPC_Archive2_parity} = <<EOF;
<tr>
    <td>Procent parytetowanych danych (0 = wyłączone, 5 = typowe)</td>
    <td><input type="numeric" value="\$ArchivePar" name="par"></td>
</tr>
EOF

$Lang{BackupPC_Archive2_split} = <<EOF;
<tr>
    <td>Rozdziel wyjście na </td>
    <td><input type="numeric" value="\$ArchiveSplit" name="splitsize">Megabytes</td>
</tr>
EOF

# -----------------------------------
$Lang{Pool_Stat} = <<EOF;
        <li>Pula to \${poolSize}GiB zawiera \$info->{"\${name}FileCnt"} plików
            oraz \$info->{"\${name}DirCnt"} katalogów (zajęło \$poolTime),
        <li>Hashowanie puli daje \$info->{"\${name}FileCntRep"} powtarzających się
            plików z najdłuższym łancuchem \$info->{"\${name}FileRepMax"},
        <li>Nocne czyszczenie usunęło \$info->{"\${name}FileCntRm"} plików o
            rozmiarze \${poolRmSize}GiB (zajęło \$poolTime),
EOF

# --------------------------------
$Lang{BackupPC__Backup_Requested_on__host} = "BackupPC: Kopia rządana na \$host";
# --------------------------------
$Lang{REPLY_FROM_SERVER} = <<EOF;
\${h1(\$str)}
<p>
Odpowiedź serwera to : \$reply
<p>
Wróć do <a href="\$MyURL?host=\$host">strony domowej \$host</a>.
EOF
# --------------------------------
$Lang{BackupPC__Start_Backup_Confirm_on__host} = "BackupPC: Potwierdzony start kopii na \$host";
# --------------------------------
$Lang{Are_you_sure_start} = <<EOF;
\${h1("Are you sure?")}
<p>
Zamierzasz zaczać kopie \$type na \$host.

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="hostIP" value="\$ipAddr">
<input type="hidden" name="doit" value="1">
<input type="hidden" name="action" value="">
Czy napewno chcesz tego ?
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="No" name="ignore">
</form>
EOF
# --------------------------------
$Lang{BackupPC__Stop_Backup_Confirm_on__host} = "BackupPC: Zatrzymaj potwierdzoną kopie na \$host";
# --------------------------------
$Lang{Are_you_sure_stop} = <<EOF;

\${h1("Czy jesteś pewien ?")}

<p>
Zamierzasz zatrzymać wykonywanie kopii na  \$host;

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host"   value="\$host">
<input type="hidden" name="doit"   value="1">
<input type="hidden" name="action" value="">
Prosze nie zaczynac nowej kopii przez
<input type="text" name="backoff" size="10" value="\$backoff"> godzin.
<p>
Czy naprawdę tego chcesz ?
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="No" name="ignore">
</form>

EOF
# --------------------------------
$Lang{Only_privileged_users_can_view_queues_} = "Tylko uprzywilejowani użytwkonicy mogą przeglądać kolejki";
# --------------------------------
$Lang{Only_privileged_users_can_archive} = "ylko uprzywilejowani użytwkonicy mogą archiwizować.";
# --------------------------------
$Lang{BackupPC__Queue_Summary} = "BackupPC: Podsumowanie kolejki";
# --------------------------------
$Lang{Backup_Queue_Summary} = <<EOF;
\${h1("Podsumowanie kolejki kopii bezpieczeństwa")}
<br><br>
\${h2("Podsumowanie kolejki uzytkownika")}
<p>
Następujący użytkonicy są w kolejce:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Host </td>
    <td> Czas do </td>
    <td> Użytkownik </td></tr>
\$strUser
</table>
<br><br>

\${h2("Podsumowanie kolejki w tle")}
<p>
Następujące kolejki będące w tle czekają na wykonanie :
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Host </td>
    <td> Czas do </td>
    <td> uzytkownik </td></tr>
\$strBg
</table>
<br><br>
\${h2("Podsumowanie kolejki poleceń")}
<p>
Następujące kolejki poleceń czekają na wykonanie :
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Host </td>
    <td> Czas do </td>
    <td> Użytkownik </td>
    <td> Polecenie </td></tr>
\$strCmd
</table>
EOF

# --------------------------------
$Lang{Backup_PC__Log_File__file} = "BackupPC: Plik \$file";
$Lang{Log_File__file__comment} = <<EOF;
\${h1("Plik \$file \$comment")}
<p>
EOF
# --------------------------------
$Lang{Contents_of_log_file} = <<EOF;
Komentarze do pliku <tt>\$file</tt>, zmodyfikowne \$mtimeStr \$comment
EOF

# --------------------------------
$Lang{skipped__skipped_lines} = "[ pominięto \$skipped linii ]\n";
# --------------------------------
$Lang{_pre___Can_t_open_log_file__file} = "<pre>\nNie można otworzyc dziennika \$file\n";

# --------------------------------
$Lang{BackupPC__Log_File_History} = "BackupPC: Historia Dziennika";
$Lang{Log_File_History__hdr} = <<EOF;
\${h1("Histria Dziennika \$hdr")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Plik </td>
    <td align="center"> Rozmiar </td>
    <td align="center"> Czas Modyfikacji </td></tr>
\$str
</table>
EOF

# -------------------------------
$Lang{Recent_Email_Summary} = <<EOF;
\${h1("Podsumowanie Emaili (kojeność odwrotna)")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Adresat </td>
    <td align="center"> Nadawca </td>
    <td align="center"> Czas </td>
    <td align="center"> Temat </td></tr>
\$str
</table>
EOF
 

# ------------------------------
$Lang{Browse_backup__num_for__host} = "BackupPC: Przeglądaj \$num dla \$host";

# ------------------------------
$Lang{Restore_Options_for__host} = "BackupPC: Przywróć opcje dla \$host";
$Lang{Restore_Options_for__host2} = <<EOF;
\${h1("Przywróć opcje dla \$host")}
<p>
Zaznaczyłeś następujące pliki/katalogi z
udziału \$share, kopia numer #\$num:
<ul>
\$fileListStr
</ul>
</p><p>
Masz do wyboru trzy możliwośći przywrócenia tych plików/katalogów.
Proszę wybrać jedna z nich.
</p>
\${h2("Opcja Pierwsza: Bezposrednie przywrócenie")}
<p>
EOF

$Lang{Restore_Options_for__host_Option1} = <<EOF;
Możesz zacząć przywracanie bezpośrednio na 
<b>\$directHost</b>.
</p><p>
<b>Uwaga:</b> jakikolwiek plik pasujący do tych ktore masz
zaznaczone będzie nadpisany !
</p>
<form action="\$MyURL" method="post" name="direct">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="3">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<table class="tableStnd" border="0">
<tr>
    <td>Przywrócenie plików na host</td>
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
	 <!--<a href="javascript:myOpen('\$MyURL?action=findShares&host='+document.direct.hostDest.options.value)">Szukaj dostępnych udziałów (NIE ZAIMPLEMENTOWANE)</a>--></td>
</tr><tr>
    <td>Przywrócenie plików do udziału</td>
    <td><input type="text" size="40" value="\${EscHTML(\$share)}"
	 name="shareDest"></td>
</tr><tr>
    <td>Przywróć pliki poniżej<br>(podobne do udziału)</td>
    <td valign="top"><input type="text" size="40" maxlength="256"
	value="\${EscHTML(\$pathHdr)}" name="pathHdr"></td>
</tr><tr>
    <td><input type="submit" value="Start Restore" name="ignore"></td>
</table>
</form>
EOF

$Lang{Restore_Options_for__host_Option1_disabled} = <<EOF;
Bezpośrednie przywrócenie na host zostało wyłączone \${EscHTML(\$hostDest)}.
Proszę wybrac inna opcję przywracania.
EOF

# ------------------------------
$Lang{Option_2__Download_Zip_archive} = <<EOF;
<p>
\${h2("Opcja Druga: Ściągnij Archiwum Zip")}
<p>
Możesz ściągnąc archiwum Zip zawieające wszystkie pliki/katalogi które
zaznaczyłeś.  Możesz wtedy użyć lokalnej aplikacji, Takiej jak 7Zip,
do przeglądania czy wypakowania danych.
</p><p>
<b>Uwaga:</b> zależnie od wybranych plików/katalogów ,
to archiwum może być bardzo duże.  Może zajać dużo czasu do
stworzenia i przesłania go, także będziesz potrzebował odpowiedniej ilości miejsca na dysku
do przechowania.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="2">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Stworzyć archiwum powiązane
z \${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(inaczej bedzie zawierac pełne scieżki do plików).
<br>
<table class="tableStnd" border="0">
<tr>
    <td>Kompresja (0=off, 1=fast,...,9=best)</td>
    <td><input type="text" size="6" value="5" name="compressLevel"></td>
</tr><tr>
    <td>Code page (e.g. cp866)</td>
    <td><input type="text" size="6" value="utf8" name="codePage"></td>
</tr>
</table>
<br>
<input type="submit" value="Sciągnij plik Zip" name="ignore">
</form>
EOF

# ------------------------------

$Lang{Option_2__Download_Zip_archive2} = <<EOF;
<p>
\${h2("Opcja Druga: Ściągnij Archiwum Zip")}
<p>
Archive::Zip nie jest zainstalowane więc nie możesz ściągnąć archiwum Zip.
Proszę poprosić swojego Administratora aby zainstalował Archive::Zip z
<a href="http://www.cpan.org">www.cpan.org</a>.
</p>
EOF


# ------------------------------
$Lang{Option_3__Download_Zip_archive} = <<EOF;
\${h2("Opcja trzecia : Ściągnij archiwum Tar")}
<p>
Możesz ściągnąc archiwum Tar zawieające wszystkie pliki/katalogi które
zaznaczyłeś.  Możesz wtedy użyć lokalnej aplikacji, Takiej jak 7Zip,
do przeglądania czy wypakowania danych.
</p><p>
<b>Uwaga:</b> zależnie od wybranych plików/katalogów ,
to archiwum może być bardzo duże.  Może zajać dużo czasu do
stworzenia i przesłania go, także będziesz potrzebował odpowiedniej ilości miejsca na dysku
do przechowania.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="1">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Stworzyć archiwum powiązane
z\${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(inaczej bedzie zawierac pełne scieżki do plików).
<br>
<input type="submit" value="Sciągnij plik Tar" name="ignore">
</form>
EOF


# ------------------------------
$Lang{Restore_Confirm_on__host} = "BackupPC: Potwiedź przywrócenie na \$host";

$Lang{Are_you_sure} = <<EOF;
\${h1("Czy jesteś pewien ?")}
<p>
Zaczynasz przywracanie bezpośrednio na maszynę \$In{hostDest}.
Następujące pliki zostaną przywrócene na udział \$In{shareDest}, z
kopii numer \$num:
<p>
<table class="tableStnd" border>
<tr class="tableheader"><td>Orginalny plik/katalog</td><td>Będzie przywrócony na</td></tr>
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
Czy napewno chcesz tego ?
<input type="button" value="\$Lang->{Restore}"
 onClick="document.RestoreForm.action.value='Restore';
          document.RestoreForm.submit();">
<input type="submit" value="No" name="ignore">
</form>
EOF


# --------------------------
$Lang{Restore_Requested_on__hostDest} = "BackupPC: Rządanie przywrócenie na \$hostDest";
$Lang{Reply_from_server_was___reply} = <<EOF;
\${h1(\$str)}
<p>
Odpowiedź serwera : \$reply
<p>
Wróć <a href="\$MyURL?host=\$hostDest">stronę domową \$hostDest</a>.
EOF

$Lang{BackupPC_Archive_Reply_from_server} = <<EOF;
\${h1(\$str)}
<p>
Odpowiedź serwera : \$reply
EOF


# -------------------------
$Lang{Host__host_Backup_Summary} = "BackupPC: Podsumowanie kopii bezpieczeństwa hosta \$host";

$Lang{Host__host_Backup_Summary2} = <<EOF;
\${h1("Podsumowanie kopii bezpieczeństwa hosta \$host")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>
</p>
\${h2("Działania użytwkonika")}
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
\${h2("Podsumowanie Kopii Bezpieczeństwa")}
<p>
Kliknij na numer kopii aby przeglądać i przywracać wybrane pliki/katalogi.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> Backup# </td>
    <td align="center"> Typ </td>
    <td align="center"> Wypełniony </td>
    <td align="center"> Poziom </td>
    <td align="center"> Początek </td>
    <td align="center"> Czas trwania w min. </td>
    <td align="center"> Wiek/dni </td>
    <td align="center"> Ścieżka serwera kopii </td>
</tr>
\$str
</table>
<p>

\$restoreStr
</p>
<br><br>
\${h2("Podsumowanie błędów Xfer")}
<br><br>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Backup# </td>
    <td align="center"> Typ </td>
    <td align="center"> Widok </td>
    <td align="center"> #Xfer  błędó</td>
    <td align="center"> #bad plików </td>
    <td align="center"> #bad udziałów </td>
    <td align="center"> #tar błędów </td>
</tr>
\$errStr
</table>
<br><br>

\${h2("Ilość/wielkość użytych ponownie plików")}
<p>
Istniejące pliki to te będące aktualnie w puli; nowe pliki to te dodane
do puli.
Puste pliki i błędy SMB nie są liczone.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="2" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> Łącznie </td>
    <td align="center" colspan="2"> Istniejących plików </td>
    <td align="center" colspan="2"> Nowych plików </td>
</tr>
<tr class="tableheader">
    <td align="center"> Kopia nr </td>
    <td align="center"> Typ </td>
    <td align="center"> Plików </td>
    <td align="center"> Rozmiar/MB </td>
    <td align="center"> MB/sek </td>
    <td align="center"> Plików </td>
    <td align="center"> Rozmiar/MB </td>
    <td align="center"> Plików </td>
    <td align="center"> Rozmiar/MB </td>
</tr>
\$sizeStr
</table>
<br><br>

\${h2("Podsumowanie Kompresji")}
<p>
Wydajność kompresji dla plików będących w puli oraz tych świeżo skompresowanych.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="3" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> Istniejące Pliki </td>
    <td align="center" colspan="3"> Nowe Pliki </td>
</tr>
<tr class="tableheader"><td align="center"> Kopia nr </td>
    <td align="center"> Typ </td>
    <td align="center"> Poziom Kompresji </td>
    <td align="center"> Rozmiar/MB </td>
    <td align="center"> Kompresja/MB </td>
    <td align="center"> Kompresja </td>
    <td align="center"> Rozmiar/MB </td>
    <td align="center"> Kompresja/MB </td>
    <td align="center"> Kompresja </td>
</tr>
\$compStr
</table>
<br><br>
EOF

$Lang{Host__host_Archive_Summary} = "BackupPC: Podsumowanie Archiwizacji hosta \$host";
$Lang{Host__host_Archive_Summary2} = <<EOF;
\${h1("Podsumowanie Archiwizacji hosta \$host")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>

\${h2("Działania Użytkownika")}
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
$Lang{Error} = "BackupPC: Błąd";
$Lang{Error____head} = <<EOF;
\${h1("Błąd: \$head")}
<p>\$mesg</p>
EOF

# -------------------------
$Lang{NavSectionTitle_} = "Serwer";

# -------------------------
$Lang{Backup_browse_for__host} = <<EOF;
\${h1("Przeglądanie kopii dla \$host")}

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
<li> Przegladasz kopie nr #\$num, która zaczeła się około \$backupTime
        (\$backupAge dni temu),
\$filledBackup
<li> Wpisz adres: <input type="text" name="dir" size="50" maxlength="4096" value="\${EscHTML(\$dir)}"> <input type="submit" value="\$Lang->{Go}" name="Submit">
<li> Wpisz adres aby przejść do niego,
<li> Kliknij plik aby go przywrócić,
<li> Możesz zobaczyć kopie <a href="\$MyURL?action=dirHistory&host=\${EscURI(\$host)}&share=\$shareURI&dir=\$pathURI">history</a> obecnego adresu.
</ul>
</form>

\${h2("Zawartość \$dirDisplay")}
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
$Lang{DirHistory_backup_for__host} = "BackupPC: Histria kopii dla \$host";

#
# These two strings are used to build the links for directories and
# file versions.  Files are appended with a version number.
#
$Lang{DirHistory_dirLink}  = "adres";
$Lang{DirHistory_fileLink} = "v";

$Lang{DirHistory_for__host} = <<EOF;
\${h1("Histria kopii dla \$host")}
<p>
Przedstawienie każdej unikalnej wersji każdego pliku we wszystkich kopiach:
<ul>
<li> Kliknij na numerze kopii aby przejść do przegladania tejże kopii,
<li> KLiknij na adres (\$Lang->{DirHistory_dirLink}) aby przejść do niego,
<li> Kliknij na wersje pliku (\$Lang->{DirHistory_fileLink}0,
     \$Lang->{DirHistory_fileLink}1, ...) aby śćiagnać ten plik,
<li> Pliki z tą samą zawartością pomiędzy różnymi kopiami mają ten sam
     numer wersji,
<li> Pliki lub adresy ,które nie są dostępne w określonej kopii
     nie są zaznaczone.
<li> Pliki pokazane z tą samą wersją mogą mieć inny atrybut.
     Wybierz numer kopii aby zobaczyć atrybuty plików.
</ul>

\${h2("Historia \$dirDisplay")}

<br>
<table border cellspacing="2" cellpadding="3">
<tr class="fviewheader"><td>Numer kopii</td>\$backupNumStr</tr>
<tr class="fviewheader"><td>Czas trwania kopii</td>\$backupTimeStr</tr>
\$fileStr
</table>
EOF

# ------------------------------
$Lang{Restore___num_details_for__host} = "BackupPC: Przywróć #\$num detali dla \$host";

$Lang{Restore___num_details_for__host2} = <<EOF;
\${h1("Przywróć #\$num detali dla \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="90%">
<tr><td class="tableheader"> Numer </td><td class="border"> \$Restores[\$i]{num} </td></tr>
<tr><td class="tableheader"> Żądane przez </td><td class="border"> \$RestoreReq{user} </td></tr>
<tr><td class="tableheader"> Czas żądania </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> Wynik </td><td class="border"> \$Restores[\$i]{result} </td></tr>
<tr><td class="tableheader"> Wiadomość błędu </td><td class="border"> \$Restores[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> Host źródłowy </td><td class="border"> \$RestoreReq{hostSrc} </td></tr>
<tr><td class="tableheader"> Źródło kopii nr </td><td class="border"> \$RestoreReq{num} </td></tr>
<tr><td class="tableheader"> Źródło udziału </td><td class="border"> \$RestoreReq{shareSrc} </td></tr>
<tr><td class="tableheader"> Host docelowy </td><td class="border"> \$RestoreReq{hostDest} </td></tr>
<tr><td class="tableheader"> Udział docelowy </td><td class="border"> \$RestoreReq{shareDest} </td></tr>
<tr><td class="tableheader"> Czas rozpoczęcia </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Czas trwania </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> Ilość plików </td><td class="border"> \$Restores[\$i]{nFiles} </td></tr>
<tr><td class="tableheader"> Całkowity rozmiar </td><td class="border"> \${MB} MB </td></tr>
<tr><td class="tableheader"> Szybkość transferu </td><td class="border"> \$MBperSec MB/sec </td></tr>
<tr><td class="tableheader"> Błędy TarCreate </td><td class="border"> \$Restores[\$i]{tarCreateErrs} </td></tr>
<tr><td class="tableheader"> Błędy Xfer </td><td class="border"> \$Restores[\$i]{xferErrs} </td></tr>
<tr><td class="tableheader"> Plik dziennika Xfer </td><td class="border">
<a href="\$MyURL?action=view&type=RestoreLOG&num=\$Restores[\$i]{num}&host=\$host">Widok</a>,
<a href="\$MyURL?action=view&type=RestoreErr&num=\$Restores[\$i]{num}&host=\$host">Błędy</a>
</tr></tr>
</table>
</p>
\${h1("Lista plików/katalogów")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="100%">
<tr class="tableheader"><td>Orginalny plik/katalog</td><td>Przywrócony na</td></tr>
\$fileListStr
</table>
EOF

# ------------------------------
$Lang{Archive___num_details_for__host} = "BackupPC: Detale Archiwum nr #\$num dla \$host";

$Lang{Archive___num_details_for__host2 } = <<EOF;
\${h1("Detale Archiwum nr #\$num dla \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr><td class="tableheader"> Numer </td><td class="border"> \$Archives[\$i]{num} </td></tr>
<tr><td class="tableheader"> Żądane przez </td><td class="border"> \$ArchiveReq{user} </td></tr>
<tr><td class="tableheader"> Czas żądania </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> Wynik </td><td class="border"> \$Archives[\$i]{result} </td></tr>
<tr><td class="tableheader"> Wiadomość błędu </td><td class="border"> \$Archives[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> Czas rozpoczęcia </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Czas trwania </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> Plik dziennika Xfer </td><td class="border">
<a href="\$MyURL?action=view&type=ArchiveLOG&num=\$Archives[\$i]{num}&host=\$host">Widok</a>,
<a href="\$MyURL?action=view&type=ArchiveErr&num=\$Archives[\$i]{num}&host=\$host">Błędy</a>
</tr></tr>
</table>
<p>
\${h1("Lista Hostów")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td>Host</td><td>Numer Kopii</td></tr>
\$HostListStr
</table>
EOF

# -----------------------------------
$Lang{Email_Summary} = "BackupPC: Podsumowanie emailów";

# -----------------------------------
#  !! ERROR messages !!
# -----------------------------------
$Lang{BackupPC__Lib__new_failed__check_apache_error_log} = "BackupPC::Lib->new failed: sprawdź apache error_log\n";
$Lang{Wrong_user__my_userid_is___} =  
              "Zly użytkownik: mój userid to \$>, a nie \$uid"
            . "(\$Conf{BackupPCUser})\n";
# $Lang{Only_privileged_users_can_view_PC_summaries} = "Tylko uprzywilejowani użytkownicy mogą przegladać podsumowania.";
$Lang{Only_privileged_users_can_stop_or_start_backups} = 
                  "Tylko uprzywilejowani użytkownicy mogą dokonywać kopii na"
		. " \${EscHTML(\$host)}.";
$Lang{Invalid_number__num} = "Zły numer \${EscHTML(\$In{num})}";
$Lang{Unable_to_open__file__configuration_problem} = "Niemozna otworzyć \$file: problem z konfiguracja ?";
$Lang{Only_privileged_users_can_view_log_or_config_files} = "Tylko uprzywilejowani użytkownicy mogą przeglądac logi/pliki konf.";
$Lang{Only_privileged_users_can_view_log_files} = "Tylko uprzywilejowani użytkownicy mogą przeglądać logi.";
$Lang{Only_privileged_users_can_view_email_summaries} = "Tylko uprzywilejowani użytkownicy mogą przeglądać podsumowania emaili.";
$Lang{Only_privileged_users_can_browse_backup_files} = "Tylko uprzywilejowani użytkownicy mogą przeglądać pliki kopii"
                . " for host \${EscHTML(\$In{host})}.";
$Lang{Empty_host_name} = "Pusta nazwa hosta.";
$Lang{Directory___EscHTML} = "Adres \${EscHTML(\"\$TopDir/pc/\$host/\$num\")}"
		    . " jest pusty";
$Lang{Can_t_browse_bad_directory_name2} = "Nie można przeglądać - zła nazwa"
	            . " \${EscHTML(\$relDir)}";
$Lang{Only_privileged_users_can_restore_backup_files} = "Tylko uprzywilejowani użytkownicy mogą przywracać pliki kopii"
                . " dla hosta \${EscHTML(\$In{host})}.";
$Lang{Bad_host_name} = "Zła nazwa hosta \${EscHTML(\$host)}";
$Lang{You_haven_t_selected_any_files__please_go_Back_to} = "Nie zaznaczyłeś zadnych plików; proszę cofnąć sie do"
                . " zaznaczanych plików.";
$Lang{You_haven_t_selected_any_hosts} = "Nie zaznaczyłeś zadnego hosta; proszę cofnij sie"
                . " i zaznacz odpowiednie hosty.";
$Lang{Nice_try__but_you_can_t_put} = "Nieźle , ale nie możesz umieścic \'..\' w nazwie pliku";
$Lang{Host__doesn_t_exist} = "Host \${EscHTML(\$In{hostDest})} nie istnieje";
$Lang{You_don_t_have_permission_to_restore_onto_host} = "Nie masz uprawnień do  przywracania danych na host"
		    . " \${EscHTML(\$In{hostDest})}";
$Lang{Can_t_open_create__openPath} = "Nie można otworzyć/stworzyć"
		. "\${EscHTML(\"\$openPath\")}";
$Lang{Only_privileged_users_can_restore_backup_files2} = "Tylko uprzywilejowani użytkownicy mogą przywracać pliki kopii"
                . " dla hosta \${EscHTML(\$host)}.";
$Lang{Empty_host_name} = "Pusta nazwa hosta";
$Lang{Unknown_host_or_user} = "Nieznany host albo uzytwkonik \${EscHTML(\$host)}";
$Lang{Only_privileged_users_can_view_information_about} = "Tylko uprzywilejowani użytkownicy mogą przeglądać informacje o"
                . " host \${EscHTML(\$host)}." ;
$Lang{Only_privileged_users_can_view_archive_information} = "Tylko uprzywilejowani użytkownicy mogą przeglądać informacje o archiwum.";
$Lang{Only_privileged_users_can_view_restore_information} = "Tylko uprzywilejowani użytkownicy mogą przeglądać przywracać informacje.";
$Lang{Restore_number__num_for_host__does_not_exist} = "Punkt przywracania nr \$num dla hosta \${EscHTML(\$host)} nie"
	        . " istnieje.";
$Lang{Archive_number__num_for_host__does_not_exist} = "Archiwum numer \$num dla hosta \${EscHTML(\$host)} nie"
                . " istnieje.";
$Lang{Can_t_find_IP_address_for} = "Nie moge znaleść adresu IP dla \${EscHTML(\$host)}";
$Lang{host_is_a_DHCP_host} = <<EOF;
\$host jest hostem DHCP, i dlatego nie znam jego IP.  Sprawdziłem
nazwe netbios \$ENV{REMOTE_ADDR}\$tryIP, i znalazlem ze ta maszyna 
to nie \$host.
<p>
Dopuki  \$host jest adresem DHCP, możesz 
rozpocząć to źądanie bezpośrednio z tejże maszyny.
EOF

# ------------------------------------
# !! Server Mesg !!
# ------------------------------------

$Lang{Backup_requested_on_DHCP__host} = "Kopia zaźądana na hoscie DHCP \$host (\$In{hostIP}) przez"
		                      . " \$User z \$ENV{REMOTE_ADDR}";
$Lang{Backup_requested_on__host_by__User} = "Kopia zażądana na  \$host przez \$User";
$Lang{Backup_stopped_dequeued_on__host_by__User} = "Kopia przerwana na \$host przez \$User";
$Lang{Restore_requested_to_host__hostDest__backup___num} = "Przywrócenie na host \$hostDest, kopii nr #\$num,"
	     . " przez \$User z \$ENV{REMOTE_ADDR}";
$Lang{Archive_requested} = "Archiwum żądane przez \$User z \$ENV{REMOTE_ADDR}";

# -------------------------------------------------
# ------- Stuff that was forgotten ----------------
# -------------------------------------------------

$Lang{Status} = "Status";
$Lang{PC_Summary} = "Podsumowanie hostów";
$Lang{LOG_file} = "Plik Log";
$Lang{LOG_files} = "Pliki Log";
$Lang{Old_LOGs} = "Stare Logi";
$Lang{Email_summary} = "Podsumowanie emaili";
$Lang{Config_file} = "Plik Konfiguracyjny";
# $Lang{Hosts_file} = "Plik Hostów";
$Lang{Current_queues} = "Aktualne kolejki";
$Lang{Documentation} = "Dokumentacja";

#$Lang{Host_or_User_name} = "<small>Host lub nazwa użytkownika:</small>";
$Lang{Go} = "Idź";
$Lang{Hosts} = "Hosty";
$Lang{Select_a_host} = "Wybierz host...";

$Lang{There_have_been_no_archives} = "<h2> Nie było żadnej archiwizacji </h2>\n";
$Lang{This_PC_has_never_been_backed_up} = "<h2> Ten PC nie byl nikty backupowany!! </h2>\n";
$Lang{This_PC_is_used_by} = "<li>Ten PC jest używany przez \${UserLink(\$user)}";

$Lang{Extracting_only_Errors} = "(Błędy wypakowywania)";
$Lang{XferLOG} = "XferLOG";
$Lang{Errors}  = "Błędy";

# ------------
$Lang{Last_email_sent_to__was_at___subject} = <<EOF;
<li>Ostatni email wysłany do \${UserLink(\$user)} byl o \$mailTime, subject "\$subj".
EOF
# ------------
$Lang{The_command_cmd_is_currently_running_for_started} = <<EOF;
<li>Polecenie \$cmd jest aktualnie wykonywane dla \$host, rozpoczęte o \$startTime.
EOF

# -----------
$Lang{Host_host_is_queued_on_the_background_queue_will_be_backed_up_soon} = <<EOF;
<li>Host \$host jest zakolejkowany (kopia zostanie wykonana niedługo).
EOF

# ----------
$Lang{Host_host_is_queued_on_the_user_queue__will_be_backed_up_soon} = <<EOF;
<li>Host \$host jest zakolejkowany w kolejce użytkownika (kopia zostanie wykonana niedługo).
EOF

# ---------
$Lang{A_command_for_host_is_on_the_command_queue_will_run_soon} = <<EOF;
<li>Polecenie dla \$host jest w kolejce poleceń (ruszy niedługo).
EOF

# --------
$Lang{Last_status_is_state_StatusHost_state_reason_as_of_startTime} = <<EOF;
<li>Ostatni status \"\$Lang->{\$StatusHost{state}}\"\$reason od \$startTime.
EOF

# --------
$Lang{Last_error_is____EscHTML_StatusHost_error} = <<EOF;
<li>Ostatni błąd to \"\${EscHTML(\$StatusHost{error})}\".
EOF

# ------
$Lang{Pings_to_host_have_failed_StatusHost_deadCnt__consecutive_times} = <<EOF;
<li>Pingowanie \$host niepowidło się \$StatusHost{deadCnt} razy.
EOF

# -----
$Lang{Prior_to_that__pings} = "Poprzednio, ";

# -----
$Lang{priorStr_to_host_have_succeeded_StatusHostaliveCnt_consecutive_times} = <<EOF;
<li>\$priorStr pingów do \$host zakończyło się sukcesem \$StatusHost{aliveCnt}
        razy.
EOF

$Lang{Because__host_has_been_on_the_network_at_least__Conf_BlackoutGoodCnt_consecutive_times___} = <<EOF;
<li>Ponieważ \$host jest w sieci od co najmniej \$Conf{BlackoutGoodCnt}
razy, nie zostanie utworzona kopia bezpieczeństwa \$blackoutStr.
EOF

$Lang{__time0_to__time1_on__days} = "\$t0 to \$t1 on \$days";

$Lang{Backups_are_deferred_for_hours_hours_change_this_number} = <<EOF;
<li>Kopie zostały odłożone na \$hours godzin
(<a href=\"\$MyURL?action=Stop_Dequeue_Backup&host=\$host\">zmień ten numer</a>).
EOF

$Lang{tryIP} = " i \$StatusHost{dhcpHostIP}";

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
    <tr class="fviewheader"><td align=center> Nazwa</td>
       <td align="center"> Typ</td>
       <td align="center"> Tryb</td>
       <td align="center"> nr#</td>
       <td align="center"> Rozmiar</td>
       <td align="center"> Data modyfikacji</td>
    </tr>
EOF

$Lang{Home} = "Dom";
$Lang{Browse} = "przeglądaj kopie";
$Lang{Last_bad_XferLOG} = "Ostatni zły XferLOG";
$Lang{Last_bad_XferLOG_errors_only} = "Ostatni zły XferLOG (tylko błedy)";

$Lang{This_display_is_merged_with_backup} = <<EOF;
<li> ten display zostal złończony z kopią nr #\$numF.
EOF

$Lang{Visit_this_directory_in_backup} = <<EOF;
<li> Wybierz kopię którą chcesz przeglądać: <select onChange="window.location=this.value">\$otherDirs </select>
EOF

$Lang{Restore_Summary} = <<EOF;
\${h2("Podsumowanie przywracania")}
<p>
Kliknij na numer przywrócenia dla informacji.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Nr przywrócenia# </td>
    <td align="center"> Wynik </td>
    <td align="right"> Data początku</td>
    <td align="right"> Trwanie/min</td>
    <td align="right"> Ilość plików </td>
    <td align="right"> MB </td>
    <td align="right"> Ilość błędów tar  </td>
    <td align="right"> Ilość błędów xferErrs </td>
</tr>
\$restoreStr
</table>
<p>
EOF

$Lang{Archive_Summary} = <<EOF;
\${h2("Podsumowanie archiwum")}
<p>
Kliknij na numerze archiwum dla informacji
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Nr Archiwum </td>
    <td align="center"> wynik </td>
    <td align="right"> Data początku</td>
    <td align="right"> Trwanie/min</td>
</tr>
\$ArchiveStr
</table>
<p>
EOF

$Lang{BackupPC__Documentation} = "BackupPC: Dokumentacja";

$Lang{No} = "nie";
$Lang{Yes} = "tak";

$Lang{The_directory_is_empty} = <<EOF;
<tr><td bgcolor="#ffffff">Ten katalog jest \$dirDisplay pusty
</td></tr>
EOF

#$Lang{on} = "wł";
$Lang{off} = "wył";

$Lang{backupType_full}    = "pełen";
$Lang{backupType_incr}    = "inkr";
$Lang{backupType_active}  = "active";
$Lang{backupType_partial} = "cząstwkowy";

$Lang{failed} = "nieudany";
$Lang{success} = "udany";
$Lang{and} = "oraz";

# ------
# Hosts states and reasons
$Lang{Status_idle} = "bezczynny";
$Lang{Status_backup_starting} = "kopia w drodze";
$Lang{Status_backup_in_progress} = "kopia w trakcie tworzenia";
$Lang{Status_restore_starting} = "przywracanie w drodze";
$Lang{Status_restore_in_progress} = "przywracanie w trakcie tworzenia";
$Lang{Status_admin_pending} = "link wtrakcie";
$Lang{Status_admin_running} = "link działa";

$Lang{Reason_backup_done}    = "zrobione";
$Lang{Reason_restore_done}   = "przywracanie zrobione";
$Lang{Reason_archive_done}   = "archiwum zrobione";
$Lang{Reason_nothing_to_do}  = "bezczynny";
$Lang{Reason_backup_failed}  = "kopia nieudana";
$Lang{Reason_restore_failed} = "przywracanie nieudane";
$Lang{Reason_archive_failed} = "archiwizacja nieudana";
$Lang{Reason_no_ping}        = "nie ma pingu";
$Lang{Reason_backup_canceled_by_user}  = "kopia przerwana przez użytwkonika";
$Lang{Reason_restore_canceled_by_user} = "przywracanie przerwane przez użytkownika";
$Lang{Reason_archive_canceled_by_user} = "archiwum przerwane przez użytwkonika";
$Lang{Disabled_OnlyManualBackups}  = "automat wyłączony";  
$Lang{Disabled_AllBackupsDisabled} = "wyłączony";                  


# ---------
# Email messages

# No backup ever
$Lang{EMailNoBackupEverSubj} = "BackupPC: żadna kopia \$host niepowiodła się";
$Lang{EMailNoBackupEverMesg} = <<'EOF';
Do: $user$domain
cc:
Temat: $subj
$headers
Drogi $userName,

Twoj PC ($host) nigdy nie został zabespieczony przez nasz program 
tworzenia kopii bezpieczeństwa.  Backup powinien nastąpic automatycznie 
kiedy twoj PC zostanie podłączony do sieci.  Powinieneś skontaktować się
z pomocą techniczną jeżeli:

  - Twój PC jest cały czas podłączony , co oznacza ze wysteuje problem z konfiguracją 
    uniemożliwiający tworzenie kopii.

  - Nie chcesz aby kopie były wykonywane i nie chcesz tych wiadomośći.

Inaczej, proszę sprawdzić czy twój PC jest podłączony do sieci
nastepnym razem kiedy bedziesz przy nim.

Pozdrawiam ,
Czarodziej BackupPC
http://backuppc.sourceforge.net
EOF

# No recent backup
$Lang{EMailNoBackupRecentSubj} = "BackupPC: żadnych nowych kopii na \$host";
$Lang{EMailNoBackupRecentMesg} = <<'EOF';
Do: $user$domain
cc:
Temat: $subj
$headers
Drogi $userName,

Twój PC ($host) nie był pomyślnie zarchiwizowany przez $days dni.
Twój PC był poprawnie zarchiwizowany $numBackups razy, od $firstTime do $days
temu.  Wykonywanie kopii bezpieczeństwa powinno nastąpić automatycznie po 
podłączeniu do śieci.

Jeżeli twoj PC był podłączony więcej niż kilka godzin do
sieci w czasie ostatnich $days dni powinieneś skontaktować sie z pomocą
techniczą czemu twoje kopie nie działają.

Inaczej , jeżeli jestes poza miejscem pracy nie możesz zrobić więcej niz
skopiować samemu najważniejsze dane na odpowiedni nośnik.
Musisz wiedzieć ze wszystkie pliki które stworzyłeś lub
zmieniłeś przez ostatnie $days dni (włącznie z nowymi emailami
i załącznikami) nie będą przywrócone jeżeli dysk ulegnie awarii.

Pozdrowienia,
Czarodziej BackupPC
http://backuppc.sourceforge.net
EOF

# Old Outlook files
$Lang{EMailOutlookBackupSubj} = "BackupPC: Outlook files on \$host need to be backed up";
$Lang{EMailOutlookBackupMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
Dear $userName,

The Outlook files on your PC have $howLong.
These files contain all your email, attachments, contact and calendar           
information.  Your PC has been correctly backed up $numBackups times from
$firstTime to $lastTime days ago.  However, Outlook locks all its files when
it is running, preventing these files from being backed up.

It is recommended you backup the Outlook files when you are connected
to the network by exiting Outlook and all other applications, and,
using just your browser, go to this link:

    $CgiURL?host=$host               

Select "Start Incr Backup" twice to start a new incremental backup.
You can select "Return to $host page" and then hit "reload" to check
the status of the backup.  It should take just a few minutes to
complete.

Regards,
BackupPC Genie
http://backuppc.sourceforge.net
EOF

$Lang{howLong_not_been_backed_up} = "utworzenie kopii nie zostało zakonczone pomyślnie";
$Lang{howLong_not_been_backed_up_for_days_days} = "Kopia nie była tworzona od \$days dni";

#######################################################################
# RSS strings
#######################################################################
$Lang{RSS_Doc_Title}       = "Serwer BackupPC";
$Lang{RSS_Doc_Description} = "Kanał RSS dla BackupPC";
$Lang{RSS_Host_Summary}    = <<EOF;
Pełna Ilość: \$fullCnt;
Całkowita liczba/dni: \$fullAge;
Calkowity rozmiar/GiB: \$fullSize;
Prędkość MB/sek: \$fullRate;
Ilość Inkr: \$incrCnt;
Inkr wiek/Dni: \$incrAge;
Status: \$host_state;
Ostatnia próba: \$host_last_attempt;
EOF

#######################################################################
# Configuration editor strings
#######################################################################

$Lang{Only_privileged_users_can_edit_config_files} = "Tylko uprzywilejowani uzytwkonicy mogą edytować pliki konfiguracyjne.";
$Lang{CfgEdit_Edit_Config} = "Edytuj konfigurację";
$Lang{CfgEdit_Edit_Hosts}  = "Edytuj Hosty";

$Lang{CfgEdit_Title_Server} = "Serwer";
$Lang{CfgEdit_Title_General_Parameters} = "Parametry Ogólne";
$Lang{CfgEdit_Title_Wakeup_Schedule} = "Plan pobudek";
$Lang{CfgEdit_Title_Concurrent_Jobs} = "Prace Równoległe";
$Lang{CfgEdit_Title_Pool_Filesystem_Limits} = "Limity puli systemu plików";
$Lang{CfgEdit_Title_Other_Parameters} = "Inne Parametry";
$Lang{CfgEdit_Title_Remote_Apache_Settings} = "Zdalne ustawienia Apache";
$Lang{CfgEdit_Title_Program_Paths} = "Ścieżki Programów";
$Lang{CfgEdit_Title_Install_Paths} = "Ścieżki Instalacji";
$Lang{CfgEdit_Title_Email} = "Email";
$Lang{CfgEdit_Title_Email_settings} = "Ustawienia Email";
$Lang{CfgEdit_Title_Email_User_Messages} = "Wiadomości Email do użytwkoników";
$Lang{CfgEdit_Title_CGI} = "CGI";
$Lang{CfgEdit_Title_Admin_Privileges} = "Prawa dostępu Admina";
$Lang{CfgEdit_Title_Page_Rendering} = "Tworzenie strony";
$Lang{CfgEdit_Title_Paths} = "Ścieżki";
$Lang{CfgEdit_Title_User_URLs} = "URLe użytkownika";
$Lang{CfgEdit_Title_User_Config_Editing} = "Edytowanie konfiguracji użytkownika";
$Lang{CfgEdit_Title_Xfer} = "Xfer";
$Lang{CfgEdit_Title_Xfer_Settings} = "Ustawienia Xfer";
$Lang{CfgEdit_Title_Ftp_Settings} = "Ustawienia FTP";
$Lang{CfgEdit_Title_Smb_Settings} = "Ustawienia Smb";
$Lang{CfgEdit_Title_Tar_Settings} = "Ustawienia Tar";
$Lang{CfgEdit_Title_Rsync_Settings} = "Ustawienia Rsync";
$Lang{CfgEdit_Title_Rsyncd_Settings} = "Ustawienia Rsyncd";
$Lang{CfgEdit_Title_Archive_Settings} = "Ustawienia Archiwizacji";
$Lang{CfgEdit_Title_Include_Exclude} = "Dodaj/Usuń";
$Lang{CfgEdit_Title_Smb_Paths_Commands} = "Ściezki/Polecenia Smb";
$Lang{CfgEdit_Title_Tar_Paths_Commands} = "Ściezki/Polecenia Tar";
$Lang{CfgEdit_Title_Rsync_Paths_Commands_Args} = "Ściezki/Polecenia/Argumenty Rsync";
$Lang{CfgEdit_Title_Rsyncd_Port_Args} = "Porty/Argumenty Rsyncds";
$Lang{CfgEdit_Title_Archive_Paths_Commands} = "Ściezki/PoleceniaArchive";
$Lang{CfgEdit_Title_Schedule} = "Harmonogram";
$Lang{CfgEdit_Title_Full_Backups} = "Pełne Kopie";
$Lang{CfgEdit_Title_Incremental_Backups} = "Kopie Inkrementalne";
$Lang{CfgEdit_Title_Blackouts} = "Przeciążenia";
$Lang{CfgEdit_Title_Other} = "Inne";
$Lang{CfgEdit_Title_Backup_Settings} = "Ustawienia Kopii";
$Lang{CfgEdit_Title_Client_Lookup} = "Sprawdzenie klienta";
$Lang{CfgEdit_Title_User_Commands} = "Polecenia dla użytkownika";
$Lang{CfgEdit_Title_Hosts} = "Hosty";

$Lang{CfgEdit_Hosts_Comment} = <<EOF;
Aby dodać nowego hosta, zaznacz "Dodaj" i podaj jego nazwę.  Aby
skopiowac ustawienia z innego hosta, wpisz nazwę hosta jako
NOWYHOST=KOPIOWANYHOST.  Takie ustawienie spowoduje nadpisanie 
konfiguracji dla NOWYHOST .  Możesz zrobic to także dla istniejacych
już hostów.  Aby skasować hosta, po prostu naciśnij "Kasuj".  "Dodaj", "Skasuj",
oraz kopia konfiguracji, nie zadziała puki nie naciśniesz "Zapisz".
Także zadna z usuniętych kopii hostów,więc jeżeli przypadkowo skasujesz coś, 
po prostu znowu ją dodaj.  Aby całkowicie usunąć kopie bezpieczeństwa
danego hosta, musisz manualnie usunąć pliki z katalogu \$topDir/pc/HOST
EOF

$Lang{CfgEdit_Header_Main} = <<EOF;
\${h1("Główny Edytor Konfiguracji")}
EOF

$Lang{CfgEdit_Header_Host} = <<EOF;
\${h1("Edytor Konfiguracji Hosta \$host")}
<p>
Notka: Sprawdź opcję "Nadpisz" jeżeli chcesz zmienić wartość specificzną dla tego hosta.
<p>
EOF

$Lang{CfgEdit_Button_Save}     = "Zapisz";
$Lang{CfgEdit_Button_Insert}   = "Wstaw";
$Lang{CfgEdit_Button_Delete}   = "Kasuj";
$Lang{CfgEdit_Button_Add}      = "Dodaj";
$Lang{CfgEdit_Button_Override} = "Nadpisz";
$Lang{CfgEdit_Button_New_Key}  = "Nowy Klucz";

$Lang{CfgEdit_Error_No_Save}
            = "Błąd: Nie zapisano z powodu błędów";
$Lang{CfgEdit_Error__must_be_an_integer}
            = "Błąd: \$var musi być liczbą całkowitą";
$Lang{CfgEdit_Error__must_be_real_valued_number}
            = "Błąd: \$var musi być liczbą rzeczywistą";
$Lang{CfgEdit_Error__entry__must_be_an_integer}
            = "Błąd: \$var wpis \$k musi być liczbą całkowitą";
$Lang{CfgEdit_Error__entry__must_be_real_valued_number}
            = "Błąd: \$var wpis \$k musi być liczbą rzeczywistą";
$Lang{CfgEdit_Error__must_be_executable_program}
            = "Błąd: \$var musi być poprawną ścieżką do programu wykonywalnego";
$Lang{CfgEdit_Error__must_be_valid_option}
            = "Błąd: \$var musi być poprawną opcją";
$Lang{CfgEdit_Error_Copy_host_does_not_exist}
            = "Kopiowany host \$copyHost nie istnieje; tworzę nową nazwę \$fullHost.  Skasuj ją jeżeli to nie to co chciałeś.";

$Lang{CfgEdit_Log_Copy_host_config}
            = "Skopiowano konfigurację \$User z \$fromHost do \$host\n";
$Lang{CfgEdit_Log_Delete_param}
            = "\$User skasowany \$p z \$conf\n";
$Lang{CfgEdit_Log_Add_param_value}
            = "\$User dodany \$p do \$conf, ustawiono \$value\n";
$Lang{CfgEdit_Log_Change_param_value}
            = "\$User zmieniony \$p w \$conf na \$valueNew z \$valueOld\n";
$Lang{CfgEdit_Log_Host_Delete}
            = "\$User skasował host \$host\n";
$Lang{CfgEdit_Log_Host_Change}
            = "\$User z hosta \$host zmienił \$key z \$valueOld na \$valueNew\n";
$Lang{CfgEdit_Log_Host_Add}
            = "\$User dodał host \$host: \$value\n";
  
#end of lang_en.pm
