package t::MusicBrainz::Server::Entity::CDStub;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::CDStub;
use MusicBrainz::Server::Entity::CDStubTrack;

test all => sub {

#check to see that all the attributes are present
my $cdstubtrack = MusicBrainz::Server::Entity::CDStubTrack->new();
has_attribute_ok($cdstubtrack, $_) for qw( cdstub_id cdstub title artist sequence length );

my $cdstub = MusicBrainz::Server::Entity::CDStub->new();
has_attribute_ok($cdstub, $_) for qw(
    artist
    barcode
    comment
    date_added
    discid
    last_modified
    leadout_offset
    lookup_count
    modify_count
    source
    title
    track_count
    track_offset
);

# Now contstruct CDStub and a CDStubTrack
$cdstubtrack->title('Track title');
$cdstub->title('CDStub Title');
$cdstub->tracks([$cdstubtrack]);
$cdstub->leadout_offset('100000');

# Check to see that the title of the CD Stub is as we expected
is ($cdstub->title, 'CDStub Title');

# Check to see that the title of the CD Stub Track is as we expected
is ($cdstub->tracks->[0]->title, 'Track title');

# Check to see if the calculated length is correct
is ($cdstub->length, '1333333');

};

1;
