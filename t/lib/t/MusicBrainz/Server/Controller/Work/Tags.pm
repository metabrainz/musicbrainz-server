package t::MusicBrainz::Server::Controller::Work::Tags;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether work tagging is working correctly. It checks both
up- and downvoting, plus withdrawing/removing tags. It also checks that
tagging is not allowed without a confirmed email address.

=cut

test 'Work tagging (up/downvoting, withdrawing)' => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c);

    $mech->get_ok(
        '/work/745c079d-374e-4436-9448-da92dedef3ce/tags',
        'Fetched the work tags page',
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
        '/work/745c079d-374e-4436-9448-da92dedef3ce/tags/upvote?tags=boring, classical',
        'Upvoted tags "boring" and "classical"',
    );
    $mech->get_ok(
        '/work/745c079d-374e-4436-9448-da92dedef3ce/tags',
        'Fetched the work tags page again',
    );
    html_ok($mech->content);
    $mech->content_contains('boring', 'Upvoted tag "boring" is present');
    $mech->content_contains(
        'classical',
        'Upvoted tag "classical" is present',
    );

    $mech->get_ok(
        '/work/745c079d-374e-4436-9448-da92dedef3ce/tags/withdraw?tags=boring, classical',
        'Withdrew tags "boring" and "classical"',
    );
    $mech->get_ok(
        '/work/745c079d-374e-4436-9448-da92dedef3ce/tags',
        'Fetched the work tags page again',
    );
    html_ok($mech->content);
    $mech->content_lacks('boring', 'Withdrawn tag "boring" is missing');
    $mech->content_lacks(
        'classical',
        'Withdrawn tag "classical" is missing',
    );

    $mech->get_ok(
        '/work/745c079d-374e-4436-9448-da92dedef3ce/tags/downvote?tags=boring, classical',
        'Downvoted tags "boring" and "classical"',
    );
    $mech->get_ok(
        '/work/745c079d-374e-4436-9448-da92dedef3ce/tags',
        'Fetched the work tags page again',
    );
    html_ok($mech->content);
    $mech->content_contains('boring', 'Downvoted tag "boring" is present');
    $mech->content_contains(
        'classical',
        'Downvoted tag "classical" is present',
    );
};

test 'Cannot tag without a confirmed email address' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $c->model('Editor')->insert({
        name => 'iwannatag',
        password => 'password'
    });

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'iwannatag', password => 'password' } );

    $mech->get('/work/745c079d-374e-4436-9448-da92dedef3ce/tags/upvote?tags=boring, classical');
    is ($mech->status, 401, 'Tag adding rejected without confirmed address');

    $mech->get('/work/745c079d-374e-4436-9448-da92dedef3ce/tags/downvote?tags=boring, classical');
    is ($mech->status, 401, 'Tag downvoting rejected without confirmed address');
};

1;
