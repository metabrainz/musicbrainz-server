package t::MusicBrainz::Server::Controller::Artist::EligibleForCleanup;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether artists are correctly displayed as eligible for
cleanup (in risk of being auto-removed).

=cut

test 'Cleanup banner does not appear for artist with recording' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database(
        $c,
        '+artist_cleanup',
    );

    $mech->get_ok(
        '/artist/6f0e02df-c745-4f2a-84bd-51b12685b942',
        'Fetched the index page for an artist with a recording',
    );

    html_ok($mech->content);
    $mech->content_lacks(
      'will be removed automatically',
      'The artist page does not show a cleanup banner',
    );
};

test 'Cleanup banner does not appear for artist with relationship' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database(
        $c,
        '+artist_cleanup',
    );

    $mech->get_ok(
        '/artist/5cd50089-fd14-460c-ae72-e94277b15ae4',
        'Fetched the index page for an artist with a relationship',
    );

    html_ok($mech->content);
    $mech->content_lacks(
      'will be removed automatically',
      'The artist page does not show a cleanup banner',
    );
};

test 'Cleanup banner does not appear for empty artist with open edits' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database(
        $c,
        '+artist_cleanup',
    );

    $mech->get_ok(
        '/artist/74b265fe-aeaf-4f47-a619-98d70ff61ffa',
        'Fetched the index page for an empty artist with an open Edit artist edit',
    );

    html_ok($mech->content);
    $mech->content_lacks(
      'will be removed automatically',
      'The artist page does not show a cleanup banner',
    );
};

test 'Cleanup banner appears for empty artist with no edits' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database(
        $c,
        '+artist_cleanup',
    );

    $mech->get_ok(
        '/artist/08d33da4-d011-4731-897a-3df1fcfc4ed5',
        'Fetched the index page for an empty artist with no open edits',
    );

    html_ok($mech->content);
    $mech->content_contains(
      'will be removed automatically',
      'The artist page shows a cleanup banner',
    );
};

test 'Cleanup banner appears for empty artist with only creation edit open' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database(
        $c,
        '+artist_cleanup',
    );

    $mech->get_ok(
        '/artist/c1f4717d-32af-418c-abae-e85ded7bd420',
        'Fetched the index page for an empty artist with only its own Add artist edit open',
    );

    html_ok($mech->content);
    $mech->content_contains(
      'will be removed automatically',
      'The artist page shows a cleanup banner',
    );
};

1;
