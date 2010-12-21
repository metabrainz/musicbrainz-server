use strict;
use warnings;
use Test::More;

use HTTP::Status qw( :constants );
use MusicBrainz::Server::Test qw( schema_validator xml_ok xml_post );
use MusicBrainz::WWW::Mechanize;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');

my $collection = $c->model('Collection')->get_first_collection(1);
my $release = $c->model('Release')->get_by_gid('0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e');

subtest 'Add releases to collection' => sub {
    my $content = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <add>
    <release id="' . $release->gid . '" />
  </add>
</metadata>';

    my $req = xml_post('/ws/2/collection?client=test-1.0', $content);

    $mech->request($req);
    is($mech->status, HTTP_UNAUTHORIZED, 'cant POST without authentication');

    $mech->credentials('localhost:80', 'musicbrainz.org', 'new_editor', 'password');

    $mech->request($req);
    is($mech->status, HTTP_OK);
    xml_ok($mech->content);

    ok($c->model('Collection')->check_release($collection->id, $release->id));
};

subtest 'Add releases to collection' => sub {
    my $content = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <add>
    <release id="' . $release->gid . '" />
  </add>
</metadata>';

    my $req = xml_post('/ws/2/collection?client=test-1.0', $content);

    $mech->request($req);
    is($mech->status, HTTP_UNAUTHORIZED, 'cant POST without authentication');

    $mech->credentials('localhost:80', 'musicbrainz.org', 'new_editor', 'password');

    $mech->request($req);
    is($mech->status, HTTP_OK);
    xml_ok($mech->content);

    $c->model('Collection')->check_release($collection->id, $release->id);

    $mech->request($req);
    is($mech->status, HTTP_OK);
    xml_ok($mech->content);

    ok(!$c->model('Collection')->check_release($collection->id, $release->id));
};

done_testing;
