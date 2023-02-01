package t::MusicBrainz::Server::Controller::Series::Show;
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

    $mech->get_ok('/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d', 'fetch series index');
    html_ok($mech->content);
    $mech->title_like(qr/Test Recording Series/, 'title has series name');
    $mech->content_like(qr/Test Recording Series/, 'content has series name');
    $mech->content_like(qr/test comment 1/, 'disambiguation comments');
    $mech->content_like(qr/Recording series/, 'has series type');
    $mech->content_like(qr/Automatic/, 'has ordering type');

    # Check recordings
    $mech->content_like(qr/Dancing Queen/, 'has recording title');
    $mech->content_like(qr/A1/, 'has part number of first recording');
    $mech->content_like(qr/King of the Mountain/, 'has recording title');
    $mech->content_like(qr/A11/, 'has part number of second recording');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
