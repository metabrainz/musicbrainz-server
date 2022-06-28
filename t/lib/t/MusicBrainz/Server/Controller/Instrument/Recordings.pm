package t::MusicBrainz::Server::Controller::Instrument::Recordings;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok test_xpath_html );
use utf8;

with 't::Mechanize', 't::Context';

=head2 Test description

  This test checks whether the instrument recordings page correctly lists
  recordings connected to the instrument.

=cut

test 'Instrument recordings page contains the expected data' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database(
        $c,
        '+controller_instrument',
    );

    $mech->get_ok(
        '/instrument/089f123c-0f7d-4105-a64e-49de81ca8fa4/recordings',
        'Fetched the instrument recordings page',
    );
    html_ok($mech->content);
    my $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '1',
        'There is one entry in the recordings table',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr/td[1]',
        '24 Capricci per violino solo, op. 1: 1. Andante. E-dur',
        'The entry is for the expected recording',
    );
    $tx->is(
        '//table[@class="tbl"]/tbody/tr/td[6]',
        'instrument (as “violino”)',
        'The entry lists the relevant role, "instrument", with the used credit',
    );
};

1;
