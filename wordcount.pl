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
our $DELLSTR="DELLWORD"; #削除辞書区別フラグ

if($#ARGV == -1){
  die "Usage:$0 [posfile]...\n";
}

#形態素解析結果を受け取り、カウント対象単語を返す
sub IsCountWord() { 
  my @features = split(/\t|,/,$_);
  my $word = shift @features;
  my $lower_word = Unicode::Japanese->new($word)->z2h->get;

  if (($features[0] eq '名詞')
       && ($features[1] !~ m/数|接尾|代名詞|固有名詞|非自立|サ変接続|副詞可能|形容動詞語幹/) 
       && ($features[2] !~ m/助動詞語幹|助数詞/)
       && ($lower_word !~ m/[a-zA-Z]/) 
       && ($features[9] ne $DELLSTR) ){
        #アルファベット一文字は削除
        #未知語などは原型が*になるためそれ以外の場合に代入
         if($features[6] ne "*"){ 
           $word = $features[6];
         }
       }else{
         $word = ""; #カウントしない場合はNULLを返す
       }
       $word =~ tr/a-z/A-Z/; #小文字→大文字変換
       #$word = Unicode::Japanese->new($word)->h2z->get; #半角→全角に統一
       return $word;
}

open(ALL,">allwords.txt");
open(CNT,">arrt_words_cnt.txt");
open(TF,">arrt_words_tf.txt");
print CNT "単語";
print TF "単語";
while(@ARGV){
  my $pos_str = "";
  my $file = shift @ARGV;
  print $file."...\n";
  my ($filename,$filepath,$filesuffix) = fileparse($file,$regex_suffix); 
  open(IN,"<$file");
  #$txt = do { local $/; <IN> };
  $filetitle{$fileid}=$filename;
  print CNT ","."$filename";
  print TF ","."$filename";
  
  while (<IN>) {
    $pos_str = $_;
    $nom_word = &IsCountWord($pos_str);
    #print $nom_word;

    if ($nom_word){
            $allwords{$nom_word}+=1;
            $wordmatrix{$nom_word}{$fileid}+=1;
            $filewordcnt{$fileid}+=1;
    }
    $node = $node->{next};
  }
    $fileid += 1;
}

print TF ","."頻度合計",","."IDF値";
print CNT ","."頻度合計",","."IDF値";

    
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
      if($filewordcnt{$arrt_id}){
        $tf = $cnt/$filewordcnt{$arrt_id};
      }else{
        $tf = 0;
      }
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
