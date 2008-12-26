package Net::FTP::RetrHandle;
our $VERSION = '0.2';

use warnings;
use strict;

use constant DEFAULT_MAX_SKIPSIZE => 1024 * 1024 * 2;
use constant DEFAULT_BLOCKSIZE => 10240; # Net::FTP's default

use base 'IO::Seekable';
# We don't use base 'IO::Handle'; it currently confuses Archive::Zip.

use Carp;
use Scalar::Util;


=head1 NAME

Net::FTP::RetrHandle - Tied or IO::Handle-compatible interface to a file retrieved by FTP

=head1 SYNOPSIS

Provides a file reading interface for reading all or parts of files
located on a remote FTP server, including emulation of C<seek> and
support for downloading only the parts of the file requested.

=head1 DESCRIPTION

Support for skipping the beginning of the file is implemented with the
FTP C<REST> command, which starts a retrieval at any point in the
file.  Support for skipping the end of the file is implemented with
the FTP C<ABOR> command, which stops the transfer.  With these two
commands and some careful tracking of the current file position, we're
able to reliably emulate a C<seek/read> pair, and get only the parts
of the file that are actually read.

This was originally designed for use with
L<Archive::Zip|Archive::Zip>; it's reliable enough that the table of
contents and individual files can be extracted from a remote ZIP
archive without downloading the whole thing.  See L<EXAMPLES> below.

An interface compatible with L<IO::Handle|IO::Handle> is provided,
along with a C<tie>-based interface.

Remember that an FTP server can only do one thing at a time, so make
sure to C<close> your connection before asking the FTP server to do
nything else.

=head1 CONSTRUCTOR

=head2 new ( $ftp, $filename, options... )

Creates a new L<IO::Handle|IO::Handle>-compatible object to fetch all
or parts of C<$filename> using the FTP connection C<$ftp>.

Available options:

=over 4

=item MaxSkipSize => $size

If we need to move forward in a file or close the connection,
sometimes it's faster to just read the bytes we don't need than to
abort the connection and restart. This setting tells how many
unnecessary bytes we're willing to read rather than abort.  An
appropriate setting depends on the speed of transferring files and the
speed of reconnecting to the server.

=item BlockSize => $size

When doing buffered reads, how many bytes to read at once.  The
default is the same as the default for L<Net::FTP|Net::FTP>, so it's
generally best to leave it alone.

=item AlreadyBinary => $bool

If set to a true value, we assume the server is already in binary
mode, and don't try to set it.

=back

=cut
use constant USAGE => "Usage: Net::FTP::RetrHandle\->new(ftp => \$ftp_obj, filename => \$filename)\n";
sub new
{
  my $class = shift;
  my $ftp = shift
    or croak USAGE;
  my $filename = shift
    or croak USAGE;
  my $self = { MaxSkipSize => DEFAULT_MAX_SKIPSIZE,
	       BlockSize => DEFAULT_BLOCKSIZE,
	       @_,
	       ftp => $ftp, filename => $filename,
	       pos => 0, nextpos => 0};
  $self->{size} = $self->{ftp}->size($self->{filename})
    or return undef;
  $self->{ftp}->binary()
    unless ($self->{AlreadyBinary});

  bless $self,$class;
}

=head1 METHODS

Most of the methods implemented behave exactly like those from
L<IO::Handle|IO::Handle>.

These methods are implemented: C<binmode>, C<clearerr>, C<close>, C<eof>,
C<error>, C<getc>, C<getline>, C<getlines>, C<getpos>, C<read>,
C<seek>, C<setpos>, C<sysseek>, C<tell>, C<ungetc>, C<opened>.

=cut ;

sub opened { 1; }

sub seek
{
  my $self = shift;
  my $pos = shift || 0;
  my $whence = shift || 0;
  warn "   SEEK: self=$self, pos=$pos, whence=$whence\n"
    if ($ENV{DEBUG});
  my $curpos = $self->tell();
  my $newpos = _newpos($self->tell(),$self->{size},$pos,$whence);
  my $ret;
  if ($newpos == $curpos)
  {
    return $curpos;
  }
  elsif (defined($self->{_buf}) and ($newpos > $curpos) and ($newpos < ($curpos + length($self->{_buf}))))
  {
    # Just seeking within the buffer (or not at all)
    substr($self->{_buf},0,$newpos - $curpos,'');
    $ret = $newpos;
  }
  else
  {
    $ret = $self->sysseek($newpos,0);
    $self->{_buf} = '';
  }
  return $ret;
}

