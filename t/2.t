use Tie::IP::Address;

# Some basic tests

$| = 1; 
print "1..6\n";

my $test = 1;

my %HostType;

tie %HostType, Tie::IP::Address;

$HostType{"200.44.0.0/18"} = "Sun";
$HostType{"200.44.64.120/18"} = "Compaq";
$HostType{"0.0.0.0/0"} = "Unknown";
$HostType{"200.44.32.10"} = "SGI";

if ($HostType{"10.10.10.10"} eq "Unknown") {
	print "ok $test\n";
}
else {
	print "not ok $test\n";
}

++$test;

delete $HostType{"0.0.0.0/0"};

if (not defined $HostType{"10.10.10.10"}) {
	print "ok $test\n";
}
else {
	print "not ok $test\n";
}

++$test;

$HostType{"161.196.66.0/25"} = "Dell";
delete $HostType{"161.196.66.2"};

if ($HostType{"161.196.66.2"} eq "Dell") {
	print "ok $test\n";
}
else {
	print "not ok $test\n";
}

++$test;

if ($HostType{"200.44.0.0"} eq "Sun") {
	print "ok $test\n";
}
else {
	print "not ok $test\n";
}

++$test;

if ($HostType{"200.44.64.120"} eq "Compaq") {
	print "ok $test\n";
}
else {
	print "not ok $test\n";
}

++$test;

if ($HostType{"200.44.32.10"} eq "SGI") {
	print "ok $test\n";
}
else {
	print "not ok $test\n";
}

++$test;


