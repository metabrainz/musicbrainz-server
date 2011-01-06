package t::MusicBrainz::Server::Data::CDStub;
use Test::Routine;
use Test::Moose;
use Test::More;

use_ok 'MusicBrainz::Server::Data::CDStub';
use_ok 'MusicBrainz::Server::Data::CDStubTOC';
use_ok 'MusicBrainz::Server::Data::CDStubTrack';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

test all => sub {

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_raw_test_database($c, '+cdstub_raw');

my $cdstubtoc = MusicBrainz::Server::Data::CDStubTOC->new(c => $c);

my $toc = $cdstubtoc->get_by_discid('YfSgiOEayqN77Irs.VNV.UNJ0Zs-');
$c->model('CDStub')->load($toc);
$c->model('CDStubTrack')->load_for_cdstub($toc->cdstub);

is ( $toc->discid, 'YfSgiOEayqN77Irs.VNV.UNJ0Zs-');
is ( $toc->leadout_offset, 20000 );
is ( $toc->track_count, 2 );
is ( $toc->track_offset->[0], 150 );
is ( $toc->track_offset->[1], 10000 );

my $cdstub = $toc->cdstub;
is ($cdstub->title, 'Test Stub');
is ($cdstub->artist, 'Test Artist');
is ($cdstub->date_added->year, 2000);
is ($cdstub->date_added->month, 1);
is ($cdstub->date_added->day, 1);
is ($cdstub->last_modified->year, 2001);
is ($cdstub->last_modified->month, 1);
is ($cdstub->last_modified->day, 1);
is ($cdstub->lookup_count, 10);
is ($cdstub->modify_count, 1);
is ($cdstub->barcode, '837101029192');
is ($cdstub->comment, 'this is a comment');

my $track = $cdstub->tracks->[0];
is ($track->title, 'Track title 1');
is ($track->artist, '');
is ($track->sequence, 0);

$track = $cdstub->tracks->[1];
is ($track->title, 'Track title 2');
is ($track->artist, '');
is ($track->sequence, 1);

};

1;
