package t::MusicBrainz::Server::Controller::Recording::Create;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits );

with 't::Mechanize', 't::Context';

test 'Adding a recording (including ISRC)' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $test->mech->get('/login');
    $test->mech->submit_form(
        with_fields => { username => 'new_editor', password => 'password' },
    );

    $mech->get_ok(
        '/recording/create',
        'Fetched the recording creation page',
    );

    my @edits = capture_edits {
        $mech->post_ok(
            $mech->uri,
            {
                'edit-recording.length' => '1:23',
                'edit-recording.comment' => 'Comment!',
                'edit-recording.name' => 'Name!',
                'edit-recording.artist_credit.names.0.name' => 'Test Artist',
                'edit-recording.artist_credit.names.0.artist.name' => 'Test Artist',
                'edit-recording.artist_credit.names.0.artist.id' => '3',
                'edit-recording.isrcs.0' => 'ZZ00Z0000001',
                'edit-recording.isrcs.1' => 'ZZ00Z0000002',
                'edit-recording.isrcs.1.removed' => '1',
                'edit-recording.edit_note' => 'source: trust me',
            },
            'The form returned a 2xx response code',
        );
    } $c;

    is(@edits, 2, 'Two edits were entered');

    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Recording::Create');

    is_deeply(
        $edits[0]->data,
        {
            artist_credit => {
                names => [
                    {
                        artist => { id => 3, name => 'Test Artist' },
                        name => 'Test Artist',
                        join_phrase => '',
                    },
                ],
            },
            name => 'Name!',
            comment => 'Comment!',
            length => 83000,
            video => 0,
        },
        'The create recording edit contains the right data',
    );

    isa_ok($edits[1], 'MusicBrainz::Server::Edit::Recording::AddISRCs');
    is_deeply(
        $edits[1]->data,
        {
            isrcs => [ {
                isrc => 'ZZ00Z0000001',
                recording => {
                    id => $edits[0]->recording_id,
                    name => 'Name!',
                },
                source => 0,
            } ],
            client_version => JSON::null,
        },
        'The add ISRC edit contains the right data',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
