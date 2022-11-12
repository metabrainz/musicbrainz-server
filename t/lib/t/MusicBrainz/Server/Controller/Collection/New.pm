package t::MusicBrainz::Server::Controller::Collection::New;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( test_xpath_html );
use HTTP::Status qw( :constants );

around run_test => sub {
    my ($orig, $test, @args) = @_;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+collection');

    $test->mech->get('/login');
    $test->mech->submit_form( with_fields => { username => 'editor1', password => 'pass' } );

    $test->$orig(@args);
};

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks collection creation, with and without seeded entities,
including the addition of collaborators.

=cut

my $collection_page_regexp = qr{/collection/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})};

test 'Create collection from release page adds the new release' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok(
        '/release/f34c079d-374e-4436-9448-da92dedef3ce',
        'Fetched a release page',
    );
    $mech->follow_link_ok(
        { text => 'Add to a new collection' },
        'Could find and follow the "Add to new collection" link',
    );
    ok(
        $mech->uri =~ qr{/collection/create\?release=1},
        'Got to the collection create page with a seeded release id',
    );

    my $tx = test_xpath_html($mech->content);
    $tx->ok(
        '//select[@id="id-edit-list.type_id"]/option[@value=1]',
        'The release collection type is available for selection',
    );
    $tx->not_ok(
        '//select[@id="id-edit-list.type_id"]/option[@value=4]',
        'The event collection type is not available for selection',
    );

    # Second form is the new collection one
    $mech->form_number(2);
    $mech->field('edit-list.name', 'Super collection');
    $mech->field('edit-list.description', '');
    $mech->click_ok(undef, 'Clicked the "Create collection" button');

    ok(
        $mech->uri =~ $collection_page_regexp,
        'The user is redirected to the collection page after creation',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        '//div[@id="content"]/div/h1/a',
        'Super collection',
        'The header contains the entered collection name',
    );
    $tx->is(
        'count(//table[@class="tbl"]/tbody/tr)',
        '1',
        'There one item in the collection contents table',
    );
    $mech->content_contains(
        'Arrival',
        'The release title is displayed on the collection page',
    );
    $mech->content_contains(
        '/release/f34c079d-374e-4436-9448-da92dedef3ce',
        'There is a link to the release from the collection page',
    );

    $mech->get_ok(
        '/release/f34c079d-374e-4436-9448-da92dedef3ce',
        'Fetched the release page again',
    );
    $mech->content_contains(
        'Remove from Super collection',
        'The release page contains a link to remove it from the collection',
    );
};

test 'Create collection without any entities preselected' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok(
        '/collection/create',
        'Fetched the collection creation page',
    );

    my $tx = test_xpath_html($mech->content);
    $tx->ok(
        '//select[@id="id-edit-list.type_id"]/option[@value=1]',
        'The release collection type is available for selection',
    );
    $tx->ok(
        '//select[@id="id-edit-list.type_id"]/option[@value=4]',
        'The event collection type is also available for selection',
    );

    # Second form is the new collection one
    $mech->form_number(2);
    $mech->field('edit-list.name', 'mycollection');
    $mech->field('edit-list.description', '');
    $mech->click_ok(undef, 'Clicked the "Create collection" button');

    ok(
        $mech->uri =~ $collection_page_regexp,
        'The user is redirected to the collection page after creation',
    );

    $mech->content_contains(
        'This collection is empty.',
        'The page indicates the collection is empty',
    );

    $tx = test_xpath_html($mech->content);
    $tx->is(
        '//div[@id="content"]/div/h1/a',
        'mycollection',
        'The header contains the entered collection name',
    );
    $tx->not_ok(
        '//div[@id="content"]/div[@class="collaborators"]/h2',
        'The collaborators section heading is missing since there are none',
    );
};

test 'Create collection with collaborators' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok(
        '/collection/create',
        'Fetched the collection creation page',
    );

    # Second form is the new collection one
    $mech->form_number(2);
    $mech->field('edit-list.name', 'mycollection');
    $mech->field('edit-list.description', '');
    $mech->field('edit-list.collaborators.0.id', '3');
    $mech->click_ok(
        undef,
        'Clicked the "Create collection" button after entering a collaborator',
    );

    ok(
        $mech->uri =~ $collection_page_regexp,
        'The user is redirected to the collection page after creation',
    );

    my $tx = test_xpath_html($mech->content);
    $tx->is(
        '//div[@id="content"]/div[@class="collaborators"]/h2',
        'Collaborators',
        'The collaborators section heading is present',
    );
    $tx->is(
        '//div[@id="content"]/div[@class="collaborators"]/p/a',
        'editor3',
        'The collaborator name is displayed',
    );
};

1;
