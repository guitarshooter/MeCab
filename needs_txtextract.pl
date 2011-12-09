#!/usr/bin/perl
#ニーズ抽出用に、最後の文章を抽出するスクリプト
#
use MeCab;
use Data::Dumper;
use File::Basename;
use TermExtract::MeCab;
use Unicode::Japanese;
my $regex_suffix = qw/\.[^\.]+$/; #拡張子をのぞくための正規表現

while(@ARGV){
  my $file = shift @ARGV;
  my ($filename,$filepath,$filesuffix) = fileparse($file,$regex_suffix); 
  open(IN,"<$file");
  @data = <IN>;
  close(IN);
  #print Dumper(@data);
  $lasttxt = pop(@data);
  open(OUT,">$filename"."_last.txt");
  print OUT $lasttxt;
}


