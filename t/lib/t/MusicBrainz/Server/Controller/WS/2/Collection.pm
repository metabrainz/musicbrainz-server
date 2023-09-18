package t::MusicBrainz::Server::Controller::WS::2::Collection;
use utf8;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test::WS qw(
    ws2_test_xml
    ws2_test_xml_forbidden
    ws2_test_xml_invalid_mbid
    ws2_test_xml_not_found
    ws2_test_xml_unauthorized
);

with 't::Mechanize', 't::Context';

test 'collection lookup' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    ws2_test_xml 'all collections',
        '/collection/' =>
        '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <collection-list count="22">
    <collection type="Area" id="9ece2fbd-3f4e-431d-9424-da8af38374e0" entity-type="area">
      <name>private area collection</name>
      <editor>the-anti-kuno</editor>
      <area-list count="1" />
    </collection>
    <collection id="5f0831af-c84c-44a3-849d-abdf0a18cdd9" type="Artist" entity-type="artist">
      <name>private artist collection</name>
      <editor>the-anti-kuno</editor>
      <artist-list count="1" />
    </collection>
    <collection entity-type="event" type="Event" id="13b1d199-a79e-40fe-bd7c-0ecc3ca52d73">
      <name>private event collection</name>
      <editor>the-anti-kuno</editor>
      <event-list count="1" />
    </collection>
    <collection entity-type="instrument" type="Instrument" id="cdef54c4-2798-4d39-a0c9-5074191f9b6e">
      <name>private instrument collection</name>
      <editor>the-anti-kuno</editor>
      <instrument-list count="1" />
    </collection>
    <collection id="b0f57375-7009-47ab-a631-469aaba34885" type="Label" entity-type="label">
      <name>private label collection</name>
      <editor>the-anti-kuno</editor>
      <label-list count="1" />
    </collection>
    <collection entity-type="place" id="65e18c7a-0958-4066-9c3e-7c1474c623d1" type="Place">
      <name>private place collection</name>
      <editor>the-anti-kuno</editor>
      <place-list count="1" />
    </collection>
    <collection entity-type="recording" type="Recording" id="b5486110-906e-4c0c-a6e6-e16baf4e18e2">
      <name>private recording collection</name>
      <editor>the-anti-kuno</editor>
      <recording-list count="1" />
    </collection>
    <collection type="Release" id="1d1e41eb-20a2-4545-b4a7-d76e53d6f2f5" entity-type="release">
      <name>private release collection</name>
      <editor>the-anti-kuno</editor>
      <release-list count="1" />
    </collection>
    <collection id="b0f09ccf-a777-4c17-a917-28e01b0e66a3" type="Release group" entity-type="release_group">
      <name>private release group collection</name>
      <editor>the-anti-kuno</editor>
      <release-group-list count="1" />
    </collection>
    <collection entity-type="series" id="870dbdcf-e047-4da5-9c80-c39e964da96f" type="Series">
      <name>private series collection</name>
      <editor>the-anti-kuno</editor>
      <series-list count="1" />
    </collection>
    <collection entity-type="work" type="Work" id="b69030b0-911e-4f7d-aa59-c488b2c8fe8e">
      <name>private work collection</name>
      <editor>the-anti-kuno</editor>
      <work-list count="1" />
    </collection>
    <collection id="cc8cd8ee-6477-47d5-a16d-adac11ed9f30" type="Area" entity-type="area">
      <name>public area collection</name>
      <editor>the-anti-kuno</editor>
      <area-list count="1" />
    </collection>
    <collection type="Artist" id="9c782444-f9f4-4a4f-93cb-92d132c79887" entity-type="artist">
      <name>public artist collection</name>
      <editor>the-anti-kuno</editor>
      <artist-list count="1" />
    </collection>
    <collection type="Event" id="05febe0a-a9df-414a-a2c9-7dc366b0de9b" entity-type="event">
      <name>public event collection</name>
      <editor>the-anti-kuno</editor>
      <event-list count="1" />
    </collection>
    <collection id="7749c811-d77c-4ea5-9a9e-e2a4e7ae0d1f" type="Instrument" entity-type="instrument">
      <name>public instrument collection</name>
      <editor>the-anti-kuno</editor>
      <instrument-list count="1" />
    </collection>
    <collection type="Label" id="d8c9f799-9255-45ca-93fa-88f7c438d0d8" entity-type="label">
      <name>public label collection</name>
      <editor>the-anti-kuno</editor>
      <label-list count="1" />
    </collection>
    <collection entity-type="place" id="e6fac30e-28c9-46ed-9cbc-5aabce8170e8" type="Place">
      <name>public place collection</name>
      <editor>the-anti-kuno</editor>
      <place-list count="1" />
    </collection>
    <collection type="Recording" id="38a6a0ec-f4a9-4424-80fd-bd4f9eb2e880" entity-type="recording">
      <name>public recording collection</name>
      <editor>the-anti-kuno</editor>
      <recording-list count="1" />
    </collection>
    <collection entity-type="release" type="Release" id="dd07ea8b-0ec3-4b2d-85cf-80e523de4902">
      <name>public release collection</name>
      <editor>the-anti-kuno</editor>
      <release-list count="1" />
    </collection>
    <collection entity-type="release_group" id="dadae81b-ff9e-464e-8c38-51156557bc36" type="Release group">
      <name>public release group collection</name>
      <editor>the-anti-kuno</editor>
      <release-group-list count="1" />
    </collection>
    <collection id="5adf966d-d82f-4ae9-a9a3-e5e187ed2c34" type="Series" entity-type="series">
      <name>public series collection</name>
      <editor>the-anti-kuno</editor>
      <series-list count="1" />
    </collection>
    <collection entity-type="work" id="3529acda-c0c1-4b13-9761-a4a8dedb64be" type="Work">
      <name>public work collection</name>
      <editor>the-anti-kuno</editor>
      <work-list count="1" />
    </collection>
  </collection-list>
