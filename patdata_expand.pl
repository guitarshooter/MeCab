use HTML::Scrubber;
use File::Find;
use File::Path;
use Encode;

my @files;
my $CABEXTRACT = "/usr/local/bin/cabextract";

my $filename = "ZenData.htm"; #特許データファイル名
my $dir = "Contents"; # 解凍したら出現するフォルダ名


while(@ARGV){
  my (@list, @filedir) =();
  my $cabfile = shift @ARGV;
  $rep = `$CABEXTRACT $cabfile|grep Zenbun|wc -l`;
  print $cabfile."...".$rep;
}

# 複数ディレクトリからファイルを検索する
find(\&wanted, ($dir)); 
sub wanted{
    push(@list, "$File::Find::name");
}
foreach(@list){
    if($_ =~ /$filename/){
        push(@files, $_);
    }
}
$c = @files;
print "All file... ".$c,"\n";
while(@files){
  $html ="";
  $txt = "";
  $file = shift @files;
  open(IN,$file);

  @lines = <IN>;
  while(@lines){
    $_ = shift @lines;
    Encode::from_to($_,"cp932","utf8");
    if(/^\(11\)【.+番号】(.+)<BR>/){
#    if(/^\(11\)【公.+番号】(\d{4}).(\d{4-})<BR>/)
      $filename = $1;
      $filename =~ s/（.+$//;
      $filename =~ s/０/0/g;
      $filename =~ s/１/1/g;
      $filename =~ s/２/2/g;
      $filename =~ s/３/3/g;
      $filename =~ s/４/4/g;
      $filename =~ s/５/5/g;
      $filename =~ s/６/6/g;
      $filename =~ s/７/7/g;
      $filename =~ s/８/8/g;
      $filename =~ s/９/9/g;
      $filename =~ s/－/\-/g;      
      #$filename =~ s/\x{2212}/\x{FF0D}/g;
      if($filename =~ m/.+-.+/){
        my @f = split(/-/,$filename);
        $filename = $f[0]."-".sprintf("%06d",$f[1]);
      }
      $filename = $filename.".txt";
      print $filename,"\n";
#      print Encode::from_to($filename, "shiftjis","utf8" );
    }
    $html .= $_;
  }
  my $scrubber = HTML::Scrubber->new();
  open(OUT,">$filename");
  $txt = $scrubber->scrub($html);
  $txt =~ s/^\s$//mg;
  print OUT $txt;
  close(OUT);
}

if (rmtree($dir)) {
} else {
  print "$dir Delete Error: $!\n";
}
