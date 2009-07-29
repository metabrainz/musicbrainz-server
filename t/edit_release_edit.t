use strict;
use warnings;
use Test::More tests => 41;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Release::Edit' };
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_EDIT );
use MusicBrainz::Server::Data::ArtistCredit;
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $c);
my $release_data = MusicBrainz::Server::Data::Release->new(c => $c);
my $ac_data = MusicBrainz::Server::Data::ArtistCredit->new(c => $c);

# Starting point for releases
my $release = $release_data->get_by_id(1);
$ac_data->load($release);

check_release_empty($release);
is($release->edits_pending, 0);
is($release->release_group_id, 1);
is($release->name, 'Release');
is($release->artist_credit->name, 'Artist');

# Test editing all possible fields
my $edit = $edit_data->create(
    edit_type => $EDIT_RELEASE_EDIT,
    editor_id => 1,
    release => $release,
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

isa_ok($edit, 'MusicBrainz::Server::Edit::Release::Edit');
is($edit->entity_model, 'Release');
is($edit->entity_id, $release->id);
is($edit->release_id, $release->id);
is_deeply($edit->entities, { release => [ $release->id ] });

# Make sure the edit entered successfully and didn't modify $release
$release = $release_data->get_by_id(1);
$ac_data->load($release);
check_release_empty($release);          # shouldn't have changed yet
is($release->edits_pending, 1);
is($release->release_group_id, 1);
is($release->name, 'Release');
is($release->artist_credit->name, 'Artist');

# Accept the edit
$edit_data->accept($edit);

$release = $release_data->get_by_id(1);
$ac_data->load($release);
is($release->name, 'Edited name');
is($release->packaging_id, 1);
is($release->script_id, 1);
is($release->release_group_id, 2);
is($release->barcode, 'BARCODE');
is($release->country_id, 1);
ok(!$release->date->is_empty);
is($release->date->year, 1985);
is($release->date->month, 4);
is($release->date->day, 13);
is($release->language_id, 1);
is($release->comment, 'Edited comment');
is($release->artist_credit->name, 'New Artist');

# Check a release has just the NOT NULL fields present
sub check_release_empty {
    my ($release) = @_;
    is($release->packaging_id, undef);
    is($release->script_id, undef);
    is($release->barcode, undef);
    is($release->country_id, undef);
    ok($release->date->is_empty);
    is($release->language_id, undef);
    is($release->comment, undef);
}
