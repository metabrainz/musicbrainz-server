#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::PUID::Delete'; }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_PUID_DELETE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+puid');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $delete_puid = $c->model('RecordingPUID')->get_by_recording_puid(3, '134478d1-306e-41a1-8b37-ff525e53c8be')
    or die "Fuck this";
my $edit = _create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::PUID::Delete');

my @puids = $c->model('RecordingPUID')->find_by_recording(3);
is(scalar @puids, 2);

my $puid = $c->model('RecordingPUID')->get_by_id(6);
is($puid->edits_pending, 1);

my ($edits, $hits) = $c->model('Edit')->find({ recording => 3 }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

reject_edit($c, $edit);

$puid = $c->model('RecordingPUID')->get_by_id(6);
is($puid->edits_pending, 0);

$edit = _create_edit();
accept_edit($c, $edit);

@puids = $c->model('RecordingPUID')->find_by_recording(3);
is(scalar @puids, 1);

$puid = $c->model('RecordingPUID')->get_by_id(6);
ok(!defined $puid);

done_testing;

sub _create_edit {
    return $c->model('Edit')->create(
        edit_type => $EDIT_PUID_DELETE,
        editor_id => 1,
        puid => $delete_puid,
    );
}
