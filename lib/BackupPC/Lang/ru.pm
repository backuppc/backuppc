#!/usr/bin/perl
#
# by Sergei Butakov <sergei@bslos.com> (2011-05-1x - 2011-05-2x for V3.2.1)
#
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

$Lang{Start_Archive} = "Начать Архивирование";
$Lang{Stop_Dequeue_Archive} = "Остановить/Убрать из Очереди";
$Lang{Start_Full_Backup} = "Начать Полн. Копирование";
$Lang{Start_Incr_Backup} = "Начать Инкр. Копирование";
$Lang{Stop_Dequeue_Backup} = "Остановить/Убрать из Очереди";
$Lang{Restore} = "Восстановить";

$Lang{Type_full} = "полн.";
$Lang{Type_incr} = "инкр.";

# -----

$Lang{Only_privileged_users_can_view_admin_options} = "Only privileged users can view admin options.";
$Lang{H_Admin_Options} = "BackupPC Server: Admin Options";
$Lang{Admin_Options} = "Администрирование";
$Lang{Admin_Options_Page} = <<EOF;
\${h1(qq{$Lang{Admin_Options}})}
<br>
\${h2("Управление Сервером")}
<form name="ReloadForm" action="\$MyURL" method="get">
<input type="hidden" name="action" value="">
<table class="tableStnd">
  <tr><td>Перезагрузить настройки сервера:<td><input type="button" value="Перезагрузить"
     onClick="document.ReloadForm.action.value='Reload';
              document.ReloadForm.submit();">
</table>
</form>
<!--
\${h2("Server Configuration")}
<ul>
  <li><i>Other options can go here... e.g.,</i>
  <li>Edit server configuration
</ul>
-->
EOF

$Lang{Unable_to_connect_to_BackupPC_server} = "Не могу подключиться к серверу BackupPC";
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

$Lang{H_BackupPC_Server_Status} = "Состояние Сервера BackupPC";

