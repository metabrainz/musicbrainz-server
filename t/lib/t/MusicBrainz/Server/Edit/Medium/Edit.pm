package t::MusicBrainz::Server::Edit::Medium::Edit;
use Test::Routine;
use Test::More;

with 't::Context';

use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_EDIT );
use MusicBrainz::Server::Types ':edit_status';
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

BEGIN { use MusicBrainz::Server::Edit::Medium::Edit }

use aliased 'MusicBrainz::Server::Entity::ArtistCredit';
use aliased 'MusicBrainz::Server::Entity::ArtistCreditName';
use aliased 'MusicBrainz::Server::Entity::Track';

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_medium');

my $medium = $c->model('Medium')->get_by_id(1);
is_unchanged($medium);

my $edit = create_edit($c, $medium);
isa_ok($edit, 'MusicBrainz::Server::Edit::Medium::Edit');

$edit = $c->model('Edit')->get_by_id($edit->id);
$medium = $c->model('Medium')->get_by_id(1);
is_unchanged($medium);
is($medium->edits_pending, 1);

reject_edit($c, $edit);
$medium = $medium = $c->model('Medium')->get_by_id(1);
is($medium->edits_pending, 0);

$edit = create_edit($c, $medium);
accept_edit($c, $edit);

$medium = $medium = $c->model('Medium')->get_by_id(1);
$c->model('Track')->load_for_tracklists($medium->tracklist);
is($medium->tracklist->tracks->[0]->name => 'Fluffles');
is($medium->format_id, 1);
is($medium->release_id, 1);
is($medium->position, 2);
is($medium->edits_pending, 0);

};

test 'Edits are rejected if the tracklist has changed since edit creation' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_medium');
    MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO editor (id, name, password) VALUES (1, 'editor', 'pass');
INSERT INTO editor (id, name, password) VALUES (4, 'modbot', 'pass');
EOSQL

    my $medium = $c->model('Medium')->get_by_id(1);
    my $edit1 = create_edit($c, $medium);
    my $edit2 = create_edit($c, $medium);

    accept_edit($c, $edit1);
    accept_edit($c, $edit2);

    $edit1 = $c->model('Edit')->get_by_id($edit1->id);
    $edit2 = $c->model('Edit')->get_by_id($edit2->id);

    is($edit1->status, $STATUS_APPLIED, 'edit 1 applied');
    is($edit2->status, $STATUS_FAILEDDEP, 'edit 2 has a failed dependency error');
};

sub create_edit {
    my ($c, $medium) = @_;

    my $tracklist = [
        Track->new(
            name => 'Fluffles',
            artist_credit => ArtistCredit->new(
                names => [
                    ArtistCreditName->new(
                        name => 'Warp Industries',
                        artist_id => 1
                    )]),
            recording_id => 1,
            position => 1
        )
    ];

    return $c->model('Edit')->create(
        editor_id => 1,
        edit_type => $EDIT_MEDIUM_EDIT,
        to_edit => $medium,
        format_id => 1,
        name => 'Edited name',
        tracklist => $tracklist,
        separate_tracklists => 1,
        position => 2,
    );
}

sub is_unchanged {
    my $medium = shift;
    is($medium->tracklist_id, 1);
    is($medium->format_id, undef);
    is($medium->release_id, 1);
    is($medium->position, 1);
}

1;
