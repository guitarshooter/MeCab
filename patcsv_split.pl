#!/usr/bin/perl
#ダウンロードしたCSVから、特許番号と発明の効果を抜き出す
use Encode;
use Data::Dumper;
use Text::CSV_XS;

while(@ARGV){
  $file = shift;
  my $csv = Text::CSV_XS->new({binary => 1});
  open my $IN,"<",$file;
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
    $txt =~ s/(^|。)(.*)。/$1/gm;

    if(length($txt)){
#      open(FH,">$row[1]".".txt");
#      print FH $txt;
      print $txt;
    }
  }
}
