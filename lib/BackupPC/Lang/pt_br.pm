#!/usr/bin/perl
#
# By Reginaldo Ferreira <reginaldo@lepper.com.br> (23.07.2004 for V2.1.10)
#
# Edited by Rodrigo Real <rreal@ucpel.tche.br> (22.06.2006)
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

$Lang{Start_Archive} = "Iniciar backup";
$Lang{Stop_Dequeue_Archive} = "Parar/Cancelar backup";
$Lang{Start_Full_Backup} = "Iniciar Backup Completo";
$Lang{Start_Incr_Backup} = "Iniciar Backup Incremental";
$Lang{Stop_Dequeue_Backup} = "Parar/Cancelar Backup";
$Lang{Restore} = "Restaurar";

$Lang{Type_full} = "completo";
$Lang{Type_incr} = "incremental";

# -----

$Lang{Only_privileged_users_can_view_admin_options} = "Somente superusuarios podem ver as op��es de administra��o.";
$Lang{H_Admin_Options} = "Servidor BackupPC: Op��es de administra��o";
$Lang{Admin_Options} = "Op��es de administra��o";
$Lang{Admin_Options_Page} = <<EOF;
\${h1(qq{$Lang{Admin_Options}})}
<br>
\${h2("Controle do Servidor")}
<form name="ReloadForm" action="\$MyURL" method="get">
<input type="hidden" name="action" value="">
<table class="tableStnd">
  <tr><td>Atualizar configura��es do servidor:<td><input type="button" value="Reload"
     onClick="document.ReloadForm.action.value='Reload';
              document.ReloadForm.submit();">
</table>
</form>
<!--
\${h2("Configura��o do Servidor")}
<ul> 
  <li><i>Espa�o para outras op��es... e.j.,</i>
  <li>Editar configura��es do servidor
</ul>
-->
EOF

$Lang{Unable_to_connect_to_BackupPC_server} = "Imposs�vel conectar ao servidor BackupPC";
$Lang{Unable_to_connect_to_BackupPC_server_error_message} = <<EOF;
Este script CGI (\$MyURL) n�o pode conectar-se ao servidor BackupPC
em \$Conf{ServerHost} porta \$Conf{ServerPort}.<br>
O erro foi: \$err.<br>
Talvez o servidor BackupPC n�o esteja ativo ou h� um
erro de configura��o. Por favor informe o administrador do sistema.
EOF

$Lang{Admin_Start_Server} = <<EOF;
\${h1(qq{$Lang{Unable_to_connect_to_BackupPC_server}})}
<form action="\$MyURL" method="get">
O servidor BackupPC em <tt>\$Conf{ServerHost}</tt> port <tt>\$Conf{ServerPort}</tt>
n�o est� iniciando (pode ter parado ou n�o ainda n�o iniciado).<br>
Deseja inicia-lo agora?
<input type="hidden" name="action" value="startServer">
<input type="submit" value="Start Server" name="ignore">
</form>
EOF

# -----

$Lang{H_BackupPC_Server_Status} = "Estado do Servidor BackupPC";

