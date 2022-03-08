package t::MusicBrainz::Server::Controller::Area::Tags;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether area tagging is working correctly. It checks both
up- and downvoting, plus withdrawing/removing tags.

=cut

test 'Test area tagging (up/downvoting, withdrawing)' => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c);

    $mech->get_ok(
        '/area/489ce91b-6658-3307-9877-795b68554c98/tags',
        'Fetched the area tags page',
    );
    html_ok($mech->content);
    $mech->content_contains(
        'Nobody has tagged this yet',
        'The "not tagged yet" message is present',
    );

    $mech->get_ok('/login');
    $mech->submit_form(with_fields => {username => 'new_editor', password => 'password'});

    $mech->get_ok(
        '/area/489ce91b-6658-3307-9877-795b68554c98/tags/upvote?tags=Broken, Fixmeplz',
        'Upvoted tags "broken" and "fixmeplz"',
    );
    $mech->get_ok(
        '/area/489ce91b-6658-3307-9877-795b68554c98/tags',
        'Fetched the area tags page again',
    );
    html_ok($mech->content);
    $mech->content_contains('broken', 'Upvoted tag "broken" is present');
    $mech->content_contains('fixmeplz', 'Upvoted tag "fixmeplz" is present');

    $mech->get_ok(
        '/area/489ce91b-6658-3307-9877-795b68554c98/tags/withdraw?tags=Broken, Fixmeplz',
        'Withdrew tags "broken" and "fixmeplz"',
    );
    $mech->get_ok(
        '/area/489ce91b-6658-3307-9877-795b68554c98/tags',
        'Fetched the area tags page again',
    );
    html_ok($mech->content);
    $mech->content_lacks('broken', 'Withdrawn tag "broken" is missing');
    $mech->content_lacks('fixmeplz', 'Withdrawn tag "fixmeplz" is missing');

    $mech->get_ok(
        '/area/489ce91b-6658-3307-9877-795b68554c98/tags/downvote?tags=Broken, Fixmeplz',
        'Downvoted tags "broken" and "fixmeplz"',
    );
    $mech->get_ok(
        '/area/489ce91b-6658-3307-9877-795b68554c98/tags',
        'Fetched the area tags page again',
    );
    html_ok($mech->content);
    $mech->content_contains('broken', 'Downvoted tag "broken" is present');
    $mech->content_contains(
        'fixmeplz',
        'Downvoted tag "fixmeplz" is present',
    );

};

1;
