use utf8;
use strict;
use warnings;
use Test::More;
use_ok 'MusicBrainz::Server::Data::URL::Wikipedia';

use MusicBrainz::Server::Data::Utils qw( linktype_to_model );
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+url');

my $url = $c->model(linktype_to_model('wikipedia'))->get_by_ids(2)->{2};

is ( $url->url, "http://zh-yue.wikipedia.org/wiki/王菲" );
is ( $url->pretty_name, "zh-yue: 王菲" );

done_testing;
