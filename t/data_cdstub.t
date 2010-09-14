#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use Test::Moose;
use_ok 'MusicBrainz::Server::Data::CDStub';
use_ok 'MusicBrainz::Server::Data::CDStubTOC';
use_ok 'MusicBrainz::Server::Data::CDStubTrack';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_raw_test_database($c, '+cdstub_raw');

my $cdstubtoc = MusicBrainz::Server::Data::CDStubTOC->new(c => $c);

my $toc = $cdstubtoc->get_by_discid('YfSgiOEayqN77Irs.VNV.UNJ0Zs-');
$c->model('CDStub')->load($toc);
$c->model('CDStubTrack')->load_for_cdstub($toc->release);

is ( $toc->discid, 'YfSgiOEayqN77Irs.VNV.UNJ0Zs-');
is ( $toc->leadout_offset, 20000 );
is ( $toc->track_count, 2 );
is ( $toc->track_offset->[0], 150 );
is ( $toc->track_offset->[1], 10000 );

my $release = $toc->release;
is ($release->title, 'Test Stub');
is ($release->artist, 'Test Artist');
is ($release->date_added->year, 2000);
is ($release->date_added->month, 1);
is ($release->date_added->day, 1);
is ($release->last_modified->year, 2001);
is ($release->last_modified->month, 1);
is ($release->last_modified->day, 1);
is ($release->lookup_count, 10);
is ($release->modify_count, 1);
is ($release->barcode, '837101029192');
is ($release->comment, 'comment');

my $track = $release->tracks->[0];
is ($track->title, 'Track title 1');
is ($track->artist, '');
is ($track->sequence, 0);

$track = $release->tracks->[1];
is ($track->title, 'Track title 2');
is ($track->artist, '');
is ($track->sequence, 1);

done_testing;
