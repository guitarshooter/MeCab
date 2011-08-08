#!/usr/bin/perl
use Unicode::Japanese;
use File::Basename;
use strict;

my %allwords;
my %wordmatrix;
my %filewordcnt;
my %filewordmatrix; #{file=>{word => count}}のハッシュ
my %header;
my $fileid=0;
my $regex_suffix = qw/\.[^\.]+$/; #拡張子をのぞくための正規表現
#頻度とFH値のファイル名
my @arrt_file = ("arrt_words_cnt.txt","arrt_words_tf.txt");

my $MAXIDF;
my $MINIDF = 2;  #使用する単語のIDF最小値。
my $MINCNT = 10; #使用する単語の最小頻度。

while(@arrt_file){
  my $file = shift @arrt_file;
  open(FH,"<$file");
  my ($filename,$filepath,$filesuffix) = fileparse($file,$regex_suffix); 
  open(SELECT,">".$filename."_select.txt");
  open(TITLE,">".$filename."_select_title.txt");

  my @fileline = <FH>;

  print SELECT $fileline[0];

  my $headerline = shift(@fileline); #１行目はヘッダなので削除
  my $linecnt = @fileline; #ファイルの行数＝単語数-1
  my @header = split(/,/,$headerline);
  #左端はヘッダ、右２つは頻度とIDF値なのでカット
  my @filetitle = @header[1..$#header-2]; 

  my $alldoccnt = @header;
  $alldoccnt = $alldoccnt - 2; #ドキュメント数＝カラム数-2（全頻度,IDF値）
  $MAXIDF = 1+log($alldoccnt)/log(2); #使用する単語のIDF最大値。

  my $i;
  for($i=0;$i<$linecnt;$i++){
    my @filelist = split(/,/,$fileline[$i]);
    my $idf = pop(@filelist);
    chomp($idf);
    my $cnt = pop(@filelist);
    my $word = shift(@filelist);
    #print join(",",$idf,$cnt,$word),"\n";
    #IDF値が一定の重みより大きく、かつ、大きすぎず、頻度は一定以上の単語
    if($idf < $MAXIDF && $idf >= $MINIDF && $cnt >= $MINCNT){
      #使用単語×文書リスト
      print SELECT join(",",$word,@filelist,$cnt,$idf),"\n"; 
      #クラスタ作成用ファイル 文書,key1,value1,key2,value2...
      my $j=0;
      for($j=0;$j<$alldoccnt;$j++){
        $filewordmatrix{$j}{$word}=$filelist[$j];
      }
    }
  }

  my $arrt_id=0;
  for($arrt_id=0;$arrt_id<$alldoccnt;$arrt_id++){
    print TITLE $filetitle[$arrt_id];
    foreach my $keyword (sort { $filewordmatrix{$arrt_id}{$a} <=> $filewordmatrix{$arrt_id}{$b} } keys %{$filewordmatrix{$arrt_id}}) {
      print TITLE "\t".$keyword."\t".$filewordmatrix{$arrt_id}->{$keyword};
    }
    print TITLE "\n";
  }
}
