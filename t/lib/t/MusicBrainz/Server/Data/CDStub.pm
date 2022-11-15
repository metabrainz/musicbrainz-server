package t::MusicBrainz::Server::Data::CDStub;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::CDStub;
use MusicBrainz::Server::Data::CDStubTrack;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;

MusicBrainz::Server::Test->prepare_raw_test_database($test->c, '+cdstub_raw');

my $cdstub_data = MusicBrainz::Server::Data::CDStub->new(c => $test->c);

my $cdstub = $cdstub_data->get_by_discid('YfSgiOEayqN77Irs.VNV.UNJ0Zs-');
$test->c->model('CDStubTrack')->load_for_cdstub($cdstub);

is ( $cdstub->discid, 'YfSgiOEayqN77Irs.VNV.UNJ0Zs-');
is ( $cdstub->leadout_offset, 20000 );
is ( $cdstub->track_count, 2 );
is ( $cdstub->track_offset->[0], 150 );
is ( $cdstub->track_offset->[1], 10000 );

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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
