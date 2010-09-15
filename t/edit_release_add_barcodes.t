#!/usr/bin/perl
use strict;
use Test::More;
BEGIN { use_ok 'MusicBrainz::Server::Edit::Release::AddBarcodes' }

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_ADD_BARCODES );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+release');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = _create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Release::AddBarcodes');

my ($edits) = $c->model('Edit')->find({ release => [1, 2] }, 10, 0);
is(@$edits, 1);
is($edits->[0]->id, $edit->id);

my $r1 = $c->model('Release')->get_by_id(1);
my $r2 = $c->model('Release')->get_by_id(2);
is($r1->edits_pending, 3);
is($r1->barcode, '731453398122');
is($r2->edits_pending, 1);
is($r2->barcode, undef);

reject_edit($c, $edit);

my $edit = _create_edit();
accept_edit($c, $edit);

my $r1 = $c->model('Release')->get_by_id(1);
my $r2 = $c->model('Release')->get_by_id(2);
is($r1->edits_pending, 2);
is($r1->barcode, '5099703257021');
is($r2->edits_pending, 0);
is($r2->barcode, '5199703257021');

done_testing;

sub _create_edit {
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_ADD_BARCODES,
        editor_id => 1,
        submissions => [
            {
                release_id => 1,
                barcode => '5099703257021',
            },
            {
                release_id => 2,
                barcode => '5199703257021'
            }
        ]
    );
}
