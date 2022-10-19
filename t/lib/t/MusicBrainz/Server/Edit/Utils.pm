package t::MusicBrainz::Server::Edit::Utils;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Edit::Utils qw(
    clean_submitted_artist_credits
    load_artist_credit_definitions
    artist_credit_from_loaded_definition
    artist_credit_preview
);

test 'clean_submitted_artist_credits, copy name to credit' => sub {

    my $ac = {
        names => [
            {
                artist => { name => 'J Alvarez' },
                join_phrase => ' feat. ',
            },
            {
                artist => { name => 'Voltio' },
                name => 'Julio Voltio',
            }]
    };

    my $expected = {
        names => [
            {
                artist => { name => 'J Alvarez' },
                name => 'J Alvarez',
                join_phrase => ' feat. ',
            },
            {
                artist => { name => 'Voltio' },
                name => 'Julio Voltio',
                join_phrase => '',
            }]
    };

    is_deeply( clean_submitted_artist_credits ($ac),
                $expected, 'copied name to credits' );
};

test 'clean_submitted_artist_credits, trim and collapse all fields' => sub {

    my $ac = {
        names => [
            {
                artist => { name => '  J  Alvarez  ' },
                join_phrase => '   feat.   ',
            },
            {
                artist => { name => '  Voltio  ' },
                name => '   Julio   Voltio  ',
                join_phrase => '!!!11~   ',
            }]
    };

    my $expected = {
        names => [
            {
                artist => { name => 'J Alvarez' },
                name => 'J Alvarez',
                join_phrase => ' feat. ',
            },
            {
                artist => { name => 'Voltio' },
                name => 'Julio Voltio',
                join_phrase => '!!!11~',
            }]
    };

    is_deeply( clean_submitted_artist_credits ($ac),
                $expected, 'trimmed and collapsed' );
};

test 'entering "0" as a credited name/join phrase' => sub {
    my $input = {
        names => [
            {
                artist => { name => 'Zero', id => 123 },
                name => '0',
                join_phrase => '0',
            },
        ]
    };

    is_deeply(clean_submitted_artist_credits($input), {
        names => [
            {
                artist => { name => 'Zero', id => 123 },
                name => '0',
                join_phrase => '0',
            },
        ]
    });

    my %loaded_ac_definitions = load_artist_credit_definitions($input);

    is_deeply(\%loaded_ac_definitions, { '123' => [] });

    my $ac = artist_credit_from_loaded_definition({ Artist => {} }, $input);
    my @names = $ac->all_names;

    is($names[0]->name, '0');
    is($names[0]->join_phrase, '0');

    $ac = artist_credit_preview({ Artist => {} }, $input);
    @names = $ac->all_names;

    is($names[0]->name, '0');
    is($names[0]->join_phrase, '0');
};

1;
