package t::MusicBrainz::Server::Controller::Work::Create;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether basic work creation works, including adding ISWCs
during the creation process.

=cut

test 'Adding a new work, including ISWCs' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form(
        with_fields => { username => 'new_editor', password => 'password' }
    );

    $mech->get_ok(
        '/work/create',
        'Fetched the work creation page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->post_ok(
            '/work/create',
            {
                'edit-work.comment' => 'A comment!',
                'edit-work.type_id' => 26,
                'edit-work.name' => 'Enchanted',
                'edit-work.iswcs.0' => 'T-000.000.003-0',
                'edit-work.iswcs.1' => 'T-000.000.004-0',
                'edit-work.languages.0' => '120',
                'edit-work.languages.1' => '134',
            },
            'The form returned a 2xx response code'
        );
    } $c;

    ok(
        $mech->uri =~ qr{/work/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})$},
        'The user is redirected to the work page after entering the edit',
    );

    is(@edits, 2, 'Two edits were entered');

    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Work::Create');

    is_deeply(
        $edits[0]->data,
        {
            name          => 'Enchanted',
            comment       => 'A comment!',
            type_id       => 26,
            attributes    => [],
            languages     => [120, 134],
        },
        'The first edit contains the right data',
    );

    # Test display of edit data
    $mech->get_ok(
        '/edit/' . $edits[0]->id,
        'Fetched the Add work edit page',
    );
    html_ok($mech->content);
    $mech->text_contains(
        'Enchanted',
        'The edit page contains the work name',
    );
    $mech->text_contains(
        'Beijing opera',
        'The edit page contains the work type',
    );
    $mech->text_contains(
        'A comment!',
        'The edit page contains the disambiguation',
    );
    $mech->text_contains(
        'English, French',
        'The edit page contains the work languages',
    );

    isa_ok($edits[1], 'MusicBrainz::Server::Edit::Work::AddISWCs');

    is_deeply(
        $edits[1]->data,
        {
            iswcs => [
                {
                    iswc => 'T-000.000.003-0',
                    work => {
                        id => $edits[0]->entity_id,
                        name => 'Enchanted',
                    },
                },
                {
                    iswc => 'T-000.000.004-0',
                    work => {
                        id => $edits[0]->entity_id,
                        name => 'Enchanted',
                    },
                },
            ],
        },
        'The second edit contains the right data',
    );

    # Test display of edit data
    $mech->get_ok(
        '/edit/' . $edits[1]->id,
        'Fetched the Add ISWCs edit page',
    );
    html_ok($mech->content);
    $mech->text_contains(
        'T-000.000.003-0',
        'The edit page contains the first ISWC',
    );
    $mech->text_contains(
        'T-000.000.004-0',
        'The edit page contains the second ISWC',
    );
};

1;
