package t::MusicBrainz::Server::Controller::Area::Tags;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    # Test tagging
    $mech->get_ok('/area/489ce91b-6658-3307-9877-795b68554c98/tags');
    html_ok($mech->content);
    my $response = $mech->submit_form(
        with_fields => {
            'tag.tags' => 'Broken, Fixme',
        }
    );
    $mech->get_ok('/area/489ce91b-6658-3307-9877-795b68554c98/tags');
    html_ok($mech->content);

    $mech->content_contains('broken');
    $mech->content_contains('fixme');
};

1;
