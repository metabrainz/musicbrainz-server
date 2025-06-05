package t::MusicBrainz::Server::Data::Utils;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Fatal;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Utils qw(
    order_by
    find_best_primary_alias
    generate_gid
    take_while
    sanitize
    trim
    ref_to_type
    model_to_type
);
use MusicBrainz::Server::Entity::Alias;
use MusicBrainz::Server::Entity::AreaAliasType;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Recording;
use MusicBrainz::Server::Entity::URL::45cat;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;

my $date = MusicBrainz::Server::Entity::PartialDate->new_from_row(
    { a_year => 2008, a_month => 1, a_day => 2 }, 'a_');

is( $date->year, 2008 );
is( $date->month, 1 );
is( $date->day, 2 );

my $model = $test->c->model('ArtistType');
my @result = $model->query_to_list(
  'SELECT * FROM artist_type WHERE id IN (1, 2) ORDER BY id',
);
is( scalar(@result), 2 );
is( $result[0]->id, 1 );
is( $result[1]->id, 2 );

my $offset = 0;
my ($result, $hits) = $model->query_to_list_limited(
    'SELECT * FROM artist_type WHERE id IN (1, 2) ORDER BY id', [], 1, $offset,
);
@result = @{$result};
is( scalar(@result), 1, 'got one result');
is( $hits, 2, 'got two total' );
is( $result[0]->id, 1, 'got result with id 1 as the first' );

$offset = 1;
my ($result2, $hits2) = $model->query_to_list_limited(
    'SELECT * FROM artist_type WHERE id IN (1, 2) ORDER BY id', [], 1, $offset,
);
@result = @{$result2};
is( scalar(@result), 1, 'got one result (with offset)' );
is( $hits2, 2, 'got two total (with offset)' );
is( $result[0]->id, 2, 'got result with id 2 as the first (with offset)' );

my $order_by;

$order_by = order_by(
    undef, '1', { '1' => 'a, b', '2' => 'c, b' });
is( $order_by, 'a, b' );

$order_by = order_by(
    '1', '1', { '1' => 'a, b', '2' => 'c, b' });
is( $order_by, 'a, b' );

$order_by = order_by(
    '3', '1', { '1' => 'a, b', '2' => 'c, b' });
is( $order_by, 'a, b' );

$order_by = order_by(
    '2', '1', { '1' => 'a, b', '2' => 'c, b' });
is( $order_by, 'c, b' );

$order_by = order_by(
    '-1', '1', { '1' => 'a, b', '2' => 'c, b' });
is( $order_by, 'a DESC, b DESC' );

$order_by = order_by(
    '-2', '1', { '1' => 'a, b', '2' => 'c, b' });
is( $order_by, 'c DESC, b DESC' );

$order_by = order_by(
    '-3', '1', { '1' => 'a, b', '2' => 'c, b' });
is( $order_by, 'a, b' );

my $gid = generate_gid();
is($gid, lc($gid), 'GID is returned as lower-case');

};

test 'Test take_while' => sub {
    is_deeply([ take_while { defined($_) } (1, 2, 3) ],
              [ 1, 2, 3 ]);

    is_deeply([ take_while { defined($_) } (1, 2, undef, 3) ],
              [ 1, 2 ]);

    is_deeply([ take_while { defined($_) } (undef, 3) ],
              []);
};

