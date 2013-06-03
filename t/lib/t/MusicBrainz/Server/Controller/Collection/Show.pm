package t::MusicBrainz::Server::Controller::Collection::Show;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok test_xpath_html );
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
    my $tx = test_xpath_html ($mech->content);

    $tx->ok('//html:div[@id="content"]/html:div/html:p/html:span[@class="small"]/html:a[contains(@href,"/editor1/collections")]',
            'contains link');
    $tx->is('//html:div[@id="content"]/html:div/html:p/html:span[@class="small"]/html:a', "See all of your collections",
            'contains correct description');
};

test 'Collection view has link back to all collections (not yours)' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/collection/f34c079d-374e-4436-9448-da92dedef3cb');
    my $tx = test_xpath_html ($mech->content);

    $tx->ok('//html:div[@id="content"]/html:div/html:p/html:span[@class="small"]/html:a[contains(@href,"/editor2/collections")]',
            'contains link');
    $tx->is('//html:div[@id="content"]/html:div/html:p/html:span[@class="small"]/html:a', "See all of editor2's public collections",
            'contains correct description');
};

test 'Collection view includes description when there is one' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/collection/f34c079d-374e-4436-9448-da92dedef3cb');
    $mech->content_like(qr/Testy!/, 'description shows');
};

test 'Collection view does not include description when there is none' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/collection/f34c079d-374e-4436-9448-da92dedef3cd');
    my $tx = test_xpath_html ($mech->content);

    $tx->not_ok('//html:div[@id=collection]', 'no description element');

};


test 'Unknown collection' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get('/collection/f34c079d-374e-1337-1337-aaaaaaaaaaaa');
    is($mech->status, HTTP_NOT_FOUND);
};

1;
