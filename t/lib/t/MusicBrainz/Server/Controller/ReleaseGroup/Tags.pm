package t::MusicBrainz::Server::Controller::ReleaseGroup::Tags;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c);

    $mech->get_ok('/release-group/7c3218d7-75e0-4e8c-971f-f097b6c308c5/tags');
    html_ok($mech->content);
    $mech->content_contains('Nobody has tagged this yet');

    # Test tagging
    $mech->get_ok('/login');
    $mech->submit_form(with_fields => {username => 'new_editor', password => 'password'});

    $mech->get_ok('/release-group/7c3218d7-75e0-4e8c-971f-f097b6c308c5/tags/upvote?tags=Art Rock, Progressive Rock');
    $mech->get_ok('/release-group/7c3218d7-75e0-4e8c-971f-f097b6c308c5/tags');
    html_ok($mech->content);
    $mech->content_contains('art rock');
    $mech->content_contains('progressive rock');

    $mech->get_ok('/release-group/7c3218d7-75e0-4e8c-971f-f097b6c308c5/tags/withdraw?tags=Art Rock, Progressive Rock');
    $mech->get_ok('/release-group/7c3218d7-75e0-4e8c-971f-f097b6c308c5/tags');
    html_ok($mech->content);
    $mech->content_lacks('art rock');
    $mech->content_lacks('progressive rock');

    $mech->get_ok('/release-group/7c3218d7-75e0-4e8c-971f-f097b6c308c5/tags/downvote?tags=Art Rock, Progressive Rock');
    $mech->get_ok('/release-group/7c3218d7-75e0-4e8c-971f-f097b6c308c5/tags');
    html_ok($mech->content);
    $mech->content_contains('art rock');
    $mech->content_contains('progressive rock');
};

1;
