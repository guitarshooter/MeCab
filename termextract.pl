#!/usr/bin/perl
use MeCab;
use Data::Dumper;
use File::Basename;
use TermExtract::MeCab;
my %allwords;
my %wordmatrix;
my %filetitle;
my $fileid=0;
my $regex_suffix = qw/\.[^\.]+$/; #拡張子をのぞくための正規表現

while(@ARGV){
  my $txt = "";
  my $pos_str = "";
  my $file = shift @ARGV;
  my ($filename,$filepath,$filesuffix) = fileparse($file,$regex_suffix); 
  open(IN,"<$file");
  $txt = do { local $/; <IN> };
  $filetitle{$fileid}=$file;
  $mecab = MeCab::Tagger->new();
  $data = new TermExtract::MeCab;
  
  $node = $mecab->parseToNode($txt);
  while ($node) {
    my $word     = $node->{'surface'};
    my $feature  = $node->{'feature'};
    my @features = split(',', $feature);
    $pos_str .= join("\t",$word,$feature)."\n";

    #print $pos_str;
    if (($features[0] eq '名詞') && ($features[1] !~ m/数|接尾/) ){
	    #print join("\t",$word,$feature),"\n";
            $allwords{$word}+=1;
	    $wordmatrix{$word}{$fileid}+=1;
    }
    $node = $node->{next};
  }
  #形態素解析結果出力
  #TermExtract 出力
    @noun_list = $data->get_imp_word($pos_str,'var');
    foreach (@noun_list) {
       # 日付・時刻は表示しない
       next if $_->[0] =~ /^(昭和)*(平成)*(\d+年)*(\d+月)*(\d+日)*(午前)*(午後)*(\d+時)*(\d+分)*(\d+秒)*$/;
       # 数値のみは表示しない
       next if $_->[0] =~ /^\d+$/;
       # 結果表示
       printf "%-60s %16.2f\n", $_->[0], $_->[1];
    #   print $_->[0], $_->[1];
    }
}
    
#print "---------------------------------------------","\n";
foreach $key (sort { $allwords{$b} <=> $allwords{$a} } keys %allwords) {
#  print "$key\t$allwords{$key}\n";
}


