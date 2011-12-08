#!/usr/bin/perl
use MeCab;
use Data::Dumper;
use File::Basename;
use TermExtract::MeCab;
use Unicode::Japanese;

my %allwords;
my %wordmatrix;
my %filewordcnt;
my %filewordmatrix; #{file=>{word => count}}のハッシュ
my %filetitle;
my $fileid=0;
my $regex_suffix = qw/\.[^\.]+$/; #拡張子をのぞくための正規表現
my $DELLSTR="DELLWORD"; #削除辞書区別フラグ

open(ALL,">allwords.txt");
open(CNT,">arrt_words_cnt.txt");
open(TF,">arrt_words_tf.txt");
#open(CLUST,">arrt_words_clust.txt");
print CNT "単語";
print TF "単語";
while(@ARGV){
  my $txt = "";
  my $pos_str = "";
  my $file = shift @ARGV;
  print $file."...\n";
  my ($filename,$filepath,$filesuffix) = fileparse($file,$regex_suffix); 
  open(IN,"<$file");
  open(TRM,">$filename"."_term.txt");
  open(POS,">$filename"."_pos.txt");
  $txt = do { local $/; <IN> };
  unless($txt){
    print "Notice:".$filename." is none...\n";
    next;
  }
  $filetitle{$fileid}=$filename;
  print CNT ","."$filename";
  print TF ","."$filename";
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

    if (($features[0] eq '名詞') && ($features[1] !~ m/数|接尾|代名詞|固有名詞|非自立|サ変接続|副詞可能|形容動詞語幹/) 
       && ($features[2] !~ m/助動詞語幹|助数詞/) && ($features[9] ne $DELLSTR)
       && ($lower_word !~ m/[a-zA-Z]/) #アルファベット一文字
    )
    {
            #print join("\t",$word,$feature),"\n";
            $allwords{$nom_word}+=1;
            $wordmatrix{$nom_word}{$fileid}+=1;
            $filewordcnt{$fileid}+=1;
            #$filewordmatrix{$fileid}{$nom_word}+=1;
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

print TF ","."頻度合計",","."IDF値";
print CNT ","."頻度合計",","."IDF値";

#print Dumper(\%filewordcnt);
    
foreach $key (sort { $allwords{$b} <=> $allwords{$a} } keys %allwords) {
  my $doccnt=0;
  print ALL "$key".","."$allwords{$key}";
  print CNT "\n",$key;
  print TF "\n",$key;
    for($arrt_id=0;$arrt_id<$fileid;$arrt_id++){
      my $cnt = 0;
      if(exists($wordmatrix{$key}->{$arrt_id})){
        $cnt = $wordmatrix{$key}->{$arrt_id};
        $doccnt += 1;
      }
      $tf = $cnt/$filewordcnt{$arrt_id};
      #$filewordmatrix{$arrt_id}{$key}=$tf;
      $filewordmatrix{$arrt_id}{$key}=$cnt;
      print CNT ",".$cnt;
      print TF ",".$tf;
    }
    $idf = 1+log(($fileid+1)/$doccnt)/log(2);
    print ALL ",".$idf."\n"; 
    print CNT ","."$allwords{$key}";
    print CNT ",".$idf;
    print TF ","."$allwords{$key}";
    print TF ",".$idf;
}


#for($arrt_id=0;$arrt_id<$fileid;$arrt_id++){
#  print CLUST $filetitle{$arrt_id};
#  foreach $keyword (sort { $filewordmatrix{$arrt_id}{$a} <=> $filewordmatrix{$arrt_id}{$b} } keys %{$filewordmatrix{$arrt_id}}) {
#    print CLUST "\t".$keyword."\t".$filewordmatrix{$arrt_id}->{$keyword};
#  }
#  print CLUST "\n";
#}
