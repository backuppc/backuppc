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

$Lang{Start_Archive} = "アーカイブ開始";
$Lang{Stop_Dequeue_Archive} = "アーカイブ停止/デキュー";
$Lang{Start_Full_Backup} = "フルバックアップ開始";
$Lang{Start_Incr_Backup} = "増分バックアップ開始";
$Lang{Stop_Dequeue_Backup} = "バックアップ停止/デキュー";
$Lang{Restore} = "リストア";

$Lang{Type_full} = "フル";
$Lang{Type_incr} = "インクリメンタル";

# -----

$Lang{Only_privileged_users_can_view_admin_options} = "管理者オプションは権限があるユーザのみ見ることができます。";
$Lang{H_Admin_Options} = "BackupPCサーバ: 管理者オプション";
$Lang{Admin_Options} = "管理者オプション";
$Lang{Admin_Options_Page} = <<EOF;
\${h1(qq{$Lang{Admin_Options}})}
<br>
\${h2("サーバ管理")}
<form name="ReloadForm" action="\$MyURL" method="get">
<input type="hidden" name="action" value="">
<table class="tableStnd">
  <tr><td>サーバ設定の再読込:<td><input type="button" value="再読込"
     onClick="document.ReloadForm.action.value='Reload';
              document.ReloadForm.submit();">
</table>
</form>
<!--
\${h2("サーバの設定")}
<ul>
  <li><i>他の設定はここでできます。例えば、</i>
  <li>サーバ設定の編集
</ul>
-->
EOF

$Lang{Unable_to_connect_to_BackupPC_server} = "BackupPCサーバへ接続できません";
$Lang{Unable_to_connect_to_BackupPC_server_error_message} = <<EOF;
このCGIスクリプト(\$MyURL)は、ホスト \$Conf{ServerHost} のポート \$Conf{ServerPort} で動作しているBackupPCサーバへ接続することができません。
<br>
エラー内容: \$err.<br>
BackupPCが起動していないか、設定エラーがあると思われます。
本件をシステム管理者へ報告してください。
EOF

$Lang{Admin_Start_Server} = <<EOF;
\${h1(qq{$Lang{Unable_to_connect_to_BackupPC_server}})}
<form action="\$MyURL" method="get">
ホスト<tt>\$Conf{ServerHost}</tt> ポート<tt>\$Conf{ServerPort}</tt>
のBackupPCサーバは起動していません(ちょうど停止しているか、まだ起動していないと思われます)。<br>
開始しますか？
<input type="hidden" name="action" value="startServer">
<input type="submit" value="サーバ開始" name="ignore">
</form>
EOF

# -----

$Lang{H_BackupPC_Server_Status} = "BackupPCサーバの状態";

