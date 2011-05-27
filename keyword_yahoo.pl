use WebService::Simple;
use HTML::ContentExtractor;
use HTTP::Request::Common;
use LWP::UserAgent;
use Encode;
use URI::Escape;
use XML::Simple;
use utf8;

my $url = $ARGV[0];
my $extractor = HTML::ContentExtractor->new();
my $ua = LWP::UserAgent->new();
$ua->env_proxy;
my $res = $ua->get($url);
my $html = $res->decoded_content();
$extractor->extract( $url, $html );
my $text = $extractor->as_text();
#$text = substr $text, 0, 500;
#$text = join('',<>);    # 解析対象のテキスト
my $text = $extractor->as_text();
#$text = substr $text, 0, 500;
print $text,"\n";
my $escaped = uri_escape(encode('utf-8', $text));


my $base_url = 'http://jlp.yahooapis.jp/KeyphraseService/V1/extract';
#my $base_url = 'http://10.124.36.191/~10005239/post.php';
my $appid = 'xLttL2axg65UrtjTDODvvsXao2nxxGFV4g58g1T2upk4lT.jF8_8kj1A9q200g--';
my %data = ( 'appid' => $appid,
             'sentence' => $escaped
            );
#my $req = HTTP::Request::Common::POST($base_url, [%data]);
$ua2 = LWP::UserAgent->new();
$ua2->env_proxy;
#$resxml = $ua2->request($req);
$resxml = $ua2->request(POST $base_url,\%data);
$ans = $resxml->content;
print encode('utf-8', $ans);
#my $ref = $resxml->parse_response();
#for my $key ( keys %$ref ) {
#    print encode_utf8("$key\n") if $ref->{$key} > 50;
#}
