use strict;
use warnings;
use utf8;
use Encode;
use LWP::UserAgent;
use Data::Dumper;
use URI::Escape;
use XML::Simple;
use HTML::ContentExtractor;


my $yahoo_app_id = 'xLttL2axg65UrtjTDODvvsXao2nxxGFV4g58g1T2upk4lT.jF8_8kj1A9q200g--';
my $agent        = 'Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)';
my $apibaseuri   = 'http://jlp.yahooapis.jp/KeyphraseService/V1/extract';
my $referrer     = 'http://developer.yahoo.co.jp/';

my $text = <<'EOS';
第1条（はじめに）
この利用規約は、株式会社はてな（以下「当社」）が本サイト上で提供する全てのサービス（以下「本サービス」）における利用条件を定めるものです。ユーザーのみなさま（以下「ユーザー」）には、本規約に従い本サービスをご利用いただきます。
本サービス内には、本規約以外に「ヘルプ」や各種ガイドラインにおいて、本サービスの利用方法や注意書きが提示されています。これらも本規約の一部を実質的に構成するものですので、合わせてお読みください。
EOS
my $url = $ARGV[0];
my $extractor = HTML::ContentExtractor->new();
my $ua = LWP::UserAgent->new();
$ua->env_proxy;
my $res = $ua->get($url);
my $html = $res->decoded_content();
$extractor->extract( $url, $html );
my $text = $extractor->as_text();
$text = substr $text, 0, 500;



# 文字列は URL エンコードしておく
my $escaped = uri_escape(encode('utf-8', $text));
my $url = sprintf('%s?output=xml&appid=%s&sentence=%s', $apibaseuri, $yahoo_app_id, $escaped);

my $ua = LWP::UserAgent->new;
my $req = HTTP::Request->new('GET', $url);
$ua->agent($agent);
$ua->env_proxy;
$req->referer($referrer);
my $response = $ua->request($req);

unless ($response->is_success) {
   print 'Request: ' . $url, " ";
    warn 'Failed to request to WEB API.', "\n";
} else {
    # see at http://iandeth.dyndns.org/mt/ian/archives/000589.html
    $XML::Simple::PREFERRED_PARSER = 'XML::Parser';
    # see at http://search.cpan.org/dist/XML-Simple/lib/XML/Simple.pm#ForceArray_=%3E_1_#_in_-_important
    my $xmlparser = XML::Simple->new(ForceArray => ['Result']);
    my $results   = $xmlparser->XMLin(decode_utf8($response->content));

    if ($results->{Error}->{Message}) {
        warn 'Error occured: ', $results->{Error}->{Message}, " ";
    } else {
        # $results->{Result} の中身を確認する
        # print Dumper($results->{Result});
        # 配列のリファレンスをデリファレンスする
        foreach my $result (@{$results->{Result}}) {
            printf("Keyword: %s. Score: %s ", encode('utf-8', $result->{Keyphrase}), $result->{Score});
	    print "\n";
        }
    }
}

