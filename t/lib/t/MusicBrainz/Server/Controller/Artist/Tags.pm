package t::MusicBrainz::Server::Controller::Artist::Tags;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether artist tagging is working correctly. It checks both
up- and downvoting, plus withdrawing/removing tags.

=cut

test 'Test artist tagging (up/downvoting, withdrawing)' => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database(
        $test->c,
        '+controller_artist',
    );

    $mech->get_ok(
        '/artist/745c079d-374e-4436-9448-da92dedef3ce/tags',
        'Fetched the artist tags page',
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

    $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/tags/upvote?tags=World Music, Jazz');
    $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/tags');
    html_ok($mech->content);
    $mech->content_contains(
        'world music',
        'Upvoted tag "world music" is present',
    );
    $mech->content_contains('jazz', 'Upvoted tag "jazz" is present');

    $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/tags/withdraw?tags=World Music, Jazz');
    $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/tags');
    html_ok($mech->content);
    $mech->content_lacks(
        'world music',
        'Withdrawn tag "world music" is missing',
    );
    $mech->content_lacks('jazz', 'Withdrawn tag "jazz" is missing');

    $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/tags/downvote?tags=World Music, Jazz');
    $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/tags');
    html_ok($mech->content);
    $mech->content_contains(
        'world music',
        'Downvoted tag "world music" is present',
    );
    $mech->content_contains('jazz', 'Downvoted tag "jazz" is present');
};

1;
