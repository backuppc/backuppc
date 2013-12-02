#============================================================= -*-perl-*-
#
# BackupPC::Xfer::Protocol package
#
# DESCRIPTION
#
#   This library defines a BackupPC::Xfer::Protocol class which
#   defines standard methods for the transfer protocols in BackupPC.
#
# AUTHOR
#   Paul Mantz    <pcmantz@zmanda.com>
#
# COPYRIGHT
#   Copyright (C) 2001-2013  Craig Barratt
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

package BackupPC::Xfer::Protocol;

use strict;
use Data::Dumper;
use Encode qw/from_to encode/;

#    
#  usage: 
#    $t = BackupPC::Xfer::Protocol->new($args);
#
# new() is the constructor.  There's nothing special going on here.
#    
sub new
{
    my($class, $bpc, $args) = @_;

    $args ||= {};
    my $t = bless {
        bpc       => $bpc,
        conf      => $bpc->{Conf},
        host      => "",
        hostIP    => "",
        shareName => "",
        pipeRH    => undef,
        pipeWH    => undef,
        badFiles  => [],
        logLevel  => $bpc->{Conf}{XferLogLevel},

        #
        # Various stats
        #
        byteCnt         => 0,
        fileCnt         => 0,
        xferErrCnt      => 0,
        xferBadShareCnt => 0,
        xferBadFileCnt  => 0,
        xferOK          => 0,

        #
        # User's args
        #
        %$args,
    }, $class;

    return $t;
}

#    
#  usage:
#    $t->args($args);
#
# args() can be used to send additional argument to the Xfer object
# via a hash reference.
#    
sub args
{
    my($t, $args) = @_;

    foreach my $arg ( keys(%$args) ) {
        $t->{$arg} = $args->{$arg};
    }
}

#
#  usage:
#    $t->start();
#
# start() executes the actual data transfer.  Must be implemented by
# the derived class.
#
sub start
{
    my($t) = @_;

    $t->{_errStr} = "start() not implemented by ".ref($t);
    return;
}

#
#
#
sub run
{
    my($t) = @_;

    $t->{_errStr} = "run() not implemented by ".ref($t);
    return;
}

#
#  usage:
#    $t->readOutput();
#
# This function is only used when $t->useTar() == 1.
#
sub readOutput
{
    my($t) = @_;

    $t->{_errStr} = "readOutput() not implemented by " . ref($t);
    return;
}

#
#  usage:
#    $t->abort($reason);
#
# Aborts the current job.
#
sub abort
{
    my($t, $reason) = @_;
    my @xferPid = $t->xferPid;

    $t->{abort}       = 1;
    $t->{abortReason} = $reason;
    if ( @xferPid ) {
        kill($t->{bpc}->sigName2num("INT"), @xferPid);
    }
}

#
#  usage:
#    $t->subSelectMask
#
# This function sets a mask for files when ($t->useTar == 1).
#
sub setSelectMask
{
    my($t) = @_;

    $t->{_errStr} = "readOutput() not implemented by " . ref($t);
}

#
#  usage:
#    $t->errStr();
#
sub errStr
{
    my($t) = @_;

    return $t->{_errStr};
}

#
#  usage:
#   $pid = $t->xferPid();
#
# xferPid() returns the process id of the child forked process.
#
sub xferPid
{
    my($t) = @_;

    return ($t->{xferPid});
}

#
#  usage:
#    $t->logMsg($msg);
#
sub logMsg
{
    my ($t, $msg) = @_;

    push(@{$t->{_logMsg}}, $msg);
}

#
#  usage:
#    $t->logMsgGet();
#
sub logMsgGet
{
    my($t) = @_;

    return shift(@{$t->{_logMsg}});
}

#
#  usage:
#    $t->getStats();
#
# This function returns xfer statistics.  It Returns a hash ref giving
# various status information about the transfer.
#
sub getStats
{
    my ($t) = @_;

    return {
        map { $_ => $t->{$_} }
          qw(byteCnt fileCnt xferErrCnt xferBadShareCnt xferBadFileCnt
             xferOK hostAbort hostError lastOutputLine)
    };
}

sub getBadFiles
{
    my ($t) = @_;

    return @{$t->{badFiles}};
}

#
# useTar function.  In order to work correctly, the protocol in
# question should overwrite the function if it needs to return true.
#
sub useTar
{
    return 0;
}

##############################################################################
# Logging Functions
##############################################################################

#
# usage:
#   $t->logWrite($msg [, $level])
#
# This function writes to XferLOG.
#
sub logWrite
{
    my($t, $msg, $level) = @_;

    my $XferLOG = $t->{XferLOG};
    $level = 3 if ( !defined($level) );
    
    return ( $XferLOG->write(\$msg) ) if ( $level <= $t->{logLevel} );
}

##############################################################################
# File Inclusion/Exclusion
##############################################################################

