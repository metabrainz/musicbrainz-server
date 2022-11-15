package t::MusicBrainz::Server::Controller::WS::2::TXT::GenreList;
use utf8;
use strict;
use warnings;

use Test::Routine;

use MusicBrainz::Server::Test::WS qw( ws2_test_txt );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test ensures the full genre names list at genre/all is working for the
txt format.

=cut

test 'Genre names list is returned as expected' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    my $genre_names = join "\n", (
        'big beat',
        'dubstep',
        'electronic',
        'electronica',
        'glitch',
        'grime',
        'house',
        'j-pop',
        'k-pop',
        'pop',
    );

    ws2_test_txt 'genre names list using accept header',
        '/genre/all' => $genre_names;

    ws2_test_txt 'genre names list with fmt=txt',
        '/genre/all?fmt=txt' => $genre_names;
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
