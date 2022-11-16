package t::MusicBrainz::Server::Controller::Label::Ratings;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok test_xpath_html );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether label ratings are properly displayed on the ratings
page, and that private ratings are hidden.

=cut

test 'Label rating page displays the right data' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);
    MusicBrainz::Server::Test->prepare_test_database(
        $c,
        '+controller_ratings',
    );
    MusicBrainz::Server::Test->prepare_raw_test_database($c, <<~'SQL');
        INSERT INTO label_rating_raw (label, editor, rating)
             VALUES (2, 1, 20), (2, 2, 100);
        SQL

    $mech->get_ok(
      '/label/46f0f4cd-8aab-4b33-b698-f459faf64190/ratings',
      'Fetched label ratings',
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
