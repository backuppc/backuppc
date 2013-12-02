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

$Lang{Start_Archive} = "Comenzar archivado";
$Lang{Stop_Dequeue_Archive} = "Parar/anular archivado";
$Lang{Start_Full_Backup} = "Comenzar copia de seguridad completa";
$Lang{Start_Incr_Backup} = "Comenzar copia de seguridad incremental";
$Lang{Stop_Dequeue_Backup} = "Parar/anular copia de seguridad";
$Lang{Restore} = "Restaurar";

$Lang{Type_full} = "completo";
$Lang{Type_incr} = "incremental";

# -----

$Lang{Only_privileged_users_can_view_admin_options} = "Sólo los superusuarios pueden ver las opciones de administración.";
$Lang{H_Admin_Options} = "Servidor BackupPC: Opciones de administración";
$Lang{Admin_Options} = "Opciones de administración";
$Lang{Admin_Options_Page} = <<EOF;
\${h1(qq{$Lang{Admin_Options}})}
<br>
\${h2("Control del Servidor")}
<form name="ReloadForm" action="\$MyURL" method="get">
<input type="hidden" name="action" value="">
<table class="tableStnd">
  <tr><td>Actualizar configuración del servidor:<td><input type="button" value="Reload"
     onClick="document.ReloadForm.action.value='Reload';
              document.ReloadForm.submit();">
</table>
</form>
<!--
\${h2("Server Configuration")}
<ul> 
  <li><i>Espacio para otras opciones... e.j.,</i>
  <li>Editar configuración del servidor
</ul>
-->
EOF

$Lang{Unable_to_connect_to_BackupPC_server} = "Imposible conectar al servidor BackupPC";
$Lang{Unable_to_connect_to_BackupPC_server_error_message} = <<EOF;
Este script CGI (\$MyURL) no puede conectar al servidor BackupPC
en \$Conf{ServerHost} puerto \$Conf{ServerPort}.<br>
El error fué: \$err.<br>
Quizá el servidor BackupPC no está activo o hay un
error de configuración. Por favor informe a su administrador de sistemas.
EOF

$Lang{Admin_Start_Server} = <<EOF;
\${h1(qq{$Lang{Unable_to_connect_to_BackupPC_server}})}
<form action="\$MyURL" method="get">
El servidor BackupPC en <tt>\$Conf{ServerHost}</tt> port <tt>\$Conf{ServerPort}</tt>
no está en funcionamiento ahora (puede haberlo detenido o no haberlo arrancado aún).<br>
¿Quiere inicializarlo?
<input type="hidden" name="action" value="startServer">
<input type="submit" value="Start Server" name="ignore">
</form>
EOF

# -----

$Lang{H_BackupPC_Server_Status} = "Estado del Servidor BackupPC";

