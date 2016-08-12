#!/usr/bin/perl

use warnings;
use strict;
use Carp;
use 5.010;

# Just for fun, we're going to use um as our JSON unit.
my $pcbunits_per_mil = 100;
my $mm_per_mil = 0.0254;
my $mm_per_pcbunit = $mm_per_mil / $pcbunits_per_mil;

# nanometers
my $ourunit_per_meter = 1000000000;

my $ourunit_per_mm = $ourunit_per_meter / 1000;
my $ourunit_per_mil = $ourunit_per_mm * $mm_per_mil;
my $ourunit_per_pcbunit = $ourunit_per_mm * $mm_per_pcbunit;

my %unit_factors = (
	mm => $ourunit_per_mm,
	mil => $ourunit_per_mil,
	'' => $ourunit_per_pcbunit,
);

my $magn = qr/
		-?
		(?:
			\.\d+
			|
			\d+(?:
				\.\d*
			)?
		)
	/x;

my $mun = qr/\s*(mm|mil)/;

my $meas = qr/$magn$mun?/;
my $meas_capt = qr/($magn)($mun)?/;

my $str = qr/"(?:.*?)"/;

my $polygon_pattern = qr/
	(?:
		\bPolygon
		\s*\(\s*
		"clearpoly"
		\s*\)\s*
		\(
	)
	([^)]+)
	(?:
		\)
	)
	/xs;

# Represents one or more whitespace-separated measurements
my $vector_contents_pattern = qr/$meas(?:\s+$meas)*/s;

# $1 = left delim
# $2 = vector contents (null if empty)
# $3 = right delim
my $vector_pattern = qr/
	(?:\[\s*)
	(?:
		($vector_contents_pattern)
		\s*
	)?
	(?:\s*\])
	/xs;

sub normalize_meas {
	my $value = shift;
	$value =~ $meas_capt or die;
	my $magnitude = $1;
	my $unit = $2 // '';

	my $f = $unit_factors{$unit};
	my $result = $magnitude * $f;
	return $result;
}

sub get_polygon_vectors {
	my $polygon_vectors_str = shift // '';

	my @vectors = ();

	for($polygon_vectors_str) {
		while(/\G\s*$vector_pattern/g) {
			my $values = get_polygon_vector_values($1);
			push @vectors, $values;
		}
	}

	return \@vectors;
}

sub get_polygon_vector_values {
	my $polygon_vector_values_str = shift // '';

	my @values = ();

	for($polygon_vector_values_str) {
		while(/\G\s*($meas)/g) {
			push @values, normalize_meas($1);
		}
	}

	return \@values;
}

local $/;


my @polygons = ();
my $current_polygon = undef;

while(<>) {
	while(/$polygon_pattern/g) {
		my $polygon_vectors_str = $1;
		push @polygons, get_polygon_vectors($polygon_vectors_str);
	}
}

use JSON;
say JSON->new->utf8->pretty->encode(\@polygons);
