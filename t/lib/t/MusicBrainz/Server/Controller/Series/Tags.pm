package t::MusicBrainz::Server::Controller::Series::Tags;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether series tagging is working correctly. It checks both
up- and downvoting, plus withdrawing/removing tags.

=cut

test 'Series tagging (up/downvoting, withdrawing)' => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c);

    $test->c->sql->do(<<~'SQL');
        INSERT INTO series (id, gid, name, comment, type, ordering_type)
        VALUES (1, 'cd58b3e5-371c-484e-b3fd-4084a6861e62', 'Test', '', 4, 1);
        SQL

    $mech->get_ok(
        '/series/cd58b3e5-371c-484e-b3fd-4084a6861e62/tags',
        'Fetched the series tags page',
    );
    html_ok($mech->content);
    $mech->content_contains(
        'Nobody has tagged this yet',
        'The "not tagged yet" message is present',
    );

    $mech->get_ok('/login');
    $mech->submit_form(with_fields => {username => 'new_editor', password => 'password'});

    $mech->get_ok(
        '/series/cd58b3e5-371c-484e-b3fd-4084a6861e62/tags/upvote?tags=World Music, Jazz',
        'Upvoted tags "jazzy" and "bassy"',
    );
    $mech->get_ok(
        '/series/cd58b3e5-371c-484e-b3fd-4084a6861e62/tags',
        'Fetched the series tags page again',
    );
    html_ok($mech->content);
    $mech->content_contains(
        'world music',
        'Upvoted tag "world music" is present',
    );
    $mech->content_contains('jazz', 'Upvoted tag "jazz" is present');

    $mech->get_ok(
        '/series/cd58b3e5-371c-484e-b3fd-4084a6861e62/tags/withdraw?tags=World Music, Jazz',
        'Withdrew tags "jazzy" and "bassy"',
    );
    $mech->get_ok(
        '/series/cd58b3e5-371c-484e-b3fd-4084a6861e62/tags',
        'Fetched the series tags page again',
    );
    html_ok($mech->content);
    $mech->content_lacks(
        'world music',
        'Withdrawn tag "world music" is missing',
    );
    $mech->content_lacks('jazz', 'Withdrawn tag "jazz" is missing');

    $mech->get_ok(
        '/series/cd58b3e5-371c-484e-b3fd-4084a6861e62/tags/downvote?tags=World Music, Jazz',
        'Downvoted tags "jazzy" and "bassy"',
    );
    $mech->get_ok(
        '/series/cd58b3e5-371c-484e-b3fd-4084a6861e62/tags',
        'Fetched the series tags page again',
    );
    html_ok($mech->content);
    $mech->content_contains(
        'world music',
        'Downvoted tag "world music" is present',
    );
    $mech->content_contains('jazz', 'Downvoted tag "jazz" is present');
};

1;
