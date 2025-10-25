#=============================================================
#
# BackupPC::CGI::Metrics package
#
# DESCRIPTION
#
#   This module implements a metrics page for the CGI interface.
#
# AUTHOR
#   Jonas L.
#
# COPYRIGHT
#   Copyright (C) 2005-2013  Jonas L., Rich Duzenbury and Craig Barratt
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
# Version 4.3.3, released 5 Apr 2020.
#
# See http://backuppc.sourceforge.net.
#
#========================================================================

package BackupPC::CGI::Metrics;

use strict;
use warnings;

use BackupPC::CGI::Lib qw(:all);
use Scalar::Util 'looks_like_number';

my $LoadErrorXMLRSS;
my $LoadErrorJSONXS;

BEGIN {
    eval "use XML::RSS;";
    $LoadErrorXMLRSS = $@ if $@;
    eval "use JSON::XS;";
    $LoadErrorJSONXS = $@ if $@;
}

sub action
{
    GetStatusInfo("info hosts queueLen");
    my $Privileged = CheckPermission();

    my %metrics;

    #
    # Global metrics
    #
    $metrics{server} = {
        hostname         => $Conf{ServerHost},
        pid              => $Info{pid},
        version          => $Info{Version},
        start_time       => $Info{startTime},
        config_time      => $Info{ConfigLTime},
        next_wakeup_time => $Info{nextWakeup},
    };

    $metrics{disk} = {
        usage       => $Info{DUlastValue},
        inode_usage => $Info{DUInodelastValue},
    };

    $metrics{queues} = {
        background_count => $QueueLen{BgQueue},
        command_count    => $QueueLen{CmdQueue},
        user_count       => $QueueLen{UserQueue},
    };

    my %poolMapper = (
        dir_count           => "DirCnt",
        file_count          => "FileCnt",
        remove_file_count   => "FileCntRm",
        remove_size         => "KbRm",
        repeated_file_count => "FileCntRep",
        repeated_file_max   => "FileRepMax",
        size                => "Kb",
    );

    my $generatePool = sub {
        my($name) = @_;
        my %pool = (time => $Info{"${name}Time"});

        foreach my $key ( keys %poolMapper ) {
            $pool{$key} = $Info{"${name}4$poolMapper{$key}"};
        }

        if ( $Conf{PoolV3Enabled} ) {
            foreach my $key ( keys %poolMapper ) {
                $pool{$key} .= $Info{"${name}$poolMapper{$key}"};
            }
        }
        return \%pool;
    };

    $metrics{pool}  = $Info{pool4FileCnt} > 0  ? &$generatePool("pool")  : undef;
    $metrics{cpool} = $Info{cpool4FileCnt} > 0 ? &$generatePool("cpool") : undef;

    #
    # Host metrics
    #
    foreach my $host ( GetUserHosts(1) ) {
        my($fullAge, $fullCount, $fullDuration, $fullRate, $fullSize);
        my($incrAge, $incrCount, $incrDuration, $incrRate, $incrSize);
        my($lastFullBackup, $lastIncrBackup);

        $fullCount = $incrCount = 0;
        $$lastFullBackup->{StartTime} = $$lastIncrBackup->{StartTime} = -1;

        my @Backups = $bpc->BackupInfoRead($host);
        $bpc->ConfigRead($host);
        %Conf = $bpc->Conf();

        next if ( $Conf{XferMethod} eq "archive" );
        next if ( !$Privileged && !CheckPermission($host) );

        for ( my $i = 0 ; $i < @Backups ; $i++ ) {
            if ( $Backups[$i]{type} eq "full" ) {
                $fullCount++;
                if ( $$lastFullBackup->{startTime} < 0 || $Backups[$i]{startTime} > $$lastFullBackup->{startTime} ) {
                    $lastFullBackup = \$Backups[$i];
                    $fullAge        = time - $$lastFullBackup->{endTime};
                }
            } elsif ( $Backups[$i]{type} eq "incr" ) {
                $incrCount++;
                if ( $$lastIncrBackup->{startTime} < 0 || $Backups[$i]{startTime} > $$lastIncrBackup->{startTime} ) {
                    $lastIncrBackup = \$Backups[$i];
                    $incrAge        = time - $$lastIncrBackup->{endTime};
                }
            }
        }

        $fullSize     = $$lastFullBackup->{size};
        $fullDuration = $$lastFullBackup->{endTime} - $$lastFullBackup->{startTime};
        $incrSize     = $$lastIncrBackup->{size};
        $incrDuration = $$lastIncrBackup->{endTime} - $$lastIncrBackup->{startTime};

        if ( $$lastFullBackup->{startTime} > 0 ) {
            $fullRate = $fullSize / ($fullDuration <= 0 ? 1 : $fullDuration);
        }

        if ( $$lastIncrBackup->{startTime} > 0 ) {
            $incrRate = $incrSize / ($incrDuration <= 0 ? 1 : $incrDuration);
        }

        my $fkc = 0;
        if ( ref($Conf{FullKeepCnt}) eq "ARRAY" ) {
            if ( looks_like_number($Conf{FullKeepCnt}[0]) > 0 ) {
                $fkc = $Conf{FullKeepCnt}[0];
            }
        } elsif ( ref($Conf{FullKeepCnt}) eq "HASHMAP" ) {
            ;
        } else {
            if ( looks_like_number($Conf{FullKeepCnt}) > 0 ) {
                $fkc = $Conf{FullKeepCnt};
            }
        }

        $metrics{hosts}{$host} = {
            full_age          => int($fullAge),
            full_start_time   => int($$lastFullBackup->{startTime}),
            full_count        => $fullCount,
            full_duration     => int($fullDuration),
            full_keep_count   => $fkc,
            full_period       => $Conf{FullPeriod},
            full_rate         => int($fullRate),
            full_size         => int($fullSize),
            full_size_exist   => int($$lastFullBackup->{sizeExist}),
            full_size_new     => int($$lastFullBackup->{sizeNew}),
            full_nfiles_exist => int($$lastFullBackup->{nFilesExist}),
            full_nfiles_new   => int($$lastFullBackup->{nFilesNew}),
            incr_age          => int($incrAge),
            incr_start_time   => int($$lastIncrBackup->{startTime}),
            incr_count        => $incrCount,
            incr_duration     => int($incrDuration),
            incr_keep_count   => $Conf{IncrKeepCnt},
            incr_period       => $Conf{IncrPeriod},
            incr_rate         => int($incrRate),
            incr_size         => int($incrSize),
            incr_size_exist   => int($$lastIncrBackup->{sizeExist}),
            incr_size_new     => int($$lastIncrBackup->{sizeNew}),
            incr_nfiles_exist => int($$lastIncrBackup->{nFilesExist}),
            incr_nfiles_new   => int($$lastIncrBackup->{nFilesNew}),
            error             => $Status{$host}{error},
            reason            => $Status{$host}{reason},
            state             => $Status{$host}{state},
            disabled          => $Conf{BackupsDisable},
        };
    }

    #
    # Format and print metrics
    #
    binmode(STDOUT, ":utf8");
    my($content, $contentType, $format);

    # Check if action is RSS, if not find out metrics format.
    # Allowed formats are the following: json (default), rss, prometheus
    $format = $In{action} eq "rss" ? "rss" : $In{format};

    if ( $format eq "rss" ) {
        if ( $LoadErrorXMLRSS ) {
            print "Status: 500 Internal Server Error\n";
            print "Content-type: text/plain\n\n";
            print $LoadErrorXMLRSS;
            return;
        }

        $contentType = "text/xml";

        my $rss = new XML::RSS(
            version  => '0.91',
            encoding => 'utf-8'
        );

        my $baseURL = $ENV{HTTPS} eq "on" ? 'https://' : 'http://' . $ENV{'SERVER_NAME'} . $ENV{SCRIPT_NAME};

        $rss->channel(
            title       => eval("qq{$Lang->{RSS_Doc_Title}}"),
            link        => $baseURL,
            language    => $Conf{Language},
            description => eval("qq{$Lang->{RSS_Doc_Description}}"),
        );

        foreach my $host ( sort keys %{$metrics{hosts}} ) {
            my(
                $fullCnt, $fullAge,   $fullSize,     $fullRate, $incrCnt,
                $incrAge, $hostState, $hostDisabled, $hostLastAttempt
            );
            $fullCnt  = $metrics{hosts}{$host}{full_count};
            $fullAge  = sprintf("%.1f", (time - $metrics{hosts}{$host}{full_timestamp}) / (24 * 3600));
            $fullSize = sprintf("%.2f", $metrics{hosts}{$host}{full_size} / (1024**3));
            $fullRate = sprintf("%.2f", $metrics{hosts}{$host}{full_rate} / (1024**2));
            $incrCnt  = $metrics{hosts}{$host}{incr_count};
            $incrAge  = sprintf("%.1f", (time - $metrics{hosts}{$host}{incr_timestamp}) / (24 * 3600));

            my $error;
            if (   $metrics{hosts}{$host}{state} ne "Status_backup_in_progress"
                && $metrics{hosts}{$host}{state} ne "Status_restore_in_progress"
                && $metrics{hosts}{$host}{error} ne "" ) {
                ($error = $metrics{hosts}{$host}{error}) =~ s/(.{48}).*/$1.../;
                $error = " ($error)";
            }

            $hostState       = $Lang->{$metrics{hosts}{$host}{state}};
            $hostLastAttempt = $Lang->{$metrics{hosts}{$host}{reason}} . $error;
            $hostDisabled    = $metrics{hosts}{$host}{disabled};

            my $description = eval("qq{$Lang->{RSS_Host_Summary}}");

            $rss->add_item(
                title       => "$host, $hostState, $hostLastAttempt",
                link        => "$baseURL?host=$host",
                description => $description,
            );
        }

        $content = $rss->as_string;
    } elsif ( $format eq "prometheus" ) {
        $contentType = "text/plain";

        my %mapper = (
            hosts => {
                full_age        => {desc => "Age of the last full backup (seconds)"},
                full_start_time => {desc => "Last full backup start in epoch time (seconds)"},
                full_count      => {desc => "Number of full backups"},
                full_duration   => {desc => "Transfer time in seconds of the last full backup"},
                full_keep_count => {desc => "Number of full backups to keep"},
                full_period     => {desc => "Minimum period in days between full backups"},
                full_rate       => {desc => "Transfer rate in bytes/s of the last full backup"},
                full_size       => {desc => "Size in bytes of the last full backup"},
                incr_age        => {desc => "Age of the last incremental backup (seconds)"},
                incr_start_time => {desc => "Same as full backup but for incremental backup"},
                incr_count      => {desc => "Number of incremental backups"},
                incr_duration   => {desc => "Transfer time in seconds of the last incremental backup"},
                incr_keep_count => {desc => "Number of incremental backups to keep"},
                incr_period     => {desc => "Minimum period in days between incremental backups"},
                disabled        => {desc => "Backups disabled"},

                error  => {kind => "label", desc => "Host error"},
                reason => {kind => "label", desc => "Host state reason"},
                state  => {kind => "label", desc => "Host state"},
            },
            disk => {
                usage       => {desc => "Disk usage in %"},
                inode_usage => {desc => "Disk inode usage in %"},
            },
            queues => {
                background_count => {desc => "Number of jobs in the background queue"},
                command_count    => {desc => "Number of jobs in the command queue"},
                user_count       => {desc => "Number of jobs in the user queue"},
            },
            pool => {
                dir_count         => {desc => "Number of directories in the pool"},
                file_count        => {desc => "Number of files in the pool"},
                remove_file_count => {desc => "Number of files to remove in the pool"},
                remove_size       => {desc => " Size in bytes to remove from the pool"},
                size              => {desc => "Size in bytes of the pool"},
            },
            cpool => {
                dir_count         => {desc => "Number of directories in the pool"},
                file_count        => {desc => "Number of files in the pool"},
                remove_file_count => {desc => "Number of files to remove in the pool"},
                remove_size       => {desc => " Size in bytes to remove from the pool"},
                size              => {desc => "Size in bytes of the pool"},
            },
        );

        foreach my $section ( sort keys %mapper ) {
            foreach my $entry ( sort keys %{$mapper{$section}} ) {

                # Ignore empty pools
                next
                  if ( ($section eq "pool" || $section eq "cpool")
                    && (!defined($metrics{$section}{file_count}) || $metrics{$section}{file_count} <= 0) );

                my $promKey = "backuppc_${section}_${entry}";

                # Generate prometheus header
                $content .= "# HELP $promKey $mapper{$section}{$entry}{desc}\n";
                $content .= "# TYPE $promKey gauge\n";

                if ( $section eq "hosts" ) {
                    foreach my $host ( sort keys %{$metrics{hosts}} ) {
                        if ( defined($mapper{hosts}{$entry}{kind}) && $mapper{hosts}{$entry}{kind} eq 'label' ) {
                            if ( $metrics{hosts}{$host}{$entry} ) {
                                $content .= "${promKey}\{host=\"$host\",label=\"$metrics{hosts}{$host}{$entry}\"\} 1\n";
                            }
                        } else {
                            my $val;
                            if ( ref($metrics{hosts}{$host}{$entry}) eq "ARRAY" ) {
                                $val = @{$metrics{hosts}{$host}{$entry}};
                            } else {
                                $val = $metrics{hosts}{$host}{$entry};
                            }
                            if ( $val == '' ) {
                                $val = 0;
                            }
                            $content .= "${promKey}\{host=\"$host\"\} $val\n";
                        }
                    }

                } else {
                    $content .= "$promKey $metrics{$section}{$entry}\n";
                }

                $content .= "\n";
            }
        }
    } else {
        if ( $LoadErrorJSONXS ) {
            print "Status: 500 Internal Server Error\n";
            print "Content-type: text/plain\n\n";
            print $LoadErrorJSONXS;
            return;
        }

        $contentType = "application/json";
        $content     = encode_json(\%metrics);
    }

    print "Content-type: $contentType\n\n";
    print $content;
}

1;