test 'Test trim and sanitize' => sub {
    my $run = sub {
        my ($input, $res_trim, $descr_trim, $res_sanitize, $descr_sanitize) = @_;
        $res_sanitize //= $res_trim;
        $descr_sanitize //= $descr_trim;

        is(trim($input), $res_trim, 'trim ' . $descr_trim);
        is(sanitize($input), $res_sanitize, 'sanitize ' . $descr_sanitize);
    };

    # MBS-4606
    $run->("The Upper Hand of Christmas C\N{ZERO WIDTH SPACE}*\N{ZERO WIDTH SPACE}*\N{ZERO WIDTH SPACE}* EP",
           'The Upper Hand of Christmas C*** EP',
           'removes zero-width space');

    $run->("Soft\N{SOFT HYPHEN}Hyphen",
           'SoftHyphen',
           'removes soft hyphens');

    $run->("NAK follows\N{NEGATIVE ACKNOWLEDGE}",
           'NAK follows',
           'removes control characters (NAK)');

    $run->("   Gutta \t cauat\nlapidem ",
           'Gutta cauat lapidem',
           'normalizes whitespace, removes leading/trailing whitespace',
           ' Gutta cauat lapidem ',
           'normalizes whitespace, keeps leading/trailing whitespace');

    $run->("NAK follows after space \N{NEGATIVE ACKNOWLEDGE}",
           'NAK follows after space',
           'removes words of invalid characters (MBS-7604)',
           'NAK follows after space ');

    $run->("\N{KATAKANA LETTER A}\N{KATAKANA LETTER SI}\N{KATAKANA LETTER TA}\N{KATAKANA LETTER KA}\x{26ED9}\x{8A18}", ## no critic (ProhibitEscapedCharacters) - unassigned/unnamed characters
           "\N{KATAKANA LETTER A}\N{KATAKANA LETTER SI}\N{KATAKANA LETTER TA}\N{KATAKANA LETTER KA}\x{26ED9}\x{8A18}", ## no critic (ProhibitEscapedCharacters) - unassigned/unnamed characters
           'does not touch characters outside the BMP');

    $run->("Le\N{COMBINING DOT BELOW}\N{COMBINING CIRCUMFLEX ACCENT} Quye\N{COMBINING CIRCUMFLEX ACCENT}n; Le\N{COMBINING CIRCUMFLEX ACCENT}\N{COMBINING DOT BELOW} Quy\N{LATIN SMALL LETTER E WITH CIRCUMFLEX}n; L\N{LATIN SMALL LETTER E WITH CIRCUMFLEX}\N{COMBINING DOT BELOW} Q.; L\N{LATIN SMALL LETTER E WITH CIRCUMFLEX AND DOT BELOW} Q.",
           "L\N{LATIN SMALL LETTER E WITH CIRCUMFLEX AND DOT BELOW} Quy\N{LATIN SMALL LETTER E WITH CIRCUMFLEX}n; L\N{LATIN SMALL LETTER E WITH CIRCUMFLEX AND DOT BELOW} Quy\N{LATIN SMALL LETTER E WITH CIRCUMFLEX}n; L\N{LATIN SMALL LETTER E WITH CIRCUMFLEX AND DOT BELOW} Q.; L\N{LATIN SMALL LETTER E WITH CIRCUMFLEX AND DOT BELOW} Q.",
           'normalizes to NFC (MBS-6010)');

    $run->("Brilliant Classics \N{LEFT-TO-RIGHT MARK}",
           'Brilliant Classics',
           'removes LRM from the end of strings containing only LTR characters',
           'Brilliant Classics ');

    $run->("Brilliant Classics.\N{RIGHT-TO-LEFT MARK}",
           'Brilliant Classics.',
           'removes RLM from the end of strings containing only LTR characters, even next to a weak character');

    $run->("\N{RIGHT-TO-LEFT MARK}\N{HEBREW LETTER MEM}\N{HEBREW LETTER RESH}\N{HEBREW LETTER TET}\N{HEBREW LETTER YOD}\N{HEBREW LETTER FINAL NUN} \N{HEBREW LETTER BET}\N{HEBREW LETTER VAV}\N{HEBREW LETTER BET}\N{HEBREW LETTER RESH}\N{LEFT-TO-RIGHT MARK}",
           "\N{HEBREW LETTER MEM}\N{HEBREW LETTER RESH}\N{HEBREW LETTER TET}\N{HEBREW LETTER YOD}\N{HEBREW LETTER FINAL NUN} \N{HEBREW LETTER BET}\N{HEBREW LETTER VAV}\N{HEBREW LETTER BET}\N{HEBREW LETTER RESH}",
           'removes LRM/RLM from the ends of strings containing Hebrew characters');

    $run->("\N{HEBREW LETTER MEM}\N{HEBREW LETTER RESH}\N{HEBREW LETTER TET}\N{HEBREW LETTER YOD}\N{HEBREW LETTER FINAL NUN} \N{HEBREW LETTER BET}\N{HEBREW LETTER VAV}\N{HEBREW LETTER BET}\N{HEBREW LETTER RESH}\N{LEFT-TO-RIGHT MARK}\N{RIGHT-TO-LEFT MARK}",
           "\N{HEBREW LETTER MEM}\N{HEBREW LETTER RESH}\N{HEBREW LETTER TET}\N{HEBREW LETTER YOD}\N{HEBREW LETTER FINAL NUN} \N{HEBREW LETTER BET}\N{HEBREW LETTER VAV}\N{HEBREW LETTER BET}\N{HEBREW LETTER RESH}",
           'removes groups of LRM/RLM');

    $run->("\N{HEBREW LETTER MEM}\N{HEBREW LETTER RESH}\N{HEBREW LETTER TET}\N{HEBREW LETTER YOD}\N{HEBREW LETTER FINAL NUN} \N{HEBREW LETTER BET}\N{HEBREW LETTER VAV}\N{HEBREW LETTER BET}\N{HEBREW LETTER RESH}!\N{LEFT-TO-RIGHT MARK}",
           "\N{HEBREW LETTER MEM}\N{HEBREW LETTER RESH}\N{HEBREW LETTER TET}\N{HEBREW LETTER YOD}\N{HEBREW LETTER FINAL NUN} \N{HEBREW LETTER BET}\N{HEBREW LETTER VAV}\N{HEBREW LETTER BET}\N{HEBREW LETTER RESH}!\N{LEFT-TO-RIGHT MARK}",
           'does not remove LRM from the end of a string RTL characters, if next to a neutral character');

    $run->("Francisco T\N{LATIN SMALL LETTER A WITH ACUTE}rrega\N{LEFT-TO-RIGHT MARK} - Lagrima",
           "Francisco T\N{LATIN SMALL LETTER A WITH ACUTE}rrega - Lagrima",
           'removes LRM from the interior of strings without RTL characters');

    $run->("Francisco\N{RIGHT-TO-LEFT MARK} T\N{LATIN SMALL LETTER A WITH ACUTE}rrega\N{RIGHT-TO-LEFT MARK}\N{LEFT-TO-RIGHT MARK} - Lagrima",
           "Francisco T\N{LATIN SMALL LETTER A WITH ACUTE}rrega - Lagrima",
           'removes multiple LRM/RLM from strings without RTL characters');

    $run->("\N{HEBREW LETTER ALEF}\N{HEBREW LETTER VAV}\N{HEBREW POINT DAGESH OR MAPIQ}\N{HEBREW LETTER MEM}\N{RIGHT-TO-LEFT MARK}\N{HEBREW LETTER YOD} 2",
           "\N{HEBREW LETTER ALEF}\N{HEBREW LETTER VAV}\N{HEBREW POINT DAGESH OR MAPIQ}\N{HEBREW LETTER MEM}\N{HEBREW LETTER YOD} 2",
           'removes LRM/RLM from the interior of strings if between strong characters');

    $run->("Dakhma (\N{ARABIC LETTER DAL}\N{ARABIC LETTER KHAH}\N{ARABIC LETTER MEEM}\N{ARABIC LETTER HEH}\N{LEFT-TO-RIGHT MARK})",
           "Dakhma (\N{ARABIC LETTER DAL}\N{ARABIC LETTER KHAH}\N{ARABIC LETTER MEEM}\N{ARABIC LETTER HEH}\N{LEFT-TO-RIGHT MARK})",
           'retains LRM between strong and neutral character in strings with RTL characters');

    $run->("A\N{RIGHT-TO-LEFT MARK}\N{ARABIC LETTER DAL}\N{LEFT-TO-RIGHT MARK}B\N{LEFT-TO-RIGHT MARK}\N{HEBREW LETTER BET}\N{RIGHT-TO-LEFT MARK}C",
           "A\N{ARABIC LETTER DAL}B\N{HEBREW LETTER BET}C",
           'removes LRM/RLM from between strong characters of different directionality');

    $run->("A  \x{FDD0}B", ## no critic (ProhibitEscapedCharacters) - unassigned character
           'A B',
           'collapses spaces before a non-printable character');

    $run->("A \x{FDD0} B", ## no critic (ProhibitEscapedCharacters) - unassigned character
           'A B',
           'collapses spaces surrounding a non-printable character');

    $run->("A\x{FDD0}  B", ## no critic (ProhibitEscapedCharacters) - unassigned character
           'A B',
           'collapses spaces after a non-printable character');

    $run->("\N{ZERO WIDTH NO-BREAK SPACE} A \N{ZERO WIDTH NO-BREAK SPACE} B \N{ZERO WIDTH NO-BREAK SPACE}",
           'A B',
           'strips BOM, removes leading/trailing whitespace',
           ' A B ',
           'strips BOM, keeps leading/trailing whitespace');
};

