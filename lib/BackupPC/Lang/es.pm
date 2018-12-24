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

$Lang{Start_Archive} = "Iniciar archivado";
$Lang{Stop_Dequeue_Archive} = "Detener/quitar de cola el archivado";
$Lang{Start_Full_Backup} = "Iniciar copia de seguridad completa";
$Lang{Start_Incr_Backup} = "Iniciar copia de seguridad incremental";
$Lang{Stop_Dequeue_Backup} = "Detener/quitar de cola la copia de seguridad";
$Lang{Restore} = "Restaurar";

$Lang{Type_full} = "completo";
$Lang{Type_incr} = "incremental";

# -----

$Lang{Only_privileged_users_can_view_admin_options} = "S&oacute;lo los superusuarios pueden ver las opciones de administraci&oacute;n.";
$Lang{H_Admin_Options} = "Servidor BackupPC: Opciones de Administraci&oacute;n";
$Lang{Admin_Options} = "Opciones de Admin";
$Lang{Admin_Options_Page} = <<EOF;
\${h1(qq{$Lang{Admin_Options}})}
<br>
\${h2("Control del Servidor")}
<form name="ReloadForm" action="\$MyURL" method="get">
<input type="hidden" name="action" value="">
<table class="tableStnd">
  <tr><td>Actualizar configuraci&oacute;n del servidor:<td><input type="button" value="Reload"
     onClick="document.ReloadForm.action.value='Reload';
              document.ReloadForm.submit();">
</table>
</form>
<!--
\${h2("Server Configuration")}
<ul> 
  <li><i>Espacio para otras opciones... e.j.,</i>
  <li>Editar configuraci&oacute;n del servidor
</ul>
-->
EOF

$Lang{Unable_to_connect_to_BackupPC_server} = "Imposible conectar al servidor BackupPC";
$Lang{Unable_to_connect_to_BackupPC_server_error_message} = <<EOF;
Este script CGI (\$MyURL) no puede conectar al servidor BackupPC
en \$Conf{ServerHost} puerto \$Conf{ServerPort}.<br>
El error fu&eacute;: \$err.<br>
Quiz&aacute; el servidor BackupPC no est&aacute; activo o hay un
error de configuraci&oacute;n. Por favor informe a su administrador de sistemas.
EOF

$Lang{Admin_Start_Server} = <<EOF;
\${h1(qq{$Lang{Unable_to_connect_to_BackupPC_server}})}
<form action="\$MyURL" method="get">
El servidor BackupPC en <tt>\$Conf{ServerHost}</tt> port <tt>\$Conf{ServerPort}</tt>
no est&aacute; en funcionamiento ahora (puede haberlo detenido o no haberlo arrancado a&uacute;n).<br>
&iquest;Quiere inicializarlo?
<input type="hidden" name="action" value="startServer">
<input type="submit" value="Start Server" name="ignore">
</form>
EOF

# -----

$Lang{H_BackupPC_Server_Status} = "Estado del Servidor BackupPC";

