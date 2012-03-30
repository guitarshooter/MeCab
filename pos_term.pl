#!/usr/bin/perl
use MeCab;
use Data::Dumper;
use File::Basename;
use TermExtract::MeCab;
use Unicode::Japanese;
use Getopt::Std;

my %filetitle;
my $fileid=0;
my $regex_suffix = qw/\.[^\.]+$/; #拡張子をのぞくための正規表現
my $DELLSTR="DELLWORD"; #削除辞書区別フラグ
my $OPTION="";

getopt "du";
print $opt_d,"\n";
print $opt_u,"\n";
if($opt_d){
  $OPTION .= " -d /usr/local/lib/mecab/dic/".$opt_d."/";
}
if($opt_u){
  $OPTION .= " -u ".$opt_u;
}

if(@ARGV == 0){
  print "$0 (-d DictionaryName) Input:テキストデータ（複数可） Output:POSデータファイル、TermExtractファイル\n";
}

while(@ARGV){
  my $txt = "";
  my $pos_str = "";
  my $pos_str_term = "";
  my $file = shift @ARGV;
  print $file."...\n";
  my ($filename,$filepath,$filesuffix) = fileparse($file,$regex_suffix); 
  open(IN,"<$file");
  open(TRM,">$filename".".term");
  open(POS,">$filename".".pos");
  $txt = do { local $/; <IN> };
  unless($txt){
    print "Notice:".$filename." is none...\n";
    next;
  }
  $filetitle{$fileid}=$filename;
  print CNT ","."$filename";
  print TF ","."$filename";
  $mecab = MeCab::Tagger->new("$OPTION");
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
    #print $word,$#features,"\n";
    $word =~ tr/a-z/A-Z/; #小文字→大文字変換
    $nom_word = Unicode::Japanese->new($word)->h2z->get; #半角→全角に統一
    $lower_word = Unicode::Japanese->new($word)->z2h->get; #半角→全角に統一

    #my $pronunce    = $features[8] if ($features[8] ne '*'); # 発音
    #print join("\t", $word, $categories[0], $kana, $pronunce), "\n";
    
    #print OUT join("\t",$word,$feature),"\n";
    $pos_str .= join("\t",$word,$feature)."\n";
    $pos_str_term .= join("\t",$word,$feature)."\n";
    $node = $node->{next};
  }
  #形態素解析結果出力
  print POS $pos_str;
  #TermExtract 出力
    @noun_list = $data->get_imp_word($pos_str_term,'var');
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