test 'Test ref_to_type' => sub {
    like exception {
        ref_to_type(undef);
    }, qr/ref_to_type can only be called on references/,
        'ref_to_type of undef throws an exception';

    like exception {
        ref_to_type('');
    }, qr/ref_to_type can only be called on references/,
        'ref_to_type of "" throws an exception';

    my $area_alias_type = MusicBrainz::Server::Entity::AreaAliasType->new;
    my $recording = MusicBrainz::Server::Entity::Recording->new;
    my $url = MusicBrainz::Server::Entity::URL::45cat->new;

    is(ref_to_type($area_alias_type), 'area_alias_type',
       'ref_to_type of Entity::AreaAliasType is "area_alias_type"');

    is(ref_to_type($recording), 'recording',
       'ref_to_type of Entity::Recording is "recording"');

    is(ref_to_type($url), 'url',
       'ref_to_type of Entity::URL::45cat is "url"');
};

test 'Test model_to_type' => sub {
    is(model_to_type(undef), undef, 'model_to_type of undef is undef');

    is(model_to_type(''), undef, 'model_to_type of "" is undef');

    is(model_to_type('AreaAliasType'), 'area_alias_type',
       'model_to_type of "AreaAliasType" is "area_alias_type"');

    is(model_to_type('Recording'), 'recording',
       'model_to_type of "Recording" is "recording"');

    is(model_to_type('URL'), 'url',
       'model_to_type of "URL" is "url"');
};


