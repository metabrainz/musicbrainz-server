package t::MusicBrainz::Server::Data::WikipediaExtract;
use Test::Routine;
use Test::More;
use Test::Fatal;
use utf8;

use FindBin qw($Bin);
use LWP::UserAgent::Mockable;
use aliased 'MusicBrainz::Server::Entity::URL::Wikipedia';
use aliased 'MusicBrainz::Server::Entity::URL::Wikidata';

with 't::Context';

test 'Get ja page from en' => sub {
    my $test = shift;
    my $c = $test->c;

    LWP::UserAgent::Mockable->reset(
        playback => $Bin.'/lwp-sessions/data_wikipedia.ja-en.lwp-mock'
    );

    my $entity = Wikipedia->new(url => 'http://en.wikipedia.org/wiki/Perfume (Japanese band)');
    # No cache
    my $extract = $c->model('WikipediaExtract')->get_extract($entity, 'ja', cache_only => 1);
    ok(!defined $extract);

    # Now let it prime the cache
    $extract = $c->model('WikipediaExtract')->get_extract($entity, 'ja', cache_only => 0);
    ok(defined $extract);

    like($extract->content, qr{は、広島県出身の女性3人組テクノポップユニットである。}, "contains japanese text");

    LWP::UserAgent::Mockable->finished;
};

test 'Get en page from en' => sub {
    my $test = shift;
    my $c = $test->c;

    LWP::UserAgent::Mockable->reset(
        playback => $Bin.'/lwp-sessions/data_wikipedia.en-en.lwp-mock'
    );

    my $entity = Wikipedia->new(url => 'http://en.wikipedia.org/wiki/Perfume (Japanese band)');
    # No cache
    my $extract = $c->model('WikipediaExtract')->get_extract($entity, 'en', cache_only => 1);
    ok(!defined $extract);

    # Now let it use the network
    $extract = $c->model('WikipediaExtract')->get_extract($entity, 'en', cache_only => 0);
    ok(defined $extract);

    like($extract->content, qr{Japanese pop girl group}, "contains english text");

    LWP::UserAgent::Mockable->finished;
};

test 'Get nl page from en, fallback to en' => sub {
    my $test = shift;
    my $c = $test->c;

    LWP::UserAgent::Mockable->reset(
        playback => $Bin.'/lwp-sessions/data_wikipedia.nl-en-fallback.lwp-mock'
    );

    my $entity = Wikipedia->new(url => 'http://en.wikipedia.org/wiki/Perfume (Japanese band)');
    # No cache
    my $extract = $c->model('WikipediaExtract')->get_extract($entity, 'nl', cache_only => 1);
    ok(!defined $extract);

    # Now let it use the network
    $extract = $c->model('WikipediaExtract')->get_extract($entity, 'nl', cache_only => 0);
    ok(defined $extract);

    like($extract->content, qr{Japanese pop girl group}, "contains english text");

    LWP::UserAgent::Mockable->finished;
};

test 'Get en page from wikidata' => sub {
    my $test = shift;
    my $c = $test->c;

    LWP::UserAgent::Mockable->reset(
        playback => $Bin.'/lwp-sessions/data_wikipedia.en-wikidata.lwp-mock'
    );

    # Q494703 is the band Perfume, as with the other tests
    my $entity = Wikidata->new(url => 'http://www.wikidata.org/wiki/Q494703');
    # No cache
    my $extract = $c->model('WikipediaExtract')->get_extract($entity, 'en', cache_only => 1);
    ok(!defined $extract);

    # Now let it use the network
    $extract = $c->model('WikipediaExtract')->get_extract($entity, 'en', cache_only => 0);
    ok(defined $extract);

    like($extract->content, qr{Japanese pop girl group}, "contains english text");

    LWP::UserAgent::Mockable->finished;
};

1;
