package t::MusicBrainz::Server::Validation;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Validation qw( is_valid_iswc format_iswc is_valid_ipi format_ipi );

test 'Test TrimInPlace' => sub {
    my $a = '  ';
    my $b = ' a ';
    my $c = ' a  b  ';
    my $d = ' a  b  c ';

    MusicBrainz::Server::Validation::TrimInPlace($a, $b, $c, $d);

    is( $a, '' );
    is( $b, 'a' );
    is( $c, 'a b' );
    is( $d, 'a b c' );
};

test 'Test is_valid_isrc' => sub {
    ok(MusicBrainz::Server::Validation::is_valid_isrc('USPR37300012'));
    ok(!MusicBrainz::Server::Validation::is_valid_isrc('12PR37300012'));
    ok(!MusicBrainz::Server::Validation::is_valid_isrc(''));
    ok(!MusicBrainz::Server::Validation::is_valid_isrc('123'));
};

test 'Test is_not_tunecore' => sub {
    ok(MusicBrainz::Server::Validation::is_not_tunecore('USPR37300012'), "Non-TuneCore ID passes 'is_not_tunecore'.");
    ok(!MusicBrainz::Server::Validation::is_not_tunecore('TCABF1283419'), "TuneCore ID does not pass 'is_not_tunecore'.");
};

test 'Test is_valid_discid' => sub {
    ok(MusicBrainz::Server::Validation::is_valid_discid('D5LsXhbWwpctL4s5xHSTS_SefQw-'));
    ok(!MusicBrainz::Server::Validation::is_valid_discid('aivDFb2Tw6HzN.XdYZFj5zr1Q9EY'));
    ok(!MusicBrainz::Server::Validation::is_valid_discid(''));
    ok(!MusicBrainz::Server::Validation::is_valid_discid('123'));
};

test 'Test is_valid_iswc' => sub {
    ok(is_valid_iswc('T-000.000.001-0'));
    ok(is_valid_iswc('T-000000001-0'));
    ok(is_valid_iswc('T-000000001.0'));
    ok(is_valid_iswc('T0000000010'));
    ok(!is_valid_iswc('T00010'));
    ok(!is_valid_iswc('T-000.000-0'));
    ok(is_valid_iswc('T- 101.914.232-4'));
};

test 'Test format_iswc' => sub {
    is(format_iswc('T-000.000.001-0'), 'T-000.000.001-0');
    is(format_iswc('T-000000001-0'), 'T-000.000.001-0');
    is(format_iswc('T-000000001.0'), 'T-000.000.001-0');
    is(format_iswc('T0000000010'), 'T-000.000.001-0');
    is(format_iswc('T- 101.914.232-4'), 'T-101.914.232-4');
};

test 'Test is_valid_ipi' => sub {
    ok(is_valid_ipi('00014107338'));
};

test 'Test format_ipi' => sub {
    is(format_ipi('014107338'), '00014107338');
};

test 'Test normalise_strings' => sub {
    my ($alice, $bob) = MusicBrainz::Server::Validation::normalise_strings ('alice', 'bob');
    is ($alice, 'alice');
    is ($bob, 'bob');
};

1;
