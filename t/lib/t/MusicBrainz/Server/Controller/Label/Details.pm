package t::MusicBrainz::Server::Controller::Label::Details;
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

$mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/details',
              'fetch label details page');
html_ok($mech->content);

$mech->content_contains('https://musicbrainz.org/label/46f0f4cd-8aab-4b33-b698-f459faf64190',
                        '..has permanent link');
# I don't think this test could be much more wrong, but it passes for now
$mech->content_contains('>46f0f4cd-8aab-4b33-b698-f459faf64190</',
                        '..has mbid in plain text');

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
