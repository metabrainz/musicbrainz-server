package t::MusicBrainz::Server::Edit::Medium::SetTrackLengths;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

use MusicBrainz::Server::Constants qw(
    $EDIT_SET_TRACK_LENGTHS
    $STATUS_FAILEDDEP
    $UNTRUSTED_FLAG
);
use MusicBrainz::Server::Test;

test all => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+tracklist');

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_SET_TRACK_LENGTHS,
        editor_id => 1,
        medium_id => 1,
        cdtoc_id => 1
    );
    isa_ok($edit => 'MusicBrainz::Server::Edit::Medium::SetTrackLengths');

    my $medium = $c->model('Medium')->get_by_id(1);
    $c->model('Track')->load_for_mediums($medium);
    is($medium->tracks->[0]->length, 338640);
    is($medium->tracks->[1]->length, 273133);
    is($medium->tracks->[2]->length, 327226);
    is($medium->tracks->[3]->length, 252066);
    is($medium->tracks->[4]->length, 719666);
    is($medium->tracks->[5]->length, 276933);
    is($medium->tracks->[6]->length, 94200);

    isa_ok exception {
        $c->model('Edit')->create(
            edit_type => $EDIT_SET_TRACK_LENGTHS,
            editor_id => 1,
            medium_id => 1,
            cdtoc_id => 1
        )
    }, 'MusicBrainz::Server::Edit::Exceptions::NoChanges';
};

test 'Setting track lengths on medium with pregap track' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+tracklist');

    # Note: Hidden pre-gap track is ignored on purpose, as pre-gap
    # duration is considered as a maximum for hidden track length.

    isa_ok exception {
        $c->model('Edit')->create(
            edit_type => $EDIT_SET_TRACK_LENGTHS,
            editor_id => 1,
            medium_id => 4,
            cdtoc_id => 2
        )
    }, 'MusicBrainz::Server::Edit::Exceptions::NoChanges';

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_SET_TRACK_LENGTHS,
        editor_id => 1,
        medium_id => 5,
        cdtoc_id => 2
    );
    isa_ok($edit => 'MusicBrainz::Server::Edit::Medium::SetTrackLengths');

    my $medium = $c->model('Medium')->get_by_id(5);
    $c->model('Track')->load_for_mediums($medium);

    # Hidden pre-gap track length is untouched on purpose, see above.
    is($medium->tracks->[0]->length, 148);

    is($medium->tracks->[1]->length, 86186);
    is($medium->tracks->[2]->length, 342306);
    is($medium->tracks->[3]->length, 290053);
    is($medium->tracks->[4]->length, 95933);
    is($medium->tracks->[5]->length, 358573);
    is($medium->tracks->[6]->length, 61333);
    is($medium->tracks->[7]->length, 300626);
    is($medium->tracks->[8]->length, 514679);
    is($medium->tracks->[9]->length, 472880);
};

test 'Fail gracefully if CD TOC has been removed' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+tracklist');

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_SET_TRACK_LENGTHS,
        editor_id => 1,
        medium_id => 1,
        cdtoc_id => 1,
        privileges => $UNTRUSTED_FLAG,
    );
    isa_ok($edit => 'MusicBrainz::Server::Edit::Medium::SetTrackLengths');

    $c->sql->do('DELETE FROM cdtoc WHERE id = 1');

    $c->model('Edit')->accept($edit);
    ok(!$edit->is_open);
    is($edit->status, $STATUS_FAILEDDEP);

    $c->model('EditNote')->load_for_edits($edit);
    is(scalar $edit->all_edit_notes, 1);

    my $note = scalar($edit->all_edit_notes) ? $edit->edit_notes->[0] : undef;
    is(
        defined $note && $note->localize,
        'The CD TOC the track times were being set from has been removed since this edit was entered.',
    );
};

1;
