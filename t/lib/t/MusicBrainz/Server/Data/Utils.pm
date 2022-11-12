package t::MusicBrainz::Server::Data::Utils;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Utils qw( order_by generate_gid take_while sanitize trim );
use MusicBrainz::Server::Entity::PartialDate;
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
  'SELECT * FROM artist_type WHERE id IN (1, 2) ORDER BY id'
);
is( scalar(@result), 2 );
is( $result[0]->id, 1 );
is( $result[1]->id, 2 );

my $offset = 0;
my ($result, $hits) = $model->query_to_list_limited(
    'SELECT * FROM artist_type WHERE id IN (1, 2) ORDER BY id', [], 1, $offset
);
@result = @{$result};
is( scalar(@result), 1, 'got one result');
is( $hits, 2, 'got two total' );
is( $result[0]->id, 1, 'got result with id 1 as the first' );

$offset = 1;
my ($result2, $hits2) = $model->query_to_list_limited(
    'SELECT * FROM artist_type WHERE id IN (1, 2) ORDER BY id', [], 1, $offset
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
    $run->("The Upper Hand of Christmas C\x{200B}*\x{200B}*\x{200B}* EP",
           'The Upper Hand of Christmas C*** EP',
           'removes zero-width space');

    $run->("Soft\x{00AD}Hyphen",
           'SoftHyphen',
           'removes soft hyphens');

    $run->("NAK follows\x15",
           'NAK follows',
           'removes control characters (NAK)');

    $run->("   Gutta \t cauat\nlapidem ",
           'Gutta cauat lapidem',
           'normalizes whitespace, removes leading/trailing whitespace',
           ' Gutta cauat lapidem ',
           'normalizes whitespace, keeps leading/trailing whitespace');

    $run->("NAK follows after space \x15",
           'NAK follows after space',
           'removes words of invalid characters (MBS-7604)',
           'NAK follows after space ');

    $run->("\x{30A2}\x{30B7}\x{30BF}\x{30AB}\x{26ED9}\x{8A18}",
           "\x{30A2}\x{30B7}\x{30BF}\x{30AB}\x{26ED9}\x{8A18}",
           'does not touch characters outside the BMP');

    $run->("Le\x{323}\x{302} Quye\x{302}n; Le\x{302}\x{323} Quy\x{EA}n; L\x{EA}\x{323} Q.; L\x{1EC7} Q.",
           "L\x{1EC7} Quy\x{EA}n; L\x{1EC7} Quy\x{EA}n; L\x{1EC7} Q.; L\x{1EC7} Q.",
           'normalizes to NFC (MBS-6010)');

    $run->("Brilliant Classics \x{200E}",
           'Brilliant Classics',
           'removes LRM from the end of strings containing only LTR characters',
           'Brilliant Classics ');

    $run->("Brilliant Classics.\x{200F}",
           'Brilliant Classics.',
           'removes RLM from the end of strings containing only LTR characters, even next to a weak character');

    $run->("\x{200F}\x{5DE}\x{5E8}\x{5D8}\x{5D9}\x{5DF} \x{5D1}\x{5D5}\x{5D1}\x{5E8}\x{200E}",
           "\x{5DE}\x{5E8}\x{5D8}\x{5D9}\x{5DF} \x{5D1}\x{5D5}\x{5D1}\x{5E8}",
           'removes LRM/RLM from the ends of strings containing Hebrew characters');

    $run->("\x{5DE}\x{5E8}\x{5D8}\x{5D9}\x{5DF} \x{5D1}\x{5D5}\x{5D1}\x{5E8}\x{200E}\x{200F}",
           "\x{5DE}\x{5E8}\x{5D8}\x{5D9}\x{5DF} \x{5D1}\x{5D5}\x{5D1}\x{5E8}",
           'removes groups of LRM/RLM');

    $run->("\x{5DE}\x{5E8}\x{5D8}\x{5D9}\x{5DF} \x{5D1}\x{5D5}\x{5D1}\x{5E8}!\x{200E}",
           "\x{5DE}\x{5E8}\x{5D8}\x{5D9}\x{5DF} \x{5D1}\x{5D5}\x{5D1}\x{5E8}!\x{200E}",
           'does not remove LRM from the end of a string RTL characters, if next to a neutral character');

    $run->("Francisco T\x{E1}rrega\x{200E} - Lagrima",
           "Francisco T\x{E1}rrega - Lagrima",
           'removes LRM from the interior of strings without RTL characters');

    $run->("Francisco\x{200F} T\x{E1}rrega\x{200F}\x{200E} - Lagrima",
           "Francisco T\x{E1}rrega - Lagrima",
           'removes multiple LRM/RLM from strings without RTL characters');

    $run->("\x{5D0}\x{5D5}\x{5BC}\x{5DE}\x{200F}\x{5D9} 2",
           "\x{5D0}\x{5D5}\x{5BC}\x{5DE}\x{5D9} 2",
           'removes LRM/RLM from the interior of strings if between strong characters');

    $run->("Dakhma (\x{62F}\x{62E}\x{645}\x{647}\x{200E})",
           "Dakhma (\x{62F}\x{62E}\x{645}\x{647}\x{200E})",
           'retains LRM between strong and neutral character in strings with RTL characters');

    $run->("A\x{200F}\x{62F}\x{200E}B\x{200E}\x{5D1}\x{200F}C",
           "A\x{62F}B\x{5D1}C",
           'removes LRM/RLM from between strong characters of different directionality');

    $run->("A  \x{FDD0}B",
           'A B',
           'collapses spaces before a non-printable character');

    $run->("A \x{FDD0} B",
           'A B',
           'collapses spaces surrounding a non-printable character');

    $run->("A\x{FDD0}  B",
           'A B',
           'collapses spaces after a non-printable character');

    $run->("\x{FEFF} A \x{FEFF} B \x{FEFF}",
           'A B',
           'strips BOM, removes leading/trailing whitespace',
           ' A B ',
           'strips BOM, keeps leading/trailing whitespace');
};

1;
