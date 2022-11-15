package t::MusicBrainz::Server::Controller::ReleaseGroup::Ratings;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok test_xpath_html );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether release group ratings are properly displayed on the
ratings page, and that private ratings are hidden.

=cut

test 'Release group rating page displays the right data' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);
    MusicBrainz::Server::Test->prepare_test_database(
        $c,
        '+controller_ratings',
    );
    MusicBrainz::Server::Test->prepare_raw_test_database($c, <<~'SQL');
        INSERT INTO release_group_rating_raw (release_group, editor, rating)
             VALUES (2, 1, 20), (2, 2, 100);
        SQL

    $mech->get_ok(
      '/release-group/7c3218d7-75e0-4e8c-971f-f097b6c308c5/ratings',
      'Fetched release group ratings',
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
