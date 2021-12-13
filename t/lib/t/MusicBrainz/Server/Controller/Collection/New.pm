package t::MusicBrainz::Server::Controller::Collection::New;
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

test 'Create collection from release page adds the new release' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/release/f34c079d-374e-4436-9448-da92dedef3ce');
    $mech->follow_link(text => 'Add to a new collection');

    $mech->form_number(2);
    $mech->field('edit-list.name', 'Super collection');
    $mech->field('edit-list.description', '');
    $mech->click();

    my $tx = test_xpath_html($mech->content);
    $tx->is('//div[@id="content"]/div/h1/a',
            'Super collection', 'contains collection name');
    $tx->is('count(//table[@class="tbl"]/tbody/tr)',
            '1', 'one item in the table');

    $mech->get_ok('/release/f34c079d-374e-4436-9448-da92dedef3ce');
    $mech->content_contains('Remove from Super collection');
};

test 'Create collection with no release set does not add release' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/collection/create');
    # Second form is the new collection one
    $mech->form_number(2);
    $mech->field('edit-list.name', 'mycollection');
    $mech->field('edit-list.description', '');
    $mech->click();

    $mech->content_contains('This collection is empty.');

    my $tx = test_xpath_html($mech->content);
    $tx->is('//div[@id="content"]/div/h1/a', 'mycollection',
            'contains collection name');
};

test 'Create collection with collaborators works' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/collection/create');
    # Second form is the new collection one
    $mech->form_number(2);
    $mech->field('edit-list.name', 'mycollection');
    $mech->field('edit-list.description', '');
    $mech->field('edit-list.collaborators.0.id', '3');
    $mech->click();

    my $tx = test_xpath_html($mech->content);
    $tx->is('//div[@id="content"]/div[@class="collaborators"]/p/a', 'editor3',
            'contains collaborator');
};

1;
