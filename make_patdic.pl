#!/usr/bin/perl

use strict;
use warnings;
#use utf8;
#use encoding 'utf8';
use File::Basename;

#if(@ARGV != 2){die "Usage:$0 filename DictionaryName";}
my ($inputfile,$dicname) = @ARGV;
my $regex_suffix = qw/\.[^\.]+$/; #拡張子をのぞくための正規表現
my ($filename,$filepath,$filesuffix) = fileparse($inputfile,$regex_suffix); 

open(IN, "$inputfile");
#binmode OUT, ":utf8";        ##    <- こっちが正しい

for(<IN>) {
#  chomp($_);
  my @line = split(/,/,$_);
  if ($line[5] ne "固有名詞") {
#    print OUT $_;
    print $_;
  }
}
