#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use 5.10.0;
use Data::Dumper;
use Frontend::Schema;


my $db = Frontend::Schema->connect('dbi:mysql:charlieharvey:charlieharvey.org.uk','charlieharvey','fhcdp22');

my @rows = $db->resultset('Page')->search({title => {'like'=>'%lambda%'}})->all;
for my $r (@rows) {
	say $r->title;
}


#my @to_insert = ('TEST MUSIXX', 'Another one');
#
#my $rs = $db->resultset('Artist');
#for (@to_insert) {
#        say "CREATE $_";
#        $rs->create({ name => $_ });
#}
#
#say '';