$Lang{BackupPC_Server_Status_General_Info}= <<EOF;
\${h2(\"Informa��es Gerais do servidor\")}

<ul>
<li> O PID do servidor � \$Info{pid}, no host \$Conf{ServerHost},
     vers�o \$Info{Version}, iniciado em \$serverStartTime.
<li> Esta informa��o de estado foi gerada em \$now.
<li> A �ltima configura��o foi carregada �s \$configLoadTime
<li> A fila de PCs se ativar� novamente em \$nextWakeupTime.
<li> Informa��es adicionais:
    <ul>
        <li>\$numBgQueue solicita��es de backup pendentes desde a �ltima ativa��o programada,
        <li>\$numUserQueue solicita��es de backup de usuarios,
        <li>\$numCmdQueue solicita��es de comandos pendentes,
        \$poolInfo
        <li>O sistema de arquivos estava recentemente em \$Info{DUlastValue}%
            (\$DUlastTime), o m�ximo de hoje � \$Info{DUDailyMax}% (\$DUmaxTime)
            e o m�ximo de ontem foi \$Info{DUDailyMaxPrev}%.
    </ul>
</ul>
EOF

$Lang{BackupPC_Server_Status} = <<EOF;
\${h1(qq{$Lang{H_BackupPC_Server_Status}})}

<p>
\${h2("Trabalhos em Execu��o")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td> Host </td>
    <td> Tipo </td>
    <td> Usu�rio </td>
    <td> Hora de In�cio </td>
    <td> Comando </td>
    <td align="center"> PID </td>
    <td align="center"> Transfer. PID </td>
    <td align="center"> Status </td>
    <td align="center"> Count </td>
    </tr>
\$jobStr
</table>

<p>
\$generalInfo

\${h2("Falhas que Precisam de Aten��o")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> Host </td>
    <td align="center"> Tipo </td>
    <td align="center"> Usu�rio </td>
    <td align="center"> �ltima Tentativa </td>
    <td align="center"> Detalhes </td>
    <td align="center"> Hora do erro </td>
    <td> �ltimo erro (ping n�o incluido) </td></tr>
\$statusStr
</table>
EOF

# --------------------------------
$Lang{BackupPC__Server_Summary} = "BackupPC: Resumo do Servidor";
$Lang{BackupPC__Archive} = "BackupPC: Archive";
$Lang{BackupPC_Summary}=<<EOF;

\${h1(qq{$Lang{BackupPC__Server_Summary}})}
<p>
<ul>
<li>Este status foi generado em \$now.
<li>O sistema de arquivos estava recentemente em \$Info{DUlastValue}%
    (\$DUlastTime), o m?ximo de hoje ? \$Info{DUDailyMax}% (\$DUmaxTime)
    e o m?ximo de ontem foi \$Info{DUDailyMaxPrev}%.
</ul>
</p>

\${h2("Hosts com Backups Completos")}
<p>
Existem \$hostCntGood hosts com backup, de um total de :
<ul>
<li> \$fullTot backups com tamanho total de \${fullSizeTot} GiB
     (antes de agrupar e comprimir),
<li> \$incrTot backups incrementais com tamanho total de \${incrSizeTot} GiB
     (antes de agrupar e comprimir).
</ul>
</p>
<table class="sortable" id="host_summary_backups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> Host </td>
    <td align="center"> Usuario </td>
    <td align="center"> #Completo </td>
    <td align="center"> Completo Antig. (Dias) </td>
    <td align="center"> Completo Tamanho (GiB) </td>
    <td align="center"> Velocidade (MB/sec) </td>
    <td align="center"> #Incrementais </td>
    <td align="center"> Incrementais Antig (Dias) </td>
    <td align="center"> ENG Last Backup (days) </td>
    <td align="center"> Estado </td>
    <td align="center"> N� Xfer errs </td>
    <td align="center"> �ltima Tentativa </td></tr>
\$strGood
</table>
\${h2("Hosts Sem Backups")}
<p>
Existem \$hostCntNone hosts sem backups.
<p>
<table class="sortable" id="host_summary_nobackups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> Host </td>
    <td align="center"> Usuario </td>
    <td align="center"> #Completo </td>
    <td align="center"> Completo Antig. (Dias) </td>
    <td align="center"> Completo Tamanho (GiB) </td>
    <td align="center"> Velocidade (MB/sec)</td>
    <td align="center"> #Incrementais </td>
    <td align="center"> Incrementais Antig (Dias) </td>
    <td align="center"> ENG Last Backup (days) </td>
    <td align="center"> Estado </td>
    <td align="center"> N� Xfer errs </td>
    <td align="center"> �ltima tentativa </td></tr>
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

Existem \$hostCntGood hosts que possuem backup com tamanho total de \${fullSizeTot}GiB
<p>
<form name="form1" method="post" action="\$MyURL">
<input type="hidden" name="fcbMax" value="\$checkBoxCnt">
<input type="hidden" name="type" value="1">
<input type="hidden" name="host" value="\${EscHTML(\$archHost)}">
<input type="hidden" name="action" value="Archive">
<table class="tableStnd" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td align=center> Host</td>
    <td align="center"> Usu�rio </td>
    <td align="center"> Tamanho Backup </td>
\$strGood
\$checkAllHosts
</table>
</form>
<p>

EOF

$Lang{BackupPC_Archive2} = <<EOF;
\${h1(qq{$Lang{BackupPC__Archive}})}
Sobre o Backup dos seguintes Hosts
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
    <td colspan=2><input type="submit" value="Iniciar Archive" name="ignore"></td>
</tr>
</form>
</table>
EOF

$Lang{BackupPC_Archive2_location} = <<EOF;
<tr>
    <td>Archive Localiza��o/Dispositivo</td>
    <td><input type="text" value="\$ArchiveDest" name="archive_device"></td>
</tr>
EOF

$Lang{BackupPC_Archive2_compression} = <<EOF;
<tr>
    <td>Compression</td>
    <td>
    <input type="radio" value="0" name="compression" \$ArchiveCompNone>None<br>
    <input type="radio" value="1" name="compression" \$ArchiveCompGzip>gzip<br>
    <input type="radio" value="2" name="compression" \$ArchiveCompBzip2>bzip2
    </td>
</tr>
EOF

$Lang{BackupPC_Archive2_parity} = <<EOF;
<tr>
    <td>Porcentagem de dados de paridade (0 = desabilitado, 5 = normal)</td>
    <td><input type="numeric" value="\$ArchivePar" name="par"></td>
</tr>
EOF

$Lang{BackupPC_Archive2_split} = <<EOF;
<tr>
    <td>Dividir resultado em</td>
    <td><input type="numeric" value="\$ArchiveSplit" name="splitsize">Megabytes</td>
</tr>
EOF

# -----------------------------------
$Lang{Pool_Stat} = <<EOF;
        <li>O pool de \${poolSize}GiB compreende \$info->{"\${name}FileCnt"} arquivos
            e \$info->{"\${name}DirCnt"} diret�rios (as of \$poolTime),
        <li>O processamento do pool � de \$info->{"\${name}FileCntRep"} arquivos
            repetidos cuja cadeia maior � \$info->{"\${name}FileRepMax"},
        <li>O processo de limpeza noturna eliminou \$info->{"\${name}FileCntRm"} arquivos de
             \${poolRmSize}GiB (around \$poolTime),
EOF

# --------------------------------
$Lang{BackupPC__Backup_Requested_on__host} = "BackupPC: Solicita��o de Backup por \$host";
# --------------------------------
$Lang{REPLY_FROM_SERVER} = <<EOF;
\${h1(\$str)}
<p>
A resposta do servidor foi: \$reply
<p>
Voltar a <a href="\$MyURL?host=\$host">\$host home page</a>.
EOF
# --------------------------------
$Lang{BackupPC__Start_Backup_Confirm_on__host} = "BackupPC: Confirme inicio do backup em \$host";
# --------------------------------
$Lang{Are_you_sure_start} = <<EOF;
\${h1("Tem certeza?")}
<p>
Iniciando Backup \$type em \$host.

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="hostIP" value="\$ipAddr">
<input type="hidden" name="doit" value="1">
<input type="hidden" name="action" value="">
Tem certeza desta a��o?
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="No" name="ignore">
</form>
EOF
# --------------------------------
$Lang{BackupPC__Stop_Backup_Confirm_on__host} = "BackupPC: Confirma��o de Parada do Backup \$host";
# --------------------------------
$Lang{Are_you_sure_stop} = <<EOF;

\${h1("Tem certeza?")}

<p>
Voc� est� certo de parar/sair da fila de backup em \$host;

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host"   value="\$host">
<input type="hidden" name="doit"   value="1">
<input type="hidden" name="action" value="">
Assim mesmo, por favor n�o impessa outro backup durante
<input type="text" name="backoff" size="10" value="\$backoff"> horas.
<p>
Tem certeza de que quer fazer isto?
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="No" name="ignore">
</form>

EOF
# --------------------------------
$Lang{Only_privileged_users_can_view_queues_} = "Somente administradores podem ver as filas.";
# --------------------------------
$Lang{Only_privileged_users_can_archive} = "Somente administradores podem arquivar.";
# --------------------------------
$Lang{BackupPC__Queue_Summary} = "BackupPC: Resumo da Fila de Backup";
# --------------------------------
$Lang{Backup_Queue_Summary} = <<EOF;
\${h1("Resumo da Fila de Backup")}
\${h2("Resumo da Fila de Usu�rios")}
<p>
As seguintes solicita��es de usu�rios est�o atualmente em fila:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Host </td>
    <td> Hora Sol. </td>
    <td> Usu�rio </td></tr>
\$strUser
</table>

\${h2("Resumo da Fila em Segundo Plano")}
<p>
As seguintes solicita��es em segundo plano est�o atualmente em fila:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Host </td>
    <td> Hora Sol. </td>
    <td> Usu�rio </td></tr>
\$strBg
</table>
\${h2("Resumo da Fila de Comandos")}
<p>
Os seguintes comandos est�o atualmente em fila:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Host </td>
    <td> Hora Sol. </td>
    <td> Usu�rio </td>
    <td> Comando </td></tr>
\$strCmd
</table>
EOF

# --------------------------------
$Lang{Backup_PC__Log_File__file} = "BackupPC: LOG de Registro \$file";
$Lang{Log_File__file__comment} = <<EOF;
\${h1("Log File \$file \$comment")}
<p>
EOF
# --------------------------------
$Lang{Contents_of_log_file} = <<EOF;
Conte�do do log de registro <tt>\$file</tt>, modificado \$mtimeStr \$comment
EOF

# --------------------------------
$Lang{skipped__skipped_lines} = "[ saltadas \$skipped linhas ]\n";
# --------------------------------
$Lang{_pre___Can_t_open_log_file__file} = "<pre>\nN�o pode-se abrir o LOG de registro \$file\n";

# --------------------------------
$Lang{BackupPC__Log_File_History} = "BackupPC: Hist�rico dos Logs de Registro";
$Lang{Log_File_History__hdr} = <<EOF;
\${h1("Hist�rico do Log de Registro \$hdr")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> File </td>
    <td align="center"> Tamanho </td>
    <td align="center"> Hora Modifica��o </td></tr>
\$str
</table>
EOF

# -------------------------------
$Lang{Recent_Email_Summary} = <<EOF;
\${h1("Resumo de Emails Recentes (Ordem cronol�gica invertida)")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Destinat�rio </td>
    <td align="center"> Host </td>
    <td align="center"> Hora </td>
    <td align="center"> Assunto </td></tr>
\$str
</table>
EOF
 

# ------------------------------
$Lang{Browse_backup__num_for__host} = "BackupPC: Explorar Backup \$num de \$host";

# ------------------------------
$Lang{Restore_Options_for__host} = "BackupPC: Op��es de restaura��o para \$host";
$Lang{Restore_Options_for__host2} = <<EOF;
\${h1("Op��es de restaura��o para \$host")}
<p>
Foi selecionado os seguintes arquivos/diret�rios
da unidade \$share, c�pia n�mero #\$num:
<ul>
\$fileListStr
</ul>
</p><p>
Existem tr�s op��es para restaurar estes arquivos/diret�rios.
Por favor, selecione uma das seguintes op��es.
</p>
\${h2("Op��o 1: Restaura��o Direta")}
<p>
EOF

$Lang{Restore_Options_for__host_Option1} = <<EOF;
� poss�vel iniciar um processo que restaurar� estes arquivos diretamente em
<b>\$directHost</b>.
</p><p>
<b>Aten��o!:</b> Qualquer arquivo existente com o mesmo nome que o que est�
selecionado ser� sobrescrito!
</p>
<form action="\$MyURL" method="post" name="direct">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="3">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<table class="tableStnd" border="0">
<tr>
    <td>Restaurar os arquivos no host</td>
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
    <td>Restaurar os arquivos na unidade</td>
    <td><input type="text" size="40" value="\${EscHTML(\$share)}"
	 name="shareDest"></td>
</tr><tr>
    <td>Restaurar os arquivos abaixo no diret�rio<br>(relativo a unidade)</td>
    <td valign="top"><input type="text" size="40" maxlength="256"
	value="\${EscHTML(\$pathHdr)}" name="pathHdr"></td>
</tr><tr>
    <td><input type="submit" value="Iniciar Restaura��o" name="ignore"></td>
</table>
</form>
EOF

$Lang{Restore_Options_for__host_Option1_disabled} = <<EOF;
Se a restaura��o direta foi desabilitada para o host \${EscHTML(\$hostDest)}.
Por favor selecione uma das outras op��es de restaura��o.
EOF

# ------------------------------
$Lang{Option_2__Download_Zip_archive} = <<EOF;
<p>
\${h2("Op��o 2: Criar arquivo Zip")}
<p>
Pode-se criar um arquivo comprimido (.zip) contendo todos os arquivos e diret�rios que
foram selecionados.  Depois pode-se utilizar uma aplica��o local, como WinZip,
para ver ou extrair os arquivos.
</p><p>
<b>Aten��o!:</b> Dependendo de quais arquivos/pastas tenham sido selecionados,
este arquivo pode ser muito grande. Poderia demorar muitos minutos para
criar e transferir o arquivo. Tamb�m necessitar� suficiente espa�io em disco
local para armazen�-lo.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="2">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Fazer arquivo relativo
a \${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(caso contr�rio o arquivo conter� os caminhos completos).
<br>
<table class="tableStnd" border="0">
<tr>
    <td>Compress�o (0=desativada, 1=r�pida,...,9=m�xima)</td>
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
\${h2("Op��o 2: Criar arquivo Zip")}
<p>
O programa Archive::Zip n�o est� instalado, de modo que n� poder� criar um
arquivo comprimido zip.
Por favor, solicite ao seu administrador de sistemas que instale Archive::Zip de
<a href="http://www.cpan.org">www.cpan.org</a>.
</p>
EOF


# ------------------------------
$Lang{Option_3__Download_Zip_archive} = <<EOF;
\${h2("Opci�n 3: Criar archivo Tar")}
<p>
Pode-se criar um arquivo comprimido (.Tar) contendo todos os arquivos e
diret�rios que foram selecionados. Ap�s pode-se utilizar uma aplica��o
local, como Tar ou WinZip, para ver ou extrair os arquivos gerados.
</p><p>
<b>Aten��o!:</b> Dependendo de quais arquivos/pastas foram selecionados,
este arquivo pode ser muito grande. Poderia levar muitos minutos para
criar e transferir o arquivo. Tamb�m necessitar� suficiente espa�o no disco
local para armazen�-lo.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="1">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Criar um arquivo
relativo a \${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(caso contr�rio o arquivo conter� os caminhos completos).
<br>
<input type="submit" value="Download Tar File" name="ignore">
</form>
EOF


# ------------------------------
$Lang{Restore_Confirm_on__host} = "BackupPC: Confirme restaura��o em \$host";

$Lang{Are_you_sure} = <<EOF;
\${h1("Tem certeza?")}
<p>
Est� prestes a comen�ar uma restaura��o diretamente na m�quina \$In{hostDest}.
Os seguintes arquivos ser�o restaurados na unidade \$In{shareDest}, a partir
do Backup n�mero \$num:
<p>
<table class="tableStnd" border>
<tr class="tableheader"><td>Arquivo/Dir Original </td><td>Ser� restaurado em</td></tr>
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
Tem certeza?
<input type="button" value="\$Lang->{Restore}"
 onClick="document.RestoreForm.action.value='Restore';
          document.RestoreForm.submit();">
<input type="submit" value="No" name="ignore">
</form>
EOF


# --------------------------
$Lang{Restore_Requested_on__hostDest} = "BackupPC: Restaura��o solicitada em \$hostDest";
$Lang{Reply_from_server_was___reply} = <<EOF;
\${h1(\$str)}
<p>
A resposta do servidor foi: \$reply
<p>
voltar a <a href="\$MyURL?host=\$hostDest">\$hostDest home page</a>.
EOF

$Lang{BackupPC_Archive_Reply_from_server} = <<EOF;
\${h1(\$str)}
<p>
A resposta do servidor foi: \$reply
EOF

# -------------------------
$Lang{Host__host_Backup_Summary} = "BackupPC: Host \$host Resumo do Backup";

$Lang{Host__host_Backup_Summary2} = <<EOF;
\${h1("Host \$host Resumo do Backup")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>
</p>
\${h2("A��es do Usu�rio")}
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
\${h2("Resumo do Backup")}
<p>
Clique no n�mero do Backup para revisar e restaurar arquivos.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> C�pia N� </td>
    <td align="center"> Tipo </td>
    <td align="center"> Completo </td>
    <td align="center"> ENG Level </td>
    <td align="center"> Data In�cio </td>
    <td align="center"> Dura��o/min </td>
    <td align="center"> Idade/dias </td>
    <td align="center"> Rota da C�pia no Servidor </td>
</tr>
\$str
</table>
<p>

\$restoreStr
</p>
\${h2("Resumo dos Erros de Transfer�ncia")}
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Copia N� </td>
    <td align="center"> Tipo </td>
    <td align="center"> Ver </td>
    <td align="center"> N� Xfer errs </td>
    <td align="center"> N� erros arquivos </td>
    <td align="center"> N� erros unidades </td>
    <td align="center"> N� erros tar </td>
</tr>
\$errStr
</table>

\${h2("Resumo do Total/Tamanho dos Arquivos Reutilizados")}
<p>
Os arquivos existentes s�o aqueles que j� est�o no lote; os novos s�o
aqueles que ser�o adicionados ao lote.
Os arquivos vazios e os erros de SMB n�o contam nos valores de reutilizados
nem nos de novos.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="2" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> Totais </td>
    <td align="center" colspan="2"> Arquivos Existentes </td>
    <td align="center" colspan="2"> Arquivos Novos </td>
</tr>
<tr class="tableheader">
    <td align="center"> C�pia N� </td>
    <td align="center"> Tipo </td>
    <td align="center"> N� Arquivos </td>
    <td align="center"> Tamanho/MB </td>
    <td align="center"> MB/seg </td>
    <td align="center"> N� Arquivos </td>
    <td align="center"> Tamanho/MB </td>
    <td align="center"> N� Arquivos </td>
    <td align="center"> Tamanho/MB </td>
</tr>
\$sizeStr
</table>

\${h2("Resumo da Compress�o")}
<p>
Performance de compres�o para os arquivos j� existentes no lote e nos
arquivos novos comprimidos.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="3" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> Arquivos Existentes </td>
    <td align="center" colspan="3"> Arquivos Novos </td>
</tr>
<tr class="tableheader"><td align="center"> C�pia N� </td>
    <td align="center"> Tipo </td>
    <td align="center"> N�vel Compr </td>
    <td align="center"> Tamanho/MB </td>
    <td align="center"> Compr/MB </td>
    <td align="center"> Compr </td>
    <td align="center"> Tamanho/MB </td>
    <td align="center"> Compr/MB </td>
    <td align="center"> Compr </td>
</tr>
\$compStr
</table>
EOF

$Lang{Host__host_Archive_Summary} = "BackupPC: Host \$host Archive Summary";
$Lang{Host__host_Archive_Summary2} = <<EOF;
\${h1("Host Archive Summary \$host")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>

\${h2("A��es do usu�rio")}
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
$Lang{Error} = "BackupPC: Erro";
$Lang{Error____head} = <<EOF;
\${h1("Erro: \$head")}
<p>\$mesg</p>
EOF

# -------------------------
$Lang{NavSectionTitle_} = "Servidor";

# -------------------------
$Lang{Backup_browse_for__host} = <<EOF;
\${h1("Revisar Backup do \$host")}

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
<li> Revisando o Backup N�\$num, que iniciou �s \$backupTime
        (faz \$backupAge dias),
\$filledBackup
<li> Indique o diret�rio: <input type="text" name="dir" size="50" maxlength="4096" value="\${EscHTML(\$dir)}"> <input type="submit" value="\$Lang->{Go}" name="Submit">
<li> Clique em um dos diret�rios abaixo para revisar seus conte�dos,
<li> Clique em um arquivo para restaur�-lo,
<li> Ver o Backup <a href="\$MyURL?action=dirHistory&host=\${EscURI(\$host)}&share=\$shareURI&dir=\$pathURI">history</a> do diret�rio atual.
</ul>
</form>

\${h2("Conte�do do \$dirDisplay")}
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
<input type="submit" name="Submit" value="Restaurar arquivos selecionados">
-->
</form>
EOF

# ------------------------------
$Lang{DirHistory_backup_for__host} = "BackupPC: Hist�rico do Backup do diret�rio em \$host";

#
# These two strings are used to build the links for directories and
# file versions.  Files are appended with a version number.
#
$Lang{DirHistory_dirLink}  = "dir";
$Lang{DirHistory_fileLink} = "v";

$Lang{DirHistory_for__host} = <<EOF;
\${h1("Hist�rico do backup do diret�rio em \$host")}
<p>
Este quadro mostra cada vers�o �nica dispon�vel nos diversos backups:
<ul>
<li> Clique no n�mero do backup para voltar ao explorador de backups,
<li> Clique no atalho do diret�rio (\$Lang->{DirHistory_dirLink}) para navegar
     por esse diret�rio,
<li> Clique no atalho da vers�o do arquivo (\$Lang->{DirHistory_fileLink}0,
     \$Lang->{DirHistory_fileLink}1, ...) para baixar esse arquivo,
<li> Os arquivos com conte�dos diferentes entre c�pias distintas de backup tem o mesmo
     n�mero de verss�o,
<li> Os arquivos ou diret�rios inexistentes em um determinado backup tem uma 
     caixa vazia.
<li> Os arquivos mostrados com a mesma vers�o podem ter diferentes atributos.
     Selecione o n�mero do backup para ver os atributos do arquivo.
</ul>

\${h2("Hist�rico de \$dirDisplay")}

<br>
<table border cellspacing="2" cellpadding="3">
<tr class="fviewheader"><td>Backup numero</td>\$backupNumStr</tr>
<tr class="fviewheader"><td>Backup time</td>\$backupTimeStr</tr>
\$fileStr
</table>
EOF

# ------------------------------
$Lang{Restore___num_details_for__host} = "BackupPC: Detalhes da restaura��o N�\$num de \$host";

$Lang{Restore___num_details_for__host2} = <<EOF;
\${h1("Detalhes da restaura��o N�\$num de \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="90%">
<tr><td class="tableheader"> N�mero </td><td class="border"> \$Restores[\$i]{num} </td></tr>
<tr><td class="tableheader"> Solicitado por </td><td class="border"> \$RestoreReq{user} </td></tr>
<tr><td class="tableheader"> Hora da Solicita��o </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> Resultado </td><td class="border"> \$Restores[\$i]{result} </td></tr>
<tr><td class="tableheader"> Mensagem de Erro </td><td class="border"> \$Restores[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> Host Origem </td><td class="border"> \$RestoreReq{hostSrc} </td></tr>
<tr><td class="tableheader"> N� c�pia origem </td><td class="border"> \$RestoreReq{num} </td></tr>
<tr><td class="tableheader"> Unidade origem </td><td class="border"> \$RestoreReq{shareSrc} </td></tr>
<tr><td class="tableheader"> Host destino </td><td class="border"> \$RestoreReq{hostDest} </td></tr>
<tr><td class="tableheader"> Unidade destino </td><td class="border"> \$RestoreReq{shareDest} </td></tr>
<tr><td class="tableheader"> Hora in�cio </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Dura��o </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> N�mero de arquivos </td><td class="border"> \$Restores[\$i]{nFiles} </td></tr>
<tr><td class="tableheader"> Tamanho total </td><td class="border"> \${MB} MB </td></tr>
<tr><td class="tableheader"> Taxa de transfer�ncia </td><td class="border"> \$MBperSec MB/sec </td></tr>
<tr><td class="tableheader"> Erros de cria��o Tar </td><td class="border"> \$Restores[\$i]{tarCreateErrs} </td></tr>
<tr><td class="tableheader"> Erros de transfer�ncia </td><td class="border"> \$Restores[\$i]{xferErrs} </td></tr>
<tr><td class="tableheader"> Arquivo registro de transfer�ncia </td><td class="border">
<a href="\$MyURL?action=view&type=RestoreLOG&num=\$Restores[\$i]{num}&host=\$host">View</a>,
<a href="\$MyURL?action=view&type=RestoreErr&num=\$Restores[\$i]{num}&host=\$host">Errors</a>
</tr></tr>
</table>
</p>
\${h1("Lista de Arquivos/Diret�rios")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="100%">
<tr class="tableheader"><td>Dir/arquivo original</td><td>Restaurado a</td></tr>
\$fileListStr
</table>
EOF

# ------------------------------
$Lang{Archive___num_details_for__host} = "BackupPC: Archive #\$num Detalhes de \$host";

$Lang{Archive___num_details_for__host2 } = <<EOF;
\${h1("Archive #\$num Detalhes de \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr><td class="tableheader"> N�mero </td><td class="border"> \$Archives[\$i]{num} </td></tr>
<tr><td class="tableheader"> Solicitado por </td><td class="border"> \$ArchiveReq{user} </td></tr>
<tr><td class="tableheader"> Hora da solicita��o </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> Resultado </td><td class="border"> \$Archives[\$i]{result} </td></tr>
<tr><td class="tableheader"> Mensagem de erro </td><td class="border"> \$Archives[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> Hora in�cio </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Dura��o </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> Arquivo registro Xfer </td><td class="border">
<a href="\$MyURL?action=view&type=ArchiveLOG&num=\$Archives[\$i]{num}&host=\$host">View</a>,
<a href="\$MyURL?action=view&type=ArchiveErr&num=\$Archives[\$i]{num}&host=\$host">Errors</a>
</tr></tr>
</table>
<p>
\${h1("Host list")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td>Host</td><td>Backup n�mero</td></tr>
\$HostListStr
</table>
EOF

# -----------------------------------
$Lang{Email_Summary} = "BackupPC: Resumo de Emails";

# -----------------------------------
#  !! ERROR messages !!
# -----------------------------------
$Lang{BackupPC__Lib__new_failed__check_apache_error_log} = "BackupPC::Lib->nova falha: revise o error_log do apache\n";
$Lang{Wrong_user__my_userid_is___} =  
              "Usu�rio inv�lido: meu userid � \$>, no lugar de \$uid"
            . "(\$Conf{BackupPCUser})\n";
# $Lang{Only_privileged_users_can_view_PC_summaries} = "Somente os usu�rios autorizados podem ver os resumos de PCs.";
$Lang{Only_privileged_users_can_stop_or_start_backups} = 
                  "Somente os usu�rios autorizados podem iniciar ou parar as c�pias"
		. " \${EscHTML(\$host)}.";
$Lang{Invalid_number__num} = "N�mero inv�lido \${EscHTML(\$In{num})}";
$Lang{Unable_to_open__file__configuration_problem} = "N�o pode abrir \$file: problema de configura��o?";
$Lang{Only_privileged_users_can_view_log_or_config_files} = "Somente os usu�rios autorizados podem ver registros ou arquivos de configura��o.";
$Lang{Only_privileged_users_can_view_log_files} = "Somente os usu�rios autorizados podem ver arquivos de registro.";
$Lang{Only_privileged_users_can_view_email_summaries} = "Somente os usu�rios autorizados podem ver resumos de email.";
$Lang{Only_privileged_users_can_browse_backup_files} = "Somente os usu�rios autorizados podem revisar os arquivos de backup"
                . " for host \${EscHTML(\$In{host})}.";
$Lang{Empty_host_name} = "N�mero de host vazio.";
$Lang{Directory___EscHTML} = "O diret�rio \${EscHTML(\"\$TopDir/pc/\$host/\$num\")}"
		    . " est� vazio";
$Lang{Can_t_browse_bad_directory_name2} = "N�o pode mostrar um nome de diret�rio inv�lido"
	            . " \${EscHTML(\$relDir)}";
$Lang{Only_privileged_users_can_restore_backup_files} = "Somente os usu�rios autorizados podem restaurar backups"
                . " para o host \${EscHTML(\$In{host})}.";
$Lang{Bad_host_name} = "Nome de host inv�lido \${EscHTML(\$host)}";
$Lang{You_haven_t_selected_any_files__please_go_Back_to} = "N�o foi selecionado nenhum arquivo; por favor, volte e"
                . " selecione alguns arquivos.";
$Lang{You_haven_t_selected_any_hosts} = "N�o foi selecionado nenhum host; por favor volte e"
                . " selecione algum host.";
$Lang{Nice_try__but_you_can_t_put} = "Boa tentativa, mas n�o pode usar \'..\' nos nomes de arquivo";
$Lang{Host__doesn_t_exist} = "O Host \${EscHTML(\$In{hostDest})} n�o existe";
$Lang{You_don_t_have_permission_to_restore_onto_host} = "Sem autoriza��o para restaurar neste host"
		    . " \${EscHTML(\$In{hostDest})}";
$Lang{Can_t_open_create__openPath} = "Imposs�vel abrir/criar "
		. "\${EscHTML(\"\$openPath\")}";
$Lang{Only_privileged_users_can_restore_backup_files2} = "Somente os usu�rios autorizados podem restaurar backups"
                . " do host \${EscHTML(\$host)}.";
$Lang{Empty_host_name} = "Nome de host vazio";
$Lang{Unknown_host_or_user} = "Usu�rio ou host inv�lido \${EscHTML(\$host)}";
$Lang{Only_privileged_users_can_view_information_about} = "Somente os usu�rios autorizados podem ver informa��es do"
                . " host \${EscHTML(\$host)}." ;
$Lang{Only_privileged_users_can_view_archive_information} = "Somente os administradores podem ver informa��es de arquivo.";
$Lang{Only_privileged_users_can_view_restore_information} = "Somente os usu�rios autorizados podem ver informa��es de restaura��o.";
$Lang{Restore_number__num_for_host__does_not_exist} = "O n�mero de restaura��o \$num del host \${EscHTML(\$host)} "
	        . " n�o existe.";
$Lang{Archive_number__num_for_host__does_not_exist} = "O backup \$num do host \${EscHTML(\$host)} "
                . " n�o existe.";
$Lang{Can_t_find_IP_address_for} = "Imposs�vel encontrar o endere�o do IP de \${EscHTML(\$host)}";
$Lang{host_is_a_DHCP_host} = <<EOF;
\$host � um host DHCP e eu n�o consigo seu endere�o IP. Provavelmente o nome netbios de \$ENV{REMOTE_ADDR}\$tryIP, e foi verificado que essa m�quina
n�o � \$host.
<p>
At� que tenha \$host um endere�o num DHCP v�lido, se pode
comen�ar este processo a partir da pr�pria m�quina cliente.
EOF

# ------------------------------------
# !! Server Mesg !!
# ------------------------------------

$Lang{Backup_requested_on_DHCP__host} = "Solicita��o de backup em DHCP \$host (\$In{hostIP}) por"
		                      . " \$User desde \$ENV{REMOTE_ADDR}";
$Lang{Backup_requested_on__host_by__User} = "Solicita��o de backup em \$host por \$User";
$Lang{Backup_stopped_dequeued_on__host_by__User} = "Backup parado/desprogramado em \$host por \$User";
$Lang{Restore_requested_to_host__hostDest__backup___num} = "Restaura��o solicitada para o host \$hostDest, backup #\$num,"
	     . " por \$User desde \$ENV{REMOTE_ADDR}";
$Lang{Archive_requested} = "Arquivo solicitado por \$User desde \$ENV{REMOTE_ADDR}";

# -------------------------------------------------
# ------- Stuff that was forgotten ----------------
# -------------------------------------------------

$Lang{Status} = "Estado";
$Lang{PC_Summary} = "Resumo PC";
$Lang{LOG_file} = "Arquivo de Log";
$Lang{LOG_files} = "Arquivos de Log";
$Lang{Old_LOGs} = "Logs antigos";
$Lang{Email_summary} = "Resumo Email";
$Lang{Config_file} = "Arquivo configura��o";
# $Lang{Hosts_file} = "Arquivo Hosts";
$Lang{Current_queues} = "Filas atuais";
$Lang{Documentation} = "Documenta��o";

#$Lang{Host_or_User_name} = "<small>Host ou usu�rio:</small>";
$Lang{Go} = "Aceitar";
$Lang{Hosts} = "Hosts";
$Lang{Select_a_host} = "Selecione um host...";

$Lang{There_have_been_no_archives} = "<h2> N�o existem arquivos </h2>\n";
$Lang{This_PC_has_never_been_backed_up} = "<h2> Nunca foi feito backup deste PC! </h2>\n";
$Lang{This_PC_is_used_by} = "<li>Este PC � utilizado por \${UserLink(\$user)}";

$Lang{Extracting_only_Errors} = "(Extraindo somente Erros)";
$Lang{XferLOG} = "TransfLOG";
$Lang{Errors}  = "Erros";

# ------------
$Lang{Last_email_sent_to__was_at___subject} = <<EOF;
<li>�ltima mensagem enviada a  \${UserLink(\$user)} foi �s \$mailTime, assunto "\$subj".
EOF
# ------------
$Lang{The_command_cmd_is_currently_running_for_started} = <<EOF;
<li>O comando \$cmd est� executando para \$host, iniciado �s \$startTime.
EOF

# -----------
$Lang{Host_host_is_queued_on_the_background_queue_will_be_backed_up_soon} = <<EOF;
<li>O host \$host est� em fila para ser processado em segundo plano (logo o backup estar� pronto!).
EOF

# ----------
$Lang{Host_host_is_queued_on_the_user_queue__will_be_backed_up_soon} = <<EOF;
<li>Host \$host est� para ser processado na fila de usuarios (logo o backup estar� pronto!).
EOF

# ---------
$Lang{A_command_for_host_is_on_the_command_queue_will_run_soon} = <<EOF;
<li>Uma execu��o para \$host estar na fila de execu��es (iniciar� a seguir).
EOF

# --------
$Lang{Last_status_is_state_StatusHost_state_reason_as_of_startTime} = <<EOF;
<li>O �ltimo estado foi \"\$Lang->{\$StatusHost{state}}\"\$reason �s \$startTime.
EOF

# --------
$Lang{Last_error_is____EscHTML_StatusHost_error} = <<EOF;
<li>O �ltimo erro foi \"\${EscHTML(\$StatusHost{error})}\".
EOF

# ------
$Lang{Pings_to_host_have_failed_StatusHost_deadCnt__consecutive_times} = <<EOF;
<li>Os pings para \$host falharam \$StatusHost{deadCnt} vezes consecutivas.
EOF

# -----
$Lang{Prior_to_that__pings} = "Antes destes, pings";

# -----
$Lang{priorStr_to_host_have_succeeded_StatusHostaliveCnt_consecutive_times} = <<EOF;
<li>\$priorStr a \$host obtiveram �xito \$StatusHost{aliveCnt}
        vezes consecutivas.
EOF

$Lang{Because__host_has_been_on_the_network_at_least__Conf_BlackoutGoodCnt_consecutive_times___} = <<EOF;
<li>Dado que \$host tem estado em uso na rede pelo menos \$Conf{BlackoutGoodCnt}
vezes consecutivas, n�o se realizar� backup das \$blackoutStr.
EOF

$Lang{__time0_to__time1_on__days} = "\$t0 at� \$t1 em \$days";

$Lang{Backups_are_deferred_for_hours_hours_change_this_number} = <<EOF;
<li>Os backups atrazaram-se durante \$hours hours
(<a href=\"\$MyURL?action=Stop_Dequeue_Backup&host=\$host\">Troque este n�mero</a>).
EOF

$Lang{tryIP} = " y \$StatusHost{dhcpHostIP}";

#$Lang{Host_Inhost} = "Host \$In{host}";

$Lang{checkAll} = <<EOF;
<tr><td class="fviewborder">
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;Selecionar tudo
</td><td colspan="5" align="center" class="fviewborder">
<input type="submit" name="Submit" value="Restaurar os arquivos selecionados">
</td></tr>
EOF

$Lang{checkAllHosts} = <<EOF;
<tr><td class="fviewborder">
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;Selecionar tudo
</td><td colspan="2" align="center" class="fviewborder">
<input type="submit" name="Submit" value="Arquivar os hosts selecionados">
</td></tr>
EOF

$Lang{fileHeader} = <<EOF;
    <tr class="fviewheader"><td align=center> Nome</td>
       <td align="center"> Tipo</td>
       <td align="center"> Modo</td>
       <td align="center"> N�</td>
       <td align="center"> Tamanho</td>
       <td align="center"> Hora Mod.</td>
    </tr>
EOF

$Lang{Home} = "Principal";
$Lang{Browse} = "Explorar backups";
$Lang{Last_bad_XferLOG} = "�ltimo erro no Log de Transfer�ncia";
$Lang{Last_bad_XferLOG_errors_only} = "�ltimo erro no Log de transfer�ncia (erros&nbsp;somente)";

$Lang{This_display_is_merged_with_backup} = <<EOF;
<li> Este quadro pertence ao backup N�\$numF.
EOF

$Lang{Visit_this_directory_in_backup} = <<EOF;
<li> Selecione o backup que desseja ver: <select onChange="window.location=this.value">\$otherDirs </select>
EOF

$Lang{Restore_Summary} = <<EOF;
\${h2("Resumo da Restaura��o")}
<p>
Clique no n�mero da restaura��o para ver seus detalhes.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Restaura��o N� </td>
    <td align="center"> Resultado </td>
    <td align="right"> Data Inicio</td>
    <td align="right"> Dur/mins</td>
    <td align="right"> N� Arquivos </td>
    <td align="right"> MB </td>
    <td align="right"> N� Err. Tar </td>
    <td align="right"> N� Err. Transf.#xferErrs </td>
</tr>
\$restoreStr
</table>
<p>
EOF

$Lang{Archive_Summary} = <<EOF;
\${h2("Archive Summary")}
<p>
Clique no n�mero do arquivo para mais detalhes.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Archive# </td>
    <td align="center"> Resultado </td>
    <td align="right"> Hora in�cio</td>
    <td align="right"> Dur/min</td>
</tr>
\$ArchiveStr
</table>
<p>
EOF

$Lang{BackupPC__Documentation} = "BackupPC: Documenta��o";

$Lang{No} = "n�o";
$Lang{Yes} = "sim";

$Lang{The_directory_is_empty} = <<EOF;
<tr><td bgcolor="#ffffff">O diret�rio \$dirDisplay est� vazio
</td></tr>
EOF

#$Lang{on} = "ativo";
$Lang{off} = "inativo";

$Lang{backupType_full}    = "completo";
$Lang{backupType_incr}    = "incremental";
$Lang{backupType_active}  = "active";
$Lang{backupType_partial} = "parcial";

$Lang{failed} = "falhado";
$Lang{success} = "sucesso";
$Lang{and} = "e";

# ------
# Hosts states and reasons
$Lang{Status_idle} = "inativo";
$Lang{Status_backup_starting} = "iniciando backup";
$Lang{Status_backup_in_progress} = "backup em execu��o";
$Lang{Status_restore_starting} = "iniciando restaura��o";
$Lang{Status_restore_in_progress} = "restaura��o em execu��o";
$Lang{Status_admin_pending} = "conex�o pendente";
$Lang{Status_admin_running} = "conex�o em curso";

$Lang{Reason_backup_done} = "backup realizado";
$Lang{Reason_restore_done} = "restaura��o realizada";
$Lang{Reason_archive_done}   = "arquivamento realizado";
$Lang{Reason_nothing_to_do} = "nada a fazer";
$Lang{Reason_backup_failed} = "falha no backup";
$Lang{Reason_restore_failed} = "falha na restaura��o";
$Lang{Reason_archive_failed} = "falha no arquivamento";
$Lang{Reason_no_ping} = "sem ping";
$Lang{Reason_backup_canceled_by_user} = "backup cancelado pelo usu�rio";
$Lang{Reason_restore_canceled_by_user} = "restaura��o cancelada pelo usu�rio";
$Lang{Reason_archive_canceled_by_user} = "arquivamento cancelado pelo usu�rio";
$Lang{Disabled_OnlyManualBackups}  = "ENG auto disabled";  
$Lang{Disabled_AllBackupsDisabled} = "ENG disabled";                  

# ---------
# Email messages

# No backup ever
$Lang{EMailNoBackupEverSubj} = "BackupPC: nenhum backup de \$host foi terminado com �xito";
$Lang{EMailNoBackupEverMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
Caro $userName,

Em seu PC ($host) nenhum backup foi completado por nosso programa de backup.
Os backups deveriam ser executados automaticamente quando seu PC se conecta
a rede. Contate seu suporte t�cnico se:

  - Seu computador est� conectado a rede com regularidade. Isto significa
    que existe algum problema de instala��o ou configura��o que impessa a
    realiza��o dos backups.

  - N�o deseja realizar backups e n�o quer receber mais mensagens
    como esta.

Caso contr�rio, assegure-se de que seu PC est� conectado � rede na pr�xima vez
que estiver utilizando-o.

Sauda��es:
Agente BackupPC
http://backuppc.sourceforge.net
EOF

# No recent backup
$Lang{EMailNoBackupRecentSubj} = "BackupPC: n�o existem backups recentes de \$host";
$Lang{EMailNoBackupRecentMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
Caro $userName,

N�o foi completado nenhum backup completo de seu PC ($host) durante
$days dias.
Seu PC tem realizado backups corretos $numBackups vezes desde
$firstTime at� $days dias.
Os backups deveriam efetuar-se automaticamente quando seu PC estiver
conectado a rede.

Se seu PC tem estado conectado durante algumas horas a rede durante os �ltimos
$days dias deveria contactar com seu suporte t�cnico para ver porque os backups
n�o funcionam adequadamente.

Por outro lado, se voc� n�o o est� utilizando, n�o h� muito o que fazer a n�o
ser copiar manualmente os arquivos mais cr�ticos para outro suporte f�sico. 
Deve-se estar ciente de que qualquer arquivo que tenha sido criado ou modificado
nos �ltimos $days dias (incluindo todos os emails novos e arquivos anexos) n�o podem
ser restaurados se seu disco danificar-se.

Sauda��es:
Agente BackupPC
http://backuppc.sourceforge.net
EOF

# Old Outlook files
$Lang{EMailOutlookBackupSubj} = "BackupPC: Oss arquivos do Outlook de \$host necessitam ser copiados";
$Lang{EMailOutlookBackupMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
Caro $userName,

Os arquivos de Outlook de seu PC tem $howLong.
Estes arquivos cont�m todo seus emails, anexos, contatos e informa��es de
sua agenda. Seu PC tem sido corretamente salvaguardado $numBackups vezes desde
$firstTime at� $lastTime dias.  Sem fech�-lo, Outlook bloqueia todos seus
arquivos quando est�o em execu��o, impidindo de se fazer backup dos mesmo.

Recomendamos fazer c�pia de seguran�a dos arquivos do Outlook quando estiver
conectado a rede fechando o Outlook e o resto das aplica��es e utilizando seu
navegador de internet. Clique neste link:

    $CgiURL?host=$host               

Selecione "Come�ar backup incremental" duas vezes para come�ar
um novo backup incremental.
Pode-se selecionar "Voltar a p�gina de $host " e clicar em "refazer"
para ver o estado do processo de backup. Este processo deve durar 
somente alguns minutos para completar.

Sauda��es:
Agente BackupPC
http://backuppc.sourceforge.net
EOF

$Lang{howLong_not_been_backed_up} = "n�o foi realizado nenhum backup com �xito";
$Lang{howLong_not_been_backed_up_for_days_days} = "n�o foi realizado nenhum backup durante \$days dias";

#######################################################################
# RSS strings
#######################################################################
$Lang{RSS_Doc_Title}       = "Servidor BackupPC";
$Lang{RSS_Doc_Description} = "RSS feed do BackupPC";
$Lang{RSS_Host_Summary}    = <<EOF;
#Completo: \$fullCnt;
Completo Antig./Dias: \$fullAge;
Completo Tamanho/GiB: \$fullSize;
Velocidade MB/sec: \$fullRate;
#Incrementais: \$incrCnt;
Incrementais Antig/Dias: \$incrAge;
Estado: \$host_state;
�ltima Tentativa: \$host_last_attempt;
EOF

#######################################################################
# Configuration editor strings
#######################################################################

$Lang{Only_privileged_users_can_edit_config_files} = "Somente usu�rios privilegiados podem editar as configura��es.";
$Lang{CfgEdit_Edit_Config} = "Editar Configura��es";
$Lang{CfgEdit_Edit_Hosts}  = "Editar Hosts";

$Lang{CfgEdit_Title_Server} = "Servidor";
$Lang{CfgEdit_Title_General_Parameters} = "Par�metros Gerais";
$Lang{CfgEdit_Title_Wakeup_Schedule} = "Agenda de ativa��o";
$Lang{CfgEdit_Title_Concurrent_Jobs} = "Trabalhos correntes";
$Lang{CfgEdit_Title_Pool_Filesystem_Limits} = "Limites do Pool no sistema de arquivos";
$Lang{CfgEdit_Title_Other_Parameters} = "Outros Par�metros";
$Lang{CfgEdit_Title_Remote_Apache_Settings} = "Configura��es remotas do Apache";
$Lang{CfgEdit_Title_Program_Paths} = "Caminho para o programa";
$Lang{CfgEdit_Title_Install_Paths} = "Caminho de instala��o";
$Lang{CfgEdit_Title_Email} = "Email";
$Lang{CfgEdit_Title_Email_settings} = "Configura��es de Email";
$Lang{CfgEdit_Title_Email_User_Messages} = "Mensagens de Email de Usu�rios";
$Lang{CfgEdit_Title_CGI} = "CGI";
$Lang{CfgEdit_Title_Admin_Privileges} = "Privil�gios de Administrador";
$Lang{CfgEdit_Title_Page_Rendering} = "Renderiza��o de p�gina";
$Lang{CfgEdit_Title_Paths} = "Caminhos";
$Lang{CfgEdit_Title_User_URLs} = "URLs do Usu�rio";
$Lang{CfgEdit_Title_User_Config_Editing} = "Edi��o de Configura��es do Usu�rio";
$Lang{CfgEdit_Title_Xfer} = "Transfer�ncia";
$Lang{CfgEdit_Title_Xfer_Settings} = "Configura��es de transfer�ncia";
$Lang{CfgEdit_Title_Ftp_Settings} = "Configura��es do FTP";
$Lang{CfgEdit_Title_Smb_Settings} = "Configura��es do Smb";
$Lang{CfgEdit_Title_Tar_Settings} = "Configura��es do Tar";
$Lang{CfgEdit_Title_Rsync_Settings} = "Configura��es do Rsync";
$Lang{CfgEdit_Title_Rsyncd_Settings} = "Configura��es do Rsyncd";
$Lang{CfgEdit_Title_Archive_Settings} = "Configura��es do Archive";
$Lang{CfgEdit_Title_Include_Exclude} = "Inclui/Exclui";
$Lang{CfgEdit_Title_Smb_Paths_Commands} = "Caminhos/Comandos do Smb";
$Lang{CfgEdit_Title_Tar_Paths_Commands} = "Caminhos/Comandos do Tar";
$Lang{CfgEdit_Title_Rsync_Paths_Commands_Args} = "Caminhos/Comandos/Args Rsync";
$Lang{CfgEdit_Title_Rsyncd_Port_Args} = "Porta/Args do Rsyncd";
$Lang{CfgEdit_Title_Archive_Paths_Commands} = "Caminhos/Comandos do Arquivo";
$Lang{CfgEdit_Title_Schedule} = "Agenda";
$Lang{CfgEdit_Title_Full_Backups} = "Backups Completos";
$Lang{CfgEdit_Title_Incremental_Backups} = "Backups Incrementais";
$Lang{CfgEdit_Title_Blackouts} = "Blackouts";
$Lang{CfgEdit_Title_Other} = "Outros";
$Lang{CfgEdit_Title_Backup_Settings} = "Configura��es do Backup";
$Lang{CfgEdit_Title_Client_Lookup} = "Busca Cliente";
$Lang{CfgEdit_Title_User_Commands} = "Commandos de usu�rio";
$Lang{CfgEdit_Title_Hosts} = "Hosts";

$Lang{CfgEdit_Hosts_Comment} = <<EOF;

Para adicionar um novo host, selecione Adicionar e entre com o
nome. Para iniciar uma configura��o espec�fica para um host a partir
de uma configura��o de outro, indique na forma
NOVOHOST=HOSTDECOPIA. Isto ir� sobre-escrever qualquer configura��o
pr�-existente para o NOVOHOST. Voc� tamb�m pode fazer isto para um
host j� existente. Para excluir um host, clique no bot�o Excluir. As
mudan�as envolvendo as opera��es de adicionar, excluir e fazer uma
c�pia de configura��o s� s�o efetivadas depois de salvas. Nenhum dos
backups dos hosts exclu�dos ser�o apagados, portanto se
incidentalmente voc� excluir um host, simplesmente o adicione
novamente. Para remover completamente backups de um host, voc� precisa
remover os arquivos manualmente abaixo de \$topDir/pc/HOST
EOF

$Lang{CfgEdit_Header_Main} = <<EOF;
\${h1("Editor de configura��es principais")}
EOF

$Lang{CfgEdit_Header_Host} = <<EOF;
\${h1("Editor de configura��es do Host \$host")}
<p>
Note: Marque Override se voc� quiser modificar um valor especificamente neste host.
<p>
EOF

$Lang{CfgEdit_Button_Save}     = "Salvar";
$Lang{CfgEdit_Button_Insert}   = "Inserir";
$Lang{CfgEdit_Button_Delete}   = "Excluir";
$Lang{CfgEdit_Button_Add}      = "Adicionar";
$Lang{CfgEdit_Button_Override} = "Sobrepor";
$Lang{CfgEdit_Button_New_Key}  = "New Key";
$Lang{CfgEdit_Button_New_Share} = "New ShareName or '*'";

$Lang{CfgEdit_Error_No_Save}
            = "ENG Error: No save due to errors";
$Lang{CfgEdit_Error__must_be_an_integer}
            = "Erro: \$var precisa ser um inteiro";
$Lang{CfgEdit_Error__must_be_real_valued_number}
            = "Erro: \$var precisa ser um n�mero com valor-real";
$Lang{CfgEdit_Error__entry__must_be_an_integer}
            = "Erro: \$var inserida \$k precisa ser um inteiro";
$Lang{CfgEdit_Error__entry__must_be_real_valued_number}
            = "Erro: \$var inserida \$k precisa ser um n�mero com valor-real";
$Lang{CfgEdit_Error__must_be_executable_program}
            = "Erro: \$var precisa ser um caminho execut�vel v�lido";
$Lang{CfgEdit_Error__must_be_valid_option}
            = "Erro: \$var precisa ser uma op��o v�lida";
$Lang{CfgEdit_Error_Copy_host_does_not_exist}
            = "Copia host \$copyHost n�o existe; criando nome de host completo \$fullHost.  Exclua este hosts se n�o for o que voc� deseja.";

$Lang{CfgEdit_Log_Copy_host_config}
            = "\$User configura��o copiada do host \$fromHost para \$host\n";
$Lang{CfgEdit_Log_Delete_param}
            = "\$User excluido \$p do \$conf\n";
$Lang{CfgEdit_Log_Add_param_value}
            = "\$User adicionado \$p para \$conf, marcado para \$value\n";
$Lang{CfgEdit_Log_Change_param_value}
            = "\$User alterado \$p em \$conf para \$valueNew de \$valueOld\n";
$Lang{CfgEdit_Log_Host_Delete}
            = "\$User excluido host \$host\n";
$Lang{CfgEdit_Log_Host_Change}
            = "\$User host \$host alterado \$key de \$valueOld para \$valueNew\n";
$Lang{CfgEdit_Log_Host_Add}
            = "\$User adicionado host \$host: \$value\n";
  
#end of lang_pt_BR.pm

