package t::MusicBrainz::Server::Controller::URL::Show;
use utf8;
use strict;
use warnings;

use Test::Routine;

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+url');

$mech->get_ok('/url/25d6b63a-12dc-41c9-858a-2f42ae610a7d');
$mech->content_contains('http://zh-yue.wikipedia.org/wiki/王菲');
$mech->content_contains('zh-yue: 王菲');

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
