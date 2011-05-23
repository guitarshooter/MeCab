use strict;
use warnings;
use Lingua::JA::Summarize;

my $text = join('',<>);    # 解析対象のテキスト

my $s = Lingua::JA::Summarize->new({
   charset => 'utf8',
   mecab_charset => 'utf8',
   default_cost => 1.8,
   singlechar_factor => 0.2,
});
$s->analyze($text);
my @keywords = $s->keywords({threshold=>4, maxwords=>10, minwords=>3});

print join(' ', @keywords), "\n";