sub _newpos
{
  
  my($curpos,$size,$pos,$whence)=@_;
  if ($whence == 0) # seek_set
  {
    return $pos;
  }
  elsif ($whence == 1) # seek_cur
  {
    return $curpos + $pos;
  }
  elsif ($whence == 2) # seek_end
  {
    return $size + $pos;
  }
  else
  {
    die "Invalid value $whence for whence!";
  }
}

sub sysseek
{
  my $self = shift;
  my $pos = shift || 0;
  my $whence = shift || 0;
  warn "SYSSEEK: self=$self, pos=$pos, whence=$whence\n"
    if ($ENV{DEBUG});
  my $newpos = _newpos($self->{nextpos},$self->{size},$pos,$whence);

  $self->{eof}=undef;
  return $self->{nextpos}=$newpos;
}

sub tell
{
  my $self = shift;
  return $self->{nextpos} - (defined($self->{_buf}) ? length($self->{_buf}) : 0);
}

# WARNING: ASCII mode probably breaks seek.
sub binmode
{
  my $self = shift;
  my $mode = shift || ':raw';
  return if (defined($self->{curmode}) && ($self->{curmode} eq $mode));
  if (defined($mode) and $mode eq ':crlf')
  {
    $self->_finish_connection();
    $self->{ftp}->ascii()
      or return $self->seterr();
  }
  else
  {
    $self->_finish_connection();
    $self->{ftp}->binary()
      or return $self->seterr();
  }
  $self->{curmode} = $mode;
}

sub _min
{
  return $_[0] < $_[1] ? $_[0] : $_[1];
}

sub _max
{
  return $_[0] > $_[1] ? $_[0] : $_[1];
}

sub read
{
  my $self = shift;
#  return $self->sysread(@_);
  
  my(undef,$len,$offset)=@_;
  $offset ||= 0;
  warn "READ(buf,$len,$offset)\n"
    if ($ENV{DEBUG});
  
  if (!defined($self->{_buf}) || length($self->{_buf}) <= 0)
  {
    $self->sysread($self->{_buf},_max($len,$self->{BlockSize}))
      or return 0;
  }
  elsif (length($self->{_buf}) < $len)
  {
    $self->sysread($self->{_buf},_max($len-length($self->{_buf}),$self->{BlockSize}),length($self->{_buf}));
  }
  my $ret = _min($len,length($self->{_buf}));
  if (!defined($_[0])) { $_[0] = '' }
  substr($_[0],$offset) = substr($self->{_buf},0,$len,'');
  $self->{read_count}++;

  return $ret;
}

sub sysread
{
  my $self = shift;
  if ($self->{eof})
  {
    return 0;
  }
  
  my(undef,$len,$offset) = @_;
  $offset ||= 0;

  warn "SYSREAD(buf,$len,$offset)\n"
    if ($ENV{DEBUG});
  if ($self->{nextpos} >= $self->{size})
  {
    $self->{eof} = 1;
    $self->{pos} = $self->{nextpos};
    return 0;
  }

  if ($self->{pos} != $self->{nextpos})
  {
    # They seeked.
    if ($self->{ftp_running})
    {
      warn "Seek detected, nextpos=$self->{nextpos}, pos=$self->{pos}, MaxSkipSize=$self->{MaxSkipSize}\n"
	if ($ENV{DEBUG});
      if ($self->{nextpos} > $self->{pos} and ($self->{nextpos} - $self->{pos}) < $self->{MaxSkipSize})
      {
	my $br = $self->{nextpos}-$self->{pos};
	warn "Reading $br bytes to skip ahead\n"
	  if ($ENV{DEBUG});
	my $junkbuff;
	while ($br > 0)
	{
	  warn "Trying to read $br more bytes\n"
	    if ($ENV{DEBUG});
	  my $b = $self->{ftp_data}->read($junkbuff,$br);
	  if ($b == 0)
	  {
	    $self->_at_eof();
	    return 0;
	  }
	  elsif (!defined($b) || $b < 0)
	  {
	    return $self->seterr();
	  }
	  else
	  {
	    $br -= $b;
	  }
	}
	$self->{pos}=$self->{nextpos};
      }
      else
      {
	warn "Aborting connection to move to new position\n"
	  if ($ENV{DEBUG});
	$self->_finish_connection();
      }
    }
  }

  if (!$self->{ftp_running})
  {
    $self->{ftp}->restart($self->{nextpos});
    $self->{ftp_data} = $self->{ftp}->retr($self->{filename})
      or return $self->seterr();
    $self->{ftp_running} = 1;
    $self->{pos}=$self->{nextpos};
  }

  my $tmpbuf;
  my $rb = $self->{ftp_data}->read($tmpbuf,$len);
  if ($rb == 0)
  {
    $self->_at_eof();
    return 0;
  }
  elsif (!defined($rb) || $rb < 0)
  {
    return $self->seterr();
  }

  if (!defined($_[0])) { $_[0] = '' }
  substr($_[0],$offset) = $tmpbuf;
  $self->{pos} += $rb;
  $self->{nextpos} += $rb;

  $self->{sysread_count}++;
  $rb;
}

