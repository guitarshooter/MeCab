#!/usr/bin/perl
use FindBin;

my $bindir = $FindBin::Bin; #実行パス
my $Rscript = "corresp.R"; #コレスポンデンス分析用Rスクリプト名
my $outData_col = "corr_data_arrt.txt"; #出力ファイル名（文書名）
my $outData_row = "corr_data_word.txt"; #出力ファイル名（単語）
my $inputData = "arrt_word_tf.txt"; #入力ファイル名（文書×単語（TF値）ファイル）

#print ("R  --vanilla --slave < $bindir/$Rscript"); 

system("R  --vanilla --slave < $bindir/$Rscript"); 