$Lang{BackupPC_Server_Status_General_Info}= <<EOF;
\${h2(\"一般サーバ情報\")}

<ul>
<li> サーバのPIDは \$Info{pid} です。 \$Conf{ServerHost} ホスト上で動作しています。
     バージョンは \$Info{Version}、 \$serverStartTime に開始しています。
<li> このサーバ状態は \$now 現在のものです。
<li> 最後に設定が読み込まれたのは \$configLoadTime です。
<li> 次のキューイングは \$nextWakeupTime の予定です。
<li> 他の情報:
    <ul>
        <li>最後にスケジュールされた起動から保留中のバックアップ要求: \$numBgQueue
        <li>保留中のユーザバックアップ要求: \$numUserQueue
        <li>保留中のコマンド要求: \$numCmdQueue
        \$poolInfo
        <li>プールファイルシステムは \$Info{DUlastValue}%
            (\$DUlastTime 現在)、今日の最大値は \$Info{DUDailyMax}% (\$DUmaxTime)、
            昨日の最大値は \$Info{DUDailyMaxPrev}%。
    </ul>
</ul>
EOF

$Lang{BackupPC_Server_Status} = <<EOF;
\${h1(qq{$Lang{H_BackupPC_Server_Status}})}

<p>
\${h2("現在実行中のジョブ")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td> ホスト </td>
    <td> 種別 </td>
    <td> ユーザ </td>
    <td> 開始時間 </td>
    <td> コマンド </td>
    <td align="center"> PID </td>
    <td align="center"> 転送 PID </td>
    <td align="center"> Status </td>
    <td align="center"> Count </td>
    </tr>
\$jobStr
</table>

<p>
\$generalInfo

\${h2("注意する必要がある失敗")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> ホスト </td>
    <td align="center"> 種別 </td>
    <td align="center"> ユーザ </td>
    <td align="center"> 最終試行 </td>
    <td align="center"> 詳細 </td>
    <td align="center"> エラー時刻 </td>
    <td> 最終エラー (無応答以外) </td></tr>
\$statusStr
</table>
EOF

# --------------------------------
$Lang{BackupPC__Server_Summary} = "BackupPC: ホストサマリ";
$Lang{BackupPC__Archive} = "BackupPC: アーカイブ";
$Lang{BackupPC_Summary} = <<EOF;

\${h1(qq{$Lang{BackupPC__Server_Summary}})}
<p>
<ul>
<li>この表示内容は \$now に更新されたものです。
<li>プールファイルシステムは \$Info{DUlastValue}%
    (\$DUlastTime 現在)、今日の最大値は \$Info{DUDailyMax}% (\$DUmaxTime)、
        昨日の最大値は \$Info{DUDailyMaxPrev}%。
</ul>
</p>

\${h2("バックアップが存在するホスト")}
<p>
\$hostCntGood 個のホストのバックアップが存在します。
<ul>
<li> \$fullTot 個のフルバックアップの合計サイズ \${fullSizeTot}GiB
     (以前のプーリングと圧縮)
<li> \$incrTot 個の増分バックアップの合計サイズ \${incrSizeTot}GiB
     (以前のプーリングと圧縮)
</ul>
</p>
<table class="sortable" id="host_summary_backups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> ホスト </td>
    <td align="center"> ユーザ </td>
    <td align="center"> フル </td>
    <td align="center"> フル世代 (日数) </td>
    <td align="center"> フルサイズ (GiB) </td>
    <td align="center"> 速度(MB/s) </td>
    <td align="center"> 増分 </td>
    <td align="center"> 増分経過 (日数) </td>
    <td align="center"> 最終バックアップ (日数) </td>
    <td align="center"> 状態 </td>
    <td align="center"> #転送エラー </td>
    <td align="center"> 最終試行 </td></tr>
\$strGood
</table>
<br><br>
\${h2("バックアップが存在しないホスト")}
<p>
\$hostCntNone 個のホストのバックアップが存在しません。
<p>
<table class="sortable" id="host_summary_nobackups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> ホスト </td>
    <td align="center"> ユーザ </td>
    <td align="center"> #フル </td>
    <td align="center"> フル世代(日) </td>
    <td align="center"> フルサイズ(GiB) </td>
    <td align="center"> 速度(MB/s) </td>
    <td align="center"> #増分</td>
    <td align="center"> 増分(日) </td>
    <td align="center"> 最終バックアップ(日)</td>
    <td align="center"> 状態 </td>
    <td align="center"> #転送エラー</td>
    <td align="center"> 最終試行 </td></tr>
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
\$hostCntGood ホストのバックアップ済の合計サイズ \${fullSizeTot}GiB
<p>
<form name="form1" method="post" action="\$MyURL">
<input type="hidden" name="fcbMax" value="\$checkBoxCnt">
<input type="hidden" name="type" value="1">
<input type="hidden" name="host" value="\${EscHTML(\$archHost)}">
<input type="hidden" name="action" value="Archive">
<table class="tableStnd" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td align=center> ホスト </td>
    <td align="center"> ユーザ </td>
    <td align="center"> バックアップサイズ </td>
\$strGood
\$checkAllHosts
</table>
</form>
<p>

EOF

$Lang{BackupPC_Archive2} = <<EOF;
\${h1(qq{$Lang{BackupPC__Archive}})}
次のホストのアーカイブについて
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
    <td colspan=2><input type="submit" value="アーカイブ開始" name="ignore"></td>
</tr>
</form>
</table>
EOF

$Lang{BackupPC_Archive2_location} = <<EOF;
<tr>
    <td>Archive Location/Device</td>
    <td><input type="text" value="\$ArchiveDest" name="archive_device"></td>
</tr>
EOF

$Lang{BackupPC_Archive2_compression} = <<EOF;
<tr>
    <td>圧縮</td>
    <td>
    <input type="radio" value="0" name="compression" \$ArchiveCompNone>なし<br>
    <input type="radio" value="1" name="compression" \$ArchiveCompGzip>gzip<br>
    <input type="radio" value="2" name="compression" \$ArchiveCompBzip2>bzip2
    </td>
</tr>
EOF

$Lang{BackupPC_Archive2_parity} = <<EOF;
<tr>
    <td>パリティデータの割合 (0 = 無効, 5 = 一般)</td>
    <td><input type="numeric" value="\$ArchivePar" name="par"></td>
</tr>
EOF

$Lang{BackupPC_Archive2_split} = <<EOF;
<tr>
    <td>出力を次へ分離</td>
    <td><input type="numeric" value="\$ArchiveSplit" name="splitsize">Mバイト</td>
</tr>
EOF

# -----------------------------------
$Lang{Pool_Stat} = <<EOF;
        <li>プールは \$info->{"\${name}FileCnt"}ファイルと
            \$info->{"\${name}DirCnt"}ディレクトリ(\$poolTime 時点)を含む、\${poolSize}GiBのサイズがあります。
        <li>プールのハッシングは最長 \$info->{"\${name}FileRepMax"} の \$info->{"\${name}FileCntRep"} の繰り返すファイルを提供します。
        <li>\$poolTime の夜間のクリーンアップによって合計\${poolRmSize}GiBの \$info->{"\${name}FileCntRm"} 個のファイルが
            削除されました。
EOF

# --------------------------------
$Lang{BackupPC__Backup_Requested_on__host} = "BackupPC: \$host のバックアップ要求";
# --------------------------------
$Lang{REPLY_FROM_SERVER} = <<EOF;
\${h1(\$str)}
<p>
サーバからの返信: \$reply
<p>
<a href="\$MyURL?host=\$host">\$host ホームページへ戻る</a>.
EOF
# --------------------------------
$Lang{BackupPC__Start_Backup_Confirm_on__host} = "BackupPC: バックアップ開始の確認 \$host";
# --------------------------------
$Lang{Are_you_sure_start} = <<EOF;
\${h1("本当によいですか？")}
<p>
\$host の \$type バックアップを開始します。

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="hostIP" value="\$ipAddr">
<input type="hidden" name="doit" value="1">
<input type="hidden" name="action" value="">
本当に実行してよいですか？
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="いいえ" name="ignore">
</form>
EOF
# --------------------------------
$Lang{BackupPC__Stop_Backup_Confirm_on__host} = "BackupPC: バックアップ停止の確認 \$host";
# --------------------------------
$Lang{Are_you_sure_stop} = <<EOF;

\${h1("本当によいですか？")}

<p>
\$host バックアップの中止/デキューをします。

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host"   value="\$host">
<input type="hidden" name="doit"   value="1">
<input type="hidden" name="action" value="">
なお、<input type="text" name="backoff" size="10" value="\$backoff"> 時間、他のバックアップを開始しないでください。
<p>
本当に実行してよいですか？
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="いいえ" name="ignore">
</form>

EOF
# --------------------------------
$Lang{Only_privileged_users_can_view_queues_} = "権限があるユーザのみキューを見ることができます。";
# --------------------------------
$Lang{Only_privileged_users_can_archive} = "権限があるユーザのみアーカイブすることができます。";
# --------------------------------
$Lang{BackupPC__Queue_Summary} = "BackupPC: キューサマリ";
# --------------------------------
$Lang{Backup_Queue_Summary} = <<EOF;
\${h1("バックアップキューサマリ")}
<br><br>
\${h2("ユーザキューサマリ")}
<p>
現在キューイングされているユーザ要求は次のとおりです。
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> ホスト </td>
    <td> 要求時間 </td>
    <td> ユーザ </td></tr>
\$strUser
</table>
<br><br>

\${h2("バックグラウンドキューサマリ")}
<p>
現在キューイングされているバックグラウンド要求は次のとおりです。</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> ホスト </td>
    <td> 要求時間 </td>
    <td> ユーザ </td></tr>
\$strBg
</table>
<br><br>
\${h2("コマンドキューサマリ")}
<p>
現在キューイングされているコマンド要求は次のとおりです。
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> ホスト </td>
    <td> 要求時間 </td>
    <td> ユーザ </td>
    <td> コマンド </td></tr>
\$strCmd
</table>
EOF

# --------------------------------
$Lang{Backup_PC__Log_File__file} = "BackupPC: ファイル \$file";
$Lang{Log_File__file__comment} = <<EOF;
\${h1("ファイル \$file \$comment")}
<p>
EOF
# --------------------------------
$Lang{Contents_of_log_file} = <<EOF;
ファイル<tt>\$file</tt>の内容 \$mtimeStr 更新 \$comment
EOF

# --------------------------------
$Lang{skipped__skipped_lines} = "[ \$skipped 行スキップしました。 ]\n";
# --------------------------------
$Lang{_pre___Can_t_open_log_file__file} = "<pre>\n\$file ログファイルを開くことができません。\n";

# --------------------------------
$Lang{BackupPC__Log_File_History} = "BackupPC: ログファイルの履歴";
$Lang{Log_File_History__hdr} = <<EOF;
\${h1("ログファイル履歴 \$hdr")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> ファイル </td>
    <td align="center"> サイズ </td>
    <td align="center"> 更新時間 </td></tr>
\$str
</table>
EOF

# -------------------------------
$Lang{Recent_Email_Summary} = <<EOF;
\${h1("最近のメールサマリ(日時降順)")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> 受信者 </td>
    <td align="center"> ホスト </td>
    <td align="center"> 日時 </td>
    <td align="center"> 件名 </td></tr>
\$str
</table>
EOF
 

# ------------------------------
$Lang{Browse_backup__num_for__host} = "BackupPC: \$host \$num バックアップの閲覧";

# ------------------------------
$Lang{Restore_Options_for__host} = "BackupPC: \$host リストアオプション";
$Lang{Restore_Options_for__host2} = <<EOF;
\${h1("\$host のリストアオプション")}
<p>
共有 \$share から次のファイル/ディレクトリを選択しています。バックアップ番号 #\$num:
<ul>
\$fileListStr
</ul>
</p><p>
これらファイル/ディレクトリのリストア方法を３つの中から選ぶことができます。
次の中から選択してください。
</p>
\${h2("オプション１: ダイレクトリストア")}
<p>
EOF

$Lang{Restore_Options_for__host_Option1} = <<EOF;
<b>\$directHost</b>へ直接これらのファイルをリストアします。
</p><p>
<b>警告:</b> 既存のファイルは選択したこれらのファイルで上書きされます。
</p>
<form action="\$MyURL" method="post" name="direct">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="3">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<table class="tableStnd" border="0">
<tr>
    <td>ホストへファイルをリストア</td>
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
	 <!--<a href="javascript:myOpen('\$MyURL?action=findShares&host='+document.direct.hostDest.options.value)">利用できる共有の検索(未実装)</a>--></td>
</tr><tr>
    <td>共有へファイルをリストア</td>
    <td><input type="text" size="40" value="\${EscHTML(\$share)}"
	 name="shareDest"></td>
</tr><tr>
    <td>次のディレクトリへファイルをリストア<br>(共有への相対)</td>
    <td valign="top"><input type="text" size="40" maxlength="256"
	value="\${EscHTML(\$pathHdr)}" name="pathHdr"></td>
</tr><tr>
    <td><input type="submit" value="リストア開始" name="ignore"></td>
</table>
</form>
EOF

$Lang{Restore_Options_for__host_Option1_disabled} = <<EOF;
Direct restore has been disabled for host \${EscHTML(\$hostDest)}.
他のリストアオプションから１つ選択してください。
EOF

# ------------------------------
$Lang{Option_2__Download_Zip_archive} = <<EOF;
<p>
\${h2("オプション２: Zipアーカイブのダウンロード")}
<p>
選択したファイル/ディレクトリをすべて含んだZIPアーカイブをダウンロードします。
WinZipのようなローカルアプリケーションで閲覧したり展開することができます。
</p><p>
<b>警告:</b> depending upon which files/directories you have selected,
this archive might be very very large.  It might take many minutes to
create and transfer the archive, and you will need enough local disk
space to store it.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="2">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Make archive relative
to \${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(otherwise archive will contain full paths).
<br>
<table class="tableStnd" border="0">
<tr>
    <td>圧縮 (0=なし, 1=高速,...,9=最高)</td>
    <td><input type="text" size="6" value="5" name="compressLevel"></td>
</tr><tr>
    <td>Code page (e.g. cp866)</td>
    <td><input type="text" size="6" value="utf8" name="codePage"></td>
</tr>
</table>
<br>
<input type="submit" value="ZIPファイルのダウンロード" name="ignore">
</form>
EOF

# ------------------------------

$Lang{Option_2__Download_Zip_archive2} = <<EOF;
<p>
\${h2("オプション２: ZIPアーカイブのダウンロード")}
<p>
Archive::Zip はインストールされていないのでZIPアーカイブをダウンロードすることができません。
<a href="http://www.cpan.org">www.cpan.org</a>からArchive::Zipをインストールすることについて、システム管理者にお問い合わせください。
</p>
EOF


# ------------------------------
$Lang{Option_3__Download_Zip_archive} = <<EOF;
\${h2("オプション３: Tarアーカイブのダウンロード")}
<p>
You can download a Tar archive containing all the files/directories you
have selected.  You can then use a local application, such as tar or
WinZip to view or extract any of the files.
</p><p>
<b>Warning:</b> depending upon which files/directories you have selected,
this archive might be very very large.  It might take many minutes to
create and transfer the archive, and you will need enough local disk
space to store it.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="1">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Make archive relative
to \${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(otherwise archive will contain full paths).
<br>
<input type="submit" value="Download Tar File" name="ignore">
</form>
EOF


# ------------------------------
$Lang{Restore_Confirm_on__host} = "BackupPC: \$host リストアの確認";

$Lang{Are_you_sure} = <<EOF;
\${h1("よいですか？")}
<p>
You are about to start a restore directly to the machine \$In{hostDest}.
The following files will be restored to share \$In{shareDest}, from
バックアップ番号 \$num:
<p>
<table class="tableStnd" border>
<tr class="tableheader"><td>元のファイル/ディレクトリ</td><td>次の場所にリストアされます。</td></tr>
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
本当に実行してよいですか？
<input type="button" value="\$Lang->{Restore}"
 onClick="document.RestoreForm.action.value='Restore';
          document.RestoreForm.submit();">
<input type="submit" value="No" name="ignore">
</form>
EOF


# --------------------------
$Lang{Restore_Requested_on__hostDest} = "BackupPC: \$hostDest へリストア";
$Lang{Reply_from_server_was___reply} = <<EOF;
\${h1(\$str)}
<p>
サーバからの応答: \$reply
<p>
<a href="\$MyURL?host=\$hostDest">\$hostDest ホームページ</a>に戻る
EOF

$Lang{BackupPC_Archive_Reply_from_server} = <<EOF;
\${h1(\$str)}
<p>
サーバからの応答: \$reply
EOF


# -------------------------
$Lang{Host__host_Backup_Summary} = "BackupPC: ホスト \$host バックアップサマリ";

$Lang{Host__host_Backup_Summary2} = <<EOF;
\${h1("ホスト \$host バックアップサマリ")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>
</p>
\${h2("ユーザの操作")}
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
\${h2("バックアップサマリ")}
<p>
閲覧・バックアップファイルのリストアを行いたいバックアップ番号をクリックしてください。
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> バックアップ番号 </td>
    <td align="center"> 種別 </td>
    <td align="center"> フィルド </td>
    <td align="center"> レベル </td>
    <td align="center"> 開始日時 </td>
    <td align="center"> 間隔(分) </td>
    <td align="center"> 経過(日) </td>
    <td align="center"> サーババックアップパス </td>
</tr>
\$str
</table>
<p>

\$restoreStr
</p>
<br><br>
\${h2("転送エラーサマリ")}
<br><br>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> バックアップ番号 </td>
    <td align="center"> 種別 </td>
    <td align="center"> ビュー </td>
    <td align="center"> #転送エラー </td>
    <td align="center"> #badファイル </td>
    <td align="center"> #bad共有 </td>
    <td align="center"> #tarエラー </td>
</tr>
\$errStr
</table>
<br><br>

\${h2("ファイルサイズ/カウント 再利用サマリ")}
<p>
存在するファイルはプール内にすでにあります。次の新しいファイルはプールへ追加されます。
空ファイルとSMBエラーは再利用にはカウントされません。
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="2" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> トータル </td>
    <td align="center" colspan="2"> 既存ファイル </td>
    <td align="center" colspan="2"> 新ファイル </td>
</tr>
<tr class="tableheader">
    <td align="center"> バックアップ番号 </td>
    <td align="center"> 種別 </td>
    <td align="center"> #ファイル </td>
    <td align="center"> サイズ(MB) </td>
    <td align="center"> 速度(MB/sec) </td>
    <td align="center"> #ファイル </td>
    <td align="center"> サイズ(MB) </td>
    <td align="center"> #ファイル </td>
    <td align="center"> サイズ(MB) </td>
</tr>
\$sizeStr
</table>
<br><br>

\${h2("圧縮サマリ")}
<p>
すでにプールに入っているものと新しく圧縮されたファイルの圧縮パフォーマンス
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="3" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> 既存ファイル </td>
    <td align="center" colspan="3"> 新ファイル </td>
</tr>
<tr class="tableheader"><td align="center"> バックアップ番号 </td>
    <td align="center"> 種別 </td>
    <td align="center"> 圧縮レベル </td>
    <td align="center"> サイズ(MB) </td>
    <td align="center"> 圧縮(MB) </td>
    <td align="center"> 圧縮 </td>
    <td align="center"> サイズ(MB) </td>
    <td align="center"> 圧縮(MB) </td>
    <td align="center"> 圧縮 </td>
</tr>
\$compStr
</table>
<br><br>
EOF

$Lang{Host__host_Archive_Summary} = "BackupPC: ホスト \$host アーカイブサマリ";
$Lang{Host__host_Archive_Summary2} = <<EOF;
\${h1("ホスト \$host アーカイブサマリ")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>

\${h2("ユーザ操作")}
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
$Lang{Error} = "BackupPC: エラー";
$Lang{Error____head} = <<EOF;
\${h1("エラー: \$head")}
<p>\$mesg</p>
EOF

# -------------------------
$Lang{NavSectionTitle_} = "サーバ";

# -------------------------
$Lang{Backup_browse_for__host} = <<EOF;
\${h1("\$host のバックアップ閲覧")}

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
<li>\$backupTime に開始したバックアップ #\$num (\$backupAge 日前) を閲覧しています。
\$filledBackup
<li> ディレクトリを入力してください: <input type="text" name="dir" size="50" maxlength="4096" value="\${EscHTML(\$dir)}"> <input type="submit" value="\$Lang->{Go}" name="Submit">
<li> 移動したいディレクトリを左下から選択してください
<li> リストアするファイルを右下から選択してください
<li> 現在のディレクトリのバックアップ<a href="\$MyURL?action=dirHistory&host=\${EscURI(\$host)}&share=\$shareURI&dir=\$pathURI">履歴</a>を見ることができます。
</ul>
</form>

\${h2("\$dirDisplay の内容")}
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
<input type="submit" name="Submit" value="選択されたファイルをリストア">
-->
</form>
EOF

# ------------------------------
$Lang{DirHistory_backup_for__host} = "BackupPC: \$host のバックアップ履歴ディレクトリ";

#
# These two strings are used to build the links for directories and
# file versions.  Files are appended with a version number.
#
$Lang{DirHistory_dirLink}  = "dir";
$Lang{DirHistory_fileLink} = "v";

$Lang{DirHistory_for__host} = <<EOF;
\${h1("\$host のディレクトリバックアップ履歴")}
<p>
全バックアップをまたいでファイルのそれぞれのバージョンを表示します。
<ul>
<li> バックアップ番号をクリックすることでバックアップ閲覧画面に戻ります。
<li> ディレクトリリンク(\$Lang->{DirHistory_dirLink})をクリックすることで、
     そのディレクトリ内に移動できます。
<li> ファイルのバージョンリンク(\$Lang->{DirHistory_fileLink}0,
     \$Lang->{DirHistory_fileLink}1, ...)をクリックすることで、そのファイルをダウンロードできます。
<li> 異なるバックアップ間の同じ内容のファイルは同じバージョン番号になります。
<li> そのバックアップに存在しないファイルやディレクトリについては空欄になります。
<li> 同じバージョンのファイルでも異なる属性を持っている場合があります。
     ファイルの属性はバックアップ番号を選択すると見ることができます。
</ul>

\${h2("\$dirDisplay の履歴")}

<br>
<table border cellspacing="2" cellpadding="3">
<tr class="fviewheader"><td>バックアップ番号</td>\$backupNumStr</tr>
<tr class="fviewheader"><td>バックアップ日時</td>\$backupTimeStr</tr>
\$fileStr
</table>
EOF

# ------------------------------
$Lang{Restore___num_details_for__host} = "BackupPC: リストア #\$num 詳細 \$host";

$Lang{Restore___num_details_for__host2} = <<EOF;
\${h1("リストア #\$num 詳細 \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="90%">
<tr><td class="tableheader"> 番号 </td><td class="border"> \$Restores[\$i]{num} </td></tr>
<tr><td class="tableheader"> 要求元 </td><td class="border"> \$RestoreReq{user} </td></tr>
<tr><td class="tableheader"> 要求時間 </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> 結果 </td><td class="border"> \$Restores[\$i]{result} </td></tr>
<tr><td class="tableheader"> エラーメッセージ </td><td class="border"> \$Restores[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> 元ホスト </td><td class="border"> \$RestoreReq{hostSrc} </td></tr>
<tr><td class="tableheader"> 元バックアップ番号 </td><td class="border"> \$RestoreReq{num} </td></tr>
<tr><td class="tableheader"> 元共有 </td><td class="border"> \$RestoreReq{shareSrc} </td></tr>
<tr><td class="tableheader"> リストア先 </td><td class="border"> \$RestoreReq{hostDest} </td></tr>
<tr><td class="tableheader"> 共有先 </td><td class="border"> \$RestoreReq{shareDest} </td></tr>
<tr><td class="tableheader"> 開始日時 </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> 間隔 </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> ファイル数 </td><td class="border"> \$Restores[\$i]{nFiles} </td></tr>
<tr><td class="tableheader"> 合計サイズ </td><td class="border"> \${MB} MB </td></tr>
<tr><td class="tableheader"> 転送率 </td><td class="border"> \$MBperSec MB/sec </td></tr>
<tr><td class="tableheader"> Tar作成エラー </td><td class="border"> \$Restores[\$i]{tarCreateErrs} </td></tr>
<tr><td class="tableheader"> 転送エラー </td><td class="border"> \$Restores[\$i]{xferErrs} </td></tr>
<tr><td class="tableheader"> 転送ログファイル </td><td class="border">
<a href="\$MyURL?action=view&type=RestoreLOG&num=\$Restores[\$i]{num}&host=\$host">ビュー</a>,
<a href="\$MyURL?action=view&type=RestoreErr&num=\$Restores[\$i]{num}&host=\$host">エラー</a>
</tr></tr>
</table>
</p>
\${h1("ファイル/ディレクトリ一覧")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="100%">
<tr class="tableheader"><td>元のディレクトリ/ファイル</td><td>リストア</td></tr>
\$fileListStr
</table>
EOF

# ------------------------------
$Lang{Archive___num_details_for__host} = "BackupPC: アーカイブ #\$num 詳細 \$host";

$Lang{Archive___num_details_for__host2 } = <<EOF;
\${h1("アーカイブ #\$num 詳細 \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr><td class="tableheader"> 番号 </td><td class="border"> \$Archives[\$i]{num} </td></tr>
<tr><td class="tableheader"> 要求元 </td><td class="border"> \$ArchiveReq{user} </td></tr>
<tr><td class="tableheader"> 要求時間 </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> 結果 </td><td class="border"> \$Archives[\$i]{result} </td></tr>
<tr><td class="tableheader"> エラーメッセージ </td><td class="border"> \$Archives[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> 開始日時 </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> 間隔 </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> 転送ログファイル </td><td class="border">
<a href="\$MyURL?action=view&type=ArchiveLOG&num=\$Archives[\$i]{num}&host=\$host">ビュー</a>,
<a href="\$MyURL?action=view&type=ArchiveErr&num=\$Archives[\$i]{num}&host=\$host">エラー</a>
</tr></tr>
</table>
<p>
\${h1("ホスト一覧")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td>ホスト</td><td>バックアップ番号</td></tr>
\$HostListStr
</table>
EOF

# -----------------------------------
$Lang{Email_Summary} = "BackupPC: メールサマリ";

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
$Lang{Invalid_number__num} = "番号 \${EscHTML(\$In{num})} が不正です。";
$Lang{Unable_to_open__file__configuration_problem} = "Unable to open \$file: configuration problem?";
$Lang{Only_privileged_users_can_view_log_or_config_files} = "Only privileged users can view log or config files.";
$Lang{Only_privileged_users_can_view_log_files} = "Only privileged users can view log files.";
$Lang{Only_privileged_users_can_view_email_summaries} = "Only privileged users can view email summaries.";
$Lang{Only_privileged_users_can_browse_backup_files} = "Only privileged users can browse backup files"
                . " ホスト \${EscHTML(\$In{host})}.";
$Lang{Empty_host_name} = "ホスト名が空です。";
$Lang{Directory___EscHTML} = "ディレクトリ \${EscHTML(\"\$TopDir/pc/\$host/\$num\")}"
		    . " は空です。";
$Lang{Can_t_browse_bad_directory_name2} = "Can\'t browse bad directory name"
	            . " \${EscHTML(\$relDir)}";
$Lang{Only_privileged_users_can_restore_backup_files} = "Only privileged users can restore backup files"
                . " for host \${EscHTML(\$In{host})}.";
$Lang{Bad_host_name} = "\${EscHTML(\$host)} はホスト名が誤っています。";
$Lang{You_haven_t_selected_any_files__please_go_Back_to} = "何もファイルを選択していません。戻って"
                . "いくつかファイルを選択してください。";
$Lang{You_haven_t_selected_any_hosts} = "何もホストを選択していません。戻って"
                . "いくつかのホストを選択してください。";
$Lang{Nice_try__but_you_can_t_put} = "Nice try, but you can\'t put \'..\' in any of the file names";
$Lang{Host__doesn_t_exist} = "Host \${EscHTML(\$In{hostDest})} doesn\'t exist";
$Lang{You_don_t_have_permission_to_restore_onto_host} = "You don\'t have permission to restore onto host"
		    . " \${EscHTML(\$In{hostDest})}";
$Lang{Can_t_open_create__openPath} = "Can\'t open/create "
		. "\${EscHTML(\"\$openPath\")}";
$Lang{Only_privileged_users_can_restore_backup_files2} = "Only privileged users can restore backup files"
                . " for host \${EscHTML(\$host)}.";
$Lang{Empty_host_name} = "ホスト名が空です。";
$Lang{Unknown_host_or_user} = "Unknown host or user \${EscHTML(\$host)}";
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

$Lang{Backup_requested_on_DHCP__host} = "バックアップ要求 on DHCP \$host (\$In{hostIP}) by"
		                      . " \$User from \$ENV{REMOTE_ADDR}";
$Lang{Backup_requested_on__host_by__User} = "\$User による \$host のバックアップ要求";
$Lang{Backup_stopped_dequeued_on__host_by__User} = "\$User による \$host のバックアップ中止/デキュー";
$Lang{Restore_requested_to_host__hostDest__backup___num} = "ホスト\$hostDest のリストア要求 バックアップ #\$num,"
	     . " by \$User from \$ENV{REMOTE_ADDR}";
$Lang{Archive_requested} = "\$ENV{REMOTE_ADDR} から \$User によってアーカイブの要求がありました。";

# -------------------------------------------------
# ------- Stuff that was forgotten ----------------
# -------------------------------------------------

$Lang{Status} = "状態";
$Lang{PC_Summary} = "ホストサマリ";
$Lang{LOG_file} = "ログファイル";
$Lang{LOG_files} = "全ログファイル";
$Lang{Old_LOGs} = "旧ログ";
$Lang{Email_summary} = "メールサマリ";
$Lang{Config_file} = "設定ファイル";
# $Lang{Hosts_file} = "ホストファイル";
$Lang{Current_queues} = "現在のキュー";
$Lang{Documentation} = "文章";

#$Lang{Host_or_User_name} = "<small>ホストまたはユーザ名:</small>";
$Lang{Go} = "実行";
$Lang{Hosts} = "ホスト";
$Lang{Select_a_host} = "ホストを選択";

$Lang{There_have_been_no_archives} = "<h2> アーカイブはありません </h2>\n";
$Lang{This_PC_has_never_been_backed_up} = "<h2> このPCはまだバックアップされたことがありません!! </h2>\n";
$Lang{This_PC_is_used_by} = "<li>このPCは \${UserLink(\$user)} によって使用されています";

$Lang{Extracting_only_Errors} = "(エラーだけ抽出)";
$Lang{XferLOG} = "転送ログ";
$Lang{Errors}  = "エラー";

# ------------
$Lang{Last_email_sent_to__was_at___subject} = <<EOF;
<li>最後のメールは \$mailTime に件名"\$subj"で\${UserLink(\$user)}宛に送りました。
EOF
# ------------
$Lang{The_command_cmd_is_currently_running_for_started} = <<EOF;
<li>\$startTime に開始されたコマンド \$cmd は現在 \$host では実行されていません。
EOF

# -----------
$Lang{Host_host_is_queued_on_the_background_queue_will_be_backed_up_soon} = <<EOF;
<li>ホスト \$host はバックグラウンドキューにキューイングされました(もう少しでバックアップされます)。
EOF

# ----------
$Lang{Host_host_is_queued_on_the_user_queue__will_be_backed_up_soon} = <<EOF;
<li>ホスト \$host はユーザキューにキューイングされました(もう少しでバックアップされます)。
EOF

# ---------
$Lang{A_command_for_host_is_on_the_command_queue_will_run_soon} = <<EOF;
<li>\$host へのコマンドはキューイングされました(もう少しで実行されます)。
EOF

# --------
$Lang{Last_status_is_state_StatusHost_state_reason_as_of_startTime} = <<EOF;
<li>最終状態 \"\$Lang->{\$StatusHost{state}}\"\$reason \$startTime.
EOF

# --------
$Lang{Last_error_is____EscHTML_StatusHost_error} = <<EOF;
<li>最終エラー \"\${EscHTML(\$StatusHost{error})}\".
EOF

# ------
$Lang{Pings_to_host_have_failed_StatusHost_deadCnt__consecutive_times} = <<EOF;
<li>\$StatusHost{deadCnt}回連続で \$host は無応答です。
EOF

# -----
$Lang{Prior_to_that__pings} = "pingの以前は";

# -----
$Lang{priorStr_to_host_have_succeeded_StatusHostaliveCnt_consecutive_times} = <<EOF;
<li>\$host への\$priorStr は \$StatusHost{aliveCnt}回連続で成功しています。
EOF

$Lang{Because__host_has_been_on_the_network_at_least__Conf_BlackoutGoodCnt_consecutive_times___} = <<EOF;
<li>\$host は少なくとも \$Conf{BlackoutGoodCnt} 回連続して、
\$blackoutStr からバックアップされていません。
EOF

$Lang{__time0_to__time1_on__days} = "\$days の \$t0 〜 \$t1";

$Lang{Backups_are_deferred_for_hours_hours_change_this_number} = <<EOF;
<li>Backups are deferred for \$hours hours
(<a href=\"\$MyURL?action=Stop_Dequeue_Backup&host=\$host\">change this number</a>).
EOF

$Lang{tryIP} = " と \$StatusHost{dhcpHostIP}";

# $Lang{Host_Inhost} = "ホスト \$In{host}";

$Lang{checkAll} = <<EOF;
<tr><td class="fviewborder">
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;全選択
</td><td colspan="5" align="center" class="fviewborder">
<input type="submit" name="Submit" value="選択したファイルのリストア">
</td></tr>
EOF

$Lang{checkAllHosts} = <<EOF;
<tr><td class="fviewborder">
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;全選択
</td><td colspan="2" align="center" class="fviewborder">
<input type="submit" name="Submit" value="選択したホストのアーカイブ">
</td></tr>
EOF

$Lang{fileHeader} = <<EOF;
    <tr class="fviewheader"><td align=center> 名前</td>
       <td align="center"> 種別</td>
       <td align="center"> モード</td>
       <td align="center"> #</td>
       <td align="center"> サイズ</td>
       <td align="center"> 更新日時</td>
    </tr>
EOF

$Lang{Home} = "ホーム";
$Lang{Browse} = "バックアップの閲覧";
$Lang{Last_bad_XferLOG} = "最終失敗転送ログ";
$Lang{Last_bad_XferLOG_errors_only} = "最終失敗転送ログ(エラーのみ)";

$Lang{This_display_is_merged_with_backup} = <<EOF;
<li>この表示はバックアップ #\$numF とマージされています。
EOF

$Lang{Visit_this_directory_in_backup} = <<EOF;
<li> 閲覧したいバックアップを選択してください: <select onChange="window.location=this.value">\$otherDirs </select>
EOF

$Lang{Restore_Summary} = <<EOF;
\${h2("リストアサマリ")}
<p>
詳細を閲覧したいリストア番号をクリックしてください。
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> リストア番号 </td>
    <td align="center"> 結果 </td>
    <td align="right"> 開始日時</td>
    <td align="right"> 間隔(分)</td>
    <td align="right"> ファイル数</td>
    <td align="right"> サイズ(MB) </td>
    <td align="right"> #tarエラー</td>
    <td align="right"> #転送エラー</td>
</tr>
\$restoreStr
</table>
<p>
EOF

$Lang{Archive_Summary} = <<EOF;
\${h2("アーカイブサマリ")}
<p>
アーカイブ番号をクリックすると詳細が確認できます。
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> アーカイブ番号 </td>
    <td align="center"> 結果 </td>
    <td align="right"> 開始日時</td>
    <td align="right"> 間隔(分)</td>
</tr>
\$ArchiveStr
</table>
<p>
EOF

$Lang{BackupPC__Documentation} = "BackupPC: 文章";

$Lang{No} = "いいえ";
$Lang{Yes} = "はい";

$Lang{The_directory_is_empty} = <<EOF;
<tr><td bgcolor="#ffffff">\$dirDisplay ディレクトリは空です。
</td></tr>
EOF

#$Lang{on} = "オン";
$Lang{off} = "オフ";

$Lang{backupType_full}    = "フル";
$Lang{backupType_incr}    = "増分";
$Lang{backupType_active}  = "active";
$Lang{backupType_partial} = "部分";

$Lang{failed} = "失敗";
$Lang{success} = "成功";
$Lang{and} = "と";

# ------
# Hosts states and reasons
$Lang{Status_idle} = "待機";
$Lang{Status_backup_starting} = "バックアップ開始";
$Lang{Status_backup_in_progress} = "バックアップ中";
$Lang{Status_restore_starting} = "リストア開始";
$Lang{Status_restore_in_progress} = "リストア中";
$Lang{Status_admin_pending} = "リンク保留中";
$Lang{Status_admin_running} = "リンク実行中";

$Lang{Reason_backup_done}    = "完了";
$Lang{Reason_restore_done}   = "リストア完了";
$Lang{Reason_archive_done}   = "アーカイブ完了";
$Lang{Reason_nothing_to_do}  = "待機";
$Lang{Reason_backup_failed}  = "バックアップ失敗";
$Lang{Reason_restore_failed} = "リストア失敗";
$Lang{Reason_archive_failed} = "アーカイブ失敗";
$Lang{Reason_no_ping}        = "無応答";
$Lang{Reason_backup_canceled_by_user}  = "ユーザによるバックアップ取消";
$Lang{Reason_restore_canceled_by_user} = "ユーザによるリストア取消";
$Lang{Reason_archive_canceled_by_user} = "ユーザによるアーカイブ取消";
$Lang{Disabled_OnlyManualBackups}  = "自動無効化";  
$Lang{Disabled_AllBackupsDisabled} = "無効化";                  


# ---------
# Email messages

# No backup ever
$Lang{EMailNoBackupEverSubj} = "BackupPC: \$host の成功したバックアップが存在しません。";
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
$Lang{RSS_Doc_Title}       = "BackupPCサーバ";
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
$Lang{CfgEdit_Edit_Config} = "設定の編集";
$Lang{CfgEdit_Edit_Hosts}  = "ホストの編集";

$Lang{CfgEdit_Title_Server} = "サーバ";
$Lang{CfgEdit_Title_General_Parameters} = "一般のパラメータ";
$Lang{CfgEdit_Title_Wakeup_Schedule} = "起動スケジュール";
$Lang{CfgEdit_Title_Concurrent_Jobs} = "並行ジョブ";
$Lang{CfgEdit_Title_Pool_Filesystem_Limits} = "ファイルシステムのプール上限";
$Lang{CfgEdit_Title_Other_Parameters} = "他のパラメータ";
$Lang{CfgEdit_Title_Remote_Apache_Settings} = "リモートApache の設定";
$Lang{CfgEdit_Title_Program_Paths} = "プログラムパス";
$Lang{CfgEdit_Title_Install_Paths} = "インストールパス";
$Lang{CfgEdit_Title_Email} = "メール";
$Lang{CfgEdit_Title_Email_settings} = "メールの設定";
$Lang{CfgEdit_Title_Email_User_Messages} = "メールユーザメッセージ";
$Lang{CfgEdit_Title_CGI} = "CGI";
$Lang{CfgEdit_Title_Admin_Privileges} = "管理者権限";
$Lang{CfgEdit_Title_Page_Rendering} = "ページ描画";
$Lang{CfgEdit_Title_Paths} = "パス";
$Lang{CfgEdit_Title_User_URLs} = "ユーザURL";
$Lang{CfgEdit_Title_User_Config_Editing} = "ユーザ設定の編集";
$Lang{CfgEdit_Title_Xfer} = "転送";
$Lang{CfgEdit_Title_Xfer_Settings} = "転送設定";
$Lang{CfgEdit_Title_Ftp_Settings} = "FTP設定";
$Lang{CfgEdit_Title_Smb_Settings} = "Smb設定";
$Lang{CfgEdit_Title_Tar_Settings} = "Tar設定";
$Lang{CfgEdit_Title_Rsync_Settings} = "Rsync設定";
$Lang{CfgEdit_Title_Rsyncd_Settings} = "Rsyncd設定";
$Lang{CfgEdit_Title_Archive_Settings} = "アーカイブの設定";
$Lang{CfgEdit_Title_Include_Exclude} = "包含・除外";
$Lang{CfgEdit_Title_Smb_Paths_Commands} = "Smbパス/コマンド";
$Lang{CfgEdit_Title_Tar_Paths_Commands} = "Tarパス/コマンド";
$Lang{CfgEdit_Title_Rsync_Paths_Commands_Args} = "Rsyncパス/コマンド/引数";
$Lang{CfgEdit_Title_Rsyncd_Port_Args} = "Rsyncdポート/引数";
$Lang{CfgEdit_Title_Archive_Paths_Commands} = "アーカイブパス/コマンド";
$Lang{CfgEdit_Title_Schedule} = "スケジュール";
$Lang{CfgEdit_Title_Full_Backups} = "フルバックアップ";
$Lang{CfgEdit_Title_Incremental_Backups} = "増分バックアップ";
$Lang{CfgEdit_Title_Blackouts} = "喪失";
$Lang{CfgEdit_Title_Other} = "その他";
$Lang{CfgEdit_Title_Backup_Settings} = "バックアップの設定";
$Lang{CfgEdit_Title_Client_Lookup} = "クライアント探索";
$Lang{CfgEdit_Title_User_Commands} = "ユーザコマンド";
$Lang{CfgEdit_Title_Hosts} = "ホスト";

$Lang{CfgEdit_Hosts_Comment} = <<EOF;
新しいホストの追加は[追加]を選択し名前を入力します。
他のホストからホスト毎の設定で起動ためには、NEWHOST=のCOPYHOSTとしてホスト名を入力します。
これはNEWHOSTの既存のホストごとの設定が上書きされます。
また、既存のホストのためにこれを行うことができます。
ホストを削除するには、[削除]ボタンを押してください。
追加、削除、およびコンフィギュレーションのコピーには、[保存]を選択するまで、変更は有効になりません。
あなたが誤ってホストを削除した場合なので、単にそれを再度追加削除されたホストのバックアップのいずれも削除されません。
完全にホストのバックアップを削除するには、手動で\$topDir/pc/HOST以下のファイルを削除する必要があります。
EOF

$Lang{CfgEdit_Header_Main} = <<EOF;
\${h1("主設定エディタ")}
EOF

$Lang{CfgEdit_Header_Host} = <<EOF;
\${h1("ホスト \$host 設定エディタ")}
<p>
備考: このホスト特有の値に更新したい場合は、「上書き」をチェックしてください。
<p>
EOF

$Lang{CfgEdit_Button_Save}     = "保存";
$Lang{CfgEdit_Button_Insert}   = "挿入";
$Lang{CfgEdit_Button_Delete}   = "削除";
$Lang{CfgEdit_Button_Add}      = "追加";
$Lang{CfgEdit_Button_Override} = "上書き";
$Lang{CfgEdit_Button_New_Key}  = "新項目";

$Lang{CfgEdit_Error_No_Save}
            = "エラー: エラーのために保存されてません";
$Lang{CfgEdit_Error__must_be_an_integer}
            = "エラー: \$var は整数である必要があります";
$Lang{CfgEdit_Error__must_be_real_valued_number}
            = "エラー: \$var は実在する番号である必要があります";
$Lang{CfgEdit_Error__entry__must_be_an_integer}
            = "エラー: \$var エントリー \$k は整数である必要があります";
$Lang{CfgEdit_Error__entry__must_be_real_valued_number}
            = "エラー: \$var エントリー \$k は実在する番号である必要があります";
$Lang{CfgEdit_Error__must_be_executable_program}
            = "エラー: \$var は有効な実行可能なパスである必要があります";
$Lang{CfgEdit_Error__must_be_valid_option}
            = "エラー: \$var は有効なオプションである必要があります";
$Lang{CfgEdit_Error_Copy_host_does_not_exist}
            = "\$copyHost のコピーが存在しません。 creating full host name \$fullHost.  Delete this host if that is not what you wanted.";

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
  
#end of lang_ja.pm
