package t::MusicBrainz::Server::Controller::User::Ratings;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
    INSERT INTO artist (id, gid, name, sort_name)
        VALUES (7, 'b9d99e40-72d7-11de-8a39-0800200c9a66', 'Kate Bush', 'Kate Bush');
    TRUNCATE artist_rating_raw CASCADE;
    INSERT INTO artist_rating_raw (artist, editor, rating) VALUES (7, 1, 80);
    SQL

$mech->get('/user/new_editor/ratings');
$mech->content_contains('Kate Bush', 'new_editor has rated Kate Bush');

$mech->get('/user/alice/ratings');
is ($mech->status(), 403, q(alice's ratings are private));

$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get('/user/alice/ratings');
is ($mech->status(), 403, q(alice's ratings are still private));

$mech->get('/logout');
$mech->get('/login');
$mech->submit_form( with_fields => { username => 'alice', password => 'secret1' } );

$mech->get('/user/alice/ratings');
is ($mech->status(), 200, 'alice can view her own ratings');
$mech->content_contains('Alice has not rated anything', 'alice has not rated anything');

};

1;
