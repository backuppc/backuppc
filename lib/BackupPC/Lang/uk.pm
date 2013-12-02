#!/usr/bin/perl

# By Serhiy Yakimchuck yakim@yakim.org.ua 02 sept 2012 vor version 3.2.1
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

$Lang{Start_Archive} = "Запустити архівування";
$Lang{Stop_Dequeue_Archive} = "Припинити/видалити з черги";
$Lang{Start_Full_Backup} = " Зробити повний архів";
$Lang{Start_Incr_Backup} = "Зробити інкрементальний архів";
$Lang{Stop_Dequeue_Backup} = "Припилити/видалити з черги";
$Lang{Restore} = "Відновити";

$Lang{Type_full} = "повний";
$Lang{Type_incr} = "інкрементальний";

# -----

$Lang{Only_privileged_users_can_view_admin_options} = "Тільки привілейовані користувачі можуть бачити адмінські налаштування.";
$Lang{H_Admin_Options} = "BackupPC Сервер: Адмінські налаштування";
$Lang{Admin_Options} = "Адмінські налаштування";
$Lang{Admin_Options_Page} = <<EOF;
\${h1(qq{$Lang{Admin_Options}})}
<br>
\${h2("Керування сервером")}
<form name="ReloadForm" action="\$MyURL" method="get">
<input type="hidden" name="action" value="">
<table class="tableStnd">
  <tr><td>Перечитати налаштування сервера:<td><input type="button" value="Перечитати"
     onClick="document.ReloadForm.action.value='Reload';
              document.ReloadForm.submit();">
</table>
</form>
<!--
\${h2("Керування сервером")}
<ul>
  <li><i>Other options can go here... e.g.,</i>
  <li>Edit server configuration
</ul>
-->
EOF

$Lang{Unable_to_connect_to_BackupPC_server} = "Неможливо зв'язатися з сервером BackupPC";
$Lang{Unable_to_connect_to_BackupPC_server_error_message} = <<EOF;
This CGI script (\$MyURL) is unable to connect to the BackupPC
server on \$Conf{ServerHost} port \$Conf{ServerPort}.<br>
The error was: \$err.<br>
Perhaps the BackupPC server is not running or there is a configuration error.
Please report this to your Sys Admin.
EOF

