#!/bin/perl -T

#my %lang;

#use strict;

# --------------------------------

$Lang{Start_Full_Backup} = "Comenzar copia de seguridad completa";
$Lang{Start_Incr_Backup} = "Comenzar copia de seguridad incremental";
$Lang{Stop_Dequeue_Backup} = "Parar/anular copia de seguridad";
$Lang{Restore} = "Restaurar";

# -----

$Lang{H_BackupPC_Server_Status} = "Estado del Servidor BackupPC";

$Lang{BackupPC_Server_Status}= <<EOF;
\${h1(qq{$Lang{H_BackupPC_Server_Status}})}


<p>
\${h2(\"Información General del servidor\")}

<ul>
<li> El PID del servidor es \$Info{pid}, en el host \$Conf{ServerHost},
     version \$Info{Version}, iniciado el \$serverStartTime.
<li> Esta información de estado se ha generado el \$now.
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

\${h2("Trabajos en Ejecución")}
<p>
<table border>
<tr><td> Host </td>
    <td> Tipo </td>
    <td> Usuario </td>
    <td> Hora de Inicio </td>
    <td> Comando </td>
    <td align="center"> PID </td>
    <td align="center"> Transfer. PID </td>
    </tr>
\$jobStr
</table>
<p>

\${h2("Fallos que Precisan Atención")}
<p>
<table border>
<tr><td align="center"> Host </td>
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
$Lang{BackupPC_Summary}=<<EOF;

\${h1(qq{$Lang{BackupPC__Server_Summary}})}
<p>
Este status ha sido generado el \$now.
<p>

\${h2("Hosts con Buenas Copias de Seguridad")}
<p>
Il y a \$hostCntGood hosts tienen copia de seguridad, de un total de :
<ul>
<li> \$fullTot copias de seguridad completas con tamaño total de \${fullSizeTot} GB
     (antes de agrupar y comprimir),
<li> \$incrTot copias de seguridad incrementales con tamaño total de \${incrSizeTot} GB
     (antes de agrupar y comprimir).
</ul>
<table border>
<tr><td> Host </td>
    <td align="center"> Usuario </td>
    <td align="center"> #Completo </td>
    <td align="center"> Completo Antig./Días </td>
    <td align="center"> Completo Tamaño/GB </td>
    <td align="center"> Velocidad MB/sec </td>
    <td align="center"> #Incrementales </td>
    <td align="center"> Incrementales Antig/Días </td>
    <td align="center"> Estado </td>
    <td align="center"> Ultimo Intento </td></tr>
\$strGood
</table>
<p>

\${h2("Hosts Sin Copias de Seguridad")}
<p>
Hay \$hostCntNone hosts sin copias de seguridad.
<p>
<table border>
<tr><td> Host </td>
    <td align="center"> Usuario </td>
    <td align="center"> #Completo </td>
    <td align="center"> Completo Antig./Días </td>
    <td align="center"> Completo Tamaño/GB </td>
    <td align="center"> Velocidad MB/sec </td>
    <td align="center"> #Incrementales </td>
    <td align="center"> Incrementales Antig/Días </td>
    <td align="center"> Estado </td>
    <td align="center"> Ultimo Intento </td></tr>
\$strNone
</table>
EOF

# -----------------------------------
$Lang{Pool_Stat} = <<EOF;
        <li>El grupo tiene \${poolSize}GB incluyendo \$info->{"\${name}FileCnt"} archivos
            y \$info->{"\${name}DirCnt"} directorios (as of \$poolTime),
        <li>El procesamiento del grupo da \$info->{"\${name}FileCntRep"} archivos
            repetidos cuya cadena más larga es \$info->{"\${name}FileRepMax"},
        <li>El proceso de limpieza nocturna ha eliminado \$info->{"\${name}FileCntRm"} archivos de
            tamaño \${poolRmSize}GB (around \$poolTime),
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

<form action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="hostIP" value="\$ipAddr">
<input type="hidden" name="doit" value="1">
¿Realmente quiere hacer esto?
<input type="submit" value="\$In{action}" name="action">
<input type="submit" value="No" name="">
</form>
EOF
# --------------------------------
$Lang{BackupPC__Stop_Backup_Confirm_on__host} = "BackupPC: Confirmación de Parada de Copia de Seguridad en \$host";
# --------------------------------
$Lang{Are_you_sure_stop} = <<EOF;

\${h1("¿Está seguro?")}

<p>
Está a punto de parar/quitar de la cola las copias de seguridad en \$host;

<form action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="doit" value="1">
Asimismo, por favor no empiece otra copia de seguridad durante
<input type="text" name="backoff" size="10" value="\$backoff"> horas.
<p>
¿Realmente quiere hacer esto?
<input type="submit" value="\$In{action}" name="action">
<input type="submit" value="No" name="">
</form>

EOF
# --------------------------------
$Lang{Only_privileged_users_can_view_queues_} = "Sólo los administradores pueden ver las colas.";
# --------------------------------
$Lang{BackupPC__Queue_Summary} = "BackupPC: Resumen de la Cola";
# --------------------------------
$Lang{Backup_Queue_Summary} = <<EOF;
\${h1("Resumen de la Cola de Copias de Seguridad")}
<p>
\${h2("Resumen de la Cola de Usuarios")}
<p>
Las siguientes solicitudes de usuarios están actualmente en cola:
<table border>
<tr><td> Host </td>
    <td> Hora Sol. </td>
    <td> Usuario </td></tr>
\$strUser
</table>
<p>

\${h2("Resumen de Cola en Segundo Plano")}
<p>
Las siguientes solicitudes en segundo plano están actualmente en cola:
<table border>
<tr><td> Host </td>
    <td> Hora Sol. </td>
    <td> Usuario </td></tr>
\$strBg
</table>
<p>

\${h2("Resumen de Cola de Comandos")}
<p>
Los siguientes comandos están actualmente en cola:
<table border>
<tr><td> Host </td>
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
<table border>
<tr><td align="center"> File </td>
    <td align="center"> Size </td>
    <td align="center"> Hora Modificación </td></tr>
\$str
</table>
EOF

# -------------------------------
$Lang{Recent_Email_Summary} = <<EOF;
\${h1("Resumen de Mensajes Recientes (Orden de tiempo inverso)")}
<p>
<table border>
<tr><td align="center"> Destinatario </td>
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
<p>
Ha seleccionado los siguientes archivos/directorios de
la unidad \$share, copia número #\$num:
<ul>
\$fileListStr
</ul>
<p>
Tiene tres opciones para restaurar estos archivos/directorios.
Por favor, seleccione una de las siguientes opciones.
<p>
\${h2("Opción 1: Restauración Directa")}
<p>
Puede empezar un proceso que restaurará estos archivos directamente en
\$host.
<p>
<b>¡Atención!:</b> ¡Cualquier archivo existente con el mismo nombre que los que ha
seleccionado será sobreescrito!

<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="3">
\$hiddenStr
<input type="hidden" value="\$In{action}" name="action">
<table border="0">
<tr>
    <td>Restaurar los archivos al host</td>
    <td><input type="text" size="40" value="\${EscHTML(\$host)}"
	 name="hostDest"></td>
</tr><tr>
    <td>Restaurar los archivos a la unidad</td>
    <td><input type="text" size="40" value="\${EscHTML(\$share)}"
	 name="shareDest"></td>
</tr><tr>
    <td>Restaurar los archivos bajo el directorio<br>(relativo a la unidad)</td>
    <td valign="top"><input type="text" size="40" maxlength="256"
	value="\${EscHTML(\$pathHdr)}" name="pathHdr"></td>
</tr><tr>
    <td><input type="submit" value="Start Restore" name=""></td>
</table>
</form>
EOF

# ------------------------------
$Lang{Option_2__Download_Zip_archive} = <<EOF;

\${h2("Opción 2: Descargar archivo Zip")}
<p>
Puede descargar un archivo comprimido (.zip) conteniendo todos los archivos y directorios que
ha seleccionado.  Después puede hacer uso de una aplicación local, como WinZip,
para ver o extraer cualquiera de los archivos.
<p>
<b>¡Atención!:</b> Dependiendo de que archivos/carpetas haya seleccionado,
este archivo puede ser muy grande. Podría tardar muchos minutos
crear y transferir el archivo. Además necesitará suficiente espacio el el disco
local para almacenarlo.
<p>
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
Compresión (0=desactivada, 1=rápida,...,9=máxima)
<input type="text" size="6" value="5" name="compressLevel">
<br>
<input type="submit" value="Download Zip File" name="">
</form>
EOF

# ------------------------------

$Lang{Option_2__Download_Zip_archive2} = <<EOF;
\${h2("Opción 2: Descargar archivo Zip")}
<p>
El programa Archive::Zip no está instalado, de modo que no podrá descargar un
archivo comprimido zip.
Por favor, solicite a su administrador de sistemas que instale Archive::Zip de
<a href="http://www.cpan.org">www.cpan.org</a>.
<p>
EOF


# ------------------------------
$Lang{Option_3__Download_Zip_archive} = <<EOF;
\${h2("Opción 3: Descargar archivo Tar")}
<p>
Puede descargar un archivo comprimido (.Tar) conteniendo todos los archivos y
directorios que ha seleccionado. Después puede hacer uso de una aplicación
local, como Tar o WinZip,para ver o extraer cualquiera de los archivos.
<p>
<b>¡Atención!:</b> Dependiendo de que archivos/carpetas haya seleccionado,
este archivo puede ser muy grande. Podría tardar muchos minutos
crear y transferir el archivo. Además necesitará suficiente espacio el el disco
local para almacenarlo.
<p>
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
<input type="submit" value="Download Tar File" name="">
</form>
EOF


# ------------------------------
$Lang{Restore_Confirm_on__host} = "BackupPC: Restore Confirm on \$host";

$Lang{Are_you_sure} = <<EOF;
\${h1("¿Está seguro?")}
<p>
Está a punto de comenzar una restauración directamente a la máquina \$In{hostDest}.
Los siguientes archivos serán restaurados en la unidad \$In{shareDest}, de
la copia de seguridad número \$num:
<p>
<table border>
<tr><td>Archivo/Dir Original </td><td>Será restaurado a</td></tr>
\$fileListStr
</table>

<form action="\$MyURL" method="post">
<input type="hidden" name="host" value="\${EscHTML(\$host)}">
<input type="hidden" name="hostDest" value="\${EscHTML(\$In{hostDest})}">
<input type="hidden" name="shareDest" value="\${EscHTML(\$In{shareDest})}">
<input type="hidden" name="pathHdr" value="\${EscHTML(\$In{pathHdr})}">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="type" value="4">
\$hiddenStr
Do you really want to do this?
<input type="submit" value="\$In{action}" name="action">
<input type="submit" value="No" name="">
</form>
EOF


# --------------------------
$Lang{Restore_Requested_on__hostDest} = "BackupPC: Restauración solicitada en \$hostDest";
$Lang{Reply_from_server_was___reply} = <<EOF;
\${h1(\$str)}
<p>
La respuesta del servidor fué: \$reply
<p>
Go back to <a href="\$MyURL?host=\$hostDest">\$hostDest home page</a>.
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

\${h2("Acciones del Usuario")}
<p>
<form action="\$MyURL" method="get">
<input type="hidden" name="host" value="\$host">
\$startIncrStr
<input type="submit" value="$Lang{Start_Full_Backup}" name="action">
<input type="submit" value="$Lang{Stop_Dequeue_Backup}" name="action">
</form>

\${h2("Resumen de Copia de Seguridad")}
<p>
Haga click en el número de copia de seguridad para revisar y restaurar archivos.
<table border>
<tr><td align="center"> Copia Nº </td>
    <td align="center"> Tipo </td>
    <td align="center"> Completo </td>
    <td align="center"> Fecha Inicio </td>
    <td align="center"> Duracion/mn </td>
    <td align="center"> Antigüedad/dias </td>
    <td align="center"> Ruta a la Copia en el Servidor </td>
</tr>
\$str
</table>
<p>

\$restoreStr

\${h2("Resumen de Errores de Transferencia")}
<p>
<table border>
<tr><td align="center"> Copia Nº </td>
    <td align="center"> Tipo </td>
    <td align="center"> Ver </td>
    <td align="center"> Nº Xfer errs </td>
    <td align="center"> Nº err. archivos </td>
    <td align="center"> Nº err. unidades </td>
    <td align="center"> Nº err. tar </td>
</tr>
\$errStr
</table>
<p>

\${h2("Resumen de Total/Tamaño de Archivos Reutilizados")}
<p>
Los archivos existentes son aquellos que ya están en el lote; los nuevos son
aquellos que se han añadido al lote.
Los archivos vacíos y los errores SMB no cuentan en las cifras de reutilizados
ni en la de nuevos.
<table border>
<tr><td colspan="2"></td>
    <td align="center" colspan="3"> Totales </td>
    <td align="center" colspan="2"> Archivos Existentes </td>
    <td align="center" colspan="2"> Archivos Nuevos </td>
</tr>
<tr>
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
<p>

\${h2("Resumen de Compresión")}
<p>
Efectividad de compresión para los archivos ya existentes en el lote y los
archivos nuevos comprimidos.
<table border>
<tr><td colspan="3"></td>
    <td align="center" colspan="3"> Archivos Existentes </td>
    <td align="center" colspan="3"> Archivos Nuevos </td>
</tr>
<tr><td align="center"> Copia Nº </td>
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
<p>
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

<ul>
<li> Está revisando la copia de seguridad Nº\$num, que comenzó hacia las \$backupTime
        (hace \$backupAge dias),
\$filledBackup
<li> Haga click en uno de los directorios de abajo para revisar sus contenidos,
<li> Haga click en un archivo para restaurarlo.
</ul>

\${h2("Contenido de \${EscHTML(\$dirDisplay)}")}
<form name="form1" method="post" action="\$MyURL">
<input type="hidden" name="num" value="\$num">
<input type="hidden" name="host" value="\$host">
<input type="hidden" name="share" value="\${EscHTML(\$share)}">
<input type="hidden" name="fcbMax" value="\$checkBoxCnt">
<input type="hidden" name="action" value="$Lang{Restore}">
<br>
<table>
<tr><td valign="top">
    <!--Navigate here:-->
    <br><table align="center" border="0" cellpadding="0" cellspacing="0" bgcolor="#ffffff">
    \$dirStr
    </table>
</td><td width="3%">
</td><td valign="top">
    <!--Restore files here:-->
    <br>
    <table cellpadding="0" cellspacing="0" bgcolor="#333333"><tr><td>
        <table border="0" width="100%" align="left" cellpadding="2" cellspacing="1">
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
</td></tr></table>
</form>
EOF

# ------------------------------
$Lang{Restore___num_details_for__host} = "BackupPC: Detalles de la restauración Nº\$num de \$host";

$Lang{Restore___num_details_for__host2 } = <<EOF;
\${h1("Detalles de la restauración Nº\$num de \$host")}
<p>
<table border>
<tr><td> Número </td><td> \$Restores[\$i]{num} </td></tr>
<tr><td> Solicitado por </td><td> \$RestoreReq{user} </td></tr>
<tr><td> Hora Petición </td><td> \$reqTime </td></tr>
<tr><td> Resultado </td><td> \$Restores[\$i]{result} </td></tr>
<tr><td> Mensaje de Error </td><td> \$Restores[\$i]{errorMsg} </td></tr>
<tr><td> Host Origen </td><td> \$RestoreReq{hostSrc} </td></tr>
<tr><td> Nº copia origen </td><td> \$RestoreReq{num} </td></tr>
<tr><td> Unidad origen </td><td> \$RestoreReq{shareSrc} </td></tr>
<tr><td> Host destino </td><td> \$RestoreReq{hostDest} </td></tr>
<tr><td> Unidad destino </td><td> \$RestoreReq{shareDest} </td></tr>
<tr><td> Hora comienzo </td><td> \$startTime </td></tr>
<tr><td> Duración </td><td> \$duration min </td></tr>
<tr><td> Número de archivos </td><td> \$Restores[\$i]{nFiles} </td></tr>
<tr><td> Tamaño total </td><td> \${MB} MB </td></tr>
<tr><td> Tasa de transferencia </td><td> \$MBperSec MB/sec </td></tr>
<tr><td> Errores creación Tar </td><td> \$Restores[\$i]{tarCreateErrs} </td></tr>
<tr><td> Errores de transferencia </td><td> \$Restores[\$i]{xferErrs} </td></tr>
<tr><td> Archivo registro de transferencia </td><td>
<a href="\$MyURL?action=view&type=RestoreLOG&num=\$Restores[\$i]{num}&host=\$host">View</a>,
<a href="\$MyURL?action=view&type=RestoreErr&num=\$Restores[\$i]{num}&host=\$host">Errors</a>
</tr></tr>
</table>
<p>
\${h1("Lista de Archivos/Directorios")}
<p>
<table border>
<tr><td>Dir/archivo original</td><td>Restaurado a</td></tr>
\$fileListStr
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
$Lang{Only_privileged_users_can_view_PC_summaries} = "Sólo los usuarios autorizados pueden ver los resúmenes de PC´s.";
$Lang{Only_privileged_users_can_stop_or_start_backups} = 
                  "Sólo los usuarios autorizados pueden comenzar a detener las copias"
		. " \${EscHTML(\$host)}.";
$Lang{Invalid_number__num} = "Número no válido \$num";
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
$Lang{Nice_try__but_you_can_t_put} = "Buen intento, pero no puede usar \'..\' en los nombres de archivo";
$Lang{Host__doesn_t_exist} = "El Host \${EscHTML(\$In{hostDest})} no existe";
$Lang{You_don_t_have_permission_to_restore_onto_host} = "No tiene autorización para restaurar en el host"
		    . " \${EscHTML(\$In{hostDest})}";
$Lang{Can_t_open_create} = "No puedo abrir/crear "
                    . "\${EscHTML(\"\$TopDir/pc/\$hostDest/\$reqFileName\")}";
$Lang{Only_privileged_users_can_restore_backup_files2} = "Sólo los usuarios autorizados pueden restaurar copias de seguridad"
                . " del host \${EscHTML(\$host)}.";
$Lang{Empty_host_name} = "Nombre de host vacío";
$Lang{Unknown_host_or_user} = "Unknown host or user \${EscHTML(\$host)}";
$Lang{Only_privileged_users_can_view_information_about} = "Sólo los usuarios autorizados pueden ver información del"
                . " host \${EscHTML(\$host)}." ;
$Lang{Only_privileged_users_can_view_restore_information} = "Sólo los usuarios autorizados pueden ver información de restauración.";
$Lang{Restore_number__num_for_host__does_not_exist} = "El número de restauración \$num del host \${EscHTML(\$host)} "
	        . " no existe.";

$Lang{Unable_to_connect_to_BackupPC_server} = "Imposible conectar al servidor BackupPC",
            "Este script CGI (\$MyURL) no puede conectar al servidor BackupPC"
          . " en \$Conf{ServerHost} puerto \$Conf{ServerPort}.  El error"
          . " fué: \$err.",
            "Quizá el servidor BackupPC no está activo o hay un "
          . " error de configuración. Por favor informe a su administrador de sistemas.";

$Lang{Can_t_find_IP_address_for} = "No puedo encontrar la dirección IP de \${EscHTML(\$host)}";
$Lang{host_is_a_DHCP_host} = <<EOF;
\$host es un host DHCP y yo no conozco su dirección IP. He comprobado el
nombre netbios de \$ENV{REMOTE_ADDR}\$tryIP, y he verificado que esa máquina
no es \$host.
<p>
Hasta que vea \$host en una dirección DHCP concreta, sólo puede
comenzar este proceso desde la propia máquina cliente.
EOF

########################
# ok you can do it then
########################

$Lang{Backup_requested_on_DHCP__host} = "Copia de seguridad solicitada en DHCP \$host (\$In{hostIP}) por"
		                      . " \$User desde \$ENV{REMOTE_ADDR}";

$Lang{Backup_requested_on__host_by__User} = "Copia de seguridad solicitada en \$host por \$User";
$Lang{Backup_stopped_dequeued_on__host_by__User} = "Copia de seguridad detenida/desprogramada en \$host por \$User";
$Lang{log_User__User_downloaded_tar_archive_for__host} = "El usuario del registro \$User ha descargado un archivo Tar para \$host,"
                           . " copia de seguridad \$num; los archivos eran: "
			   . " \${join(\", \", \@fileListTrim)}";

$Lang{log_User__User_downloaded_zip_archive_for__host}= "El usuario del registro \$User ha descargado un archivo Zip para \$host,"
                           . " copia de seguridad \$num; los archivos eran: "
                           . "\${join(\", \", \@fileListTrim)}";

$Lang{Restore_requested_to_host__hostDest__backup___num} = "Restauración solicitada para el host \$hostDest, copia de seguridad #\$num,"
	     . " por \$User desde \$ENV{REMOTE_ADDR}";

# -------------------------------------------------
# ------- Stuff that was forgotten ----------------
# -------------------------------------------------

$Lang{Status} = "Estado";
$Lang{PC_Summary} = "Resumen PC";
$Lang{LOG_file} = "Archivo Registro";
$Lang{Old_LOGs} = "Registros antiguos";
$Lang{Email_summary} = "Resumen correo";
$Lang{Config_file} = "Archivo configuración";
$Lang{Hosts_file} = "Archivo Hosts";
$Lang{Current_queues} = "Colas actuales";
$Lang{Documentation} = "Documentación";

$Lang{Host_or_User_name} = "<small>Host o usuario:</small>";
$Lang{Go} = "Aceptar";
$Lang{Hosts} = "Hosts";

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
<li>El último error fué \"\${EscHTML(\$StatusHost{error})}\"
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
veces consecutivas, no se le realizará copia de seguridad desde \$t0 hasta \$t1 en \$days.
EOF

$Lang{Backups_are_deferred_for_hours_hours_change_this_number} = <<EOF;
<li>Las copias de seguridad se retrasarán durante \$hours hours
(<a href=\"\$MyURL?action=Stop/Dequeue%20Backup&host=\$host\">Cambie este número</a>).
EOF

$Lang{tryIP} = " y \$StatusHost{dhcpHostIP}";

$Lang{Host_Inhost} = "Host \$In{host}";

$Lang{checkAll} = <<EOF;
<tr bgcolor="#ffffcc"><td>
<input type="checkbox" name="allFiles" onClick="return checkAll('allFiles');">&nbsp;Seleccionar todo
</td><td colspan="5" align="center">
<input type="submit" name="Submit" value="Restaurar los archivos seleccionados">
</td></tr>
EOF

$Lang{fileHeader} = <<EOF;
    <tr bgcolor="\$Conf{CgiHeaderBgColor}"><td align=center> Nombre</td>
       <td align="center"> Tipo</td>
       <td align="center"> Modo</td>
       <td align="center"> Nº</td>
       <td align="center"> Tamaño</td>
       <td align="center"> Hora Mod.</td>
    </tr>
EOF

$Lang{Home} = "Principal";
$Lang{Last_bad_XferLOG} = "Ultimo error en registro de transferencia";
$Lang{Last_bad_XferLOG_errors_only} = "Ultimo error en registro de transferencia (errores&nbsp;sólo)";

$Lang{This_display_is_merged_with_backup} = <<EOF;
<li> Esta pantalla está unida a la copia de seguridad Nº\$numF.
EOF

$Lang{Visit_this_directory_in_backup} = <<EOF;
<li> Explorar este directorio en copia de seguridad Nº\$otherDirs.
EOF

$Lang{Restore_Summary} = <<EOF;
\${h2("Resumen de Restauración")}
<p>
Haga click en el número de restauración para ver sus detalles.
<table border>
<tr><td align="center"> Restauración Nº </td>
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

$Lang{BackupPC__Documentation} = "BackupPC: Documentacion";

$Lang{No} = "no";
$Lang{Yes} = "si";

$Lang{The_directory_is_empty} = <<EOF;
<tr><td bgcolor="#ffffff">El directorio \${EscHTML(\$dirDisplay)} está vacio
</td></tr>
EOF

#$Lang{on} = "activo";
$Lang{off} = "inactivo";

$Lang{full} = "completo";
$Lang{incremental} = "incremental";

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
$Lang{Status_link_pending} = "conexión pendiente";
$Lang{Status_link_running} = "conexión en curso";

$Lang{Reason_backup_done} = "copia de seguridad realizada";
$Lang{Reason_restore_done} = "restauración realizada";
$Lang{Reason_nothing_to_do} = "nada por hacer";
$Lang{Reason_backup_failed} = "copia de seguridad fallida";
$Lang{Reason_no_ping} = "no hay ping";
$Lang{Reason_backup_canceled_by_user} = "copia cancelada por el usuario";

# ---------
# Email messages

# No backup ever
$Lang{EMailNoBackupEverSubj} = "BackupPC: ningúna copia de \$host ha tenido éxito";
$Lang{EMailNoBackupEverMesg} = <<'EOF';
To: $user$domain
cc:
Subject: $subj

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

#end of lang_en.pm
