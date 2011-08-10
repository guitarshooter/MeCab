#!/usr/bin/perl
use MeCab;
use Data::Dumper;
use File::Basename;
use TermExtract::MeCab;
use Unicode::Japanese;

my $regex_suffix = qw/\.[^\.]+$/; #拡張子をのぞくための正規表現
my $DELLSTR="DELLWORD"; #削除辞書区別フラグ

open(OUT,">title_words.txt");
my $argcnt = $#ARGV + 1;
print $argcnt." file..."."\n";
while(@ARGV){
  $argcnt = @ARGV;
  if($argcnt % 10 == 0){print $argcnt." file remains..."."\n"};
  my $txt = "";
  my $pos_str = "";
  my %wordcount = ();
  my $file = shift @ARGV;
  my ($filename,$filepath,$filesuffix) = fileparse($file,$regex_suffix); 
  open(IN,"<$file");
  open(TRM,">$filename"."_term.txt");
  open(POS,">$filename"."_pos.txt");
  $txt = do { local $/; <IN> };
  print OUT "$filename";
  $mecab = MeCab::Tagger->new();
  $data = new TermExtract::MeCab;
  
  $node = $mecab->parseToNode($txt);
  while ($node) {
    my $word     = $node->{'surface'};
    my $feature  = $node->{'feature'};
    my @features = split(',', $feature);
    $word =~ tr/a-z/A-Z/; #小文字→大文字変換
    $nom_word = Unicode::Japanese->new($word)->h2z->get; #半角→全角に統一
    $lower_word = Unicode::Japanese->new($word)->z2h->get; #半角→全角に統一
    $pos_str .= join("\t",$word,$feature)."\n";

    if (($features[0] eq '名詞') && ($features[1] !~ m/数|接尾|代名詞|固有名詞|非自立|サ変接続|副詞可能|形容動詞語幹/) 
       && ($features[2] !~ m/助動詞語幹|助数詞/) && ($features[9] ne $DELLSTR)
       && ($lower_word !~ m/[a-zA-Z]/) #アルファベット一文字
    )
    {
            $wordcount{$nom_word}+=1;
    }
    $node = $node->{next};
  }

  foreach $w (keys %wordcount){
    print OUT "\t".$w."\t"."$wordcount{$w}";
  }
  print OUT "\n";
  
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
}

