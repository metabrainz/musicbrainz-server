package t::MusicBrainz::Server::Controller::Area::Places;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether the Places tab for an area correctly lists places
located in another area contained in this one.

=cut

test 'Places from contained areas are shown' => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+event');

    $mech->get_ok(
      '/area/8a754a16-0027-3a29-b6d7-2b40ea0481ed/places',
      'Fetch the area places page',
    );
    html_ok($mech->content);

    $mech->content_contains(
        'Royal Albert Hall',
        'An place from a contained area is present',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
