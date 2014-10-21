package t::MusicBrainz::Server::Controller::Series::Tags;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $c->sql->do(q{
        INSERT INTO series_type (id, name, entity_type, parent, child_order, description)
        VALUES (1, 'Work', 'work', NULL, 3, '');

        INSERT INTO series_ordering_type (id, name, parent, child_order, description)
        VALUES (1, 'Automatic', NULL, 0, '');

        INSERT INTO link_attribute_type (id, root, parent, child_order, gid, name, description)
        VALUES (5, 1, NULL, 0, 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a', 'number', '');

        INSERT INTO link_text_attribute_type VALUES (5);

        INSERT INTO series (id, gid, name, comment, type, ordering_attribute, ordering_type)
        VALUES (1, 'cd58b3e5-371c-484e-b3fd-4084a6861e62', 'Test', '', 1, 5, 1);
    });

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    # Test tagging
    $mech->get_ok('/series/cd58b3e5-371c-484e-b3fd-4084a6861e62/tags');
    html_ok($mech->content);
    my $response = $mech->submit_form(
        with_fields => {
            'tag.tags' => 'World Music, Jazz',
        }
    );
    $mech->get_ok('/series/cd58b3e5-371c-484e-b3fd-4084a6861e62/tags');
    html_ok($mech->content);

    $mech->content_contains('world music');
    $mech->content_contains('jazz');
};

1;
