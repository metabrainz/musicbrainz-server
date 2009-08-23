#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::ReleaseGroup::Edit' }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_EDIT );
use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_rg_delete');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $rg = $c->model('ReleaseGroup')->get_by_id(1);
my $edit = create_edit($rg);
isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Edit');

my ($edits) = $c->model('Edit')->find({ release_group => 1 }, 10, 0);
is($edits->[0]->id, $edit->id);

$rg = $c->model('ReleaseGroup')->get_by_id(1);
is($rg->edits_pending, 1);
is_unchanged($rg);

$c->model('Edit')->load_all($edit);
is($edit->release_group_id, 1);
is($edit->release_group->id, 1);

$c->model('Edit')->reject($edit);
$rg = $c->model('ReleaseGroup')->get_by_id(1);
is_unchanged($rg);
is($rg->edits_pending, 0);

$edit = create_edit($rg);
$c->model('Edit')->accept($edit);
$rg = $c->model('ReleaseGroup')->get_by_id(1);
$c->model('ArtistCredit')->load($rg);
is($rg->edits_pending, 0);
is($rg->artist_credit->name, 'Break & Silent Witness');
is($rg->type_id, 1);
is($rg->comment, 'EP');
is($rg->name, 'We Know');

done_testing;

sub create_edit {
    my $rg = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASEGROUP_EDIT,
        editor_id => 2,
        release_group => $rg,

        artist_credit => [
            { name => 'Break', artist => 1 },
            ' & ',
            { name => 'Silent Witness', artist => 1 },
        ],
        name => 'We Know',
        comment => 'EP',
        type_id => 1,
    );
}

sub is_unchanged {
    my $rg = shift;
    is($rg->name, 'Release Name');
    is($rg->type_id, undef);
    is($rg->comment, undef);
    is($rg->artist_credit_id, 1);
}
