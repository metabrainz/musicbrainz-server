package t::MusicBrainz::Server::Controller::Series::Merge;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Edit';
with 't::Mechanize';
with 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+series');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'editor', password => 'pass' } );

    $mech->get_ok('/series/merge_queue?add-to-merge=1');
    $mech->get_ok('/series/merge_queue?add-to-merge=3');

    $mech->get_ok('/series/merge');
    $mech->submit_form(
        with_fields => {
            'merge.target' => 1,
            'merge.edit_note' => 'grrr',
        }
    );

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Series::Merge');

    is_deeply($edit->data, {
        old_entities => [ { name => 'Dumb Recording Series', id => '3' } ],
        new_entity => { name => 'Test Recording Series', id => '1' },
    });

    $mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
    html_ok($mech->content, '..valid xml');
    $mech->content_contains('Dumb Recording Series', '..contains old name');
    $mech->content_contains('/series/dbb23c50-d4e4-11e3-9c1a-0800200c9a66', '..contains old series link');
    $mech->content_contains('Test Recording Series', '..contains new name');
    $mech->content_contains('/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d', '..contains new series link');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
