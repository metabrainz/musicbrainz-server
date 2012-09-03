package t::MusicBrainz::Server::Controller::Collection::New;
use Test::Routine;
use Test::More;
use Test::XPath;
use MusicBrainz::Server::Test qw( html_ok );
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
    $mech->field("edit-list.name", "Super collection");
    $mech->click();

    my $tx = Test::XPath->new( xml => $mech->content, is_html => 1 );
    $tx->is('//div[@id="content"]/div/h1/a', "Super collection",
            'contains collection name');
    $tx->is('count(//table[@class="tbl"]/tbody/tr)', "1", "one item in the table");

};

test 'Create collection with no release set does not add release' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/collection/create');
    # Second form is the new collection one
    $mech->form_number(2);
    $mech->field("edit-list.name", "mycollection");
    $mech->click();

    $mech->content_contains("No releases found in collection.");

    my $tx = Test::XPath->new( xml => $mech->content, is_html => 1 );
    $tx->is('//div[@id="content"]/div/h1/a', "mycollection",
            'contains collection name');
};

1;
