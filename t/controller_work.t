use strict;
use warnings;
use Test::More tests => 10;

BEGIN {
    use MusicBrainz::Server::Context;
    use MusicBrainz::Server::Test;
    my $c = MusicBrainz::Server::Context->new();
    MusicBrainz::Server::Test->prepare_test_database($c);
    MusicBrainz::Server::Test->prepare_test_server();
    use_ok 'Catalyst::Test', 'MusicBrainz::Server';
}

my $res = request('/work/745c079d-374e-4436-9448-da92dedef3ce');
is( $res->code, 200 );
like( $res->content, qr/Composition Dancing Queen by ABBA/ );
like( $res->content, qr/Dancing Queen/ );
like( $res->content, qr/"\/work\/745c079d-374e-4436-9448-da92dedef3ce"/ );
like( $res->content, qr/ABBA/ );
like( $res->content, qr/"\/artist\/a45c079d-374e-4436-9448-da92dedef3cf"/ );
like( $res->content, qr/T-000.000.001-0/ );

# Missing
$res = request('/work/dead079d-374e-4436-9448-da92dedef3ce');
is( $res->code, 404 );

# Invalid UUID
$res = request('/work/xxxx079d-374e-4436-9448-da92dedef3ce');
is( $res->code, 404 );
