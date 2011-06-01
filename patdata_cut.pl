#!/usr/bin/perl
use File::Basename;
my $regex_suffix = qw/\.[^\.]+$/; #拡張子をのぞくための正規表現

while(@ARGV){
  my $txt = "";
  my $pos_str = "";
  my $file = shift @ARGV;
  my ($filename,$filepath,$filesuffix) = fileparse($file,$regex_suffix); 
  open(IN,"<$file");
  open(DATA,">$filename"."_dat.txt");

  $txt = do { local $/; <IN> };
  $txt =~ s/^↑//gm; #頭の矢印を削除
  $txt =~ s/^.+\(57\)【要約】//s; #文の頭から要約までを削除
  #$txt =~ s/【符号の説明】.+【代表図面】//s;
  $txt =~ s/【図面の簡単な説明】.+$//s; #【符号の説明】以下全部削除
  $txt =~ s/フロントページの続き.+$//s; #上記がない場合、フロントページの続き以下を削除
  $txt =~ s/^【選択図】.+$//gm;
  $txt =~ s/^\s$//gm; #先頭が改行
  $txt =~ s/^(?:\s|　)+//gm;#先頭スペース削除 
  $txt =~ s/^(.*?)(?:\s|　)+$/$1/gm;#後ろスペース削除 
  $txt =~ s/^──.*──//gm; #先頭が改行
  $txt =~ s/^【.+?】(.*)$/$1/gm; #【○○】のみ行を削除
  $txt =~ s/^\s*$//gm;#空行を削除
  print DATA $txt;
}
