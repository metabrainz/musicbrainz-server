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
    my $extract = $c->model('WikipediaExtract')->get_extract([$entity], 'ja', cache_only => 1);
    ok(!defined $extract);

    # Now let it prime the cache
    $extract = $c->model('WikipediaExtract')->get_extract([$entity], 'ja', cache_only => 0);
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
    my $extract = $c->model('WikipediaExtract')->get_extract([$entity], 'en', cache_only => 1);
    ok(!defined $extract);

    # Now let it use the network
    $extract = $c->model('WikipediaExtract')->get_extract([$entity], 'en', cache_only => 0);
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
    my $extract = $c->model('WikipediaExtract')->get_extract([$entity], 'nl', cache_only => 1);
    ok(!defined $extract);

    # Now let it use the network
    $extract = $c->model('WikipediaExtract')->get_extract([$entity], 'nl', cache_only => 0);
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
    my $extract = $c->model('WikipediaExtract')->get_extract([$entity], 'en', cache_only => 1);
    ok(!defined $extract);

    # Now let it use the network
    $extract = $c->model('WikipediaExtract')->get_extract([$entity], 'en', cache_only => 0);
    ok(defined $extract);

    like($extract->content, qr{Japanese pop girl group}, "contains english text");

    LWP::UserAgent::Mockable->finished;
};

test 'Request eo page via wikidata, fallback to de' => sub {
    my $test = shift;
    my $c = $test->c;

    LWP::UserAgent::Mockable->reset(
        playback => $Bin.'/lwp-sessions/data_wikipedia.eo-de-fallback-wikidata.lwp-mock'
    );

    # german municipality of schladen-werla
    my $entity = Wikidata->new(url => 'https://www.wikidata.org/wiki/Q1462109');
    my $entity2 = Wikipedia->new(url => 'http://de.wikipedia.org/wiki/Schladen-Werla');
    # No cache
    my $extract = $c->model('WikipediaExtract')->get_extract([$entity, $entity2], 'eo', cache_only => 1);
    ok(!defined $extract);

    # Now let it use the network
    $extract = $c->model('WikipediaExtract')->get_extract([$entity, $entity2], 'eo', cache_only => 0);
    ok(defined $extract);

    like($extract->content, qr{ist eine Einheitsgemeinde}, "contains german text");

    LWP::UserAgent::Mockable->finished;
};

test 'Request ja page via wikidata, fallback to it (according to browser accepted language)' => sub {
    my $test = shift;
    my $c = $test->c;

    # Assuming that browser accepted languages are set to Japanese (Japan) then Italian (Italy),
    # set all_system_languages as usually set by sub build_languages_from_header
    MusicBrainz::Server::Translation->instance->languages([
        'ja-ja',
        'ja',
        'it-it',
        'it',
        'i-default'
    ]);

    LWP::UserAgent::Mockable->reset(
      playback => $Bin.'/lwp-sessions/data_wikipedia.ja-it-fallback-browser.lwp-mock'
    );

    # german municipality of schladen-werla
    my $entity = Wikidata->new(url => 'https://www.wikidata.org/wiki/Q1462109');
    # No cache
    my $extract = $c->model('WikipediaExtract')->get_extract([$entity], 'ja', cache_only => 1);
    ok(!defined $extract);

    # Now let it use the network
    $extract = $c->model('WikipediaExtract')->get_extract([$entity], 'ja', cache_only => 0);
    ok(defined $extract);

    like($extract->content, qr{è un comune tedesco}, "contains italian text");

    LWP::UserAgent::Mockable->finished;
};

1;
