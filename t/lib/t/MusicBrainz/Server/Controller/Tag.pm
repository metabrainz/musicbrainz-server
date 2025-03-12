package t::MusicBrainz::Server::Controller::Tag;
use utf8;
use strict;
use warnings;

use HTTP::Status qw( :constants );
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Test qw( html_ok );

with 't::Context', 't::Mechanize';

test 'Can view tags' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c);

    $test->mech->get_ok('/tag/musical');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Tag .musical.});

    $test->mech->get_ok('/tag/musical/artist');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Test Artist});
    $test->mech->get_ok('/tag/not-used/artist');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{0 artists found});

    $test->mech->get_ok('/tag/musical/label');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Warp Records});
    $test->mech->get_ok('/tag/not-used/label');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{0 labels found});

    $test->mech->get_ok('/tag/musical/recording');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Dancing Queen.*?ABBA});
    $test->mech->get_ok('/tag/not-used/recording');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{0 recordings found});

    $test->mech->get_ok('/tag/musical/release-group');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Arrival.*?ABBA});
    $test->mech->get_ok('/tag/not-used/release-group');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{0 release groups found});

    $test->mech->get_ok('/tag/musical/work');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Dancing Queen});
    $test->mech->get_ok('/tag/not-used/work');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{0 works found});

    $test->mech->get('/tag/not-found');
    html_ok($test->mech->content);
    is($test->mech->status(), HTTP_NOT_FOUND);

    $test->mech->get_ok('/tag/hip-hop%2Frap/');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Tag “hip-hop/rap”}, 'contains hip-hop/rap tag');
};

test 'Deleting user tags works as expected' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok(
        '/user/editor1/tag/rock',
        'Fetched the user page for "rock" upvotes',
    );

    $test->mech->content_contains(
        '1 entity found',
        'The user has tagged one entity as "rock"',
    );

    $mech->get_ok(
        '/tag/rock/delete',
        'Fetched the delete page for "rock" upvotes',
    );

    $test->mech->content_contains(
        'Delete all my upvotes of “rock”',
        'Has the correct delete button message',
    );

    $mech->submit_form_ok(
        {form_number => 2},
        'The form returned a 2xx response code',
    );

    $mech->get_ok(
        '/user/editor1/tag/rock',
        'Fetched the user page for "rock" upvotes again',
    );

    $test->mech->content_contains(
        '0 entities found',
        'The user no longer has any entities tagged as "rock"',
    );

    $mech->get_ok(
        '/user/editor1/tag/rock?show_downvoted=1',
        'Fetched the user page for "rock" downvotes',
    );

    $test->mech->content_contains(
        '1 entity found',
        'The downvote for "rock" was not affected',
    );

    $mech->get_ok(
        '/tag/rock/delete?delete_downvoted=1',
        'Fetched the delete page for "rock" downvotes',
    );

    $test->mech->content_contains(
        'Delete all my downvotes of “rock”',
        'Has the correct delete button message',
    );

    $mech->submit_form_ok(
        {form_number => 2},
        'The form returned a 2xx response code',
    );

    $mech->get_ok(
        '/user/editor1/tag/rock?show_downvoted=1',
        'Fetched the user page for "rock" downvotes',
    );

    $test->mech->content_contains(
        '0 entities found',
        'The downvote for "rock" is now gone',
    );
};

test 'Editing user tags works as expected' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok(
        '/user/editor1/tag/musical',
        'Fetched the user page for "musical" upvotes',
    );

    $test->mech->content_contains(
        '2 entities found',
        'The user has tagged two entities as "musical"',
    );

    $mech->get_ok(
        '/user/editor1/tag/rock',
        'Fetched the user page for "rock" upvotes',
    );

    $test->mech->content_contains(
        '1 entity found',
        'The user has tagged one entity as "rock"',
    );

    $mech->get_ok(
        '/user/editor1/tag/rock?show_downvoted=1',
        'Fetched the user page for "rock" downvotes',
    );

    $test->mech->content_contains(
        '1 entity found',
        'The user has downvoted "rock" once',
    );

    $mech->get_ok(
        '/user/editor1/tag/song',
        'Fetched the user page for "song" upvotes',
    );

    $test->mech->content_contains(
        '0 entities found',
        'The user has not tagged any entities as "song"',
    );

    $mech->get_ok(
        '/tag/musical/move',
        'Fetched the move page for "musical"',
    );

    $mech->submit_form_ok(
        { with_fields => { 'move-tag.tags' => 'rock, song' } },
        'The form returned a 2xx response code',
    );

    $mech->get_ok(
        '/user/editor1/tag/musical',
        'Fetched the user page for "musical" upvotes again',
    );

    $test->mech->content_contains(
        '0 entities found',
        'There are no entities tagged "musical" after moving the tag',
    );

    $mech->get_ok(
        '/user/editor1/tag/rock',
        'Fetched the user page for "rock" upvotes again',
    );

    $test->mech->content_contains(
        '2 entities found',
        'There are two entities tagged as "rock" now (one was added by move)',
    );

    $mech->get_ok(
        '/user/editor1/tag/rock?show_downvoted=1',
        'Fetched the user page for "rock" downvotes again',
    );

    $test->mech->content_contains(
        '0 entities found',
        'Moving an upvote to "rock" replaced the previous downvote (now 0)',
    );

    $mech->get_ok(
        '/user/editor1/tag/song',
        'Fetched the user page for "song" upvotes again',
    );

    $test->mech->content_contains(
        '2 entities found',
        'The move means two entities are now tagged as "song"',
    );
};

sub prepare_test {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+tag');
    MusicBrainz::Server::Test->prepare_test_database(
        $test->c,
        '+tag_changes',
    );

    $test->mech->get('/login');
    $test->mech->submit_form(
        with_fields => { username => 'editor1', password => 'password' },
    );
}

1;
