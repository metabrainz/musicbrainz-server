package t::MusicBrainz::Server::Controller::Collection::Merge;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok test_xpath_html );

with 't::Mechanize', 't::Context';

test 'Can merge collections' => sub {

    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+collection');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'editor1', password => 'pass' } );

    $mech->get_ok('/collection/merge_queue?add-to-merge=3');
    $mech->get_ok('/collection/merge_queue?add-to-merge=4');

    $mech->get_ok('/collection/merge');
    html_ok($mech->content);
    $mech->submit_form(
        with_fields => {
            'merge.target' => 3,
        }
    );
    ok($mech->uri =~ qr{/collection/f34c079d-374e-4436-9448-da92dedef3c9});

    $mech->content_contains('Copy of the Better Festival', 'event was moved to destination collection');

    my $tx = test_xpath_html($mech->content);
    $tx->is('count(//div[@id="content"]/div[@class="collaborators"]/p/a)',
            '2', 'both collaborators are on the destination collection');

    my $merged_added = $c->sql->select_single_value(
        'SELECT added FROM editor_collection_event WHERE collection = 3 AND event = 4'
    );
    ok($merged_added eq '2014-11-05 03:00:13.359654+00', 'merged added value is oldest');

    my $merged_comment = $c->sql->select_single_value(
        'SELECT comment FROM editor_collection_event WHERE collection = 3 AND event = 4'
    );
    like($merged_comment, qr{testy1}, 'merged comment contains first comment');
    like($merged_comment, qr{testy2}, 'merged comment contains second comment');
};

test 'Can only merge collections of the same type' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+collection');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'editor1', password => 'pass' } );

    # Release collection
    $mech->get_ok('/collection/merge_queue?add-to-merge=1');

    # Event collection
    $mech->get_ok('/collection/merge_queue?add-to-merge=3');

    $mech->submit_form(
        with_fields => {
            'merge.target' => 3,
        }
    );

    $mech->content_contains('Attempt to merge collections of different entity types', 'merge was not allowed');
};

test 'Can only merge own collections' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+collection');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'editor1', password => 'pass' } );

    # Own collection, fine to add to merge
    $mech->get_ok('/collection/merge_queue?add-to-merge=1', 'can add own collection');

    # Someone else's collection, not allowed!
    $mech->get('/collection/merge_queue?add-to-merge=2');
    is($mech->status, 403, q(forbidden to add other editor's collection));
};

1;
