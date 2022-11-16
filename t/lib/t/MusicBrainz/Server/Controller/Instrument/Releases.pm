package t::MusicBrainz::Server::Controller::Instrument::Releases;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok test_xpath_html );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

  This test checks whether the instrument releases page correctly lists
  releases connected to the instrument.

=cut

test 'Instrument releases page contains the expected data' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database(
        $c,
        '+controller_instrument',
    );

    $mech->get_ok(
        '/instrument/089f123c-0f7d-4105-a64e-49de81ca8fa4/releases',
        'Fetched the instrument releases page',
    );
    html_ok($mech->content);
    my $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '1',
        'There is one entry in the releases table',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr/td[1]',
        'Diabolus in Musica - Accardo interpreta Paganini',
        'The entry is for the expected release',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr/td[9]',
        'instrument',
        'The entry lists the relevant role, "instrument"',
    );
};

1;
