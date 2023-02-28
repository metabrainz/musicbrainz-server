package t::MusicBrainz::Server::Controller::Place::Edit;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( accept_edit capture_edits html_ok );
use utf8;

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether basic place editing works.

=cut

test 'Editing a place (remove coordinates)' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
        INSERT INTO place (id, gid, name, type, coordinates)
            VALUES (50, 'a24c9284-a9d2-428b-bacd-fa79cf9a9108',
                    'Sydney Opera House', 2, POINT(-33.858667,151.214028))
        SQL

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'new_editor', password => 'password' }
    );

    $mech->get_ok(
        '/place/a24c9284-a9d2-428b-bacd-fa79cf9a9108/edit',
        'Fetched the place editing page',
    );
    html_ok($mech->content);
    $mech->content_contains(
        '33.858667S, 151.214028E',
        'The edit page lists the coordinates',
    );

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-place.coordinates' => '',
            },
        },
        'The form returned a 2xx response code')
    } $c;

    ok(
        $mech->uri =~ qr{/place/a24c9284-a9d2-428b-bacd-fa79cf9a9108$},
        'The user is redirected to the place page after entering the edit',
    );

    $mech->text_contains(
        '33.858667°S, 151.214028°E',
        'The place page still contains the coordinates',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Place::Edit');

    is_deeply(
        $edit->data,
        {
            entity => {
                id => 50,
                gid => 'a24c9284-a9d2-428b-bacd-fa79cf9a9108',
                name => 'Sydney Opera House',
            },
            new => {
                coordinates => undef,
            },
            old => {
                coordinates => {
                    latitude => -33.858667,
                    longitude => 151.214028,
                },
            },
        },
        'The edit contains the right data',
    );

    accept_edit($c, $edit);

    $mech->get_ok(
        '/place/a24c9284-a9d2-428b-bacd-fa79cf9a9108/edit',
        'Fetched the place page again after accepting the edit',
    );
    html_ok($mech->content);
    $mech->text_lacks(
        '33.858667°S, 151.214028°E',
        'The place page no longer contains the coordinates',
    );
};

1;
