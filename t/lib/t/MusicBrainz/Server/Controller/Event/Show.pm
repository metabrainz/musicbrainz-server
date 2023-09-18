package t::MusicBrainz::Server::Controller::Event::Show;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );
use utf8;

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether basic event data is correctly listed on an event's
index (main) page.

=cut

test 'Basic event data appears the index page' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+event');

    $mech->get_ok(
        '/event/ca1d24c1-1999-46fd-8a95-3d4108df5cb2',
        'Fetched event index page',
    );
    html_ok($mech->content);

    $mech->title_like(
        qr/BBC Open Music Prom/,
        'The page title contains the event name',
    );
    $mech->content_like(qr/Kwamé Ryan/, 'The first performer name is listed');
    $mech->content_like(
        qr/BBC Concert Orchestra/,
        'The second performer name is listed',
    );
    $mech->content_like(qr/2022-09-01/, 'The event date is listed');
    $mech->content_like(qr/19:30/, 'The event time is listed');
    $mech->content_like(qr/Concert/, 'The event type is listed');
    $mech->content_like(qr/Royal Albert Hall/, 'The place is listed');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
