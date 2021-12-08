package t::MusicBrainz::Server::Controller::Instrument::Tags;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c);

    $test->c->sql->do(q{
        INSERT INTO instrument (id, gid, name)
        VALUES (5, '945c079d-374e-4436-9448-da92dedef3cf', 'Minimal Instrument');
    });

    $mech->get_ok('/instrument/945c079d-374e-4436-9448-da92dedef3cf/tags');
    html_ok($mech->content);
    $mech->content_contains('Nobody has tagged this yet');

    # Test tagging
    $mech->get_ok('/login');
    $mech->submit_form(with_fields => {username => 'new_editor', password => 'password'});

    # Test tagging
    $mech->get_ok('/instrument/945c079d-374e-4436-9448-da92dedef3cf/tags/upvote?tags=Jazzy, Bassy');
    $mech->get_ok('/instrument/945c079d-374e-4436-9448-da92dedef3cf/tags');
    html_ok($mech->content);
    $mech->content_contains('jazzy');
    $mech->content_contains('bassy');

    $mech->get_ok('/instrument/945c079d-374e-4436-9448-da92dedef3cf/tags/withdraw?tags=Jazzy, Bassy');
    $mech->get_ok('/instrument/945c079d-374e-4436-9448-da92dedef3cf/tags');
    html_ok($mech->content);
    $mech->content_lacks('jazzy');
    $mech->content_lacks('bassy');

    $mech->get_ok('/instrument/945c079d-374e-4436-9448-da92dedef3cf/tags/downvote?tags=Jazzy, Bassy');
    $mech->get_ok('/instrument/945c079d-374e-4436-9448-da92dedef3cf/tags');
    html_ok($mech->content);
    $mech->content_contains('jazzy');
    $mech->content_contains('bassy');
};

1;
