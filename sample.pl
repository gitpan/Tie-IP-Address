# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tie::IP::Address;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

use Address;

my %HostType;

tie %HostType, Tie::IP::Address;

$HostType{"200.44.0.0/18"} = "SUN U250/Solaris";
$HostType{"200.44.64.120/18"} = "Compaq Proliant 1600/Windows NT 4.0";
$HostType{"0.0.0.0/0"} = "Unknown/Unknown";
$HostType{"200.44.32.10"} = "Compaq Armada 7800/Windows 2000 RC1";

delete $HostType{"0.0.0.0/0"};
delete $HostType{"161.196.66.2"};
$HostType{"161.196.66.0/25"} = "Sun SparcStation 5/Solaris";

foreach my $host ("200.44.32.15", "161.196.66.2", "200.44.96.10", 
		  "255.255.255.255", "200.44.32.0/20")
{
    if (defined($HostType{$host})) {
	print "$host is an ", $HostType{$host}, "\n";
    }
    else {
	print "We know nothing about $host\n";
    }
}

my $a;
my $b;

while (($a, $b) = each %HostType) {
    print "By array: $a is '$b'\n";
}

untie %HostType;

print "After untie\n";

foreach my $host ("200.44.32.15", "161.196.66.2", "200.44.96.10", 
		  "255.255.255.255", "200.44.32.0/20")
{
    if (defined($HostType{$host})) {
	print "$host is an ", $HostType{$host}, "\n";
    }
    else {
	print "We know nothing about $host\n";
    }
}
