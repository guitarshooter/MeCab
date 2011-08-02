#!/usr/bin/perl
use strict;
use warnings;
use Algorithm::Diff;
use Encode;
use utf8;
use open ':utf8';
binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

#my $key = shift;
#my @seq1 = split(//, decode('utf-8', $key));
my $file = shift;
open (IN,$file);
my @file = <IN>;
my @str = grep (/^.{3,}/,@file);
#my @str = ("イメージ","ディスプレイ");
foreach my $q1 (@str){
  my @seq1 = split(//, $q1);
  my @simstr = ($q1);
  foreach my $q2 (@str){
    chomp($q2);
    my @seq2 = split(//, $q2);
    my @lcs = Algorithm::Diff::LCS(\@seq1, \@seq2);
    next if @lcs < ((@seq1 > @seq2) ? @seq1 : @seq2) - 1;
    #print "$q2".",";
    if($q1 ne $q2){
      push @simstr,$q2;
    }
  }
  if(@simstr > 1){
	 print join(",",@simstr);
  print "\n";
  }
}
