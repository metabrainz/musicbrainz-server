package t::MusicBrainz::Server::Edit::Release::EditBarcodes;
use strict;
use warnings;

use Test::Deep qw( cmp_set );
use Test::Routine;
use Test::More;

with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Release::EditBarcodes }

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_EDIT_BARCODES );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');

    my $edit = _create_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Release::EditBarcodes');

    my ($edits) = $c->model('Edit')->find({ release => [1, 2] }, 10, 0);
    is(@$edits, 1);
    is($edits->[0]->id, $edit->id);

    cmp_set(
        [ map +{
            barcode => $_->{barcode},
            old_barcode => $_->{old_barcode}
        }, @{ $edit->data->{submissions} } ],
        [
            { barcode => '5099703257021', old_barcode => '731453398122' },
            { barcode => '5199703257021', old_barcode => undef }
        ]
    );

    cmp_set($edit->related_entities->{artist},
            [ 1 ],
            'is related to the release artists');

    cmp_set($edit->related_entities->{release},
            [ 1, 2 ],
            'is related to the releases');

    cmp_set($edit->related_entities->{release_group},
            [ 1 ],
            'is related to the release groups');

    my $r1 = $c->model('Release')->get_by_id(1);
    my $r2 = $c->model('Release')->get_by_id(2);
    is($r1->edits_pending, 3);
    is($r1->barcode->format, '731453398122');
    is($r2->edits_pending, 1);
    is($r2->barcode->format, '');

    reject_edit($c, $edit);

    $edit = _create_edit($c);
    accept_edit($c, $edit);

    $r1 = $c->model('Release')->get_by_id(1);
    $r2 = $c->model('Release')->get_by_id(2);
    is($r1->edits_pending, 2);
    is($r1->barcode->format, '5099703257021');
    is($r2->edits_pending, 0);
    is($r2->barcode->format, '5199703257021');
};

sub _create_edit {
    my $c = shift;
    my $old_rel = $c->model('Release')->get_by_id(1);
    my $new_rel = $c->model('Release')->get_by_id(2);
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_EDIT_BARCODES,
        editor_id => 1,
        submissions => [
            {
                release => $old_rel,
                barcode => '5099703257021',
            },
            {
                release => $new_rel,
                barcode => '5199703257021'
            }
        ]
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
