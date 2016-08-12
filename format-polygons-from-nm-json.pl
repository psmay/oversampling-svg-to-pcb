#!/usr/bin/perl

use warnings;
use strict;
use Carp;
use 5.010;

use JSON;

local $/;

my $layer_number = $ENV{LAYER_NUMBER} // 9;
my $layer_name = $ENV{LAYER_NAME} // "silk";

# The factor by which the input is oversized
my $shrink_factor = $ENV{FACTOR} // 100;

# Since the target unit is mm, the number of mm in 1nm
my $mm_per_nm = 1000000;


my $net_scale = 1 / ($mm_per_nm * $shrink_factor);

my $polygons = JSON->new->decode(scalar <>);

sub min {
	my $value;

	for(@_) {
		next unless defined($_);
		$value = $_ if +(not defined $value or $_ < $value);
	}
	return $value;
}

sub max {
	my $value;

	for(@_) {
		next unless defined($_);
		$value = $_ if +(not defined $value or $_ > $value);
	}
	return $value;
}

my $min_x;
my $max_x;
my $min_y;
my $max_y;

my @new_polygons = ();
for my $points (@$polygons) {

	my @new_points = ();
	for my $point (@$points) {
		my($x, $y) = map { $_ * $net_scale } @$point;
		$min_x = min($min_x, $x);
		$max_x = max($max_x, $x);
		$min_y = min($min_y, $y);
		$max_y = max($max_y, $y);

		push @new_points, [$x, $y];
	}

	push @new_polygons, \@new_points;
}

# Add this number to all points
my $mx = -$min_x;
my $my = -$min_y;

my $w = $max_x + $mx;
my $h = $max_y + $my;


say <<EOHEADER ;
PCB["" ${w}mm ${h}mm]

Grid[1000 0 0 0]

Layer($layer_number "$layer_name")
(
EOHEADER

for my $points (@new_polygons) {
	say qq/\tPolygon("clearpoly")/;
	say qq/\t(/;

	for my $point (@$points) {
		my($x, $y) = @$point;
		$x += $mx;
		$y += $my;
		say qq/\t\t[${x}mm ${y}mm]/;
	}

	say qq/\t)/;
}

say qq/)/;
