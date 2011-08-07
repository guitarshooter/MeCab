#!/usr/bin/perl -w

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
  die "usage: need -f filename\n";
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
    print $title,"\n";
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
    print Dumper($result);
  }
}
  
sub trainInstance {
  my $file  = $_[0];
  my $label = $_[1];
  my %list = &getHash($file);
  $bayes->add_instance(
    attributes => {%list},
    label => $label,
  );
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
  print Dumper($bayes);