</metadata>', { username => 'the-anti-kuno', password => 'notreally' };

    ws2_test_xml 'private collection lookup',
        '/collection/1d1e41eb-20a2-4545-b4a7-d76e53d6f2f5' =>
        '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <collection entity-type="release" type="Release" id="1d1e41eb-20a2-4545-b4a7-d76e53d6f2f5">
    <name>private release collection</name>
    <editor>the-anti-kuno</editor>
    <release-list count="1" />
  </collection>
</metadata>', { username => 'the-anti-kuno', password => 'notreally' };

    ws2_test_xml 'private collection releases lookup',
        '/collection/1d1e41eb-20a2-4545-b4a7-d76e53d6f2f5/releases/' =>
        '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <collection entity-type="release" type="Release" id="1d1e41eb-20a2-4545-b4a7-d76e53d6f2f5">
    <name>private release collection</name>
    <editor>the-anti-kuno</editor>
    <release-list count="1">
      <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6">
        <title>Summer Reggae! Rainbow</title>
        <status id="41121bb9-3413-3818-8a9a-9742318349aa">Pseudo-Release</status>
        <quality>high</quality>
        <text-representation>
          <language>jpn</language>
          <script>Latn</script>
        </text-representation>
        <date>2001-07-04</date>
        <country>JP</country>
        <release-event-list count="1">
          <release-event>
            <date>2001-07-04</date>
            <area id="2db42837-c832-3c27-b4a3-08198f75693c">
              <name>Japan</name>
              <sort-name>Japan</sort-name>
              <iso-3166-1-code-list>
                <iso-3166-1-code>JP</iso-3166-1-code>
              </iso-3166-1-code-list>
            </area>
          </release-event>
        </release-event-list>
        <barcode>4942463511227</barcode>
      </release>
    </release-list>
  </collection>
</metadata>', { username => 'the-anti-kuno', password => 'notreally' };

    ws2_test_xml 'public collection lookup',
        '/collection/dd07ea8b-0ec3-4b2d-85cf-80e523de4902' =>
        '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <collection entity-type="release" type="Release" id="dd07ea8b-0ec3-4b2d-85cf-80e523de4902">
    <name>public release collection</name>
    <editor>the-anti-kuno</editor>
    <release-list count="1" />
  </collection>
