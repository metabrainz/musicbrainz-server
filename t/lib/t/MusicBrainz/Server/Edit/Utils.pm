package t::MusicBrainz::Server::Edit::Utils;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Edit::Utils qw( clean_submitted_artist_credits );

test 'clean_submitted_artist_credits, copy name to credit' => sub {

    my $ac = {
        names => [
            {
                artist => { name => "J Alvarez" },
                join_phrase => " feat. ",
            },
            {
                artist => { name => "Voltio" },
                name => "Julio Voltio",
            }]
    };

    my $expected = {
        names => [
            {
                artist => { name => "J Alvarez" },
                name => "J Alvarez",
                join_phrase => " feat. ",
            },
            {
                artist => { name => "Voltio" },
                name => "Julio Voltio",
                join_phrase => "",
            }]
    };

    is_deeply ( clean_submitted_artist_credits ($ac),
                $expected, "copied name to credits" );
};

test 'clean_submitted_artist_credits, trim and collapse all fields' => sub {

    my $ac = {
        names => [
            {
                artist => { name => "  J  Alvarez  " },
                join_phrase => "   feat.   ",
            },
            {
                artist => { name => "  Voltio  " },
                name => "   Julio   Voltio  ",
                join_phrase => "!!!11~   ",
            }]
    };

    my $expected = {
        names => [
            {
                artist => { name => "J Alvarez" },
                name => "J Alvarez",
                join_phrase => " feat. ",
            },
            {
                artist => { name => "Voltio" },
                name => "Julio Voltio",
                join_phrase => "!!!11~",
            }]
    };

    is_deeply ( clean_submitted_artist_credits ($ac),
                $expected, "trimmed and collapsed" );
};

1;