sub _at_eof
{
  my $self = shift;
  $self->{eof}=1;
  $self->_finish_connection();
#  $self->{ftp_data}->_close();
  $self->{ftp_running} = $self->{ftp_data} = undef;
}
  
sub _finish_connection
{
  my $self = shift;
  warn "_finish_connection\n"
    if ($ENV{DEBUG});
  return unless ($self->{ftp_running});
  
  if ($self->{size} - $self->{pos} < $self->{MaxSkipSize})
  {
    warn "Skipping " . ($self->{size}-$self->{pos}) . " bytes\n"
      if ($ENV{DEBUG});
    my $junkbuff;
    my $br;
    while(($br = $self->{ftp_data}->read($junkbuff,8192)))
    {
      # Read until EOF or error
    }
    defined($br)
      or $self->seterr();
  }
  warn "Shutting down existing FTP DATA session...\n"
    if ($ENV{DEBUG});

  my $closeret;
  {
    eval {
      $closeret = $self->{ftp_data}->close();
    };
    # Work around a timeout bug in Net::FTP
    if ($@ && $@ =~ /^Timeout /)
    {
      warn "Timeout closing connection, retrying...\n"
	if ($ENV{DEBUG});
      select(undef,undef,undef,1);
      redo;
    }
  }

  $self->{ftp_running} = $self->{ftp_data} = undef;
  return $closeret ? 1 : $self->seterr();
}

sub write
{
  die "Only reading currently supported";
}

sub close
{
  my $self = shift;
  return $self->{ftp_data} ? $self->_finish_connection()
                           : 1;
}

sub eof
{
  my $self = shift;
  if ($self->{eof})
  {
    return 1;
  }

  my $c = $self->getc;
  if (!defined($c))
  {
    return 1;
  }
  $self->ungetc(ord($c));
  return undef;
}

sub getc
{
  my $self = shift;
  my $c;
  my $rb = $self->read($c,1);
  if ($rb < 1)
  {
    return undef;
  }
  return $c;
}

sub ungetc
{
  my $self = shift;
  # Note that $c is the ordinal value of a character, not the
  # character itself (for some reason)
  my($c)=@_;
  $self->{_buf} = chr($c) . $self->{_buf};
}

