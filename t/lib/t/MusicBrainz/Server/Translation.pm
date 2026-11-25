package t::MusicBrainz::Server::Translation;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use HTTP::Headers;
use List::AllUtils qw( any );
use POSIX qw( setlocale LC_MESSAGES );

use DBDefs;
use MusicBrainz::Server::Translation;

{
    package t::MusicBrainz::Server::Translation::Cookie;
    sub new { my ($class, $value) = @_; bless { value => $value }, $class }
    sub value { shift->{value} }
}

# True if the compiled catalog of this language is installed. This does not
# depend on gettext, so a broken lookup fails the tests instead of skipping
# them.
sub catalog_installed {
    my $lang = shift;
    return any { -f "$_/LocaleData/$lang/LC_MESSAGES/mb_server.mo" } @INC;
}

sub with_mb_languages {
    my ($code, @languages) = @_;
    no warnings 'redefine';
    local *DBDefs::MB_LANGUAGES = sub { @languages };
    local *DBDefs::LANGUAGE_FALLBACK_TO_BROWSER = sub { 1 };
    $code->();
}

test 'Language codes with a script subtag' => sub {
    is(MusicBrainz::Server::Translation::posix_locale('zh-hant'), 'zh_Hant');
    is(MusicBrainz::Server::Translation::posix_locale('zh-HANT-tw'), 'zh_Hant_TW');
    is(MusicBrainz::Server::Translation::posix_locale('fr-ca'), 'fr_CA');
    is(MusicBrainz::Server::Translation::posix_locale('es-419'), 'es_419');
    is(MusicBrainz::Server::Translation::bcp47_tag('zh_Hant'), 'zh-Hant');
    is(MusicBrainz::Server::Translation::bcp47_tag('fr_CA'), 'fr-CA');
    is(MusicBrainz::Server::Translation::bcp47_tag('en'), 'en');
};

test 'language_from_cookie with a script subtag' => sub {
    my $translation = MusicBrainz::Server::Translation->instance;
    my $cookie = sub {
        $translation->language_from_cookie(
            t::MusicBrainz::Server::Translation::Cookie->new(shift),
        );
    };
    with_mb_languages(sub {
        is($cookie->('zh-Hant'), 'zh-Hant', 'Exact match');
        is($cookie->('zh-Hant-TW'), 'zh-Hant', 'Match without the country');
        is($cookie->('fr-CA'), 'fr-CA', 'Country match');
        is($cookie->('fr-BE'), 'fr', 'Match without the country');
        is($cookie->('de'), undef, 'No match');
        is($translation->language_from_cookie(undef), undef, 'No cookie');

        my @warnings;
        local $SIG{__WARN__} = sub { push @warnings, @_ };
        is($cookie->(''), undef, 'Empty cookie');
        is_deeply(\@warnings, [], 'An empty cookie gives no warning');
    }, qw( en fr fr-ca zh-hant ));
};

test 'all_languages with a script subtag' => sub {
    with_mb_languages(sub {
        my %languages = map { $_->[0] => $_->[1] }
            @{ MusicBrainz::Server::Translation->instance->all_languages };
        is_deeply([sort keys %languages],
                  [qw( en es-419 fr-CA zh-Hans zh-Hant )],
                  'Codes are in the BCP 47 form');
        is($languages{'zh-Hant'}->native_language, '中文',
           'zh-Hant has a native name');
        is($languages{'zh-Hans'}->native_script, '简体',
           'zh-Hans has a native script name');
    }, qw( en es-419 fr-ca zh-hans zh-hant ));
};

test 'set_language with zh-Hans' => sub {
    my $prev_locale = setlocale(LC_MESSAGES);
    plan skip_all => 'The zh_CN.UTF-8 system locale is not installed'
        unless defined setlocale(LC_MESSAGES, 'zh_CN.UTF-8');
    setlocale(LC_MESSAGES, $prev_locale);

    my $translation = MusicBrainz::Server::Translation->instance;
    with_mb_languages(sub {
        is($translation->set_language('zh-Hans'), 'zh_Hans',
           'Selected with the cookie');
        is($ENV{LANGUAGE}, 'zh_Hans', 'gettext reads the zh_Hans catalogs');
        SKIP: {
            skip 'The zh catalog is not installed', 1
                unless catalog_installed('zh');
            is(MusicBrainz::Server::Translation::l('Search'), '搜索',
               'Without zh_Hans catalogs, gettext reads the zh catalog');
        }
    }, qw( en zh-hans ));
    $translation->unset_language;
};

