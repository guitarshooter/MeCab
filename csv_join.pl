#!/usr/bin/perl
#CSVのカラムをすべてJOINしてひとつのファイルに（ファイル名は最左列）
use Encode;
use File::Basename;
use Data::Dumper;
use Text::CSV_XS;
my $regex_suffix = qw/\.[^\.]+$/; #拡張子をのぞくための正規表現

if($#ARGV == -1){
  die "Usage:$0 [fieldno] filename...\n";
}
my $i=0;

while(@ARGV){
  $file = shift;
  my $csv = Text::CSV_XS->new({binary => 1});
  open my $IN,"<",$file;
  my ($filename,$filepath,$filesuffix) = fileparse($file,$regex_suffix); 
  #open(CSV,">最後の一文_".$filename.".csv");
  while ( my $row = $csv->getline($IN) ){ 
    map( { Encode::from_to($_,"cp932","utf8") } @$row);
    if($i == 0){
      $i++;
      next;
    }
    $outfile = shift @$row;
    $txt = join("",@$row);

    if(length($txt)){
      open(FH,">$outfile".".csv.txt");
      print FH $txt;
      #print CSV $$row[1],',"',$$row[3].'","'.$txt.'"'."\n";
#      print $$row[1].":".$txt."\n";
    }
    $i++;
  }
}