</metadata>';

    ws2_test_xml 'browse by editor name, no credentials',
        '/collection/?editor=the-anti-kuno' =>
        '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <collection-list count="11">
    <collection id="cc8cd8ee-6477-47d5-a16d-adac11ed9f30" type="Area" entity-type="area">
      <name>public area collection</name>
      <editor>the-anti-kuno</editor>
      <area-list count="1" />
    </collection>
    <collection type="Artist" id="9c782444-f9f4-4a4f-93cb-92d132c79887" entity-type="artist">
      <name>public artist collection</name>
      <editor>the-anti-kuno</editor>
      <artist-list count="1" />
    </collection>
    <collection type="Event" id="05febe0a-a9df-414a-a2c9-7dc366b0de9b" entity-type="event">
      <name>public event collection</name>
      <editor>the-anti-kuno</editor>
      <event-list count="1" />
    </collection>
    <collection id="7749c811-d77c-4ea5-9a9e-e2a4e7ae0d1f" type="Instrument" entity-type="instrument">
      <name>public instrument collection</name>
      <editor>the-anti-kuno</editor>
      <instrument-list count="1" />
    </collection>
    <collection type="Label" id="d8c9f799-9255-45ca-93fa-88f7c438d0d8" entity-type="label">
      <name>public label collection</name>
      <editor>the-anti-kuno</editor>
      <label-list count="1" />
    </collection>
    <collection entity-type="place" id="e6fac30e-28c9-46ed-9cbc-5aabce8170e8" type="Place">
      <name>public place collection</name>
      <editor>the-anti-kuno</editor>
      <place-list count="1" />
    </collection>
    <collection type="Recording" id="38a6a0ec-f4a9-4424-80fd-bd4f9eb2e880" entity-type="recording">
      <name>public recording collection</name>
      <editor>the-anti-kuno</editor>
      <recording-list count="1" />
    </collection>
    <collection entity-type="release" type="Release" id="dd07ea8b-0ec3-4b2d-85cf-80e523de4902">
      <name>public release collection</name>
      <editor>the-anti-kuno</editor>
      <release-list count="1" />
    </collection>
    <collection entity-type="release_group" id="dadae81b-ff9e-464e-8c38-51156557bc36" type="Release group">
      <name>public release group collection</name>
      <editor>the-anti-kuno</editor>
      <release-group-list count="1" />
    </collection>
    <collection id="5adf966d-d82f-4ae9-a9a3-e5e187ed2c34" type="Series" entity-type="series">
      <name>public series collection</name>
      <editor>the-anti-kuno</editor>
      <series-list count="1" />
    </collection>
    <collection entity-type="work" id="3529acda-c0c1-4b13-9761-a4a8dedb64be" type="Work">
      <name>public work collection</name>
      <editor>the-anti-kuno</editor>
      <work-list count="1" />
    </collection>
  </collection-list>
</metadata>';

    ws2_test_xml 'browse by editor name, inc=user-collections',
        '/collection/?editor=the-anti-kuno&inc=user-collections&limit=3' =>
        '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <collection-list count="22">
    <collection type="Area" id="9ece2fbd-3f4e-431d-9424-da8af38374e0" entity-type="area">
      <name>private area collection</name>
      <editor>the-anti-kuno</editor>
      <area-list count="1" />
    </collection>
    <collection id="5f0831af-c84c-44a3-849d-abdf0a18cdd9" type="Artist" entity-type="artist">
      <name>private artist collection</name>
      <editor>the-anti-kuno</editor>
      <artist-list count="1" />
    </collection>
    <collection entity-type="event" type="Event" id="13b1d199-a79e-40fe-bd7c-0ecc3ca52d73">
      <name>private event collection</name>
      <editor>the-anti-kuno</editor>
      <event-list count="1" />
    </collection>
  </collection-list>
</metadata>', { username => 'the-anti-kuno', password => 'notreally' };
};

