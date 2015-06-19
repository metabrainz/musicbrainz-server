package t::MusicBrainz::Server::Controller::Artist::Tags;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+controller_artist');

    $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/tags');
    html_ok($mech->content);
    $mech->content_contains('musical');
    ok($mech->find_link(url_regex => qr{/tag/musical}), 'content links to the "musical" tag');

    # Test tagging
    $mech->get_ok('/login');
    $mech->submit_form(with_fields => {username => 'new_editor', password => 'password'});

    # Test tagging
    $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/tags/upvote?tags=World Music, Jazz');
    $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/tags');
    html_ok($mech->content);
    $mech->content_contains('world music');
    $mech->content_contains('jazz');

    $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/tags/withdraw?tags=World Music, Jazz');
    $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/tags');
    html_ok($mech->content);
    $mech->content_lacks('world music');
    $mech->content_lacks('jazz');

    $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/tags/downvote?tags=World Music, Jazz');
    $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/tags');
    html_ok($mech->content);
    $mech->content_contains('world music');
    $mech->content_contains('jazz');
};

1;
