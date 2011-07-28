#!/usr/bin/perl
use MeCab;
use Data::Dumper;
use File::Basename;
use TermExtract::MeCab;
use Unicode::Japanese;

my %allwords;
my %wordmatrix;
my %filetitle;
my $fileid=0;
my $regex_suffix = qw/\.[^\.]+$/; #拡張子をのぞくための正規表現
my $DELLSTR="DELLWORD"; #削除辞書区別フラグ

open(ALL,">allwords.txt");
open(CNT,">arrt_words.txt");
print CNT "単語";
while(@ARGV){
  my $txt = "";
  my $pos_str = "";
  my $file = shift @ARGV;
  my ($filename,$filepath,$filesuffix) = fileparse($file,$regex_suffix); 
  open(IN,"<$file");
  open(TRM,">$filename"."_term.txt");
  open(POS,">$filename"."_pos.txt");
  $txt = do { local $/; <IN> };
  $filetitle{$fileid}=$file;
  print CNT ","."$file";
  #$mecab = MeCab::Tagger->new("-u /Users/shooter/Bin/MeCab/wikipedia.dic");
  $mecab = MeCab::Tagger->new();
  $data = new TermExtract::MeCab;
  
  $node = $mecab->parseToNode($txt);
  while ($node) {
  #  my $id       = $node->{'id'};
    my $word     = $node->{'surface'};
    my $feature  = $node->{'feature'};
    my @features = split(',', $feature);
    #my @categories  = grep { $_ ne '*' } @features[0..3];    # 品詞
    #my $conjugation = $features[4] if ($features[4] ne '*'); # 活用
    #my $conjugate   = $features[5] if ($features[5] ne '*'); # 活用形
    #my $description = $features[6] if ($features[6] ne '*'); # 記述
#    print $word,$#features,"\n";
    $word =~ tr/a-z/A-Z/; #小文字→大文字変換
    $nom_word = Unicode::Japanese->new($word)->h2z->get; #半角→全角に統一
    $lower_word = Unicode::Japanese->new($word)->z2h->get; #半角→全角に統一

    #my $pronunce    = $features[8] if ($features[8] ne '*'); # 発音
    #print join("\t", $word, $categories[0], $kana, $pronunce), "\n";
    
    #print OUT join("\t",$word,$feature),"\n";
    $pos_str .= join("\t",$word,$feature)."\n";

    if (($features[0] eq '名詞') && ($features[1] !~ m/数|接尾|代名詞|固有名詞|非自立/) 
       && ($features[2] !~ m/助動詞語幹|副詞可能/) && ($features[9] ne $DELLSTR)
       && ($lower_word !~ m/[a-zA-Z]/) #アルファベット一文字
    )
    {
	    #print join("\t",$word,$feature),"\n";
            $allwords{$nom_word}+=1;
	    $wordmatrix{$nom_word}{$fileid}+=1;
    }
    $node = $node->{next};
  }
  #形態素解析結果出力
  print POS $pos_str;
  #TermExtract 出力
    @noun_list = $data->get_imp_word($pos_str,'var');
    foreach (@noun_list) {
       # 日付・時刻は表示しない
       next if $_->[0] =~ /^(昭和)*(平成)*(\d+年)*(\d+月)*(\d+日)*(午前)*(午後)*(\d+時)*(\d+分)*(\d+秒)*$/;
       # 数値のみは表示しない
       next if $_->[0] =~ /^\d+$/;
       # 結果表示
#       printf TRM "%-60s %16.2f\n", $_->[0], $_->[1];
       printf TRM "%-s,%.2f\n",$_->[0],$_->[1];
    }
    $fileid += 1;
}
    
foreach $key (sort { $allwords{$b} <=> $allwords{$a} } keys %allwords) {
  print ALL "$key".","."$allwords{$key}\n";
  print CNT "\n",$key;
    for($arrt_id=0;$arrt_id<$fileid;$arrt_id++){
      unless($wordmatrix{$key}->{$arrt_id}){
        $cnt = 0;
      }else{
        $cnt = $wordmatrix{$key}->{$arrt_id};
      }
      print CNT ",".$cnt;
    }
#    print CNT "\n";
}

#foreach my $wordkey ( keys %wordmatrix ){
##    foreach my $arrt_id ( sort { $wordmatrix{$wordkey}->{$a} <=>  $wordmatrix{$wordkey}->{$b} } keys %{$wordmatrix{$wordkey}} ){
#	print $wordkey."\t";
#	for($arrt_id=0;$arrt_id<$fileid;$arrt_id++){
##	    print "$wordkey\t$arrt_id\t".$wordmatrix{$wordkey}->{$arrt_id} ."\n";
#	    print $wordmatrix{$wordkey}->{$arrt_id} ."\t";
#    }
#    print "\n";
#}

