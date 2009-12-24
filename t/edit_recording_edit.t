#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Recording::Edit' };

use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_EDIT );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_recording');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $recording = $c->model('Recording')->get_by_id(1);
is_unchanged($recording);
is($recording->edits_pending, 0);

my $edit = create_edit($recording);
isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::Edit');

my ($edits) = $c->model('Edit')->find({ recording => 1 }, 10, 0);
is($edits->[0]->id, $edit->id);

$recording = $c->model('Recording')->get_by_id(1);
is_unchanged($recording);
is($recording->edits_pending, 1);

reject_edit($c, $edit);

$recording = $c->model('Recording')->get_by_id(1);
is_unchanged($recording);
is($recording->edits_pending, 0);

$recording = $c->model('Recording')->get_by_id(1);
$edit = create_edit($recording);
accept_edit($c, $edit);

$recording = $c->model('Recording')->get_by_id(1);
$c->model('ArtistCredit')->load($recording);
is($recording->name, 'Edited name');
is($recording->comment, 'Edited comment');
is($recording->length, 12345);
is($recording->edits_pending, 0);
is($recording->artist_credit->name, 'Foo');

done_testing;

sub create_edit {
    my $recording = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_RECORDING_EDIT,
        editor_id => 1,
        recording => $recording,
        name => 'Edited name',
        comment => 'Edited comment',
        length => '12345',
        artist_credit => [
            { artist => 1, name => 'Foo' },
        ]
    );
}

sub is_unchanged {
    my $recording = shift;
    subtest 'check recording hasnt changed' => sub {
        plan tests => 4;
        is($recording->name, 'Traits (remix)');
        is($recording->comment, undef);
        is($recording->artist_credit_id, 1);
        is($recording->length, undef);
    }
}
