use utf8;
use Moose;
use Test::More;
use FindBin qw( $Bin );
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Controller::Release;
use MusicBrainz::Server::Controller::ReleaseEditor;

my $c = MusicBrainz::Server::Test->create_test_context;

my $no_changes_data = do {
    local $/ = undef;
    open my $fh, "<", "$Bin/no-changes.data";
    <$fh>;
};

my $wizard_value = eval ($no_changes_data);

$wizard_value->{mediums}->[0]->{tracklist}->{tracks}->[1]->{deleted} = 1;
$wizard_value->{mediums}->[0]->{tracklist}->{tracks}->[2]->{position} -= 1;


# load release
# ------------------------------
my $release = $c->model('Release')->get_by_gid ('aff4a693-5970-4e2e-bd46-e2ee49c22de7');
$c->model('Release')->load_meta($release);
$c->model('ReleaseGroup')->load($release);
MusicBrainz::Server::Controller::Release::_load_tracklist ($c, $release);
MusicBrainz::Server::Controller::Release::_load_release ($c, $release);

# test changes
# ------------------------------
my $changes = MusicBrainz::Server::Controller::ReleaseEditor::tracklist_compare
    ($c, $release->mediums->[0], $wizard_value->{mediums}->[0]);

use Data::Dumper;
local $Data::Dumper::Maxdepth = 3;

warn Dumper ($changes)."\n";

ok (1, "OK\n");

done_testing;
