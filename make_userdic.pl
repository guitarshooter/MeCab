#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use encoding 'utf8';
use File::Basename;

if(@ARGV <= 1){die "Usage:$0 DictionaryName file file ...";}
my $dicname = shift(@ARGV);
my $regex_suffix = qw/\.[^\.]+$/; #拡張子をのぞくための正規表現

while(@ARGV){
  my $inputfile = shift @ARGV;
  my ($filename,$filepath,$filesuffix) = fileparse($inputfile,$regex_suffix); 
  open(IN, "$inputfile");

  for(<IN>) {
    chomp($_);
    if (length($_) >= 1) {
      print "$_,1358,1358,".max(-32768,(4000-200 * (length($_)^1.3))).",名詞,一般,*,*,*,*,$_,*,*,$dicname,\n";
    }
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

