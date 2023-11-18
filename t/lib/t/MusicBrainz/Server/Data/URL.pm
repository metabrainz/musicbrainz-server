package t::MusicBrainz::Server::Data::URL;
use strict;
use warnings;

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
    url => 'http://link.example',
});

$url = $url_data->get_by_id(1);
is ( $url->id, 1 );
is ( $url->gid, '9201840b-d810-4e0f-bb75-c791205f5b24' );
is ( $url->url, 'http://link.example/', 'URL was updated and normalized to add extra slash at end');

$url_data->update(2, {
    url => 'http://link.example',
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

test 'MBS-13372: Unused URL with gid redirect should be deleted' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+url');
    MusicBrainz::Server::Test->prepare_test_database($test->c, <<~'SQL');
        INSERT INTO url_gid_redirect (gid, new_id)
             VALUES ('68bab7a6-abcf-4108-922a-b452a20b0a63', 1)
        SQL

    my $url_data = MusicBrainz::Server::Data::URL->new(c => $test->c);
    $url_data->delete(1);
    ok(!defined $url_data->get_by_id(1), 'the URL was deleted');
};

1;