#
# loadInclExclRegexps() places the appropriate file include/exclude regexps 
#
sub loadInclExclRegexps
{
    my ( $t, $shareType ) = @_;
    my $bpc  = $t->{bpc};
    my $conf = $t->{conf};
    
    my @BackupFilesOnly    = ();
    my @BackupFilesExclude = ();
    my ($shareName, $shareNameRE);
    
    $shareName = $t->{shareName};
    $shareName =~ s/\/*$//;    # remove trailing slashes
    $shareName = "/" if ( $shareName eq "" );

    $t->{shareName}   = $shareName;
    $t->{shareNameRE} = $bpc->glob2re($shareName);

    #
    # load all relevant values into @BackupFilesOnly
    #
    if ( ref( $conf->{BackupFilesOnly} ) eq "HASH" ) {

        foreach my $share ( ( '*', $shareName ) ) {
   	    push @BackupFilesOnly, @{ $conf->{BackupFilesOnly}{$share} } 
	        if ( defined( $conf->{BackupFilesOnly}{$share} ) );
        }
	
    } elsif ( ref( $conf->{BackupFilesOnly} ) eq "ARRAY" ) {
	
        push( @BackupFilesOnly, @{ $conf->{BackupFilesOnly} } );
	
    } elsif ( !defined( $conf->{BackupFilesOnly} ) ) {

        #
        # do nothing 
        #
	
    } else {

        #
        # not a legitimate entry for $conf->{BackupFilesOnly}
        #
        $t->{_errStr} = "Incorrect syntax in BackupFilesOnly for host $t->{Host}";
          
        return;
    }
    
    #
    # load all relevant values into @BackupFilesExclude
    #
    if ( ref( $conf->{BackupFilesExclude} ) eq "HASH" ) {

        foreach my $share ( ( '*', $shareName ) ) {
            push( @BackupFilesExclude,
                map {
                        ( $_ =~ /^\// )
                      ? ( $t->{shareNameRE} . $bpc->glob2re($_) )
                      : ( '.*\/' . $bpc->glob2re($_) . '(?=\/.*)?' )
                  } @{ $conf->{BackupFilesExclude}{$share} }
                ) if ( defined( $conf->{BackupFilesExclude}{$share} ) ) ;
        }

    } elsif ( ref( $conf->{BackupFilesExclude} ) eq "ARRAY" ) {

        push( @BackupFilesExclude,
            map {
                    ( $_ =~ /\// )
                  ? ( $bpc->glob2re($_) )
                  : ( '.*\/' . $bpc->glob2re($_) . '(?<=\/.*)?' )
              } @{ $conf->{BackupFilesExclude} } );

    } elsif ( !defined( $conf->{BackupFilesOnly} ) ) {

        #
        # do nothing here
        #

    } else {

        #
        # not a legitimate entry for $conf->{BackupFilesExclude}
        #
        $t->{_errStr} =
          "Incorrect syntax in BackupFilesExclude for host $t->{Host}";
        return;
    }

    #
    # load the regular expressions into the xfer object
    #
    $t->{BackupFilesOnly} = ( @BackupFilesOnly > 0 ) ? \@BackupFilesOnly : undef;
    $t->{BackupFilesExclude} = ( @BackupFilesExclude > 0 ) ? \@BackupFilesExclude : undef;

    return 1;
}


sub checkIncludeExclude
{
    my ($t, $file) = @_;

    return ( $t->checkIncludeMatch($file) && !$t->checkExcludeMatch($file) );
}
    
sub checkIncludeMatch
{
    my ($t, $file) = @_;

    my $shareName = $t->{shareName};
    my $includes  = $t->{BackupFilesOnly} || return 1;
    my $match = "";
    
    foreach my $include ( @{$includes} ) {
      
        #
        # construct regexp elsewhere to avoid syntactical evil
        #
        $match = '^' . quotemeta( $shareName . $include ) . '(?=\/.*)?';

	#
        # return true if the include folder is a parent of the file,
        # or the folder itself.
	#
        return 1 if ( $file =~ /$match/ );

        $match = '^' . quotemeta($file) . '(?=\/.*)?';

	#
        # return true if the file is a parent of the include folder,
        # or the folder itself.
	#
        return 1 if ( "$shareName$include" =~ /$match/ );
    }
    return 0;
}

sub checkExcludeMatch
{
    my ($t, $file) = @_;

    my $shareName = $t->{shareName};
    my $excludes  = $t->{BackupFilesExclude} || return 0;
    my $match = "";

    foreach my $exclude ( @{$excludes} ) {

        #
        # construct regexp elsewhere to avoid syntactical evil
        #
        $match = '^' . quotemeta( $shareName . $exclude ) . '(?=\/.*)?';

	#
        # return true if the exclude folder is a parent of the file,
        # or the folder itself.
	#
        return 1 if ( $file =~ /$match/ );

        $match = '^' . quotemeta($file) . '(?=\/.*)?';
                
	#
        # return true if the file is a parent of the exclude folder,
        # or the folder itself.
	#
        return 1 if ( "$shareName$exclude" =~ /$match/ );
    }
    return 0;
}

1;
