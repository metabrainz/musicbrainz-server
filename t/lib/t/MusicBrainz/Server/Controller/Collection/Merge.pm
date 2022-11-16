package t::MusicBrainz::Server::Controller::Collection::Merge;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok test_xpath_html );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether collection merges work as intended, display the
expected user warnings, and makes sure merges can't happen in ways
that would cause issues (different types, users).

=cut

test 'Can merge collections' => sub {

    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+collection');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'editor1', password => 'pass' } );

    $mech->get_ok(
        '/collection/merge_queue?add-to-merge=3',
        'Added first collection to merge queue',
    );
    $mech->get_ok(
        '/collection/merge_queue?add-to-merge=4',
        'Added second collection to merge queue',
    );

    $mech->content_contains(
        'Some of these collections are public and some are private',
        'The user is told the privacy settings differ',
    );

    $mech->get_ok('/collection/merge', 'Fetched collection merge page');
    html_ok($mech->content);
    $mech->submit_form_ok(
        {
            with_fields => {
                'merge.target' => 3,
            },
        },
        'The form returned a 2xx response code',
    );

    ok(
        $mech->uri =~ qr{/collection/f34c079d-374e-4436-9448-da92dedef3c9},
        'The user is redirected to the destination collection after merging',
    );

    $mech->text_contains(
        'Public collection by editor1',
        'The destination collection is still public',
    );

    $mech->content_contains(
        'Copy of the Better Festival',
        'Event from merged collection was moved to destination collection',
    );

    my $tx = test_xpath_html($mech->content);
    $tx->is(
        'count(//div[@id="content"]/div[@class="collaborators"]/p/a)',
        '2',
        'There are two collaborators on the destination collection',
    );

    my $merged_added = $c->sql->select_single_value(
        'SELECT added FROM editor_collection_event WHERE collection = 3 AND event = 4'
    );
    ok(
        $merged_added eq '2014-11-05 03:00:13.359654+00',
        'The merged "added to collection" time is the oldest of both times',
    );

    my $merged_comment = $c->sql->select_single_value(
        'SELECT comment FROM editor_collection_event WHERE collection = 3 AND event = 4'
    );
    like(
        $merged_comment,
        qr{testy1},
        'Merged collection comment is on final collection comment',
    );
    like(
        $merged_comment,
        qr{testy2},
        'Destination collection comment is on final collection comment',
    );
};

test 'Can only merge collections of the same type' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+collection');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'editor1', password => 'pass' } );

    $mech->get_ok(
        '/collection/merge_queue?add-to-merge=1',
        'Added release collection to merge queue',
    );

    $mech->get_ok(
        '/collection/merge_queue?add-to-merge=3',
        'Added event collection to merge queue',
    );

    $mech->content_contains(
        'These collections are for different entity types',
        'The user is told the types differ',
    );

    my $tx = test_xpath_html($mech->content);
    $tx->ok(
        '//div[@id="content"]//button[@disabled]',
        'The submit button is disabled',
    );

    $mech->submit_form(
        with_fields => {
            'merge.target' => 3,
        }
    );

    is(
        $mech->status,
        500,
        'Attempting to force a merge anyway returns a 500 error',
    );

    $mech->content_contains(
        'Attempt to merge collections of different entity types',
        'The forced merge attempt was not allowed since types differ',
    );
};

test 'Can only merge own collections' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+collection');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'editor1', password => 'pass' } );

    $mech->get_ok(
        '/collection/merge_queue?add-to-merge=1',
        'Added own collection to merge queue',
    );

    $mech->get(
        '/collection/merge_queue?add-to-merge=2',
        q(Tried to add other editor's collection to merge queue),
    );
    is(
        $mech->status,
        403,
        q(Adding other editor's collection to merge queue is 403 Forbidden)
    );
};

1;
