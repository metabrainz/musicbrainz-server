package t::MusicBrainz::Server::Controller::Artist::Edit;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether basic artist editing works, including when also
updating artist credits.

=cut

test 'Editing an artist' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database(
        $c,
        '+controller_artist',
    );

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'new_editor', password => 'password' }
    );

    $mech->get_ok(
        '/artist/745c079d-374e-4436-9448-da92dedef3ce/edit',
        'Fetched the artist editing page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-artist.name' => 'edit artist',
                'edit-artist.sort_name' => 'artist, controller',
                'edit-artist.type_id' => '',
                'edit-artist.area_id' => 222,
                'edit-artist.gender_id' => 2,
                'edit-artist.period.begin_date.year' => 1990,
                'edit-artist.period.begin_date.month' => 1,
                'edit-artist.period.begin_date.day' => 2,
                'edit-artist.begin_area_id' => 222,
                'edit-artist.period.end_date.year' => '',
                'edit-artist.period.end_date.month' => '',
                'edit-artist.period.end_date.day' => '',
                'edit-artist.end_area_id' => 222,
                'edit-artist.comment' => 'artist created in controller_artist.t',
                'edit-artist.rename_artist_credit' => undef
            }
        },
        'The form returned a 2xx response code');
    } $c;

    ok(
        $mech->uri =~ qr{/artist/745c079d-374e-4436-9448-da92dedef3ce$},
        'The user is redirected to the artist page after entering the edit',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Edit');
    is_deeply(
        $edit->data,
        {
            entity => {
                id => 3,
                gid => '745c079d-374e-4436-9448-da92dedef3ce',
                name => 'Test Artist',
            },
            new => {
                name => 'edit artist',
                sort_name => 'artist, controller',
                type_id => undef,
                area_id => 222,
                gender_id => 2,
                comment => 'artist created in controller_artist.t',
                begin_date => {
                    year => 1990,
                    month => 1,
                    day => 2,
                },
                begin_area_id => 222,
                end_date => {
                    year => undef,
                    month => undef,
                    day => undef,
                },
                end_area_id => 222,
            },
            old => {
                name => 'Test Artist',
                sort_name => 'Artist, Test',
                type_id => 1,
                gender_id => 1,
                area_id => 221,
                comment => 'Yet Another Test Artist',
                begin_date => {
                    year => 2008,
                    month => 1,
                    day => 2,
                },
                begin_area_id => 221,
                end_date => {
                    year => 2009,
                    month => 3,
                    day => 4,
                },
                end_area_id => 221,
            }
        },
        'The edit contains the right data',
    );

    # Test display of edit data
    $mech->get_ok('/edit/' . $edit->id, 'Fetched the edit page');
    html_ok($mech->content);
    $mech->text_contains(
        'edit artist',
        'The edit page contains the old artist name',
    );
    $mech->text_contains(
        'Test Artist',
        'The edit page contains the new artist name',
    );
    $mech->text_contains(
        'artist, controller',
        'The edit page contains the old sort name',
    );
    $mech->text_contains(
        'Artist, Test',
        'The edit page contains the new sort name',
    );
    $mech->text_contains(
        'Person',
        'The edit page contains the new artist type',
    );
    $mech->text_contains(
        'United States',
        'The edit page contains the old area',
    );
    $mech->text_contains(
        'United Kingdom',
        'The edit page contains the new area',
    );
    $mech->text_contains(
        'Male',
        'The edit page contains the old artist gender',
    );
    $mech->text_contains(
        'Female',
        'The edit page contains the new artist gender',
    );
    $mech->text_contains(
        '2008-01-02',
        'The edit page contains the old begin date',
    );
    $mech->text_contains(
        '1990-01-02',
        'The edit page contains the new begin date',
    );
    $mech->text_contains(
        '2009-03-04',
        'The edit page contains the old end date',
    );
    $mech->text_contains(
        'Yet Another Test Artist',
        'The edit page contains the old disambiguation',
    );
    $mech->text_contains(
        'artist created in controller_artist.t',
        'The edit page contains the new disambiguation',
    );
};

test 'Too long disambiguation is rejected without ISE' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'new_editor', password => 'password' }
    );

    $mech->get_ok(
        '/artist/745c079d-374e-4436-9448-da92dedef3ce/edit',
        'Fetched the artist editing page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-artist.name' => 'test artist',
                'edit-artist.comment' => 'comment ' x 100,
                'edit-artist.sort_name' => 'artist, test',
                'edit-artist.rename_artist_credit' => undef
            }
        },
        'The form returned a 2xx response code');
    } $c;

    ok(
        $mech->uri =~ qr{/artist/745c079d-374e-4436-9448-da92dedef3ce/edit$},
        'The edit artist page is shown again',
    );

    is(@edits, 0, 'No edit was entered');

    $mech->text_contains(
        'Field should not exceed 255 characters',
        'The "too long disambiguation" error is shown',
    );
};

test 'Updating artist credits' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    $c->sql->do(<<~'SQL');
        INSERT INTO editor (id, name, password, email, email_confirm_date, ha1)
            VALUES (1, 'new_editor', '{CLEARTEXT}password', 'example@example.com', '2005-10-20', 'e1dd8fee8ee728b0ddc8027d3a3db478');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (10, '9f0b3e1a-2431-400f-b6ff-2bcebbf0971a', 'Artist name', 'Artist name');

        INSERT INTO artist_credit (id, artist_count, name, gid)
            VALUES (1, 1, 'Alternative Name', '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');
        INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
            VALUES (1, 10, 'Alternative Name', 1, '');
        SQL

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'new_editor', password => 'password' }
    );

    $mech->get_ok(
        '/artist/9f0b3e1a-2431-400f-b6ff-2bcebbf0971a/edit',
        'Fetched the artist editing page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-artist.name' => 'test artist',
                'edit-artist.rename_artist_credit' => [ 1 ]
            },
        },
        'The form returned a 2xx response code');
    } $c;

    is(@edits, 2, 'Two edits were entered');
    my ($edit_artist, $edit_ac) = @edits;
    isa_ok(
        $edit_artist,
        'MusicBrainz::Server::Edit::Artist::Edit',
        'Created an artist edit',
    );
    isa_ok(
        $edit_ac,
        'MusicBrainz::Server::Edit::Artist::EditArtistCredit',
        'Edited an artist credit',
    );

    is_deeply(
        $edit_ac->data->{new}{artist_credit},
        {
            names => [{
                artist => {
                    name => 'Artist name',
                    id => 10,
                },
                name => 'test artist',
                join_phrase => ''
            }]
        },
        'The new artist credit contains the right data',
    );

    is_deeply(
        $edit_ac->data->{old}{artist_credit},
        {
            names => [{
                artist => {
                    name => 'Artist name',
                    id => 10,
                },
                name => 'Alternative Name',
                join_phrase => ''
            }]
        },
        'The old artist credit contains the right data',
    );
};

1;
