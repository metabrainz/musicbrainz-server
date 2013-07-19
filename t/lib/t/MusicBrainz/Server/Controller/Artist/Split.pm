package t::MusicBrainz::Server::Controller::Artist::Split;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

use HTTP::Request::Common qw( POST );

test 'Test splitting an artist' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    $c->sql->do(<<'EOSQL');
INSERT INTO editor (id, name, password, email, email_confirm_date, ha1) VALUES (1, 'new_editor', '{CLEARTEXT}password', 'example@example.com', '2005-10-20', 'e1dd8fee8ee728b0ddc8027d3a3db478');
INSERT INTO editor (id, name, password, ha1)
  VALUES ( 4, 'ModBot', '', '' );
INSERT INTO artist_name (id, name) VALUES (1, 'Bob & David'), (2, 'Bob'), (3, 'David');
INSERT INTO artist (id, gid, name, sort_name) VALUES
    (10, '9f0b3e1a-2431-400f-b6ff-2bcebbf0971a', 1, 1),
    (11, '1f0b3e1a-2431-400f-b6ff-2bcebbf0971a', 2, 2),
    (12, '2f0b3e1a-2431-400f-b6ff-2bcebbf0971a', 3, 3);
EOSQL

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my @edits = capture_edits {
        $mech->get_ok('/artist/9f0b3e1a-2431-400f-b6ff-2bcebbf0971a/split');
        $mech->request(POST $mech->uri, [
            'split-artist.artist_credit.names.0.artist.name' => 'Bob',
            'split-artist.artist_credit.names.0.artist.id' => 11,
            'split-artist.artist_credit.names.0.name' => 'Bob',
            'split-artist.artist_credit.names.0.join_phrase' => '',
            'split-artist.artist_credit.names.1.artist.name' => 'David',
            'split-artist.artist_credit.names.1.artist.id' => 12,
            'split-artist.artist_credit.names.1.name' => 'David',
            'split-artist.artist_credit.names.1.join_phrase' => '',
        ]);
    } $c;

    is(@edits, 1, 'created 1 edit');
    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Artist::EditArtistCredit');

    my ($edit) = @edits;
    is_deeply($edit->data->{old}{artist_credit}, {
        names => [{
            artist => {
                name => 'Bob & David',
                id => 10,
            },
            name => 'Bob & David',
            join_phrase => ''
        }]
    });

    is_deeply($edit->data->{new}{artist_credit}, {
        names => [
            {
                artist => {
                    name => 'Bob',
                    id => 11,
                },
                name => 'Bob',
                join_phrase => ''
            },
            {
                artist => {
                    name => 'David',
                    id => 12,
                },
                name => 'David',
                join_phrase => ''
            },
        ]
    });
};

1;
