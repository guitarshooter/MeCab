#!/usr/bin/perl
#ニーズワード設定スクリプト

use MeCab;
use Data::Dumper;
use File::Basename;
use TermExtract::MeCab;
use Unicode::Japanese;
my $regex_suffix = qw/\.[^\.]+$/; #拡張子をのぞくための正規表現


while(@ARGV){
  my $file = shift @ARGV;
  my @data = ();
  my $flg = 0;
  my $needs_str = "";
  open(IN,"<$file");
  @data = <IN>;
  #BOS/EOSを取り除く
  if($data[0] =~ /BOS\/EOS/){
    shift(@data);
  }
  if($data[$#data] =~ /BOS\/EOS/){
    pop(@data);
  }

  #ニーズワード抽出部。逆から遡る
  for($i=$#data;0<=$i;$i--){
    #フラグが立っていれば、名詞一般まですべての単語を取得
    if($flg == 1){
      #名詞一般でない場合は取得
      if($data[$i] !~ /名詞,一般/){
        @line = split(/,/,$data[$i]);
        $needs_str = $line[0].$needs_str;
      }else{
        #名詞一般の場合、その単語を取得
        @line = split(/,/,$data[$i]);
        $needs_str = $line[0].$needs_str;
        #次が助詞や名詞以外なら終了
        if($data[$i-1] !~ /助詞,連体化|名詞,一般/){
          #前の単語が形容詞or接頭語ならそれも追加して終了
          if($data[$i-1] =~ /形容詞|接頭語/){
            @line = split(/,/,$data[$i-1]);
            $needs_str = $line[0].$needs_str;
          }
         last;
        }
      }
    }
    #注目ワード設定部
    if($flg != 1){
      #形容動詞があればフラグを立てる
      if($data[$i] =~ /形容動詞/){
        $flg = 1;
        @line = split(/,/,$data[$i]);
        $needs_str = $line[0].$needs_str;
      }
      #サ変接続&(Not 提供)&(Not 前後が名詞)であればフラグを立てる
      if($data[$i] =~ /サ変接続/ && $data[$i] !~ /提供/ && ($data[$i-1] !~ /名詞/ || $data[$i+1] !~ /名詞/)){
        $flg = 1;
        @line = split(/,/,$data[$i]);
        $needs_str = $line[0].$needs_str;
      }
      #注目ワードの後が名詞or接続詞なら連結
      if($flg == 1 && ($data[$i+1] =~ /名詞/ || $data[$i+1] =~ /接続詞/)){
        for($j=$i;$j<=$#data;$j++){
          if($data[$j+1] =~ /名詞/){
            @line = split(/,/,$data[$j+1]);
            $needs_str = $needs_str.$line[0];
          }else{
            last;
          }
        }
      }
    }
  }
  print $file.":".$needs_str,"\n";
}
