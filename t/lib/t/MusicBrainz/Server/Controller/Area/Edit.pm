package t::MusicBrainz::Server::Controller::Area::Edit;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether non-ended areas can be edited (which used to ISE, see
MBS-8661) and, by extension, whether basic area editing works. It also ensures
unprivileged users cannot edit areas.

=cut

test 'Editing a (non-ended) area' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+area_editing');

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'area_editor', password => 'pass' }
    );

    $mech->get_ok(
        '/area/29a709d8-0320-493e-8d0c-f2c386662b7f/edit',
        'Fetched the area editing page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => { 'edit-area.name' => 'wild onion' },
        },
        'The form returned a 2xx response code')
    } $c;

    ok(
        $mech->uri =~ qr{/area/29a709d8-0320-493e-8d0c-f2c386662b7f$},
        'The user is redirected to the area page after entering the edit',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Area::Edit');

    is_deeply(
        $edit->data,
        {
            entity => {
                gid => '29a709d8-0320-493e-8d0c-f2c386662b7f',
                id => 5099,
                name => 'Chicago',
            },
            new => { name => 'wild onion' },
            old => { name => 'Chicago' },
        },
        'The edit contains the right data',
    );

    # Test display of edit data
    $mech->get_ok('/edit/' . $edit->id, 'Fetched the edit page');
    html_ok($mech->content);
    $mech->text_contains(
        'Chicago',
        'The edit page contains the old area name',
    );
    $mech->text_contains(
        'wild onion',
        'The edit page contains the new area name',
    );
};

test 'Area editing is blocked for unprivileged users' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+area_editing');

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'boring_editor', password => 'pass' }
    );

    $mech->get('/area/29a709d8-0320-493e-8d0c-f2c386662b7f/edit');
    is(
        $mech->status,
        403,
        'Trying to edit an area without the right privileges gives a 403 Forbidden error',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
