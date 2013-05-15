package t::MusicBrainz::Server::Edit::Medium::Create;
use Test::Routine;
use Test::More;
use Test::Deep qw( cmp_set );

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Medium::Create; }

use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_CREATE );
use MusicBrainz::Server::Constants qw( $STATUS_APPLIED );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

use aliased 'MusicBrainz::Server::Entity::Artist';
use aliased 'MusicBrainz::Server::Entity::ArtistCredit';
use aliased 'MusicBrainz::Server::Entity::ArtistCreditName';
use aliased 'MusicBrainz::Server::Entity::Track';

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+create_medium');

my $tracklist = [
    Track->new(
        name => 'Fluffles',
        artist_credit => ArtistCredit->new(
            names => [
                ArtistCreditName->new(
                    name => 'Warp Industries',
                    artist => Artist->new(
                        id => 2,
                        name => 'Artist',
                    )
                )]),
        recording_id => 1,
        position => 1
    )
];

my $edit = $c->model('Edit')->create(
    edit_type => $EDIT_MEDIUM_CREATE,
    editor_id => 1,
    name => 'Studio',
    position => 1,
    format_id => 1,
    release => $c->model('Release')->get_by_id(1),
    tracklist => $tracklist
);

cmp_set($edit->related_entities->{artist}, [ 1, 2 ]);
cmp_set($edit->related_entities->{release}, [ 1 ]);
cmp_set($edit->related_entities->{release_group}, [ 1 ]);

isa_ok($edit, 'MusicBrainz::Server::Edit::Medium::Create');

ok(defined $edit->medium_id);
ok(defined $edit->id);

$c->model('Edit')->load_all($edit);
ok($edit->display_data);
is($edit->display_data->{name}, 'Studio');
is($edit->display_data->{position}, 1);
is($edit->display_data->{format}->id, 1);
is($edit->display_data->{release}->id, 1);
is($edit->display_data->{release}->artist_credit->name, 'Tosca');

my $medium = $c->model('Medium')->get_by_id($edit->medium_id);
is($medium->edits_pending, 1);

my $release = $c->model('Release')->get_by_id(1);
is($release->edits_pending, 1);

accept_edit($c, $edit);

$medium = $c->model('Medium')->get_by_id($edit->medium_id);
is($medium->edits_pending, 0);

$release = $c->model('Release')->get_by_id(1);
is($release->edits_pending, 0);

## Create a medium to reject
$edit = $c->model('Edit')->create(
    edit_type => $EDIT_MEDIUM_CREATE,
    editor_id => 1,
    name => 'Live',
    position => 2,
    format_id => 1,
    release => $c->model('Release')->get_by_id(1),
    tracklist => [
        $tracklist->[0],
        $tracklist->[0]->meta->clone_object($tracklist->[0], position => 2)
    ]
);

my $medium_id = $edit->medium_id;
$medium = $c->model('Medium')->get_by_id($medium_id);
reject_edit($c, $edit);

$medium = $c->model('Medium')->get_by_id($medium_id);
ok(!defined $medium);

my $tracks_creating_recordings = [
    Track->new(
        name => 'Fluffles',
        artist_credit => ArtistCredit->new(
            names => [
                ArtistCreditName->new(
                    name => 'Warp Industries',
                    artist => Artist->new(
                        id => 2,
                        name => 'Artist',
                    )
                )]),
        position => 1
    )
];

$edit = $c->model('Edit')->create(
    edit_type => $EDIT_MEDIUM_CREATE,
    editor_id => 1,
    name => 'Live',
    position => 2,
    format_id => 1,
    release => $c->model('Release')->get_by_id(1),
    tracklist => $tracks_creating_recordings
);

$c->model('Edit')->load_all($edit);
ok($edit->display_data);
ok(defined $edit->display_data->{tracks}->[0]->{recording_id}, "New recording was created");

};

1;
