package t::MusicBrainz::Server::Controller::Label::Tags;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether label tagging is working correctly. It checks both
up- and downvoting, plus withdrawing/removing tags.

=cut

test 'Label tagging (up/downvoting, withdrawing)' => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c);

    $mech->get_ok(
        '/label/46f0f4cd-8aab-4b33-b698-f459faf64190/tags',
        'Fetched the label tags page',
    );
    html_ok($mech->content);
    $mech->content_contains('musical', 'The "musical" tag is present');
    ok(
        $mech->find_link(
        url_regex => qr{/tag/musical}),
        'There is a link to the "musical" tag',
    );

    $mech->get_ok('/login');
    $mech->submit_form(with_fields => {username => 'new_editor', password => 'password'});

    $mech->get_ok(
        '/label/46f0f4cd-8aab-4b33-b698-f459faf64190/tags/upvote?tags=British, Electronic%3F',
        'Upvoted tags "british" and "electronic?"',
    );
    $mech->get_ok(
        '/label/46f0f4cd-8aab-4b33-b698-f459faf64190/tags',
        'Fetched the label tags page again',
    );
    html_ok($mech->content);
    $mech->content_contains('british', 'Upvoted tag "british" is present');
    $mech->content_contains(
        'electronic?',
        'Upvoted tag "electronic?" is present',
    );

    $mech->get_ok(
        '/label/46f0f4cd-8aab-4b33-b698-f459faf64190/tags/withdraw?tags=British, Electronic%3F',
        'Withdrew tags "british" and "electronic?"',
    );
    $mech->get_ok(
        '/label/46f0f4cd-8aab-4b33-b698-f459faf64190/tags',
        'Fetched the label tags page again',
    );
    html_ok($mech->content);
    $mech->content_lacks('british', 'Withdrawn tag "british" is missing');
    $mech->content_lacks(
        'electronic?',
        'Withdrawn tag "electronic?" is missing',
    );

    $mech->get_ok(
        '/label/46f0f4cd-8aab-4b33-b698-f459faf64190/tags/downvote?tags=British, Electronic%3F',
        'Downvoted tags "british" and "electronic?"',
    );
    $mech->get_ok(
        '/label/46f0f4cd-8aab-4b33-b698-f459faf64190/tags',
        'Fetched the label tags page again',
    );
    html_ok($mech->content);
    $mech->content_contains('british', 'Downvoted tag "british" is present');
    $mech->content_contains(
        'electronic?',
        'Downvoted tag "electronic?" is present',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
