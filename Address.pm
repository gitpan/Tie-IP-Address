package Tie::IP::Address;

use strict;
use vars qw($VERSION);
use Carp;
use IP::Address;

require DynaLoader;
require AutoLoader;

$VERSION = '0.01';

# Preloaded methods go here.

sub new {
    TIEHASH(shift);
}

sub TIEHASH {
    my $class = shift;
    my $self = [ ];
    bless $self, $class;
}

sub FETCH {
    my $self = shift;
    my $where = shift;
    my $ip = new IP::Address $where;
    if (!$ip) {
	croak "$where is not a valid IP::Address specification";
    }
    else {
	for(my $mask = 32; $mask >= 0 ; --$mask) {
	    foreach my $network (keys %{$self->[$mask]}) {
		if ($self->[$mask]->{$network}->{'where'}->contains($ip)) {
		    return $self->[$mask]->{$network}->{'what'};
		}
	    }
	}
    }
    return undef;		# None of the networks matched the spec
}

sub STORE {
    my $self = shift;
    my $where = shift;
    my $what = shift;
    my $ip = new IP::Address $where;
    if (!$ip) {
	croak "$where is not a valid IP::Address specification";
    }
    else {
	my $cidr_mask_mode = $IP::Address::Use_CIDR_Notation;
	$IP::Address::Use_CIDR_Notation = 1;
	my $masklen = $ip->mask_to_string;
	$self->[33]++ 
	    if not defined($self->[$masklen]->{$ip->network->to_string});
	$self->[$masklen]->{$ip->network->to_string} = {
	    'where' => $ip,
	    'what' => $what
	};
	$IP::Address::Use_CIDR_Notation = $cidr_mask_mode;
    }
}

sub EXISTS {
    my $self = shift;
    my $where = shift;
    my $ip = new IP::Address $where;
    if (!$ip) {
	croak "$where is not a valid IP::Address specification";
    }
    else {
	my $cidr_mask_mode = $IP::Address::Use_CIDR_Notation;
	$IP::Address::Use_CIDR_Notation = 1;
	my $masklen = $ip->mask_to_string;
	my $addr = $ip->network->to_string;
	$IP::Address::Use_CIDR_Notation = $cidr_mask_mode;
	return exists $self->[$masklen]->{$addr};
    }
}

sub DELETE {
    my $self = shift;
    my $where = shift;
    my $ip = new IP::Address $where;
    if (!$ip) {
	croak "$where is not a valid IP::Address specification";
    }
    else {
	my $cidr_mask_mode = $IP::Address::Use_CIDR_Notation;
	$IP::Address::Use_CIDR_Notation = 1;
	my $masklen = $ip->mask_to_string;
	my $addr = $ip->network->to_string;
	$IP::Address::Use_CIDR_Notation = $cidr_mask_mode;
	--$self->[33] if defined($self->[$masklen]->{$addr});
	return delete $self->[$masklen]->{$addr};
    }
}

sub CLEAR {
    my $self = shift;
    for(my $mask = 32; $mask >= 0 ; --$mask) {
	foreach my $network (keys %{$self->[$mask]}) {
	    DELETE $self, $network;
	}
    }
}

sub NEXTKEY {
    my $self = shift;
    my $last = shift;
    my $lastmask = 0;
    my $origmask = 0;
    my $lastaddr;
    my $ip;
    my $cidr_mask_mode = $IP::Address::Use_CIDR_Notation;
    my $found_key = undef;
    my $found;

    $IP::Address::Use_CIDR_Notation = 1;

    if (defined $last and $ip = new IP::Address $last) {
	$origmask = $lastmask = $ip->mask_to_string;
	$lastaddr = $ip->network->to_string;
    }
    else {
	$lastmask = 0;
	$found = 1;
    }

  LOOKUP:
    while (1) {
	foreach my $cur_key (keys %{$self->[$lastmask]}) {
	    if ($found) { 
		$IP::Address::Use_CIDR_Notation = $cidr_mask_mode;
		return wantarray ? 
		    ($cur_key, $self->[$lastmask]->{$cur_key}->{'what'})
			: $cur_key;
	    }
	    if ($cur_key eq $lastaddr) { $found = 1; }
	}
	++$lastmask;
	last if $lastmask > 32;
    }
    
    $IP::Address::Use_CIDR_Notation = $cidr_mask_mode;

    return wantarray ? () : undef;
}

sub FIRSTKEY { NEXTKEY $_[0], undef; }

1;
__END__

=head1 NAME

Tie::IP::Address - Implements a Hash where the key is a subnet

=head1 SYNOPSIS

  use Tie::IP::Address;

  my %WhereIs;
  
  tie %WhereIs, Tie::IP::Address;

  $WhereIs{"10.0.10.0/24"} = "Lab, First Floor";
  $WhereIs{"10.0.20.0/24"} = "Datacenter, Second Floor";
  $WhereIs{"10.0.30.0/27"} = "Remote location";
  $WhereIs{"0.0.0.0/0"} = "God knows where";

  foreach $host ("10.0.10.1", "10.0.20.15", "10.0.32.17", "10.10.0.1") {
     print "Host $host is in ", $WhereIs{$host}, "\n";
  }

  foreach $subnet (keys %WhereIs) {
     print "Network ", $subnet, " is used in ", 
     $WhereIs{$subnet}, "\n";
  }

  untie %WhereIs;

=head1 DESCRIPTION

This module overloads hashes so that the key can be a subnet as in
B<IP::Address>. When looking values up, an interpretation will be made
to find the given key B<within> the subnets specified in the hash.

The code sample provided on the B<SYNOPSIS> would print out the
locations of every machine in the C<foreach> loop.

Care must be taken, as only strings that can be parsed as an IP
address by B<IP::Address> can be used as keys for this hash.

Iterators on the hash such as C<foreach>, C<each>, C<keys> and
C<values> will only see the actual subnets provided as keys to the
hash. When looking up a value such as in C<$hash{$ipaddress}> this IP
address will be looked up among the subnets existing as keys within
the hash. The matching subnet with the longest mask (ie, the most
specific subnet) will win and its associated value will be returned.

This code can be distributed freely according to the terms set forth
in the PERL license provided that proper credit is maintained. Please
send bug reports and feedback to the author for further improvement.

=head1 AUTHOR

Luis E. Munoz (lem@cantv.net)

=head1 SEE ALSO

perl(1), IP::Address(3).

=cut

    1;
