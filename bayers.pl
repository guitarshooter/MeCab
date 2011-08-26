#!/usr/bin/perl

use strict;
use Algorithm::NaiveBayes;
use Algorithm::NaiveBayes::Model::Frequency;
use Storable;
use Getopt::Std;
use Data::Dumper;

getopt('cfl'); #Command, File, Label
use vars qw / $opt_c $opt_f $opt_l /;

my $bayes;
my $DB    = 'bayes.db';
my $command = $opt_c;
my $file  = $opt_f;
my $label = $opt_l;

if (!defined($file)) { 
  die "usage: -c [predict|train] -f filename -l label\n";
}
$bayes = &loadInstance;
if ($command eq 'predict') {
  &calcPredict($file);
} elsif ($command eq 'train') {
  if (!defined($label)) {die "need -l labelname\n"};
  &trainInstance($file,$label);
}


sub calcPredict {
  my $file = $_[0];
  open INFILE, "< $file" or die "Cannot open file: $file";
  while (<INFILE>) {
    chomp();
    my @line = split(/\t/,$_);
    my $linecnt = @line;
    my %list;
    my $title = $line[0];
    $title =~ s/_dat//g;
    print $title;
    my ($i,$word,$cnt);
    for($i=1;$i<$linecnt;){
      my $linecnt = @line;
      if($i % 2 == 1){
        $word = $line[$i];
        $cnt = $line[$i+1];
        $list{$word}=$cnt;
      }
      $i=$i+2;
    }
    #my %list = &getHash($file);
    my $result = $bayes->predict(
      attributes => {%list}
    );
    foreach my $key (sort {$$result{$b} <=> $$result{$a}} keys %$result){
      print ",".$key.",".$$result{$key};
    }
    print "\n";
    #print Dumper($result);
  }
}
  
sub trainInstance {
  my $file  = $_[0];
  my $labelfile = $_[1];
  my %labelhush;
  #my %list = &getHash($file);
  open INFILE, "< $file" or die "Cannot open file: $file";
  open INLABEL, "< $labelfile" or die "Cannot open file: $file";

  while (<INLABEL>) {
    chomp();
    my ($docname,$labelname)=split(/,/,$_);
    $docname =~ s/_dat//g;
    $labelhush{$docname}=$labelname;
    #print $docname,$labelhush{$docname};
  }

  while (<INFILE>) {
    chomp();
    my %hash=();
    my @line = split(/\t/,$_);
    my $linecnt = @line;
    my ($word,$i,$cnt);
    my $doc = $line[0];
    $doc =~ s/_dat//g;
    if($labelhush{$doc}){ #ラベルがないものはスキップ
      for($i=1;$i<$linecnt;){
        if($i % 2 == 1){
          $word = $line[$i];
          $cnt = $line[$i+1];
          $hash{$word} = $cnt;
        }
        $i=$i+2;
      }
      $bayes->add_instance(
        attributes => {%hash},
        label => $labelhush{$doc},
      );
      print "$doc".":".$labelhush{$doc}." reading..."."\n";
    }else{
      print "$doc".": No Label. skip..."."\n";
    }
  }
  $bayes->train;
  Storable::store($bayes => $DB );
}

sub loadInstance {
  eval {$bayes = Storable::retrieve($DB)} if -e $DB;
  $bayes ||= Algorithm::NaiveBayes->new(purge => 0);
  return $bayes;
}

sub getHash {
  my $file = $_[0];
  my %hash;
  open INFILE, "< $file" or die "Cannot open file: $file";

  while (<INFILE>) {
    chomp();
    my @line = split(/\t/,$_);
    my $linecnt = @line;
    my $word;
    my $i;
    my $cnt;
    for($i=1;$i<$linecnt;){
      if($i % 2 == 1){
        $word = $line[$i];
        $cnt = $line[$i+1];
        if (!$hash{$word}) {$hash{$word} = 0}; 
        $hash{$word} = $hash{$word}+$cnt;
      }
      $i=$i+2;
    }
  }
  return %hash;
}
  eval {$bayes = Storable::retrieve($DB)} if -e $DB;
  $bayes ||= Algorithm::NaiveBayes->new(purge => 0);
  #print Dumper($bayes);
