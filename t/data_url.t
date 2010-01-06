use strict;
use warnings;
use Test::More;
use_ok 'MusicBrainz::Server::Data::URL';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+url');

my $url_data = MusicBrainz::Server::Data::URL->new(c => $c);

my $url = $url_data->get_by_id(1);
is ( $url->id, 1 );
is ( $url->gid, "9201840b-d810-4e0f-bb75-c791205f5b24" );
is ( $url->url, "http://musicbrainz.org/" );
is ( $url->description, "MusicBrainz" );
is ( $url->edits_pending, 0 );
is ( $url->reference_count, 2 );

my $sql = Sql->new($c->dbh);
$sql->begin;

$url_data->update($url->id, {
    url => 'http://google.com',
    description => 'Google'
});

$url = $url_data->get_by_id(1);
is ( $url->id, 1 );
is ( $url->gid, "9201840b-d810-4e0f-bb75-c791205f5b24" );
is ( $url->url, 'http://google.com' );
is ( $url->description, 'Google' );

$sql->commit;

done_testing;
