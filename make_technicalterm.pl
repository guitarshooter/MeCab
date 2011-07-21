#!/usr/bin/perl
use MeCab;
use Data::Dumper;
use File::Basename;
use TermExtract::MeCab;
use Unicode::Japanese;
#open(TECHTERM,">technicalterm.txt");
my $DELLSTR = "DELLWORD"; #削除辞書区別フラグ

my %term_score;
my %word_join;

while(<>){
  my $txt = "";
  my $pos_str = "";
  my $score = 0;
  $line = $_;
  ($txt,$score) = split(/,/,$line);
  $term_score{$wordlist[0]}+=$wordlist[1];
  $mecab = MeCab::Tagger->new();
  
  my $node_cnt = 0;
  my $delflg = 0;
  my $node_word = "";
  $node = $mecab->parseToNode($txt);
  while ($node) {
    my $word     = $node->{'surface'};
    my $feature  = $node->{'feature'};
    my @features = split(',', $feature);
    $word =~ tr/a-z/A-Z/; #小文字→大文字変換
    $nom_word = Unicode::Japanese->new($word)->h2z->get; #半角→全角に統一
    if ( $features[0] ne "BOS/EOS" ){
      $node_cnt++;
      $node_word = $node_word." ".$word;
      if ($features[9] eq $DELLSTR){
        $delflg = 1;
      }
	#    print $word,"\n";
	#    print "NODECNT:".$node_cnt,"\n";
	#    print $delflg,"\n";
#     if (($node_cnt > 1 ) && ($delflg == 0 )){
#        print $txt;
#     }
    }
    $node = $node->{next};
  }
  if (($node_cnt > 1 ) && ($delflg == 0 )){
    $term_score{$txt}+=$score;
    $word_join{$txt}=$node_word;
  }
}
foreach my $wd (sort { $term_score{$b} <=> $term_score{$a} } keys %term_score){
  print "$wd,$term_score{$wd},$word_join{$wd}\n";
}
