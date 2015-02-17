package t::MusicBrainz::Server::Entity::CDStub;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::CDStub;
use MusicBrainz::Server::Entity::CDStubTOC;
use MusicBrainz::Server::Entity::CDStubTrack;

test all => sub {

#check to see that all the attributes are present
my $cdstubtoc = MusicBrainz::Server::Entity::CDStubTOC->new();
has_attribute_ok($cdstubtoc, $_) for qw( cdstub_id cdstub discid track_count
                                         leadout_offset track_offset );

my $cdstubtrack = MusicBrainz::Server::Entity::CDStubTrack->new();
has_attribute_ok($cdstubtrack, $_) for qw( cdstub_id cdstub title artist sequence length );

my $cdstub = MusicBrainz::Server::Entity::CDStub->new();
has_attribute_ok($cdstub, $_) for qw( discid title artist date_added last_modified
                                      lookup_count modify_count source track_count
                                      barcode comment );

# Now contstruct a CDStubTOC with a CDStub and a CDStubTrack
$cdstubtrack->title("Track title");
$cdstub->title("CDStub Title");
$cdstub->tracks([$cdstubtrack]);
$cdstubtoc->leadout_offset("100000");
$cdstubtoc->cdstub($cdstub);

# Check to see that the title of the CD Stub is as we expected
is ($cdstubtoc->cdstub->title, "CDStub Title");

# Check to see that the title of the CD Stub Track is as we expected
is ($cdstubtoc->cdstub->tracks->[0]->title, "Track title");

# Check to see if the calculated length is correct
is ($cdstubtoc->length, "1333333");

};

1;
