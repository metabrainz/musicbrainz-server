package t::MusicBrainz::Server::Edit::Release::Edit;
use Test::Routine;
use Test::More;

with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Release::Edit };

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_EDIT );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release');

# Starting point for releases
my $release = $c->model('Release')->get_by_id(1);
$c->model('ArtistCredit')->load($release);

is_unchanged($release);
is($release->edits_pending, 0);

# Test editing all possible fields
my $edit = create_edit($c, $release);
isa_ok($edit, 'MusicBrainz::Server::Edit::Release::Edit');

my ($edits) = $c->model('Edit')->find({ release => $release->id }, 10, 0);
is($edits->[0]->id, $edit->id);

$release = $c->model('Release')->get_by_id(1);
is($release->edits_pending, 1);
is_unchanged($release);

reject_edit($c, $edit);
$release = $c->model('Release')->get_by_id(1);
is_unchanged($release);
is($release->edits_pending, 0);

# Accept the edit
$edit = create_edit($c, $release);
accept_edit($c, $edit);

$release = $c->model('Release')->get_by_id(1);
$c->model('ArtistCredit')->load($release);
is($release->name, 'Edited name');
is($release->packaging_id, 1);
is($release->script_id, 1);
is($release->release_group_id, 2);
is($release->barcode, 'BARCODE');
is($release->country_id, 1);
is($release->date->year, 1985);
is($release->date->month, 4);
is($release->date->day, 13);
is($release->language_id, 1);
is($release->comment, 'Edited comment');
is($release->artist_credit->name, 'New Artist');

};

sub is_unchanged {
    my ($release) = @_;
    is($release->packaging_id, undef);
    is($release->script_id, undef);
    is($release->barcode, undef);
    is($release->country_id, undef);
    ok($release->date->is_empty);
    is($release->language_id, undef);
    is($release->comment, undef);
    is($release->release_group_id, 1);
    is($release->name, 'Release');
    is($release->artist_credit_id, 1);
}

sub create_edit {
    my $c = shift;
    my $release = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_EDIT,
        editor_id => 1,
        to_edit => $release,
        name => 'Edited name',
        comment => 'Edited comment',
        status_id => 1,
        packaging_id => 1,
        release_group_id => 2,
        barcode => 'BARCODE',
        country_id => 1,
        date => {
            year => 1985, month => 4, day => 13
        },
        artist_credit => [
            { artist => 2, name => 'New Artist' }
        ],
        language_id => 1,
        script_id => 1,
    );
}

1;
