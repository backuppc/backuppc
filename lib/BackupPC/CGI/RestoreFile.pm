#============================================================= -*-perl-*-
#
# BackupPC::CGI::RestoreFile package
#
# DESCRIPTION
#
#   This module implements the RestoreFile action for the CGI interface.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2003-2013  Craig Barratt
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
#========================================================================
#
# Version 4.0.0alpha3, released 1 Dec 2013.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

package BackupPC::CGI::RestoreFile;

use strict;
use BackupPC::CGI::Lib qw(:all);
use BackupPC::XS qw(:all);
use BackupPC::View;
use Encode qw/from_to decode_utf8/;

sub action
{
    my $num    = $In{num};
    my $share  = $In{share};
    my $dir    = $In{dir};

    ErrorExit(eval("qq{$Lang->{Invalid_number__num}}"))
                    if ( $num ne "" && $num !~ /^\d+$/ );
    ErrorExit($Lang->{Nice_try__but_you_can_t_put})
                     if ( $dir =~ m{(^|/)\.\.(/|$)} );

    restoreFile($In{host}, $num, $share, $dir);
}

sub restoreFile
{
    my($host, $num, $share, $dir, $skipHardLink, $origName) = @_;
    my($Privileged) = CheckPermission($host);

    #
    # Some common content (media) types from www.iana.org (via MIME::Types).
    #
    my $Ext2ContentType = {
	'asc'  => 'text/plain',
	'avi'  => 'video/x-msvideo',
	'bmp'  => 'image/bmp',
	'book' => 'application/x-maker',
	'cc'   => 'text/plain',
	'cpp'  => 'text/plain',
	'csh'  => 'application/x-csh',
	'csv'  => 'text/comma-separated-values',
	'c'    => 'text/plain',
	'deb'  => 'application/x-debian-package',
	'doc'  => 'application/msword',
	'dot'  => 'application/msword',
	'dtd'  => 'text/xml',
	'dvi'  => 'application/x-dvi',
	'eps'  => 'application/postscript',
	'fb'   => 'application/x-maker',
	'fbdoc'=> 'application/x-maker',
	'fm'   => 'application/x-maker',
	'frame'=> 'application/x-maker',
	'frm'  => 'application/x-maker',
	'gif'  => 'image/gif',
	'gtar' => 'application/x-gtar',
	'gz'   => 'application/x-gzip',
	'hh'   => 'text/plain',
	'hpp'  => 'text/plain',
	'h'    => 'text/plain',
	'html' => 'text/html',
	'htmlx'=> 'text/html',
	'htm'  => 'text/html',
	'iges' => 'model/iges',
	'igs'  => 'model/iges',
	'jpeg' => 'image/jpeg',
	'jpe'  => 'image/jpeg',
	'jpg'  => 'image/jpeg',
	'js'   => 'application/x-javascript',
	'latex'=> 'application/x-latex',
	'maker'=> 'application/x-maker',
	'mid'  => 'audio/midi',
	'midi' => 'audio/midi',
	'movie'=> 'video/x-sgi-movie',
	'mov'  => 'video/quicktime',
	'mp2'  => 'audio/mpeg',
	'mp3'  => 'audio/mpeg',
	'mpeg' => 'video/mpeg',
	'mpg'  => 'video/mpeg',
	'mpp'  => 'application/vnd.ms-project',
	'pdf'  => 'application/pdf',
	'pgp'  => 'application/pgp-signature',
	'php'  => 'application/x-httpd-php',
	'pht'  => 'application/x-httpd-php',
	'phtml'=> 'application/x-httpd-php',
	'png'  => 'image/png',
	'ppm'  => 'image/x-portable-pixmap',
	'ppt'  => 'application/powerpoint',
	'ppt'  => 'application/vnd.ms-powerpoint',
	'ps'   => 'application/postscript',
	'qt'   => 'video/quicktime',
	'rgb'  => 'image/x-rgb',
	'rtf'  => 'application/rtf',
	'rtf'  => 'text/rtf',
	'shar' => 'application/x-shar',
	'shtml'=> 'text/html',
	'swf'  => 'application/x-shockwave-flash',
	'tex'  => 'application/x-tex',
	'texi' => 'application/x-texinfo',
	'texinfo'=> 'application/x-texinfo',
	'tgz'  => 'application/x-gtar',
	'tiff' => 'image/tiff',
	'tif'  => 'image/tiff',
	'txt'  => 'text/plain',
	'vcf'  => 'text/x-vCard',
	'vrml' => 'model/vrml',
	'wav'  => 'audio/x-wav',
	'wmls' => 'text/vnd.wap.wmlscript',
	'wml'  => 'text/vnd.wap.wml',
	'wrl'  => 'model/vrml',
	'xls'  => 'application/vnd.ms-excel',
	'xml'  => 'text/xml',
	'xwd'  => 'image/x-xwindowdump',
	'z'    => 'application/x-compress',
	'zip'  => 'application/zip',
        %{$Conf{CgiExt2ContentType}},       # add site-specific values
    };
    if ( !$Privileged ) {
        ErrorExit(eval("qq{$Lang->{Only_privileged_users_can_restore_backup_files2}}"));
    }
    $bpc->ConfigRead($host);
    %Conf = $bpc->Conf();
    ServerConnect();
    ErrorExit($Lang->{Empty_host_name}) if ( $host eq "" );

    $dir = "/" if ( $dir eq "" );
    my @Backups = $bpc->BackupInfoRead($host);
    my $view = BackupPC::View->new($bpc, $host, \@Backups);
    my $a = $view->fileAttrib($num, $share, $dir);
    if ( $dir =~ m{(^|/)\.\.(/|$)} || !defined($a) ) {
        $dir = decode_utf8($dir);
        ErrorExit("Can't restore bad file ${EscHTML($dir)} (${EscHTML($num)}, ${EscHTML($share)})");
    }
    my $f = BackupPC::XS::FileZIO::open($a->{fullPath}, 0, $a->{compress});
    if ( !defined($f) ) {
        my $fullPath = decode_utf8($a->{fullPath});
        ErrorExit("Unable to open file ${EscHTML($fullPath)} (${EscHTML($num)}, ${EscHTML($share)})");
    }
    my $data;
    if ( !$skipHardLink && $a->{type} == BPC_FTYPE_HARDLINK ) {
	#
	# hardlinks should look like the file they point to
	#
	my $linkName;
        while ( $f->read(\$data, 65536) > 0 ) {
            $linkName .= $data;
        }
	$f->close;
	$linkName =~ s/^\.\///;
	restoreFile($host, $num, $share, $linkName, 1, $dir);
	return;
    }
    $bpc->ServerMesg("log User $User recovered file $host/$num:$share/$dir ($a->{fullPath})");
    $dir = $origName if ( defined($origName) );
    my $ext = $1 if ( $dir =~ /\.([^\/\.]+)$/ );
    my $contentType = $Ext2ContentType->{lc($ext)}
				    || "application/octet-stream";
    my $fileName = $1 if ( $dir =~ /.*\/(.*)/ );
    $fileName =~ s/"/\\"/g;

    print "Content-Type: $contentType\r\n";
    print "Content-Transfer-Encoding: binary\r\n";

    if ( $ENV{HTTP_USER_AGENT} =~ /\bmsie\b/i
                && $ENV{HTTP_USER_AGENT} !~ /\bopera\b/i ) {
        #
        # Convert to cp1252 for MS IE.  TODO: find a way to get IE
        # to accept UTF8 encoding.  Firefox accepts inline encoding
        # using the "=?UTF-8?B?base64?=" format, but IE doesn't.
        #
        from_to($fileName, "utf8", "cp1252")
                        if ( $Conf{ClientCharset} ne "" );
    }
    print "Content-Disposition: attachment; filename=\"$fileName\"\r\n\r\n";
    while ( $f->read(\$data, 1024 * 1024) > 0 ) {
        print $data;
    }
    $f->close;
}

1;
