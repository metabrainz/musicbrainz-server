package t::MusicBrainz::Server::Controller::Area::Users;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether the Users tab for an area correctly lists editors
who have their area set to it.

=cut

test 'MBS-6511: List of editors in the area' => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c);

    $mech->get_ok('/area/489ce91b-6658-3307-9877-795b68554c98/users');
    html_ok($mech->content);
    $mech->content_contains(
        'There are currently no users in this area',
        'The "no users" message appears when the list is empty',
    );

    $test->c->sql->do(q{
        INSERT INTO editor (area, name, password, ha1)
        VALUES (222, 'Editor 1', 'hunter2', '');
    });

    $mech->get_ok('/area/489ce91b-6658-3307-9877-795b68554c98/users');
    html_ok($mech->content);
    $mech->content_contains(
        'There is currently 1 user in this area',
        'The user count is correct after adding one editor',
    );
    $mech->content_contains('Editor 1', 'The added editor name is listed');

    $test->c->sql->do(q{
        INSERT INTO editor (id, area, name, password, ha1, email)
        VALUES (666, 222, 'Editor 2', 'hunter2', '', 'hunter2@hotmail.com');
    });

    $mech->get_ok('/area/489ce91b-6658-3307-9877-795b68554c98/users');
    html_ok($mech->content);
    $mech->content_contains(
        'There are currently 2 users in this area',
        'The user count is correct after adding a second editor',
    );
    $mech->content_contains('Editor 1', 'The previous editor is listed');
    $mech->content_contains('Editor 2', 'The added editor is also listed');
};

1;