$Lang{BackupPC_Server_Status_General_Info}= <<EOF;
\${h2(\"Información General del servidor\")}

<ul>
<li> El PID del servidor es \$Info{pid}, en el host \$Conf{ServerHost},
     version \$Info{Version}, iniciado el \$serverStartTime.
<li> Esta información de estado se ha generado el \$now.
<li> La última configuración ha sido cargada a las \$configLoadTime
<li> La cola de PC´s se activará de nuevo el \$nextWakeupTime.
<li> Información adicional:
    <ul>
        <li>\$numBgQueue solicitudes pendientes de copia de seguridad desde la última activación programada,
        <li>\$numUserQueue solicitudes pendientes de copia de seguridad de usuarios,
        <li>\$numCmdQueue solicitudes de comandos pendientes ,
        \$poolInfo
        <li>El sistema de archivos estaba recientemente al \$Info{DUlastValue}%
            (\$DUlastTime), el máximo de hoy es \$Info{DUDailyMax}% (\$DUmaxTime)
            y el máximo de ayer era \$Info{DUDailyMaxPrev}%.
    </ul>
</ul>
EOF

$Lang{BackupPC_Server_Status} = <<EOF;
\${h1(qq{$Lang{H_BackupPC_Server_Status}})}

<p>
\${h2("Trabajos en Ejecución")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
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

\${h2("Fallos que Precisan Atención")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> Host </td>
    <td align="center"> Tipo </td>
    <td align="center"> Usuario </td>
    <td align="center"> Ultimo Intento </td>
    <td align="center"> Detalles </td>
    <td align="center"> Hora del error </td>
    <td> Ultimo error (ping no incluido) </td></tr>
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
    (\$DUlastTime), el m?ximo de hoy es \$Info{DUDailyMax}% (\$DUmaxTime)
    y el m?ximo de ayer era \$Info{DUDailyMaxPrev}%.
</ul>
</p>

\${h2("Hosts con Buenas Copias de Seguridad")}
<p>
Il y a \$hostCntGood hosts tienen copia de seguridad, de un total de :
<ul>
<li> \$fullTot copias de seguridad completas con tamaño total de \${fullSizeTot} GiB
     (antes de agrupar y comprimir),
<li> \$incrTot copias de seguridad incrementales con tamaño total de \${incrSizeTot} GiB
     (antes de agrupar y comprimir).
</ul>
</p>
<table class="sortable" id="host_summary_backups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> Host </td>
    <td align="center"> Usuario </td>
    <td align="center"> #Completo </td>
    <td align="center"> Completo Antig. (Días) </td>
    <td align="center"> Completo Tamaño (GiB) </td>
    <td align="center"> Velocidad MB/sec </td>
    <td align="center"> #Incrementales </td>
    <td align="center"> Incrementales Antig (Días) </td>
    <td align="center"> ENG Last Backup (days) </td>
    <td align="center"> Estado </td>
    <td align="center"> Nº Xfer errs </td>
    <td align="center"> Ultimo Intento </td></tr>
\$strGood
</table>
<br><br>
\${h2("Hosts Sin Copias de Seguridad")}
<p>
Hay \$hostCntNone hosts sin copias de seguridad.
<p>
<table class="sortable" id="host_summary_nobackups" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td> Host </td>
    <td align="center"> Usuario </td>
    <td align="center"> #Completo </td>
    <td align="center"> Completo Antig. (Días) </td>
    <td align="center"> Completo Tamaño (GiB) </td>
    <td align="center"> Velocidad MB/sec </td>
    <td align="center"> #Incrementales </td>
    <td align="center"> Incrementales Antig (Días) </td>
    <td align="center"> ENG Last Backup (days) </td>
    <td align="center"> Estado </td>
    <td align="center"> Nº Xfer errs </td>
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

Hay \$hostCntGood hosts que tienen copia de seguridad con un tamaño total de \${fullSizeTot}GiB
<p>
<form name="form1" method="post" action="\$MyURL">
<input type="hidden" name="fcbMax" value="\$checkBoxCnt">
<input type="hidden" name="type" value="1">
<input type="hidden" name="host" value="\${EscHTML(\$archHost)}">
<input type="hidden" name="action" value="Archive">
<table class="tableStnd" border cellpadding="3" cellspacing="1">
<tr class="tableheader"><td align=center> Host</td>
    <td align="center"> User </td>
    <td align="center"> Backup Size </td>
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
    <td>Ubicación de archivo/Dispositivo</td>
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
        <li>El grupo tiene \${poolSize}GiB incluyendo \$info->{"\${name}FileCnt"} archivos
            y \$info->{"\${name}DirCnt"} directorios (as of \$poolTime),
        <li>El procesamiento del grupo da \$info->{"\${name}FileCntRep"} archivos
            repetidos cuya cadena más larga es \$info->{"\${name}FileRepMax"},
        <li>El proceso de limpieza nocturna ha eliminado \$info->{"\${name}FileCntRm"} archivos de
            tamaño \${poolRmSize}GiB (around \$poolTime),
EOF

# --------------------------------
$Lang{BackupPC__Backup_Requested_on__host} = "BackupPC: Copia de Seguridad Solicitada en \$host";
# --------------------------------
$Lang{REPLY_FROM_SERVER} = <<EOF;
\${h1(\$str)}
<p>
La respuesta del servidor fué: \$reply
<p>
Volver a <a href="\$MyURL?host=\$host">\$host home page</a>.
EOF
# --------------------------------
$Lang{BackupPC__Start_Backup_Confirm_on__host} = "BackupPC: Confirme inicio de copia de seguridad en \$host";
# --------------------------------
$Lang{Are_you_sure_start} = <<EOF;
\${h1("¿Está seguro?")}
<p>
Va a hacer comenzar una copia de seguridad \$type en \$host.

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="hostIP" value="\$ipAddr">
<input type="hidden" name="doit" value="1">
<input type="hidden" name="action" value="">
¿Realmente quiere hacer esto?
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="No" name="ignore">
</form>
EOF
# --------------------------------
$Lang{BackupPC__Stop_Backup_Confirm_on__host} = "BackupPC: Confirmación de Parada de Copia de Seguridad en \$host";
# --------------------------------
$Lang{Are_you_sure_stop} = <<EOF;

\${h1("¿Está seguro?")}

<p>
Está a punto de parar/quitar de la cola las copias de seguridad en \$host;

<form name="Confirm" action="\$MyURL" method="get">
<input type="hidden" name="host"   value="\$host">
<input type="hidden" name="doit"   value="1">
<input type="hidden" name="action" value="">
Asimismo, por favor no empiece otra copia de seguridad durante
<input type="text" name="backoff" size="10" value="\$backoff"> horas.
<p>
¿Realmente quiere hacer esto?
<input type="button" value="\$buttonText"
  onClick="document.Confirm.action.value='\$In{action}';
           document.Confirm.submit();">
<input type="submit" value="No" name="ignore">
</form>

EOF
# --------------------------------
$Lang{Only_privileged_users_can_view_queues_} = "Sólo los administradores pueden ver las colas.";
# --------------------------------
$Lang{Only_privileged_users_can_archive} = "Sólo los administradores pueden archivar.";
# --------------------------------
$Lang{BackupPC__Queue_Summary} = "BackupPC: Resumen de la Cola";
# --------------------------------
$Lang{Backup_Queue_Summary} = <<EOF;
\${h1("Resumen de la Cola de Copias de Seguridad")}
<br><br>
\${h2("Resumen de la Cola de Usuarios")}
<p>
Las siguientes solicitudes de usuarios están actualmente en cola:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Host </td>
    <td> Hora Sol. </td>
    <td> Usuario </td></tr>
\$strUser
</table>
<br><br>

\${h2("Resumen de Cola en Segundo Plano")}
<p>
Las siguientes solicitudes en segundo plano están actualmente en cola:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Host </td>
    <td> Hora Sol. </td>
    <td> Usuario </td></tr>
\$strBg
</table>
<br><br>
\${h2("Resumen de Cola de Comandos")}
<p>
Los siguientes comandos están actualmente en cola:
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td> Host </td>
    <td> Hora Sol. </td>
    <td> Usuario </td>
    <td> Comando </td></tr>
\$strCmd
</table>
EOF

# --------------------------------
$Lang{Backup_PC__Log_File__file} = "BackupPC: Archivo de Registro \$file";
$Lang{Log_File__file__comment} = <<EOF;
\${h1("Log File \$file \$comment")}
<p>
EOF
# --------------------------------
$Lang{Contents_of_log_file} = <<EOF;
Contenido del archivo de registro <tt>\$file</tt>, modificado \$mtimeStr \$comment
EOF

# --------------------------------
$Lang{skipped__skipped_lines} = "[ saltadas \$skipped lineas ]\n";
# --------------------------------
$Lang{_pre___Can_t_open_log_file__file} = "<pre>\nNo puedo abrir el archivo de registro \$file\n";

# --------------------------------
$Lang{BackupPC__Log_File_History} = "BackupPC: Historial de Archivo de Registro";
$Lang{Log_File_History__hdr} = <<EOF;
\${h1("Historial de Archivo de Registro \$hdr")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> File </td>
    <td align="center"> Size </td>
    <td align="center"> Hora Modificación </td></tr>
\$str
</table>
EOF

# -------------------------------
$Lang{Recent_Email_Summary} = <<EOF;
\${h1("Resumen de Mensajes Recientes (Orden de tiempo inverso)")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Destinatario </td>
    <td align="center"> Host </td>
    <td align="center"> Hora </td>
    <td align="center"> Asunto </td></tr>
\$str
</table>
EOF
 

# ------------------------------
$Lang{Browse_backup__num_for__host} = "BackupPC: Hojear copia de seguridad \$num de \$host";

# ------------------------------
$Lang{Restore_Options_for__host} = "BackupPC: Opciones de restauración para \$host";
$Lang{Restore_Options_for__host2} = <<EOF;
\${h1("Opciones de restauración para \$host")}
<p>
Ha seleccionado los siguientes archivos/directorios de
la unidad \$share, copia número #\$num:
<ul>
\$fileListStr
</ul>
</p><p>
Tiene tres opciones para restaurar estos archivos/directorios.
Por favor, seleccione una de las siguientes opciones.
</p>
\${h2("Opción 1: Restauración Directa")}
<p>
EOF

$Lang{Restore_Options_for__host_Option1} = <<EOF;
Puede empezar un proceso que restaurará estos archivos directamente en
<b>\$directHost</b>.
</p><p>
<b>¡Atención!:</b> ¡Cualquier archivo existente con el mismo nombre que los que ha
seleccionado será sobreescrito!
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
Se ha deshabilitado la restauración directa para el host \${EscHTML(\$hostDest)}.
Por favor seleccione una de las otras opciones de restauración.
EOF

# ------------------------------
$Lang{Option_2__Download_Zip_archive} = <<EOF;
<p>
\${h2("Opción 2: Descargar archivo Zip")}
<p>
Puede descargar un archivo comprimido (.zip) conteniendo todos los archivos y directorios que
ha seleccionado.  Después puede hacer uso de una aplicación local, como WinZip,
para ver o extraer cualquiera de los archivos.
</p><p>
<b>¡Atención!:</b> Dependiendo de que archivos/carpetas haya seleccionado,
este archivo puede ser muy grande. Podría tardar muchos minutos en
crear y transferir el archivo. Además necesitará suficiente espacio el el disco
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
(en caso contrario el archivo contendrá las rutas completas).
<br>
<table class="tableStnd" border="0">
<tr>
    <td>Compresión (0=desactivada, 1=rápida,...,9=máxima)</td>
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
\${h2("Opción 2: Descargar archivo Zip")}
<p>
El programa Archive::Zip no está instalado, de modo que no podrá descargar un
archivo comprimido zip.
Por favor, solicite a su administrador de sistemas que instale Archive::Zip de
<a href="http://www.cpan.org">www.cpan.org</a>.
</p>
EOF


# ------------------------------
$Lang{Option_3__Download_Zip_archive} = <<EOF;
\${h2("Opción 3: Descargar archivo Tar")}
<p>
Puede descargar un archivo comprimido (.Tar) conteniendo todos los archivos y
directorios que ha seleccionado. Después puede hacer uso de una aplicación
local, como Tar o WinZip,para ver o extraer cualquiera de los archivos.
</p><p>
<b>¡Atención!:</b> Dependiendo de que archivos/carpetas haya seleccionado,
este archivo puede ser muy grande. Podría tardar muchos minutos
crear y transferir el archivo. Además necesitará suficiente espacio el el disco
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
(en caso contrario el archivo contendrá las rutas completas).
<br>
<input type="submit" value="Download Tar File" name="ignore">
</form>
EOF


# ------------------------------
$Lang{Restore_Confirm_on__host} = "BackupPC: Confirme restauración en \$host";

$Lang{Are_you_sure} = <<EOF;
\${h1("¿Está seguro?")}
<p>
Está a punto de comenzar una restauración directamente a la máquina \$In{hostDest}.
Los siguientes archivos serán restaurados en la unidad \$In{shareDest}, de
la copia de seguridad número \$num:
<p>
<table class="tableStnd" border>
<tr class="tableheader"><td>Archivo/Dir Original </td><td>Será restaurado a</td></tr>
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
¿Realmente quiere hacer esto?
<input type="button" value="\$Lang->{Restore}"
 onClick="document.RestoreForm.action.value='Restore';
          document.RestoreForm.submit();">
<input type="submit" value="No" name="ignore">
</form>
EOF


# --------------------------
$Lang{Restore_Requested_on__hostDest} = "BackupPC: Restauración solicitada en \$hostDest";
$Lang{Reply_from_server_was___reply} = <<EOF;
\${h1(\$str)}
<p>
La respuesta del servidor fué: \$reply
<p>
volver a <a href="\$MyURL?host=\$hostDest">\$hostDest home page</a>.
EOF

$Lang{BackupPC_Archive_Reply_from_server} = <<EOF;
\${h1(\$str)}
<p>
La respuesta del servidor fué: \$reply
EOF

# -------------------------
$Lang{Host__host_Backup_Summary} = "BackupPC: Host \$host Resumen de Copia de Seguridad";

$Lang{Host__host_Backup_Summary2} = <<EOF;
\${h1("Host \$host Backup Summary")}
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
Haga click en el número de copia de seguridad para revisar y restaurar archivos.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader"><td align="center"> Copia Nº </td>
    <td align="center"> Tipo </td>
    <td align="center"> Completo </td>
    <td align="center"> ENG Level </td>
    <td align="center"> Fecha Inicio </td>
    <td align="center"> Duracion/mn </td>
    <td align="center"> Antigüedad/dias </td>
    <td align="center"> Ruta a la Copia en el Servidor </td>
</tr>
\$str
</table>
<p>

\$restoreStr
</p>
<br><br>
\${h2("Resumen de Errores de Transferencia")}
<br><br>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Copia Nº </td>
    <td align="center"> Tipo </td>
    <td align="center"> Ver </td>
    <td align="center"> Nº Xfer errs </td>
    <td align="center"> Nº err. archivos </td>
    <td align="center"> Nº err. unidades </td>
    <td align="center"> Nº err. tar </td>
</tr>
\$errStr
</table>
<br><br>

\${h2("Resumen de Total/Tamaño de Archivos Reutilizados")}
<p>
Los archivos existentes son aquellos que ya están en el lote; los nuevos son
aquellos que se han añadido al lote.
Los archivos vacíos y los errores SMB no cuentan en las cifras de reutilizados
ni en la de nuevos.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="2" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> Totales </td>
    <td align="center" colspan="2"> Archivos Existentes </td>
    <td align="center" colspan="2"> Archivos Nuevos </td>
</tr>
<tr class="tableheader">
    <td align="center"> Copia Nº </td>
    <td align="center"> Tipo </td>
    <td align="center"> Nº Archivos </td>
    <td align="center"> Tamaño/MB </td>
    <td align="center"> MB/sg </td>
    <td align="center"> Nº Archivos </td>
    <td align="center"> Tamaño/MB </td>
    <td align="center"> Nº Archivos </td>
    <td align="center"> Tamaño/MB </td>
</tr>
\$sizeStr
</table>
<br><br>

\${h2("Resumen de Compresión")}
<p>
Efectividad de compresión para los archivos ya existentes en el lote y los
archivos nuevos comprimidos.
</p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td colspan="3" bgcolor="#ffffff"></td>
    <td align="center" colspan="3"> Archivos Existentes </td>
    <td align="center" colspan="3"> Archivos Nuevos </td>
</tr>
<tr class="tableheader"><td align="center"> Copia Nº </td>
    <td align="center"> Tipo </td>
    <td align="center"> Nivel Comp </td>
    <td align="center"> Tamaño/MB </td>
    <td align="center"> Comp/MB </td>
    <td align="center"> Comp </td>
    <td align="center"> Tamaño/MB </td>
    <td align="center"> Comp/MB </td>
    <td align="center"> Comp </td>
</tr>
\$compStr
</table>
<br><br>
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
\${h1("Revisar Copia de seguridad de \$host")}

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
<li> Está revisando la copia de seguridad Nº\$num, que comenzó hacia las \$backupTime
        (hace \$backupAge dias),
\$filledBackup
<li> Introduzca el directorio: <input type="text" name="dir" size="50" maxlength="4096" value="\${EscHTML(\$dir)}"> <input type="submit" value="\$Lang->{Go}" name="Submit">
<li> Haga click en uno de los directorios de abajo para revisar sus contenidos,
<li> Haga click en un archivo para restaurarlo,
<li> Puede ver la copia de seguridad <a href="\$MyURL?action=dirHistory&host=\${EscURI(\$host)}&share=\$shareURI&dir=\$pathURI">history</a> del directorio actual.
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
$Lang{DirHistory_backup_for__host} = "BackupPC: Histórico de copia de seguridad del directorio en \$host";

#
# These two strings are used to build the links for directories and
# file versions.  Files are appended with a version number.
#
$Lang{DirHistory_dirLink}  = "dir";
$Lang{DirHistory_fileLink} = "v";

$Lang{DirHistory_for__host} = <<EOF;
\${h1("Histórico de copia de seguridad del directorio en \$host")}
<p>
Esta pantalla muestra cada versión única de archivos de entre todas
las copias de seguridad:
<ul>
<li> Haga click en un número de copia de seguridad para volver al explorador de copias de seguridad,
<li> Haga click en un vínculo de directorio (\$Lang->{DirHistory_dirLink}) para navegar
     en ese directorio,
<li> Haga click en un vínculo de versión de archivo (\$Lang->{DirHistory_fileLink}0,
     \$Lang->{DirHistory_fileLink}1, ...) para descargar ese archivo,
<li> Los archivos con diferentes contenidos entre distintas copias de seguridad tienen el mismo
     número de versión,
<li> Los archivos o directorios que no existen en una copia concreta tienen una
     celda vacía.
<li> Los archivos mostrados con la misma versión pueden tener diferentes atributos.
     Seleccione el número de copia de seguridad para ver los atributos del archivo.
</ul>

\${h2("History of \$dirDisplay")}

<br>
<table border cellspacing="2" cellpadding="3">
<tr class="fviewheader"><td>Backup number</td>\$backupNumStr</tr>
<tr class="fviewheader"><td>Backup time</td>\$backupTimeStr</tr>
\$fileStr
</table>
EOF

# ------------------------------
$Lang{Restore___num_details_for__host} = "BackupPC: Detalles de la restauración Nº\$num de \$host";

$Lang{Restore___num_details_for__host2} = <<EOF;
\${h1("Detalles de la restauración Nº\$num de \$host")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="90%">
<tr><td class="tableheader"> Número </td><td class="border"> \$Restores[\$i]{num} </td></tr>
<tr><td class="tableheader"> Solicitado por </td><td class="border"> \$RestoreReq{user} </td></tr>
<tr><td class="tableheader"> Hora Petición </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> Resultado </td><td class="border"> \$Restores[\$i]{result} </td></tr>
<tr><td class="tableheader"> Mensaje de Error </td><td class="border"> \$Restores[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> Host Origen </td><td class="border"> \$RestoreReq{hostSrc} </td></tr>
<tr><td class="tableheader"> Nº copia origen </td><td class="border"> \$RestoreReq{num} </td></tr>
<tr><td class="tableheader"> Unidad origen </td><td class="border"> \$RestoreReq{shareSrc} </td></tr>
<tr><td class="tableheader"> Host destino </td><td class="border"> \$RestoreReq{hostDest} </td></tr>
<tr><td class="tableheader"> Unidad destino </td><td class="border"> \$RestoreReq{shareDest} </td></tr>
<tr><td class="tableheader"> Hora comienzo </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Duración </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> Número de archivos </td><td class="border"> \$Restores[\$i]{nFiles} </td></tr>
<tr><td class="tableheader"> Tamaño total </td><td class="border"> \${MB} MB </td></tr>
<tr><td class="tableheader"> Tasa de transferencia </td><td class="border"> \$MBperSec MB/sec </td></tr>
<tr><td class="tableheader"> Errores creación Tar </td><td class="border"> \$Restores[\$i]{tarCreateErrs} </td></tr>
<tr><td class="tableheader"> Errores de transferencia </td><td class="border"> \$Restores[\$i]{xferErrs} </td></tr>
<tr><td class="tableheader"> Archivo registro de transferencia </td><td class="border">
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
<tr><td class="tableheader"> Número </td><td class="border"> \$Archives[\$i]{num} </td></tr>
<tr><td class="tableheader"> Solicitado por </td><td class="border"> \$ArchiveReq{user} </td></tr>
<tr><td class="tableheader"> Hora petición </td><td class="border"> \$reqTime </td></tr>
<tr><td class="tableheader"> Resultado </td><td class="border"> \$Archives[\$i]{result} </td></tr>
<tr><td class="tableheader"> Mensaje de error </td><td class="border"> \$Archives[\$i]{errorMsg} </td></tr>
<tr><td class="tableheader"> Hora comienzo </td><td class="border"> \$startTime </td></tr>
<tr><td class="tableheader"> Duración </td><td class="border"> \$duration min </td></tr>
<tr><td class="tableheader"> Archivo registro Xfer </td><td class="border">
<a href="\$MyURL?action=view&type=ArchiveLOG&num=\$Archives[\$i]{num}&host=\$host">View</a>,
<a href="\$MyURL?action=view&type=ArchiveErr&num=\$Archives[\$i]{num}&host=\$host">Errors</a>
</tr></tr>
</table>
<p>
\${h1("Host list")}
<p>
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td>Host</td><td>Copia de seguridad número</td></tr>
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
              "Usuario erróneo: mi userid es \$>, en lugar de \$uid"
            . "(\$Conf{BackupPCUser})\n";
# $Lang{Only_privileged_users_can_view_PC_summaries} = "Sólo los usuarios autorizados pueden ver los resúmenes de PC´s.";
$Lang{Only_privileged_users_can_stop_or_start_backups} = 
                  "Sólo los usuarios autorizados pueden comenzar a detener las copias"
		. " \${EscHTML(\$host)}.";
$Lang{Invalid_number__num} = "Número no válido \${EscHTML(\$In{num})}";
$Lang{Unable_to_open__file__configuration_problem} = "No puedo abrir \$file: ¿problema de configuración?";
$Lang{Only_privileged_users_can_view_log_or_config_files} = "Sólo los usuarios autorizados pueden ver registros o archivos de configuración.";
$Lang{Only_privileged_users_can_view_log_files} = "Sólo los usuarios autorizados pueden ver archivos de registro.";
$Lang{Only_privileged_users_can_view_email_summaries} = "Sólo los usuarios autorizados pueden ver resúmenes de correo.";
$Lang{Only_privileged_users_can_browse_backup_files} = "Sólo los usuarios autorizados pueden revisar los archivos de las copias de seguridad"
                . " for host \${EscHTML(\$In{host})}.";
$Lang{Empty_host_name} = "Número de host vacío.";
$Lang{Directory___EscHTML} = "El directorio \${EscHTML(\"\$TopDir/pc/\$host/\$num\")}"
		    . " está vacío";
$Lang{Can_t_browse_bad_directory_name2} = "No puedo mostrar un nombre de directorio erróneo"
	            . " \${EscHTML(\$relDir)}";
$Lang{Only_privileged_users_can_restore_backup_files} = "Sólo los usuarios autorizados pueden restaurar copias de seguridad"
                . " para el host \${EscHTML(\$In{host})}.";
$Lang{Bad_host_name} = "Nombre de host erróneo \${EscHTML(\$host)}";
$Lang{You_haven_t_selected_any_files__please_go_Back_to} = "No ha seleccionado nigún archivo; por favor, vuelva a"
                . " seleccione algunos archivos.";
$Lang{You_haven_t_selected_any_hosts} = "No ha seleccionado ningún host; por favor vuelva a"
                . " select some hosts.";
$Lang{Nice_try__but_you_can_t_put} = "Buen intento, pero no puede usar \'..\' en los nombres de archivo";
$Lang{Host__doesn_t_exist} = "El Host \${EscHTML(\$In{hostDest})} no existe";
$Lang{You_don_t_have_permission_to_restore_onto_host} = "No tiene autorización para restaurar en el host"
		    . " \${EscHTML(\$In{hostDest})}";
$Lang{Can_t_open_create__openPath} = "No puedo abrir/crear "
		. "\${EscHTML(\"\$openPath\")}";
$Lang{Only_privileged_users_can_restore_backup_files2} = "Sólo los usuarios autorizados pueden restaurar copias de seguridad"
                . " del host \${EscHTML(\$host)}.";
$Lang{Empty_host_name} = "Nombre de host vacío";
$Lang{Unknown_host_or_user} = "Unknown host or user \${EscHTML(\$host)}";
$Lang{Only_privileged_users_can_view_information_about} = "Sólo los usuarios autorizados pueden ver información del"
                . " host \${EscHTML(\$host)}." ;
$Lang{Only_privileged_users_can_view_archive_information} = "Sólo los administradores pueden ver información de archivo.";
$Lang{Only_privileged_users_can_view_restore_information} = "Sólo los usuarios autorizados pueden ver información de restauración.";
$Lang{Restore_number__num_for_host__does_not_exist} = "El número de restauración \$num del host \${EscHTML(\$host)} "
	        . " no existe.";
$Lang{Archive_number__num_for_host__does_not_exist} = "La copia de seguridad \$num del host \${EscHTML(\$host)} "
                . " no existe.";
$Lang{Can_t_find_IP_address_for} = "No puedo encontrar la dirección IP de \${EscHTML(\$host)}";
$Lang{host_is_a_DHCP_host} = <<EOF;
\$host es un host DHCP y yo no conozco su dirección IP. He comprobado el
nombre netbios de \$ENV{REMOTE_ADDR}\$tryIP, y he verificado que esa máquina
no es \$host.
<p>
Hasta que vea \$host en una dirección DHCP concreta, sólo puede
comenzar este proceso desde la propia máquina cliente.
EOF

# ------------------------------------
# !! Server Mesg !!
# ------------------------------------

$Lang{Backup_requested_on_DHCP__host} = "Copia de seguridad solicitada en DHCP \$host (\$In{hostIP}) por"
		                      . " \$User desde \$ENV{REMOTE_ADDR}";
$Lang{Backup_requested_on__host_by__User} = "Copia de seguridad solicitada en \$host por \$User";
$Lang{Backup_stopped_dequeued_on__host_by__User} = "Copia de seguridad detenida/desprogramada en \$host por \$User";
$Lang{Restore_requested_to_host__hostDest__backup___num} = "Restauración solicitada para el host \$hostDest, copia de seguridad #\$num,"
	     . " por \$User desde \$ENV{REMOTE_ADDR}";
$Lang{Archive_requested} = "Archivo solicitado por \$User desde \$ENV{REMOTE_ADDR}";

# -------------------------------------------------
# ------- Stuff that was forgotten ----------------
# -------------------------------------------------

$Lang{Status} = "Estado";
$Lang{PC_Summary} = "Resumen PC";
$Lang{LOG_file} = "Archivo Registro";
$Lang{LOG_files} = "Archivos de registro";
$Lang{Old_LOGs} = "Registros antiguos";
$Lang{Email_summary} = "Resumen correo";
$Lang{Config_file} = "Archivo configuración";
# $Lang{Hosts_file} = "Archivo Hosts";
$Lang{Current_queues} = "Colas actuales";
$Lang{Documentation} = "Documentación";

#$Lang{Host_or_User_name} = "<small>Host o usuario:</small>";
$Lang{Go} = "Aceptar";
$Lang{Hosts} = "Hosts";
$Lang{Select_a_host} = "Seleccione un host...";

$Lang{There_have_been_no_archives} = "<h2> No ha habido archivos </h2>\n";
$Lang{This_PC_has_never_been_backed_up} = "<h2> !Nunca se ha hecho copia de seguridad de este PC! </h2>\n";
$Lang{This_PC_is_used_by} = "<li>This PC es utilizado por \${UserLink(\$user)}";

$Lang{Extracting_only_Errors} = "(Extrayendo sólo Errores)";
$Lang{XferLOG} = "TransfREG";
$Lang{Errors}  = "Errores";

# ------------
$Lang{Last_email_sent_to__was_at___subject} = <<EOF;
<li>El último mensaje enviado a  \${UserLink(\$user)} fué a las \$mailTime, asunto "\$subj".
EOF
# ------------
$Lang{The_command_cmd_is_currently_running_for_started} = <<EOF;
<li>El comando \$cmd está ejecutandose para \$host, comenzado a \$startTime.
EOF

# -----------
$Lang{Host_host_is_queued_on_the_background_queue_will_be_backed_up_soon} = <<EOF;
<li>El host \$host está en cola en la cola en segundo plano (pronto tendrá copia de seguridad).
EOF

# ----------
$Lang{Host_host_is_queued_on_the_user_queue__will_be_backed_up_soon} = <<EOF;
<li>Host \$host está en cola en la cola de usuarios (pronto tendrá copia de seguridad).
EOF

# ---------
$Lang{A_command_for_host_is_on_the_command_queue_will_run_soon} = <<EOF;
<li>Un comando para \$host está en la cola de comandos (se ejecutará pronto).
EOF

# --------
$Lang{Last_status_is_state_StatusHost_state_reason_as_of_startTime} = <<EOF;
<li>El último estado fué \"\$Lang->{\$StatusHost{state}}\"\$reason a las \$startTime.
EOF

# --------
$Lang{Last_error_is____EscHTML_StatusHost_error} = <<EOF;
<li>El último error fué \"\${EscHTML(\$StatusHost{error})}\".
EOF

# ------
$Lang{Pings_to_host_have_failed_StatusHost_deadCnt__consecutive_times} = <<EOF;
<li>Los pings a \$host han fallado \$StatusHost{deadCnt} veces consecutivas.
EOF

# -----
$Lang{Prior_to_that__pings} = "Antes de eso, pings";

# -----
$Lang{priorStr_to_host_have_succeeded_StatusHostaliveCnt_consecutive_times} = <<EOF;
<li>\$priorStr a \$host han tenido éxito \$StatusHost{aliveCnt}
        veces consecutivas.
EOF

$Lang{Because__host_has_been_on_the_network_at_least__Conf_BlackoutGoodCnt_consecutive_times___} = <<EOF;
<li>Dado que \$host ha estado en la red al menos \$Conf{BlackoutGoodCnt}
veces consecutivas, no se le realizará copia de seguridad desde \$blackoutStr.
EOF

$Lang{__time0_to__time1_on__days} = "\$t0 hasta \$t1 en \$days";

$Lang{Backups_are_deferred_for_hours_hours_change_this_number} = <<EOF;
<li>Las copias de seguridad se retrasarán durante \$hours hours
(<a href=\"\$MyURL?action=Stop_Dequeue_Backup&host=\$host\">Cambie este número</a>).
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
       <td align="center"> Nº</td>
       <td align="center"> Tamaño</td>
       <td align="center"> Hora Mod.</td>
    </tr>
EOF

$Lang{Home} = "Principal";
$Lang{Browse} = "Explorar copias de seguridad";
$Lang{Last_bad_XferLOG} = "Ultimo error en registro de transferencia";
$Lang{Last_bad_XferLOG_errors_only} = "Ultimo error en registro de transferencia (errores&nbsp;sólo)";

$Lang{This_display_is_merged_with_backup} = <<EOF;
<li> Esta pantalla está unida a la copia de seguridad Nº\$numF.
EOF

$Lang{Visit_this_directory_in_backup} = <<EOF;
<li> Seleccione la copia de seguridad que desea ver: <select onChange="window.location=this.value">\$otherDirs </select>
EOF

$Lang{Restore_Summary} = <<EOF;
\${h2("Resumen de Restauración")}
<p>
Haga click en el número de restauración para ver sus detalles.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Restauración Nº </td>
    <td align="center"> Resultado </td>
    <td align="right"> Fecha Inicio</td>
    <td align="right"> Dur/mins</td>
    <td align="right"> Nº Archivos </td>
    <td align="right"> MB </td>
    <td align="right"> Nº Err. Tar </td>
    <td align="right"> Nº Err. Transf.#xferErrs </td>
</tr>
\$restoreStr
</table>
<p>
EOF

$Lang{Archive_Summary} = <<EOF;
\${h2("Archive Summary")}
<p>
Click on the archive number for more details.
<table class="tableStnd" border cellspacing="1" cellpadding="3" width="80%">
<tr class="tableheader"><td align="center"> Archive# </td>
    <td align="center"> Resultado </td>
    <td align="right"> Hora comienzo</td>
    <td align="right"> Dur/mins</td>
</tr>
\$ArchiveStr
</table>
<p>
EOF

$Lang{BackupPC__Documentation} = "BackupPC: Documentacion";

$Lang{No} = "no";
$Lang{Yes} = "si";

$Lang{The_directory_is_empty} = <<EOF;
<tr><td bgcolor="#ffffff">El directorio \$dirDisplay está vacio
</td></tr>
EOF

#$Lang{on} = "activo";
$Lang{off} = "inactivo";

$Lang{backupType_full}    = "completo";
$Lang{backupType_incr}    = "incremental";
$Lang{backupType_active}  = "active";
$Lang{backupType_partial} = "parcial";

$Lang{failed} = "fallido";
$Lang{success} = "éxito";
$Lang{and} = "y";

# ------
# Hosts states and reasons
$Lang{Status_idle} = "inactivo";
$Lang{Status_backup_starting} = "comenzando copia de seguridad";
$Lang{Status_backup_in_progress} = "copia de seguridad ejecutándose";
$Lang{Status_restore_starting} = "comenzando restauración";
$Lang{Status_restore_in_progress} = "restauración ejecutándose";
$Lang{Status_admin_pending} = "conexión pendiente";
$Lang{Status_admin_running} = "conexión en curso";

$Lang{Reason_backup_done} = "copia de seguridad realizada";
$Lang{Reason_restore_done} = "restauración realizada";
$Lang{Reason_archive_done}   = "archivado realizado";
$Lang{Reason_nothing_to_do} = "nada por hacer";
$Lang{Reason_backup_failed} = "copia de seguridad fallida";
$Lang{Reason_restore_failed} = "restauración fallida";
$Lang{Reason_archive_failed} = "ha fallado el archivado";
$Lang{Reason_no_ping} = "no hay ping";
$Lang{Reason_backup_canceled_by_user} = "copia cancelada por el usuario";
$Lang{Reason_restore_canceled_by_user} = "restauración cancelada por el usuario";
$Lang{Reason_archive_canceled_by_user} = "archivado cancelado por el usuario";
$Lang{Disabled_OnlyManualBackups}  = "ENG auto disabled";  
$Lang{Disabled_AllBackupsDisabled} = "ENG disabled";                  

# ---------
# Email messages

# No backup ever
$Lang{EMailNoBackupEverSubj} = "BackupPC: ningúna copia de \$host ha tenido éxito";
$Lang{EMailNoBackupEverMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
Estimado $userName,

Su PC ($host) nunca ha completado una copia de seguridad mediante nuestro
programa de copias de seguridad. Las copias de seguridad deberían ejecutarse
automáticamente cuando su PC se conecta a la red. Debería contactar con su
soporte técnico si:

  - Su ordenador ha estado conectado a la red con regularidad. Esto implicaría
    que existe algún problema de instalación o configuración que impide que se
    realicen las copias de seguridad.

  - No desea realizar copias de seguridad y no quiere recibir más mensajes
    como éste.

De no ser así, asegúrese de que su PC está conectado a la red la próxima vez
que esté en la oficina.

Saludos:
Agente BackupPC
http://backuppc.sourceforge.net
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
$days días.
Su PC ha realizado copias de seguridad correctas $numBackups veces desde
$firstTime hasta hace $days días.
Las copias de seguridad deberían efectuarse automáticamente cuando su PC está
conectado a la red.

Si su PC ha estado conectado durante algunas horas a la red durante los últimos
$days días debería contactar con su soporte técnico para ver porqué las copias
de seguridad no funcionan adecuadamente.

Por otro lado, si está fuera de la oficina, no hay mucho que se pueda hacer al
respecto salvo copiar manualmente los archivos especialmente críticos a otro
soporte físico. Debería estar al corriente de que cualquier archivo que haya
creado o modificado en los últimos $days días (incluyendo todo el correo nuevo
y archivos adjuntos) no pueden ser restaurados si su disco se avería.

Saludos:
Agente BackupPC
http://backuppc.sourceforge.net
EOF

# Old Outlook files
$Lang{EMailOutlookBackupSubj} = "BackupPC: Los archivos de Outlook de \$host necesitan ser copiados";
$Lang{EMailOutlookBackupMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj
$headers
Estimado $userName,

Los archivos de Outlook de su PC tienen $howLong.
Estos archivos contienen todo su correo, adjuntos, contactos e información de
su agenda. Su PC ha sido correctamente salvaguardado $numBackups veces desde
$firstTime hasta hace $lastTime días.  Sin embargo, Outlook bloquea todos sus
archivos mientras funciona, impidiendo que pueda hacerse copia de seguridad de
los mismos.

Se le recomienda hacer copia de seguridad de los archivos de Outlook cuando esté
conectado a la red cerrando Outlook y el resto de aplicaciones y utilizando su
navegador de internet. Haga click en este vínculo:

    $CgiURL?host=$host               

Seleccione "Comenzar copia de seguridad incremental" dos veces para comenzar
una neva copia de seguridad incremental.
Puede seleccionar "Volver a la página de $host " y hacer click en "refrescar"
para ver el estado del proceso de copia de seguridad. Debería llevarle sólo
unos minutos completar el proceso.

Saludos:
Agente BackupPC
http://backuppc.sourceforge.net
EOF

$Lang{howLong_not_been_backed_up} = "no se le ha realizado una copia de seguridad con éxito";
$Lang{howLong_not_been_backed_up_for_days_days} = "no se le ha realizado una copia de seguridad durante \$days días";

#######################################################################
# RSS strings
#######################################################################
$Lang{RSS_Doc_Title}       = "BackupPC Server";
$Lang{RSS_Doc_Description} = "RSS feed for BackupPC";
$Lang{RSS_Host_Summary}    = <<EOF;
#Completo: \$fullCnt;
Completo Antig./Días: \$fullAge;
Completo Tamaño/GiB: \$fullSize;
Velocidad MB/sec: \$fullRate;
#Incrementales: \$incrCnt;
Incrementales Antig/Días: \$incrAge;
Estado: \$host_state;
Ultimo Intento: \$host_last_attempt;
EOF

#######################################################################
# Configuration editor strings (all ENGLISH currently)
#######################################################################

$Lang{Only_privileged_users_can_edit_config_files} = "Only privileged users can edit configuation settings.";
$Lang{CfgEdit_Edit_Config} = "Edit Config";
$Lang{CfgEdit_Edit_Hosts}  = "Edit Hosts";

$Lang{CfgEdit_Title_Server} = "Server";
$Lang{CfgEdit_Title_General_Parameters} = "General Parameters";
$Lang{CfgEdit_Title_Wakeup_Schedule} = "Wakeup Schedule";
$Lang{CfgEdit_Title_Concurrent_Jobs} = "Concurrent Jobs";
$Lang{CfgEdit_Title_Pool_Filesystem_Limits} = "Pool Filesystem Limits";
$Lang{CfgEdit_Title_Other_Parameters} = "Other Parameters";
$Lang{CfgEdit_Title_Remote_Apache_Settings} = "Remote Apache Settings";
$Lang{CfgEdit_Title_Program_Paths} = "Program Paths";
$Lang{CfgEdit_Title_Install_Paths} = "Install Paths";
$Lang{CfgEdit_Title_Email} = "Email";
$Lang{CfgEdit_Title_Email_settings} = "Email settings";
$Lang{CfgEdit_Title_Email_User_Messages} = "Email User Messages";
$Lang{CfgEdit_Title_CGI} = "CGI";
$Lang{CfgEdit_Title_Admin_Privileges} = "Admin Privileges";
$Lang{CfgEdit_Title_Page_Rendering} = "Page Rendering";
$Lang{CfgEdit_Title_Paths} = "Paths";
$Lang{CfgEdit_Title_User_URLs} = "User URLs";
$Lang{CfgEdit_Title_User_Config_Editing} = "User Config Editing";
$Lang{CfgEdit_Title_Xfer} = "Xfer";
$Lang{CfgEdit_Title_Xfer_Settings} = "Xfer Settings";
$Lang{CfgEdit_Title_Ftp_Settings} = "FTP Settings";
$Lang{CfgEdit_Title_Smb_Settings} = "Smb Settings";
$Lang{CfgEdit_Title_Tar_Settings} = "Tar Settings";
$Lang{CfgEdit_Title_Rsync_Settings} = "Rsync Settings";
$Lang{CfgEdit_Title_Rsyncd_Settings} = "Rsyncd Settings";
$Lang{CfgEdit_Title_Archive_Settings} = "Archive Settings";
$Lang{CfgEdit_Title_Include_Exclude} = "Include/Exclude";
$Lang{CfgEdit_Title_Smb_Paths_Commands} = "Smb Paths/Commands";
$Lang{CfgEdit_Title_Tar_Paths_Commands} = "Tar Paths/Commands";
$Lang{CfgEdit_Title_Rsync_Paths_Commands_Args} = "Rsync Paths/Commands/Args";
$Lang{CfgEdit_Title_Rsyncd_Port_Args} = "Rsyncd Port/Args";
$Lang{CfgEdit_Title_Archive_Paths_Commands} = "Archive Paths/Commands";
$Lang{CfgEdit_Title_Schedule} = "Schedule";
$Lang{CfgEdit_Title_Full_Backups} = "Full Backups";
$Lang{CfgEdit_Title_Incremental_Backups} = "Incremental Backups";
$Lang{CfgEdit_Title_Blackouts} = "Blackouts";
$Lang{CfgEdit_Title_Other} = "Other";
$Lang{CfgEdit_Title_Backup_Settings} = "Backup Settings";
$Lang{CfgEdit_Title_Client_Lookup} = "Client Lookup";
$Lang{CfgEdit_Title_User_Commands} = "User Commands";
$Lang{CfgEdit_Title_Hosts} = "Hosts";

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

$Lang{CfgEdit_Button_Save}     = "Save";
$Lang{CfgEdit_Button_Insert}   = "Insert";
$Lang{CfgEdit_Button_Delete}   = "Delete";
$Lang{CfgEdit_Button_Add}      = "Add";
$Lang{CfgEdit_Button_Override} = "Override";
$Lang{CfgEdit_Button_New_Key}  = "New Key";

$Lang{CfgEdit_Error_No_Save}
            = "ENG Error: No save due to errors";
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
