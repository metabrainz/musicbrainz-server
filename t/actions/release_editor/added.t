use utf8;
use Moose;
use Test::More;
use FindBin qw( $Bin );
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Controller::Release;
use MusicBrainz::Server::Controller::ReleaseEditor;

BEGIN {
    no warnings 'redefine';
    use DBDefs;
    *DBDefs::_RUNNING_TESTS = sub { 1 };
    *DBDefs::WEB_SERVER = sub { "localhost" };
}

my $c = MusicBrainz::Server::Test->create_test_context;
my $release_editor = MusicBrainz::Server::Controller::ReleaseEditor->new (c => $c);

sub track_changes
{
    my $t = shift;

    return $t->added || $t->artist || $t->deleted || $t->length ||
        $t->moved || $t->renamed;
}

# wizard->value without changes
# ------------------------------
my $no_changes_data = do {
    local $/ = undef;
    open my $fh, "<", "$Bin/no-changes.data";
    <$fh>;
};

my $wizard_value = eval ($no_changes_data);

# make some changes
# ------------------------------
$wizard_value->{mediums}->[0]->{tracklist}->{tracks}->[3] = {
    length => 243000,
    position => 2,
    name => 'the Love Bug (add a track remix)',
    deleted => 0,
    artist_credit => [
        { artist => '135345', name => 'm-flo' },
        "\x{2665}",
        { artist => '9496', name => 'BoA' },
        undef,
        { artist => undef, name => undef }
    ]
};

# load release
# ------------------------------
my $release = $c->model('Release')->get_by_gid ('aff4a693-5970-4e2e-bd46-e2ee49c22de7');
$c->model('Release')->load_meta($release);
$c->model('ReleaseGroup')->load($release);
$release_editor->_load_tracklist ($release);
$release_editor->_load_release ($release);

my @tracks = map { $_->all_tracks } map { $_->tracklist } $release->all_mediums;
$c->model('Recording')->load (@tracks);


# test changes
# ------------------------------
my $changes = $release_editor->tracklist_compare ($wizard_value->{mediums}->[0], $release->mediums->[0]);

is (0, track_changes ($changes->[0]), "Track 1 has no changes");
is (0, track_changes ($changes->[1]), "Track 2 has no changes");
is (0, track_changes ($changes->[2]), "Track 3 has no changes");

is (1, $changes->[3]->added, "Track 4 is being added");
is ('the Love Bug (add a track remix)', $changes->[3]->track->name, "New track has correct name");
is ('m-flo♥BoA', $changes->[3]->track->artist_credit->name, "New track has correct artist");
ok (scalar @{ $changes->[3]->suggestions } > 1, "Recording suggestions for new track");

done_testing;
