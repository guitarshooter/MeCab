#!/usr/bin/perl
#ダウンロードしたCSVから、特許番号と発明の効果を抜き出す
use Encode;
use File::Basename;
use Data::Dumper;
use Text::CSV_XS;
my $regex_suffix = qw/\.[^\.]+$/; #拡張子をのぞくための正規表現

$f = shift @ARGV;
if($f !~ /[0-9]/ ||@ARGV < 1){
  die "Usage:$0 [fieldno] filename...\n";
}

while(@ARGV){
  $file = shift;
  my $csv = Text::CSV_XS->new({binary => 1});
  open my $IN,"<",$file;
  my ($filename,$filepath,$filesuffix) = fileparse($file,$regex_suffix); 
  #open(CSV,">最後の一文_".$filename.".csv");
  while ( my $row = $csv->getline($IN) ){ 
    map( { Encode::from_to($_,"cp932","utf8") } @$row);
    if($$row[1] eq "公開番号"){
      next;
    }
    $txt = $$row[$f];
    $txt =~ s/【符号の説明】.+$//g;
    $txt =~ s/^\(57\)//s; #文の頭から要約／特許請求の範囲までを削除
    $txt =~ s/。/。\n/g;
    $txt =~ s/【図面の簡単な説明】.+$//s; #【符号の説明】以下全部削除
    $txt =~ s/【符号の説明】.+$//s;
    $txt =~ s/【代表図面】.+$//s;
    $txt =~ s/フロントページの続き.+$//s; #上記がない場合、フロントページの続き以下を削除
    $txt =~ s/^【選択図】.+$//gm;
    $txt =~ s/【.+?】//g;
    $txt =~ s/^ +//g;
    $txt =~ s/^\n//g;
    $txt =~ s/ +$//g;
    $txt =~ s/^\s$//gm; #先頭が改行
    $txt =~ s/^(?:\s|　)+//gm;#先頭スペース削除 
    $txt =~ s/^(.*?)(?:\s|　)+$/$1/gm;#後ろスペース削除 
    #my @last = split(/\n/,$txt);
    #$txt = pop(@last);

    if(length($txt)){
      open(FH,">$$row[0]".".csv.txt");
      print FH $txt;
      #print CSV $$row[1],',"',$$row[3].'","'.$txt.'"'."\n";
#      print $$row[1].":".$txt."\n";
    }
  }
}
