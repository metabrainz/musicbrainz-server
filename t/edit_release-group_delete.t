#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 9;

BEGIN {
    use_ok 'MusicBrainz::Server::Data::Edit';
    use_ok 'MusicBrainz::Server::Edit::ReleaseGroup::Delete';
}

use MusicBrainz::Server::Data::ReleaseGroup;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_DELETE );
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $c);
my $rg_data = MusicBrainz::Server::Data::ReleaseGroup->new(c => $c);

my $edit = $edit_data->create(
    edit_type => $EDIT_RELEASEGROUP_DELETE,
    release_group_id => 3,
    editor_id => 1
);
isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Delete');
is($edit->entity_model, 'ReleaseGroup');
is($edit->entity_id, 3);
is_deeply($edit->entities, { release_group => [ 3 ] });

my $rg = $rg_data->get_by_id(3);
ok(defined $rg);
is($rg->edits_pending, 1);

$edit_data->accept($edit);
$rg = $rg_data->get_by_id(3);
ok(!defined $rg);