$Lang{Admin_Start_Server} = <<EOF;
\${h1(qq{$Lang{Unable_to_connect_to_BackupPC_server}})}
<form action="\$MyURL" method="get">
The BackupPC server at <tt>\$Conf{ServerHost}</tt> port <tt>\$Conf{ServerPort}</tt>
is not currently running (maybe you just stopped it, or haven't yet started it).<br>
Do you want to start it?
<input type="hidden" name="action" value="startServer">
<input type="submit" value="Start Server" name="ignore">
</form>
EOF

# -----

$Lang{H_BackupPC_Server_Status} = "Статус сервера BackupPC";

$Lang{BackupPC_Server_Status_General_Info}= <<EOF;
\${h2(\"Загальна інформація про сервер\")}

<ul>
<li> PID сервера - \$Info{pid},  на комп'ютері \$Conf{ServerHost},
     версія \$Info{Version}, запущений \$serverStartTime.
<li> Цей статус був згенерований \$now.
<li> Конфігурація останній раз була завантажена \$configLoadTime.
<li> Наступного разу комп\'ютери будуть поставлені до черги \$nextWakeupTime.
<li> Інша інформація:
    <ul>
        <li>\$numBgQueue запитів в черзі на резервне копіювання з часу останнього запуску планувальника,
        <li>\$numUserQueue запитів в черзі користувачів на резервне копіювання,
        <li>\$numCmdQueue запитів в черзі на виконання команд,
        \$poolInfo
        <li>Файлова система пула зайнята на \$Info{DUlastValue}%
            (\$DUlastTime), сьогодняшній максимум \$Info{DUDailyMax}% (\$DUmaxTime)
            вчорашній максимум \$Info{DUDailyMaxPrev}%.
    </ul>
</ul>
EOF

$Lang{BackupPC_Server_Status} = <<EOF;
\${h1(qq{$Lang{H_BackupPC_Server_Status}})}

<p>
\${h2("Запущені зараз завдання")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td> Хост </td>
    <td> Тип </td>
    <td> Користувач </td>
    <td> час запуску </td>
    <td> Команда </td>
    <td align="center"> PID </td>
    <td align="center"> Xfer PID </td>
    <td align="center"> Status </td>
    <td align="center"> Count </td>
    </tr>
\$jobStr
</table>

<p>
\$generalInfo

\${h2("Помилки, що потребують уваги")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> Хост </td>
    <td align="center"> Тип </td>
    <td align="center"> Користувач </td>
    <td align="center"> Остання спроба </td>
    <td align="center"> Деталі </td>
    <td align="center"> Час помилки </td>
    <td> Остання помилка (крім відсутності пінга) </td></tr>
\$statusStr
</table>
EOF

# --------------------------------
$Lang{BackupPC__Server_Summary} = "BackupPC: Зведена інформація по хостах";
$Lang{BackupPC__Archive} = "BackupPC: Архів";
$Lang{BackupPC_Summary} = <<EOF;

\${h1(qq{$Lang{BackupPC__Server_Summary}})}
<p>
<ul>
<li>Цей статус було згенеровано \$now.
<li>Файлова система пула зайнята на \$Info{DUlastValue}%
    (\$DUlastTime), сьогодняшній максимум \$Info{DUDailyMax}% (\$DUmaxTime)
        вчорашній максимум \$Info{DUDailyMaxPrev}%.
</ul>
</p>

\${h2("Хости, що мають резервні копії")}
<p>
Загалом \$hostCntGood хостів, що містять:
<ul>
<li> \$fullTot загальний розмір повних резервних копій \${fullSizeTot}GiB
     (до об\'єднання та стискання),
<li> \$incrTot загальний розмір інкрементальних резервних копій \${incrSizeTot}GiB
     (до об\'єднання та стискання).
</ul>
</p>
<table class="sortable" id="host_summary_backups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> Хост </td>
    <td align="center"> Користувач </td>
    <td align="center"> #Кіль-ть повн. копій </td>
    <td align="center"> Вік повн. копій (дні) </td>
    <td align="center"> Повний розмір (GiB) </td>
    <td align="center"> Швидкість (MB/s) </td>
    <td align="center"> #Кіль-ть інкр. копій </td>
    <td align="center"> Вік інкр. копій (дні) </td>
    <td align="center"> Остання копія (days) </td>
    <td align="center"> Стан </td>
    <td align="center"> #Xfer помилки </td>
    <td align="center"> Остання дія </td></tr>
\$strGood
</table>
<br><br>
\${h2("Хости без резервних копій")}
<p>
Загалом \$hostCntNone хостів без резервних копій.
<p>
<table class="sortable" id="host_summary_nobackups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> Хост </td>
    <td align="center"> Користувач </td>
    <td align="center"> #Кіль-ть повн. копій </td>
    <td align="center"> Вік повн. копій (дні) </td>
    <td align="center"> Повний розмір (GiB) </td>
    <td align="center"> Швидкість (MB/s) </td>
    <td align="center"> #Кіль-ть інкр. копій </td>
    <td align="center"> Вік інкр. копій (дні) </td>
    <td align="center"> Остання копія (days) </td>
    <td align="center"> Стан </td>
    <td align="center"> #Xfer помилки </td>
    <td align="center"> Остання дія </td></tr>
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

Всього \$hostCntGood хостів, що мають повну резервну копію загальним розміром \${fullSizeTot}GiB
<p>
<form name="form1" method="post" action="\$MyURL">
<input type="hidden" name="fcbMax" value="\$checkBoxCnt">
<input type="hidden" name="type" value="1">
<input type="hidden" name="host" value="\${EscHTML(\$archHost)}">
<input type="hidden" name="action" value="Archive">
<table class="tableStnd" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td align=center> Host</td>
    <td align="center"> Користувач </td>
    <td align="center"> Розмір копії </td>
\$strGood
\$checkAllHosts
</table>
</form>
<p>

EOF

$Lang{BackupPC_Archive2} = <<EOF;
\${h1(qq{$Lang{BackupPC__Archive}})}
Архівування наступлих хостів
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
    <td colspan=2><input type="submit" value="Почати архівування" name="ignore"></td>
</tr>
</form>
</table>
EOF

$Lang{BackupPC_Archive2_location} = <<EOF;
<tr>
    <td>Місцезнаходження/Пристрій архіву</td>
    <td><input type="text" value="\$ArchiveDest" name="archive_device"></td>
</tr>
EOF

$Lang{BackupPC_Archive2_compression} = <<EOF;
<tr>
    <td>Стискання</td>
    <td>
    <input type="radio" value="0" name="compression" \$ArchiveCompNone>None<br>
    <input type="radio" value="1" name="compression" \$ArchiveCompGzip>gzip<br>
    <input type="radio" value="2" name="compression" \$ArchiveCompBzip2>bzip2
    </td>
</tr>
EOF

$Lang{BackupPC_Archive2_parity} = <<EOF;
<tr>
    <td>Відсоток даних парності (0 = disable, 5 = typical)</td>
    <td><input type="numeric" value="\$ArchivePar" name="par"></td>
</tr>
EOF

$Lang{BackupPC_Archive2_split} = <<EOF;
<tr>
    <td>Розділити на частини</td>
    <td><input type="numeric" value="\$ArchiveSplit" name="splitsize">Megabytes</td>
</tr>
EOF

# -----------------------------------
$Lang{Pool_Stat} = <<EOF;
        <li>Пул займає \${poolSize}GiB в тому числі \$info->{"\${name}FileCnt"} файлів
            та \$info->{"\${name}DirCnt"} тек (на \$poolTime),
        <li>Під час хешування пулу виявлено \$info->{"\${name}FileCntRep"} файлів що 
            повторюються з найбільшою кількістю повторень \$info->{"\${name}FileRepMax"},
        <li>Під час нічного очищення видалено \$info->{"\${name}FileCntRm"} файлів 
            загальним розміром \${poolRmSize}GiB (близько \$poolTime),
EOF

# --------------------------------
$Lang{BackupPC__Backup_Requested_on__host} = "BackupPC: Запит на резервне копіювання з \$host";
# --------------------------------
$Lang{REPLY_FROM_SERVER} = <<EOF;
\${h1(\$str)}
<p>
Відповідь з сервера: \$reply
<p>
Повернутися на сторінку хоста <a href="\$MyURL?host=\$host">\$host </a>.
EOF
# --------------------------------
$Lang{BackupPC__Start_Backup_Confirm_on__host} = "BackupPC: Start Backup Confirm on \$host";
# --------------------------------
$Lang{Are_you_sure_start} = <<EOF;
\${h1("Ви впевнені?")}
<p>
Резервне \$type копіювання на \$host.

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="hostIP" value="\$ipAddr">
<input type="hidden" name="doit" value="1">
<input type="hidden" name="action" value="">
Ви дійсно хочете це зробити?
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="No" name="ignore">
</form>
EOF
# --------------------------------
$Lang{BackupPC__Stop_Backup_Confirm_on__host} = "BackupPC: Stop Backup Confirm on \$host";
# --------------------------------
$Lang{Are_you_sure_stop} = <<EOF;

\${h1("Ви впевнені?")}

<p>
Ви зупиняєте/видаляєте з черги резервне копіювання на \$host;

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host"   value="\$host">
<input type="hidden" name="doit"   value="1">
<input type="hidden" name="action" value="">
Also, please don\'t start another backup for
<input type="text" name="backoff" size="10" value="\$backoff"> hours.
<p>
Ви дійсно хочете це зробити?
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="No" name="ignore">
</form>

EOF
# --------------------------------
$Lang{Only_privileged_users_can_view_queues_} = "Тільки привілейовані користувачі можуть переглядати черги.";
# --------------------------------
$Lang{Only_privileged_users_can_archive} = "Тільки привілейовані користувачі можуть створювати резервну копію.";
# --------------------------------
$Lang{BackupPC__Queue_Summary} = "BackupPC: Зведена інформація по чергам завдань";
# --------------------------------
$Lang{Backup_Queue_Summary} = <<EOF;
\${h1("Зведена інформація по чергам завдань")}
<br><br>
\${h2("Черга завдань користувачів")}
<p>
Наступні запити користувачів поставлені до черги:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Хост </td>
    <td> Час запиту </td>
    <td> Користувач </td></tr>
\$strUser
</table>
<br><br>

\${h2("Зведена інформація по фоновій черзі")}
<p>
Наступні фонові запити були поставлені до черги:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Хост </td>
    <td> Час запиту </td>
    <td> Користувач </td></tr>
\$strBg
</table>
<br><br>
\${h2("Зведена інформація по черзі команд")}
<p>
Наступні команди були поставлені до черги:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Хост </td>
    <td> Час запиту </td>
    <td> Користувач </td>
    <td> Команда </td></tr>
\$strCmd
</table>
EOF

# --------------------------------
$Lang{Backup_PC__Log_File__file} = "BackupPC: Файли \$file";
$Lang{Log_File__file__comment} = <<EOF;
\${h1("Файл \$file \$comment")}
<p>
EOF
# --------------------------------
$Lang{Contents_of_log_file} = <<EOF;
Вміст файлу <tt>\$file</tt>, було змінено \$mtimeStr \$comment
EOF

# --------------------------------
$Lang{skipped__skipped_lines} = "[ пропущено \$skipped рядків ]\n";
# --------------------------------
$Lang{_pre___Can_t_open_log_file__file} = "<pre>\nНе вдається відкрити файл логу \$file\n";

# --------------------------------
$Lang{BackupPC__Log_File_History} = "BackupPC: Історія лог-файлу";
$Lang{Log_File_History__hdr} = <<EOF;
\${h1("Історія лог-файлу \$hdr")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Файл </td>
    <td align="center"> Розмір </td>
    <td align="center"> Час зміни </td></tr>
\$str
</table>
EOF

# -------------------------------
$Lang{Recent_Email_Summary} = <<EOF;
\${h1("Останні поштові відправлення (В зворотньому порядку)")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Отримувач </td>
    <td align="center"> Хост </td>
    <td align="center"> Час </td>
    <td align="center"> Тема </td></tr>
\$str
</table>
EOF
 

# ------------------------------
$Lang{Browse_backup__num_for__host} = "BackupPC: Продивитися резервну копію \$num для \$host";

# ------------------------------
$Lang{Restore_Options_for__host} = "BackupPC: Налаштування відновлення для \$host";
$Lang{Restore_Options_for__host2} = <<EOF;
\${h1("Restore Options for \$host")}
<p>
You have selected the following files/directories from
Ви позначили ластупні файли/теки з 
ресурсу \$share, номер резервної копіїr #\$num:
<ul>
\$fileListStr
</ul>
</p><p>
У Вас є три варіанта відновлення обраних файлів/тек.
Виберіть, будь ласка, один з них:
</p>
\${h2("Варіант 1: Пряме відновлення")}
<p>
EOF

$Lang{Restore_Options_for__host_Option1} = <<EOF;
Ви можете запустити відновлення файла прямо на 
<b>\$directHost</b>.
</p><p>
<b>Увага!:</b> Всі існуючі файли будуть перезаписані!
</p>
<form action="\$MyURL" method="post" name="direct">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="3">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<table class="tableStnd" border="0">
<tr>
    <td>Restore the files to host</td>
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
	 <!--<a href="javascript:myOpen('\$MyURL?action=findShares&host='+document.direct.hostDest.options.value)">Search for available shares (NOT IMPLEMENTED)</a>--></td>
</tr><tr>
    <td>Restore the files to share</td>
    <td><input type="text" size="40" value="\${EscHTML(\$share)}"
	 name="shareDest"></td>
</tr><tr>
    <td>Restore the files below dir<br>(relative to share)</td>
    <td valign="top"><input type="text" size="40" maxlength="256"
	value="\${EscHTML(\$pathHdr)}" name="pathHdr"></td>
</tr><tr>
    <td><input type="submit" value="Start Restore" name="ignore"></td>
</table>
</form>
EOF

$Lang{Restore_Options_for__host_Option1_disabled} = <<EOF;
Пряме відновлення заборонене для хоста \${EscHTML(\$hostDest)}.
Будб ласка оберіть інший варіант відновлення.
EOF

# ------------------------------
$Lang{Option_2__Download_Zip_archive} = <<EOF;
<p>
\${h2("Варіант 2: Звантажити Zip архів")}
<p>
Ви можете звантажити zip-архів, що буде містити всі обрані файли/теки.
Ви можете використати локальну програму, наприклад WinZip, для того
щоб продивитися або відновити будь-які файли.
</p><p>
<b>Увага:</b> в залежності від того, які файли/теки Ви позначили залежить розмір архіву.
Процес його створення та звантаження може зайняти деякий час. Ви маєте бути впевнені, 
що Вам вистачить місця на локальному диску для його збереження.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="2">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Створити архів відносно
 \${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(інакше архів буде містити повні шляхи).
<br>
<table class="tableStnd" border="0">
<tr>
    <td>Compression (0=off, 1=fast,...,9=best)</td>
    <td><input type="text" size="6" value="5" name="compressLevel"></td>
</tr><tr>
    <td>Code page (e.g. cp866)</td>
    <td><input type="text" size="6" value="utf8" name="codePage"></td>
</tr>
</table>
<br>
<input type="submit" value="Download Zip File" name="ignore">
</form>
EOF

# ------------------------------

$Lang{Option_2__Download_Zip_archive2} = <<EOF;
<p>
\${h2("Option 2: Download Zip archive")}
<p>
Archive::Zip не встановлено тому Ви не можете звантажити
zip-архів.
Попросіть системного адміністратора встановити Archive::Zip з 
<a href="http://www.cpan.org">www.cpan.org</a>.
</p>
EOF


# ------------------------------
$Lang{Option_3__Download_Zip_archive} = <<EOF;
\${h2("Option 3: Звантажити Tar архів")}
<p>
Ви можете звантажити tar-архів, що буде містити всі обрані файли/теки.
Ви можете використати локальну програму, наприклад WinZip або tar, для того
щоб продивитися або відновити будь-які файли.
</p><p>
<b>Увага:</b> в залежності від того, які файли/теки Ви позначили залежить розмір архіву.
Процес його створення та звантаження може зайняти деякий час. Ви маєте бути впевнені, 
що Вам вистачить місця на локальному диску для його збереження.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="1">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Створити архів відносно
 \${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(інакше архів буде містити повні шляхи).
<br>
<input type="submit" value="Download Tar File" name="ignore">
</form>
EOF


# ------------------------------
$Lang{Restore_Confirm_on__host} = "BackupPC: Підтвердження відновлення на \$host";

$Lang{Are_you_sure} = <<EOF;
\${h1("Ви впевнені?")}
<p>
Ви починаєте пряме відновлення на комп\'ютер \$In{hostDest}.
Наступні файли будуть відновлені до ресурсу \$In{shareDest}, з
архівної копії номер \$num:
<p>
<table class="tableStnd" border>
<tr class="tableheader"><td>Original file/dir</td><td>Will be restored to</td></tr>
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
Ви дійсно хочете це зробити?
<input type="button" value="\$Lang->{Restore}"
 onClick="document.RestoreForm.action.value='Restore';
          document.RestoreForm.submit();">
<input type="submit" value="No" name="ignore">
</form>
EOF


# --------------------------
$Lang{Restore_Requested_on__hostDest} = "BackupPC: Запит на відновлення до \$hostDest";
$Lang{Reply_from_server_was___reply} = <<EOF;
\${h1(\$str)}
<p>
Відповідь сервера була: \$reply
<p>
Поверніться до <a href="\$MyURL?host=\$hostDest">\$hostDest home page</a>.
EOF

$Lang{BackupPC_Archive_Reply_from_server} = <<EOF;
\${h1(\$str)}
<p>
Відповідь сервера була: \$reply
EOF


# -------------------------
$Lang{Host__host_Backup_Summary} = "BackupPC: Зведена інформація по резервному копіюванню хоста \$host ";

$Lang{Host__host_Backup_Summary2} = <<EOF;
\${h1("Зведена інформація по резервному копіюванню хоста \$host")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>
</p>
\${h2("Дії користувача")}
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
\${h2("Інформація про резервні копії")}
<p>
Натисніть на номер резервної копії для огляду та відновлення файлів з неї.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> Рез. Копія# </td>
    <td align="center"> тип </td>
    <td align="center"> Повний </td>
    <td align="center"> Рівень </td>
    <td align="center"> Дата початку </td>
    <td align="center"> Тривалість/хв </td>
    <td align="center"> Вік/днів </td>
    <td align="center"> Серверний шлях копії </td>
</tr>
\$str
</table>
<p>

\$restoreStr
</p>
<br><br>
\${h2("Зведена інформація про помилки Xfer")}
<br><br>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Backup# </td>
    <td align="center"> Тип </td>
    <td align="center"> Журнал </td>
    <td align="center"> #Xfer помилок </td>
    <td align="center"> #паганих файлів </td>
    <td align="center"> #паганих ресурсів </td>
    <td align="center"> #tar помилок </td>
</tr>
\$errStr
</table>
<br><br>

\${h2("Зведена інформація по файлах")}
<p>
Існуючі файли, це ті, які вже були в пулі; нові файли це ті,
що тільки-но додаються до пулу.
Пусті файли та SMB-помилки не враховуються
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="2" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> Totals </td>
    <td align="center" colspan="2"> Existing Files </td>
    <td align="center" colspan="2"> New Files </td>
</tr>
<tr class="tableheader">
    <td align="center"> Рез. копія# </td>
    <td align="center"> Тип </td>
    <td align="center"> #Файли </td>
    <td align="center"> Розмір/MB </td>
    <td align="center"> MB/с </td>
    <td align="center"> #Файли </td>
    <td align="center"> Розмір/MB </td>
    <td align="center"> #Файли </td>
    <td align="center"> Розмір/MB </td>
</tr>
\$sizeStr
</table>
<br><br>

\${h2("Зведена інформація про стискання")}
<p>
Рівень стискання нових та існуючих файлів.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="3" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> Існуючі файли </td>
    <td align="center" colspan="3"> Нові файли </td>
</tr>
<tr class="tableheader"><td align="center"> Рез. копія# </td>
    <td align="center"> Тип </td>
    <td align="center"> Рівень стиск. </td>
    <td align="center"> Розмір/MB </td>
    <td align="center"> Стиск./MB </td>
    <td align="center"> Стиск </td>
    <td align="center"> Розмір/MB </td>
    <td align="center"> Стиск/MB </td>
    <td align="center"> Стиск </td>
</tr>
\$compStr
</table>
<br><br>
EOF

$Lang{Host__host_Archive_Summary} = "BackupPC: Host \$host Archive Summary";
$Lang{Host__host_Archive_Summary2} = <<EOF;
\${h1("Host \$host Archive Summary")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>

\${h2("Дії користувачів")}
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
$Lang{Error} = "BackupPC: Помилки";
$Lang{Error____head} = <<EOF;
\${h1("Помилка: \$head")}
<p>\$mesg</p>
EOF

# -------------------------
$Lang{NavSectionTitle_} = "Сервер";

# -------------------------
$Lang{Backup_browse_for__host} = <<EOF;
\${h1("Продивитися резервні копії для \$host")}

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
<li> You are browsing backup #\$num, which started around \$backupTime
        (\$backupAge days ago),
\$filledBackup
<li> Увійти в текуy: <input type="text" name="dir" size="50" maxlength="4096" value="\${EscHTML(\$dir)}"> <input type="submit" value="\$Lang->{Go}" name="Submit">
<li> Натисніть на теку нижче для входу в неї,
<li> Натисніть на файл нижче для його відновлення,
<li> Ви можете переглянути резервну копію <a href="\$MyURL?action=dirHistory&host=\${EscURI(\$host)}&share=\$shareURI&dir=\$pathURI">history</a> of the current directory.
</ul>
</form>

\${h2("Contents of \$dirDisplay")}
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
$Lang{DirHistory_backup_for__host} = "BackupPC: Історія резервних копій тек для \$host";

#
# These two strings are used to build the links for directories and
# file versions.  Files are appended with a version number.
#
$Lang{DirHistory_dirLink}  = "dir";
$Lang{DirHistory_fileLink} = "v";

$Lang{DirHistory_for__host} = <<EOF;
\${h1("Історія резервних копій тек для \$host")}
<p>
Тут відображені всі унікальні версії файлів в усіх
Резервних копіях:
<ul>
<li> Натисніть на номер резервної копії для повернення до перегляду рез. копій,
<li> Натисніть на посилання на теку (\$Lang->{DirHistory_dirLink}) для переходу 
     в цю теку,
<li> Натисніть на посилання на версію файла (\$Lang->{DirHistory_fileLink}0,
     \$Lang->{DirHistory_fileLink}1, ...) для його звантаженняe,
<li> Фали з однаковим вмістом мають однакову версію в усіх
      резервних копіях,
<li> Файли та теки, що відсутні в поточній резервній копії позначені 
     порожнім прямокутником.
<li> Файли однієї версії можуть відрізнятися атрибутами файлової системи.
     Виберіть номмер резервної копії для перегляду атрибутів.
</ul>

\${h2("Історія \$dirDisplay")}

<br>
<table border cellspacing="2" cellpadding="3">
<tr class="fviewheader"><td>Backup number</td>\$backupNumStr</tr>
<tr class="fviewheader"><td>Backup time</td>\$backupTimeStr</tr>
\$fileStr
</table>
EOF

# ------------------------------
$Lang{Restore___num_details_for__host} = "BackupPC: Подробиці відновлення  #\$num для \$host";

$Lang{Restore___num_details_for__host2} = <<EOF;
\${h1("Подробиці відновлення #\$num для \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="90%">
<tr><td class="tableheader"> Номер </td><td class="border"> \$Restores[\$i]{num} </td></tr>
<tr><td class="tableheader"> Запит від </td><td class="border"> \$RestoreReq{user} </td></tr>
<tr><td class="tableheader"> Час запиту </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> Результат </td><td class="border"> \$Restores[\$i]{result} </td></tr>
<tr><td class="tableheader"> Повідомлення про помилки </td><td class="border"> \$Restores[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> Хост джерело </td><td class="border"> \$RestoreReq{hostSrc} </td></tr>
<tr><td class="tableheader"> Номер вихідн. рез. копії </td><td class="border"> \$RestoreReq{num} </td></tr>
<tr><td class="tableheader"> Вихідний ресурс </td><td class="border"> \$RestoreReq{shareSrc} </td></tr>
<tr><td class="tableheader"> Хост призначення </td><td class="border"> \$RestoreReq{hostDest} </td></tr>
<tr><td class="tableheader"> Ресурс призначення </td><td class="border"> \$RestoreReq{shareDest} </td></tr>
<tr><td class="tableheader"> Час початку </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Тривалість </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> Кільк. файлів </td><td class="border"> \$Restores[\$i]{nFiles} </td></tr>
<tr><td class="tableheader"> Загальний розмір </td><td class="border"> \${MB} MB </td></tr>
<tr><td class="tableheader"> Швидкість передачі </td><td class="border"> \$MBperSec MB/sec </td></tr>
<tr><td class="tableheader"> TarCreate помилки </td><td class="border"> \$Restores[\$i]{tarCreateErrs} </td></tr>
<tr><td class="tableheader"> Xfer помилки </td><td class="border"> \$Restores[\$i]{xferErrs} </td></tr>
<tr><td class="tableheader"> Xfer log file </td><td class="border">
<a href="\$MyURL?action=view&type=RestoreLOG&num=\$Restores[\$i]{num}&host=\$host">View</a>,
<a href="\$MyURL?action=view&type=RestoreErr&num=\$Restores[\$i]{num}&host=\$host">Errors</a>
</tr></tr>
</table>
</p>
\${h1("Файл/Список тек")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="100%">
<tr class="tableheader"><td>Original file/dir</td><td>Restored to</td></tr>
\$fileListStr
</table>
EOF

# ------------------------------
$Lang{Archive___num_details_for__host} = "BackupPC: Деталі архіву #\$num для \$host";

$Lang{Archive___num_details_for__host2 } = <<EOF;
\${h1("Archive #\$num Details for \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr><td class="tableheader"> Номер </td><td class="border"> \$Archives[\$i]{num} </td></tr>
<tr><td class="tableheader"> Запит від </td><td class="border"> \$ArchiveReq{user} </td></tr>
<tr><td class="tableheader"> Час запиту </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> Результат </td><td class="border"> \$Archives[\$i]{result} </td></tr>
<tr><td class="tableheader"> Помилки </td><td class="border"> \$Archives[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> Час початку </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Тривалість </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> Xfer log файл </td><td class="border">
<a href="\$MyURL?action=view&type=ArchiveLOG&num=\$Archives[\$i]{num}&host=\$host">View</a>,
<a href="\$MyURL?action=view&type=ArchiveErr&num=\$Archives[\$i]{num}&host=\$host">Errors</a>
</tr></tr>
</table>
<p>
\${h1("Host list")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td>Хост</td><td>Номер резерв. копії</td></tr>
\$HostListStr
</table>
EOF

# -----------------------------------
$Lang{Email_Summary} = "BackupPC: Зведена інформація по Email";

# -----------------------------------
#  !! ERROR messages !!
# -----------------------------------
$Lang{BackupPC__Lib__new_failed__check_apache_error_log} = "BackupPC::Lib->new failed: check apache error_log\n";
$Lang{Wrong_user__my_userid_is___} =  
              "Неправильний користувач: мій userid  \$>, а не \$uid"
            . "(\$Conf{BackupPCUser})\n";
# $Lang{Only_privileged_users_can_view_PC_summaries} = "Only privileged users can view PC summaries.";
$Lang{Only_privileged_users_can_stop_or_start_backups} = 
                  "Тільки привілейований користувач може запустити резевне копіювання на"
		. " \${EscHTML(\$host)}.";
$Lang{Invalid_number__num} = "Неправильнмй номер \${EscHTML(\$In{num})}";
$Lang{Unable_to_open__file__configuration_problem} = "Неможливо відкрити \$file: проблеми з конфігурацією?";
$Lang{Only_privileged_users_can_view_log_or_config_files} = "Тільки привілейований користувач може переглядати log чи файл конфігурації.";
$Lang{Only_privileged_users_can_view_log_files} = "Тільки привілейований користувач може переглядати log файли.";
$Lang{Only_privileged_users_can_view_email_summaries} = "Тільки привілейований користувач може переглядати інформацію про email.";
$Lang{Only_privileged_users_can_browse_backup_files} = "Тільки привілейований користувач може переглядати файли резервних копій"
                . " для хосту \${EscHTML(\$In{host})}.";
$Lang{Empty_host_name} = "Порожнє ім\'я хоста.";
$Lang{Directory___EscHTML} = "Тека \${EscHTML(\"\$TopDir/pc/\$host/\$num\")}"
		    . " порожня";
$Lang{Can_t_browse_bad_directory_name2} = "Не вдається відкрити неправильну назву теки"
	            . " \${EscHTML(\$relDir)}";
$Lang{Only_privileged_users_can_restore_backup_files} = "Тільки привілейований користувач може відновлювати файли з резервних копій"
                . " для хоста \${EscHTML(\$In{host})}.";
$Lang{Bad_host_name} = "Неправильне ім\'я хоста \${EscHTML(\$host)}";
$Lang{You_haven_t_selected_any_files__please_go_Back_to} = "Ви не обрали жодного файла; Будь ласка поверніться назад"
                . " та оберіть якийсь файл.";
$Lang{You_haven_t_selected_any_hosts} = "Ви не обрали жодного хоста; будь ласка поверніться назад"
                . " та оберіть якийсь хост.";
$Lang{Nice_try__but_you_can_t_put} = "Добра спроба, але ви не можете вставити \'..\' у будь яке ім\'я файлу";
$Lang{Host__doesn_t_exist} = "Хост \${EscHTML(\$In{hostDest})} не існує";
$Lang{You_don_t_have_permission_to_restore_onto_host} = "У Вас немає прав відновлення на хост"
		    . " \${EscHTML(\$In{hostDest})}";
$Lang{Can_t_open_create__openPath} = "не можливо відкрити/створити "
		. "\${EscHTML(\"\$openPath\")}";
$Lang{Only_privileged_users_can_restore_backup_files2} = "Тільки привілейований користувач може відновити резервну копію"
                . " для хоста \${EscHTML(\$host)}.";
$Lang{Empty_host_name} = "Порожнє ім\'я хоста";
$Lang{Unknown_host_or_user} = "Невідомий хост або користувач \${EscHTML(\$host)}";
$Lang{Only_privileged_users_can_view_information_about} = "Тільки привілейований користувач може переглядати інформацію про"
                . " хост \${EscHTML(\$host)}." ;
$Lang{Only_privileged_users_can_view_archive_information} = "Тільки привілейований користувач може переглядати інформацію про архівування.";
$Lang{Only_privileged_users_can_view_restore_information} = "Тільки привілейований користувач може переглядати інформацію про відновлення.";
$Lang{Restore_number__num_for_host__does_not_exist} = "Номер відновлення \$num для хосту \${EscHTML(\$host)} не"
	        . " існує.";
$Lang{Archive_number__num_for_host__does_not_exist} = "Номер архіву \$num для хосту \${EscHTML(\$host)} не"
                . " існує.";
$Lang{Can_t_find_IP_address_for} = "Неможливо знайти IP адресу для \${EscHTML(\$host)}";
$Lang{host_is_a_DHCP_host} = <<EOF;
\$host отримує адресу по DHCP і я не знаю його IP адреси.  Я перевірив
netbios ім\'я \$ENV{REMOTE_ADDR}\$tryIP, та виявим, що цей комп\'ютер не є
 \$host.
<p>
Наскільки я бачу \$host має приватну DHCP адресу, Ви маєте можливість
запустити запит з клієнтського комп\'ютера самостійно.
EOF

# ------------------------------------
# !! Server Mesg !!
# ------------------------------------

$Lang{Backup_requested_on_DHCP__host} = "Запит на резерв. копіювання на DHCP \$host (\$In{hostIP}) від"
		                      . " \$User з \$ENV{REMOTE_ADDR}";
$Lang{Backup_requested_on__host_by__User} = "Запит на резерв. копіювання з \$host від \$User";
$Lang{Backup_stopped_dequeued_on__host_by__User} = "Резерв. копіювання зупинено/виключено з черги на \$host від \$User";
$Lang{Restore_requested_to_host__hostDest__backup___num} = "Запит на відновлення на \$hostDest, резерв. копія #\$num,"
	     . " від \$User на \$ENV{REMOTE_ADDR}";
$Lang{Archive_requested} = "Запит на архів від \$User на \$ENV{REMOTE_ADDR}";

# -------------------------------------------------
# ------- Stuff that was forgotten ----------------
# -------------------------------------------------

$Lang{Status} = "Статус";
$Lang{PC_Summary} = "Зведена інформація по хостам";
$Lang{LOG_file} = "LOG файл";
$Lang{LOG_files} = "LOG файли";
$Lang{Old_LOGs} = "Старі LOGи";
$Lang{Email_summary} = "Поштові налаштування";
$Lang{Config_file} = "Файл конфігурації";
# $Lang{Hosts_file} = "Hosts file";
$Lang{Current_queues} = "Поточні черги";
$Lang{Documentation} = "Документація (англ)";

#$Lang{Host_or_User_name} = "<small>Host or User name:</small>";
$Lang{Go} = "Перейти";
$Lang{Hosts} = "Хости";
$Lang{Select_a_host} = "Виберіть хост...";

$Lang{There_have_been_no_archives} = "<h2> Немає жодної резервної копії </h2>\n";
$Lang{This_PC_has_never_been_backed_up} = "<h2> З цього PC ніколи не створювалась резервна копія!! </h2>\n";
$Lang{This_PC_is_used_by} = "<li>Цей PC використовується \${UserLink(\$user)}";

$Lang{Extracting_only_Errors} = "(Показати лише помилки)";
$Lang{XferLOG} = "XferLOG";
$Lang{Errors}  = "Помилки";

# ------------
$Lang{Last_email_sent_to__was_at___subject} = <<EOF;
<li>Останній email було відіслано доo \${UserLink(\$user)} час \$mailTime, тема "\$subj".
EOF
# ------------
$Lang{The_command_cmd_is_currently_running_for_started} = <<EOF;
<li>Команда \$cmd зараз виконується для хоста \$host, started \$startTime.
EOF

# -----------
$Lang{Host_host_is_queued_on_the_background_queue_will_be_backed_up_soon} = <<EOF;
<li>Хост \$host поставлений у фонову чергу (повернеться за першої можливості).
EOF

# ----------
$Lang{Host_host_is_queued_on_the_user_queue__will_be_backed_up_soon} = <<EOF;
<li>Хост \$host поставлений у чергу користувача (повернеться за першої можливості).
EOF

# ---------
$Lang{A_command_for_host_is_on_the_command_queue_will_run_soon} = <<EOF;
<li>Команда для \$host поставлена в чергу команд (скоро буде запущена).
EOF

# --------
$Lang{Last_status_is_state_StatusHost_state_reason_as_of_startTime} = <<EOF;
<li>Last status is state \"\$Lang->{\$StatusHost{state}}\"\$reason as of \$startTime.
EOF

# --------
$Lang{Last_error_is____EscHTML_StatusHost_error} = <<EOF;
<li>Остання помилка \"\${EscHTML(\$StatusHost{error})}\".
EOF

# ------
$Lang{Pings_to_host_have_failed_StatusHost_deadCnt__consecutive_times} = <<EOF;
<li>Ping до \$host не пройшов \$StatusHost{deadCnt} декілька разів підряд.
EOF

# -----
$Lang{Prior_to_that__pings} = "До цього, pings";

# -----
$Lang{priorStr_to_host_have_succeeded_StatusHostaliveCnt_consecutive_times} = <<EOF;
<li>\$priorStr to \$host have succeeded \$StatusHost{aliveCnt}
        consecutive times.
EOF

$Lang{Because__host_has_been_on_the_network_at_least__Conf_BlackoutGoodCnt_consecutive_times___} = <<EOF;
<li>Because \$host has been on the network at least \$Conf{BlackoutGoodCnt}
consecutive times, it will not be backed up from \$blackoutStr.
EOF

$Lang{__time0_to__time1_on__days} = "\$t0 to \$t1 on \$days";

$Lang{Backups_are_deferred_for_hours_hours_change_this_number} = <<EOF;
<li>Резервне копіювання відкладене на \$hours годин
(<a href=\"\$MyURL?action=Stop_Dequeue_Backup&host=\$host\">change this number</a>).
EOF

$Lang{tryIP} = " and \$StatusHost{dhcpHostIP}";

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
    <tr class="fviewheader"><td align=center> Name</td>
       <td align="center"> Тип</td>
       <td align="center"> Режим</td>
       <td align="center"> #</td>
       <td align="center"> Розмір</td>
       <td align="center"> Дата зміни</td>
    </tr>
EOF

$Lang{Home} = "Додому";
$Lang{Browse} = "Продивитися резерв. копії";
$Lang{Last_bad_XferLOG} = "Last bad XferLOG";
$Lang{Last_bad_XferLOG_errors_only} = "Last bad XferLOG (errors&nbsp;only)";

$Lang{This_display_is_merged_with_backup} = <<EOF;
<li> This display is merged with backup #\$numF.
EOF

$Lang{Visit_this_directory_in_backup} = <<EOF;
<li> Оберіть резервну копію, яку Ви хочете продивитися: <select onChange="window.location=this.value">\$otherDirs </select>
EOF

$Lang{Restore_Summary} = <<EOF;
\${h2("Інформація про відновлення")}
<p>
Натисніть на номер для перегляду деталей.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Відновлення# </td>
    <td align="center"> Результат </td>
    <td align="right"> Дата початку</td>
    <td align="right"> Тривал/хи</td>
    <td align="right"> #файлів </td>
    <td align="right"> MB </td>
    <td align="right"> #tar помилок </td>
    <td align="right"> #xfer помилок </td>
</tr>
\$restoreStr
</table>
<p>
EOF

$Lang{Archive_Summary} = <<EOF;
\${h2("Інформація про архіви")}
<p>
Натисніть на номер архіву для перегляду деталей.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Архів# </td>
    <td align="center"> Результат </td>
    <td align="right"> Дата початку</td>
    <td align="right"> Трив/хв</td>
</tr>
\$ArchiveStr
</table>
<p>
EOF

$Lang{BackupPC__Documentation} = "BackupPC: Документація";

$Lang{No} = "ні";
$Lang{Yes} = "так";

$Lang{The_directory_is_empty} = <<EOF;
<tr><td bgcolor="#ffffff">The directory \$dirDisplay is empty
</td></tr>
EOF

#$Lang{on} = "on";
$Lang{off} = "off";

$Lang{backupType_full}    = "повний";
$Lang{backupType_incr}    = "інкрементальний";
$Lang{backupType_active}  = "active";
$Lang{backupType_partial} = "частковий";

$Lang{failed} = "неуспішно";
$Lang{success} = "успішно";
$Lang{and} = "та";

# ------
# Hosts states and reasons
$Lang{Status_idle} = "бездія";
$Lang{Status_backup_starting} = "Резерв. копіювання запущено";
$Lang{Status_backup_in_progress} = "Резерв. копіювання в процесі";
$Lang{Status_restore_starting} = "Відновлення запущено";
$Lang{Status_restore_in_progress} = "Відновлення в процесі";
$Lang{Status_admin_pending} = "link pending";
$Lang{Status_admin_running} = "link running";

$Lang{Reason_backup_done}    = "зроблено";
$Lang{Reason_restore_done}   = "відновлення зроблено";
$Lang{Reason_archive_done}   = "архівування зроблено";
$Lang{Reason_nothing_to_do}  = "бездія";
$Lang{Reason_backup_failed}  = "резерв. копіювання неуспішне";
$Lang{Reason_restore_failed} = "відновлення неуспішне";
$Lang{Reason_archive_failed} = "архівування  неуспішне";
$Lang{Reason_no_ping}        = "no ping";
$Lang{Reason_backup_canceled_by_user}  = "резерв. копіювання перерване користувачем";
$Lang{Reason_restore_canceled_by_user} = "відновлення перерване користувачем";
$Lang{Reason_archive_canceled_by_user} = "архівування перерване користувачем";
$Lang{Disabled_OnlyManualBackups}  = "auto відключене";  
$Lang{Disabled_AllBackupsDisabled} = "відключене";                  


# ---------
# Email messages

# No backup ever
$Lang{EMailNoBackupEverSubj} = "BackupPC: жлдного резерв. копіювання на \$host не було успішним";
$Lang{EMailNoBackupEverMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
Dear $userName,

Your PC ($host) has never been successfully backed up by our
PC backup software.  PC backups should occur automatically
when your PC is connected to the network.  You should contact
computer support if:

  - Your PC has been regularly connected to the network, meaning
    there is some configuration or setup problem preventing
    backups from occurring.

  - You don't want your PC backed up and you want these email
    messages to stop.

Otherwise, please make sure your PC is connected to the network
next time you are in the office.

Regards,
BackupPC Genie
http://backuppc.sourceforge.net
EOF

# No recent backup
$Lang{EMailNoBackupRecentSubj} = "BackupPC: no recent backups on \$host";
$Lang{EMailNoBackupRecentMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
Dear $userName,

Your PC ($host) has not been successfully backed up for $days days.
Your PC has been correctly backed up $numBackups times from $firstTime to $days days
ago.  PC backups should occur automatically when your PC is connected
to the network.

If your PC has been connected for more than a few hours to the
network during the last $days days you should contact IS to find
out why backups are not working.

Otherwise, if you are out of the office, there's not much you can
do, other than manually copying especially critical files to other
media.  You should be aware that any files you have created or
changed in the last $days days (including all new email and
attachments) cannot be restored if your PC disk crashes.

Regards,
BackupPC Genie
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

$Lang{howLong_not_been_backed_up} = "not been backed up successfully";
$Lang{howLong_not_been_backed_up_for_days_days} = "not been backed up for \$days days";

#######################################################################
# RSS strings
#######################################################################
$Lang{RSS_Doc_Title}       = "BackupPC Server";
$Lang{RSS_Doc_Description} = "RSS feed for BackupPC";
$Lang{RSS_Host_Summary}    = <<EOF;
Full Count: \$fullCnt;
Full Age/days: \$fullAge;
Full Size/GiB: \$fullSize;
Speed MB/sec: \$fullRate;
Incr Count: \$incrCnt;
Incr Age/Days: \$incrAge;
State: \$host_state;
Last Attempt: \$host_last_attempt;
EOF

#######################################################################
# Configuration editor strings
#######################################################################

$Lang{Only_privileged_users_can_edit_config_files} = "Only privileged users can edit configuation settings.";
$Lang{CfgEdit_Edit_Config} = "Правити конфігурацію";
$Lang{CfgEdit_Edit_Hosts}  = "Правити хости";

$Lang{CfgEdit_Title_Server} = "Сервер";
$Lang{CfgEdit_Title_General_Parameters} = "Загальні параметри";
$Lang{CfgEdit_Title_Wakeup_Schedule} = "Wakeup Schedule";
$Lang{CfgEdit_Title_Concurrent_Jobs} = "Concurrent Jobs";
$Lang{CfgEdit_Title_Pool_Filesystem_Limits} = "Обмеження файлової системи пула";
$Lang{CfgEdit_Title_Other_Parameters} = "Інші параметри";
$Lang{CfgEdit_Title_Remote_Apache_Settings} = "Налаштування віддаленого Apache";
$Lang{CfgEdit_Title_Program_Paths} = "Шляхи до програми";
$Lang{CfgEdit_Title_Install_Paths} = "Шлях встановлення";
$Lang{CfgEdit_Title_Email} = "Email";
$Lang{CfgEdit_Title_Email_settings} = "Налаштування Email";
$Lang{CfgEdit_Title_Email_User_Messages} = "Email User Messages";
$Lang{CfgEdit_Title_CGI} = "CGI";
$Lang{CfgEdit_Title_Admin_Privileges} = "Admin Privileges";
$Lang{CfgEdit_Title_Page_Rendering} = "Page Rendering";
$Lang{CfgEdit_Title_Paths} = "Шляхи";
$Lang{CfgEdit_Title_User_URLs} = "User URLs";
$Lang{CfgEdit_Title_User_Config_Editing} = "User Config Editing";
$Lang{CfgEdit_Title_Xfer} = "Xfer";
$Lang{CfgEdit_Title_Xfer_Settings} = "Налаштування Xfer";
$Lang{CfgEdit_Title_Ftp_Settings} = "Налаштування FTP";
$Lang{CfgEdit_Title_Smb_Settings} = "Налаштування Smb";
$Lang{CfgEdit_Title_Tar_Settings} = "Налаштування Tar";
$Lang{CfgEdit_Title_Rsync_Settings} = "Налаштування Rsync";
$Lang{CfgEdit_Title_Rsyncd_Settings} = "Налаштування Rsyncd";
$Lang{CfgEdit_Title_Archive_Settings} = "Налаштування архівування";
$Lang{CfgEdit_Title_Include_Exclude} = "Включити/Виключити";
$Lang{CfgEdit_Title_Smb_Paths_Commands} = "Шляхи/команди Smb";
$Lang{CfgEdit_Title_Tar_Paths_Commands} = "Шляхи/команди Tar";
$Lang{CfgEdit_Title_Rsync_Paths_Commands_Args} = "Шляхи/команди/аргументи Rsync";
$Lang{CfgEdit_Title_Rsyncd_Port_Args} = "Порт/аргументи Rsyncd";
$Lang{CfgEdit_Title_Archive_Paths_Commands} = "Шляхи/команди архівування";
$Lang{CfgEdit_Title_Schedule} = "Планувальник";
$Lang{CfgEdit_Title_Full_Backups} = "Повне резерв. копіювання";
$Lang{CfgEdit_Title_Incremental_Backups} = "Інкрементальне резерв. копіювання";
$Lang{CfgEdit_Title_Blackouts} = "Blackouts";
$Lang{CfgEdit_Title_Other} = "Інше";
$Lang{CfgEdit_Title_Backup_Settings} = "Налаштування резерв. копіювання";
$Lang{CfgEdit_Title_Client_Lookup} = "Пошук клієнтів";
$Lang{CfgEdit_Title_User_Commands} = "Команди користувача";
$Lang{CfgEdit_Title_Hosts} = "Хости";

$Lang{CfgEdit_Hosts_Comment} = <<EOF;
To add a new host, select Add and then enter the name.  To start with
the per-host configuration from another host, enter the host name
as NEWHOST=COPYHOST.  This will overwrite any existing per-host
configuration for NEWHOST.  You can also do this for an existing
host.  To delete a host, hit the Delete button.  For Add, Delete,
and configuration copy, changes don't take effect until you select
Save.  None of the deleted host's backups will be removed,
so if you accidently delete a host, simply re-add it.  To completely
remove a host's backups, you need to manually remove the files
below \$topDir/pc/HOST
EOF

$Lang{CfgEdit_Header_Main} = <<EOF;
\${h1("Main Configuration Editor")}
EOF

$Lang{CfgEdit_Header_Host} = <<EOF;
\${h1("Host \$host Configuration Editor")}
<p>
Note: Check Override if you want to modify a value specific to this host.
<p>
EOF

$Lang{CfgEdit_Button_Save}     = "Зберегти";
$Lang{CfgEdit_Button_Insert}   = "Вставити";
$Lang{CfgEdit_Button_Delete}   = "Видалити";
$Lang{CfgEdit_Button_Add}      = "Додати";
$Lang{CfgEdit_Button_Override} = "Перезаписати";
$Lang{CfgEdit_Button_New_Key}  = "Нове значення";

$Lang{CfgEdit_Error_No_Save}
            = "Error: No save due to errors";
$Lang{CfgEdit_Error__must_be_an_integer}
            = "Error: \$var must be an integer";
$Lang{CfgEdit_Error__must_be_real_valued_number}
            = "Error: \$var must be a real-valued number";
$Lang{CfgEdit_Error__entry__must_be_an_integer}
            = "Error: \$var entry \$k must be an integer";
$Lang{CfgEdit_Error__entry__must_be_real_valued_number}
            = "Error: \$var entry \$k must be a real-valued number";
$Lang{CfgEdit_Error__must_be_executable_program}
            = "Error: \$var must be a valid executable path";
$Lang{CfgEdit_Error__must_be_valid_option}
            = "Error: \$var must be a valid option";
$Lang{CfgEdit_Error_Copy_host_does_not_exist}
            = "Copy host \$copyHost doesn't exist; creating full host name \$fullHost.  Delete this host if that is not what you wanted.";

$Lang{CfgEdit_Log_Copy_host_config}
            = "\$User copied config from host \$fromHost to \$host\n";
$Lang{CfgEdit_Log_Delete_param}
            = "\$User deleted \$p from \$conf\n";
$Lang{CfgEdit_Log_Add_param_value}
            = "\$User added \$p to \$conf, set to \$value\n";
$Lang{CfgEdit_Log_Change_param_value}
            = "\$User changed \$p in \$conf to \$valueNew from \$valueOld\n";
$Lang{CfgEdit_Log_Host_Delete}
            = "\$User deleted host \$host\n";
$Lang{CfgEdit_Log_Host_Change}
            = "\$User host \$host changed \$key from \$valueOld to \$valueNew\n";
$Lang{CfgEdit_Log_Host_Add}
            = "\$User added host \$host: \$value\n";
  
#end of lang_en.pm
