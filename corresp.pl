#!/usr/bin/perl
use FindBin;
use File::Basename;
use Cwd;
use Encode;

my $cnt = @ARGV;

if($cnt < 1 && $cnt > 2){
  die("Usage:$0 inputfile [outputfile]"); #出力ファイル名は省略可能
}

my $regex_suffix = qw/\.[^\.]+$/; #拡張子をのぞくための正規表現
my $bindir = $FindBin::Bin; #実行パス
my $wd = Cwd::getcwd();
print $bindir."\n";
my $Rscript = "corresp_tmp.R"; #コレスポンデンス分析用Rスクリプト名

#my $inputData = $wd."/"."arrt_words_tf_select.txt"; #入力ファイル名（文書×単語（TF値）ファイル）
my $inputData = $wd."/".$ARGV[0]; #入力ファイル名（文書×単語（TF値）ファイル）
#my ($filename,$filepath,$filesuffix) = fileparse($file,$regex_suffix); 

open(IN,"<$inputData");
open(OUT,">$wd/corresp_calc.csv");
while($line = <IN>){
    Encode::from_to($line,"cp932","utf8");
  if($line =~ /^"/){
    $line =~ /^"(.+)"(.+)/;
    #print "111".$1,"\n";
    #print "222".$2,"\n";
    $comma = $1;
    $nocomma = $1;
    $data = $2;
    #print "----".$comma,"\n";
    $nocomma =~ s/,/、/g;
    #print "-------".$nocomma,"\n";
    #$line = s/"$comma"/"$nocomma"/g;
    $line = $nocomma.$data."\n";
  }
  print OUT $line;
}

if( -f $inputData){
  print "$inputData"." exist.\n";
}else{
  print "$inputData"." not exist."."\n";
  exit;
}

my ($filename,$filepath,$filesuffix) = fileparse($inputData,$regex_suffix); 
if($ARGV[1]){
  $output = $ARGV[1];
}else{
  $output = $filename;
}

open(FH,">$Rscript");

my $Rbat = <<"EOS";
library(MASS)
y<-read.csv("$wd/corresp_calc.csv",header=TRUE,row.names=1)
z <- y[rowSums(y) != 0, ]
x <- z[,colSums(z) != 0 ]
x.ca<-corresp(x,nf=3)
write.table(x.ca\$cscore,"./${output}_col.csv",sep=",",col.names=F)
write.table(x.ca\$rscore,"./${output}_row.csv",sep=",",col.names=F)
EOS

print FH $Rbat;

system("R  --vanilla --slave < $Rscript"); 


