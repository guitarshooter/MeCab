#!/usr/bin/perl
use File::Basename;
my $regex_suffix = qw/\.[^\.]+$/; #拡張子をのぞくための正規表現

while(@ARGV){
  my $txt = "";
  my $pos_str = "";
  my $file = shift @ARGV;
  my ($filename,$filepath,$filesuffix) = fileparse($file,$regex_suffix); 
  open(IN,"<$file");
#  open(DATA,">$filename"."_dat.txt");

  $txt = do { local $/; <IN> };
  $txt =~ s/^↑//gm; #文の頭から要約までを削除
  $txt =~ s/^.+\(57\)【要約】//s; #文の頭から要約までを削除
  $txt =~ s/^【.+】\r$//gm; #文の頭から要約までを削除
  $txt =~ s/^\r\n//gm;
  print $txt;
}
