#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use encoding 'utf8';

my $file1 = "jawiki-latest-all-titles-in-ns0";
my $file2 = "wikipedia.csv";

open(IN, "$file1");
open(OUT, ">$file2");
binmode OUT, ":utf8";        ##    <- こっちが正しい

for(<IN>) {
  chomp($_);

  ## いらない単語をとばす
  next if $_ =~ /^\./;
#  next if $_ =~ /\(曖昧*回避\)/;
  next if $_ =~ /^[0-9]{1,100}$/;
  next if $_ =~ /[0-9]{4}./;
  next if $_ =~ /_(.+)$/;
  next if $_ =~ /^\s$/;
  next if $_ =~ /年$/;
  next if $_ =~ /年代$/;
  next if $_ =~ /.+月.+日$/;
  next if $_ =~ /^[0-9]{3,}系$/;
  next if $_ =~ /^[0-9]{3,}空$/;
  next if $_ =~ /^～+/;
  next if $_ =~ /^（+/;
#  next if $_ =~ /^\+|^!|^\-|^\"|^\'|^\$|^%|^&|^\(|^\*/;
  next if $_ =~ /[\/\+!\?\-"'\$%&\(\*\)_,]+/;
  
  
  print $_."\n";
  if (length($_) > 3) {
    print OUT "$_,0,0,".max(-36000,-400 * (length^1.5)).",名詞,固有名詞,*,*,*,*,$_,*,*,wikipedia_word,\n";
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

