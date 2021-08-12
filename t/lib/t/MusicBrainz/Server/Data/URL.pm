package t::MusicBrainz::Server::Data::URL;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::URL;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+url');

my $url_data = MusicBrainz::Server::Data::URL->new(c => $test->c);

my $url = $url_data->get_by_id(1);
is ( $url->id, 1 );
is ( $url->gid, '9201840b-d810-4e0f-bb75-c791205f5b24' );
is ( $url->url, 'http://musicbrainz.org/' );
is ( $url->edits_pending, 0 );

my $sql = $test->c->sql;
$sql->begin;

$url_data->update($url->id, {
    url => 'http://google.com',
});

$url = $url_data->get_by_id(1);
is ( $url->id, 1 );
is ( $url->gid, '9201840b-d810-4e0f-bb75-c791205f5b24' );
is ( $url->url, 'http://google.com/', 'URL was updated and normalized to add extra slash at end');

$url_data->update(2, {
    url => 'http://google.com',
});

is($url_data->get_by_gid('9b3c5c67-572a-4822-82a3-bdd3f35cf152')->id,
   $url_data->get_by_gid('9201840b-d810-4e0f-bb75-c791205f5b24')->id, 'both (equivalent) URLs were normalized the same, and were merged');


$sql->commit;

};

test find_or_insert => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+url');

    my $url_data = MusicBrainz::Server::Data::URL->new(c => $test->c);

    my $url1 = $url_data->find_or_insert('http://musicbrainz.org');
    is($url1->id, 1, 'Finds existing URL');
    is($url1->url, 'http://musicbrainz.org/', 'Existing URL is normalized even with non-normalized input');

    my $url2 = $url_data->find_or_insert('http://lalalalala.horse');
    ok($url2->id > 4, 'Inserted new url');
    is($url2->url, 'http://lalalalala.horse/', 'Normalized new URL');

};

1;
