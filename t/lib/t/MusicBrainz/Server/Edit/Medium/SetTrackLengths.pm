package t::MusicBrainz::Server::Edit::Medium::SetTrackLengths;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

use MusicBrainz::Server::Constants qw( $EDIT_SET_TRACK_LENGTHS );
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
};

test 'Setting track lengths on medium with pregap track' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+tracklist');

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_SET_TRACK_LENGTHS,
        editor_id => 1,
        medium_id => 4,
        cdtoc_id => 2
    );
    isa_ok($edit => 'MusicBrainz::Server::Edit::Medium::SetTrackLengths');

    my $medium = $c->model('Medium')->get_by_id(4);
    $c->model('Track')->load_for_mediums($medium);
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

1;
