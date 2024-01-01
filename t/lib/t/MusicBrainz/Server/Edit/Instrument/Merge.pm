package t::MusicBrainz::Server::Edit::Instrument::Merge;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Deep qw( cmp_deeply ignore );

with 't::Context';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_INSTRUMENT_MERGE :edit_status );
use MusicBrainz::Server::Test qw( accept_edit );

test 'MBS-8639' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+mbs-8639');

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_INSTRUMENT_MERGE,
        editor_id => 1,
        old_entities => [{ id => 588, name => 'other drums' }],
        new_entity => { id => 100, name => 'drums' },
    );

    accept_edit($c, $edit);
    is($edit->status, $STATUS_APPLIED);

    # Both instrument credits are kept, as separate relationships.
    my $relationships = $c->sql->select_list_of_hashes('SELECT * FROM l_artist_recording ORDER BY id');
    cmp_deeply($relationships, [
        {
            edits_pending => 0,
            entity0 => 1,
            entity0_credit => '',
            entity1 => 1,
            entity1_credit => '',
            id => 1,
            last_updated => ignore(),
            link => 5,
            link_order => 0,
        },
        {
            edits_pending => 0,
            entity0 => 2,
            entity0_credit => '',
            entity1 => 1,
            entity1_credit => '',
            id => 2,
            last_updated => ignore(),
            link => 7,
            link_order => 0,
        },
        {
            edits_pending => 0,
            entity0 => 3,
            entity0_credit => '',
            entity1 => 1,
            entity1_credit => '',
            id => 3,
            last_updated => ignore(),
            link => 3,
            link_order => 0,
        },
        {
            edits_pending => 0,
            entity0 => 1,
            entity0_credit => '',
            entity1 => 1,
            entity1_credit => '',
            id => 5,
            last_updated => ignore(),
            link => 6,
            link_order => 0,
        },
    ]);

    my $credits = $c->sql->select_list_of_hashes('SELECT * FROM link_attribute_credit ORDER BY link');
    cmp_deeply($credits, [
        {
            attribute_type => 125,
            credited_as => 'drumz',
            link => 5,
        },
        {
            attribute_type => 125,
            credited_as => 'crazy drums',
            link => 6,
        },
        {
            attribute_type => 125,
            credited_as => 'kool drums',
            link => 7,
        },
    ]);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
