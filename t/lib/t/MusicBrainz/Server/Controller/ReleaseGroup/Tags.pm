package t::MusicBrainz::Server::Controller::ReleaseGroup::Tags;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether release group tagging is working correctly. It checks
both up- and downvoting, plus withdrawing/removing tags.

=cut

test 'Release group tagging (up/downvoting, withdrawing)' => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c);

    $mech->get_ok(
        '/release-group/7c3218d7-75e0-4e8c-971f-f097b6c308c5/tags',
        'Fetched the release group tags page',
    );
    html_ok($mech->content);
    $mech->content_contains(
        'Nobody has tagged this yet',
        'The "not tagged yet" message is present',
    );

    $mech->get_ok('/login');
    $mech->submit_form(with_fields => {username => 'new_editor', password => 'password'});

    $mech->get_ok(
        '/release-group/7c3218d7-75e0-4e8c-971f-f097b6c308c5/tags/upvote?tags=Art Rock, Progressive Rock',
        'Upvoted tags "art rock" and "progressive rock"',
    );
    $mech->get_ok(
        '/release-group/7c3218d7-75e0-4e8c-971f-f097b6c308c5/tags',
        'Fetched the release group tags page again',
    );
    html_ok($mech->content);
    $mech->content_contains(
        'art rock',
        'Upvoted tag "art rock" is present',
    );
    $mech->content_contains(
        'progressive rock',
        'Upvoted tag "progressive rock" is present',
    );

    $mech->get_ok(
        '/release-group/7c3218d7-75e0-4e8c-971f-f097b6c308c5/tags/withdraw?tags=Art Rock, Progressive Rock',
        'Withdrew tags "art rock" and "progressive rock"',
    );
    $mech->get_ok(
        '/release-group/7c3218d7-75e0-4e8c-971f-f097b6c308c5/tags',
        'Fetched the release group tags page again',
    );
    html_ok($mech->content);
    $mech->content_lacks(
        'art rock',
        'Withdrawn tag "art rock" is missing',
    );
    $mech->content_lacks(
        'progressive rock',
        'Withdrawn tag "progressive rock" is missing',
    );

    $mech->get_ok(
        '/release-group/7c3218d7-75e0-4e8c-971f-f097b6c308c5/tags/downvote?tags=Art Rock, Progressive Rock',
        'Downvoted tags "art rock" and "progressive rock"',
    );
    $mech->get_ok(
        '/release-group/7c3218d7-75e0-4e8c-971f-f097b6c308c5/tags',
        'Fetched the release group tags page again',
    );
    html_ok($mech->content);
    $mech->content_contains(
        'art rock',
        'Downvoted tag "art rock" is present',
    );
    $mech->content_contains(
        'progressive rock',
        'Downvoted tag "progressive rock" is present',
    );
};

1;