$Lang{BackupPC_Server_Status_General_Info}= <<EOF;
\${h2(\"Informaci&oacute;n General del servidor\")}

<ul>
<li> El PID del servidor es \$Info{pid}, en el host \$Conf{ServerHost},
     version \$Info{Version}, iniciado el \$serverStartTime.
<li> Esta informaci&oacute;n de estado se ha generado el \$now.
<li> La &uacute;ltima configuraci&oacute;n ha sido cargada a las \$configLoadTime
<li> La cola de PC's se activar&aacute; de nuevo el \$nextWakeupTime.
<li> Informaci&oacute;n adicional:
    <ul>
        <li>\$numBgQueue solicitudes pendientes de copia de seguridad desde la &uacute;ltima activaci&oacute;n programada,
        <li>\$numUserQueue solicitudes pendientes de copia de seguridad de usuarios,
        <li>\$numCmdQueue solicitudes de comandos pendientes ,
        \$poolInfo
        <li>El sistema de archivos estaba recientemente al \$Info{DUlastValue}%
            (\$DUlastTime), el m&aacute;ximo de hoy es \$Info{DUDailyMax}% (\$DUmaxTime)
            y el m&aacute;ximo de ayer era \$Info{DUDailyMaxPrev}%.
        <li>Inode El sistema de archivos estaba recientemente al \$Info{DUInodelastValue}%
            (\$DUlastTime), el m&aacute;ximo de hoy es \$Info{DUInodeDailyMax}% (\$DUInodemaxTime)
            y el m&aacute;ximo de ayer era \$Info{DUInodeDailyMaxPrev}%.
    </ul>
</ul>
EOF

$Lang{BackupPC_Server_Status} = <<EOF;
\${h1(qq{$Lang{H_BackupPC_Server_Status}})}

<p>
\${h2("Trabajos en Ejecuci&oacute;n")}
<p>
<table class="tableStnd sortable" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td> Host </td>
    <td> Tipo </td>
    <td> Usuario </td>
    <td> Hora de Inicio </td>
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

\${h2("Fallas que Requieren Atenci&oacute;n")}
<p>
<table class="tableStnd sortable" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> Host </td>
    <td align="center"> Tipo </td>
    <td align="center"> Usuario </td>
    <td align="center"> Ultimo Intento </td>
    <td align="center"> Detalles </td>
    <td align="center"> Hora del error </td>
    <td> Ultimo error (diferente a no ping) </td></tr>
\$statusStr
</table>
EOF

# --------------------------------
$Lang{BackupPC__Server_Summary} = "BackupPC: Resumen del Servidor";
$Lang{BackupPC__Archive} = "BackupPC: Archivo";
$Lang{BackupPC_Summary}=<<EOF;

\${h1(qq{$Lang{BackupPC__Server_Summary}})}
<p>
<ul>
<li>Este status ha sido generado el \$now.
<li>El sistema de archivos estaba recientemente al \$Info{DUlastValue}%
    (\$DUlastTime), el m&aacute;ximo de hoy es \$Info{DUDailyMax}% (\$DUmaxTime)
    y el m&aacute;ximo de ayer era \$Info{DUDailyMaxPrev}%.
<li>Inode El sistema de archivos estaba recientemente al \$Info{DUInodelastValue}%
    (\$DUlastTime), el m&aacute;ximo de hoy es \$Info{DUInodeDailyMax}% (\$DUInodemaxTime)
    y el m&aacute;ximo de ayer era \$Info{DUInodeDailyMaxPrev}%.
</ul>
</p>

\${h2("Hosts con Buenas Copias de Seguridad")}
<p>
Hay \$hostCntGood hosts que tienen copia de seguridad, de un total de :
<ul>
<li> \$fullTot copias de seguridad completas con tama&ntilde;o total de \${fullSizeTot} GB
     (antes de agrupar y comprimir),
<li> \$incrTot copias de seguridad incrementales con tama&ntilde;o total de \${incrSizeTot} GB
     (antes de agrupar y comprimir).
</ul>
</p>

<table class="sortable" id="host_summary_backups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"> <td> Host </td>
    <td align="center"> Usuario </td>
    <td align="center"> Comentario </td>
    <td align="center"> # Completo </td>
    <td align="center"> Completo Antiguedad (d&iacute;as) </td>
    <td align="center"> Completo Tama&ntilde;o (GB) </td>
    <td align="center"> Velocidad (MB/s) </td>
    <td align="center"> # Incr </td>
    <td align="center"> Incr Antiguedad (D&iacute;as) </td>
    <td align="center"> Ultimo Backup (d&iacute;as) </td>
    <td align="center"> Estado </td>
    <td align="center"> Xfer errores </td>
    <td align="center"> Ultimo Intento </td></tr>
\$strGood
</table>
\${h2("Hosts Sin Copias de Seguridad")}
<p>
Hay \$hostCntNone hosts sin copias de seguridad.
<p>
<table class="sortable" id="host_summary_nobackups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"> <td> Host </td>
    <td align="center"> Usuario </td>
    <td align="center"> Comentario </td>
    <td align="center"> # Completo </td>
    <td align="center"> Completo Antiguedad (d&iacute;as) </td>
    <td align="center"> Completo Tama&ntilde;o (GB) </td>
    <td align="center"> Velocidad (MB/s) </td>
    <td align="center"> # Incr </td>
    <td align="center"> Incr Antiguedad (d&iacute;as) </td>
    <td align="center"> Ultimo Backup (d&iacute;as) </td>
    <td align="center"> Estado </td>
    <td align="center"> Xfer errores </td>
    <td align="center"> Ultimo Intento </td></tr>
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

Hay \$hostCntGood hosts que tienen copia de seguridad con un tama&ntilde;o total de \${fullSizeTot}GB
<p>
<form name="form1" method="post" action="\$MyURL">
<input type="hidden" name="fcbMax" value="\$checkBoxCnt">
<input type="hidden" name="type" value="1">
<input type="hidden" name="host" value="\${EscHTML(\$archHost)}">
<input type="hidden" name="action" value="Archive">
<table class="tableStnd" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td align=center> Host</td>
    <td align="center"> Usuario </td>
    <td align="center"> Tam&ntilde;o de Backup</td>
\$strGood
\$checkAllHosts
</table>
</form>
<p>

EOF

$Lang{BackupPC_Archive2} = <<EOF;
\${h1(qq{$Lang{BackupPC__Archive}})}
Se va a hacer copia de seguridad de los siguientes hosts
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
    <td>Ubicaci&oacute;n de archivo/Dispositivo</td>
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
    <td>Porcentaje de datos de paridad (0 = deshabilitado, 5 = normal)</td>
    <td><input type="numeric" value="\$ArchivePar" name="par"></td>
</tr>
EOF

$Lang{BackupPC_Archive2_split} = <<EOF;
<tr>
    <td>Dividir resultado en</td>
    <td><input type="numeric" value="\$ArchiveSplit" name="splitsize">Megabytes</td>
</tr>
EOF

# -----------------------------------
$Lang{Pool_Stat} = <<EOF;
        <li>El grupo tiene \${poolSize}GB incluyendo \$info->{"\${name}FileCnt"} archivos
            y \$info->{"\${name}DirCnt"} directorios (as of \$poolTime),
        <li>El procesamiento del grupo da \$info->{"\${name}FileCntRep"} archivos
            repetidos cuya cadena m&aacute;s larga es \$info->{"\${name}FileRepMax"},
        <li>El proceso de limpieza nocturna ha eliminado \$info->{"\${name}FileCntRm"} archivos de
            tama&ntilde;o \${poolRmSize}GB (around \$poolTime),
EOF

# --------------------------------
$Lang{BackupPC__Backup_Requested_on__host} = "BackupPC: Copia de Seguridad Solicitada en \$host";
$Lang{BackupPC__Delete_Requested_for_a_backup_of__host} = "BackupPC: Delete Requested for a backup of \$host";
# --------------------------------
$Lang{REPLY_FROM_SERVER} = <<EOF;
\${h1(\$str)}
<p>
La respuesta del servidor fu&eacute;: \$reply
<p>
Volver a <a href="\$MyURL?host=\$host">\$host home page</a>.
EOF
# --------------------------------
$Lang{BackupPC__Start_Backup_Confirm_on__host} = "BackupPC: Confirme inicio de copia de seguridad en \$host";
# --------------------------------
$Lang{Are_you_sure_start} = <<EOF;
\${h1("&iquest;Est&aacute; seguro?")}
<p>
Est&aacute; a punto de iniciar una copia de seguridad \$type en \$host.

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="hostIP" value="\$ipAddr">
<input type="hidden" name="doit" value="1">
<input type="hidden" name="action" value="">
&iquest;Realmente quiere hacer esto?
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="No" name="ignore">
</form>
EOF
# --------------------------------
$Lang{BackupPC__Stop_Backup_Confirm_on__host} = "BackupPC: Confirme Detener la Copia de Seguridad en \$host";
# --------------------------------
$Lang{Are_you_sure_stop} = <<EOF;

\${h1("&iquest;Est&aacute; seguro?")}

<p>
Est&aacute; a punto de detener/quitar de la cola las copias de seguridad en \$host;

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host"   value="\$host">
<input type="hidden" name="doit"   value="1">
<input type="hidden" name="action" value="">
Asimismo, por favor no empiece otra copia de seguridad durante
<input type="text" name="backoff" size="10" value="\$backoff"> horas.
<p>
&iquest;Realmente quiere hacer esto?
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="No" name="ignore">
</form>

EOF
# --------------------------------
$Lang{Only_privileged_users_can_view_queues_} = "S&oacute;lo los administradores pueden ver las colas.";
# --------------------------------
$Lang{Only_privileged_users_can_archive} = "S&oacute;lo los administradores pueden archivar.";
# --------------------------------
$Lang{BackupPC__Queue_Summary} = "BackupPC: Resumen de la Cola";
# --------------------------------
$Lang{Backup_Queue_Summary} = <<EOF;
\${h1("Resumen de la Cola de Copias de Seguridad")}
\${h2("Resumen de la Cola de Usuarios")}
<p>
Las siguientes solicitudes de usuarios est&aacute;n actualmente en cola:
</p>
<table class="tableStnd sortable" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Host </td>
    <td> Action </td>
    <td> Hora Solicitud </td>
    <td> Usuario </td></tr>
\$strUser
</table>

\${h2("Resumen de Cola en Segundo Plano")}
<p>
Las siguientes solicitudes en segundo plano est&aacute;n actualmente en cola:
</p>
<table class="tableStnd sortable" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Host </td>
    <td> Action </td>
    <td> Hora Solicitud </td>
    <td> Usuario </td></tr>
\$strBg
</table>
\${h2("Resumen de Cola de Comandos")}
<p>
Los siguientes comandos est&aacute;n actualmente en cola:
</p>
<table class="tableStnd sortable" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Host </td>
    <td> Action </td>
    <td> Hora Solicitud </td>
    <td> Usuario </td>
    <td> Comando </td></tr>
\$strCmd
</table>
EOF

# --------------------------------
$Lang{Backup_PC__Log_File__file} = "BackupPC: Archivo de Eventos \$file";
$Lang{Log_File__file__comment} = <<EOF;
\${h1("Archivo de Eventos \$file \$comment")}
<p>
EOF
# --------------------------------
$Lang{Contents_of_log_file} = <<EOF;
Contenido del archivo de eventos <tt>\$file</tt>, modificado \$mtimeStr \$comment
EOF

# --------------------------------
$Lang{skipped__skipped_lines} = "[ saltadas \$skipped lineas ]\n";
# --------------------------------
$Lang{_pre___Can_t_open_log_file__file} = "<pre>\nNo puedo abrir el archivo de eventos \$file\n";

# --------------------------------
$Lang{BackupPC__Log_File_History} = "BackupPC: Historial de Archivos de Eventos";
$Lang{Log_File_History__hdr} = <<EOF;
\${h1("Historial de Archivos de Eventos \$hdr")}
<p>
<table class="tableStnd sortable" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Archivo </td>
    <td align="center"> Tama&ntilde;o </td>
    <td align="center"> Hora Modificaci&oacute;n </td></tr>
\$str
</table>
EOF

# -------------------------------
$Lang{Recent_Email_Summary} = <<EOF;
\${h1("Resumen de Mensajes Recientes (Orden de tiempo inverso)")}
<p>
<table class="tableStnd sortable" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Destinatario </td>
    <td align="center"> Host </td>
    <td align="center"> Hora </td>
    <td align="center"> Asunto </td></tr>
\$str
</table>
EOF
 

# ------------------------------
$Lang{Browse_backup__num_for__host} = "BackupPC: Explorar Copia de Seguridad \$num de \$host";

# ------------------------------
$Lang{Restore_Options_for__host} = "BackupPC: Opciones de Restauraci&oacute;n para \$host";
$Lang{Restore_Options_for__host2} = <<EOF;
\${h1("Opciones de Restauraci&oacute;n para \$host")}
<p>
Ha seleccionado los siguientes archivos/directorios de
la unidad \$share, copia n&uacute;mero #\$num:
<ul>
\$fileListStr
</ul>
</p><p>
Tiene tres opciones para restaurar estos archivos/directorios.
Por favor, seleccione una de las siguientes opciones.
</p>
\${h2("Opci&oacute;n 1: Restauraci&oacute;n Directa")}
<p>
EOF

$Lang{Restore_Options_for__host_Option1} = <<EOF;
Puede empezar un proceso que restaurar&aacute; estos archivos directamente en
<b>\$directHost</b>.
</p><p>
<b>!Atenci&oacute;n!:</b> !Cualquier archivo existente con el mismo nombre que los que ha
seleccionado ser&aacute; sobreescrito!
</p>
<form action="\$MyURL" method="post" name="direct">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="3">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<table class="tableStnd" border="0">
<tr>
    <td>Restaurar los archivos al host</td>
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
    <td>Restaurar los archivos a la unidad</td>
    <td><input type="text" size="40" value="\${EscHTML(\$share)}"
	 name="shareDest"></td>
</tr><tr>
    <td>Restaurar los archivos bajo el directorio<br>(relativo a la unidad)</td>
    <td valign="top"><input type="text" size="40" maxlength="256"
	value="\${EscHTML(\$pathHdr)}" name="pathHdr"></td>
</tr><tr>
    <td><input type="submit" value="Start Restore" name="ignore"></td>
</table>
</form>
EOF

$Lang{Restore_Options_for__host_Option1_disabled} = <<EOF;
Se ha deshabilitado la restauraci&oacute;n directa para el host \${EscHTML(\$hostDest)}.
Por favor seleccione una de las otras opciones de restauraci&oacute;n.
EOF

# ------------------------------
$Lang{Option_2__Download_Zip_archive} = <<EOF;
<p>
\${h2("Opci&oacute;n 2: Descargar archivo Zip")}
<p>
Puede descargar un archivo comprimido (.zip) conteniendo todos los archivos y directorios que
ha seleccionado.  Despu&eacute;s puede hacer uso de una aplicaci&oacute;n local, como WinZip,
para ver o extraer cualquiera de los archivos.
</p><p>
<b>!Atenci&oacute;n!:</b> Dependiendo de que archivos/carpetas haya seleccionado,
este archivo puede ser muy grande. Podr&iacute;a tardar muchos minutos en
crear y transferir el archivo. Adem&aacute;s necesitar&aacute; suficiente espacio el el disco
local para almacenarlo.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="2">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Hacer archivo relativo
a \${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(en caso contrario el archivo contendr&aacute; las rutas completas).
<br>
<table class="tableStnd" border="0">
<tr>
    <td>Compresi&oacute;n (0=desactivada, 1=r&aacute;pida,...,9=mejor)</td>
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
\${h2("Opci&oacute;n 2: Descargar archivo Zip")}
<p>
El programa Archive::Zip no est&aacute; instalado, de modo que no podr&aacute; descargar un
archivo comprimido zip.
Por favor, solicite a su administrador de sistemas que instale Archive::Zip de
<a href="http://www.cpan.org">www.cpan.org</a>.
</p>
EOF


# ------------------------------
$Lang{Option_3__Download_Zip_archive} = <<EOF;
\${h2("Opci&oacute;n 3: Descargar archivo Tar")}
<p>
Puede descargar un archivo comprimido (.Tar) conteniendo todos los archivos y
directorios que ha seleccionado. Despu&eacute;s puede hacer uso de una aplicaci&oacute;n
local, como Tar o WinZip,para ver o extraer cualquiera de los archivos.
</p><p>
<b>!Atenci&oacute;n!:</b> Dependiendo de que archivos/carpetas haya seleccionado,
este archivo puede ser muy grande. Podr&iacute;a tardar muchos minutos
crear y transferir el archivo. Adem&aacute;s necesitar&aacute; suficiente espacio el el disco
local para almacenarlo.
</p>
<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="1">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<input type="checkbox" value="1" name="relative" checked> Hacer el archivo
relativo a \${EscHTML(\$pathHdr eq "" ? "/" : \$pathHdr)}
(en caso contrario el archivo contendr&aacute; las rutas completas).
<br>
<input type="submit" value="Download Tar File" name="ignore">
</form>
EOF


# ------------------------------
$Lang{Restore_Confirm_on__host} = "BackupPC: Confirme restauraci&oacute;n en \$host";

$Lang{Are_you_sure} = <<EOF;
\${h1("&iquest;Est&aacute; seguro?")}
<p>
Est&aacute; a punto de iniciar una restauraci&oacute;n directamente a la m&aacute;quina \$In{hostDest}.
Los siguientes archivos ser&aacute;n restaurados en la unidad \$In{shareDest}, de
la copia de seguridad n&uacute;mero \$num:
<p>
<table class="tableStnd" border>
<tr class="tableheader"><td>Archivo/Dir Original </td><td>Ser&aacute; restaurado a</td></tr>
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
&iquest;Realmente quiere hacer esto?
<input type="button" value="\$Lang->{Restore}"
 onClick="document.RestoreForm.action.value='Restore';
          document.RestoreForm.submit();">
<input type="submit" value="No" name="ignore">
</form>
EOF


# --------------------------
$Lang{Restore_Requested_on__hostDest} = "BackupPC: Restauraci&oacute;n solicitada en \$hostDest";
$Lang{Reply_from_server_was___reply} = <<EOF;
\${h1(\$str)}
<p>
La respuesta del servidor fu&eacute;: \$reply
<p>
volver a <a href="\$MyURL?host=\$hostDest">\$hostDest home page</a>.
EOF

$Lang{BackupPC_Archive_Reply_from_server} = <<EOF;
\${h1(\$str)}
<p>
La respuesta del servidor fu&eacute;: \$reply
EOF


# --------------------------------
$Lang{BackupPC__Delete_Backup_Confirm__num_of__host} = "BackupPC: Delete Backup Confirm #\$num of \$host";
# --------------------------------
$Lang{A_filled} = "a filled";
$Lang{An_unfilled} = "an unfilled";
$Lang{Are_you_sure_delete} = <<EOF;
\${h1("Are you sure?")}
<p>
You are about to delete \$filled \$type backup #\$num of \$host.

<form name="Confirm" action="\$MyURL" method="get">

<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">

<input type="hidden" name="doit" value="1">
<input type="hidden" name="action" value="">

Do you really want to do this?

<input type="button" value="\${EscHTML(\$Lang->{CfgEdit_Button_Delete})}"
 onClick="document.Confirm.action.value='deleteBackup';
          document.Confirm.submit();">

<input type="submit" value="No" name="ignore">
</form>
EOF

# -------------------------
$Lang{Host__host_Backup_Summary} = "BackupPC: Host \$host Resumen de Copia de Seguridad";

$Lang{Host__host_Backup_Summary2} = <<EOF;
\${h1("Host \$host Res&uacute;men de Copia de Seguridad")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>
</p>
\${h2("Acciones del Usuario")}
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
\${h2("Resumen de Copia de Seguridad")}
<p>
Haga click en el n&uacute;mero de copia de seguridad para revisar y restaurar archivos.
</p>
<table class="tableStnd sortable" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> Copia N&deg; </td>
    <td align="center"> Tipo </td>
    <td align="center"> Completo </td>
    <td align="center"> Nivel </td>
    <td align="center"> Fecha Inicio </td>
    <td align="center"> Duraci&oacute;n/min </td>
    <td align="center"> Antiguedad/d&iacute;as </td>
    \$deleteHdrStr
    <td align="center"> Ruta a la Copia en Servidor </td>
</tr>
\$str
</table>
<p>

\$restoreStr
</p>
\${h2("Resumen de Errores de Transferencia")}
<table class="tableStnd sortable" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Copia N&deg; </td>
    <td align="center"> Tipo </td>
    <td align="center"> Ver </td>
    <td align="center"> N&deg; Xfer errs </td>
    <td align="center"> N&deg; err. archivos </td>
    <td align="center"> N&deg; err. unidades </td>
    <td align="center"> N&deg; err. tar </td>
</tr>
\$errStr
</table>

\${h2("Resumen de Total/Tama&ntilde;o de Archivos Reutilizados")}
<p>
Los archivos existentes son aquellos que ya est&aacute;n en el lote; los nuevos son
aquellos que se han a&ntilde;adido al lote.
Los archivos vac&iacute;os y los errores SMB no cuentan en las cifras de reutilizados
ni en la de nuevos.
</p>
<table class="tableStnd sortable" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="2" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> Totales </td>
    <td align="center" colspan="2"> Archivos Existentes </td>
    <td align="center" colspan="2"> Archivos Nuevos </td>
</tr>
<tr class="tableheader sortheader">
    <td align="center"> Copia N&deg; </td>
    <td align="center"> Tipo </td>
    <td align="center"> N&deg; Archivos </td>
    <td align="center"> Tama&ntilde;o/MB </td>
    <td align="center"> MB/sg </td>
    <td align="center"> N&deg; Archivos </td>
    <td align="center"> Tama&ntilde;o/MB </td>
    <td align="center"> N&deg; Archivos </td>
    <td align="center"> Tama&ntilde;o/MB </td>
</tr>
\$sizeStr
</table>

\${h2("Resumen de Compresi&oacute;n")}
<p>
Efectividad de compresi&oacute;n para los archivos ya existentes en el lote y los
archivos nuevos comprimidos.
</p>
<table class="tableStnd sortable" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="3" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> Archivos Existentes </td>
    <td align="center" colspan="3"> Archivos Nuevos </td>
</tr>
<tr class="tableheader sortheader"><td align="center"> Copia N&deg; </td>
    <td align="center"> Tipo </td>
    <td align="center"> Nivel Comp </td>
    <td align="center"> Tama&ntilde;o/MB </td>
    <td align="center"> Comp/MB </td>
    <td align="center"> Comp </td>
    <td align="center"> Tama&ntilde;o/MB </td>
    <td align="center"> Comp/MB </td>
    <td align="center"> Comp </td>
</tr>
\$compStr
</table>
EOF

$Lang{Host__host_Archive_Summary} = "BackupPC: Host \$host Archive Summary";
$Lang{Host__host_Archive_Summary2} = <<EOF;
\${h1("Resumen de archivo del Host \$host")}
<p>
\$warnStr
<ul>
\$statusStr
</ul>

\${h2("Acciones de usuario")}
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
$Lang{NavSectionTitle_} = "Servidor";

# -------------------------
$Lang{Backup_browse_for__host} = <<EOF;
\${h1("Explorar Copia de Seguridad de \$host")}

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
<li> Est&aacute; revisando la copia de seguridad N&deg;\$num, que comenz&oacute; hacia las \$backupTime
        (hace \$backupAge d&iacute;as),
\$filledBackup
<li> Introduzca el directorio: <input type="text" name="dir" size="50" maxlength="4096" value="\${EscHTML(\$dir)}"> <input type="submit" value="\$Lang->{Go}" name="Submit">
<li> Haga click en uno de los directorios de abajo para revisar sus contenidos,
<li> Haga click en un archivo para restaurarlo,
<li> Puede ver la <a href="\$MyURL?action=dirHistory&host=\${EscURI(\$host)}&share=\$shareURI&dir=\$pathURI">history</a> de la copia de seguridad del directorio actual.
</ul>
</form>

\${h2("Contenido de \$dirDisplay")}
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
$Lang{DirHistory_backup_for__host} = "BackupPC: Hist&oacute;rico de copia de seguridad del directorio en \$host";

#
# These two strings are used to build the links for directories and
# file versions.  Files are appended with a version number.
#
$Lang{DirHistory_dirLink}  = "dir";
$Lang{DirHistory_fileLink} = "v";

$Lang{DirHistory_for__host} = <<EOF;
\${h1("Hist&oacute;rico de copia de seguridad del directorio en \$host")}
<p>
Esta pantalla muestra cada versi&oacute;n &uacute;nica de archivos de entre todas
las copias de seguridad:
<ul>
<li> Haga click en un n&uacute;mero de copia de seguridad para volver al explorador de copias de seguridad,
<li> Haga click en un v&iacute;nculo de directorio (\$Lang->{DirHistory_dirLink}) para navegar
     en ese directorio,
<li> Haga click en un v&iacute;nculo de versi&oacute;n de archivo (\$Lang->{DirHistory_fileLink}0,
     \$Lang->{DirHistory_fileLink}1, ...) para descargar ese archivo,
<li> Los archivos con diferentes contenidos entre distintas copias de seguridad tienen el mismo
     n&uacute;mero de versi&oacute;n (PleaseTranslateThis: except between v3 and v4 backups),
<li> Los archivos o directorios que no existen en una copia concreta tienen una
     celda vac&iacute;a.
<li> Los archivos mostrados con la misma versi&oacute;n pueden tener diferentes atributos.
     Seleccione el n&uacute;mero de copia de seguridad para ver los atributos del archivo.
</ul>

\${h2("Historia de \$dirDisplay")}

<br>
<table border cellspacing="2" cellpadding="3">
<tr class="fviewheader"><td>N&uacute;mero de Backup</td>\$backupNumStr</tr>
<tr class="fviewheader"><td>Hora de Backup</td>\$backupTimeStr</tr>
\$fileStr
</table>
EOF

# ------------------------------
$Lang{Restore___num_details_for__host} = "BackupPC: Detalles de la restauraci&oacute;n N&deg;\$num de \$host";

$Lang{Restore___num_details_for__host2} = <<EOF;
\${h1("Detalles de la restauraci&oacute;n N&deg;\$num de \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="90%">
<tr><td class="tableheader"> N&uacute;mero </td><td class="border"> \$Restores[\$i]{num} </td></tr>
<tr><td class="tableheader"> Solicitado por </td><td class="border"> \$RestoreReq{user} </td></tr>
<tr><td class="tableheader"> Hora Petici&oacute;n </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> Resultado </td><td class="border"> \$Restores[\$i]{result} </td></tr>
<tr><td class="tableheader"> Mensaje de Error </td><td class="border"> \$Restores[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> Host Origen </td><td class="border"> \$RestoreReq{hostSrc} </td></tr>
<tr><td class="tableheader"> N&deg; copia origen </td><td class="border"> \$RestoreReq{num} </td></tr>
<tr><td class="tableheader"> Unidad origen </td><td class="border"> \$RestoreReq{shareSrc} </td></tr>
<tr><td class="tableheader"> Host destino </td><td class="border"> \$RestoreReq{hostDest} </td></tr>
<tr><td class="tableheader"> Unidad destino </td><td class="border"> \$RestoreReq{shareDest} </td></tr>
<tr><td class="tableheader"> Hora comienzo </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Duraci&oacute;n </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> N&uacute;mero de archivos </td><td class="border"> \$Restores[\$i]{nFiles} </td></tr>
<tr><td class="tableheader"> Tama&ntilde;o total </td><td class="border"> \${MB} MB </td></tr>
<tr><td class="tableheader"> Tasa de transferencia </td><td class="border"> \$MBperSec MB/sec </td></tr>
<tr><td class="tableheader"> Errores creaci&oacute;n Tar </td><td class="border"> \$Restores[\$i]{tarCreateErrs} </td></tr>
<tr><td class="tableheader"> Errores de transferencia </td><td class="border"> \$Restores[\$i]{xferErrs} </td></tr>
<tr><td class="tableheader"> Archivo eventos de transferencia </td><td class="border">
<a href="\$MyURL?action=view&type=RestoreLOG&num=\$Restores[\$i]{num}&host=\$host">View</a>,
<a href="\$MyURL?action=view&type=RestoreErr&num=\$Restores[\$i]{num}&host=\$host">Errors</a>
</tr></tr>
</table>
</p>
\${h1("Lista de Archivos/Directorios")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="100%">
<tr class="tableheader"><td>Dir/archivo original</td><td>Restaurado a</td></tr>
\$fileListStr
</table>
EOF

# ------------------------------
$Lang{Archive___num_details_for__host} = "BackupPC: Copia de seguridad #\$num .Detalles de \$host";

$Lang{Archive___num_details_for__host2 } = <<EOF;
\${h1("Copia de seguridad #\$num Detalles de \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr><td class="tableheader"> N&uacute;mero </td><td class="border"> \$Archives[\$i]{num} </td></tr>
<tr><td class="tableheader"> Solicitado por </td><td class="border"> \$ArchiveReq{user} </td></tr>
<tr><td class="tableheader"> Hora petici&oacute;n </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> Resultado </td><td class="border"> \$Archives[\$i]{result} </td></tr>
<tr><td class="tableheader"> Mensaje de error </td><td class="border"> \$Archives[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> Hora comienzo </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Duraci&oacute;n </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> Archivo eventos Xfer </td><td class="border">
<a href="\$MyURL?action=view&type=ArchiveLOG&num=\$Archives[\$i]{num}&host=\$host">View</a>,
<a href="\$MyURL?action=view&type=ArchiveErr&num=\$Archives[\$i]{num}&host=\$host">Errors</a>
</tr></tr>
</table>
<p>
\${h1("Host list")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td>Host</td><td>Copia de seguridad n&uacute;mero</td></tr>
\$HostListStr
</table>
EOF

# -----------------------------------
$Lang{Email_Summary} = "BackupPC: Resumen de Correos";

# -----------------------------------
#  !! ERROR messages !!
# -----------------------------------
$Lang{BackupPC__Lib__new_failed__check_apache_error_log} = "BackupPC::Lib->nuevo ha fallado: revise el error_log de apache\n";
$Lang{Wrong_user__my_userid_is___} =  
              "Usuario err&oacute;neo: mi userid es \$>, en lugar de \$uid"
            . "(\$Conf{BackupPCUser})\n";
# $Lang{Only_privileged_users_can_view_PC_summaries} = "S&oacute;lo los usuarios autorizados pueden ver los res&uacute;menes de PC's.";
$Lang{Only_privileged_users_can_stop_or_start_backups} = 
                  "S&oacute;lo los usuarios autorizados pueden iniciar o detener las copias de seguridad en"
		. " \${EscHTML(\$host)}.";
$Lang{Invalid_number__num} = "N&uacute;mero no v&aacute;lido \${EscHTML(\$In{num})}";
$Lang{Unable_to_open__file__configuration_problem} = "No puedo abrir \$file: &iquest;problema de configuraci&oacute;n?";
$Lang{Only_privileged_users_can_view_log_or_config_files} = "S&oacute;lo los usuarios autorizados pueden ver los archivos de eventos o de configuraci&oacute;n.";
$Lang{Only_privileged_users_can_view_log_files} = "S&oacute;lo los usuarios autorizados pueden ver los archivos de eventos.";
$Lang{Only_privileged_users_can_view_email_summaries} = "S&oacute;lo los usuarios autorizados pueden ver res&uacute;menes de correo.";
$Lang{Only_privileged_users_can_browse_backup_files} = "S&oacute;lo los usuarios autorizados pueden revisar los archivos de las copias de seguridad"
                . " para el Host \${EscHTML(\$In{host})}.";
$Lang{Only_privileged_users_can_delete_backups} = "Only privileged users can delete backups"
                . " of host \${EscHTML(\$host)}.";
$Lang{Empty_host_name} = "Nombre de Host vac&iacute;o.";
$Lang{Directory___EscHTML} = "El directorio \${EscHTML(\"\$TopDir/pc/\$host/\$num\")}"
		    . " est&aacute; vac&iacute;o";
$Lang{Can_t_browse_bad_directory_name2} = "No puedo mostrar un nombre de directorio err&oacute;neo"
	            . " \${EscHTML(\$relDir)}";
$Lang{Only_privileged_users_can_restore_backup_files} = "S&oacute;lo los usuarios autorizados pueden restaurar copias de seguridad"
                . " para el host \${EscHTML(\$In{host})}.";
$Lang{Bad_host_name} = "Nombre de Host err&oacute;neo \${EscHTML(\$host)}";
$Lang{You_haven_t_selected_any_files__please_go_Back_to} = "No ha seleccionado nig&uacute;n archivo; por favor, vuelva a"
                . " seleccione algunos archivos.";
$Lang{You_haven_t_selected_any_hosts} = "No ha seleccionado ning&uacute;n host; por favor vuelva a"
                . " seleccione algunos hosts.";
$Lang{Nice_try__but_you_can_t_put} = "Buen intento, pero no puede usar \'..\' en los nombres de archivo";
$Lang{Host__doesn_t_exist} = "El Host \${EscHTML(\$In{hostDest})} no existe";
$Lang{You_don_t_have_permission_to_restore_onto_host} = "No tiene autorizaci&oacute;n para restaurar en el host"
		    . " \${EscHTML(\$In{hostDest})}";
$Lang{Can_t_open_create__openPath} = "No puedo abrir/crear "
		. "\${EscHTML(\"\$openPath\")}";
$Lang{Only_privileged_users_can_restore_backup_files2} = "S&oacute;lo los usuarios autorizados pueden restaurar copias de seguridad"
                . " del host \${EscHTML(\$host)}.";
$Lang{Empty_host_name} = "Nombre de host vac&iacute;o";
$Lang{Unknown_host_or_user} = "Host o usuario desconocido \${EscHTML(\$host)}";
$Lang{Only_privileged_users_can_view_information_about} = "S&oacute;lo los usuarios autorizados pueden ver informaci&oacute;n del"
                . " host \${EscHTML(\$host)}." ;
$Lang{Only_privileged_users_can_view_archive_information} = "S&oacute;lo los usuarios autorizados pueden ver informaci&oacute;n de archivo.";
$Lang{Only_privileged_users_can_view_restore_information} = "S&oacute;lo los usuarios autorizados pueden ver informaci&oacute;n de restauraci&oacute;n.";
$Lang{Restore_number__num_for_host__does_not_exist} = "El n&uacute;mero de restauraci&oacute;n \$num del host \${EscHTML(\$host)} "
	        . " no existe.";
$Lang{Archive_number__num_for_host__does_not_exist} = "La copia de seguridad \$num del host \${EscHTML(\$host)} "
                . " no existe.";
$Lang{Can_t_find_IP_address_for} = "No puedo encontrar la direcci&oacute;n IP de \${EscHTML(\$host)}";
$Lang{host_is_a_DHCP_host} = <<EOF;
\$host es un host DHCP y no conozco su direcci&oacute;n IP. He comprobado el
nombre netbios de \$ENV{REMOTE_ADDR}\$tryIP, y he verificado que esa m&aacute;quina
no es \$host.
<p>
Hasta que vea \$host en una direcci&oacute;n DHCP concreta, s&oacute;lo puede
iniciar este proceso desde la propia m&aacute;quina cliente.
EOF

# ------------------------------------
# !! Server Mesg !!
# ------------------------------------

$Lang{Backup_requested_on_DHCP__host} = "Copia de seguridad solicitada en DHCP \$host (\$In{hostIP}) por"
		                      . " \$User desde \$ENV{REMOTE_ADDR}";
$Lang{Backup_requested_on__host_by__User} = "Copia de seguridad solicitada en \$host por \$User";
$Lang{Backup_stopped_dequeued_on__host_by__User} = "Copia de seguridad detenida/desprogramada en \$host por \$User";
$Lang{Restore_requested_to_host__hostDest__backup___num} = "Restauraci&oacute;n solicitada para el host \$hostDest, copia de seguridad #\$num,"
	     . " por \$User desde \$ENV{REMOTE_ADDR}";
$Lang{Delete_requested_for_backup_of__host_by__User} = "Delete requested for backup #\$num of \$host"
             . " by \$User from \$ENV{REMOTE_ADDR}";
$Lang{Archive_requested} = "Archivo solicitado por \$User desde \$ENV{REMOTE_ADDR}";

# -------------------------------------------------
# ------- Stuff that was forgotten ----------------
# -------------------------------------------------

$Lang{Status} = "Estado";
$Lang{PC_Summary} = "Resumen de Hosts";
$Lang{LOG_file} = "Archivo de eventos";
$Lang{LOG_files} = "Archivos de eventos";
$Lang{Old_LOGs} = "Eventos antiguos";
$Lang{Email_summary} = "Resumen correo";
$Lang{Config_file} = "Archivo configuraci&oacute;n";
# $Lang{Hosts_file} = "Archivo Hosts";
$Lang{Current_queues} = "Colas actuales";
$Lang{Documentation} = "Documentaci&oacute;n";

#$Lang{Host_or_User_name} = "<small>Host o usuario:</small>";
$Lang{Go} = "Aceptar";
$Lang{Hosts} = "Hosts";
$Lang{Select_a_host} = "Seleccione un host...";

$Lang{There_have_been_no_archives} = "<h2> No ha habido archivos </h2>\n";
$Lang{This_PC_has_never_been_backed_up} = "<h2> !Nunca se ha hecho copia de seguridad de este Host! </h2>\n";
$Lang{This_PC_is_used_by} = "<li>Este Host es utilizado por \${UserLink(\$user)}";

$Lang{Extracting_only_Errors} = "(Extrayendo s&oacute;lo Errores)";
$Lang{XferLOG} = "TransfREG";
$Lang{Errors}  = "Errores";

# ------------
$Lang{Last_email_sent_to__was_at___subject} = <<EOF;
<li>El &uacute;ltimo mensaje enviado a  \${UserLink(\$user)} fu&eacute; a las \$mailTime, asunto "\$subj".
EOF
# ------------
$Lang{The_command_cmd_is_currently_running_for_started} = <<EOF;
<li>El comando \$cmd est&aacute; ejecutandose para \$host, comenzado a \$startTime.
EOF

# -----------
$Lang{Host_host_is_queued_on_the_background_queue_will_be_backed_up_soon} = <<EOF;
<li>El host \$host est&aacute; en cola en la cola en segundo plano (pronto tendr&aacute; copia de seguridad).
EOF

# ----------
$Lang{Host_host_is_queued_on_the_user_queue__will_be_backed_up_soon} = <<EOF;
<li>Host \$host est&aacute; en cola en la cola de usuarios (pronto tendr&aacute; copia de seguridad).
EOF

# ---------
$Lang{A_command_for_host_is_on_the_command_queue_will_run_soon} = <<EOF;
<li>Un comando para \$host est&aacute; en la cola de comandos (se ejecutar&aacute; pronto).
EOF

# --------
$Lang{Last_status_is_state_StatusHost_state_reason_as_of_startTime} = <<EOF;
<li>El &uacute;ltimo estado fu&eacute; \"\$Lang->{\$StatusHost{state}}\"\$reason a las \$startTime.
EOF

# --------
$Lang{Last_error_is____EscHTML_StatusHost_error} = <<EOF;
<li>El &uacute;ltimo error fu&eacute; \"\${EscHTML(\$StatusHost{error})}\".
EOF

# ------
$Lang{Pings_to_host_have_failed_StatusHost_deadCnt__consecutive_times} = <<EOF;
<li>Los pings a \$host han fallado \$StatusHost{deadCnt} veces consecutivas.
EOF

# -----
$Lang{Prior_to_that__pings} = "Antes de eso, pings";

# -----
$Lang{priorStr_to_host_have_succeeded_StatusHostaliveCnt_consecutive_times} = <<EOF;
<li>\$priorStr a \$host han tenido &eacute;xito \$StatusHost{aliveCnt}
        veces consecutivas.
EOF

$Lang{Because__host_has_been_on_the_network_at_least__Conf_BlackoutGoodCnt_consecutive_times___} = <<EOF;
<li>Dado que \$host ha estado en la red al menos \$Conf{BlackoutGoodCnt}
veces consecutivas, no se le realizar&aacute; copia de seguridad desde \$blackoutStr.
EOF

$Lang{__time0_to__time1_on__days} = "\$t0 hasta \$t1 en \$days";

$Lang{Backups_are_deferred_for_hours_hours_change_this_number} = <<EOF;
<li>Las copias de seguridad se retrasar&aacute;n durante \$hours horas
(<a href=\"\$MyURL?action=Stop_Dequeue_Backup&host=\$host\">Cambie este n&uacute;mero</a>).
EOF

$Lang{tryIP} = " y \$StatusHost{dhcpHostIP}";

#$Lang{Host_Inhost} = "Host \$In{host}";

$Lang{checkAll} = <<EOF;
<tr><td class="fviewborder">
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;Seleccionar todo
</td><td colspan="5" align="center" class="fviewborder">
<input type="submit" name="Submit" value="Restaurar los archivos seleccionados">
</td></tr>
EOF

$Lang{checkAllHosts} = <<EOF;
<tr><td class="fviewborder">
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;Seleccionar todo
</td><td colspan="2" align="center" class="fviewborder">
<input type="submit" name="Submit" value="Archivar los hosts seleccionados">
</td></tr>
EOF

$Lang{fileHeader} = <<EOF;
    <tr class="fviewheader"><td align=center> Nombre</td>
       <td align="center"> Tipo</td>
       <td align="center"> Modo</td>
       <td align="center"> N&deg;</td>
       <td align="center"> Tama&ntilde;o</td>
       <td align="center"> Hora Mod.</td>
    </tr>
EOF

$Lang{Home} = "Inicio";
$Lang{Browse} = "Explorar copias de seguridad";
$Lang{Last_bad_XferLOG} = "Ultimo error en eventos de transferencia";
$Lang{Last_bad_XferLOG_errors_only} = "Ultimo error en eventos de transferencia (errores&nbsp;s&oacute;lo)";

$Lang{This_display_is_merged_with_backup} = <<EOF;
<li> Esta pantalla est&aacute; unida a la copia de seguridad N&deg;\$numF.
EOF

$Lang{Visit_this_directory_in_backup} = <<EOF;
<li> Seleccione la copia de seguridad que desea ver: <select onChange="window.location=this.value">\$otherDirs </select>
EOF

$Lang{Restore_Summary} = <<EOF;
\${h2("Resumen de Restauraci&oacute;n")}
<p>
Haga click en el n&uacute;mero de restauraci&oacute;n para ver sus detalles.
<table class="tableStnd sortable" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Restauraci&oacute;n N&deg; </td>
    <td align="center"> Resultado </td>
    <td align="right"> Fecha Inicio</td>
    <td align="right"> Dur/mins</td>
    <td align="right"> N&deg; Archivos </td>
    <td align="right"> MB </td>
    <td align="right"> N&deg; Err. Tar </td>
    <td align="right"> N&deg; Err. Transf.#xferErrs </td>
</tr>
\$restoreStr
</table>
<p>
EOF

$Lang{Archive_Summary} = <<EOF;
\${h2("Archive Summary")}
<p>
Hacer Click en el n&uacute;mero de Archivo para m&aacute;s detalles.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Archive# </td>
    <td align="center"> Resultado </td>
    <td align="right"> Hora inicio</td>
    <td align="right"> Duraci&oacute;n/mins</td>
</tr>
\$ArchiveStr
</table>
<p>
EOF

$Lang{BackupPC__Documentation} = "BackupPC: Documentacion";

$Lang{No} = "no";
$Lang{Yes} = "si";

$Lang{The_directory_is_empty} = <<EOF;
<tr><td bgcolor="#ffffff">El directorio \$dirDisplay est&aacute; vac&iacute;o
</td></tr>
EOF

#$Lang{on} = "activo";
$Lang{off} = "inactivo";

$Lang{backupType_full}    = "completo";
$Lang{backupType_incr}    = "incremental";
$Lang{backupType_active}  = "active";
$Lang{backupType_partial} = "parcial";

$Lang{failed} = "fallido";
$Lang{success} = "&eacute;xito";
$Lang{and} = "y";

# ------
# Hosts states and reasons
$Lang{Status_idle} = "inactivo";
$Lang{Status_backup_starting} = "comenzando copia de seguridad";
$Lang{Status_backup_in_progress} = "copia de seguridad ejecut&aacute;ndose";
$Lang{Status_restore_starting} = "comenzando restauraci&oacute;n";
$Lang{Status_restore_in_progress} = "restauraci&oacute;n ejecut&aacute;ndose";
$Lang{Status_admin_pending} = "conexi&oacute;n pendiente";
$Lang{Status_admin_running} = "conexi&oacute;n en curso";

$Lang{Reason_backup_done} = "copia de seguridad realizada";
$Lang{Reason_restore_done} = "restauraci&oacute;n realizada";
$Lang{Reason_archive_done}   = "archivado realizado";
$Lang{Reason_nothing_to_do} = "nada por hacer";
$Lang{Reason_backup_failed} = "copia de seguridad fallida";
$Lang{Reason_restore_failed} = "restauraci&oacute;n fallida";
$Lang{Reason_archive_failed} = "ha fallado el archivado";
$Lang{Reason_no_ping} = "no hay ping";
$Lang{Reason_backup_canceled_by_user} = "copia cancelada por el usuario";
$Lang{Reason_restore_canceled_by_user} = "restauraci&oacute;n cancelada por el usuario";
$Lang{Reason_archive_canceled_by_user} = "archivado cancelado por el usuario";
$Lang{Disabled_OnlyManualBackups}  = "auto deshabilitado";  
$Lang{Disabled_AllBackupsDisabled} = "deshabilitado";                  

# ---------
# Email messages

# No backup ever
$Lang{EMailNoBackupEverSubj} = "BackupPC: ning&uacute;na copia de \$host ha tenido &eacute;xito";
$Lang{EMailNoBackupEverMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
Estimado $userName,

Su PC ($host) nunca ha completado una copia de seguridad mediante nuestro
programa de copias de seguridad. Las copias de seguridad deber&iacute;an ejecutarse
autom&aacute;ticamente cuando su PC se conecta a la red. Deber&iacute;a contactar con su
soporte t&eacute;cnico si:

  - Su ordenador ha estado conectado a la red con regularidad. Esto implicar&iacute;a
    que existe alg&uacute;n problema de instalaci&oacute;n o configuraci&oacute;n que impide que se
    realicen las copias de seguridad.

  - No desea realizar copias de seguridad y no quiere recibir m&aacute;s mensajes
    como &eacute;ste.

De no ser as&iacute;, aseg&uacute;rese de que su PC est&aacute; conectado a la red la pr&oacute;xima vez
que est&eacute; en la oficina.

Saludos:
Agente BackupPC
https://backuppc.github.io/backuppc
EOF

# No recent backup
$Lang{EMailNoBackupRecentSubj} = "BackupPC: no hay copias de seguridad recientes de \$host";
$Lang{EMailNoBackupRecentMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
Estimado $userName,

No se ha podido completar ninguna copia de seguridad de su PC ($host) durante
$days d&iacute;as.
Su PC ha realizado copias de seguridad correctas $numBackups veces desde
$firstTime hasta hace $days d&iacute;as.
Las copias de seguridad deber&iacute;an efectuarse autom&aacute;ticamente cuando su PC est&aacute;
conectado a la red.

Si su PC ha estado conectado durante algunas horas a la red durante los &uacute;ltimos
$days d&iacute;as deber&iacute;a contactar con su soporte t&eacute;cnico para ver porqu&eacute; las copias
de seguridad no funcionan adecuadamente.

Por otro lado, si est&aacute; fuera de la oficina, no hay mucho que se pueda hacer al
respecto salvo copiar manualmente los archivos especialmente cr&iacute;ticos a otro
soporte f&iacute;sico. Deber&iacute;a estar al corriente de que cualquier archivo que haya
creado o modificado en los &uacute;ltimos $days d&iacute;as (incluyendo todo el correo nuevo
y archivos adjuntos) no pueden ser restaurados si su disco se aver&iacute;a.

Saludos:
Agente BackupPC
https://backuppc.github.io/backuppc
EOF

# Old Outlook files
$Lang{EMailOutlookBackupSubj} = "BackupPC: Los archivos de Outlook de \$host necesitan ser copiados";
$Lang{EMailOutlookBackupMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
Estimado $userName,





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
----------------------------------------------------------------
Los archivos de Outlook de su PC tienen $howLong.
Estos archivos contienen todo su correo, adjuntos, contactos e informaci&oacute;n de
su agenda. Los archivos de su PC han sido correctamente salvaguardados $numBackups veces 
desde $firstTime hasta hace $lastTime d&iacute;as. Sin embargo, Outlook bloquea todos 
sus archivos mientras funciona, impidiendo que pueda hacerse una copia de seguridad de
los mismos.

Se le recomienda hacer copia de seguridad de los archivos de Outlook cuando est&eacute;
conectado a la red cerrando Outlook y el resto de aplicaciones y utilizando su
navegador de internet haga click en este v&iacute;nculo:

    $CgiURL?host=$host               

Seleccione "Iniciar copia de seguridad incremental" dos veces para iniciar
una neva copia de seguridad incremental.
Puede seleccionar "Volver a la p&aacute;gina de $host " y luego de click en "refrescar"
para verificar el estado del proceso de copia de seguridad. Deber&iacute;a llevarle s&oacute;lo unos pocos minutos completar el proceso.

Saludos:
Agente BackupPC
https://backuppc.github.io/backuppc
EOF

$Lang{howLong_not_been_backed_up} = "no se le ha realizado una copia de seguridad con &eacute;xito";
$Lang{howLong_not_been_backed_up_for_days_days} = "no se le ha realizado una copia de seguridad durante \$days d&iacute;as";

#######################################################################
# RSS strings
#######################################################################
$Lang{RSS_Doc_Title}       = "Servidor BackupPC";
$Lang{RSS_Doc_Description} = "RSS feed para BackupPC";
$Lang{RSS_Host_Summary}    = <<EOF;
#Completo: \$fullCnt;
Completo Antig./D&iacute;as: \$fullAge;
Completo Tama&ntilde;o/GB: \$fullSize;
Velocidad MB/sec: \$fullRate;
#Incrementales: \$incrCnt;
Incrementales Antig/D&iacute;as: \$incrAge;
Estado: \$host_state;
Discapacitado: \$host_disabled;
Ultimo Intento: \$host_last_attempt;
EOF

#######################################################################
# Configuration editor strings (all ENGLISH currently)
#######################################################################

$Lang{Only_privileged_users_can_edit_config_files} = "S&oacute;lo los usuarios con privilegios pueden editar los valores de configuraci&oacute;n.";
$Lang{CfgEdit_Edit_Config} = "Editar Configuraci&oacute;n";
$Lang{CfgEdit_Edit_Hosts}  = "Editar Hosts";

$Lang{CfgEdit_Title_Server} = "Servidor";
$Lang{CfgEdit_Title_General_Parameters} = "Par&aacute;metros Generales";
$Lang{CfgEdit_Title_Wakeup_Schedule} = "Horario de Activaci&oacute;n";
$Lang{CfgEdit_Title_Concurrent_Jobs} = "Trabajos Concurrentes";
$Lang{CfgEdit_Title_Pool_Filesystem_Limits} = "L&iacute;mites de Sistema de Archivos Pool";
$Lang{CfgEdit_Title_Other_Parameters} = "Otros Par&aacute;metros";
$Lang{CfgEdit_Title_Remote_Apache_Settings} = "Opciones de Apache Remoto";
$Lang{CfgEdit_Title_Program_Paths} = "Rutas de Programa";
$Lang{CfgEdit_Title_Install_Paths} = "Rutas de Instalaci&oacute;n";
$Lang{CfgEdit_Title_Email} = "Email";
$Lang{CfgEdit_Title_Email_settings} = "Opciones de Email";
$Lang{CfgEdit_Title_Email_User_Messages} = "Email Mensajes de Usuario";
$Lang{CfgEdit_Title_CGI} = "CGI";
$Lang{CfgEdit_Title_Admin_Privileges} = "Privilegios Administrador";
$Lang{CfgEdit_Title_Page_Rendering} = "Representaci&oacute;n de P&aacute;gina";
$Lang{CfgEdit_Title_Paths} = "Rutas";
$Lang{CfgEdit_Title_User_URLs} = "URLs de Usuario";
$Lang{CfgEdit_Title_User_Config_Editing} = "Editando Configuraci&oacute;n de Usuario";
$Lang{CfgEdit_Title_Xfer} = "Transferencia";
$Lang{CfgEdit_Title_Xfer_Settings} = "Opciones de Transferencia";
$Lang{CfgEdit_Title_Ftp_Settings} = "Opciones de FTP";
$Lang{CfgEdit_Title_Smb_Settings} = "Opciones de Smb";
$Lang{CfgEdit_Title_Tar_Settings} = "Opciones de Tar";
$Lang{CfgEdit_Title_Rsync_Settings} = "Opciones de Rsync";
$Lang{CfgEdit_Title_Rsyncd_Settings} = "Opciones de Rsyncd";
$Lang{CfgEdit_Title_Archive_Settings} = "Opciones de Archive";
$Lang{CfgEdit_Title_Include_Exclude} = "Include/Exclude";
$Lang{CfgEdit_Title_Smb_Paths_Commands} = "Smb Rutas/Comandos";
$Lang{CfgEdit_Title_Tar_Paths_Commands} = "Tar Rutas/Comandos";
$Lang{CfgEdit_Title_Rsync_Paths_Commands_Args} = "Rsync Rutas/Comandos/Argumentos";
$Lang{CfgEdit_Title_Rsyncd_Port_Args} = "Rsyncd Puerto/Argumentoss";
$Lang{CfgEdit_Title_Archive_Paths_Commands} = "Rutas/Comandos de Archivamiento";
$Lang{CfgEdit_Title_Schedule} = "Horario";
$Lang{CfgEdit_Title_Full_Backups} = "Backups Completos";
$Lang{CfgEdit_Title_Incremental_Backups} = "Backups Incrementales";
$Lang{CfgEdit_Title_Blackouts} = "Blackouts - per&iacute;odos sin backup autom&aacute;ticos";
$Lang{CfgEdit_Title_Other} = "Otro";
$Lang{CfgEdit_Title_Backup_Settings} = "Opciones de Backup";
$Lang{CfgEdit_Title_Client_Lookup} = "B&uacute;squeda de Cliente";
$Lang{CfgEdit_Title_User_Commands} = "Comandos de Usuario";
$Lang{CfgEdit_Title_Hosts} = "Hosts";

$Lang{CfgEdit_Hosts_Comment} = <<EOF;
Para agregar un nuevo host, seleccione Agregar y luego escriba el nombre. Para empezar
la configuraci&oacute;n de cada host desde otro host, escriba el nombre de host
como NEWHOST=COPYHOST. Esto sobrescribir&aacute; cualquier configuraci&oacute;n por host 
existente para NEWHOST. TambiŽn puede hacer esto para un host ya existente. Para eliminar 
un host, pulse el bot&oacute;n Eliminar. Al agregar, eliminar y copiar la 
configuraci&oacute;n, los cambios no entrar&aacute;n en vigor hasta que se pulse el 
bot&oacute;n Guardar. Ninguna de las copias de seguridad de host eliminados ser&aacute;n 
removidos, por lo que si accidentalmente borra un host, simplemente vuelva a agregarlo. 
Para remover completamente las copias de seguridad de un host, es necesario eliminar 
manualmente los archivos debajo de \$topDir/pc/HOST
EOF

$Lang{CfgEdit_Header_Main} = <<EOF;
\${h1("Editor de Configuraci&oacute;n Principal")}
EOF

$Lang{CfgEdit_Header_Host} = <<EOF;
\${h1("Host \$host Editor de Configuraci&oacute;n")}
<p>
Nota: Marque 'Reemplazar' si desea modificar un valor espec’fico a este host.
<p>
EOF

$Lang{CfgEdit_Button_Save}     = "Grabar";
$Lang{CfgEdit_Button_Insert}   = "Insertar";
$Lang{CfgEdit_Button_Delete}   = "Borrar";
$Lang{CfgEdit_Button_Add}      = "Aumentar";
$Lang{CfgEdit_Button_Override} = "Reemplazar";
$Lang{CfgEdit_Button_New_Key}  = "Nueva Llave";
$Lang{CfgEdit_Button_New_Share} = "New ShareName or '*'";

$Lang{CfgEdit_Error_No_Save}
            = "ENG Error: No grab&oacute; debido a errores";
$Lang{CfgEdit_Error__must_be_an_integer}
            = "Error: \$var debe ser un entero";
$Lang{CfgEdit_Error__must_be_real_valued_number}
            = "Error: \$var debe ser un n&uacute;mero de valor real";
$Lang{CfgEdit_Error__entry__must_be_an_integer}
            = "Error: \$var ingreso \$k debe ser un entero";
$Lang{CfgEdit_Error__entry__must_be_real_valued_number}
            = "Error: \$var ingreso \$k debe ser un n&uacute;mero de valor real";
$Lang{CfgEdit_Error__must_be_executable_program}
            = "Error: \$var debe ser una ruta de acceso ejecutable v&aacute;lida";
$Lang{CfgEdit_Error__must_be_valid_option}
            = "Error: \$var debe ser una opci&oacute;n v&aacute;lida";
$Lang{CfgEdit_Error_Copy_host_does_not_exist}
            = "Copia del host \$copyHost no existe; creando nombre completo del host \$fullHost.  Elimine este host si eso no es lo que deseaba.";

$Lang{CfgEdit_Log_Copy_host_config}
            = "\$User copi&oacute; configuraci&oacute;n del host \$fromHost a \$host\n";
$Lang{CfgEdit_Log_Delete_param}
            = "\$User borr&oacute; \$p de \$conf\n";
$Lang{CfgEdit_Log_Add_param_value}
            = "\$User aument&oacute; \$p a \$conf, con el valor \$value\n";
$Lang{CfgEdit_Log_Change_param_value}
            = "\$User cambi&oacute; \$p en \$conf a \$valueNew de \$valueOld\n";
$Lang{CfgEdit_Log_Host_Delete}
            = "\$User borr&oacute; host \$host\n";
$Lang{CfgEdit_Log_Host_Change}
            = "\$User host \$host cambi&oacute; \$key de \$valueOld a \$valueNew\n";
$Lang{CfgEdit_Log_Host_Add}
            = "\$User aument&oacute; host \$host: \$value\n";
  
#end of es.pm backuppc ver 3.3.0 - luis bustamante olivera - luisbustamante@yahoo.com 
