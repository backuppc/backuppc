#!/usr/bin/perl
#
# Test script to verify Data::Dumper compatibility with Perl 5.38+
# This tests that our Data::Dumper configuration produces consistent output
#

use strict;
use warnings;
use Data::Dumper;

# Configure Data::Dumper for consistent output with Perl 5.38+
$Data::Dumper::Useqq    = 1;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Terse    = 1;
$Data::Dumper::Indent   = 1;

# Test hash serialization (similar to config data)
my %test_config = (
    'BackupFilesOnly'       => {'/' => ['etc', 'home', 'usr/local']},
    'XferMethod'            => 'rsync',
    'RsyncArgs'             => ['--numeric-ids', '--perms', '--owner', '--group'],
    'BackupPCNightlyPeriod' => 1,
    'MaxBackups'            => 4,
);

print "=== Testing Data::Dumper configuration ===\n";
print "Perl version: $^V\n";
print "Data::Dumper version: " . ($Data::Dumper::VERSION || "unknown") . "\n\n";

# Test 1: Basic hash serialization
print "Test 1: Basic hash serialization\n";
my $d1 = Data::Dumper->new([\%test_config]);
$d1->Sortkeys(1);
$d1->Useqq(1);
$d1->Terse(1);
$d1->Indent(1);
my $output1 = $d1->Dump;
print $output1;
print "\n";

# Test 2: Using global settings
print "Test 2: Using global settings\n";
my $d2      = Data::Dumper->new([\%test_config]);
my $output2 = $d2->Dump;
print $output2;
print "\n";

# Test 3: Check consistency (both outputs should be identical)
print "Test 3: Consistency check\n";
if ( $output1 eq $output2 ) {
    print "✓ PASS: Both outputs are identical\n";
} else {
    print "✗ FAIL: Outputs differ\n";
    print "Difference detected - this indicates a configuration issue\n";
}

print "\n=== Test completed ===\n";
