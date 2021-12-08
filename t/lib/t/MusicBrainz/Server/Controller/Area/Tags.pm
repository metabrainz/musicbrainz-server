package t::MusicBrainz::Server::Controller::Area::Tags;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c);

    $mech->get_ok('/area/489ce91b-6658-3307-9877-795b68554c98/tags');
    html_ok($mech->content);
    $mech->content_contains('Nobody has tagged this yet');

    # Test tagging
    $mech->get_ok('/login');
    $mech->submit_form(with_fields => {username => 'new_editor', password => 'password'});

    $mech->get_ok('/area/489ce91b-6658-3307-9877-795b68554c98/tags/upvote?tags=Broken, Fixmeplz');
    $mech->get_ok('/area/489ce91b-6658-3307-9877-795b68554c98/tags');
    html_ok($mech->content);
    $mech->content_contains('broken');
    $mech->content_contains('fixmeplz');

    $mech->get_ok('/area/489ce91b-6658-3307-9877-795b68554c98/tags/withdraw?tags=Broken, Fixmeplz');
    $mech->get_ok('/area/489ce91b-6658-3307-9877-795b68554c98/tags');
    html_ok($mech->content);
    $mech->content_lacks('broken');
    $mech->content_lacks('fixmeplz');

    $mech->get_ok('/area/489ce91b-6658-3307-9877-795b68554c98/tags/downvote?tags=Broken, Fixmeplz');
    $mech->get_ok('/area/489ce91b-6658-3307-9877-795b68554c98/tags');
    html_ok($mech->content);
    $mech->content_contains('broken');
    $mech->content_contains('fixmeplz');
};

1;
