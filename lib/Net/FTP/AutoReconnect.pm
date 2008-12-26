package Net::FTP::AutoReconnect;
our $VERSION = '0.2';

use warnings;
use strict;

use Net::FTP;

=head1 NAME

Net::FTP::AutoReconnect - FTP client class with automatic reconnect on failure

=head1 SYNOPSIS

C<Net::FTP::AutoReconnect> is a wrapper module around C<Net::FTP>.
For many commands, if anything goes wrong on the first try, it tries
to disconnect and reconnect to the server, restore the state to the
same as it was when the command was executed, then execute it again.
The state includes login credentials, authorize credentials, transfer
mode (ASCII or binary), current working directory, and any restart,
passive, or port commands sent.

=head1 DESCRIPTION

The goal of this method is to hide some implementation details of FTP
server systems from the programmer.  In particular, many FTP systems
will automatically disconnect a user after a relatively short idle
time or after a transfer is aborted.  In this case,
C<Net::FTP::AutoReconnect> will simply reconnect, send the commands
necessary to return your session to its previous state, then resend
the command.  If that fails, it will return the error.

It makes no effort to determine what sorts of errors are likely to
succeed when they're retried.  Partly that's because it's hard to
know; if you're retreiving a file from an FTP site with several
mirrors and the file is not found, for example, maybe on the next try
you'll connect to a different server and find it.  But mostly it's
from laziness; if you have some good ideas about how to determine when
to retry and when not to bother, by all means send patches.

This module contains an instance of C<Net::FTP>, which it passes most
method calls along to.

These methods also record their state: C<alloc>, C<ascii>,
C<authorize>, C<binary>, C<cdup>, C<cwd>, C<hash>,
C<login>,C<restart>, C<pasv>, C<port>.  Directory changing commands
execute a C<pwd> afterwards and store their new working directory.

These methods are automatically retried: C<alloc>, C<appe>, C<append>,
C<ascii>, C<binary>, C<cdup>, C<cwd>, C<delete>, C<dir>, C<get>,
C<list>, C<ls>, C<mdtm>, C<mkdir>, C<nlst>, C<pasv>, C<port>, C<put>,
C<put_unique>, C<pwd>, C<rename>, C<retr>, C<rmdir>, C<size>, C<stou>,
C<supported>.

