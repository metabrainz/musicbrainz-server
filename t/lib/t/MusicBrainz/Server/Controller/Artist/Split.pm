package t::MusicBrainz::Server::Controller::Artist::Split;
use strict;
use warnings;

use Test::Routine;
use HTTP::Request::Common qw( POST );
use MusicBrainz::Server::Test qw( capture_edits );
use Test::More;

around run_test => sub {
    my ($orig, $test, @args) = @_;
    my $c = $test->c;
    my $mech = $test->mech;

    $c->sql->do(<<~'SQL');
        INSERT INTO editor (id, name, password, email, email_confirm_date, ha1)
            VALUES (1, 'new_editor', '{CLEARTEXT}password', 'example@example.com', '2005-10-20', 'e1dd8fee8ee728b0ddc8027d3a3db478');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (10, '9f0b3e1a-2431-400f-b6ff-2bcebbf0971a', 'Bob & David', 'Bob & David'),
                   (11, '1f0b3e1a-2431-400f-b6ff-2bcebbf0971a', 'Bob', 'Bob'),
                   (12, '2f0b3e1a-2431-400f-b6ff-2bcebbf0971a', 'David', 'David');
        SQL

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $test->$orig(@args);
};

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks the artist split function, and whether it removes
collaboration relationships as intended.

=cut

test 'Split artist remove all collaboration relationships for that artist' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<~'SQL');
        INSERT INTO link (id, link_type)
             VALUES (1, 102);
        INSERT INTO l_artist_artist (id, link, entity0, entity1)
             VALUES (1, 1, 11, 10);
        SQL

    my @edits = perform_split($test);

    is(@edits, 2, 'Two edits were created');

    my ($edit_ac, $del_rel) = @edits;

    isa_ok(
        $edit_ac,
        'MusicBrainz::Server::Edit::Artist::EditArtistCredit',
    );
    is($edit_ac->editor_id, 1, 'The edit AC edit was created by editor #1');

    isa_ok(
        $del_rel,
        'MusicBrainz::Server::Edit::Relationship::Delete',
    );
    is(
        $del_rel->editor_id,
        1,
        'The relationship removal edit was created by editor #1',
    );
};

test 'Splitting an artist creates the right edit' => sub {
    my $test = shift;

    my $c = $test->c;

    $c->sql->do(<<~'SQL');
        INSERT INTO artist_credit (id, name, artist_count, gid)
            VALUES (100, 'Bob & David', 1, '71fde822-f07c-38d8-a969-9973fe775fbb');
        INSERT INTO artist_credit_name (artist_credit, position, artist, name)
            VALUES (100, 0, 10, 'Bob & David');
        INSERT INTO recording (id, gid, name, artist_credit, length)
            VALUES (1, '123c079d-374e-4436-9448-da92dedef3cd', 'Bobbing and Daviding', 100, 123456);
        SQL

    my @edits = perform_split($test);

    is(@edits, 1, 'One edit was created');
    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Artist::EditArtistCredit');

    my ($edit) = @edits;
    is_deeply(
        $edit->data->{old}{artist_credit},
        {
            names => [{
                artist => {
                    name => 'Bob & David',
                    id => 10,
                },
                name => 'Bob & David',
                join_phrase => ''
            }]
        },
        'The edit contains the old artist credit',
    );

    is_deeply(
        $edit->data->{new}{artist_credit},
        {
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
        },
        'The edit contains the new artist credit',
    );
};

sub perform_split {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;
    capture_edits {
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
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
