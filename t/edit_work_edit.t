#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Work::Edit' };

use MusicBrainz::Server::Constants qw( $EDIT_WORK_EDIT );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_work');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $work = $c->model('Work')->get_by_id(1);
is_unchanged($work);
is($work->edits_pending, 0);

my $edit = create_edit($work);
isa_ok($edit, 'MusicBrainz::Server::Edit::Work::Edit');

my ($edits) = $c->model('Edit')->find({ work => 1 }, 10, 0);
is($edits->[0]->id, $edit->id);

$edit = $c->model('Edit')->get_by_id($edit->id);
$c->model('Edit')->load_all($edit);
is($edit->work_id, 1);
is($edit->work->id, 1);
is_unchanged($edit->work);
is($edit->work->edits_pending, 1);

reject_edit($c, $edit);

$work = $c->model('Work')->get_by_id(1);
is_unchanged($work);
is($work->edits_pending, 0);

$work = $c->model('Work')->get_by_id(1);
$edit = create_edit($work);
accept_edit($c, $edit);

$work = $c->model('Work')->get_by_id(1);
$c->model('ArtistCredit')->load($work);
is($work->name, 'Edited name');
is($work->comment, 'Edited comment');
is($work->iswc, '123456789123456');
is($work->type_id, 1);
is($work->edits_pending, 0);
is($work->artist_credit->name, 'Foo');

done_testing;

sub create_edit {
    my $work = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_WORK_EDIT,
        editor_id => 1,
        work => $work,
        name => 'Edited name',
        comment => 'Edited comment',
        iswc => '123456789123456',
        type_id => 1,
        artist_credit => [
            { artist => 1, name => 'Foo' },
        ]
    );
}

sub is_unchanged {
    my $work = shift;
    is($work->name, 'Traits (remix)');
    is($work->comment, undef);
    is($work->iswc, undef);
    is($work->type_id, undef);
    is($work->artist_credit_id, 1);
}
