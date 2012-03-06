#!/usr/bin/perl
#ダウンロードしたCSVから、特許番号と発明の効果を抜き出す
use Encode;
use File::Basename;
use Data::Dumper;
use Text::CSV_XS;
my $regex_suffix = qw/\.[^\.]+$/; #拡張子をのぞくための正規表現

while(@ARGV){
  $file = shift;
  my $csv = Text::CSV_XS->new({binary => 1});
  open my $IN,"<",$file;
  my ($filename,$filepath,$filesuffix) = fileparse($file,$regex_suffix); 
  open(CSV,">最後の一文_".$filename.".csv");
  while ( my $row = $csv->getline($IN) ){ 
    map( { Encode::from_to($_,"cp932","utf8") } @$row);
    if($$row[1] eq "公開番号"){
      next;
    }
    $txt = $$row[9];
    $txt =~ s/【符号の説明】.+$//g;
    $txt =~ s/【.+?】//g;
    $txt =~ s/。/。\n/g;
    $txt =~ s/^ +//g;
    $txt =~ s/^\n//g;
    $txt =~ s/ +$//g;
    $txt =~ s/^\s$//gm; #先頭が改行
    $txt =~ s/^(?:\s|　)+//gm;#先頭スペース削除 
    $txt =~ s/^(.*?)(?:\s|　)+$/$1/gm;#後ろスペース削除 
    my @last = split(/\n/,$txt);
    $txt = pop(@last);

    if(length($txt)){
      open(FH,">$$row[1]".".last");
      print FH $txt;
      print CSV $$row[1],',"',$$row[3].'","'.$txt.'"'."\n";
#      print $$row[1].":".$txt."\n";
    }
  }
}