sub getline
{
  my $self = shift;
  if (!defined($/))
  {
    my $buf;
    while($self->read($buf,$self->{BlockSize},length($buf)) > 0)
    {
      # Keep going
    }
    return $buf;
  }
  elsif (ref($/) && looks_like_number ${$/} )
  {
    my $buf;
    $self->read($buf,${$/})
      or return undef;
    return $buf;
  }

  my $rs;
  if ($/ eq '')
  {
    $rs = "\n\n";
  }
  else
  {
    $rs = $/;
  }
  my $eol;
  if (!defined($self->{_buf})) { $self->{_buf} = '' }
  while (($eol=index($self->{_buf},$rs)) < $[)
  {
    if ($self->{eof})
    {
      # return what's left
      if (length($self->{_buf}) == 0)
      {
	return undef;
      }
      else
      {
	return substr($self->{_buf},0,length($self->{_buf}),'');
      }
    }
    else
    {
      $self->sysread($self->{_buf},$self->{BlockSize},length($self->{_buf}));
    }
  }
  # OK, we should have a match.
  my $tmpbuf = substr($self->{_buf},0,$eol+length($rs),'');
  while ($/ eq '' and substr($self->{_buf},0,1) eq "\n")
  {
    substr($self->{_buf},0,1)='';
  }
  return $tmpbuf;
}

sub getlines
{
  my $self = shift;
  my @lines;
  my $line;
  while (defined($line = $self->getline()))
  {
    push(@lines,$line);
  }
  @lines;
}

sub error
{
  return undef;
}

sub seterr
{
  my $self = shift;
  $self->{_error} = 1;
  return undef;
}

sub clearerr
{
  my $self = shift;
  $self->{_error} = undef;
  return 0;
}

sub getpos
{
  my $self = shift;
  return $self->tell();
}

sub setpos
{
  my $self = shift;
  return $self->seek(@_);
}

sub DESTROY
{
  my $self = shift;
  if (UNIVERSAL::isa($self,'GLOB'))
  {
    $self = tied *$self
	or die "$self not tied?...";
  }
  if ($self->{ftp_data})
  {
    $self->_finish_connection();
  }
  warn "sysread called ".$self->{sysread_count}." times.\n"
    if ($ENV{DEBUG});
}

=head1 TIED INTERFACE

Instead of a L<IO::Handle|IO::Handle>-compatible interface, you can
use a C<tie>-based interface to use the standard Perl I/O operators.
You can use it like this:

  use Net::FTP::RetrHandle;
  # Create FTP object in $ftp
  # Store filename in $filename
  tie *FH, 'Net::FTP::RetrHandle', $ftp, $filename
    or die "Error in tie!\n";

=cut
  ;
sub TIEHANDLE
{
  my $class = shift;
  my $obj = $class->new(@_);
  $obj;
}

sub READ
{
  my $self = shift;
  $self->read(@_);
}

sub READLINE
{
  my $self = shift;
  return wantarray ? $self->getlines(@_)
                   : $self->getline(@_);
}

sub GETC
{
  my $self = shift;
  return $self->getc(@_);
}

sub SEEK
{
  my $self = shift;
  return $self->seek(@_);
}

sub SYSSEEK
{
  my $self = shift;
  return $self->sysseek(@_);
}

sub TELL
{
  my $self = shift;
  return $self->tell();
}

sub CLOSE
{
  my $self = shift;
  return $self->close(@_);
}

sub EOF
{
  my $self = shift;
  return $self->eof(@_);

}
sub UNTIE
{
  tied($_[0])->close(@_);
}

=head1 EXAMPLE

Here's an example of listing a Zip file without downloading the whole
thing:

    #!/usr/bin/perl
    
    use warnings;
    use strict;
    
    use Net::FTP;
    use Net::FTP::AutoReconnect;
    use Net::FTP::RetrHandle;
    use Archive::Zip;
    
    my $ftp = Net::FTP::AutoReconnect->new("ftp.info-zip.com", Debug => $ENV{DEBUG}) 
        or die "connect error\n";
    $ftp->login('anonymous','example@example.com')
        or die "login error\n";
    $ftp->cwd('/pub/infozip/UNIX/LINUX')
        or die "cwd error\n";
    my $fh = Net::FTP::RetrHandle->new($ftp,'unz551x-glibc.zip')
        or die "Couldn't get handle to remote file\n";
    my $zip = Archive::Zip->new($fh)
        or die "Couldn't create Zip object\n";
    foreach my $fn ($zip->memberNames())
    {
      print "unz551-glibc.zip: $fn\n";
    }


=head1 AUTHOR

Scott Gifford <sgifford@suspectclass.com>

=head1 BUGS

The distinction between tied filehandles and C<IO::Handle>-compatible
filehandles should be blurrier.  It seems like other file handle
objects you can freely mix method calls and traditional Perl
operations, but I can't figure out how to do it.

Many FTP servers don't like frequent connection aborts.  If that's the
case, try L<Net::FTP::AutoReconnect>, which will hide much of that
from you.

If the filehandle is tied and created with C<gensym>, C<readline>
doesn't work with older versions of Perl.  No idea why.

=head1 SEE ALSO

L<Net::FTP>, L<Net::FTP::AutoReconnect>, L<IO::Handle>.

=head1 COPYRIGHT

Copyright (c) 2006 Scott Gifford. All rights reserved.  This program
is free software; you can redistribute it and/or modify it under the
same terms as Perl itself.

=cut

1;
