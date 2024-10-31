package t::MusicBrainz::Server::Controller::Area::Create;
use strict;
use warnings;

use HTTP::Status qw( :constants );
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether non-ended areas can be added (which used to ISE, see
MBS-8661) and, by extension, whether basic area adding works. It also ensures
unprivileged users cannot create areas.

=cut

test 'Adding a new (non-ended) area' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+area_editing');

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'area_editor', password => 'pass' },
    );

    $mech->get_ok(
        '/area/create',
        'Fetched the area creation page',
    );

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => { 'edit-area.name' => 'New Area' },
        },
        'The form returned a 2xx response code')
    } $c;

    ok(
        $mech->uri =~ qr{/area/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})},
        'The user is redirected to the area page after entering the edit',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Area::Create');

    is_deeply(
        $edit->data,
        {
            begin_date => {
                year => undef,
                month => undef,
                day => undef,
            },
            comment => '',
            end_date => {
                day => undef,
                month => undef,
                year => undef,
            },
            ended => 0,
            iso_3166_1 => [],
            iso_3166_2 => [],
            iso_3166_3 => [],
            name => 'New Area',
            type_id => undef,
        },
        'The edit contains the right data',
    );

    # Test display of edit data
    $mech->get_ok('/edit/' . $edit->id, 'Fetched the edit page');
    html_ok($mech->content);
    $mech->text_contains(
        'New Area',
        'The edit page contains the area name',
    );
};

test 'Area creation is blocked for unprivileged users' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+area_editing');

    $mech->get_ok('/login');
    $mech->submit_form(with_fields => { username => 'boring_editor', password => 'pass' });
    $mech->get('/area/create');
    is(
        $mech->status,
        HTTP_FORBIDDEN,
        'Trying to add an area without the right privileges gives a 403 Forbidden error',
    );
};

1;