test 'collection lookup errors' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    ws2_test_xml_forbidden 'all collections, no credentials',
        '/collection/';

    ws2_test_xml_unauthorized 'all collections, bad credentials',
        '/collection/',
        { username => 'the-anti-kuno', password => 'wrong_password' };

    ws2_test_xml_forbidden 'private collection lookup, no credentials',
        '/collection/1d1e41eb-20a2-4545-b4a7-d76e53d6f2f5';

    ws2_test_xml_unauthorized 'private collection lookup, bad credentials',
        '/collection/1d1e41eb-20a2-4545-b4a7-d76e53d6f2f5',
        { username => 'the-anti-kuno', password => 'wrong_password' };

    ws2_test_xml_forbidden 'private collection releases lookup, no credentials',
        '/collection/1d1e41eb-20a2-4545-b4a7-d76e53d6f2f5/releases/';

    ws2_test_xml_unauthorized 'private collection releases lookup, bad credentials',
        '/collection/1d1e41eb-20a2-4545-b4a7-d76e53d6f2f5/releases/',
        { username => 'the-anti-kuno', password => 'wrong_password' };

    ws2_test_xml_forbidden 'browse by editor name, inc=user-collections, no credentials',
        '/collection/?editor=the-anti-kuno&inc=user-collections';

    ws2_test_xml_unauthorized 'browse by editor name, inc=user-collections, bad credentials',
        '/collection/?editor=the-anti-kuno&inc=user-collections',
        { username => 'the-anti-kuno', password => 'wrong_password' };

    ws2_test_xml_not_found 'lookup 404s if mbid is not found',
        '/collection/c1f75626-bff2-499d-b8f3-1a8ade05cb70';

    ws2_test_xml_invalid_mbid 'lookup 400s if mbid is invalid',
        '/collection/29611d8b-b3ad-4ffb-acb5-xxxxxxxxxxxx';

    my $bad_entity_response = sub {
        my ($entity_type) = @_;

        <<EOXML;
<?xml version="1.0" encoding="UTF-8"?>
<error>
  <text>This is not a collection for entity type $entity_type.</text>
  <text>For usage, please see: https://musicbrainz.org/development/mmd</text>
</error>
EOXML
    };

    ws2_test_xml 'GET /areas on a release collection 400s',
        '/collection/dd07ea8b-0ec3-4b2d-85cf-80e523de4902/areas',
        $bad_entity_response->('area'), { response_code => 400 };

    ws2_test_xml 'GET /artists on a release collection 400s',
        '/collection/dd07ea8b-0ec3-4b2d-85cf-80e523de4902/artists',
        $bad_entity_response->('artist'), { response_code => 400 };

    ws2_test_xml 'GET /events on a release collection 400s',
        '/collection/dd07ea8b-0ec3-4b2d-85cf-80e523de4902/events',
        $bad_entity_response->('event'), { response_code => 400 };

    ws2_test_xml 'GET /instruments on a release collection 400s',
        '/collection/dd07ea8b-0ec3-4b2d-85cf-80e523de4902/instruments',
        $bad_entity_response->('instrument'), { response_code => 400 };

    ws2_test_xml 'GET /labels on a release collection 400s',
        '/collection/dd07ea8b-0ec3-4b2d-85cf-80e523de4902/labels',
        $bad_entity_response->('label'), { response_code => 400 };

    ws2_test_xml 'GET /places on a release collection 400s',
        '/collection/dd07ea8b-0ec3-4b2d-85cf-80e523de4902/places',
        $bad_entity_response->('place'), { response_code => 400 };

    ws2_test_xml 'GET /releases on a release group collection 400s',
        '/collection/dadae81b-ff9e-464e-8c38-51156557bc36/releases',
        $bad_entity_response->('release'), { response_code => 400 };

    ws2_test_xml 'GET /release-groups on a release collection 400s',
        '/collection/dd07ea8b-0ec3-4b2d-85cf-80e523de4902/release-groups',
        $bad_entity_response->('release-group'), { response_code => 400 };

    ws2_test_xml 'GET /series on a release collection 400s',
        '/collection/dd07ea8b-0ec3-4b2d-85cf-80e523de4902/series',
        $bad_entity_response->('series'), { response_code => 400 };

    ws2_test_xml 'GET /works on a release collection 400s',
        '/collection/dd07ea8b-0ec3-4b2d-85cf-80e523de4902/works',
        $bad_entity_response->('work'), { response_code => 400 };
};

test 'browsing by area' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    ws2_test_xml 'browse by area',
        '/collection/?area=106e0bec-b638-3b37-b731-f53d507dc00e' =>
        '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <collection-list count="1">
    <collection entity-type="area" type="Area" id="cc8cd8ee-6477-47d5-a16d-adac11ed9f30">
      <name>public area collection</name>
      <editor>the-anti-kuno</editor>
      <area-list count="1" />
    </collection>
  </collection-list>
</metadata>';

    ws2_test_xml 'browse by area, no public collections',
        '/collection/?area=85752fda-13c4-31a3-bee5-0e5cb1f51dad' =>
        '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <collection-list count="0" />
</metadata>', { username => 'the-anti-kuno', password => 'notreally' };

    ws2_test_xml 'browse by area, inc=user-collections',
        '/collection/?area=85752fda-13c4-31a3-bee5-0e5cb1f51dad&inc=user-collections' =>
        '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <collection-list count="1">
    <collection entity-type="area" type="Area" id="9ece2fbd-3f4e-431d-9424-da8af38374e0">
      <name>private area collection</name>
      <editor>the-anti-kuno</editor>
      <area-list count="1" />
    </collection>
  </collection-list>
