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

$Lang{Start_Archive} = "开始备档";
$Lang{Stop_Dequeue_Archive} = "中止／取消备档";
$Lang{Start_Full_Backup} = "开始完全备份";
$Lang{Start_Incr_Backup} = "开始增量备份";
$Lang{Stop_Dequeue_Backup} = "中止／取消备份";
$Lang{Restore} = "恢复";

$Lang{Type_full} = "完全";
$Lang{Type_incr} = "增量";

# -----

$Lang{Only_privileged_users_can_view_admin_options} = "只有特权用户可以查看管理选项。";
$Lang{H_Admin_Options} = "BackupPC 服务器：管理选项";
$Lang{Admin_Options} = "管理选项";
$Lang{Admin_Options_Page} = <<EOF;
\${h1(qq{$Lang{Admin_Options}})}
<br>
\${h2("服务器控制")}
<form name="ReloadForm" action="\$MyURL" method="get">
<input type="hidden" name="action" value="">
<table class="tableStnd">
  <tr><td>更新服务器配置：<td><input type="button" value="更新配置"
     onClick="document.ReloadForm.action.value='Reload';
              document.ReloadForm.submit();">
</table>
</form>
<!--
\${h2("服务器配置")}
<ul>
  <li><i>其它选项，如：</i>
  <li>更改服务器配置
</ul>
-->
EOF

$Lang{Unable_to_connect_to_BackupPC_server} = "无法连接到 BackupPC 服务器";
$Lang{Unable_to_connect_to_BackupPC_server_error_message} = <<EOF;
CGI 脚本程序 (\$MyURL) 无法连接到 BackupPC 服务器 \$Conf{ServerHost} 端口 \$Conf{ServerPort}。错误信息：\$err。
可能 BackupPC 服务器没有运行，或者服务器配置不正确。请通知网络系统管理员。
<br><br>
EOF

$Lang{Admin_Start_Server} = <<EOF;
\${h1(qq{$Lang{Unable_to_connect_to_BackupPC_server}})}
<form action="\$MyURL" method="get">
BackupPC 服务器 <tt>\$Conf{ServerHost}</tt> 端口 <tt>\$Conf{ServerPort}</tt>
此刻没有运行（可能刚被停止，或者还没被启动）。<br>
你想现在启动它吗？
<input type="hidden" name="action" value="startServer">
<input type="submit" value="启动服务器" name="ignore">
</form>
EOF

# -----

$Lang{H_BackupPC_Server_Status} = "BackupPC 服务器状态";

