package t::MusicBrainz::Server::Form::Utils;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Form::Utils qw( expand_param );

test all => sub {

    my $values = {
        'artist_credit.names.0.name' => 'Meth',
        'artist_credit.names.2.name' => 'Rae',
        'artist_credit.names.1.join_phrase' => ' & ',
        'artist_credit.names.1.artist.name' => 'Ghostface Killah',
        'date.day' => '30',
        'name' => 'Wu-Massacre',
        'date.month' => '3',
        'artist_credit.names.1.artist.id' => '121932',
        'release_group.name' => 'Wu-Massacre',
        'artist_credit.names.0.artist.id' => '172',
        'date.year' => '2010',
        'artist_credit.names.1.name' => 'Ghost',
        'artist_credit.names.2.artist.id' => '33616',
        'artist_credit.names.2.artist.name' => 'Raekwon',
        'artist_credit.names.0.join_phrase' => ', ',
        'artist_credit.names.2.join_phrase' => '',
        'artist_credit.names.0.artist.name' => 'Method Man'
    };

    my $date = { year => '2010', month => '3', day => '30' };
    my $artist_credit = {
        names => [
            {
                artist => {
                    name => 'Method Man',
                    id => 172,
                },
                join_phrase => ', ',
                name => 'Meth',
            },
            {
                artist => {
                    name => 'Ghostface Killah',
                    id => 121932,
                },
                join_phrase => ' & ',
                name => 'Ghost',
            },
            {
                artist => {
                    name => 'Raekwon',
                    id => 33616,
                },
                join_phrase => undef,
                name => 'Rae',
            }
            ]
    };

    is( expand_param ($values, 'name'), 'Wu-Massacre' );
    is_deeply( expand_param ($values, 'date'), $date );
    is_deeply( expand_param ($values, 'artist_credit'), $artist_credit );

};

1;