</metadata>', { username => 'the-anti-kuno', password => 'notreally' };

    ws2_test_xml_forbidden 'browse by area, inc=user-collections, no credentials',
        '/collection/?area=85752fda-13c4-31a3-bee5-0e5cb1f51dad&inc=user-collections';

    ws2_test_xml_unauthorized 'browse by area, inc=user-collections, bad credentials',
        '/collection/?area=85752fda-13c4-31a3-bee5-0e5cb1f51dad&inc=user-collections',
        { username => 'the-anti-kuno', password => 'wrong_password' };
};

test 'browsing by release' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    ws2_test_xml 'browse by release',
        '/collection/?release=0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e' =>
        '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <collection-list count="1">
    <collection entity-type="release" type="Release" id="dd07ea8b-0ec3-4b2d-85cf-80e523de4902">
      <name>public release collection</name>
      <editor>the-anti-kuno</editor>
      <release-list count="1" />
    </collection>
  </collection-list>
</metadata>';

    ws2_test_xml 'browse by release, no public collections',
        '/collection/?release=b3b7e934-445b-4c68-a097-730c6a6d47e6' =>
        '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <collection-list count="0" />
</metadata>', { username => 'the-anti-kuno', password => 'notreally' };

    ws2_test_xml 'browse by release, inc=user-collections',
        '/collection/?release=b3b7e934-445b-4c68-a097-730c6a6d47e6&inc=user-collections' =>
        '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <collection-list count="1">
    <collection entity-type="release" type="Release" id="1d1e41eb-20a2-4545-b4a7-d76e53d6f2f5">
      <name>private release collection</name>
      <editor>the-anti-kuno</editor>
      <release-list count="1" />
    </collection>
  </collection-list>
</metadata>', { username => 'the-anti-kuno', password => 'notreally' };

    ws2_test_xml_forbidden 'browse by release, inc=user-collections, no credentials',
        '/collection/?release=b3b7e934-445b-4c68-a097-730c6a6d47e6&inc=user-collections';

    ws2_test_xml_unauthorized 'browse by release, inc=user-collections, bad credentials',
        '/collection/?release=b3b7e934-445b-4c68-a097-730c6a6d47e6&inc=user-collections',
        { username => 'the-anti-kuno', password => 'wrong_password' };
};

test 'browsing by release group' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    ws2_test_xml 'browse by release group',
        '/collection/?release-group=b84625af-6229-305f-9f1b-59c0185df016' =>
        '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <collection-list count="1">
    <collection entity-type="release_group" type="Release group" id="dadae81b-ff9e-464e-8c38-51156557bc36">
      <name>public release group collection</name>
      <editor>the-anti-kuno</editor>
      <release-group-list count="1" />
    </collection>
  </collection-list>
</metadata>';

    ws2_test_xml 'browse by release group, no public collections',
        '/collection/?release-group=202cad78-a2e1-3fa7-b8bc-77c1f737e3da' =>
        '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <collection-list count="0" />
</metadata>', { username => 'the-anti-kuno', password => 'notreally' };

    ws2_test_xml 'browse by release group, inc=user-collections',
        '/collection/?release-group=202cad78-a2e1-3fa7-b8bc-77c1f737e3da&inc=user-collections' =>
        '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <collection-list count="1">
    <collection entity-type="release_group" type="Release group" id="b0f09ccf-a777-4c17-a917-28e01b0e66a3">
      <name>private release group collection</name>
      <editor>the-anti-kuno</editor>
      <release-group-list count="1" />
    </collection>
  </collection-list>
</metadata>', { username => 'the-anti-kuno', password => 'notreally' };

    ws2_test_xml_forbidden 'browse by releasegroup, inc=user-collections, no credentials',
        '/collection/?release-group=202cad78-a2e1-3fa7-b8bc-77c1f737e3da&inc=user-collections';

    ws2_test_xml_unauthorized 'browse by release group, inc=user-collections, bad credentials',
        '/collection/?release-group=202cad78-a2e1-3fa7-b8bc-77c1f737e3da&inc=user-collections',
        { username => 'the-anti-kuno', password => 'wrong_password' };
};

1;