$Lang{BackupPC_Server_Status_General_Info}= <<EOF;
\${h2(\"服务器总体信息\")}

<ul>
<li> 服务器进程号是 \$Info{pid}，运行在主机 \$Conf{ServerHost} 上，
     版本号 \$Info{Version}，开始运行于 \$serverStartTime。
<li> 此状态报告生成于 \$now。
<li> 服务器配置最近一次加载于 \$configLoadTime。
<li> 服务器任务队列下次启动时间是 \$nextWakeupTime。
<li> 其它信息：
    <ul>
        <li>\$numBgQueue 个自上次遗留备份请求，
        <li>\$numUserQueue 个待处理用户备份请求，
        <li>\$numCmdQueue 个待处理命令请求，
        \$poolInfo
        <li>备份池文件系统磁盘空间占用率是 \$Info{DUlastValue}%
            （统计于 \$DUlastTime），今天的最大占用率是 \$Info{DUDailyMax}%（统计于 \$DUmaxTime），
            昨天的最大占用率是 \$Info{DUDailyMaxPrev}%。
    </ul>
</ul>
EOF

$Lang{BackupPC_Server_Status} = <<EOF;
\${h1(qq{$Lang{H_BackupPC_Server_Status}})}

<p>
\${h2("正在运行的任务")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td> 客户机 </td>
    <td> 类型 </td>
    <td> 用户 </td>
    <td> 开始时间 </td>
    <td> 命令 </td>
    <td align="center"> 进程号 </td>
    <td align="center"> 传输进程号 </td>
    <td align="center"> Status </td>
    <td align="center"> Count </td>
    </tr>
\$jobStr
</table>

<p>
\$generalInfo

\${h2("需要关注的错误")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> 客户机 </td>
    <td align="center"> 类型 </td>
    <td align="center"> 用户 </td>
    <td align="center"> 最后一次尝试 </td>
    <td align="center"> 详情 </td>
    <td align="center"> 错误时间 </td>
    <td> 最后一次错误（ PING 失败除外） </td></tr>
\$statusStr
</table>
EOF

# --------------------------------
$Lang{BackupPC__Server_Summary} = "BackupPC: 客户机报告";
$Lang{BackupPC__Archive} = "BackupPC: 备档";
$Lang{BackupPC_Summary} = <<EOF;

\${h1(qq{$Lang{BackupPC__Server_Summary}})}
<p>
<ul>
<li>此状态报告生成于 \$now。
<li>备份池文件系统磁盘空间占用率是 \$Info{DUlastValue}%
    （统计于 \$DUlastTime），今天的最大占用率是 \$Info{DUDailyMax}%（统计于 \$DUmaxTime），
    昨天的最大占用率是 \$Info{DUDailyMaxPrev}%。
</ul>
</p>

\${h2("已成功完成备份的客户机")}
<p>
有 \$hostCntGood 台客户机已完成备份，总数是：
<ul>
<li> \$fullTot 个完全备份，总大小是 \${fullSizeTot}GiB
     （被压缩前值），
<li> \$incrTot 个增量备份，总大小是 \${incrSizeTot}GiB
     （被压缩前值）。
</ul>
</p>
<table class="sortable" id="host_summary_backups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> 客户机 </td>
    <td align="center"> 用户 </td>
    <td align="center"> 完全备份个数 </td>
    <td align="center"> 最后一次完全备份 (天前) </td>
    <td align="center"> 完全备份大小 (GiB) </td>
    <td align="center"> 完全备份速度 (MB/s) </td>
    <td align="center"> 增量备份个数 </td>
    <td align="center"> 最后一次增量备份 (天前) </td>
    <td align="center"> 最后一次备份 (天前) </td>
    <td align="center"> 当前状态 </td>
    <td align="center"> 传输错误数目 </td>
    <td align="center"> 最后一次备份结果 </td></tr>
\$strGood
</table>
<br><br>
\${h2("未备份过的客户机")}
<p>
有 \$hostCntNone 台客户机从未被备份过。
<p>
<table class="sortable" id="host_summary_nobackups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> 客户机 </td>
    <td align="center"> 用户 </td>
    <td align="center"> 完全备份个数 </td>
    <td align="center"> 最后一次完全备份 (天前) </td>
    <td align="center"> 完全备份大小 (GiB) </td>
    <td align="center"> 完全备份速度 (MB/s) </td>
    <td align="center"> 增量备份个数 </td>
    <td align="center"> 最后一次增量备份 (天前) </td>
    <td align="center"> 最后一次备份 (天前) </td>
    <td align="center"> 当前状态 </td>
    <td align="center"> 传输错误数目 </td>
    <td align="center"> 最后一次备份结果 </td></tr>
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

一共有 \$hostCntGood 台客户机已经被备份，总备份大小为 \${fullSizeTot}GiB
<p>
<form name="form1" method="post" action="\$MyURL">
<input type="hidden" name="fcbMax" value="\$checkBoxCnt">
<input type="hidden" name="type" value="1">
<input type="hidden" name="host" value="\${EscHTML(\$archHost)}">
<input type="hidden" name="action" value="Archive">
<table class="tableStnd" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td align=center> 客户机 </td>
    <td align="center"> 用户 </td>
    <td align="center"> 备份大小 </td>
\$strGood
\$checkAllHosts
</table>
</form>
<p>

EOF

$Lang{BackupPC_Archive2} = <<EOF;
\${h1(qq{$Lang{BackupPC__Archive}})}
即将为下列客户机备档
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
    <td colspan=2><input type="submit" value="开始备档" name="ignore"></td>
</tr>
</form>
</table>
EOF

$Lang{BackupPC_Archive2_location} = <<EOF;
<tr>
    <td>备档目的地／外设</td>
    <td><input type="text" value="\$ArchiveDest" name="archive_device"></td>
</tr>
EOF

$Lang{BackupPC_Archive2_compression} = <<EOF;
<tr>
    <td>压缩</td>
    <td>
    <input type="radio" value="0" name="compression" \$ArchiveCompNone>无<br>
    <input type="radio" value="1" name="compression" \$ArchiveCompGzip>gzip<br>
    <input type="radio" value="2" name="compression" \$ArchiveCompBzip2>bzip2
    </td>
</tr>
EOF

$Lang{BackupPC_Archive2_parity} = <<EOF;
<tr>
    <td>奇偶校验数据比例 (0 = 不启用，5 = 典型设置)</td>
    <td><input type="numeric" value="\$ArchivePar" name="par"></td>
</tr>
EOF

$Lang{BackupPC_Archive2_split} = <<EOF;
<tr>
    <td>将输出分开为</td>
    <td><input type="numeric" value="\$ArchiveSplit" name="splitsize">兆字节</td>
</tr>
EOF

# -----------------------------------
$Lang{Pool_Stat} = <<EOF;
        <li>备份服务器文件池大小是 \${poolSize}GiB 包含 \$info->{"\${name}FileCnt"} 个文件
            和 \$info->{"\${name}DirCnt"} 个文件夹／目录（截至 \$poolTime）。文件池大小基本就是所有备份数据占用的实际磁盘空间。
        <li>服务器文件池散列操作(Hashing)发现 \$info->{"\${name}FileCntRep"} 
            个文件具有重复散列值，其中 \$info->{"\${name}FileRepMax"} 个文件具有相同散列值。相同散列值并不意味着相同文件。散列操作被用来节省相同文件所占用的磁盘空间。
        <li>每日例行清理过期数据操作删除了 \$info->{"\${name}FileCntRm"} 个文件共
             \${poolRmSize}GiB （操作于 \$poolTime ）。
EOF

# --------------------------------
$Lang{BackupPC__Backup_Requested_on__host} = "BackupPC: 客户机 \$host 有备份请求";
# --------------------------------
$Lang{REPLY_FROM_SERVER} = <<EOF;
\${h1(\$str)}
<p>
服务器答复是：\$reply
<p>
返回 <a href="\$MyURL?host=\$host">\$host 主页</a>。
EOF
# --------------------------------
$Lang{BackupPC__Start_Backup_Confirm_on__host} = "BackupPC: 客户机 \$host 开始备份确认";
# --------------------------------
$Lang{Are_you_sure_start} = <<EOF;
\${h1("确定？")}
<p>
你即将在客户机 \$host 上开始 \$type 备份。

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="hostIP" value="\$ipAddr">
<input type="hidden" name="doit" value="1">
<input type="hidden" name="action" value="">
你能确定吗？
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="取消" name="ignore">
</form>
EOF
# --------------------------------
$Lang{BackupPC__Stop_Backup_Confirm_on__host} = "BackupPC: 客户机 \$host 停止备份确认";
# --------------------------------
$Lang{Are_you_sure_stop} = <<EOF;

\${h1("确定？")}

<p>
你即将在客户机 \$host 上停止／取消备份操作；

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host"   value="\$host">
<input type="hidden" name="doit"   value="1">
<input type="hidden" name="action" value="">
如果确定取消备份操作，请从现在起
<input type="text" name="backoff" size="10" value="\$backoff"> 小时内不要再启动另一备份操作。
<p>
你能确定吗？
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="不" name="ignore">
</form>

EOF
# --------------------------------
$Lang{Only_privileged_users_can_view_queues_} = "只有特权用户可以查看任务请求队列。";
# --------------------------------
$Lang{Only_privileged_users_can_archive} = "只有特权用户可以执行备档操作。";
# --------------------------------
$Lang{BackupPC__Queue_Summary} = "BackupPC: 队列报告";
# --------------------------------
$Lang{Backup_Queue_Summary} = <<EOF;
\${h1("备份请求队列报告")}
<br><br>
\${h2("用户队列报告")}
<p>
下列用户请求排在队列中：
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> 客户机 </td>
    <td> 请求时间 </td>
    <td> 用户 </td></tr>
\$strUser
</table>
<br><br>

\${h2("后台请求队列报告")}
<p>
下列后台请求排在队列中：
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> 客户机 </td>
    <td> 请求时间 </td>
    <td> 用户 </td></tr>
\$strBg
</table>
<br><br>
\${h2("命令队列报告")}
<p>
下列命令请求排在队列中：
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> 客户机 </td>
    <td> 请求时间 </td>
    <td> 用户 </td>
    <td> 命令 </td></tr>
\$strCmd
</table>
EOF

# --------------------------------
$Lang{Backup_PC__Log_File__file} = "BackupPC: 日志文件 \$file";
$Lang{Log_File__file__comment} = <<EOF;
\${h1("日志文件 \$file \$comment")}
<p>
EOF
# --------------------------------
$Lang{Contents_of_log_file} = <<EOF;
日志文件 <tt>\$file</tt>， 修改时间 \$mtimeStr \$comment
EOF

# --------------------------------
$Lang{skipped__skipped_lines} = "[ 略过 \$skipped 行 ]\n";
# --------------------------------
$Lang{_pre___Can_t_open_log_file__file} = "<pre>\n无法打开日志文件 \$file\n";

# --------------------------------
$Lang{BackupPC__Log_File_History} = "BackupPC: 日志文件历史";
$Lang{Log_File_History__hdr} = <<EOF;
\${h1("日志文件历史 \$hdr")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> 文件 </td>
    <td align="center"> 大小 </td>
    <td align="center"> 修改时间 </td></tr>
\$str
</table>
EOF

# -------------------------------
$Lang{Recent_Email_Summary} = <<EOF;
\${h1("最近电子邮件报告（最新排前）")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> 收信人 </td>
    <td align="center"> 客户机 </td>
    <td align="center"> 时间 </td>
    <td align="center"> 标题 </td></tr>
\$str
</table>
EOF
 

# ------------------------------
$Lang{Browse_backup__num_for__host} = "BackupPC: 浏览客户机 \$host 备份序列号 \$num";

# ------------------------------
$Lang{Restore_Options_for__host} = "BackupPC: 客户机 \$host 恢复选项";
$Lang{Restore_Options_for__host2} = <<EOF;
\${h1("客户机 \$host 恢复选项")}
<p>
你从备份序列 #\$num，卷 \$share 中选择了以下文件／目录：
<ul>
\$fileListStr
</ul>
</p><p>
你有三种选择来恢复这些文件／目录。
请从下列三种方法中选择其一。
</p>
\${h2("方法 1：直接恢复")}
<p>
EOF

$Lang{Restore_Options_for__host_Option1} = <<EOF;
你可以将这些文件直接恢复到客户机 <b>\$directHost</b> 上。
</p><p>
<b>警告：</b> 客户机上现存的文件，如果和被恢复的文件具有相同文件名并且位于相同路径，其内容将会被替换！
</p>
<form action="\$MyURL" method="post" name="direct">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="3">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<table class="tableStnd" border="0">
<tr>
    <td>恢复到客户机</td>
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
	 <!--<a href="javascript:myOpen('\$MyURL?action=findShares&host='+document.direct.hostDest.options.value)">搜寻可供使用的文件卷（此功能还未被实现）</a>--></td>
</tr><tr>
    <td>恢复到卷</td>
    <td><input type="text" size="40" value="\${EscHTML(\$share)}"
	 name="shareDest"></td>
</tr><tr>
    <td>恢复到此目录中<br>（位于上述卷下）</td>
    <td valign="top"><input type="text" size="40" maxlength="256"
	value="\${EscHTML(\$pathHdr)}" name="pathHdr"></td>
</tr><tr>
    <td><input type="submit" value="开始恢复" name="ignore"></td>
</table>
</form>
EOF

$Lang{Restore_Options_for__host_Option1_disabled} = <<EOF;
直接恢复到客户机 \${EscHTML(\$hostDest) 的功能被关闭。
请选择其它恢复方法。
EOF

# ------------------------------
$Lang{Option_2__Download_Zip_archive} = <<EOF;
<p>
\${h2("方法 2：下载 Zip 备档")}
<p>
你可以将所有你选择的文件和目录下载进一个 Zip 备档。然后再用一个本地应用，
例如 WinZip，来浏览或提取其中的任何文件。 
</p><p>
<b>警告：</b> 取决于你选择的文件／目录，此备档可能会占用很大存储空间。
可能需要若干分钟或更长时间来生成和传输此备档，并且还需要足够大的本地磁盘空间。
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="2">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> 备档中所有文件具有相对路径，在 \${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)} 目录内
（否则备档中文件具有完整路径）。
<br>
<table class="tableStnd" border="0">
<tr>
    <td>选择压缩比（0＝不压缩，1＝最低但速度快，...，9＝最高但速度慢）</td>
    <td><input type="text" size="6" value="5" name="compressLevel"></td>
</tr><tr>
    <td>Code page (e.g. cp866)</td>
    <td><input type="text" size="6" value="utf8" name="codePage"></td>
</tr>
</table>
<br>
<input type="submit" value="下载 Zip 文件" name="ignore">
</form>
EOF

# ------------------------------

$Lang{Option_2__Download_Zip_archive2} = <<EOF;
<p>
\${h2("方法 2：下载 Zip 备档")}
<p>
因服务器没有安装 Perl 组件 Archive::Zip，Zip 备档无法被生成。
请联系系统管理员安装 Archive::Zip，下载地址
<a href="http://www.cpan.org">www.cpan.org</a>。
</p>
EOF


# ------------------------------
$Lang{Option_3__Download_Zip_archive} = <<EOF;
\${h2("方法 3：下载 Tar 备档")}
<p>
你可以将所有你选择的文件和目录下载进一个 Tar 备档。然后再用一个本地应用，
例如 tar 或 WinZip，来浏览或提取其中的任何文件。 
</p><p>
<b>警告：</b> 取决于你选择的文件／目录，此备档可能会占用很大存储空间。
可能需要若干分钟或更长时间来生成和传输此备档，并且还需要足够大的本地磁盘空间。
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="1">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> 备档中所有文件具有相对路径，在 \${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)} 目录内
（否则备档中文件具有完整路径）。
<br>
<input type="submit" value="下载 Tar 文件" name="ignore">
</form>
EOF


# ------------------------------
$Lang{Restore_Confirm_on__host} = "BackupPC: 客户机 \$host 开始恢复确认";

$Lang{Are_you_sure} = <<EOF;
\${h1("确定？")}
<p>
你即将开始恢复数据直接到客户机 \$In{hostDest} 上。
储存在备份号 \$num 中的下列文件将被恢复到卷 \$In{shareDest} 内：
<p>
<table class="tableStnd" border>
<tr class="tableheader"><td>原始文件／目录</td><td>将被恢复到</td></tr>
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
你确定吗？
<input type="button" value="\$Lang->{Restore}"
 onClick="document.RestoreForm.action.value='Restore';
          document.RestoreForm.submit();">
<input type="submit" value="不" name="ignore">
</form>
EOF


# --------------------------
$Lang{Restore_Requested_on__hostDest} = "BackupPC: 客户机 \$hostDest 有恢复请求";
$Lang{Reply_from_server_was___reply} = <<EOF;
\${h1(\$str)}
<p>
服务器答复是：\$reply
<p>
返回 <a href="\$MyURL?host=\$hostDest">\$hostDest 主页</a>。
EOF

$Lang{BackupPC_Archive_Reply_from_server} = <<EOF;
\${h1(\$str)}
<p>
服务器答复是：\$reply
EOF


# -------------------------
$Lang{Host__host_Backup_Summary} = "BackupPC: 客户机 \$host 备份报告";

$Lang{Host__host_Backup_Summary2} = <<EOF;
\${h1("客户机 \$host 备份报告")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>
</p>
\${h2("用户操作")}
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
\${h2("备份报告")}
<p>
点击备份序列号浏览和恢复文件。
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> 备份序列号＃ </td>
    <td align="center"> 类型 </td>
    <td align="center"> 完整 </td>
    <td align="center"> 备份级别 </td>
    <td align="center"> 开始时间 </td>
    <td align="center"> 耗时（分钟）</td>
    <td align="center"> 距离现在（天前）</td>
    <td align="center"> 服务器上备份路径 </td>
</tr>
\$str
</table>
<p>

\$restoreStr
</p>
<br><br>
\${h2("传输错误报告")}
<br><br>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> 备份序列号＃ </td>
    <td align="center"> 类型 </td>
    <td align="center"> 查看 </td>
    <td align="center"> 传输错误数目 </td>
    <td align="center"> 损坏文件数目 </td>
    <td align="center"> 损坏文件系统卷数目 </td>
    <td align="center"> 损坏 Tar 文件数目 </td>
</tr>
\$errStr
</table>
<br><br>

\${h2("文件大小／数目统计")}
<p>
"原有文件"是指原先已存在备份池中的文件；"新增文件"是指备份新写入池中的文件。
空文件不被统计在内。
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="2" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> 合计 </td>
    <td align="center" colspan="2"> 原有文件 </td>
    <td align="center" colspan="2"> 新增文件 </td>
</tr>
<tr class="tableheader">
    <td align="center"> 备份序列号＃ </td>
    <td align="center"> 类型 </td>
    <td align="center"> 文件数目 </td>
    <td align="center"> 大小(MB) </td>
    <td align="center"> 备份速度(MB/sec) </td>
    <td align="center"> 文件数目 </td>
    <td align="center"> 大小(MB) </td>
    <td align="center"> 文件数目 </td>
    <td align="center"> 大小(MB) </td>
</tr>
\$sizeStr
</table>
<br><br>

\${h2("压缩报告")}
<p>
备份池中原有文件和新增文件的压缩性能报告。
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="3" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> 原有文件 </td>
    <td align="center" colspan="3"> 新增文件 </td>
</tr>
<tr class="tableheader"><td align="center"> 备份序列号＃ </td>
    <td align="center"> 类型 </td>
    <td align="center"> 压缩级别 </td>
    <td align="center"> 压缩前(MB) </td>
    <td align="center"> 压缩后(MB) </td>
    <td align="center"> 压缩比 </td>
    <td align="center"> 压缩前(MB) </td>
    <td align="center"> 压缩后(MB) </td>
    <td align="center"> 压缩比 </td>
</tr>
\$compStr
</table>
<br><br>
EOF

$Lang{Host__host_Archive_Summary} = "BackupPC: 客户机 \$host 备档报告";
$Lang{Host__host_Archive_Summary2} = <<EOF;
\${h1("客户机 \$host 备档报告")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>

\${h2("用户操作")}
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
$Lang{Error} = "BackupPC: 错误";
$Lang{Error____head} = <<EOF;
\${h1("错误：\$head")}
<p>\$mesg</p>
EOF

# -------------------------
$Lang{NavSectionTitle_} = "服务器";

# -------------------------
$Lang{Backup_browse_for__host} = <<EOF;
\${h1("客户机 \$host 备份浏览")}

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
<li> 你正在浏览备份 #\$num，该备份开始于 \$backupTime 
       （\$backupAge 天前）。
\$filledBackup
<li> 进入目录：<input type="text" name="dir" size="50" maxlength="4096" value="\${EscHTML(\$dir)}"> <input type="submit" value="\$Lang->{Go}" name="Submit">
<li> 点击目录名进入相应目录。
<li> 点击文件名恢复相应文件。
<li> 查看当前目录的备份<a href="\$MyURL?action=dirHistory&host=\${EscURI(\$host)}&share=\$shareURI&dir=\$pathURI">历史</a>。
</ul>
</form>

\${h2("\$dirDisplay 的内容")}
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
<input type="submit" name="Submit" value="恢复被选择的文件">
-->
</form>
EOF

# ------------------------------
$Lang{DirHistory_backup_for__host} = "BackupPC: 客户机 \$host 目录备份历史";

#
# These two strings are used to build the links for directories and
# file versions.  Files are appended with a version number.
#
$Lang{DirHistory_dirLink}  = "目录";
$Lang{DirHistory_fileLink} = "v";

$Lang{DirHistory_for__host} = <<EOF;
\${h1("客户机 \$host 目录备份历史")}
<p>
本页显示文件在所有备份中的不同版本：
<ul>
<li> 点击备份序列号返回相应备份浏览主页，
<li> 点击目录链接标记 (\$Lang->{DirHistory_dirLink}) 进入相应目录，
<li> 点击文件版本链接标记 (\$Lang->{DirHistory_fileLink}0,
     \$Lang->{DirHistory_fileLink}1, ...) 下载相应文件，
<li> 如果一个文件的内容在多个备份中相同，文件在多个备份中具有相同版本号，
<li> 如果一个文件或目录在某个备份中不存在，下表中用空白表示，
<li> 具有相同版本号的文件可能在不同备份中有不同的文件属性。可以点击备份序列号来查看文件在相应备份中的属性。
</ul>

\${h2("\$dirDisplay 的历史")}

<br>
<table border cellspacing="2" cellpadding="3">
<tr class="fviewheader"><td>备份序列号</td>\$backupNumStr</tr>
<tr class="fviewheader"><td>备份时间</td>\$backupTimeStr</tr>
\$fileStr
</table>
EOF

# ------------------------------
$Lang{Restore___num_details_for__host} = "BackupPC: 客户机 \$host 恢复 #\$num 详情";

$Lang{Restore___num_details_for__host2} = <<EOF;
\${h1("客户机 \$host 恢复 #\$num 详情")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="90%">
<tr><td class="tableheader"> 恢复序列号 </td><td class="border"> \$Restores[\$i]{num} </td></tr>
<tr><td class="tableheader"> 请求方 </td><td class="border"> \$RestoreReq{user} </td></tr>
<tr><td class="tableheader"> 请求时间 </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> 结果 </td><td class="border"> \$Restores[\$i]{result} </td></tr>
<tr><td class="tableheader"> 错误信息 </td><td class="border"> \$Restores[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> 源客户机 </td><td class="border"> \$RestoreReq{hostSrc} </td></tr>
<tr><td class="tableheader"> 源备份序列号 </td><td class="border"> \$RestoreReq{num} </td></tr>
<tr><td class="tableheader"> 源文件卷 </td><td class="border"> \$RestoreReq{shareSrc} </td></tr>
<tr><td class="tableheader"> 目的客户机 </td><td class="border"> \$RestoreReq{hostDest} </td></tr>
<tr><td class="tableheader"> 目的文件卷 </td><td class="border"> \$RestoreReq{shareDest} </td></tr>
<tr><td class="tableheader"> 恢复开始时间 </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> 耗时 </td><td class="border"> \$duration 分钟 </td></tr>
<tr><td class="tableheader"> 文件个数 </td><td class="border"> \$Restores[\$i]{nFiles} </td></tr>
<tr><td class="tableheader"> 文件总大小 </td><td class="border"> \${MB} MB </td></tr>
<tr><td class="tableheader"> 传输速率 </td><td class="border"> \$MBperSec MB/sec </td></tr>
<tr><td class="tableheader"> Tar 生成过程错误个数 </td><td class="border"> \$Restores[\$i]{tarCreateErrs} </td></tr>
<tr><td class="tableheader"> 传输过程错误个数 </td><td class="border"> \$Restores[\$i]{xferErrs} </td></tr>
<tr><td class="tableheader"> 传输日志文件 </td><td class="border">
<a href="\$MyURL?action=view&type=RestoreLOG&num=\$Restores[\$i]{num}&host=\$host">查看日志</a>,
<a href="\$MyURL?action=view&type=RestoreErr&num=\$Restores[\$i]{num}&host=\$host">查看错误</a>
</tr></tr>
</table>
</p>
\${h1("文件／目录列表")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="100%">
<tr class="tableheader"><td>原始文件／目录</td><td>恢复至</td></tr>
\$fileListStr
</table>
EOF

# ------------------------------
$Lang{Archive___num_details_for__host} = "BackupPC: 客户机 \$host 备档 #\$num 详情";

$Lang{Archive___num_details_for__host2 } = <<EOF;
\${h1("客户机 \$host 备档 #\$num 详情")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr><td class="tableheader"> 备档序列号 </td><td class="border"> \$Archives[\$i]{num} </td></tr>
<tr><td class="tableheader"> 请求方 </td><td class="border"> \$ArchiveReq{user} </td></tr>
<tr><td class="tableheader"> 请求方 </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> 结果 </td><td class="border"> \$Archives[\$i]{result} </td></tr>
<tr><td class="tableheader"> 错误信息 </td><td class="border"> \$Archives[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> 开始时间 </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> 耗时 </td><td class="border"> \$duration 分钟 </td></tr>
<tr><td class="tableheader"> 传输日志文件 </td><td class="border">
<a href="\$MyURL?action=view&type=ArchiveLOG&num=\$Archives[\$i]{num}&host=\$host">查看日志</a>,
<a href="\$MyURL?action=view&type=ArchiveErr&num=\$Archives[\$i]{num}&host=\$host">查看错误</a>
</tr></tr>
</table>
<p>
\${h1("客户机列表")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td>客户机</td><td>备份序列号</td></tr>
\$HostListStr
</table>
EOF

# -----------------------------------
$Lang{Email_Summary} = "BackupPC: 电子邮件报告";

# -----------------------------------
#  !! ERROR messages !!
# -----------------------------------
$Lang{BackupPC__Lib__new_failed__check_apache_error_log} = "BackupPC::Lib->new 步骤失败：请检查 Apache 服务器日志\n";
$Lang{Wrong_user__my_userid_is___} =  
              "错误用户：我的用户 ID 是 \$>, 不是 \$uid"
            . "(\$Conf{BackupPCUser})\n";
# $Lang{Only_privileged_users_can_view_PC_summaries} = "Only privileged users can view PC summaries.";
$Lang{Only_privileged_users_can_stop_or_start_backups} = 
                  "只有特权用户可以执行备份的开始或停止操作于客户机"
		. " \${EscHTML(\$host)}.";
$Lang{Invalid_number__num} = "无效数字 \${EscHTML(\$In{num})}";
$Lang{Unable_to_open__file__configuration_problem} = "无法打开文件 \$file：配置有误？";
$Lang{Only_privileged_users_can_view_log_or_config_files} = "只有特权用户可以查看日志或配置文件。";
$Lang{Only_privileged_users_can_view_log_files} = "只有特权用户可以查看日志文件。";
$Lang{Only_privileged_users_can_view_email_summaries} = "只有特权用户可以查看电子邮件报告。";
$Lang{Only_privileged_users_can_browse_backup_files} = "只有特权用户可以浏览"
                . "客户机 \${EscHTML(\$In{host})} 的备份文件。";
$Lang{Empty_host_name} = "空客户机名。";
$Lang{Directory___EscHTML} = "目录 \${EscHTML(\"\$TopDir/pc/\$host/\$num\")}"
		    . " 为空";
$Lang{Can_t_browse_bad_directory_name2} = "无法浏览非法目录名"
	            . " \${EscHTML(\$relDir)}";
$Lang{Only_privileged_users_can_restore_backup_files} = "只有特权用户可以恢复"
                . "客户机 \${EscHTML(\$In{host})} 的备份文件。";
$Lang{Bad_host_name} = "错误客户机名 \${EscHTML(\$host)}";
$Lang{You_haven_t_selected_any_files__please_go_Back_to} = "你还没有选择任何文件；请返回上一页"
                . "选择文件。";
$Lang{You_haven_t_selected_any_hosts} = "你还没有选择任何客户机；请返回上一页"
                . "选择客户机。";
$Lang{Nice_try__but_you_can_t_put} = "对不起，文件名内不能包含 \'..\'";
$Lang{Host__doesn_t_exist} = "客户机 \${EscHTML(\$In{hostDest})} 不存在";
$Lang{You_don_t_have_permission_to_restore_onto_host} = "你没有权限恢复客户机"
		    . " \${EscHTML(\$In{hostDest})}";
$Lang{Can_t_open_create__openPath} = "无法打开／创建 "
		. "\${EscHTML(\"\$openPath\")}";
$Lang{Only_privileged_users_can_restore_backup_files2} = "只有特权用户可以恢复"
                . "客户机 \${EscHTML(\$host)} 的备份文件。";
$Lang{Empty_host_name} = "空客户机名";
$Lang{Unknown_host_or_user} = "未知客户机或用户 \${EscHTML(\$host)}";
$Lang{Only_privileged_users_can_view_information_about} = "只有特权用户可以查看"
                . "客户机 \${EscHTML(\$host)} 的信息。" ;
$Lang{Only_privileged_users_can_view_archive_information} = "只有特权用户可以查看备档信息。";
$Lang{Only_privileged_users_can_view_restore_information} = "只有特权用户可以查看恢复信息。";
$Lang{Restore_number__num_for_host__does_not_exist} = "客户机 \${EscHTML(\$host)} 恢复序列号 \$num "
	        . "不存在。";
$Lang{Archive_number__num_for_host__does_not_exist} = "客户机 \${EscHTML(\$host)} 备档序列号 \$num "
	        . "不存在。";
$Lang{Can_t_find_IP_address_for} = "客户机 \${EscHTML(\$host)} 的 IP 地址无法找到";
$Lang{host_is_a_DHCP_host} = <<EOF;
客户机 \$host 的网络设置是使用动态 IP 地址（DHCP），现在它的 IP 地址未知。已经检查过 \$ENV{REMOTE_ADDR}\$tryIP 的 NETBIOS 名，但那台机器不是 \$host。
<p>
除非获得客户机 \$host 的动态 IP 地址，否则只能从客户主机上发出此任务请求。
EOF

# ------------------------------------
# !! Server Mesg !!
# ------------------------------------

$Lang{Backup_requested_on_DHCP__host} = "用户 \$User 从 \$ENV{REMOTE_ADDR} 发起请求备份使用动态 IP 的客户机 \$host (\$In{hostIP})";
$Lang{Backup_requested_on__host_by__User} = "用户 \$User 发起请求备份客户机 \$host";
$Lang{Backup_stopped_dequeued_on__host_by__User} = "用户 \$User 停止／取消了对客户机 \$host 的备份";
$Lang{Restore_requested_to_host__hostDest__backup___num} = "用户 \$User 从 \$ENV{REMOTE_ADDR} 发起请求恢复客户机 \$hostDest，使用备份序列号 #\$num";
$Lang{Archive_requested} = "用户 \$User 从 \$ENV{REMOTE_ADDR} 发起备档请求";

# -------------------------------------------------
# ------- Stuff that was forgotten ----------------
# -------------------------------------------------

$Lang{Status} = "状态";
$Lang{PC_Summary} = "客户机报告";
$Lang{LOG_file} = "日志文件";
$Lang{LOG_files} = "日志文件列表";
$Lang{Old_LOGs} = "旧日志";
$Lang{Email_summary} = "电子邮件报告";
$Lang{Config_file} = "配置文件";
# $Lang{Hosts_file} = "Hosts file";
$Lang{Current_queues} = "当前队列";
$Lang{Documentation} = "文档资料";

#$Lang{Host_or_User_name} = "<small>Host or User name:</small>";
$Lang{Go} = "确定";
$Lang{Hosts} = "客户机";
$Lang{Select_a_host} = "选择客户机名...";

$Lang{There_have_been_no_archives} = "<h2> 这台机器还从来没有执行过备档操作！</h2>\n";
$Lang{This_PC_has_never_been_backed_up} = "<h2> 这台机器还从来没有被备份过！！</h2>\n";
$Lang{This_PC_is_used_by} = "<li>这台机器的用户包括 \${UserLink(\$user)}";

$Lang{Extracting_only_Errors} = "（只提取错误信息）";
$Lang{XferLOG} = "传输日志";
$Lang{Errors}  = "错误";

# ------------
$Lang{Last_email_sent_to__was_at___subject} = <<EOF;
<li>给用户 \${UserLink(\$user)} 的最近一封邮件送出于 \$mailTime，标题是"\$subj"。
EOF
# ------------
$Lang{The_command_cmd_is_currently_running_for_started} = <<EOF;
<li>命令 \$cmd 正在为客户机 \$host 运行，开始于 \$startTime。
EOF

# -----------
$Lang{Host_host_is_queued_on_the_background_queue_will_be_backed_up_soon} = <<EOF;
<li>客户机 \$host 已在后台队列中等待（即将被备份）。
EOF

# ----------
$Lang{Host_host_is_queued_on_the_user_queue__will_be_backed_up_soon} = <<EOF;
<li>客户机 \$host 已在用户队列中等待（即将被备份）。
EOF

# ---------
$Lang{A_command_for_host_is_on_the_command_queue_will_run_soon} = <<EOF;
<li>针对客户机 \$host 的一条命令已在命令队列中等待（即将被执行）。
EOF

# --------
$Lang{Last_status_is_state_StatusHost_state_reason_as_of_startTime} = <<EOF;
<li>最后状态是 \"\$Lang->{\$StatusHost{state}}\"\$reason，当时时间 \$startTime。
EOF

# --------
$Lang{Last_error_is____EscHTML_StatusHost_error} = <<EOF;
<li>最后错误信息是 \"\${EscHTML(\$StatusHost{error})}\"。
EOF

# ------
$Lang{Pings_to_host_have_failed_StatusHost_deadCnt__consecutive_times} = <<EOF;
<li>试图与客户机 \$host 联系（Ping 操作）已连续失败 \$StatusHost{deadCnt} 次。 
EOF

# -----
$Lang{Prior_to_that__pings} = "先前，Ping";

# -----
$Lang{priorStr_to_host_have_succeeded_StatusHostaliveCnt_consecutive_times} = <<EOF;
<li>\$priorStr 客户机 \$host 已连续成功 \$StatusHost{aliveCnt} 次。
EOF

$Lang{Because__host_has_been_on_the_network_at_least__Conf_BlackoutGoodCnt_consecutive_times___} = <<EOF;
<li>因为客户机 \$host 已经在网络上至少连续 \$Conf{BlackoutGoodCnt} 次，
在下列时段 \$blackoutStr，它将不进行备份操作。
EOF

$Lang{__time0_to__time1_on__days} = "\$t0 to \$t1 在 \$days";

$Lang{Backups_are_deferred_for_hours_hours_change_this_number} = <<EOF;
<li>备份被推迟 \$hours 小时
(<a href=\"\$MyURL?action=Stop_Dequeue_Backup&host=\$host\">改变时间</a>)。
EOF

$Lang{tryIP} = " 和 \$StatusHost{dhcpHostIP}";

# $Lang{Host_Inhost} = "Host \$In{host}";

$Lang{checkAll} = <<EOF;
<tr><td class="fviewborder">
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;全选
</td><td colspan="5" align="center" class="fviewborder">
<input type="submit" name="Submit" value="恢复被选择的文件">
</td></tr>
EOF

$Lang{checkAllHosts} = <<EOF;
<tr><td class="fviewborder">
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;全选
</td><td colspan="2" align="center" class="fviewborder">
<input type="submit" name="Submit" value="备档被选择的客户机">
</td></tr>
EOF

$Lang{fileHeader} = <<EOF;
    <tr class="fviewheader"><td align=center> 文件／目录名</td>
       <td align="center"> 类型</td>
       <td align="center"> 读写权限</td>
       <td align="center"> 备份序列号</td>
       <td align="center"> 大小</td>
       <td align="center"> 修改日期</td>
    </tr>
EOF

$Lang{Home} = "主页";
$Lang{Browse} = "浏览备份";
$Lang{Last_bad_XferLOG} = "最近出错传输日志";
$Lang{Last_bad_XferLOG_errors_only} = "最近出错传输日志（只含错误）";

$Lang{This_display_is_merged_with_backup} = <<EOF;
<li> 本页显示的是与备份序列 #\$numF 合成的结果。
EOF

$Lang{Visit_this_directory_in_backup} = <<EOF;
<li> 选择你想查看的备份：<select onChange="window.location=this.value">\$otherDirs </select>
EOF

$Lang{Restore_Summary} = <<EOF;
\${h2("恢复报告")}
<p>
点击恢复序列号获取详情。
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> 恢复序列号 </td>
    <td align="center"> 结果 </td>
    <td align="right"> 开始时间 </td>
    <td align="right"> 耗时（分钟）</td>
    <td align="right"> 文件个数 </td>
    <td align="right"> 大小(MB) </td>
    <td align="right"> Tar 错误个数 </td>
    <td align="right"> 传输错误个数 </td>
</tr>
\$restoreStr
</table>
<p>
EOF

$Lang{Archive_Summary} = <<EOF;
\${h2("备档报告")}
<p>
点击备档序列号获取详情。
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> 备档序列号 </td>
    <td align="center"> 结果 </td>
    <td align="right"> 开始时间 </td>
    <td align="right"> 耗时（分钟）</td>
</tr>
\$ArchiveStr
</table>
<p>
EOF

$Lang{BackupPC__Documentation} = "BackupPC: 文档资料";

$Lang{No} = "否";
$Lang{Yes} = "是";

$Lang{The_directory_is_empty} = <<EOF;
<tr><td bgcolor="#ffffff">目录 \$dirDisplay 是空目录
</td></tr>
EOF

#$Lang{on} = "开";
$Lang{off} = "关";

$Lang{backupType_full}    = "完全";
$Lang{backupType_incr}    = "增量";
$Lang{backupType_active}  = "active";
$Lang{backupType_partial} = "部分";

$Lang{failed} = "失败";
$Lang{success} = "成功";
$Lang{and} = "和";

# ------
# Hosts states and reasons
$Lang{Status_idle} = "空闲";
$Lang{Status_backup_starting} = "备份已开始";
$Lang{Status_backup_in_progress} = "备份进行中";
$Lang{Status_restore_starting} = "恢复已开始";
$Lang{Status_restore_in_progress} = "恢复进行中";
$Lang{Status_admin_pending} = "文件链接待建立";
$Lang{Status_admin_running} = "文件链接建立中";

$Lang{Reason_backup_done}    = "完成";
$Lang{Reason_restore_done}   = "恢复完成";
$Lang{Reason_archive_done}   = "备档完成";
$Lang{Reason_nothing_to_do}  = "空闲";
$Lang{Reason_backup_failed}  = "备份失败";
$Lang{Reason_restore_failed} = "恢复失败";
$Lang{Reason_archive_failed} = "备档失败";
$Lang{Reason_no_ping}        = "网络连接中断(no ping)";
$Lang{Reason_backup_canceled_by_user}  = "备份被用户取消";
$Lang{Reason_restore_canceled_by_user} = "恢复被用户取消";
$Lang{Reason_archive_canceled_by_user} = "备档被用户取消";
$Lang{Disabled_OnlyManualBackups}  = "自动备份被关闭";  
$Lang{Disabled_AllBackupsDisabled} = "关闭";                  


# ---------
# Email messages

# No backup ever
$Lang{EMailNoBackupEverSubj} = "BackupPC: 客户机 \$host 从未被成功备份过";
$Lang{EMailNoBackupEverMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
尊敬的用户 $userName,

您的电脑 ($host) 还从来没有被我们的备份系统成功备份过。
正常情况下，当您的电脑与网络连接时电脑备份会自动进行。
如果您属于下面两种情况，请与系统管理员联系：

  － 您的电脑经常是连在网络上的。这意味着可能是某些配置
     方面的问题导致备份无法进行。

  － 您不希望您的电脑被备份，并且不愿再收到这些电子邮件。

如果不是以上这些情况，请确认您的电脑是被连接在网络上的。

此致敬礼，

BackupPC Genie
http://backuppc.sourceforge.net
EOF

# No recent backup
$Lang{EMailNoBackupRecentSubj} = "BackupPC: 客户机 \$host 最近未被备份过";
$Lang{EMailNoBackupRecentMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
尊敬的用户 $userName,

您的电脑 ($host) 已经有 $days 天没有被成功备份过了。您的电脑
第一次被备份是在 $firstTime 天前，直至 $days 天前已经被备份过 $numBackups 次。
正常情况下，当您的电脑与网络连接时电脑备份会自动进行。

在最近 $days 天内，如果您的电脑已经与网络连接了若干小时，
请与系统管理员联系以判断为什么备份没有进行。

除此之外，如果您不在办公室，您只能手动拷贝重要文件到其它存储介质上。
应该提醒您的是，如果您的电脑磁盘损坏，您在最近 $days 天内创建或修改
的文件，包括新收到的电子邮件和附件，将无法被恢复。

此致敬礼，

BackupPC Genie
http://backuppc.sourceforge.net
EOF

# Old Outlook files
$Lang{EMailOutlookBackupSubj} = "BackupPC: 客户机 \$host 上的微软 Outlook 文件需要备份";
$Lang{EMailOutlookBackupMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
尊敬的用户 $userName,

您的电脑上的 Outlook 文件 $howLong。

这些文件包括所有您的电子邮件，附件，通讯录及日程表信息。
您的电脑第一次被备份是在 $firstTime 天前，直至 $lastTime 天前已经被
备份过 $numBackups 次。但是，Outlook 在运行时锁住所有所属文件，
导致这些文件无法被备份。

建议您依以下方式备份 Outlook 文件：

1。首先确认电脑是连接在网路上；
2。退出 Outlook 及所有其它应用；
3。使用网页浏览器访问此链接：

    $CgiURL?host=$host               

选择 “开始增量备份”，启动增量备份操作；然后选择 “返回 $host 主页”
并用浏览器的 “刷新” 功能来检查该备份操作的状态。

此致敬礼，

BackupPC Genie
http://backuppc.sourceforge.net
EOF

$Lang{howLong_not_been_backed_up} = "还从未被成功备份过";
$Lang{howLong_not_been_backed_up_for_days_days} = "已经有 \$days 天未被备份过";

#######################################################################
# RSS strings
#######################################################################
$Lang{RSS_Doc_Title}       = "BackupPC 服务器";
$Lang{RSS_Doc_Description} = "RSS feed for BackupPC";
$Lang{RSS_Host_Summary}    = <<EOF;
完全备份个数：\$fullCnt;
最后一次完全备份 (天前)：\$fullAge;
完全备份大小 (GiB)：\$fullSize;
完全备份速度 (MB/sec)：\$fullRate;
增量备份个数：\$incrCnt;
最后一次增量备份 (天前)：\$incrAge;
当前状态：\$host_state;
最后一次备份结果：\$host_last_attempt;
EOF

#######################################################################
# Configuration editor strings
#######################################################################

$Lang{Only_privileged_users_can_edit_config_files} = "只有特权用户可以编辑服务器配置。";
$Lang{CfgEdit_Edit_Config} = "修改服务器配置";
$Lang{CfgEdit_Edit_Hosts}  = "增删客户机";

$Lang{CfgEdit_Title_Server} = "服务器";
$Lang{CfgEdit_Title_General_Parameters} = "总体参数";
$Lang{CfgEdit_Title_Wakeup_Schedule} = "唤醒调度";
$Lang{CfgEdit_Title_Concurrent_Jobs} = "并行任务";
$Lang{CfgEdit_Title_Pool_Filesystem_Limits} = "备份池文件系统资源限制";
$Lang{CfgEdit_Title_Other_Parameters} = "其它参数";
$Lang{CfgEdit_Title_Remote_Apache_Settings} = "远程 Apache 服务器设置";
$Lang{CfgEdit_Title_Program_Paths} = "程序路径";
$Lang{CfgEdit_Title_Install_Paths} = "安装路径";
$Lang{CfgEdit_Title_Email} = "电子邮件";
$Lang{CfgEdit_Title_Email_settings} = "电子邮件设置";
$Lang{CfgEdit_Title_Email_User_Messages} = "用户邮件内容设置";
$Lang{CfgEdit_Title_CGI} = "CGI";
$Lang{CfgEdit_Title_Admin_Privileges} = "管理特权";
$Lang{CfgEdit_Title_Page_Rendering} = "网页外观";
$Lang{CfgEdit_Title_Paths} = "路径";
$Lang{CfgEdit_Title_User_URLs} = "用户 URLs";
$Lang{CfgEdit_Title_User_Config_Editing} = "用户配置编辑";
$Lang{CfgEdit_Title_Xfer} = "传输";
$Lang{CfgEdit_Title_Xfer_Settings} = "传输设置";
$Lang{CfgEdit_Title_Ftp_Settings} = "FTP 设置";
$Lang{CfgEdit_Title_Smb_Settings} = "Smb 设置";
$Lang{CfgEdit_Title_Tar_Settings} = "Tar 设置";
$Lang{CfgEdit_Title_Rsync_Settings} = "Rsync 设置";
$Lang{CfgEdit_Title_Rsyncd_Settings} = "Rsyncd 设置";
$Lang{CfgEdit_Title_Archive_Settings} = "备档设置";
$Lang{CfgEdit_Title_Include_Exclude} = "包含／排除";
$Lang{CfgEdit_Title_Smb_Paths_Commands} = "Smb 路径／命令";
$Lang{CfgEdit_Title_Tar_Paths_Commands} = "Tar 路径／命令";
$Lang{CfgEdit_Title_Rsync_Paths_Commands_Args} = "Rsync 路径／命令／参数";
$Lang{CfgEdit_Title_Rsyncd_Port_Args} = "Rsyncd 端口／参数";
$Lang{CfgEdit_Title_Archive_Paths_Commands} = "备档路径／命令";
$Lang{CfgEdit_Title_Schedule} = "调度";
$Lang{CfgEdit_Title_Full_Backups} = "完全备份";
$Lang{CfgEdit_Title_Incremental_Backups} = "增量备份";
$Lang{CfgEdit_Title_Blackouts} = "备份暂停期";
$Lang{CfgEdit_Title_Other} = "其它";
$Lang{CfgEdit_Title_Backup_Settings} = "备份设置";
$Lang{CfgEdit_Title_Client_Lookup} = "客户机查找";
$Lang{CfgEdit_Title_User_Commands} = "用户命令";
$Lang{CfgEdit_Title_Hosts} = "客户机";

$Lang{CfgEdit_Hosts_Comment} = <<EOF;
要增加一台新的备份客户机，请点击"添加"，然后在 "host" 列输入其主机名。
关于 "dhcp" 列的选择：只要该客户机的 IP 地址能被 nslookup 或 nmblookup 命令
获得，就不选择此标志位。"user" 列中填入该客户机的一个拥有者或使用者的用户名，
此用户拥有开始／中止／浏览／恢复该客户机备份的权限;同时此用户将被传送电子邮件，
所以此用户名必须是一个合法电子邮件用户名。"moreUsers" 列中可填入该客户机的
其他使用者的用户名，他们也拥有开始／中止／浏览／恢复该客户机备份的权限，
多个用户名间用逗号分隔且不能含空格。与 "user" 列不同的是，"moreUsers" 列
中用户不被传送电子邮件，所以他们不必是合法电子邮件用户名，只要能被 
Apache Web 服务器认证登录即可。 如果想在一台现有客户机的管理配置的基础上
配置一台新机，该新机主机名可在 "host" 列以这种方式输入 "NEWHOST=COPYHOST" ，
这里 NEWHOST 是新机主机名，COPYHOST 是现有客户机主机名。也可以以这种方式
修改一个现有客户机的配置。要删除一台现有备份客户机，请点击其所在行的"删除"。
所有上述修改只有在点击"保存“后才能生效。被删除的备份客户机，其备份数据
并没有被删除。所以如果不慎"删除"一台备份客户机，只需重新"添加"即可。要想
完全删除一台备份客户机的备份数据，你需要手动删除备份服务器目录
 \$topDir/pc/HOST 下的所有文件，这里 HOST 是该客户机主机名。
EOF

$Lang{CfgEdit_Header_Main} = <<EOF;
\${h1("总体配置编辑")}
EOF

$Lang{CfgEdit_Header_Host} = <<EOF;
\${h1("客户机 \$host 配置编辑")}
<p>
注意：适用于所有客户机的全局性默认配置，其相应 “替换” 旁的方框是不被选择的。如果要修改本客户机的某项设置，请点击 “替换” 旁的方框。如果该设置已经处于被修改状态，则修改后不需点击 “替换” 旁的方框。如果要将其还原使用默认配置，则需点击 “替换” 旁的方框，使其处于未被修改状态。
<p>
EOF

$Lang{CfgEdit_Button_Save}     = "保存";
$Lang{CfgEdit_Button_Insert}   = "插入";
$Lang{CfgEdit_Button_Delete}   = "删除";
$Lang{CfgEdit_Button_Add}      = "添加";
$Lang{CfgEdit_Button_Override} = "替换";
$Lang{CfgEdit_Button_New_Key}  = "文件卷名(Windows Share)";

$Lang{CfgEdit_Error_No_Save}
            = "错误：有误，无法保存";
$Lang{CfgEdit_Error__must_be_an_integer}
            = "错误：\$var 必须是整数";
$Lang{CfgEdit_Error__must_be_real_valued_number}
            = "错误：\$var 必须是实数，不能是浮点数";
$Lang{CfgEdit_Error__entry__must_be_an_integer}
            = "错误：\$var 内容 \$k 必须是整数";
$Lang{CfgEdit_Error__entry__must_be_real_valued_number}
            = "错误：\$var 内容 \$k 必须是实数，不能是浮点数";
$Lang{CfgEdit_Error__must_be_executable_program}
            = "错误：\$var 必须是可执行程序";
$Lang{CfgEdit_Error__must_be_valid_option}
            = "错误：\$var 必须是合法选项";
$Lang{CfgEdit_Error_Copy_host_does_not_exist}
            = "客户机 \$copyHost 不存在；生成全计算机名 \$fullHost。如果此客户机不是你想要的，请将它删除。";

$Lang{CfgEdit_Log_Copy_host_config}
            = "用户 \$User 拷贝了客户机 \$fromHost 的配置到客户机 \$host\n";
$Lang{CfgEdit_Log_Delete_param}
            = "用户 \$User 从配置 \$conf 中删除了 \$p\n";
$Lang{CfgEdit_Log_Add_param_value}
            = "用户 \$User 添加了 \$p 到配置 \$conf 中，值设为 \$value\n";
$Lang{CfgEdit_Log_Change_param_value}
            = "用户 \$User 将配置 \$conf 中的 \$p 从 \$valueOld 更改为 \$valueNew\n";
$Lang{CfgEdit_Log_Host_Delete}
            = "用户 \$User 删除了客户机 \$host\n";
$Lang{CfgEdit_Log_Host_Change}
            = "用户 \$User 将客户机 \$host 上的 \$key 从 \$valueOld 更改为 \$valueNew\n";
$Lang{CfgEdit_Log_Host_Add}
            = "用户 \$User 添加了客户机 \$host: \$value\n";
  
#end of lang_zh_CN.pm
