package t::MusicBrainz::Server::Controller::Collection::Show;
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

test 'Collection view has link back to all collections (signed in)' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/collection/f34c079d-374e-4436-9448-da92dedef3cd');
    my $tx = Test::XPath->new( xml => $mech->content, is_html => 1 );
    $tx->ok('//div[@id="content"]/div/p/span[@class="small"]/a[contains(@href,"/editor1/collections")]',
            'contains link');
    $tx->is('//div[@id="content"]/div/p/span[@class="small"]/a', "See all of your collections",
            'contains correct description');
};

test 'Collection view has link back to all collections (not yours)' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/collection/f34c079d-374e-4436-9448-da92dedef3cb');
    my $tx = Test::XPath->new( xml => $mech->content, is_html => 1 );
    $tx->ok('//div[@id="content"]/div/p/span[@class="small"]/a[contains(@href,"/editor2/collections")]',
            'contains link');
    $tx->is('//div[@id="content"]/div/p/span[@class="small"]/a', "See all of editor2's public collections",
            'contains correct description');
};

test 'Unknown collection' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get('/collection/f34c079d-374e-1337-1337-aaaaaaaaaaaa');
    is($mech->status, HTTP_NOT_FOUND);
};


test 'Images are present for some releases' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/collection/f34c079d-374e-4436-9448-da92dedef3cb');
    my $tx = Test::XPath->new( xml => $mech->content, is_html => 1 );
    $tx->is('/descendant-or-self::div[@class="collection-image"][1]//img/@src', 'http://ecx.images-amazon.com/images/I/41KMH1VE7XL.jpg',
        'contains image pointing to amazon');
    $tx->is('/descendant-or-self::div[@class="collection-image"][2]//img/@src',
        'http://coverartarchive.org/release/c34c079d-374e-4436-9448-da92dedef3ce/1-500.jpg',
        'contains image pointing to CAA');
};

1;
