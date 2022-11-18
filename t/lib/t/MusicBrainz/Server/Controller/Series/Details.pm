package t::MusicBrainz::Server::Controller::Series::Details;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Edit';
with 't::Mechanize';
with 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+series');

    $mech->get_ok('/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/details',
                  'fetch series details page');
    html_ok($mech->content);

    $mech->content_contains('https://musicbrainz.org/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d',
                            '..has permanent link');

    $mech->content_contains('>a8749d0c-4a5a-4403-97c5-f6cd018f8e6d</',
                            '..has mbid in plain text');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
