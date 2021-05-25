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

    like($extract->content, qr{は、中田ヤスタカがプロデュースする広島県出身の3人組テクノポップユニット。}, "contains japanese text");

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

test 'Get ast page from en, fallback to en' => sub {
    my $test = shift;
    my $c = $test->c;

    LWP::UserAgent::Mockable->reset(
        playback => $Bin.'/lwp-sessions/data_wikipedia.ast-en-fallback.lwp-mock'
    );

    my $entity = Wikipedia->new(url => 'http://en.wikipedia.org/wiki/Perfume (Japanese band)');
    # No cache
    my $extract = $c->model('WikipediaExtract')->get_extract([$entity], 'ast', cache_only => 1);
    ok(!defined $extract);

    # Now let it use the network
    $extract = $c->model('WikipediaExtract')->get_extract([$entity], 'ast', cache_only => 0);
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

test 'Request ast page via wikidata, fallback to en' => sub {
    my $test = shift;
    my $c = $test->c;

    LWP::UserAgent::Mockable->reset(
        playback => $Bin.'/lwp-sessions/data_wikipedia.ast-en-fallback-wikidata.lwp-mock'
    );

    # german municipality of schladen-werla
    my $entity = Wikidata->new(url => 'https://www.wikidata.org/wiki/Q1462109');
    my $entity2 = Wikipedia->new(url => 'http://de.wikipedia.org/wiki/Schladen-Werla');
    # No cache
    my $extract = $c->model('WikipediaExtract')->get_extract([$entity, $entity2], 'ast', cache_only => 1);
    ok(!defined $extract);

    # Now let it use the network
    $extract = $c->model('WikipediaExtract')->get_extract([$entity, $entity2], 'ast', cache_only => 0);
    ok(defined $extract);

    like($extract->content, qr{is a municipality}, "contains English text");

    LWP::UserAgent::Mockable->finished;
};

test 'Request ja page via wikidata, fallback to it (according to browser accepted language)' => sub {
    my $test = shift;
    my $c = $test->c;

    # Assuming that browser accepted languages are set to Japanese (Japan) then Italian (Italy),
    # set all_system_languages as usually set by sub build_languages_from_header
    MusicBrainz::Server::Translation->instance->languages([
        'ja-jp',
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

test 'Request tr page via wikidata, fallback to it (according to editor known language)' => sub {
    my $test = shift;
    my $c = $test->c;

    # Assuming that browser accepted language is set to Finnish (Finland),
    # set all_system_languages as usually set by sub build_languages_from_header
    MusicBrainz::Server::Translation->instance->languages([
        'fi-fi',
        'fi',
        'i-default'
    ]);

    # Set editor known languages to native Finnish and basic Macedonian
    $c->sql->do(<<~'EOSQL');
        INSERT INTO area (id, gid, name, type)
            VALUES (221, '8a754a16-0027-3a29-b6d7-2b40ea0481ed', 'United Kingdom', 1);
        INSERT INTO iso_3166_1 (area, code) VALUES (221, 'GB');
        INSERT INTO editor (
            id, name, password, email,
            website, bio, member_since, email_confirm_date,
            last_login_date, privs, birth_date, area, gender, ha1
        )
            VALUES (
                1, 'Bob', '{CLEARTEXT}bob', 'bob@bob.bob',
                'http://bob.bob/', 'Bobography', now(), now(),
                now(), 1, now(), 221, 1, '026299da47965340ef66ca485a57975d');
        INSERT INTO language (id, iso_code_2t, iso_code_1, name)
            VALUES (131, 'fin', 'fi', 'Finnish'),
                   (254, 'mkd', 'mk', 'Macedonian');
        INSERT INTO editor_language (editor, language, fluency)
            VALUES (1, 131, 'native'), (1, 254, 'basic');
        EOSQL

    my $model = $c->model('Editor');
    my $bob = $model->get_by_id(1);
    $c->model('EditorLanguage')->load_for_editor($bob);

    LWP::UserAgent::Mockable->reset(
      playback => $Bin.'/lwp-sessions/data_wikipedia.fi-mk-fallback-browser.lwp-mock'
    );

    # german municipality of schladen-werla
    my $entity = Wikidata->new(url => 'https://www.wikidata.org/wiki/Q1462109');
    # No cache
    my $extract = $c->model('WikipediaExtract')->get_extract([$entity], 'fi', cache_only => 1, editor => $bob);
    ok(!defined $extract);

    # Now let it use the network
    $extract = $c->model('WikipediaExtract')->get_extract([$entity], 'fi', cache_only => 0, editor => $bob);
    ok(defined $extract);

    like($extract->content, qr{општина во округот}, "contains macedonian text");

    LWP::UserAgent::Mockable->finished;
};

test 'Request en page via wikidata, fallback to de (en is redirect)' => sub {
    my $test = shift;
    my $c = $test->c;

    LWP::UserAgent::Mockable->reset(
        playback => $Bin.'/lwp-sessions/data_wikipedia.en-de-fallback-redirect.lwp-mock'
    );

    # American actress Clarissa Burt
    my $entity = Wikidata->new(url => 'https://www.wikidata.org/wiki/Q514294');
    # No cache
    my $extract = $c->model('WikipediaExtract')->get_extract([$entity], 'en', cache_only => 1);
    ok(!defined $extract);

    # Now let it use the network
    $extract = $c->model('WikipediaExtract')->get_extract([$entity], 'en', cache_only => 0);
    ok(defined $extract);

    like($extract->content, qr{ist eine US-amerikanisch-italienische Schauspielerin}, "contains German text");

    LWP::UserAgent::Mockable->finished;
};

1;
