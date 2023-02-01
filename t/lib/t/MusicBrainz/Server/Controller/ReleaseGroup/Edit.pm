package t::MusicBrainz::Server::Controller::ReleaseGroup::Edit;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether basic release group editing works.

=cut

test 'Editing a release group' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'new_editor', password => 'password' }
    );

    $mech->get_ok(
        '/release-group/234c079d-374e-4436-9448-da92dedef3ce/edit',
        'Fetched the release group editing page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->post_ok(
            $mech->uri,
            {
                'edit-release-group.comment' => 'A comment!',
                'edit-release-group.primary_type_id' => 2,
                'edit-release-group.name' => 'Another name',
                'edit-release-group.artist_credit.names.0.name' => 'Foo',
                'edit-release-group.artist_credit.names.0.artist.name' => 'Bar',
                'edit-release-group.artist_credit.names.0.artist.id' => '3',
            },
            'The form returned a 2xx response code'
        );
    } $c;

    ok(
        $mech->uri =~ qr{/release-group/234c079d-374e-4436-9448-da92dedef3ce$},
        'The user is redirected to the release group page after entering the edit',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Edit');

    is_deeply(
        $edit->data,
        {
            entity => {
                id => 1,
                gid => '234c079d-374e-4436-9448-da92dedef3ce',
                name => 'Arrival',
            },
            new => {
                artist_credit => {
                    names => [ {
                        artist => { id => 3, name => 'Bar' },
                        name => 'Foo',
                        join_phrase => '',
                    } ],
                },
                name => 'Another name',
                comment => 'A comment!',
                type_id => 2,
            },
            old => {
                artist_credit => {
                    names => [ {
                        artist => { id => 6, name => 'ABBA' },
                        name => 'ABBA',
                        join_phrase => '',
                    } ],
                },
                name => 'Arrival',
                comment => '',
                type_id => 1,
            },
        },
        'The edit contains the right data',
    );

    # Test display of edit data
    $mech->get_ok('/edit/' . $edit->id, 'Fetched the edit page');
    html_ok($mech->content);
    $mech->text_contains(
        'Arrival',
        'The edit page contains the old release group name',
    );
    $mech->text_contains(
        'Another name',
        'The edit page contains the new release group name',
    );
    $mech->text_contains(
        'Album',
        'The edit page contains the old release group type',
    );
    $mech->text_contains(
        'Single',
        'The edit page contains the new release group type',
    );
    $mech->text_contains(
        'A comment!',
        'The edit page contains the new disambiguation',
    );
    $mech->text_contains('Foo', 'The edit page lists the new artist');
    $mech->content_contains(
        '/artist/745c079d-374e-4436-9448-da92dedef3ce',
        'The edit page contains a link to the new artist',
    );
    $mech->text_contains('ABBA', 'The edit page lists the old artist');
    $mech->content_contains(
        '/artist/a45c079d-374e-4436-9448-da92dedef3cf',
        'The edit page contains a link to the old artist',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
