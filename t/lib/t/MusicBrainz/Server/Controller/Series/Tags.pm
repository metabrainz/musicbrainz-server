package t::MusicBrainz::Server::Controller::Series::Tags;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c);

    $test->c->sql->do(q{
        INSERT INTO link_attribute_type (id, root, parent, child_order, gid, name, description)
        VALUES (5, 1, NULL, 0, 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a', 'number', '');

        INSERT INTO link_text_attribute_type VALUES (5);

        INSERT INTO series (id, gid, name, comment, type, ordering_attribute, ordering_type)
        VALUES (1, 'cd58b3e5-371c-484e-b3fd-4084a6861e62', 'Test', '', 4, 5, 1);
    });

    $mech->get_ok('/series/cd58b3e5-371c-484e-b3fd-4084a6861e62/tags');
    html_ok($mech->content);
    $mech->content_contains('Nobody has tagged this yet');

    # Test tagging
    $mech->get_ok('/login');
    $mech->submit_form(with_fields => {username => 'new_editor', password => 'password'});

    $mech->get_ok('/series/cd58b3e5-371c-484e-b3fd-4084a6861e62/tags/upvote?tags=World Music, Jazz');
    $mech->get_ok('/series/cd58b3e5-371c-484e-b3fd-4084a6861e62/tags');
    html_ok($mech->content);
    $mech->content_contains('world music');
    $mech->content_contains('jazz');

    $mech->get_ok('/series/cd58b3e5-371c-484e-b3fd-4084a6861e62/tags/withdraw?tags=World Music, Jazz');
    $mech->get_ok('/series/cd58b3e5-371c-484e-b3fd-4084a6861e62/tags');
    html_ok($mech->content);
    $mech->content_lacks('world music');
    $mech->content_lacks('jazz');

    $mech->get_ok('/series/cd58b3e5-371c-484e-b3fd-4084a6861e62/tags/downvote?tags=World Music, Jazz');
    $mech->get_ok('/series/cd58b3e5-371c-484e-b3fd-4084a6861e62/tags');
    html_ok($mech->content);
    $mech->content_contains('world music');
    $mech->content_contains('jazz');
};

1;
