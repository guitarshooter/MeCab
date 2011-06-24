#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use encoding 'utf8';
use File::Basename;

if(@ARGV != 2){die "Usage:$0 filename DictionaryName";}
my ($inputfile,$dicname) = @ARGV;
my $regex_suffix = qw/\.[^\.]+$/; #拡張子をのぞくための正規表現
my ($filename,$filepath,$filesuffix) = fileparse($inputfile,$regex_suffix); 
my $outputfile = "$filename".".csv";

open(IN, "$inputfile");
open(OUT, ">$outputfile");
binmode OUT, ":utf8";        ##    <- こっちが正しい

for(<IN>) {
  chomp($_);
  if (length($_) > 1) {
    print OUT "$_,0,0,".max(-32768,(6000-200 * (length($_)^1.3))).",名詞,固有名詞,*,*,*,*,$_,*,*,$dicname,\n";
  }
}

sub max {
    my $comp = shift @_;
    my $val  = shift @_;
    my $max  = $comp;
    if ( $comp <= $val ) {
      $max = $val;
    }
    return int($max);
}

