#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_MOVE_DISCID );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

BEGIN { use_ok 'MusicBrainz::Server::Edit::Medium::MoveDiscID' }

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+cdtoc');
MusicBrainz::Server::Test->prepare_test_database($c, <<'SQL');
    SET client_min_messages TO warning;
    TRUNCATE artist CASCADE;
SQL
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my ($new_medium, $medium_cdtoc);

reload_data();

my $edit = create_edit();
reload_data();

ok($edit->is_open);
is($medium_cdtoc->medium_id, 1);
is($medium_cdtoc->edits_pending, 1);
is($medium_cdtoc->medium->release->edits_pending, 1);

reject_edit($c, $edit);
reload_data();

is($medium_cdtoc->medium_id, 1);
is($medium_cdtoc->edits_pending, 0);
is($medium_cdtoc->medium->release->edits_pending, 0);

$edit = create_edit();
accept_edit($c, $edit);
reload_data();

is($medium_cdtoc->medium_id, 2);
is($medium_cdtoc->edits_pending, 0);
is($medium_cdtoc->medium->release->edits_pending, 0);

done_testing;

sub create_edit {
    return $c->model('Edit')->create(
        edit_type => $EDIT_MEDIUM_MOVE_DISCID,
        editor_id => 1,
        new_medium => $new_medium,
        medium_cdtoc => $medium_cdtoc,
    );
}

sub reload_data {
    $new_medium = $c->model('Medium')->get_by_id(2);
    $medium_cdtoc = $c->model('MediumCDTOC')->get_by_id(1);
    $c->model('Medium')->load($medium_cdtoc);
    $c->model('Release')->load($new_medium, $medium_cdtoc->medium);
}
