package t::MusicBrainz::Server::Controller::Collection::Show;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Constants qw( :edit_status );
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
    my $tx = test_xpath_html($mech->content);

    $tx->ok('//div[@id="content"]/div/p/span[@class="small"]/a[contains(@href,"/editor1/collections")]',
            'contains link');
    $tx->is('//div[@id="content"]/div/p/span[@class="small"]/a', 'See all of your collections',
            'contains correct description');
};

test 'Collection view has link back to all collections (not yours)' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/collection/f34c079d-374e-4436-9448-da92dedef3cb');
    my $tx = test_xpath_html($mech->content);

    $tx->ok('//div[@id="content"]/div/p/span[@class="small"]/a[contains(@href,"/editor2/collections")]',
            'contains link');
    $tx->is('//div[@id="content"]/div/p/span[@class="small"]/a', q(See all of editor2's public collections),
            'contains correct description');
};

test 'Collection view includes description when there is one' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/collection/f34c079d-374e-4436-9448-da92dedef3cb');
    $mech->content_like(qr/Testy!/, 'collection description of beginner/limited user shows for logged-in user');

    $mech->get('/logout');

    $mech->get_ok('/collection/f34c079d-374e-4436-9448-da92dedef3cb');
    my $tx = test_xpath_html($mech->content);
    $tx->not_ok('//div[@id=collection]/p[@class=deleted and starts-with(text(), "This content is hidden to prevent spam.")]',
        'collection description of beginner/limited user hides for not-logged-in user');

    $test->c->sql->do(<<~"SQL");
        INSERT INTO edit (id, editor, type, status, expire_time, autoedit)
            VALUES (11, 2, 1, $STATUS_APPLIED, now(), 0),
                   (12, 2, 1, $STATUS_APPLIED, now(), 0),
                   (13, 2, 1, $STATUS_APPLIED, now(), 0),
                   (14, 2, 1, $STATUS_APPLIED, now(), 0),
                   (15, 2, 1, $STATUS_APPLIED, now(), 0),
                   (16, 2, 1, $STATUS_APPLIED, now(), 0),
                   (17, 2, 1, $STATUS_APPLIED, now(), 0),
                   (18, 2, 1, $STATUS_APPLIED, now(), 0),
                   (19, 2, 1, $STATUS_APPLIED, now(), 0),
                   (20, 2, 1, $STATUS_APPLIED, now(), 0);
        UPDATE editor SET member_since = '2007-07-23' WHERE id = 2;
        SQL

    $mech->get_ok('/collection/f34c079d-374e-4436-9448-da92dedef3cb');
    $mech->content_like(qr/Testy!/, 'collection description of (not beginner/limited) user shows for everyone');
};

test 'Collection view does not include description when there is none' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get_ok('/collection/f34c079d-374e-4436-9448-da92dedef3cd');
    my $tx = test_xpath_html($mech->content);

    $tx->not_ok('//div[@id=collection]', 'no description element');

};

test 'Private collection pages are private' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get('/collection/a34c079d-374e-4436-9448-da92dedef3cb');
    is($mech->status, 403, 'main collection page is private');
    $mech->get('/collection/a34c079d-374e-4436-9448-da92dedef3cb/subscribers');
    is($mech->status, 403, 'subscribers page is private');

    $mech->get('/collection/f34c079d-374e-4436-9448-da92dedef3cd');
    is($mech->status, 200, 'main collection page is visible to owner');
    $mech->get('/collection/f34c079d-374e-4436-9448-da92dedef3cd/subscribers');
    is($mech->status, 200, 'subscribers page is visible to owner');

    $mech->get('/collection/a34c079d-374e-4436-9448-da92dedef3ce');
    is($mech->status, 200, 'main collection page is visible to collaborator');
    $mech->get('/collection/a34c079d-374e-4436-9448-da92dedef3ce/subscribers');
    is($mech->status, 200, 'subscribers page is visible to collaborator');
};

test 'Unknown collection' => sub {
    my $test = shift;
    my $mech = $test->mech;

    $mech->get('/collection/f34c079d-374e-1337-1337-aaaaaaaaaaaa');
    is($mech->status, HTTP_NOT_FOUND);
};

1;
