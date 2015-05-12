#!/usr/bin/perl
# make a little mojolicious server that delays connections to slow down scanners
# and skiddies.
use strict;
use warnings;
use utf8;
use 5.10.0;
use Data::Dumper;
use Mojolicious::Lite;
use Mojo::IOLoop;

get '/' => sub {
  my $c = shift;
  my $i=0;
  my @reply= split //,"Fuck off\n";
  my $id = Mojo::IOLoop->recurring(1 => sub {
    $c->write_chunk($reply[$i]);
    $c->finish if $reply[$i++] eq "\n";
  });
  $c->on(finish => sub { Mojo::IOLoop->remove($id) });
};

app->start;
