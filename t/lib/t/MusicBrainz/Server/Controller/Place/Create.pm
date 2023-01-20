package t::MusicBrainz::Server::Controller::Place::Create;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );
use utf8;

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether basic place creation works.

=cut

test 'Adding a new place' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+area');
    MusicBrainz::Server::Test->prepare_test_database($c, '+area_hierarchy');
    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'Alice', password => 'secret1' }
    );

    $mech->get_ok(
        '/place/create',
        'Fetched the place creation page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-place.name' => 'Somewhere',
                'edit-place.address' => 'Silly Road 1',
                'edit-place.coordinates' => '51.4795478N, 0.096023W',
                'edit-place.area_id' => 1178,
                'edit-place.type_id' => 1,
            },
        },
        'The form returned a 2xx response code')
    } $c;

    ok(
        $mech->uri =~ qr{/place/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})$},
        'The user is redirected to the place page after entering the edit',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Place::Create');

    is_deeply(
        $edit->data,
        {
            address => 'Silly Road 1',
            area_id => 1178,
            begin_date => {
                year => undef,
                month => undef,
                day => undef,
            },
            comment => '',
            coordinates => {
                latitude => '51.479548',
                longitude => '-0.096023',
            },
            end_date => {
                day => undef,
                month => undef,
                year => undef,
            },
            ended => 0,
            name => 'Somewhere',
            type_id => 1,
        },
        'The edit contains the right data',
    );

    # Test display of edit data
    $mech->get_ok('/edit/' . $edit->id, 'Fetched the edit page');
    html_ok($mech->content);
    $mech->text_contains(
        'Somewhere',
        'The edit page contains the place name',
    );
    $mech->text_contains(
        'Studio',
        'The edit page contains the place type',
    );
    $mech->text_contains(
        'Silly Road 1',
        'The edit page contains the place address',
    );
    $mech->text_contains(
        '51.479548°N, 0.096023°W',
        'The edit page contains the place coordinates',
    );
    $mech->text_contains(
        'London',
        'The edit page contains the place area',
    );
    $mech->text_contains(
        'England',
        'The edit page contains the containing subdivision',
    );
    $mech->text_contains(
        'United Kingdom',
        'The edit page contains the containing country',
    );
};

1;
