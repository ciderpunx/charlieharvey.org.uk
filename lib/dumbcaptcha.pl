#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use 5.10.0;
use Data::Dumper;

sub captchas {
  [
    [ "What is 9 factorial?" => "362880" ]
  , [ "What was the surname of the person who said 'Program testing can be used to show the presence of bugs, but never to show their absence'?" => "Dijkstra"]
  , [ "Who wrote 'Theorems for Free!'" => "Philip Wadler"]
  , [ "What is a monoid in the category of endofunctors?" => "Monad"]
  , [ "How many kilobytes of  RAM did the Commodore 64 have" => "64"]
  , [ "How many beans make 5?" => "5" ]
  , [ "Who was the original author of the Linux kernel?" => "Linux Torvalds" ]
  , [ "Who founded the Free Software Foundation and GNU project?" => "Richard Stallman"]
  , [ "A natural transformation is a 'morphism of f______s'?" => "Functors" ]
  , [ "What is 9 cubed", "729" ]
  , [ "What is the square root of -1?", "i"]
  , [ "Who wrote 'A Brief History of Time'?", "Stephen Hawking"]
  , [ "Who was the original author of the Lisp programming language?", "John McCarthy"]
  ]
}

1;