These methods are tried just once: C<abort>, C<authorize>, C<hash>,
C<login>, C<pasv_xfer>, C<pasv_xfer_unique>, C<pasv_wait>, C<quit>,
C<restart>, C<site>, C<unique_name>.  From C<Net::Cmd>: C<code>,
C<message>, C<ok>, C<status>.  C<restart> doesn't actually send any
FTP commands (they're sent along with the command they apply to),
which is why it's not restarted.

Any other commands are unimplemented (or possibly misdocumented); if I
missed one you'd like, please send a patch.

=head2 CONSTRUCTOR

=head3 new

All parameters are passed along verbatim to C<Net::FTP>, as well as
stored in case we have to reconnect.

=cut
  ;

sub new {
  my $self = {};
  my $class = shift;
  bless $self,$class;

  $self->{newargs} = \@_;
  $self->reconnect();

  $self;
}

=head2 METHODS

Most of the methods are those of L<Net::FTP|Net::FTP>.  One additional
method is available:

=head3 reconnect()

Abandon the current FTP connection and create a new one, restoring all
the state we can.

=cut
  ;

sub reconnect
{
  my $self = shift;

  warn "Reconnecting!\n"
    if ($ENV{DEBUG});

  $self->{ftp} = Net::FTP->new(@{$self->{newargs}})
    or die "Couldn't create new FTP object\n";

  if ($self->{login})
  {
    $self->{ftp}->login(@{$self->{login}});
  }
  if ($self->{authorize})
  {
    $self->{ftp}->authorize(@{$self->{authorize}});
  }
  if ($self->{mode})
  {
    if ($self->{mode} eq 'ascii')
    {
      $self->{ftp}->ascii();
    }
    else
    {
      $self->{ftp}->binary();
    }
  }
  if ($self->{cwd})
  {
    $self->{ftp}->cwd($self->{cwd});
  }
  if ($self->{hash})
  {
    $self->{ftp}->hash(@{$self->{hash}});
  }
  if ($self->{restart})
  {
    $self->{ftp}->restart(@{$self->{restart}});
  }
  if ($self->{alloc})
  {
    $self->{ftp}->restart(@{$self->{alloc}});
  }
  if ($self->{pasv})
  {
    $self->{ftp}->pasv(@{$self->{pasv}});
  }
  if ($self->{port})
  {
    $self->{ftp}->port(@{$self->{port}});
  }
}

sub _auto_reconnect
{
  my $self = shift;
  my($code)=@_;

  my $ret = $code->();
  if (!defined($ret))
  {
    $self->reconnect();
    $ret = $code->();
  }
  $ret;
}

sub _after_pcmd
{
  my $self = shift;
  my($r) = @_;
  if ($r)
  {
    # succeeded
    delete $self->{port};
    delete $self->{pasv};
    delete $self->{restart};
    delete $self->{alloc};
  }
  $r;
}


sub login
{
  my $self = shift;

  $self->{login} = \@_;
  $self->{ftp}->login(@_);
}

sub authorize
{
  my $self = shift;
  $self->{authorize} = \@_;
  $self->{ftp}->authorize(@_);
}

sub site
{
  my $self = shift;
  $self->{ftp}->site(@_);
}

sub ascii
{
  my $self = shift;
  $self->{mode} = 'ascii';
  $self->_auto_reconnect(sub { $self->{ftp}->ascii() });
}

sub binary
{
  my $self = shift;
  $self->{mode} = 'binary';
  $self->_auto_reconnect(sub { $self->{ftp}->binary() });
}

sub rename
{
  my $self = shift;
  my @a = @_;
  $self->_auto_reconnect(sub { $self->{ftp}->rename(@a) });
}

sub delete
{
  my $self = shift;
  my @a = @_;
  $self->_auto_reconnect(sub { $self->{ftp}->delete(@a) });
}

sub cwd
{
  my $self = shift;
  my @a = @_;
  my $ret = $self->_auto_reconnect(sub { $self->{ftp}->cwd(@a) });
  if (defined($ret))
  {
    $self->{cwd} = $self->{ftp}->pwd()
      or die "Couldn't get directory after cwd\n";
  }
  $ret;
}

sub cdup
{
  my $self = shift;
  my @a = @_;
  my $ret = $self->_auto_reconnect(sub { $self->{ftp}->cdup(@a) });
  if (defined($ret))
  {
    $self->{cwd} = $self->{ftp}->pwd()
      or die "Couldn't get directory after cdup\n";
  }
  $ret;
}

sub pwd
{
  my $self = shift;
  my @a = @_;
  $self->_auto_reconnect(sub { $self->{ftp}->pwd(@a) });
}

sub rmdir
{
  my $self = shift;
  my @a = @_;
  $self->_auto_reconnect(sub { $self->{ftp}->rmdir(@a) });
}

sub mkdir
{
  my $self = shift;
  my @a = @_;
  $self->_auto_reconnect(sub { $self->{ftp}->mkdir(@a) });
}

sub ls
{
  my $self = shift;
  my @a = @_;
  my $ret = $self->_auto_reconnect(sub { $self->{ftp}->ls(@a) });
  return $ret ? (wantarray ? @$ret : $ret) : undef;
}

sub dir
{
  my $self = shift;
  my @a = @_;
  my $ret = $self->_auto_reconnect(sub { $self->{ftp}->dir(@a) });
  return $ret ? (wantarray ? @$ret : $ret) : undef;
}

sub restart
{
  my $self = shift;
  my @a = @_;
  $self->{restart} = \@a;
  $self->{ftp}->restart(@_);
}

sub retr
{
  my $self = shift;
  my @a = @_;
  $self->_after_pcmd($self->_auto_reconnect(sub { $self->{ftp}->retr(@a) }));
}

sub get
{
  my $self = shift;
  my @a = @_;
  $self->_auto_reconnect(sub { $self->{ftp}->get(@a) });
}

sub mdtm
{
  my $self = shift;
  my @a = @_;
  $self->_auto_reconnect(sub { $self->{ftp}->mdtm(@a) });
}

sub size
{
  my $self = shift;
  my @a = @_;
  $self->_auto_reconnect(sub { $self->{ftp}->size(@a) });
}

sub abort
{
  my $self = shift;
  $self->{ftp}->abort();
}

sub quit
{
  my $self = shift;
  $self->{ftp}->quit();
}

sub hash
{
  my $self = shift;
  my @a = @_;
  $self->{hash} = \@a;
  $self->{ftp}->hash(@_);
}

sub alloc
{
  my $self = shift;
  my @a = @_;
  $self->{alloc} = \@a;
  $self->_auto_reconnect(sub { $self->{ftp}->alloc(@a) });
}

sub put
{
  my $self = shift;
  my @a = @_;
  $self->_auto_reconnect(sub { $self->{ftp}->put(@a) });
}

sub put_unique
{
  my $self = shift;
  my @a = @_;
  $self->_auto_reconnect(sub { $self->{ftp}->put_unique(@a) });
}

sub append
{
  my $self = shift;
  my @a = @_;
  $self->_auto_reconnect(sub { $self->{ftp}->append(@a) });
}

sub unique_name
{
  my $self = shift;
  $self->{ftp}->unique_name(@_);
}

sub supported
{
  my $self = shift;
  my @a = @_;
  $self->_auto_reconnect(sub { $self->{ftp}->supported(@a) });
}

sub port
{
  my $self = shift;
  my @a = @_;
  $self->{port} = \@a;
  $self->_auto_reconnect(sub { $self->{ftp}->port(@a) });
}

sub pasv
{
  my $self = shift;
  my @a = @_;
  $self->{pasv} = \@a;
  $self->_auto_reconnect(sub { $self->{ftp}->pasv(@a) });
}

sub nlst
{
  my $self = shift;
  my @a = @_;
  $self->_after_pcmd($self->_auto_reconnect(sub { $self->{ftp}->nlst(@a) }));
}

sub stou
{
  my $self = shift;
  my @a = @_;
  $self->_after_pcmd($self->_auto_reconnect(sub { $self->{ftp}->stou(@a) }));
}

sub appe
{
  my $self = shift;
  my @a = @_;
  $self->_after_pcmd($self->_auto_reconnect(sub { $self->{ftp}->appe(@a) }));
}

sub list
{
  my $self = shift;
  my @a = @_;
  $self->_after_pcmd($self->_auto_reconnect(sub { $self->{ftp}->list(@a) }));
}

sub pasv_xfer
{
  my $self = shift;
  $self->{ftp}->pasv_xfer(@_);
}

sub pasv_xfer_unique
{
  my $self = shift;
  $self->{ftp}->pasv_xfer_unique(@_);
}

sub pasv_wait
{
  my $self = shift;
  $self->{ftp}->pasv_wait(@_);
}

sub message
{
  my $self = shift;
  $self->{ftp}->message(@_);
}

sub code
{
  my $self = shift;
  $self->{ftp}->code(@_);
}

sub ok
{
  my $self = shift;
  $self->{ftp}->ok(@_);
}

sub status
{
  my $self = shift;
  $self->{ftp}->status(@_);
}

=head1 AUTHOR

Scott Gifford <sgifford@suspectclass.com>

=head1 BUGS

We should really be smarter about when to retry.

We shouldn't be hardwired to use C<Net::FTP>, but any FTP-compatible
class; that would allow all modules similar to this one to be chained
together.

Much of this is only lightly tested; it's hard to find an FTP server
unreliable enough to test all aspects of it.  It's mostly been tested
with a server that dicsonnects after an aborted transfer, and the
module seems to work OK.

=head1 SEE ALSO

L<Net::FTP>.

=head1 COPYRIGHT

Copyright (c) 2006 Scott Gifford. All rights reserved.  This program
is free software; you can redistribute it and/or modify it under the
same terms as Perl itself.

=cut

1;
