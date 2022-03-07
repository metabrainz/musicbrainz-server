package t::MusicBrainz::Server::Controller::Artist::Ratings;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok test_xpath_html );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether artist ratings are properly displayed on the ratings
page, and that private ratings are hidden.

=cut

test 'Artist rating page displays the right data' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);
    MusicBrainz::Server::Test->prepare_test_database(
        $c,
        '+controller_ratings',
    );
    MusicBrainz::Server::Test->prepare_raw_test_database($c, <<~'SQL');
        INSERT INTO artist_rating_raw (artist, editor, rating)
             VALUES (3, 1, 20), (3, 2, 100);
        SQL

    $mech->get_ok(
      '/artist/745c079d-374e-4436-9448-da92dedef3ce/ratings',
      'Fetched artist ratings',
    );
    html_ok($mech->content);
    $mech->content_contains(
        'new_editor',
        'The editor who gave a public rating is named',
    );
    $mech->content_lacks(
        'alice',
        'The editor who gave a private rating is not named',
    );

    my $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//li//span[@class="inline-rating"])',
        1,
        'One user rating is shown'
    );
    $tx->is(
        '(//span[@class="current-rating"])[1]',
        1,
        'The public user rating is shown',
    );
    $tx->is(
        '(//span[@class="current-rating"])[2]',
        3,
        'The average rating is shown',
    );

    $mech->content_contains(
        '1 private rating not listed',
        'The notice about a private rating is present',
    );
};

1;