test 'Test find_best_primary_alias' => sub {
    my @aliases = (
        MusicBrainz::Server::Entity::Alias->new(
            name => 'Alias McAliasy',
            sort_name => 'McAliasy, Alias',
            locale => 'en_US',
            primary_for_locale => 1,
        ),
        MusicBrainz::Server::Entity::Alias->new(
            name => 'Alias von Alias',
            sort_name => 'Alias, Alias von',
            locale => 'de',
            primary_for_locale => 1,
        ),
        MusicBrainz::Server::Entity::Alias->new(
            name => 'Alias von der Schweiz',
            sort_name => 'Schweiz, Alias von der',
            locale => 'de_CH',
            primary_for_locale => 1,
        ),
        MusicBrainz::Server::Entity::Alias->new(
            name => 'Alias van der Alias',
            sort_name => 'van der Alias, Alias',
            locale => 'nl',
            primary_for_locale => 0,
        ),
        MusicBrainz::Server::Entity::Alias->new(
            name => 'Alias de Alias y Alias',
            sort_name => 'Alias y Alias, Alias de',
            locale => 'es',
            ended => 1,
            primary_for_locale => 1,
        ),
    );

    is(
       find_best_primary_alias(\@aliases, 'de')->name,
       'Alias von Alias',
       'Asking for "de" alias, "de" match is returned',
    );

    is(
       find_best_primary_alias(\@aliases, 'de_CH')->name,
       'Alias von der Schweiz',
       'Asking for "de_CH" alias, "de_CH" match is returned',
    );

    is(
       find_best_primary_alias(\@aliases, 'de_AT')->name,
       'Alias von Alias',
       'Asking for "de_AT" alias, "de" fallback is returned since we lack "de_AT"',
    );

    is(
       find_best_primary_alias(\@aliases, 'en')->name,
       'Alias McAliasy',
       'Asking for "en" alias, "en" match is returned',
    );

    is(
       find_best_primary_alias(\@aliases, 'nl')->name,
       'Alias McAliasy',
       'Asking for "nl" alias, "en" fallback is returned since "nl" is not primary',
    );

    is(
       find_best_primary_alias(\@aliases, 'es')->name,
       'Alias McAliasy',
       'Asking for "es" alias, "en" fallback is returned since "es" is ended',
    );

    is(
       find_best_primary_alias(\@aliases, 'es_AR')->name,
       'Alias McAliasy',
       'Asking for "es_AR" alias, "en" fallback is returned since "es" fallback is ended',
    );

    is(
       find_best_primary_alias(\@aliases, 'it')->name,
       'Alias McAliasy',
       'Asking for "it" alias, "en" fallback is returned since we lack "it"',
    );

    is(
       find_best_primary_alias([], 'en'),
       undef,
       'Nothing is returned if no aliases exist',
    );
};

1;
