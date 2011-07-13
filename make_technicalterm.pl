#!/usr/bin/perl
use MeCab;
use Data::Dumper;
use File::Basename;
use TermExtract::MeCab;
use Unicode::Japanese;

open(TECHTERM,">technicalterm.txt");

my $DELLSTR = "DELLWORD"; #削除辞書区別フラグ


while(<>){
  my $txt = "";
  my $pos_str = "";
  $txt = $_;
  $mecab = MeCab::Tagger->new();
  
  my $node_cnt = 0;
  $node = $mecab->parseToNode($txt);
  while ($node) {
    $node_cnt++;
    my $delflg = 0;
    my $word     = $node->{'surface'};
    my $feature  = $node->{'feature'};
    my @features = split(',', $feature);
    $word =~ tr/a-z/A-Z/; #小文字→大文字変換
    $nom_word = Unicode::Japanese->new($word)->h2z->get; #半角→全角に統一

    if ($features[9] eq $DELLFLG){
      $delflg = 1;
    }
  }
  if (($node_cnt > 1 ) && ($delflg = 0 )){
    print $txt;
  }
}
