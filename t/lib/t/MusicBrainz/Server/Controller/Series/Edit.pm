package t::MusicBrainz::Server::Controller::Series::Edit;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Deep qw( cmp_deeply ignore re );
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Edit';
with 't::Mechanize';
with 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+series');

    $mech->get_ok('/login');
    $mech->submit_form(with_fields => { username => 'editor', password => 'pass' });

    $mech->get_ok('/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/edit');
    html_ok($mech->content);

    $mech->submit_form(
        with_fields => {
            'edit-series.name' => 'New Name!',
            'edit-series.comment' => 'new comment!',
            'edit-series.ordering_type_id' => 2,
        }
    );

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Series::Edit');

    cmp_deeply($edit->data, {
        entity => {
            id => 1,
            gid => re('[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'),
            name => 'Test Recording Series'
        },
        new => {
            name => 'New Name!',
            comment => 'new comment!',
            ordering_type_id => 2,

        },
        old => {
            name => 'Test Recording Series',
            comment => 'test comment 1',
            ordering_type_id => 1,
        }
    });

    $edit->accept;
    $mech->get_ok('/edit/' . $edit->id, 'Fetch the edit page');
    html_ok($mech->content, '..valid xml');
    $mech->text_contains('New Name!', '..has new name');
    $mech->text_contains('Test Recording Series', '..has old name');
    $mech->text_contains('Automatic', '..has old ordering type');
    $mech->text_contains('Manual', '..has new ordering type');

    my @edits = capture_edits {
        $mech->post('/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/edit', {
            'edit-series.name' => 'New Name!',
            'edit-series.comment' => 'new comment!',
            'edit-series.type_id' => 3,
            'edit-series.ordering_type_id' => 2,
            'edit-series.rel.0.relationship_id' => 1,
            'edit-series.rel.0.link_type_id' => 740,
            'edit-series.rel.0.attributes.0.type.gid' => 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a',
            'edit-series.rel.0.attributes.0.text_value' => 'B1',
            'edit-series.rel.1.relationship_id' => 2,
            'edit-series.rel.1.link_type_id' => 740,
            'edit-series.rel.1.attributes.0.type.gid' => 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a',
            'edit-series.rel.1.attributes.0.text_value' => 'B11',
            'edit-series.rel.1.link_order' => '3',
        });
    } $c;

    $edit = $edits[0];
    isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Edit');

    my $number_attribute = {
        type => {
            id => 788,
            gid => 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a',
            name => 'number',
            root => {
                id => 788,
                gid => 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a',
                name => 'number',
            }
        }
    };

    cmp_deeply($edit->data->{old}, {
        attributes => [{ %$number_attribute, text_value => 'A1' }]
    });

    cmp_deeply($edit->data->{new}, {
        attributes => [{ %$number_attribute, text_value => 'B1' }]
    });

    $edit = $edits[1];
    isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Edit');

    cmp_deeply($edit->data->{old}, {
        attributes => [{ %$number_attribute, text_value => 'A11' }]
    });

    cmp_deeply($edit->data->{new}, {
        attributes => [{ %$number_attribute, text_value => 'B11' }]
    });

    $edit = $edits[2];

    cmp_deeply($edit->data->{relationship_order}, [
        {
            relationship => ignore(),
            old_order => 2,
            new_order => 3,
        }
    ]);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
