package t::MusicBrainz::Server::Controller::Event::Tags;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether event tagging is working correctly. It checks both
up- and downvoting, plus withdrawing/removing tags.

=cut

test 'Event tagging (up/downvoting, withdrawing)' => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c);

    $mech->get_ok(
        '/event/ca1d24c1-1999-46fd-8a95-3d4108df5cb2/tags',
        'Fetched the event tags page',
    );
    html_ok($mech->content);
    $mech->content_contains(
        'Nobody has tagged this yet',
        'The "not tagged yet" message is present',
    );

    $mech->get_ok('/login');
    $mech->submit_form(
        with_fields => {username => 'new_editor', password => 'password'},
    );

    $mech->get_ok(
        '/event/ca1d24c1-1999-46fd-8a95-3d4108df5cb2/tags/upvote?tags=Broken, Fixmeplz',
        'Upvoted tags "broken" and "fixmeplz"',
    );
    $mech->get_ok(
        '/event/ca1d24c1-1999-46fd-8a95-3d4108df5cb2/tags',
        'Fetched the event tags page again',
    );
    html_ok($mech->content);
    $mech->content_contains('broken', 'Upvoted tag "broken" is present');
    $mech->content_contains('fixmeplz', 'Upvoted tag "fixmeplz" is present');

    $mech->get_ok(
        '/event/ca1d24c1-1999-46fd-8a95-3d4108df5cb2/tags/withdraw?tags=Broken, Fixmeplz',
        'Withdrew tags "broken" and "fixmeplz"',
    );
    $mech->get_ok(
        '/event/ca1d24c1-1999-46fd-8a95-3d4108df5cb2/tags',
        'Fetched the event tags page again',
    );
    html_ok($mech->content);
    $mech->content_lacks('broken', 'Withdrawn tag "broken" is missing');
    $mech->content_lacks('fixmeplz', 'Withdrawn tag "fixmeplz" is missing');

    $mech->get_ok(
        '/event/ca1d24c1-1999-46fd-8a95-3d4108df5cb2/tags/downvote?tags=Broken, Fixmeplz',
        'Downvoted tags "broken" and "fixmeplz"',
    );
    $mech->get_ok(
        '/event/ca1d24c1-1999-46fd-8a95-3d4108df5cb2/tags',
        'Fetched the event tags page again',
    );
    html_ok($mech->content);
    $mech->content_contains('broken', 'Downvoted tag "broken" is present');
    $mech->content_contains(
        'fixmeplz',
        'Downvoted tag "fixmeplz" is present',
    );

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
