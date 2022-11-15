package t::MusicBrainz::Server::Controller::Work::Details;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/work/745c079d-374e-4436-9448-da92dedef3ce/details',
              'fetch work details page');
html_ok($mech->content);
$mech->content_contains('https://musicbrainz.org/work/745c079d-374e-4436-9448-da92dedef3ce',
                        '..has permanent link');
$mech->content_contains('>745c079d-374e-4436-9448-da92dedef3ce</',
                        '..has mbid in plain text');


};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