test 'set_language with a script subtag' => sub {
    my $prev_locale = setlocale(LC_MESSAGES);
    plan skip_all => 'The zh_TW.UTF-8 system locale is not installed'
        unless defined setlocale(LC_MESSAGES, 'zh_TW.UTF-8');
    setlocale(LC_MESSAGES, $prev_locale);

    my $translation = MusicBrainz::Server::Translation->instance;
    with_mb_languages(sub {
        is($translation->set_language('zh-Hant'), 'zh_Hant',
           'Selected with the cookie');
        is($ENV{LANGUAGE}, 'zh_Hant', 'gettext reads the zh_Hant catalogs');
        like(setlocale(LC_MESSAGES), qr/^zh_TW/, 'The system locale is zh_TW');

        $translation->languages([qw( zh-hant zh en i-default )]);
        is($translation->set_language(undef), 'zh_Hant',
           'Selected with Accept-Language');

        $translation->build_languages_from_header(HTTP::Headers->new(
            'Accept-Language' => 'zh-Hant-TW,zh;q=0.8,en;q=0.5',
        ));
        is($translation->set_language(undef), 'zh_Hant',
           'Selected with a real Accept-Language header');

        $translation->languages([qw( zh-hant-tw zh-hant zh en i-default )]);
        is($translation->set_language(undef), 'zh_Hant',
           'Accept-Language zh-Hant-TW selects zh_Hant');

        $translation->set_language('zh-Hant');
        $translation->run_without_translations(sub {
            is($ENV{LANGUAGE}, '', 'LANGUAGE is clear without translations');
            is(MusicBrainz::Server::Translation::l('Search'), 'Search',
               'The text is English without translations');
        });
        is($ENV{LANGUAGE}, 'zh_Hant', 'LANGUAGE is restored after the code');
        SKIP: {
            skip 'The zh_Hant catalog is not installed', 1
                unless catalog_installed('zh_Hant');
            is(MusicBrainz::Server::Translation::l('Search'), '搜尋',
               'The text is Traditional Chinese after the code');
        }

        $translation->set_language('en');
        is($ENV{LANGUAGE}, '', 'LANGUAGE is clear for other languages');
    }, qw( en zh-hant ));

    # zh_TW reads the zh catalog, and zh_Hant reads the zh_Hant catalog, but
    # both use the zh_TW system locale.
    SKIP: {
        skip 'The zh and zh_Hant catalogs are not installed', 2
            unless catalog_installed('zh') && catalog_installed('zh_Hant');
        with_mb_languages(sub {
            $translation->set_language('zh-TW');
            is(MusicBrainz::Server::Translation::l('Search'), '搜索',
               'zh_TW uses the zh catalog');
            $translation->set_language('zh-Hant');
            is(MusicBrainz::Server::Translation::l('Search'), '搜尋',
               'zh_Hant after zh_TW uses the zh_Hant catalog');
        }, qw( en zh-tw zh-hant ));
    }

    $translation->languages([]);
    $translation->unset_language;
};

test 'Check _expand_link' => sub {
    is(MusicBrainz::Server::Translation->instance->expand('An {apple_fruit}',
                                                  apple_fruit => 'apple'),
        'An apple', 'Simple replacement');
    is(MusicBrainz::Server::Translation->instance->expand('An {apple_fruit|Apple}',
                                                  apple_fruit => 'http://www.apple.com'),
        'An <a href="http://www.apple.com">Apple</a>', 'Replacement with links');
    is(MusicBrainz::Server::Translation->instance->expand('A {apple_fruit|apple}',
                                                  apple_fruit => 'http://www.apple.com', apple => 'pear'),
        'A <a href="http://www.apple.com">pear</a>', 'Replacement with link description evaluation');
    is(MusicBrainz::Server::Translation->instance->expand('A {apple_fruit|apple}',
                                                  apple_fruit => {href => 'http://www.apple.com', target => '_blank'}, apple => 'pear'),
        'A <a href="http://www.apple.com" target="_blank">pear</a>', 'Replacement with link description evaluation and hash argument');
    is(MusicBrainz::Server::Translation->instance->expand('A {apple_fruit|{condition} apple …}',
                                                  apple_fruit => {href => 'http://www.apple.com', target => '_blank'}, condition => 'bad'),
        'A <a href="http://www.apple.com" target="_blank">bad apple …</a>', 'Replacement with link description evaluation and nested hash argument');
};

1;
