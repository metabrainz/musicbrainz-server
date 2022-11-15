package t::MusicBrainz::Server::Controller::WS::2::SubmitCollection;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::More;

with 't::Mechanize', 't::Context';

use HTTP::Status qw( :constants );
use HTTP::Request::Common qw( DELETE );
use Test::XML::SemanticCompare;

use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Test qw( xml_ok );
use MusicBrainz::Server::Test ws_test => {
    version => 2
};

test all => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    $mech->default_header('Accept' => 'application/xml');

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    my @tests = (
        {
            collection => 'cc8cd8ee-6477-47d5-a16d-adac11ed9f30',
            entity => '89a675c2-3e37-3518-b83c-418bad59a85a',
            entity_type => 'area',
        },
        {
            collection => '5f0831af-c84c-44a3-849d-abdf0a18cdd9',
            entity => '97fa3f6e-557c-4227-bc0e-95a7f9f3285d',
            entity_type => 'artist',
        },
        {
            collection => '05febe0a-a9df-414a-a2c9-7dc366b0de9b',
            entity => 'eb668bdc-a928-49a1-beb7-8e37db2a5b65',
            entity_type => 'event',
        },
        {
            collection => 'cdef54c4-2798-4d39-a0c9-5074191f9b6e',
            entity => '3590521b-8c97-4f4b-b1bb-5f68d3663d8a',
            entity_type => 'instrument',
        },
        {
            collection => 'd8c9f799-9255-45ca-93fa-88f7c438d0d8',
            entity => 'b4edce40-090f-4956-b82a-5d9d285da40b',
            entity_type => 'label',
        },
        {
            collection => '65e18c7a-0958-4066-9c3e-7c1474c623d1',
            entity => 'df9269dd-0470-4ea2-97e8-c11e46080edd',
            entity_type => 'place',
        },
        {
            collection => '38a6a0ec-f4a9-4424-80fd-bd4f9eb2e880',
            entity => '4f3321a6-7277-4c0e-808f-423b81e083e0',
            entity_type => 'recording',
        },
        {
            collection => '1d1e41eb-20a2-4545-b4a7-d76e53d6f2f5',
            entity => 'a84b9fea-aee9-4e1f-b5a2-a5a23c673688',
            entity_type => 'release',
        },
        {
            collection => 'dadae81b-ff9e-464e-8c38-51156557bc36',
            entity => '153f0a09-fead-3370-9b17-379ebd09446b',
            entity_type => 'release_group',
        },
        {
            collection => '870dbdcf-e047-4da5-9c80-c39e964da96f',
            entity => 'd977f7fd-96c9-4e3e-83b5-eb484a9e6582',
            entity_type => 'series',
        },
        {
            collection => '3529acda-c0c1-4b13-9761-a4a8dedb64be',
            entity => 'fa97639c-ea29-47d6-9461-16b411322bac',
            entity_type => 'work',
        },
    );

    for my $t (@tests) {
        my $entity_type = $t->{entity_type};
        my $collection = $c->model('Collection')->get_by_gid($t->{collection});
        my $entity = $c->model($ENTITIES{$entity_type}{model})->get_by_gid($t->{entity});

        my $uri = '/ws/2/collection/' . $collection->gid . '/' .
                $ENTITIES{$entity_type}{plural_url} . '/' .  $entity->gid .
                '?client=test-1.0';

        $test->_clear_mech;
        $mech = $test->mech;

        subtest "Add $entity_type to collection" => sub {
            $mech->put($uri);
            is($mech->status, HTTP_UNAUTHORIZED, "can’t PUT $entity_type without authentication");

            $mech->credentials('localhost:80', 'musicbrainz.org', 'the-anti-kuno', 'notreally');

            $mech->put_ok($uri);
            note($mech->content);
            xml_ok($mech->content);
            is_xml_same($mech->content, <<'EOXML');
<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <message>
        <text>OK</text>
    </message>
</metadata>
EOXML

            ok($c->model('Collection')->contains_entity($entity_type, $collection->id, $entity->id));
        };

        $test->_clear_mech;
        $mech = $test->mech;

        subtest "Remove $entity_type from collection" => sub {
            my $req = DELETE $uri;
            $mech->request($req);
            is($mech->status, HTTP_UNAUTHORIZED, "can’t POST $entity_type without authentication");

            $mech->credentials('localhost:80', 'musicbrainz.org', 'the-anti-kuno', 'notreally');

            $mech->request($req);
            is($mech->status, HTTP_OK);
            xml_ok($mech->content);
            is_xml_same($mech->content, <<'EOXML');
<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <message>
        <text>OK</text>
    </message>
</metadata>
EOXML

            ok(!$c->model('Collection')->contains_entity($entity_type, $collection->id, $entity->id));
        };
    }

    subtest 'PUT request to an invalid entity subpath 405s' => sub {
        $mech->credentials('localhost:80', 'musicbrainz.org', 'the-anti-kuno', 'notreally');

        my $bad_entity_uri =
            '/ws/2/collection/cc8cd8ee-6477-47d5-a16d-adac11ed9f30/foo/' .
            '89a675c2-3e37-3518-b83c-418bad59a85a?client=test-1.0';

        $mech->put($bad_entity_uri);
        is($mech->status, 405);
        xml_ok($mech->content);
        is_xml_same($mech->content, <<'EOXML');
<?xml version="1.0" encoding="UTF-8"?>
<error>
    <text>PUT is not allowed on this endpoint.</text>
    <text>For usage, please see: https://musicbrainz.org/development/mmd</text>
</error>
EOXML
    };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