$Lang{BackupPC_Server_Status_General_Info}= <<EOF;
\${h2(\"Общая Информация\")}

<ul>
<li> PID сервера \$Info{pid}, версия \$Info{Version},
     запущен \$serverStartTime на узле \$Conf{ServerHost}.
<li> Данный отчёт был сформирован \$now.
<li> Настройки последний раз загружались \$configLoadTime.
<li> В следующий раз ПК будут поставлены в очередь запросов \$nextWakeupTime.
<li> Прочая информация:
    <ul>
        <li>\$numBgQueue запросов в очереди на резервирование (с момента последнего запуска планировщика);
        <li>\$numUserQueue запросов в пользовательской очереди на резервирование;
        <li>\$numCmdQueue запросов в очереди на выполнение команд;
        \$poolInfo
        <li>Файловая система пула занята на \$Info{DUlastValue}%
            (\$DUlastTime), сегодняшний максимум \$Info{DUDailyMax}% (\$DUmaxTime),
            вчерашний максимум \$Info{DUDailyMaxPrev}%.
    </ul>
</ul>
EOF

$Lang{BackupPC_Server_Status} = <<EOF;
\${h1(qq{$Lang{H_BackupPC_Server_Status}})}

<p>
\${h2("Работы, выполняемые в данный момент времени")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td>Узел</td>
    <td>Тип</td>
    <td>Пользователь</td>
    <td>Время начала</td>
    <td>Команда</td>
    <td align="center">PID</td>
    <td align="center">Xfer PID</td>
    <td align="center"> Status </td>
    <td align="center"> Count </td>
    </tr>
\$jobStr
</table>

<p>
\$generalInfo

\${h2("Сбои, нуждающиеся внимания")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center">Узел</td>
    <td align="center">Тип</td>
    <td align="center">Пользователь</td>
    <td align="center">Последняя попытка</td>
    <td align="center">Детали</td>
    <td align="center">Время ошибки</td>
    <td>Последняя ошибка (не считая отсутствие \'пинга\')</td></tr>
\$statusStr
</table>
EOF

# --------------------------------
$Lang{BackupPC__Server_Summary} = "Сводка по Узлам";
$Lang{BackupPC__Archive} = "Архивирование";
$Lang{BackupPC_Summary} = <<EOF;

\${h1(qq{$Lang{BackupPC__Server_Summary}})}
<p>
<ul>
<li>Данный отчёт был сформирован \$now.
<li>Файловая система пула занята на \$Info{DUlastValue}%
    (\$DUlastTime), сегодняшний максимум \$Info{DUDailyMax}% (\$DUmaxTime),
        вчерашний максимум \$Info{DUDailyMaxPrev}%.
</ul>
</p>

\${h2("Узлы, имеющие резервные копии")}
<p>
Всего \$hostCntGood узлов, которые содержат:
<ul>
<li> \$fullTot полных резервных копий общим размером \${fullSizeTot}GiB
     (до объединения и сжатия);
<li> \$incrTot инкрементальных резервных копий общим размером \${incrSizeTot}GiB
     (до объединения и сжатия).
</ul>
</p>
<table class="sortable" id="host_summary_backups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td>Узел</td>
    <td align="center">Поль-ль</td>
    <td align="center">Кол-во ПОЛН. копий</td>
    <td align="center">ПОЛН. возраст (дни)</td>
    <td align="center">ПОЛН. размер (ГБ)</td>
    <td align="center">Скорость (МБ/с)</td>
    <td align="center">Кол-во ИНКР. копий</td>
    <td align="center">ИНКР. возраст (дни)</td>
    <td align="center">Посл. копир-ие (дни)</td>
    <td align="center">Состояние</td>
    <td align="center">Трансп. ошибок</td>
    <td align="center">Последнее действие</td></tr>
\$strGood
</table>
<br><br>
\${h2("Узлы, не имеющие резервные копии")}
<p>
Всего \$hostCntNone узлов, не имеющих резервных копий.
<p>
<table class="sortable" id="host_summary_nobackups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td>Узел</td>
    <td align="center">Поль-ль</td>
    <td align="center">Кол-во ПОЛН. копий</td>
    <td align="center">ПОЛН. возраст (дни)</td>
    <td align="center">ПОЛН. размер (ГБ)</td>
    <td align="center">Скорость (МБ/с)</td>
    <td align="center">Кол-во ИНКР. копий</td>
    <td align="center">ИНКР. возраст (дни)</td>
    <td align="center">Последн. копир-ие (дни)</td>
    <td align="center">Состояние</td>
    <td align="center">Трансп. ошибок</td>
    <td align="center">Последнее действие</td></tr>
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

Всего \$hostCntGood узлов, чьи резервные копии занимают в общем \${fullSizeTot} ГБ.
<p>
<form name="form1" method="post" action="\$MyURL">
<input type="hidden" name="fcbMax" value="\$checkBoxCnt">
<input type="hidden" name="type" value="1">
<input type="hidden" name="host" value="\${EscHTML(\$archHost)}">
<input type="hidden" name="action" value="Archive">
<table class="tableStnd" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td align=center> Узел</td>
    <td align="center"> Пользователь </td>
    <td align="center"> Размер Копии </td>
\$strGood
\$checkAllHosts
</table>
</form>
<p>

EOF

$Lang{BackupPC_Archive2} = <<EOF;
\${h1(qq{$Lang{BackupPC__Archive}})}
Архивирование следующих узлов
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
    <td colspan=2><input type="submit" value="Начать Архивирование" name="ignore"></td>
</tr>
</form>
</table>
EOF

$Lang{BackupPC_Archive2_location} = <<EOF;
<tr>
    <td>Расположение/Устройство Архива</td>
    <td><input type="text" value="\$ArchiveDest" name="archive_device"></td>
</tr>
EOF

$Lang{BackupPC_Archive2_compression} = <<EOF;
<tr>
    <td>Сжатие</td>
    <td>
    <input type="radio" value="0" name="compression" \$ArchiveCompNone>Нет<br>
    <input type="radio" value="1" name="compression" \$ArchiveCompGzip>gzip<br>
    <input type="radio" value="2" name="compression" \$ArchiveCompBzip2>bzip2
    </td>
</tr>
EOF

$Lang{BackupPC_Archive2_parity} = <<EOF;
<tr>
    <td>Percentage of Parity Data (0 = disable, 5 = typical)</td>
    <td><input type="numeric" value="\$ArchivePar" name="par"></td>
</tr>
EOF

$Lang{BackupPC_Archive2_split} = <<EOF;
<tr>
    <td>Разделить на части по</td>
    <td><input type="numeric" value="\$ArchiveSplit" name="splitsize">МБ</td>
</tr>
EOF

# -----------------------------------
$Lang{Pool_Stat} = <<EOF;
        <li>Пул занимает \${poolSize}GiB, включая \$info->{"\${name}FileCnt"} файлов
            и \$info->{"\${name}DirCnt"} каталогов (по данным на \$poolTime);
        <li>При хешировании пула произошло \$info->{"\${name}FileCntRep"} коллизии,
            максимальное количество файлов в одной коллизии - \$info->{"\${name}FileRepMax"};
        <li>Во время ночной очистки было удалено \$info->{"\${name}FileCntRm"} файлов
            общим размером \${poolRmSize}GiB (в районе \$poolTime);
EOF

# --------------------------------
$Lang{BackupPC__Backup_Requested_on__host} = "BackupPC: Backup Requested on \$host";
# --------------------------------
$Lang{REPLY_FROM_SERVER} = <<EOF;
\${h1(\$str)}
<p>
Ответ с сервера: \$reply
<p>
Вернуться на Главную страницу узла <a href="\$MyURL?host=\$host">\$host</a>.
EOF
# --------------------------------
$Lang{BackupPC__Start_Backup_Confirm_on__host} = "BackupPC: Start Backup Confirm on \$host";
# --------------------------------
$Lang{Are_you_sure_start} = <<EOF;
\${h1("Вы уверены?")}
<p>
Резервное \$type копирование узла \$host.

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="hostIP" value="\$ipAddr">
<input type="hidden" name="doit" value="1">
<input type="hidden" name="action" value="">
Вы уверены, что хотите сделать это?
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="Нет" name="ignore">
</form>
EOF
# --------------------------------
$Lang{BackupPC__Stop_Backup_Confirm_on__host} = "BackupPC: Stop Backup Confirm on \$host";
# --------------------------------
$Lang{Are_you_sure_stop} = <<EOF;

\${h1("Вы уверены?")}

<p>
Остановка/удаление из очереди узла \$host.

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host"   value="\$host">
<input type="hidden" name="doit"   value="1">
<input type="hidden" name="action" value="">
Также, не начинать другое резервное копирование в течение
<input type="text" name="backoff" size="10" value="\$backoff"> часов.
<p>
Вы уверены, что хотите сделать это?
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="Нет" name="ignore">
</form>

EOF
# --------------------------------
$Lang{Only_privileged_users_can_view_queues_} = "Only privileged users can view queues.";
# --------------------------------
$Lang{Only_privileged_users_can_archive} = "Only privileged users can Archive.";
# --------------------------------
$Lang{BackupPC__Queue_Summary} = "BackupPC: Queue Summary";
# --------------------------------
$Lang{Backup_Queue_Summary} = <<EOF;
\${h1("Сводка по Очередям")}
<br><br>
\${h2("Очередь Пользовательских Задач")}
<p>
Следующие запросы находятся в очереди:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Узел </td>
    <td> Время Запроса </td>
    <td> Пользователь </td></tr>
\$strUser
</table>
<br><br>

\${h2("Очередь Фоновых Задач")}
<p>
Следующие фоновые запросы находятся в очереди:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Узел </td>
    <td> Время Запроса </td>
    <td> Пользователь </td></tr>
\$strBg
</table>
<br><br>
\${h2("Очередь Команд")}
<p>
Следующие команды находятся в очереди:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Узел </td>
    <td> Время Запроса </td>
    <td> Пользователь </td>
    <td> Команда </td></tr>
\$strCmd
</table>
EOF

# --------------------------------
$Lang{Backup_PC__Log_File__file} = "BackupPC: File \$file";
$Lang{Log_File__file__comment} = <<EOF;
\${h1("Файл \$file \$comment")}
<p>
EOF
# --------------------------------
$Lang{Contents_of_log_file} = <<EOF;
Содержимое файла <tt>\$file</tt>, с последними изменениями от \$mtimeStr \$comment
EOF

# --------------------------------
$Lang{skipped__skipped_lines} = "[ пропущено \$skipped строк ]\n";
# --------------------------------
$Lang{_pre___Can_t_open_log_file__file} = "<pre>\nНе могу открыть журнальный файл \$file\n";

# --------------------------------
$Lang{BackupPC__Log_File_History} = "BackupPC: Log File History";
$Lang{Log_File_History__hdr} = <<EOF;
\${h1("Архив Журналов \$hdr")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Файл </td>
    <td align="center"> Размер </td>
    <td align="center"> Время изменения </td></tr>
\$str
</table>
EOF

# -------------------------------
$Lang{Recent_Email_Summary} = <<EOF;
\${h1("Сводка по Последним Письмам (в обратном порядке времени)")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Получатель </td>
    <td align="center"> Узел </td>
    <td align="center"> Время </td>
    <td align="center"> Тема </td></tr>
\$str
</table>
EOF
 

# ------------------------------
$Lang{Browse_backup__num_for__host} = "BackupPC: Browse backup \$num for \$host";

# ------------------------------
$Lang{Restore_Options_for__host} = "BackupPC: Restore Options for \$host";
$Lang{Restore_Options_for__host2} = <<EOF;
\${h1("Параметры Восстановления для Узла \$host")}
<p>
Вы выбрали следующие файлы/каталоги из
ресурса \$share, номер копии № \$num:
<ul>
\$fileListStr
</ul>
</p><p>
Выберите один из трёх способов восстановления.
</p>
\${h2("Способ 1: Прямое Восстановление")}
<p>
EOF

$Lang{Restore_Options_for__host_Option1} = <<EOF;
Вы можете восстановить данные напрямую в
<b>\$directHost</b>.
</p><p>
<b>Внимание:</b> все существующие файлы, совпадающие с выбранными,
будут переписаны!
</p>
<form action="\$MyURL" method="post" name="direct">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="3">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<table class="tableStnd" border="0">
<tr>
    <td>Восстановить на узел</td>
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
    <td>Восстановить на ресурс</td>
    <td><input type="text" size="40" value="\${EscHTML(\$share)}"
	 name="shareDest"></td>
</tr><tr>
    <td>Восстановить в каталог<br>(относительно ресурса)</td>
    <td valign="top"><input type="text" size="40" maxlength="256"
	value="\${EscHTML(\$pathHdr)}" name="pathHdr"></td>
</tr><tr>
    <td><input type="submit" value="Начать Восстановление" name="ignore"></td>
</table>
</form>
EOF

$Lang{Restore_Options_for__host_Option1_disabled} = <<EOF;
Direct restore has been disabled for host \${EscHTML(\$hostDest)}.
Please select one of the other restore options.
EOF

# ------------------------------
$Lang{Option_2__Download_Zip_archive} = <<EOF;
<p>
\${h2("Способ 2: Загрузка Zip-архива")}
<p>
Вы можете загрузить Zip-архив, содержащий все выбранные файлы и каталоги.
После чего, используя локальное приложение, такое как WinZip, можно просмотреть
или разархивировать любые файлы.
</p><p>
<b>Внимание:</b> в зависимости от выбранных Вами файлов/каталогов,
этот архив может быть очень очень большим. На создание и передачу
такого архива может уйти много времени, и Вам понадобится достаточно
много места на локальном диске для его хранения.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="2">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Создать архив относительно
\${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(в противном случае файлы в архиве будут иметь полные пути).
<br>
<table class="tableStnd" border="0">
<tr>
    <td>Степень сжатия (0=нет, 1=самая быстрая, ..., 9=самая большая)</td>
    <td><input type="text" size="6" value="5" name="compressLevel"></td>
</tr><tr>
    <td>Code page (e.g. cp866)</td>
    <td><input type="text" size="6" value="utf8" name="codePage"></td>
</tr>
</table>
<br>
<input type="submit" value="Загрузить Zip-архив" name="ignore">
</form>
EOF

# ------------------------------

$Lang{Option_2__Download_Zip_archive2} = <<EOF;
<p>
\${h2("Option 2: Download Zip archive")}
<p>
Archive::Zip is not installed so you will not be able to download a
zip archive.
Please ask your system adminstrator to install Archive::Zip from
<a href="http://www.cpan.org">www.cpan.org</a>.
</p>
EOF


# ------------------------------
$Lang{Option_3__Download_Zip_archive} = <<EOF;
\${h2("Способ 3: Загрузка Tar-архива")}
<p>
Вы можете загрузить Tar-архив, содержащий все выбранные файлы и каталоги.
После чего, используя локальное приложение, такое как tar или WinZip,
можно просмотреть или разархивировать любые файлы.
</p><p>
<b>Внимание:</b> в зависимости от выбранных Вами файлов/каталогов,
этот архив может быть очень очень большим. На создание и передачу
такого архива может уйти много времени, и Вам понадобится достаточно
много места на локальном диске для его хранения.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="1">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Создать архив относительно
\${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(в противном случае файлы в архиве будут иметь полные пути).
<br>
<input type="submit" value="Загрузить Tar-архив" name="ignore">
</form>
EOF


# ------------------------------
$Lang{Restore_Confirm_on__host} = "BackupPC: Restore Confirm on \$host";

$Lang{Are_you_sure} = <<EOF;
\${h1("Вы уверены? Точно-точно? А если подумать? Может всё-таки не надо?")}
<p>
Следующие файлы будут восстановлены напрямую на узел \$In{hostDest} в ресурс
\$In{shareDest}, из резервной копии № \$num:
<p>
<table class="tableStnd" border>
<tr class="tableheader"><td>Оригинальный файл/каталог</td><td>Будет восстановлен как</td></tr>
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
Вы уверены?
<input type="button" value="\$Lang->{Restore}"
 onClick="document.RestoreForm.action.value='Restore';
          document.RestoreForm.submit();">
<input type="submit" value="Нет" name="ignore">
</form>
EOF


# --------------------------
$Lang{Restore_Requested_on__hostDest} = "BackupPC: Restore Requested on \$hostDest";
$Lang{Reply_from_server_was___reply} = <<EOF;
\${h1(\$str)}
<p>
Ответ с сервера: \$reply
<p>
Вернуться на Главную страницу узла <a href="\$MyURL?host=\$hostDest">\$hostDest</a>.
EOF

$Lang{BackupPC_Archive_Reply_from_server} = <<EOF;
\${h1(\$str)}
<p>
Ответ с сервера: \$reply
EOF


# -------------------------
$Lang{Host__host_Backup_Summary} = "BackupPC: Host \$host Backup Summary";

$Lang{Host__host_Backup_Summary2} = <<EOF;
\${h1("Сводка по Узлу \$host")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>
</p>
\${h2("Пользовательские Действия")}
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
\${h2("Сводка Резервного Копирования")}
<p>
Щёлкните по номеру для просмотра и восстановления скопированных файлов.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> № </td>
    <td align="center"> Тип </td>
    <td align="center"> Полный </td>
    <td align="center"> Уровень </td>
    <td align="center"> Дата Начала </td>
    <td align="center"> Длительность(мин) </td>
    <td align="center"> Возраст(дни) </td>
    <td align="center"> Локальный Путь Копии </td>
</tr>
\$str
</table>
<p>

\$restoreStr
</p>
<br><br>
\${h2("Сводка Ошибок при Копировании")}
<br><br>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> № </td>
    <td align="center"> Тип </td>
    <td align="center"> Журнал </td>
    <td align="center"> Трансп. ошибок </td>
    <td align="center"> Плохих файлов </td>
    <td align="center"> Ресурс. проблем </td>
    <td align="center"> tar ошибок </td>
</tr>
\$errStr
</table>
<br><br>

\${h2("Сводка по Файлам")}
<p>
Существующие файлы - файлы, уже находящиеся в пуле.
Новые это те, которые добавлены к пулу.
Пустые файлы не учитываются.
Empty files and SMB errors aren\'t counted in the reuse and new counts.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="2" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> Всего </td>
    <td align="center" colspan="2"> Существующие Файлы </td>
    <td align="center" colspan="2"> Новые Файлы </td>
</tr>
<tr class="tableheader">
    <td align="center"> № </td>
    <td align="center"> Тип </td>
    <td align="center"> Файлов </td>
    <td align="center"> Размер(МБ) </td>
    <td align="center"> МБ/с </td>
    <td align="center"> Файлов </td>
    <td align="center"> Размер(МБ) </td>
    <td align="center"> Файлов </td>
    <td align="center"> Размер(МБ) </td>
</tr>
\$sizeStr
</table>
<br><br>

\${h2("Сводка по Сжатию")}
<p>
Степень сжатия существующих и новых файлов.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="3" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> Существующие Файлы </td>
    <td align="center" colspan="3"> Новые Файлы </td>
</tr>
<tr class="tableheader"><td align="center"> № </td>
    <td align="center"> Тип </td>
    <td align="center"> Уровень Сжатия </td>
    <td align="center"> Размер(МБ) </td>
    <td align="center"> Сжатый(МБ) </td>
    <td align="center"> Степень сж. </td>
    <td align="center"> Размер(МБ) </td>
    <td align="center"> Сжатый(МБ) </td>
    <td align="center"> Степень сж. </td>
</tr>
\$compStr
</table>
<br><br>
EOF

$Lang{Host__host_Archive_Summary} = "BackupPC: Host \$host Archive Summary";
$Lang{Host__host_Archive_Summary2} = <<EOF;
\${h1("Сводка по Архиву \$host")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>

\${h2("Пользовательские Действия")}
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
$Lang{Error} = "BackupPC: Error";
$Lang{Error____head} = <<EOF;
\${h1("Error: \$head")}
<p>\$mesg</p>
EOF

# -------------------------
$Lang{NavSectionTitle_} = "Сервер";

# -------------------------
$Lang{Backup_browse_for__host} = <<EOF;
\${h1("Просмотр Резервной Копии Узла \$host")}

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
<li> Копия № \$num, создание которой было начато примерно \$backupTime
        (\$backupAge дней назад),
\$filledBackup
<li> Введите каталог: <input type="text" name="dir" size="50" maxlength="4096" value="\${EscHTML(\$dir)}"> <input type="submit" value="\$Lang->{Go}" name="Submit">
<li> Щёлкните на каталог, чтобы увидеть его содержимое.
<li> Щёлкните на файл, чтобы восстановить его.
<li> <a href="\$MyURL?action=dirHistory&host=\${EscURI(\$host)}&share=\$shareURI&dir=\$pathURI">История копий</a> текущего каталога.
</ul>
</form>

\${h2("Содержание каталога \$dirDisplay")}
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
$Lang{DirHistory_backup_for__host} = "BackupPC: Directory backup history for \$host";

#
# These two strings are used to build the links for directories and
# file versions.  Files are appended with a version number.
#
$Lang{DirHistory_dirLink}  = "dir";
$Lang{DirHistory_fileLink} = "v";

$Lang{DirHistory_for__host} = <<EOF;
\${h1("История каталога резервной копии для узла \$host")}
<p>
Здесь показаны все уникальные версии файлов, находящиеся во всех
резервных копиях:
<ul>
<li> Щёлкните по номеру копии для возврата к просмотру копии;
<li> Щёлкните по ссылке на каталог (\$Lang->{DirHistory_dirLink}) для захода 
     в этот каталог;
<li> Щёлкните по версии файла (\$Lang->{DirHistory_fileLink}0,
     \$Lang->{DirHistory_fileLink}1, ...) для загрузки этого файла;
<li> Файлы из разных резервных копий, содержащие одно и то же,
     имеют один и тот же номер версии;
<li> Файлы и каталоги, отсутствующие в конкретной копии, показаны
     пустым прямоугольником;
<li> Файлы одной версии могут отличаться разными атрибутами файловой системы.
     Выберите  номер копии, чтобы посмотреть эти атрибуты.
</ul>

\${h2("История \$dirDisplay")}

<br>
<table border cellspacing="2" cellpadding="3">
<tr class="fviewheader"><td>Номер копии</td>\$backupNumStr</tr>
<tr class="fviewheader"><td>Время копирования</td>\$backupTimeStr</tr>
\$fileStr
</table>
EOF

# ------------------------------
$Lang{Restore___num_details_for__host} = "BackupPC: Restore #\$num details for \$host";

$Lang{Restore___num_details_for__host2} = <<EOF;
\${h1("Детали восстановления № \$num для узла \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="90%">
<tr><td class="tableheader"> Номер </td><td class="border"> \$Restores[\$i]{num} </td></tr>
<tr><td class="tableheader"> Запросил </td><td class="border"> \$RestoreReq{user} </td></tr>
<tr><td class="tableheader"> Время запроса </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> Результат </td><td class="border"> \$Restores[\$i]{result} </td></tr>
<tr><td class="tableheader"> Текст ошибки </td><td class="border"> \$Restores[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> Исходящий узел </td><td class="border"> \$RestoreReq{hostSrc} </td></tr>
<tr><td class="tableheader"> Номер исходящей копии </td><td class="border"> \$RestoreReq{num} </td></tr>
<tr><td class="tableheader"> Исходящий ресурс </td><td class="border"> \$RestoreReq{shareSrc} </td></tr>
<tr><td class="tableheader"> Узел назначения </td><td class="border"> \$RestoreReq{hostDest} </td></tr>
<tr><td class="tableheader"> Ресурс назначения </td><td class="border"> \$RestoreReq{shareDest} </td></tr>
<tr><td class="tableheader"> Время начала </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Продолжительность </td><td class="border"> \$duration мин </td></tr>
<tr><td class="tableheader"> Количество файлов </td><td class="border"> \$Restores[\$i]{nFiles} </td></tr>
<tr><td class="tableheader"> Общий размер </td><td class="border"> \${MB} МБ </td></tr>
<tr><td class="tableheader"> Скорость передачи </td><td class="border"> \$MBperSec МБ/с </td></tr>
<tr><td class="tableheader"> Ошибок при создании Tar </td><td class="border"> \$Restores[\$i]{tarCreateErrs} </td></tr>
<tr><td class="tableheader"> Ошибок при передаче </td><td class="border"> \$Restores[\$i]{xferErrs} </td></tr>
<tr><td class="tableheader"> Журнал </td><td class="border">
<a href="\$MyURL?action=view&type=RestoreLOG&num=\$Restores[\$i]{num}&host=\$host">Весь</a>,
<a href="\$MyURL?action=view&type=RestoreErr&num=\$Restores[\$i]{num}&host=\$host">Только ошибки</a>
</tr></tr>
</table>
</p>
\${h1("Список Файлов/Каталогов")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="100%">
<tr class="tableheader"><td>Оригинальный файл/каталог</td><td>Восстановлен как</td></tr>
\$fileListStr
</table>
EOF

# ------------------------------
$Lang{Archive___num_details_for__host} = "BackupPC: Archive #\$num details for \$host";

$Lang{Archive___num_details_for__host2 } = <<EOF;
\${h1("Детали по Архиву № \$num узла \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr><td class="tableheader"> Номер </td><td class="border"> \$Archives[\$i]{num} </td></tr>
<tr><td class="tableheader"> Запросил </td><td class="border"> \$ArchiveReq{user} </td></tr>
<tr><td class="tableheader"> Время запроса </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> Результат </td><td class="border"> \$Archives[\$i]{result} </td></tr>
<tr><td class="tableheader"> Сообщение об ошибке </td><td class="border"> \$Archives[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> Время запуска </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Продолжительность </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> Журнал передачи данных </td><td class="border">
<a href="\$MyURL?action=view&type=ArchiveLOG&num=\$Archives[\$i]{num}&host=\$host">Просмотреть</a>,
<a href="\$MyURL?action=view&type=ArchiveErr&num=\$Archives[\$i]{num}&host=\$host">Только ошибки</a>
</tr></tr>
</table>
<p>
\${h1("Список узлов")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td>Узел</td><td>Номер резервной копии</td></tr>
\$HostListStr
</table>
EOF

# -----------------------------------
$Lang{Email_Summary} = "BackupPC: Email Summary";

# -----------------------------------
#  !! ERROR messages !!
# -----------------------------------
$Lang{BackupPC__Lib__new_failed__check_apache_error_log} = "BackupPC::Lib->new failed: check apache error_log\n";
$Lang{Wrong_user__my_userid_is___} =  
              "Wrong user: my userid is \$>, instead of \$uid"
            . "(\$Conf{BackupPCUser})\n";
# $Lang{Only_privileged_users_can_view_PC_summaries} = "Only privileged users can view PC summaries.";
$Lang{Only_privileged_users_can_stop_or_start_backups} = 
                  "Only privileged users can stop or start backups on"
		. " \${EscHTML(\$host)}.";
$Lang{Invalid_number__num} = "Invalid number \${EscHTML(\$In{num})}";
$Lang{Unable_to_open__file__configuration_problem} = "Unable to open \$file: configuration problem?";
$Lang{Only_privileged_users_can_view_log_or_config_files} = "Only privileged users can view log or config files.";
$Lang{Only_privileged_users_can_view_log_files} = "Only privileged users can view log files.";
$Lang{Only_privileged_users_can_view_email_summaries} = "Only privileged users can view email summaries.";
$Lang{Only_privileged_users_can_browse_backup_files} = "Only privileged users can browse backup files"
                . " for host \${EscHTML(\$In{host})}.";
$Lang{Empty_host_name} = "Empty host name.";
$Lang{Directory___EscHTML} = "Directory \${EscHTML(\"\$TopDir/pc/\$host/\$num\")}"
		    . " is empty";
$Lang{Can_t_browse_bad_directory_name2} = "Не могу просмотреть каталог с неправильным названием"
	            . " \${EscHTML(\$relDir)}";
$Lang{Only_privileged_users_can_restore_backup_files} = "Only privileged users can restore backup files"
                . " for host \${EscHTML(\$In{host})}.";
$Lang{Bad_host_name} = "Bad host name \${EscHTML(\$host)}";
$Lang{You_haven_t_selected_any_files__please_go_Back_to} = "Вы не выбрали ни один файл.";
$Lang{You_haven_t_selected_any_hosts} = "You haven\'t selected any hosts; please go Back to"
                . " select some hosts.";
$Lang{Nice_try__but_you_can_t_put} = "Nice try, but you can\'t put \'..\' in any of the file names";
$Lang{Host__doesn_t_exist} = "Host \${EscHTML(\$In{hostDest})} doesn\'t exist";
$Lang{You_don_t_have_permission_to_restore_onto_host} = "You don\'t have permission to restore onto host"
		    . " \${EscHTML(\$In{hostDest})}";
$Lang{Can_t_open_create__openPath} = "Can\'t open/create "
		. "\${EscHTML(\"\$openPath\")}";
$Lang{Only_privileged_users_can_restore_backup_files2} = "Only privileged users can restore backup files"
                . " for host \${EscHTML(\$host)}.";
$Lang{Empty_host_name} = "Empty host name";
$Lang{Unknown_host_or_user} = "Неизвестный узел или пользователь \${EscHTML(\$host)}";
$Lang{Only_privileged_users_can_view_information_about} = "Only privileged users can view information about"
                . " host \${EscHTML(\$host)}." ;
$Lang{Only_privileged_users_can_view_archive_information} = "Only privileged users can view archive information.";
$Lang{Only_privileged_users_can_view_restore_information} = "Only privileged users can view restore information.";
$Lang{Restore_number__num_for_host__does_not_exist} = "Restore number \$num for host \${EscHTML(\$host)} does"
	        . " not exist.";
$Lang{Archive_number__num_for_host__does_not_exist} = "Archive number \$num for host \${EscHTML(\$host)} does"
                . " not exist.";
$Lang{Can_t_find_IP_address_for} = "Can\'t find IP address for \${EscHTML(\$host)}";
$Lang{host_is_a_DHCP_host} = <<EOF;
\$host is a DHCP host, and I don\'t know its IP address.  I checked the
netbios name of \$ENV{REMOTE_ADDR}\$tryIP, and found that that machine
is not \$host.
<p>
Until I see \$host at a particular DHCP address, you can only
start this request from the client machine itself.
EOF

# ------------------------------------
# !! Server Mesg !!
# ------------------------------------

$Lang{Backup_requested_on_DHCP__host} = "Резервное копирование DHCP узла \$host (\$In{hostIP}) запросил"
		                      . " \$User с \$ENV{REMOTE_ADDR}";
$Lang{Backup_requested_on__host_by__User} = "Резервное копирование узла \$host запросил \$User";
$Lang{Backup_stopped_dequeued_on__host_by__User} = "Резервное копирование для узла \$host остановил/убрал из очереди \$User";
$Lang{Restore_requested_to_host__hostDest__backup___num} = "Восстановление на узел \$hostDest, копию № \$num,"
	     . " запросил \$User с \$ENV{REMOTE_ADDR}";
$Lang{Archive_requested} = "Архивирование запросил \$User с \$ENV{REMOTE_ADDR}";

# -------------------------------------------------
# ------- Stuff that was forgotten ----------------
# -------------------------------------------------

$Lang{Status} = "Состояние";
$Lang{PC_Summary} = "Сводка по Узлам";
$Lang{LOG_file} = "Журнал";
$Lang{LOG_files} = "Старые журналы";
$Lang{Old_LOGs} = "Старые журналы";
$Lang{Email_summary} = "Сводка по Письмам";
$Lang{Config_file} = "Config file";
# $Lang{Hosts_file} = "Hosts file";
$Lang{Current_queues} = "Сводка по Очередям";
$Lang{Documentation} = "Руководство";

#$Lang{Host_or_User_name} = "<small>Host or User name:</small>";
$Lang{Go} = "Найти";
$Lang{Hosts} = "Узлы";
$Lang{Select_a_host} = "Выбрать узел ...";

$Lang{There_have_been_no_archives} = "<h2> Архивы отсутствуют </h2>\n";
$Lang{This_PC_has_never_been_backed_up} = "<h2> Данный ПК ни разу не резервировался!! </h2>\n";
$Lang{This_PC_is_used_by} = "<li>Данный ПК использует \${UserLink(\$user)}";

$Lang{Extracting_only_Errors} = "(Выбраны только ошибки)";
$Lang{XferLOG} = "Весь";
$Lang{Errors}  = "Только Ошибки";

# ------------
$Lang{Last_email_sent_to__was_at___subject} = <<EOF;
<li>Последнее письмо было отправлено \$mailTime, с темой "\$subj".
EOF
# ------------
$Lang{The_command_cmd_is_currently_running_for_started} = <<EOF;
<li>Команда \$cmd выполняется для узла \$host, запущена \$startTime.
EOF

# -----------
$Lang{Host_host_is_queued_on_the_background_queue_will_be_backed_up_soon} = <<EOF;
<li>Узел \$host поставлен в фоновую очередь (скоро будет запущено резервное копирование).
EOF

# ----------
$Lang{Host_host_is_queued_on_the_user_queue__will_be_backed_up_soon} = <<EOF;
<li>Узел \$host поставлен в пользовательскую очередь (скоро будет запущено резервное копирование).
EOF

# ---------
$Lang{A_command_for_host_is_on_the_command_queue_will_run_soon} = <<EOF;
<li>Команда для узла \$host поставлена в очередь команд (скоро будет запущена).
EOF

# --------
$Lang{Last_status_is_state_StatusHost_state_reason_as_of_startTime} = <<EOF;
<li>Состояние \"\$Lang->{\$StatusHost{state}}\"\$reason на \$startTime.
EOF

# --------
$Lang{Last_error_is____EscHTML_StatusHost_error} = <<EOF;
<li>Последняя ошибка: \"\${EscHTML(\$StatusHost{error})}\".
EOF

# ------
$Lang{Pings_to_host_have_failed_StatusHost_deadCnt__consecutive_times} = <<EOF;
<li>"Пропинговать" узел \$host не удалось \$StatusHost{deadCnt} раз(а) подряд.
EOF

# -----
$Lang{Prior_to_that__pings} = "Prior to that, pings";

# -----
$Lang{priorStr_to_host_have_succeeded_StatusHostaliveCnt_consecutive_times} = <<EOF;
<li>\$priorStr to \$host были успешны \$StatusHost{aliveCnt}
        раз(а) подряд.
EOF

$Lang{Because__host_has_been_on_the_network_at_least__Conf_BlackoutGoodCnt_consecutive_times___} = <<EOF;
<li>Because \$host has been on the network at least \$Conf{BlackoutGoodCnt}
consecutive times, it will not be backed up from \$blackoutStr.
EOF

$Lang{__time0_to__time1_on__days} = "\$t0 to \$t1 on \$days";

$Lang{Backups_are_deferred_for_hours_hours_change_this_number} = <<EOF;
<li>Backups are deferred for \$hours hours
(<a href=\"\$MyURL?action=Stop_Dequeue_Backup&host=\$host\">change this number</a>).
EOF

$Lang{tryIP} = " and \$StatusHost{dhcpHostIP}";

# $Lang{Host_Inhost} = "Host \$In{host}";

$Lang{checkAll} = <<EOF;
<tr><td class="fviewborder">
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;Выбрать всё
</td><td colspan="5" align="center" class="fviewborder">
<input type="submit" name="Submit" value="Восстановить выбранные файлы и каталоги">
</td></tr>
EOF

$Lang{checkAllHosts} = <<EOF;
<tr><td class="fviewborder">
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;Выбрать всё
</td><td colspan="2" align="center" class="fviewborder">
<input type="submit" name="Submit" value="Заархивировать выбранные узлы">
</td></tr>
EOF

$Lang{fileHeader} = <<EOF;
    <tr class="fviewheader"><td align=center> Название</td>
       <td align="center"> Тип</td>
       <td align="center"> Права</td>
       <td align="center"> №</td>
       <td align="center"> Размер</td>
       <td align="center"> Дата изменения</td>
    </tr>
EOF

$Lang{Home} = "Главная";
$Lang{Browse} = "Просмотр резервной копии";
$Lang{Last_bad_XferLOG} = "Последний журнал с ошибками";
$Lang{Last_bad_XferLOG_errors_only} = "Последний журнал с ошибками (только&nbsp;ошибки)";

$Lang{This_display_is_merged_with_backup} = <<EOF;
<li> Данное отображение объединено с копией № \$numF.
EOF

$Lang{Visit_this_directory_in_backup} = <<EOF;
<li> Выберите номер копии для просмотра: <select onChange="window.location=this.value">\$otherDirs </select>
EOF

$Lang{Restore_Summary} = <<EOF;
\${h2("Сводка Восстановлений")}
<p>
Щёлкните по номеру для более детального просмотра.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> № </td>
    <td align="center"> Результат </td>
    <td align="right"> Дата начала </td>
    <td align="right"> Длительность(мин) </td>
    <td align="right"> Кол-во файлов </td>
    <td align="right"> Размер(МБ) </td>
    <td align="right"> tar ошибок </td>
    <td align="right"> Трансп. ошибок </td>
</tr>
\$restoreStr
</table>
<p>
EOF

$Lang{Archive_Summary} = <<EOF;
\${h2("Архивная Сводка")}
<p>
Щёлкните по номеру архива для более детального просмотра.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> № </td>
    <td align="center"> Результат </td>
    <td align="right"> Время Запуска </td>
    <td align="right"> Продолжительность(мин)</td>
</tr>
\$ArchiveStr
</table>
<p>
EOF

$Lang{BackupPC__Documentation} = "BackupPC: Documentation";

$Lang{No} = "нет";
$Lang{Yes} = "да";

$Lang{The_directory_is_empty} = <<EOF;
<tr><td bgcolor="#ffffff">The directory \$dirDisplay is empty
</td></tr>
EOF

#$Lang{on} = "on";
$Lang{off} = "откл.";

$Lang{backupType_full}    = "полн.";
$Lang{backupType_incr}    = "инкр.";
$Lang{backupType_active}  = "active";
$Lang{backupType_partial} = "частичный";

$Lang{failed} = "неудачно";
$Lang{success} = "успешно";
$Lang{and} = "и";

# ------
# Hosts states and reasons
$Lang{Status_idle} = "бездействует";
$Lang{Status_backup_starting} = "началось копирование";
$Lang{Status_backup_in_progress} = "в процессе копирования";
$Lang{Status_restore_starting} = "началось восстановление";
$Lang{Status_restore_in_progress} = "в процессе восстановления";
$Lang{Status_admin_pending} = "link pending";
$Lang{Status_admin_running} = "link running";

$Lang{Reason_backup_done}    = "копирование закончено";
$Lang{Reason_restore_done}   = "восстановление закончено";
$Lang{Reason_archive_done}   = "архивирование закончено";
$Lang{Reason_nothing_to_do}  = "без работы";
$Lang{Reason_backup_failed}  = "копирование не удалось";
$Lang{Reason_restore_failed} = "восстановление не удалось";
$Lang{Reason_archive_failed} = "архивирование не удалось";
$Lang{Reason_no_ping}        = "не \'пингуется\'";
$Lang{Reason_backup_canceled_by_user}  = "копирование прервано пользователем";
$Lang{Reason_restore_canceled_by_user} = "восстановление прервано пользователем";
$Lang{Reason_archive_canceled_by_user} = "восстановление прервано пользователем";
$Lang{Disabled_OnlyManualBackups}  = "автозапрет";  
$Lang{Disabled_AllBackupsDisabled} = "запрещено";                  


# ---------
# Email messages

# No backup ever
$Lang{EMailNoBackupEverSubj} = "BackupPC: no backups of \$host have succeeded";
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
$Lang{CfgEdit_Edit_Config} = "Редактирование Настроек";
$Lang{CfgEdit_Edit_Hosts}  = "Редактирование Узлов";

$Lang{CfgEdit_Title_Server} = "Сервер";
$Lang{CfgEdit_Title_General_Parameters} = "Общие Параметры";
$Lang{CfgEdit_Title_Wakeup_Schedule} = "Время Запуска Планировщика";
$Lang{CfgEdit_Title_Concurrent_Jobs} = "Совмещение Заданий";
$Lang{CfgEdit_Title_Pool_Filesystem_Limits} = "Лимиты Файловой Системы Пула";
$Lang{CfgEdit_Title_Other_Parameters} = "Прочие Параметры";
$Lang{CfgEdit_Title_Remote_Apache_Settings} = "Установки Удалённого Сервера Apache";
$Lang{CfgEdit_Title_Program_Paths} = "Программные Пути";
$Lang{CfgEdit_Title_Install_Paths} = "Установочные Пути";
$Lang{CfgEdit_Title_Email} = "Почта";
$Lang{CfgEdit_Title_Email_settings} = "Настройки Электронной Почты";
$Lang{CfgEdit_Title_Email_User_Messages} = "Настройки Письма Для Пользователя";
$Lang{CfgEdit_Title_CGI} = "CGI";
$Lang{CfgEdit_Title_Admin_Privileges} = "Административные Привилегии";
$Lang{CfgEdit_Title_Page_Rendering} = "Отображение Веб-Страницы";
$Lang{CfgEdit_Title_Paths} = "Пути";
$Lang{CfgEdit_Title_User_URLs} = "Пользовательские URL\'ы";
$Lang{CfgEdit_Title_User_Config_Editing} = "Редактируемые Пользователем Настройки";
$Lang{CfgEdit_Title_Xfer} = "Транспорт";
$Lang{CfgEdit_Title_Xfer_Settings} = "Настройка Транспорта";
$Lang{CfgEdit_Title_Ftp_Settings} = "Установки FTP";
$Lang{CfgEdit_Title_Smb_Settings} = "Установки Smb";
$Lang{CfgEdit_Title_Tar_Settings} = "Установки Tar";
$Lang{CfgEdit_Title_Rsync_Settings} = "Установки Rsync";
$Lang{CfgEdit_Title_Rsyncd_Settings} = "Установки Rsyncd";
$Lang{CfgEdit_Title_Archive_Settings} = "Установки Archive";
$Lang{CfgEdit_Title_Include_Exclude} = "Включить/Исключить";
$Lang{CfgEdit_Title_Smb_Paths_Commands} = "Пути/Команды Smb";
$Lang{CfgEdit_Title_Tar_Paths_Commands} = "Пути/Команды Tar";
$Lang{CfgEdit_Title_Rsync_Paths_Commands_Args} = "Пути/Команды/Аргументы Rsync";
$Lang{CfgEdit_Title_Rsyncd_Port_Args} = "Порты/Аргументы Rsyncd";
$Lang{CfgEdit_Title_Archive_Paths_Commands} = "Пути/Команды Archive";
$Lang{CfgEdit_Title_Schedule} = "Планировщик";
$Lang{CfgEdit_Title_Full_Backups} = "Полное Резервирование";
$Lang{CfgEdit_Title_Incremental_Backups} = "Инкрементальное Резервирование";
$Lang{CfgEdit_Title_Blackouts} = "Перерыв";
$Lang{CfgEdit_Title_Other} = "Прочее";
$Lang{CfgEdit_Title_Backup_Settings} = "Другое";
$Lang{CfgEdit_Title_Client_Lookup} = "Поиск Клиента";
$Lang{CfgEdit_Title_User_Commands} = "Пользовательские Команды";
$Lang{CfgEdit_Title_Hosts} = "Узлы";

$Lang{CfgEdit_Hosts_Comment} = <<EOF;
Чтобы добавить новый узел, нажмите на кнопку "Добавить" и введите имя узла.
Чтобы задать новому узлу настройки от другого уже существующего узла,
введите название узла как НОВЫЙ_УЗЕЛ=СУЩЕСТВУЮЩИЙ_УЗЕЛ.
Таким же образом можно переназначить настройки и уже существующему узлу.
Для удаления узла нажмите на кнопку "Удалить".
Чтобы изменения вступили в силу, нажмите на кнопку "Сохранить".
Резервные копии удалённых узлов сохраняются. Поэтому если Вы удалили узел
случайно, то просто добавьте его опять.
Чтобы удалить и сами резервные копии узла, Вам надо вручную удалить
каталог \$topDir/pc/УЗЕЛ.
EOF

$Lang{CfgEdit_Header_Main} = <<EOF;
\${h1("Редактирование Основных Настроек")}
EOF

$Lang{CfgEdit_Header_Host} = <<EOF;
\${h1("Редактирование Настроек Узла \$host")}
<p>
Примечание: Поставьте галочку рядом с "Заменить", если хотите изменить значение параметра индивидуально для этого узла.
<p>
EOF

$Lang{CfgEdit_Button_Save}     = "Сохранить";
$Lang{CfgEdit_Button_Insert}   = "Вставить";
$Lang{CfgEdit_Button_Delete}   = "Удалить";
$Lang{CfgEdit_Button_Add}      = "Добавить";
$Lang{CfgEdit_Button_Override} = "Заменить";
$Lang{CfgEdit_Button_New_Key}  = "New Key";

$Lang{CfgEdit_Error_No_Save}
            = "Ошибка: не сохранено из-за наличия ошибок";
$Lang{CfgEdit_Error__must_be_an_integer}
            = "Ошибка: \$var должно быть целым числом";
$Lang{CfgEdit_Error__must_be_real_valued_number}
            = "Ошибка: \$var должно быть действительным числом";
$Lang{CfgEdit_Error__entry__must_be_an_integer}
            = "Ошибка: \$var элемент \$k должен быть целым числом";
$Lang{CfgEdit_Error__entry__must_be_real_valued_number}
            = "Ошибка: \$var элемент \$k должен быть действительным числом";
$Lang{CfgEdit_Error__must_be_executable_program}
            = "Ошибка: \$var должно быть действительным путём исполняемой программы";
$Lang{CfgEdit_Error__must_be_valid_option}
            = "Ошибка: \$var должно быть допустимой опцией";
$Lang{CfgEdit_Error_Copy_host_does_not_exist}
            = "Копируемый узел \$copyHost отсутствует, создаётся узел \$fullHost. Удалите этот узел, если это не то, что Вам требуется.";

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
  
#end of ru.pm
