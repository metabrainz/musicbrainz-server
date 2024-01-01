package t::MusicBrainz::Server::Controller::ReleaseGroup::Create;
use strict;
use warnings;

use HTTP::Request::Common qw( POST );
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether basic release group creation works.

=cut

test 'Adding a new release group' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'new_editor', password => 'password' },
    );

    $mech->get_ok(
        '/release-group/create',
        'Fetched the release group creation page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        my $req = POST $mech->uri, [
            'edit-release-group.name' => 'controller release group',
            'edit-release-group.primary_type_id' => 2,
            'edit-release-group.secondary_type_ids' => [ 1 ],
            'edit-release-group.comment' => 'release group created in controller_releasegroup.t',
            'edit-release-group.artist_credit.names.0.name' => 'Foo',
            'edit-release-group.artist_credit.names.0.artist.name' => 'Bar',
            'edit-release-group.artist_credit.names.0.artist.id' => '3',
        ];
        $mech->request($req);
        ok($mech->success, 'The form returned a 2xx response code');
    } $test->c;

    ok(
        $mech->uri =~ qr{/release-group/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})},
        'The user is redirected to the release group page after entering the edit',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Create');

    is_deeply(
        $edit->data,
        {
            name => 'controller release group',
            type_id => 2,
            secondary_type_ids => [ 1 ],
            comment => 'release group created in controller_releasegroup.t',
            artist_credit => {
                names => [ {
                    artist => { id => 3, name => 'Bar' },
                    name => 'Foo',
                    join_phrase => '',
                } ],
            },
        },
        'The edit contains the right data',
    );


    # Test display of edit data
    $mech->get_ok('/edit/' . $edit->id, 'Fetched the edit page');
    html_ok($mech->content);
    $mech->text_contains(
        'controller release group',
        'The edit page contains the release group name',
    );
    $mech->text_contains(
        'Single',
        'The edit page contains the release group primary type',
    );
    $mech->text_contains(
        'Compilation',
        'The edit page contains the release group secondary type',
    );
    $mech->text_contains(
        'release group created in controller_releasegroup.t',
        'The edit page contains the disambiguation',
    );
    $mech->text_contains('Foo', 'The edit page lists the artist');
    $mech->content_contains(
        '/artist/745c079d-374e-4436-9448-da92dedef3ce',
        'The edit page contains a link to the artist',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
