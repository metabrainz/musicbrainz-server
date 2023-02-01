package t::MusicBrainz::Server::Controller::Recording::Edit;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Edit', 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether basic recording editing works, including replacing
ISRCs. It also checks if it still works if you don't indicate
the artist credit.

=cut

test 'Editing a recording (inc. replacing ISRC)' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    prepare_test($test);

    $mech->get_ok(
        '/recording/54b9d183-7dab-42ba-94a3-7388a66604b8/edit',
        'Fetched the recording editing page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->post_ok(
            $mech->uri,
            {
                'edit-recording.length' => '1:23',
                'edit-recording.comment' => 'A comment!',
                'edit-recording.name' => 'Another name',
                'edit-recording.artist_credit.names.0.name' => 'Foo',
                'edit-recording.artist_credit.names.0.artist.name' => 'Bar',
                'edit-recording.artist_credit.names.0.artist.id' => '3',
                'edit-recording.artist_credit.names.1.name' => '',
                'edit-recording.artist_credit.names.1.artist.name' => 'Queen',
                'edit-recording.artist_credit.names.1.artist.id' => '4',
                'edit-recording.artist_credit.names.2.name' => '',
                'edit-recording.artist_credit.names.2.artist.name' => 'David Bowie',
                'edit-recording.artist_credit.names.2.artist.id' => '5',
                'edit-recording.isrcs.0' => 'USS1Z9900001',
            },
            'The form returned a 2xx response code'
        );
    } $c;

    ok(
        $mech->uri =~ qr{/recording/54b9d183-7dab-42ba-94a3-7388a66604b8$},
        'The user is redirected to the recording page after entering the edit',
    );

    is(@edits, 3, 'Three edits were entered');

    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Recording::Edit');

    is_deeply(
        $edits[0]->data,
        {
            entity => {
                id => 1,
                gid => '54b9d183-7dab-42ba-94a3-7388a66604b8',
                name => 'Dancing Queen',
            },
            new => {
                artist_credit => {
                    names => [
                        {
                            artist => { id => 3, name => 'Bar' },
                            name => 'Foo',
                            join_phrase => '',
                        },
                        {
                            artist => { id => 4, name => 'Queen' },
                            name => 'Queen',
                            join_phrase => '',
                        },
                        {
                            artist => { id => 5, name => 'David Bowie' },
                            name => 'David Bowie',
                            join_phrase => '',
                        }
                    ],
                },
                name => 'Another name',
                comment => 'A comment!',
                length => 83000,
            },
            old => {
                artist_credit => {
                    names => [
                        {
                            artist => { id => 6, name => 'ABBA' },
                            name => 'ABBA',
                            join_phrase => '',
                        }
                    ],
                },
                name => 'Dancing Queen',
                comment => '',
                length => 123456,
            },
        },
        'The edit recording edit contains the right data',
    );

    # Test display of edit data
    $mech->get_ok(
        '/edit/' . $edits[0]->id,
        'Fetched the edit recording edit page',
    );
    html_ok($mech->content);
    $mech->text_contains(
        'Dancing Queen',
        'The edit page contains the old recording name',
    );
    $mech->text_contains(
        'Another name',
        'The edit page contains the new recording name',
    );
    $mech->text_contains(
        '2:03',
        'The edit page contains the old recording length',
    );
    $mech->text_contains(
        '1:23',
        'The edit page contains the new recording length',
    );
    $mech->text_contains(
        'A comment!',
        'The edit page contains the new disambiguation',
    );
    $mech->text_contains('Foo', 'The edit page lists the first new artist');
    $mech->content_contains(
        '/artist/745c079d-374e-4436-9448-da92dedef3ce',
        'The edit page contains a link to the first new artist',
    );
    $mech->text_contains(
        'Queen',
        'The edit page lists the second new artist',
    );
    $mech->content_contains(
        '/artist/945c079d-374e-4436-9448-da92dedef3cf',
        'The edit page contains a link to the second new artist',
    );
    $mech->text_contains(
        'David Bowie',
        'The edit page lists the third new artist',
    );
    $mech->content_contains(
        '/artist/5441c29d-3602-4898-b1a1-b77fa23b8e50',
        'The edit page contains a link to the third new artist',
    );
    $mech->text_contains('ABBA', 'The edit page lists the old artist');
    $mech->content_contains(
        '/artist/a45c079d-374e-4436-9448-da92dedef3cf',
        'The edit page contains a link to the old artist',
    );

    isa_ok($edits[1], 'MusicBrainz::Server::Edit::Recording::AddISRCs');
    is_deeply(
        $edits[1]->data,
        {
            isrcs => [ {
                isrc => 'USS1Z9900001',
                recording => {
                    id => 1,
                    name => 'Dancing Queen'
                },
                source => 0,
            } ],
            client_version => JSON::null
        },
        'The add ISRC edit contains the right data',
    );

    isa_ok($edits[2], 'MusicBrainz::Server::Edit::Recording::RemoveISRC');
    my @isrc = $c->model('ISRC')->find_by_isrc('DEE250800231');

    is_deeply(
        $edits[2]->data,
        {
            isrc => {
                id => $isrc[0]->id,
                isrc => 'DEE250800231',
            },
            recording => {
                id => 1,
                name => 'Dancing Queen',
            },
        },
        'The remove ISRC edit contains the right data',
    );
};

test 'Editing a recording without submitting the artist credit field' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    prepare_test($test);

    $mech->get_ok(
        '/recording/54b9d183-7dab-42ba-94a3-7388a66604b8/edit',
        'Fetched the recording editing page',
    );

    my @edits = capture_edits {
        $mech->post_ok(
            $mech->uri,
            {
                'edit-recording.length' => '4:56',
                'edit-recording.name' => 'Dancing Queen',
                'edit-recording.isrcs.0' => 'DEE250800231',
            },
            'The form returned a 2xx response code'
        );
    } $c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::Edit');

    is_deeply(
        $edit->data,
        {
            entity => {
                id => 1,
                gid => '54b9d183-7dab-42ba-94a3-7388a66604b8',
                name => 'Dancing Queen',
            },
            new => { length => 296000 },
            old => { length => 123456 },
        },
        'The edit contains the right data',
    );
};

sub prepare_test {
    my $test = shift;

    $test->c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name, comment)
             VALUES (3, '745c079d-374e-4436-9448-da92dedef3ce', 'ABBA', 'ABBA', 'A'),
                    (6, 'a45c079d-374e-4436-9448-da92dedef3cf', 'ABBA', 'ABBA', 'B'),
                    (4, '945c079d-374e-4436-9448-da92dedef3cf', 'ABBA', 'ABBA', 'C'),
                    (5, '5441c29d-3602-4898-b1a1-b77fa23b8e50', 'ABBA', 'ABBA', 'D');

        INSERT INTO artist_credit (id, name, artist_count, gid)
            VALUES (1, 'ABBA', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');

        INSERT INTO artist_credit_name (artist_credit, position, artist, name)
             VALUES (1, 0, 6, 'ABBA');

        INSERT INTO recording (id, gid, name, artist_credit, length)
             VALUES (1, '54b9d183-7dab-42ba-94a3-7388a66604b8', 'Dancing Queen', 1, 123456);

        INSERT INTO isrc (isrc, recording)
             VALUES ('DEE250800231', 1);
        SQL

    $test->mech->get('/login');
    $test->mech->submit_form(
        with_fields => { username => 'editor', password => 'pass' }
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
