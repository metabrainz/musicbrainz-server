package t::MusicBrainz::Server::Controller::Series::Aliases;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Edit';
with 't::Mechanize';
with 't::Context';

=head1 DESCRIPTION

This test checks whether series aliases are correctly listed on the series
alias page.

=cut

test 'Series alias appears on alias page content' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+series');

    $mech->get_ok(
        '/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/aliases',
        'Fetched series aliases page',
    );
    html_ok($mech->content);

    $mech->text_contains('Test Series Alias', 'Alias page lists the alias');
    $mech->text_contains('Series name', 'Alias page lists the alias type');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
