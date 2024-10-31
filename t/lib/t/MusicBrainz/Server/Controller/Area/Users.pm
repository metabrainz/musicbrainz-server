package t::MusicBrainz::Server::Controller::Area::Users;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Constants qw( $SPAMMER_FLAG );
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether the Users tab for an area correctly lists editors
who have their area set to it or to an area contained in it.

=cut

test 'MBS-6511: List of editors in the area' => sub {
    my $test = shift;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+area');

    $mech->get_ok(
        '/area/106e0bec-b638-3b37-b731-f53d507dc00e/users',
        'Fetched the area users page',
    );
    html_ok($mech->content);
    $mech->content_contains(
        'There are currently no users in this area',
        'The "no users" message appears when the list is empty',
    );

    $test->c->sql->do(q{
        INSERT INTO editor (area, name, password, ha1)
        VALUES (13, 'Editor 1', 'hunter2', '');
    });

    $mech->get_ok(
        '/area/106e0bec-b638-3b37-b731-f53d507dc00e/users',
        'Fetched the area users page again',
    );
    html_ok($mech->content);
    $mech->content_contains(
        'There is currently 1 user in this area',
        'The user count is correct after adding one editor',
    );
    $mech->content_contains('Editor 1', 'The added editor name is listed');

    $test->c->sql->do(q{
        INSERT INTO editor (id, area, name, password, ha1, email)
        VALUES (666, 13, 'Editor 2', 'hunter2', '', 'hunter2@hotmail.com');
    });

    $mech->get_ok(
        '/area/106e0bec-b638-3b37-b731-f53d507dc00e/users',
        'Fetched the area users page again',
    );
    html_ok($mech->content);
    $mech->content_contains(
        'There are currently 2 users in this area',
        'The user count is correct after adding a second editor',
    );
    $mech->content_contains('Editor 1', 'The previous editor is listed');
    $mech->content_contains('Editor 2', 'The added editor is also listed');

    $test->c->sql->do(q{
        INSERT INTO editor (id, area, name, password, ha1, email)
        VALUES (999, 5126, 'Editor 3', 'hunter2', '', 'hunter2@hotmail.com');
    });

    $mech->get_ok(
        '/area/106e0bec-b638-3b37-b731-f53d507dc00e/users',
        'Fetched the area users page again',
    );
    html_ok($mech->content);
    $mech->content_contains(
        'There are currently 3 users in this area',
        'The user count is correct after adding an editor to contained area',
    );
    $mech->content_contains('Editor 3', 'The added editor is also listed');

    $test->c->sql->do(qq{
        UPDATE editor SET privs = $SPAMMER_FLAG WHERE name = 'Editor 2';
    });

    $mech->get_ok(
        '/area/106e0bec-b638-3b37-b731-f53d507dc00e/users',
        'Fetched the area users page again',
    );
    html_ok($mech->content);
    $mech->content_contains(
        'There are currently 2 users in this area',
        'The user count is 1 lower after marking an editor as a spammer',
    );
    $mech->content_lacks(
        'Editor 2',
        'The spammer editor is no longer listed',
    );

    $test->c->sql->do(qq{
        UPDATE editor SET privs = $SPAMMER_FLAG WHERE name = 'Editor 3';
    });

    $mech->get_ok(
        '/area/106e0bec-b638-3b37-b731-f53d507dc00e/users',
        'Fetched the area users page again',
    );
    html_ok($mech->content);
    $mech->content_contains(
        'There is currently 1 user in this area',
        'The user count is 1 lower after marking another editor as a spammer',
    );
    $mech->content_lacks(
        'Editor 3',
        'The new spammer editor (from a contained area) is no longer listed',
    );
};

1;
