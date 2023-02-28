package t::MusicBrainz::Server::Controller::ReleaseGroup::Edits;
use strict;
use warnings;

use Test::Routine;

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/release-group/234c079d-374e-4436-9448-da92dedef3ce/edits',
              'fetch release group editing history');

};

1;
