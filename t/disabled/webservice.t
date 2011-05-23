#!/usr/bin/env perl

use warnings;

# This test module is far from complete because the tests are too brittle to really make it work.
# It was useful for testing the port of the webservice, so I'll check it in for possible use later.

use strict;
use warnings;
use LWP::UserAgent;
use Data::Dumper;

use Test::More tests => 16;

undef $/;

my $testdata = [
    { 
        name   => 'artist get',
        url    => '/ws/1/artist/8f6bd1e4-fbe1-4f50-aa9b-94c450ec0f11?type=xml&inc=aliases+artist-rels+label-rels+release-rels+track-rels+url-rels+tags+ratings+counts+release-events+discs+labels',
        method => 'GET',
        xml    => qq|<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><artist id="8f6bd1e4-fbe1-4f50-aa9b-94c450ec0f11" type="Group"><name>Portishead</name><sort-name>Portishead</sort-name><life-span begin="1991"/><alias-list><alias>Postishead</alias></alias-list><tag-list><tag count="6">trip-hop</tag><tag count="3">british</tag><tag count="2">uk</tag><tag count="1">alternative rock</tag><tag count="1">britannique</tag><tag count="1">dance and electronica</tag><tag count="1">down-tempo</tag><tag count="1">downtempo</tag><tag count="1">electronic</tag><tag count="1">english</tag><tag count="1">psychedelic</tag><tag count="1">rock</tag><tag count="1">trip hop</tag><tag count="1">trip rock</tag><tag count="1">triphop</tag></tag-list><rating votes-count="3">4.33333</rating><relation-list target-type="Artist"><relation type="MemberOfBand" direction="backward"  target="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" begin="1991" end=""><artist id="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" type="Person"><name>Geoff Barrow</name><sort-name>Barrow, Geoff</sort-name><life-span begin="1971-12-09"/></artist></relation><relation type="MemberOfBand" direction="backward"  target="5adcb9d9-5ea2-428d-af46-ef626966e106" begin="1991" end=""><artist id="5adcb9d9-5ea2-428d-af46-ef626966e106" type="Person"><name>Beth Gibbons</name><sort-name>Gibbons, Beth</sort-name><life-span begin="1965-01-04"/></artist></relation><relation type="MemberOfBand" direction="backward"  target="619b1116-740e-42e0-bdfe-96af274f79f7" begin="1991" end=""><artist id="619b1116-740e-42e0-bdfe-96af274f79f7" type="Person"><name>Adrian Utley</name><sort-name>Utley, Adrian</sort-name></artist></relation><relation type="MemberOfBand" direction="backward"  target="d576e6be-03d1-489c-8c3e-692c6fbfb7ca" begin="" end=""><artist id="d576e6be-03d1-489c-8c3e-692c6fbfb7ca" type="Person"><name>Clive Deamer</name><sort-name>Deamer, Clive</sort-name></artist></relation><relation type="MemberOfBand" direction="backward"  target="0944a9f5-65be-44b6-9e8e-33732fdfe923" begin="" end=""><artist id="0944a9f5-65be-44b6-9e8e-33732fdfe923" type="Person"><name>Dave McDonald</name><sort-name>McDonald, Dave</sort-name><life-span begin="1964"/></artist></relation></relation-list><relation-list target-type="Release"><relation type="Producer" target="e1e5386a-5616-460b-bb79-0d366537b7fb" begin="" end=""><release id="e1e5386a-5616-460b-bb79-0d366537b7fb" type="Album Official" ><title>Third</title><text-representation language="ENG" script="Latn"/></release></relation></relation-list><relation-list target-type="Track"><relation type="Remixer" target="c790203b-fcc4-499f-a8e1-9e5c9a7e5e19" begin="" end=""><track id="c790203b-fcc4-499f-a8e1-9e5c9a7e5e19"><title>Moonlight Medicine (Portishead's Ride on the Wire mix)</title><duration>379920</duration></track></relation><relation type="Producer" attributes="Additional" target="252c3b82-c5b0-4457-9704-77545bbcd29b" begin="" end=""><track id="252c3b82-c5b0-4457-9704-77545bbcd29b"><title>Time Has Come (Portishead Plays UNKLE mix)</title><duration>262400</duration></track></relation><relation type="Performer" target="7d4c0ff6-c626-41ff-b0cd-22b08ab8c40f" begin="" end=""><track id="7d4c0ff6-c626-41ff-b0cd-22b08ab8c40f"><title>Motherless Child (feat. Portishead)</title><duration>311373</duration></track></relation><relation type="Performer" target="937d64a8-4571-4117-b4ed-a3d87d4dc458" begin="" end=""><track id="937d64a8-4571-4117-b4ed-a3d87d4dc458"><title>Motherless Child (feat. Portishead)</title><duration>308933</duration></track></relation><relation type="Performer" target="6615729a-a152-47bf-9721-41cecb79874c" begin="" end=""><track id="6615729a-a152-47bf-9721-41cecb79874c"><title>Motherless Child (feat. Portishead)</title><duration>310600</duration></track></relation><relation type="Remixer" target="b986b2d1-5711-4977-8184-7e00ba15c049" begin="" end=""><track id="b986b2d1-5711-4977-8184-7e00ba15c049"><title>Wild Wood (The Sheared Wood remix by Portishead)</title><duration>208866</duration></track></relation><relation type="Remixer" target="8afdb437-7f9d-4308-8a85-8579b87ba983" begin="" end=""><track id="8afdb437-7f9d-4308-8a85-8579b87ba983"><title>Karmacoma (Portishead Experience)</title><duration>237240</duration></track></relation><relation type="Remixer" target="851fa1cf-cff7-41fa-994b-27066bc970d8" begin="" end=""><track id="851fa1cf-cff7-41fa-994b-27066bc970d8"><title>Karmacoma (Portishead Experience)</title><duration>239826</duration></track></relation><relation type="Remixer" target="813b2266-bc51-4c65-9ae3-11748428c347" begin="" end=""><track id="813b2266-bc51-4c65-9ae3-11748428c347"><title>Fall of Agade (Portishead remix)</title><duration>313093</duration></track></relation><relation type="Remixer" target="cb9fb2ff-18da-4a33-a657-04f59c492395" begin="" end=""><track id="cb9fb2ff-18da-4a33-a657-04f59c492395"><title>Karmacoma (Portishead Experience)</title><duration>240173</duration></track></relation><relation type="Remixer" target="aebdc90b-0656-4f62-977b-5a8b7e892ba5" begin="" end=""><track id="aebdc90b-0656-4f62-977b-5a8b7e892ba5"><title>Karmacoma (Portishead Experience)</title><duration>238466</duration></track></relation><relation type="Remixer" target="bc675448-18ea-44cb-a3b1-cb7dd95ae5b1" begin="" end=""><track id="bc675448-18ea-44cb-a3b1-cb7dd95ae5b1"><title>Karmacoma (Portishead Experience)</title><duration>240160</duration></track></relation><relation type="Remixer" target="dda3f875-fb89-4582-a060-6ca50a4c1926" begin="" end=""><track id="dda3f875-fb89-4582-a060-6ca50a4c1926"><title>Rusty James (Portishead remix)</title><duration>322266</duration></track></relation><relation type="Remixer" target="8c7f25b5-10d3-413f-a1fa-b1c75c82e7ca" begin="" end=""><track id="8c7f25b5-10d3-413f-a1fa-b1c75c82e7ca"><title>Karmacoma (Portishead Experience)</title><duration>240000</duration></track></relation><relation type="Remixer" target="aa897555-18fe-46e8-9bcd-b8e301d8c476" begin="" end=""><track id="aa897555-18fe-46e8-9bcd-b8e301d8c476"><title>If You Find the Earth Boring (Portishead Plays U.N.K.L.E mix)</title><duration>261000</duration></track></relation><relation type="Remixer" target="df74fddc-e81c-4c41-b82d-377a097698b0" begin="" end=""><track id="df74fddc-e81c-4c41-b82d-377a097698b0"><title>Karmacoma (Portishead Experience)</title><duration>238000</duration></track></relation><relation type="Remixer" target="d9f62704-10ad-491f-9bba-59ebc5ab645d" begin="" end=""><track id="d9f62704-10ad-491f-9bba-59ebc5ab645d"><title>Karmacoma (Portishead Experience)</title><duration>237333</duration></track></relation><relation type="Remixer" target="2c7def5c-d15d-4015-8658-7a37081c2ffc" begin="" end=""><track id="2c7def5c-d15d-4015-8658-7a37081c2ffc"><title>Give Out but Don't Give Up (Portishead remix)</title><duration>349506</duration></track></relation><relation type="Remixer" target="2ca4b414-ff96-4c96-bd49-22e8bf753a7a" begin="" end=""><track id="2ca4b414-ff96-4c96-bd49-22e8bf753a7a"><title>Karmakoma (Portishead Experience)</title><duration>237773</duration></track></relation><relation type="Remixer" target="4a63c731-2558-4592-9dfa-a47fe522b8a0" begin="" end=""><track id="4a63c731-2558-4592-9dfa-a47fe522b8a0"><title>Give Out but Don't Give Up (Portishead remix)</title><duration>348813</duration></track></relation><relation type="Remixer" target="e45c0ac5-880c-4cf8-8e8d-5a7bbc1285d0" begin="" end=""><track id="e45c0ac5-880c-4cf8-8e8d-5a7bbc1285d0"><title>Wildwood (Portishead remix)</title><duration>207333</duration></track></relation><relation type="Remixer" target="d3a566a9-33a8-4631-9efc-e65e2b7d05e4" begin="" end=""><track id="d3a566a9-33a8-4631-9efc-e65e2b7d05e4"><title>Planet D (Portishead remix)</title><duration>284893</duration></track></relation><relation type="Remixer" target="7069b122-97ca-4c93-8395-3971638776bb" begin="" end=""><track id="7069b122-97ca-4c93-8395-3971638776bb"><title>Wild Wood ('Portishead' remix)</title><duration>207786</duration></track></relation><relation type="Remixer" target="20567f4d-30a6-40f1-94dc-a6bc10f4b08e" begin="" end=""><track id="20567f4d-30a6-40f1-94dc-a6bc10f4b08e"><title>Horny Blonde 40 (Portishead Remix)</title><duration>309466</duration></track></relation><relation type="Remixer" target="7d425653-292d-4f0d-9683-4083add51161" begin="" end=""><track id="7d425653-292d-4f0d-9683-4083add51161"><title>Wild Wood (The Sheared Wood remix by Portishead)</title><duration>192680</duration></track></relation><relation type="Producer" attributes="Additional" target="3aeea534-e00c-4f83-baea-0141442181a9" begin="" end=""><track id="3aeea534-e00c-4f83-baea-0141442181a9"><title>Planet D</title><duration>281160</duration></track></relation><relation type="Remixer" target="3aeea534-e00c-4f83-baea-0141442181a9" begin="" end=""><track id="3aeea534-e00c-4f83-baea-0141442181a9"><title>Planet D</title><duration>281160</duration></track></relation><relation type="Remixer" target="ef556697-4f14-43bc-a941-c4c0364f0f3f" begin="" end=""><track id="ef556697-4f14-43bc-a941-c4c0364f0f3f"><title>In Your Room (The Jeep Rock mix)</title><duration>379960</duration></track></relation><relation type="Remixer" target="ea82d1b9-c921-4a66-9b01-06516ebb7877" begin="" end=""><track id="ea82d1b9-c921-4a66-9b01-06516ebb7877"><title>Wild Wood (Sheared Wood)</title><duration>208000</duration></track></relation><relation type="Remixer" target="8d45be66-a999-4c4d-a88e-80442221869b" begin="" end=""><track id="8d45be66-a999-4c4d-a88e-80442221869b"><title>1st Transmission (Earthead)</title><duration>269026</duration></track></relation><relation type="Remixer" target="1159adf3-55bc-47df-8557-10d22d91ecc9" begin="" end=""><track id="1159adf3-55bc-47df-8557-10d22d91ecc9"><title>Nefisa (Portishead mix)</title><duration>343200</duration></track></relation></relation-list><relation-list target-type="Url"><relation type="OfficialHomepage" target="http://portishead.co.uk/" begin="" end=""/><relation type="Fanpage" target="http://freespace.virgin.net/sour.times" begin="" end=""/><relation type="Wikipedia" target="http://en.wikipedia.org/wiki/Portishead" begin="" end=""/><relation type="Musicmoz" target="http://musicmoz.org/Bands_and_Artists/P/Portishead/" begin="" end=""/><relation type="Discogs" target="http://www.discogs.com/artist/Portishead" begin="" end=""/><relation type="Myspace" target="http://www.myspace.com/PORTISHEADALBUM3" begin="" end=""/></relation-list></artist></metadata>|
    },
    { 
        name   => 'artist get with auth',
        url    => '/ws/1/artist/8f6bd1e4-fbe1-4f50-aa9b-94c450ec0f11?type=xml&inc=user-tags+user-ratings',
        method => 'GET',
        xml    => qq|<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><artist id="8f6bd1e4-fbe1-4f50-aa9b-94c450ec0f11" type="Group"><name>Portishead</name><sort-name>Portishead</sort-name><life-span begin="1991"/><user-tag-list><user-tag>down-tempo</user-tag><user-tag>trip-hop</user-tag></user-tag-list><user-rating>5</user-rating></artist></metadata>|
    },
    { 
        name   => 'release get',
        url    => '/ws/1/release/8f468f36-8c7e-4fc1-9166-50664d267127?type=xml&inc=artist+counts+release-events+discs+tracks+artist-rels+label-rels+release-rels+track-rels+url-rels+track-level-rels+labels+tags+ratings',
        method => 'GET',
        xml    => qq|<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" xmlns:ext="http://musicbrainz.org/ns/ext-1.0#"><release id="8f468f36-8c7e-4fc1-9166-50664d267127" type="Album Official" ><title>Dummy</title><text-representation language="ENG" script="Latn"/><asin>B000001FI7</asin><artist id="8f6bd1e4-fbe1-4f50-aa9b-94c450ec0f11" type="Group"><name>Portishead</name><sort-name>Portishead</sort-name><life-span begin="1991"/></artist><release-event-list><event date="1994-08-22" country="XE" catalog-number="828 553-2" barcode="042282855329" format="CD"><label id="cd275ac6-9af0-4465-895b-462208cb716e" type="OriginalProduction"><name>Go! Beat Records</name><sort-name>Go! Beat Records</sort-name><label-code>7142</label-code><country>GB</country><relation-list target-type="Label"><relation type="LabelOwnership" direction="backward"  target="d348ac6f-0fb1-4d28-b95c-814eb9ad17ef" begin="" end=""><label id="d348ac6f-0fb1-4d28-b95c-814eb9ad17ef" type="OriginalProduction"><name>Go! Discs</name><sort-name>Go! Discs</sort-name><label-code>7192</label-code><country>GB</country><life-span begin="1983" end="1996"/></label></relation></relation-list><relation-list target-type="Url"><relation type="Wikipedia" target="http://en.wikipedia.org/wiki/Go%21_Beat_Records" begin="" end=""/><relation type="Discogs" target="http://www.discogs.com/label/Go!+Beat" begin="" end=""/></relation-list><tag-list><tag count="1">beat</tag><tag count="1">go</tag><tag count="1">wife</tag><tag count="1">your</tag></tag-list><rating votes-count="1">3</rating></label></event><event date="1994-10-17" country="US" catalog-number="422-828 553-2" barcode="042282855329" format="CD"><label id="cd275ac6-9af0-4465-895b-462208cb716e" type="OriginalProduction"><name>Go! Beat Records</name><sort-name>Go! Beat Records</sort-name><label-code>7142</label-code><country>GB</country><relation-list target-type="Label"><relation type="LabelOwnership" direction="backward"  target="d348ac6f-0fb1-4d28-b95c-814eb9ad17ef" begin="" end=""><label id="d348ac6f-0fb1-4d28-b95c-814eb9ad17ef" type="OriginalProduction"><name>Go! Discs</name><sort-name>Go! Discs</sort-name><label-code>7192</label-code><country>GB</country><life-span begin="1983" end="1996"/></label></relation></relation-list><relation-list target-type="Url"><relation type="Wikipedia" target="http://en.wikipedia.org/wiki/Go%21_Beat_Records" begin="" end=""/><relation type="Discogs" target="http://www.discogs.com/label/Go!+Beat" begin="" end=""/></relation-list><tag-list><tag count="1">beat</tag><tag count="1">go</tag><tag count="1">wife</tag><tag count="1">your</tag></tag-list><rating votes-count="1">3</rating></label></event></release-event-list><disc-list><disc sectors="221793" id="D5LsXhbWwpctL4s5xHSTS_SefQw-"/><disc sectors="222362" id="ivDFb2Tw6HzN.XdYZFj5zr1Q9EY-"/><disc sectors="221792" id="F.fgxu2RXRxg2i2ZAr8qgObMAlY-"/><disc sectors="221817" id="HYPt52_I9z8PaKaWnYpm8bGm6Wo-"/><disc sectors="222512" id="_t98GzKmGo23c0oNwZzLnBY.jq8-"/><disc sectors="221822" id="nA87dKURKperVfmckD5b_xo8BO8-"/><disc sectors="221130" id="43qPpRDTFk5Lwi_YI1RUpLxghgs-"/><disc sectors="222332" id="_zB6DfhRE_kGj3iUDS4FMEG4ers-"/><disc sectors="222461" id="cXkIRw6It48QmgrVk0jHVjF.we8-"/></disc-list><tag-list><tag count="4">trip-hop</tag><tag count="2">british</tag><tag count="2">groundbreaking</tag><tag count="2">trip hop</tag><tag count="1">1994</tag><tag count="1">britannique</tag><tag count="1">down-tempo</tag><tag count="1">downtempo</tag><tag count="1">electronic</tag><tag count="1">uk</tag></tag-list><rating votes-count="4">5</rating><track-list count="11"/><track id="b5d7d380-f43a-4c1f-a5de-694150b093ac"><title>Mysterons</title><duration>306200</duration><relation-list target-type="Artist"><relation type="Composer" target="619b1116-740e-42e0-bdfe-96af274f79f7" begin="" end=""><artist id="619b1116-740e-42e0-bdfe-96af274f79f7" type="Person"><name>Adrian Utley</name><sort-name>Utley, Adrian</sort-name></artist></relation><relation type="Composer" target="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" begin="" end=""><artist id="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" type="Person"><name>Geoff Barrow</name><sort-name>Barrow, Geoff</sort-name><life-span begin="1971-12-09"/></artist></relation><relation type="Composer" target="5adcb9d9-5ea2-428d-af46-ef626966e106" begin="" end=""><artist id="5adcb9d9-5ea2-428d-af46-ef626966e106" type="Person"><name>Beth Gibbons</name><sort-name>Gibbons, Beth</sort-name><life-span begin="1965-01-04"/></artist></relation></relation-list><rating votes-count="1">5</rating></track><track id="1234a7ae-2af2-4291-aa84-bd0bafe291a1"><title>Sour Times</title><duration>254000</duration><relation-list target-type="Artist"><relation type="Composer" target="619b1116-740e-42e0-bdfe-96af274f79f7" begin="" end=""><artist id="619b1116-740e-42e0-bdfe-96af274f79f7" type="Person"><name>Adrian Utley</name><sort-name>Utley, Adrian</sort-name></artist></relation><relation type="Composer" target="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" begin="" end=""><artist id="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" type="Person"><name>Geoff Barrow</name><sort-name>Barrow, Geoff</sort-name><life-span begin="1971-12-09"/></artist></relation><relation type="Composer" target="5adcb9d9-5ea2-428d-af46-ef626966e106" begin="" end=""><artist id="5adcb9d9-5ea2-428d-af46-ef626966e106" type="Person"><name>Beth Gibbons</name><sort-name>Gibbons, Beth</sort-name><life-span begin="1965-01-04"/></artist></relation></relation-list><rating votes-count="2">5</rating></track><track id="e97f805a-ab48-4c52-855e-07049142113d"><title>Strangers</title><duration>238000</duration><relation-list target-type="Artist"><relation type="Composer" target="619b1116-740e-42e0-bdfe-96af274f79f7" begin="" end=""><artist id="619b1116-740e-42e0-bdfe-96af274f79f7" type="Person"><name>Adrian Utley</name><sort-name>Utley, Adrian</sort-name></artist></relation><relation type="Composer" target="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" begin="" end=""><artist id="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" type="Person"><name>Geoff Barrow</name><sort-name>Barrow, Geoff</sort-name><life-span begin="1971-12-09"/></artist></relation><relation type="Composer" target="5adcb9d9-5ea2-428d-af46-ef626966e106" begin="" end=""><artist id="5adcb9d9-5ea2-428d-af46-ef626966e106" type="Person"><name>Beth Gibbons</name><sort-name>Gibbons, Beth</sort-name><life-span begin="1965-01-04"/></artist></relation></relation-list><tag-list><tag count="1">dark</tag><tag count="1">disembodied</tag></tag-list><rating votes-count="2">4.5</rating></track><track id="c837f888-d471-4b07-bcbc-1b9f7406ec1a"><title>It Could Be Sweet</title><duration>259973</duration><relation-list target-type="Artist"><relation type="Composer" target="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" begin="" end=""><artist id="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" type="Person"><name>Geoff Barrow</name><sort-name>Barrow, Geoff</sort-name><life-span begin="1971-12-09"/></artist></relation><relation type="Composer" target="5adcb9d9-5ea2-428d-af46-ef626966e106" begin="" end=""><artist id="5adcb9d9-5ea2-428d-af46-ef626966e106" type="Person"><name>Beth Gibbons</name><sort-name>Gibbons, Beth</sort-name><life-span begin="1965-01-04"/></artist></relation></relation-list><rating votes-count="1">5</rating></track><track id="9170054a-8a9b-4f33-b31f-4ed58347154a"><title>Wandering Star</title><duration>293960</duration><relation-list target-type="Artist"><relation type="Composer" target="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" begin="" end=""><artist id="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" type="Person"><name>Geoff Barrow</name><sort-name>Barrow, Geoff</sort-name><life-span begin="1971-12-09"/></artist></relation><relation type="Composer" target="5adcb9d9-5ea2-428d-af46-ef626966e106" begin="" end=""><artist id="5adcb9d9-5ea2-428d-af46-ef626966e106" type="Person"><name>Beth Gibbons</name><sort-name>Gibbons, Beth</sort-name><life-span begin="1965-01-04"/></artist></relation></relation-list><rating votes-count="1">3</rating></track><track id="46d6ebba-8d3f-4600-a2a3-9eab4713458d"><title>It's a Fire</title><duration>229306</duration><relation-list target-type="Artist"><relation type="Composer" target="619b1116-740e-42e0-bdfe-96af274f79f7" begin="" end=""><artist id="619b1116-740e-42e0-bdfe-96af274f79f7" type="Person"><name>Adrian Utley</name><sort-name>Utley, Adrian</sort-name></artist></relation><relation type="Composer" target="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" begin="" end=""><artist id="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" type="Person"><name>Geoff Barrow</name><sort-name>Barrow, Geoff</sort-name><life-span begin="1971-12-09"/></artist></relation><relation type="Composer" target="5adcb9d9-5ea2-428d-af46-ef626966e106" begin="" end=""><artist id="5adcb9d9-5ea2-428d-af46-ef626966e106" type="Person"><name>Beth Gibbons</name><sort-name>Gibbons, Beth</sort-name><life-span begin="1965-01-04"/></artist></relation></relation-list></track><track id="977c23ba-10e0-4c03-a882-5896e58717ae"><title>Numb</title><duration>237960</duration><relation-list target-type="Artist"><relation type="Composer" target="619b1116-740e-42e0-bdfe-96af274f79f7" begin="" end=""><artist id="619b1116-740e-42e0-bdfe-96af274f79f7" type="Person"><name>Adrian Utley</name><sort-name>Utley, Adrian</sort-name></artist></relation><relation type="Composer" target="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" begin="" end=""><artist id="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" type="Person"><name>Geoff Barrow</name><sort-name>Barrow, Geoff</sort-name><life-span begin="1971-12-09"/></artist></relation><relation type="Composer" target="5adcb9d9-5ea2-428d-af46-ef626966e106" begin="" end=""><artist id="5adcb9d9-5ea2-428d-af46-ef626966e106" type="Person"><name>Beth Gibbons</name><sort-name>Gibbons, Beth</sort-name><life-span begin="1965-01-04"/></artist></relation></relation-list><rating votes-count="1">3</rating></track><track id="8a49dba0-253a-4535-b87f-78bb035336ce"><title>Roads</title><duration>305173</duration><relation-list target-type="Artist"><relation type="Composer" target="619b1116-740e-42e0-bdfe-96af274f79f7" begin="" end=""><artist id="619b1116-740e-42e0-bdfe-96af274f79f7" type="Person"><name>Adrian Utley</name><sort-name>Utley, Adrian</sort-name></artist></relation><relation type="Composer" target="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" begin="" end=""><artist id="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" type="Person"><name>Geoff Barrow</name><sort-name>Barrow, Geoff</sort-name><life-span begin="1971-12-09"/></artist></relation><relation type="Composer" target="5adcb9d9-5ea2-428d-af46-ef626966e106" begin="" end=""><artist id="5adcb9d9-5ea2-428d-af46-ef626966e106" type="Person"><name>Beth Gibbons</name><sort-name>Gibbons, Beth</sort-name><life-span begin="1965-01-04"/></artist></relation></relation-list><relation-list target-type="Track"><relation type="Cover" direction="backward"  target="1729b2eb-2f24-432f-9366-a78587e4c252" begin="" end=""><track id="1729b2eb-2f24-432f-9366-a78587e4c252"><title>Roads</title><duration>306066</duration></track></relation></relation-list><rating votes-count="2">5</rating></track><track id="c7baf0bc-77ed-454e-92a0-687f6b70d612"><title>Pedestal</title><duration>221000</duration><relation-list target-type="Artist"><relation type="Composer" target="619b1116-740e-42e0-bdfe-96af274f79f7" begin="" end=""><artist id="619b1116-740e-42e0-bdfe-96af274f79f7" type="Person"><name>Adrian Utley</name><sort-name>Utley, Adrian</sort-name></artist></relation><relation type="Composer" target="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" begin="" end=""><artist id="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" type="Person"><name>Geoff Barrow</name><sort-name>Barrow, Geoff</sort-name><life-span begin="1971-12-09"/></artist></relation><relation type="Composer" target="5adcb9d9-5ea2-428d-af46-ef626966e106" begin="" end=""><artist id="5adcb9d9-5ea2-428d-af46-ef626966e106" type="Person"><name>Beth Gibbons</name><sort-name>Gibbons, Beth</sort-name><life-span begin="1965-01-04"/></artist></relation></relation-list><rating votes-count="1">4</rating></track><track id="5efc1689-a6e8-45d3-a481-774be58e8b59"><title>Biscuit</title><duration>304093</duration><relation-list target-type="Artist"><relation type="Composer" target="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" begin="" end=""><artist id="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" type="Person"><name>Geoff Barrow</name><sort-name>Barrow, Geoff</sort-name><life-span begin="1971-12-09"/></artist></relation><relation type="Composer" target="5adcb9d9-5ea2-428d-af46-ef626966e106" begin="" end=""><artist id="5adcb9d9-5ea2-428d-af46-ef626966e106" type="Person"><name>Beth Gibbons</name><sort-name>Gibbons, Beth</sort-name><life-span begin="1965-01-04"/></artist></relation></relation-list></track><track id="145f5c43-0ac2-4886-8b09-63d0e92ded5d"><title>Glory Box</title><duration>305573</duration><relation-list target-type="Artist"><relation type="Composer" target="619b1116-740e-42e0-bdfe-96af274f79f7" begin="" end=""><artist id="619b1116-740e-42e0-bdfe-96af274f79f7" type="Person"><name>Adrian Utley</name><sort-name>Utley, Adrian</sort-name></artist></relation><relation type="Composer" target="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" begin="" end=""><artist id="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" type="Person"><name>Geoff Barrow</name><sort-name>Barrow, Geoff</sort-name><life-span begin="1971-12-09"/></artist></relation><relation type="Composer" target="5adcb9d9-5ea2-428d-af46-ef626966e106" begin="" end=""><artist id="5adcb9d9-5ea2-428d-af46-ef626966e106" type="Person"><name>Beth Gibbons</name><sort-name>Gibbons, Beth</sort-name><life-span begin="1965-01-04"/></artist></relation></relation-list><relation-list target-type="Track"><relation type="MashesUp" direction="backward"  target="2de6c090-f982-4550-b181-b4623713651d" begin="" end=""><track id="2de6c090-f982-4550-b181-b4623713651d"><title>Sleeping</title><duration>216053</duration></track></relation></relation-list><rating votes-count="2">4</rating></track></track-list><relation-list target-type="Artist"><relation type="Engineer" target="0944a9f5-65be-44b6-9e8e-33732fdfe923" begin="" end=""><artist id="0944a9f5-65be-44b6-9e8e-33732fdfe923" type="Person"><name>Dave McDonald</name><sort-name>McDonald, Dave</sort-name><life-span begin="1964"/></artist></relation></relation-list><relation-list target-type="Release"><relation type="Remix" direction="backward"  target="dc65cd68-92c2-4bdb-b49f-326a996731e6" begin="" end=""><release id="dc65cd68-92c2-4bdb-b49f-326a996731e6" type="Remix Bootleg" ><title>Portishead Remixed: Dumb</title><text-representation language="ENG" script="Latn"/></release></relation></relation-list><relation-list target-type="Url"><relation type="AmazonAsin" target="http://www.amazon.com/gp/product/B000001FI7" begin="" end=""/><relation type="Wikipedia" target="http://en.wikipedia.org/wiki/Dummy_%28album%29" begin="" end=""/><relation type="Discogs" target="http://www.discogs.com/release/581216" begin="" end=""/><relation type="Discogs" target="http://www.discogs.com/release/15820" begin="" end=""/></relation-list></release></metadata>|
    },
    { 
        name   => 'release get with auth',
        url    => '/ws/1/release/8f468f36-8c7e-4fc1-9166-50664d267127?type=xml&inc=user-tags+user-ratings',
        method => 'GET',
        xml    => qq|<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" xmlns:ext="http://musicbrainz.org/ns/ext-1.0#"><release id="8f468f36-8c7e-4fc1-9166-50664d267127" type="Album Official" ><title>Dummy</title><text-representation language="ENG" script="Latn"/><asin>B000001FI7</asin><user-tag-list><user-tag>groundbreaking</user-tag><user-tag>trip-hop</user-tag></user-tag-list></release></metadata>|
    },
    { 
        name   => 'track get',
        url    => '/ws/1/track/e97f805a-ab48-4c52-855e-07049142113d?type=xml&inc=artist+releases+puids+artist-rels+label-rels+release-rels+track-rels+url-rels+tags+ratings',
        method => 'GET',
        xml    => qq|<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><track id="e97f805a-ab48-4c52-855e-07049142113d"><title>Strangers</title><duration>238000</duration><artist id="8f6bd1e4-fbe1-4f50-aa9b-94c450ec0f11" type="Group"><name>Portishead</name><sort-name>Portishead</sort-name><life-span begin="1991"/></artist><release-list><release id="8f468f36-8c7e-4fc1-9166-50664d267127" type="Album Official" ><title>Dummy</title><text-representation language="ENG" script="Latn"/><asin>B000001FI7</asin><track-list offset="2"/></release></release-list><puid-list><puid id="28e65167-6a97-c28a-a964-522f5958159a"/><puid id="e9fb9ec3-8fe7-fa96-d4ff-19618fbab5b9"/><puid id="b732be75-1d95-6b23-baa9-4e5ab0fa2ab8"/><puid id="2623b79f-03a1-eb68-3b83-1aec7d391c10"/></puid-list><relation-list target-type="Artist"><relation type="Composer" target="619b1116-740e-42e0-bdfe-96af274f79f7" begin="" end=""><artist id="619b1116-740e-42e0-bdfe-96af274f79f7" type="Person"><name>Adrian Utley</name><sort-name>Utley, Adrian</sort-name></artist></relation><relation type="Composer" target="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" begin="" end=""><artist id="5082a11f-7203-4ff3-ae04-2a0150d3bbb6" type="Person"><name>Geoff Barrow</name><sort-name>Barrow, Geoff</sort-name><life-span begin="1971-12-09"/></artist></relation><relation type="Composer" target="5adcb9d9-5ea2-428d-af46-ef626966e106" begin="" end=""><artist id="5adcb9d9-5ea2-428d-af46-ef626966e106" type="Person"><name>Beth Gibbons</name><sort-name>Gibbons, Beth</sort-name><life-span begin="1965-01-04"/></artist></relation></relation-list><tag-list><tag count="1">dark</tag><tag count="1">disembodied</tag></tag-list><rating votes-count="2">4.5</rating></track></metadata>|
    },
    { 
        name   => 'release submit cdstub',
        url    => 'http://musicbrainz.homeip.net:3000/ws/1/release',
        data   => { type=> 'xml', client=>'urmom', title=>'title', artist=>'sa-artist', 
                    toc => '1+4+40001+150+10000+20000+30000', discid=>'g0ALgJ7ujkH.Ia9RKUuTecWcVlM-',
                    track0=>'t0', track1=>'t1', track2=>'t2', track3=>'t3' },
        method => 'POST',
        status => 400,
        xml    => qq|This CD Stub already exists.\n For usage, please see: http://musicbrainz.org/development/mmd|
    },
    { 
        name   => 'track get with auth',
        url    => '/ws/1/track/e97f805a-ab48-4c52-855e-07049142113d?type=xml&inc=user-tags+user-ratings',
        method => 'GET',
        xml    => qq|<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><track id="e97f805a-ab48-4c52-855e-07049142113d"><title>Strangers</title><duration>238000</duration><user-tag-list><user-tag>dark</user-tag><user-tag>disembodied</user-tag></user-tag-list></track></metadata>|
    },
    { 
        name   => 'label get',
        url    => '/ws/1/label/cd275ac6-9af0-4465-895b-462208cb716e?type=xml&inc=aliases+artist-rels+label-rels+release-rels+track-rels+url-rels+tags+ratings',
        method => 'GET',
        xml    => qq|<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><label id="cd275ac6-9af0-4465-895b-462208cb716e" type="OriginalProduction"><name>Go! Beat Records</name><sort-name>Go! Beat Records</sort-name><label-code>7142</label-code><country>GB</country><relation-list target-type="Label"><relation type="LabelOwnership" direction="backward"  target="d348ac6f-0fb1-4d28-b95c-814eb9ad17ef" begin="" end=""><label id="d348ac6f-0fb1-4d28-b95c-814eb9ad17ef" type="OriginalProduction"><name>Go! Discs</name><sort-name>Go! Discs</sort-name><label-code>7192</label-code><country>GB</country><life-span begin="1983" end="1996"/></label></relation></relation-list><relation-list target-type="Url"><relation type="Wikipedia" target="http://en.wikipedia.org/wiki/Go%21_Beat_Records" begin="" end=""/><relation type="Discogs" target="http://www.discogs.com/label/Go!+Beat" begin="" end=""/></relation-list><tag-list><tag count="1">beat</tag><tag count="1">go</tag><tag count="1">wife</tag><tag count="1">your</tag></tag-list><rating votes-count="1">3</rating></label></metadata>|
    },
    { 
        name   => 'label get with auth',
        url    => '/ws/1/label/cd275ac6-9af0-4465-895b-462208cb716e?type=xml&inc=user-tags+user-ratings',
        method => 'GET',
        xml    => qq|<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><label id="cd275ac6-9af0-4465-895b-462208cb716e" type="OriginalProduction"><name>Go! Beat Records</name><sort-name>Go! Beat Records</sort-name><label-code>7142</label-code><country>GB</country><user-tag-list><user-tag>beat</user-tag><user-tag>go</user-tag><user-tag>wife</user-tag><user-tag>your</user-tag></user-tag-list><user-rating>3</user-rating></label></metadata>|
    },
    { 
        name   => 'tag get',
        url    => '/ws/1/tag/?id=635c89c7-e2a6-4c92-b67e-aa19e6da2de3&type=xml&entity=artist',
        method => 'GET',
        xml    => qq||
    },
    { 
        name   => 'tag submit single',
        url    => '/ws/1/tag',
        data   => { type=>'xml', id=>'8f6bd1e4-fbe1-4f50-aa9b-94c450ec0f11', entity=>'artist', tags=>'srip-hop' },
        method => 'POST',
        xml    => qq|<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"/>|
    },
    { 
        name   => 'tag submit batch',
        url    => '/ws/1/tag',
        data   => { type=>'xml', 'id.0'=>'8f6bd1e4-fbe1-4f50-aa9b-94c450ec0f11', 'entity.0'=>'artist', 'tags.0'=>'skip-snop',
                                 'id.1'=>'8f468f36-8c7e-4fc1-9166-50664d267127', 'entity.1'=>'release', 'tags.1'=>'skip-snop' },
        method => 'POST',
        xml    => qq|<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"/>|
    },
    { 
        name   => 'rating get',
        url    => '/ws/1/rating/?id=635c89c7-e2a6-4c92-b67e-aa19e6da2de3&type=xml&entity=artist',
        method => 'GET',
        xml    => qq|<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"><user-rating>5</user-rating></metadata>|
    },
    { 
        name   => 'rating submit single',
        url    => '/ws/1/rating',
        data   => { type=>'xml', id=>'635c89c7-e2a6-4c92-b67e-aa19e6da2de3', entity=>'artist', rating=>'1' },
        method => 'POST',
        xml    => qq|<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"/>|
    },
    { 
        name   => 'rating submit batch',
        url    => '/ws/1/rating',
        data   => { type=>'xml', 'id.0'=>'8f6bd1e4-fbe1-4f50-aa9b-94c450ec0f11', 'entity.0'=>'artist', 'rating.0'=>'3',
                                 'id.1'=>'8f468f36-8c7e-4fc1-9166-50664d267127', 'entity.1'=>'release', 'rating.1'=>'4' },
        method => 'POST',
        xml    => qq|<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"/>|
    },
    { 
        name   => 'user with auth',
        url    => '/ws/1/user/?name=test',
        xml    => qq|<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" xmlns:ext="http://musicbrainz.org/ns/ext-1.0#"><ext:user-list><ext:user type=""><name>test</name><ext:nag show="true"/></ext:user></ext:user-list></metadata>|
    },
];

sub crude_pp
{
    my ($xml) = @_;
    $xml =~ s/></>\n</g;
    return $xml;
}

{
    package RequestAgent;
    our @ISA = qw(LWP::UserAgent);

    sub get_basic_credentials
    {
        return ("test", "MrTest");
    }
}

sub run_test
{
    my ($server, $test) = @_;

    my $ua = RequestAgent->new();
    $ua->env_proxy;
    my $response;
    if (exists $test->{method} && $test->{method} eq 'POST')
    {
        $response = $ua->post($server . $test->{url}, $test->{data});
    }
    else
    {
        $response = $ua->get($server . $test->{url});
    }
    if ($response->is_success)
    {
        my $xml = $response->content;
        if ($xml ne $test->{xml})
        {
            open(FILE, ">/tmp/got.$$.xml") or die;
            print FILE crude_pp($xml) . "\n";
            close(FILE);
            open(FILE, ">/tmp/expected.$$.xml") or die;
            print FILE crude_pp($test->{xml}) . "\n";
            close(FILE);

            print $server . $test->{url} . "\n";

            open(DIFF, "diff -Naur /tmp/expected.$$.xml /tmp/got.$$.xml |") or die;
            print <DIFF>;
            close(DIFF);

            unlink("/tmp/got.$$.xml");
            unlink("/tmp/expected.$$.xml");
            
            ok(0, $test->{name});
        }
        else
        {
            ok(1, $test->{name});
        }
    }
    else
    {
        print "Failed to fetch page: " . $response->content . "\n";
        ok(0, $test->{name});
    }
}

foreach my $t (@{$testdata})
{
    run_test("http://musicbrainz.homeip.net:3000", $t);
}
