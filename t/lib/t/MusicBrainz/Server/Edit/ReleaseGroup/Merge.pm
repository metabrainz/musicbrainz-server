package t::MusicBrainz::Server::Edit::ReleaseGroup::Merge;
use strict;
use warnings;

use Test::Routine;
use Test::More;

with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::ReleaseGroup::Merge }

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_MERGE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    my $old_rg = $c->model('ReleaseGroup')->insert({
        name => 'Old RG',
        artist_credit => 1,
        secondary_type_ids => [8, 6]
    });

    my $new_rg = $c->model('ReleaseGroup')->insert({
        name => 'New RG',
        artist_credit => 1,
        secondary_type_ids => [8, 10]
    });

    my $old_rg_id = $old_rg->{id};
    my $new_rg_id = $new_rg->{id};

    my $create_edit = sub {
        return $c->model('Edit')->create(
            edit_type => $EDIT_RELEASEGROUP_MERGE,
            editor_id => 1,
            old_entities => [{ id => $old_rg_id, name => 'Old RG' }],
            new_entity => { id => $new_rg_id, name => 'New RG' },
        );
    };

    my $edit = $create_edit->();
    isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Merge');

    my ($edits) = $c->model('Edit')->find({ release_group => [$new_rg_id, $old_rg_id] }, 10, 0);
    is($edits->[0]->id, $edit->id);

    $old_rg = $c->model('ReleaseGroup')->get_by_id($old_rg_id);
    $new_rg = $c->model('ReleaseGroup')->get_by_id($new_rg_id);
    is($old_rg->edits_pending, 1);
    is($new_rg->edits_pending, 1);

    reject_edit($c, $edit);
    $old_rg = $c->model('ReleaseGroup')->get_by_id($old_rg_id);
    $new_rg = $c->model('ReleaseGroup')->get_by_id($new_rg_id);
    ok(defined $old_rg);
    ok(defined $new_rg);

    $edit = $create_edit->();
    accept_edit($c, $edit);
    $old_rg = $c->model('ReleaseGroup')->get_by_id($old_rg_id);
    $new_rg = $c->model('ReleaseGroup')->get_by_id($new_rg_id);
    ok(defined $new_rg);
    ok(!defined $old_rg);

    $c->model('ReleaseGroupSecondaryType')->load_for_release_groups($new_rg);

    is(scalar @{ $new_rg->secondary_types }, 2, 'Release group has two secondary types after merging');
    my %types = map { $_->name => 1 } @{ $new_rg->secondary_types };

    ok($types{'DJ-mix'}, 'Release group has type DJ-mix');
    ok($types{'Demo'}, 'Release group has type Demo');
};

1;
