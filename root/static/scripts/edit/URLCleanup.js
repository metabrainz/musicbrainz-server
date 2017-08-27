// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2010 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const _ = require('lodash');

// See https://musicbrainz.org/relationships (but deprecated ones)
const LINK_TYPES = {
  wikipedia: {
    area: "9228621d-9720-35c3-ad3f-327d789464ec",
    artist: "29651736-fa6d-48e4-aadc-a557c6add1cb",
    label: "51e9db21-8864-49b3-aa58-470d7b81fa50",
    release_group: "6578f0e9-1ace-4095-9de8-6e517ddb1ceb",
    work: "b45a88d6-851e-4a6e-9ec8-9a5f4ebe76ab",
    place: "82680bbb-0391-4344-9687-4f419df4b97a",
    instrument: "b21fd997-c813-3bc6-99cc-c64323bd15d3",
    series: "b2b9407a-dd32-30f4-aa48-b2fd2077d1d2",
    event: "08a982f7-d754-39b2-8315-d7cae474c641",
  },
  discogs: {
    artist: "04a5b104-a4c2-4bac-99a1-7b837c37d9e4",
    label: "5b987f87-25bc-4a2d-b3f1-3618795b8207",
    place: "1c140ac8-8dc2-449e-92cb-52c90d525640",
    release: "4a78823c-1c53-4176-a5f3-58026c76f2bc",
    release_group: "99e550f3-5ab4-3110-b5b9-fe01d970b126",
    series: "338811ef-b1a9-449d-954e-115846f33a44"
  },
  imdb: {
    artist: "94c8b0cc-4477-4106-932c-da60e63de61c",
    label: "dfd36bc7-0c06-49fa-8b79-96978778c716",
    place: "815bc5ca-c2fb-4dc6-a89b-9150888b0d4d",
    // recording and release are the "samples from" version of the IMDb rel
    recording: "dad34b86-5a1a-4628-acf5-a48ccb0785f2",
    release: "7387c5a2-9abe-4515-b667-9eb5ed4dd4ce",
    release_group: "85b0a010-3237-47c7-8476-6fcefd4761af",
    work: "e5c75559-4dda-452e-a900-ae375935164c"
  },
  myspace: {
    artist: "bac47923-ecde-4b59-822e-d08f0cd10156",
    label: "240ba9dc-9898-4505-9bf7-32a53a695612",
    place: "c809cb4a-2835-44fb-bc64-fd4882bd389c"
  },
  purevolume: {
    artist: "b6f02157-a9d3-4f24-9057-0675b2dbc581"
  },
  allmusic: {
    artist: "6b3e3c85-0002-4f34-aca6-80ace0d7e846",
    recording: "54482490-5ff1-4b1c-9382-b4d0ef8e0eac",
    release: "90ff18ad-3e9d-4472-a3d1-71d4df7e8484",
    release_group: "a50a1d20-2b20-4d2c-9a29-eb771dd78386",
    work: "ca9c9f46-11bd-423a-b134-9109cbebe9d7"
  },
  amazon: {
    release: "4f2e710d-166c-480c-a293-2e2c8d658d87"
  },
  bookbrainz: {
    artist: "f82f9342-a08d-46b7-ab7a-d8b6330c805d",
    label: "b7be2ca4-bdb7-4d87-9619-f2fa50120409",
    release: "63b84620-ba52-4630-9bfe-8ad3b5504dff",
    release_group: "27cfc95c-d368-45a9-ae0d-308c274c2017",
    work: "0ea7cf4e-93dd-4bc4-b748-0f1073cf951c"
  },
  license: {
    release: "004bd0c3-8a45-4309-ba52-fa99f3aa3d50",
    recording: "f25e301d-b87b-4561-86a0-5d2df6d26c0a"
  },
  lyrics: {
    artist: "e4d73442-3762-45a8-905c-401da65544ed",
    release_group: "156344d3-da8b-40c6-8b10-7b1c22727124",
    work: "e38e65aa-75e0-42ba-ace0-072aeb91a538"
  },
  bbcmusic: {
    artist: "d028a975-000c-4525-9333-d3c8425e4b54"
  },
  discography: {
    artist: "4fb0eeec-a6eb-4ae3-ad52-b55765b94e8f"
  },
  image: {
    artist: "221132e9-e30e-43f2-a741-15afc4c5fa7c",
    label: "b35f7822-bf3c-4148-b306-fb723c63ee8b",
    place: "68a4537c-f2a6-49b8-81c5-82a62b0976b7",
    instrument: "f64eacbd-1ea1-381e-9886-2cfb552b7d90"
  },
  discographyentry: {
    release: "823656dd-0309-4247-b282-b92d287d59c5"
  },
  mailorder: {
    artist: "611b1862-67af-4253-a64f-34adba305d1d",
    release: "3ee51e05-a06a-415e-b40c-b3f740dedfd7"
  },
  downloadpurchase: {
    artist: "f8319a2f-f824-4617-81c8-be6560b3b203",
    recording: "92777657-504c-4acb-bd33-51a201bd57e1",
    release: "98e08c20-8402-4163-8970-53504bb6a1e4"
  },
  downloadfree: {
    artist: "34ae77fe-defb-43ea-95d4-63c7540bac78",
    recording: "45d0cbc5-d65b-4e77-bdfd-8a75207cb5c5",
    release: "9896ecd0-6d29-482d-a21e-bd5d1b5e3425"
  },
  review: {
    release_group: "c3ac9c3b-f546-4d15-873f-b294d2c1b708"
  },
  score: {
    work: "0cc8527e-ea40-40dd-b144-3b7588e759bf"
  },
  secondhandsongs: {
    artist: "79c5b84d-a206-4f4c-9832-78c028c312c3",
    release: "0e555925-1b7d-475c-9b25-b9c349dcc3f3",
    work: "b80dff64-9560-445a-b824-c8b432d77a52"
  },
  songfacts: {
    work: "80402bbc-1aec-41d1-a5be-b599b89bc3c3"
  },
  socialnetwork: {
    artist: "99429741-f3f6-484b-84f8-23af51991770",
    label: "5d217d99-bc05-4a76-836d-c91eec4ba818",
    place: "040de4d5-ace5-4cfb-8a45-95c5c73bce01",
    series: "80d5e037-9aa7-3d80-80da-fb01d6dbc25b",
    event: "68f5fcaa-b58c-3bfe-9b7c-75c2b56e839a"
  },
  soundcloud: {
    artist: "89e4a949-0976-440d-bda1-5f772c1e5710",
    label: "a31d05ba-3b82-47b2-ab8b-1fe73b5459e2",
    series: "4789521b-57b9-4689-9644-46de63190f66"
  },
  blog: {
    artist: "eb535226-f8ca-499d-9b18-6a144df4ae6f",
    label: "1b431eba-0d25-4f27-9151-1bb607f5c8f8",
    place: "e3051f32-527b-4c47-9993-71250a6cd99c"
  },
  streamingmusic: {
    artist: "769085a1-c2f7-4c24-a532-2375a77693bd",
    recording: "7e41ef12-a124-4324-afdb-fdbae687a89c",
    release: "08445ccf-7b99-4438-9f9a-fb9ac18099ee"
  },
  videochannel: {
    artist: "d86c9450-b6d0-4760-a275-e7547495b48b",
    event: "1f3df2eb-3d0b-44f1-9599-1309c692bc7c",
    label: "20ad367c-cba0-4c02-bd61-2df3ae8cc799",
    place: "e5c5a0f6-9581-44d8-a5fb-d3688254dc9f",
    series: "71774032-781b-468c-9cbf-8a9a2f8eda13",
  },
  vgmdb: {
    artist: "0af15ab3-c615-46d6-b95b-a5fcd2a92ed9",
    label: "8a2d3e55-d291-4b99-87a0-c59c6b121762",
    release: "6af0134a-df6a-425a-96e2-895f9cd342ba",
    event: "5d3e0348-71a8-3dc1-b847-3a8f1d5de688"
  },
  youtube: {
    artist: "6a540e5b-58c6-4192-b6ba-dbc71ec8fcf0",
    label: "d9c71059-ba9d-4135-b909-481d12cf84e3",
    place: "22ec436d-bb65-4c83-a268-0fdb0dbd8834",
    series: "f23802a4-36be-3751-8e4d-93422e08b3e8",
    event: "fea46163-dc45-3af9-917e-1798f325d21a"
  },
  otherdatabases: {
    artist: "d94fb61c-fa20-4e3c-a19a-71a949fb2c55",
    label: "83eca2b3-5ae1-43f5-a732-56fa9a8591b1",
    place: "87a0a644-0a69-46c0-9e48-0656b8240d89",
    recording: "bc21877b-e993-42ed-a7ce-9187ec9b638f",
    release: "c74dee45-3c85-41e9-a804-92ab1c654446",
    release_group: "38320e40-9f4a-3ae7-8cb2-3f3c9c5d856d",
    series: "8a08d0f5-c7c4-4572-9d22-cee92693d820",
    work: "190ea031-4355-405d-a43e-53eb4c5c4ada",
    event: "1e06fb0b-831d-49cf-abfd-52acb5b56e05"
  },
  viaf: {
    artist: "e8571dcc-35d4-4e91-a577-a3382fd84460",
    label: "c4bee4f4-e622-4c74-b80b-585989de27f4",
    work: "b6eaef52-68a0-4b50-b875-8acd7d9212ba"
  },
  wikidata: {
    area: "85c5256f-aef1-484f-979a-42007218a1c2",
    artist: "689870a4-a1e4-4912-b17f-7b2664215698",
    label: "75d87e83-d927-4580-ba63-44dc76256f98",
    release_group: "b988d08c-5d86-4a57-9557-c83b399e3580",
    work: "587fdd8f-080e-46a9-97af-6425ebbcb3a2",
    place: "e6826618-b410-4b8d-b3b5-52e29eac5e1f",
    instrument: "1486fccd-cf59-35e4-9399-b50e2b255877",
    series: "a1eecd98-f2f2-420b-ba8e-e5bc61697869",
    event: "b022d060-e6a8-340f-8c73-6b21b1d090b9"
  },
  bandcamp: {
    artist: "c550166e-0548-4a18-b1d4-e2ae423a3e88",
    label: "c535de4c-a112-4974-b138-5e0daa56eab5"
  },
  bandsintown: {
    artist: "ea45ed3d-2d5e-456e-8c32-94b6f51426e2",
    event: "81bc32b3-7039-486a-a92f-52486fb7e162",
    place: "0e41b9de-20d8-4d1a-869d-7018e1045439",
  },
  cdbaby: {
    artist: "4c21e5f5-2960-4abc-88a1-62ce491bb96e"
  },
  songkick: {
    artist: "aac9c4bc-a5b9-30b8-9839-e3ac314c6e58",
    event: "125afc57-4d33-3b63-ab41-848a3a18d3a6",
    place: "3eb58d3e-6f00-36a8-a115-3dad616b7391"
  },
  setlistfm: {
    artist: "bf5d0d5e-27a1-4e94-9df7-3cdc67b3b207",
    event: "027fce0c-c621-4fd1-b728-1678ae08f280",
    place: "751e8fb1-ed8d-4a94-b71b-a38065054f5d"
  },
  geonames: {
    area: "c52f14c0-e9ac-4a8a-8f7a-c47328de168f"
  },
  imslp: {
    artist: "8147b6a2-ad14-4ce7-8f0a-697f9a31f68f"
  },
  lastfm: {
    artist: "08db8098-c0df-4b78-82c3-c8697b4bba7f",
    label: "e3390a1d-3083-4bc9-9295-aff9da18612c",
    place: "c3ddb53d-a7df-4486-8cc7-c1b7baec994e",
    event: "fd86b01d-c8f7-4f0a-a077-81855a9cfeef"
  },
  onlinecommunity: {
    artist: "35b3a50f-bf0e-4309-a3b4-58eeed8cee6a"
  },
  patronage: {
    artist: "6f77d54e-1d81-4e1a-9ea5-37947577151b",
    event: "f0f05915-64ac-45fb-a9b3-1bf24cd191d9",
    label: "e3d9c283-0146-4d91-9471-1b491a9c17ef",
    place: "f14b4e5f-0884-4bb0-b3fa-134cc2734f0e",
    series: "492a4e07-0ea9-4e82-870b-cab942b0576f"
  },
  crowdfunding: {
    artist: "93883cf6-e818-4938-990e-75863f8db2d3",
    event: "61187747-04d3-4d15-889a-0ceedaecf0aa",
    label: "16f681e4-93c9-4888-ae5e-3163f01269ab",
    place: "09328447-f070-463e-a760-a419ffc115bf",
    recording: "f9d9946e-0cea-4e47-9d3b-be4be55397a8",
    release: "e1434bc9-5e54-4b10-b3f6-db09e6f0cb44",
    release_group: "6aec99c1-8817-4d91-8fd0-1028cb467b62",
    series: "b4894e57-5e32-479f-b1e7-bc561048ce48"
  }
};

// See https://musicbrainz.org/doc/Style/Relationships/URLs#Restricted_relationships
const RESTRICTED_LINK_TYPES = _.reduce([
  LINK_TYPES.allmusic,
  LINK_TYPES.amazon,
  LINK_TYPES.bandcamp,
  LINK_TYPES.bandsintown,
  LINK_TYPES.bbcmusic,
  LINK_TYPES.bookbrainz,
  LINK_TYPES.discogs,
  LINK_TYPES.geonames,
  LINK_TYPES.imdb,
  LINK_TYPES.imslp,
  LINK_TYPES.lastfm,
  LINK_TYPES.lyrics,
  LINK_TYPES.myspace,
  LINK_TYPES.otherdatabases,
  LINK_TYPES.purevolume,
  LINK_TYPES.secondhandsongs,
  LINK_TYPES.setlistfm,
  LINK_TYPES.songfacts,
  LINK_TYPES.songkick,
  LINK_TYPES.soundcloud,
  LINK_TYPES.wikidata,
  LINK_TYPES.wikipedia,
  LINK_TYPES.vgmdb,
  LINK_TYPES.viaf,
  LINK_TYPES.youtube,
], function (result, linkType) {return result.concat(_.values(linkType));}, []);

function reencode_mediawiki_localpart(url) {
  var m = url.match(/^(https?:\/\/[^\/]+\/wiki\/)([^?#]+)(.*)$/);
  if (m) {
    url = m[1] + encodeURIComponent(decodeURIComponent(m[2])).replace(/%20/g, "_").replace(/%24/g, "$").replace(/%2C/g, ",").replace(/%2F/g, "/").replace(/%3A/g, ":").replace(/%3B/g, ";").replace(/%40/g, "@") + m[3];
  }
  return url;
}

function disallow(url, id) {
  return false;
}

/**
 * CLEANUPS entries have 2 to 4 of the following properties:
 * 
 * - match: Array of regexps to match a given URL with the entry.
 *          It is the only mandatory property.
 * - type: Set of relationship types to be auto-selected for matched URL.
 *         It contains at most 1 relationship type by entity type.
 * - clean: Function to clean up/normalize matched URL.
 * - validate: Function to validate matched (clean) URL
 *             for an auto-selected relationship type.
 **/
const CLEANUPS = {
  wikipedia: {
    match: [new RegExp("^(https?://)?(([^/]+\\.)?wikipedia|secure\\.wikimedia)\\.","i")],
    type: LINK_TYPES.wikipedia,
    clean: function (url) {
      url = url.replace(/^https:\/\/secure\.wikimedia\.org\/wikipedia\/([a-z-]+)\/wiki\/(.*)/, "https://$1.wikipedia.org/wiki/$2");
      url = url.replace(/^http:\/\/wikipedia\.org\/(.+)$/, "https://en.wikipedia.org/$1");
      url = url.replace(/\.wikipedia\.org\/w\/index\.php\?title=([^&]+).*/, ".wikipedia.org/wiki/$1");
      url = url.replace(/\?oldformat=true$/, '');
      url = url.replace(/^(?:https?:\/\/)?([a-z-]+)(?:\.m)?\.wikipedia\.org\/[a-z-]+\/([^?]+)$/, "https://$1.wikipedia.org/wiki/$2");
      url = reencode_mediawiki_localpart(url);
      return url;
    },
    validate: function (url, id) {
      return /^https:\/\/[a-z]+\.wikipedia\.org\/wiki\//.test(url);
    }
  },
  discogs: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?discogs\\.com","i")],
    type: LINK_TYPES.discogs,
    clean: function (url) {
      url = url.replace(/\/viewimages\?release=([0-9]*)/, "/release/$1");
      url = url.replace(/^https?:\/\/(?:[^.]+\.)?discogs\.com\/(?:.*\/)?(user\/[^\/#?]+|(?:artist|release|master(?:\/view)?|label)\/[0-9]+)(?:[\/#?-].*)?$/, "https://www.discogs.com/$1");
      url = url.replace(/^(https:\/\/www\.discogs\.com\/master)\/view\/([0-9]+)$/, "$1/$2");
      return url;
    },
    validate: function (url, id) {
      var m = /^https:\/\/www\.discogs\.com\/(?:(artist|label|master|release)\/[1-9][0-9]*|(user)\/.+)$/.exec(url);
      if (m) {
        var prefix = m[1] || m[2];
        switch (id) {
          case LINK_TYPES.discogs.artist:
            return prefix === 'artist' || prefix === 'user';
          case LINK_TYPES.discogs.label:
          case LINK_TYPES.discogs.series:
            return prefix === 'label';
          case LINK_TYPES.discogs.place:
            return prefix === 'artist' || prefix === 'label';
          case LINK_TYPES.discogs.release_group:
            return prefix === 'master';
          case LINK_TYPES.discogs.release:
            return prefix === 'release';
        }
      }
      return false;
    }
  },
  geonames: {
    match: [new RegExp("^https?:\/\/([a-z]+\.)?geonames.org\/([0-9]+)\/.*$", "i")],
    type: LINK_TYPES.geonames,
    clean: function (url) {
      return url.replace(/^https?:\/\/([a-z]+\.)?geonames.org\/([0-9]+)\/.*$/, 'http://sws.geonames.org/$2/');
    }
  },
  imdb: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?imdb\\.","i")],
    type: LINK_TYPES.imdb,
    clean: function (url) {
      return url.replace(/^https?:\/\/([^.]+\.)?imdb\.(com|de|it|es|fr|pt)\/([a-z]+\/[a-z0-9]+)(\/.*)*$/, "http://www.imdb.com/$3/");
    },
    validate: function (url, id) {
      var m = /^http:\/\/www\.imdb\.com\/(name\/nm|title\/tt|character\/ch|company\/co)[0-9]{7}\/$/.exec(url);
      if (m) {
        var prefix = m[1];
        switch (id) {
          case LINK_TYPES.imdb.artist:
            return prefix === 'name/nm' || prefix === 'character/ch' || prefix === 'company/co';
          case LINK_TYPES.imdb.label:
          case LINK_TYPES.imdb.place:
            return prefix === 'company/co';
          case LINK_TYPES.imdb.recording:
          case LINK_TYPES.imdb.release:
          case LINK_TYPES.imdb.release_group:
          case LINK_TYPES.imdb.work:
            return prefix === 'title/tt';
        }
      }
      return false;
    }
  },
  mora: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?mora\\.jp","i")],
    type: LINK_TYPES.downloadpurchase,
    clean: function (url) {
      return url.replace(/^(?:https?:\/\/)?(?:[^.]+\.)?mora\.jp\/package\/([0-9]+)\/([a-zA-Z0-9_-]+)(\/)?.*$/, "http://mora.jp/package/$1/$2/");
    }
  },
  myspace: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?myspace\\.(com|de|fr)","i")],
    type: LINK_TYPES.myspace,
    clean: function (url) {
      return url.replace(/^(https?:\/\/)?([^.]+\.)?myspace\.(com|de|fr)/, "https://myspace.com");
    },
    validate: function (url, id) {
      return /^https:\/\/myspace\.com\//.test(url);
    }
  },
  purevolume: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?purevolume\\.com","i")],
    type: LINK_TYPES.purevolume
  },
  recochoku: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?recochoku\\.jp","i")],
    type: LINK_TYPES.downloadpurchase,
    clean: function (url) {
      return url.replace(/^(?:https?:\/\/)?(?:[^.]+\.)?recochoku\.jp\/(album|song)\/([a-zA-Z0-9]+)(\/)?.*$/, "http://recochoku.jp/$1/$2/");
    }
  },
  allmusic: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?allmusic\\.com","i")],
    type: LINK_TYPES.allmusic,
    clean: function (url) {
      return url.replace(/^https?:\/\/(?:[^.]+\.)?allmusic\.com\/(artist|album(?:\/release)?|composition|song|performance)\/(?:[^\/]*-)?((?:mn|mw|mc|mt|mq|mr)[0-9]+).*/, "http://www.allmusic.com/$1/$2");
    },
    validate: function (url, id) {
      var m = /^http:\/\/www\.allmusic\.com\/([a-z\/]+)[0-9]{10}$/.exec(url);
      if (m) {
        var prefix = m[1];
        switch (id) {
          case LINK_TYPES.allmusic.artist:
            return prefix === 'artist/mn';
          case LINK_TYPES.allmusic.recording:
            return prefix === 'performance/mq';
          case LINK_TYPES.allmusic.release:
            return prefix === 'album/release/mr';
          case LINK_TYPES.allmusic.release_group:
            return prefix === 'album/mw';
          case LINK_TYPES.allmusic.work:
            return prefix === 'composition/mc' || prefix === 'song/mt';
        }
      }
      return false;
    }
  },
  amazon: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?(amazon\\.(com|ca|co\\.uk|fr|at|de|it|co\\.jp|jp|cn|es|in|com\\.br|com\\.mx)|amzn\\.com)","i")],
    type: LINK_TYPES.amazon,
    clean: function (url) {
      // determine tld, asin from url, and build standard format [1],
      // if both were found. There used to be another [2], but we'll
      // stick to the new one for now.
      //
      // [1] "https://www.amazon.<tld>/gp/product/<ASIN>"
      // [2] "http://www.amazon.<tld>/exec/obidos/ASIN/<ASIN>"
      var tld = "";
      var asin = "";
      var m;

      if ((m = url.match(/(?:amazon|amzn)\.([a-z\.]+)\//))) {
        tld = m[1];
        if (tld === "jp") {
          tld = "co.jp";
        }
        if (tld === "at") {
          tld = "de";
        }
      }

      if ((m = url.match(/\/e\/([A-Z0-9]{10})(?:[/?&%#]|$)/))) { // artist pages
        return "https://www.amazon." + tld + "/-/e/" + m[1];
      } else if ((m = url.match(/\/(?:product|dp)\/(B[0-9A-Z]{9}|[0-9]{9}[0-9X])(?:[/?&%#]|$)/))) { // strict regex to catch most ASINs
        asin = m[1];
      } else if ((m = url.match(/(?:\/|\ba=)([A-Z0-9]{10})(?:[/?&%#]|$)/))) { // if all else fails, find anything that could be an ASIN
        asin = m[1];
      }

      if (tld !== "" && asin !== "") {
        return "https://www.amazon." + tld + "/gp/product/" + asin;
      }
    },
    validate: function (url, id) {
      return /^https:\/\/www\.amazon\.(com|ca|co\.uk|fr|at|de|it|co\.jp|jp|cn|es|in|com\.br|com\.mx)\//.test(url);
    }
  },
  archive: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?archive\\.org/","i")],
    clean: function (url) {
      url = url.replace(/^https?:\/\/(www.)?archive.org\//, "https://archive.org/");
      // clean up links to files
      url = url.replace(/\?cnt=\d+$/, "");
      url = url.replace(/^https?:\/\/(.*)\.archive.org\/\d+\/items\/(.*)\/(.*)/, "https://archive.org/download/$2/$3");
      // clean up links to items
      return url.replace(/^(https:\/\/archive\.org\/details\/[A-Za-z0-9._-]+)\/$/, "$1");
    }
  },
  bigcartel: {
    match: [new RegExp("^(https?://)?[^/]+\\.bigcartel\\.com","i")],
    type: LINK_TYPES.mailorder,
    clean: function (url) {
      var m = url.match(/^(?:https?:\/\/)?([^\/]+)\.bigcartel\.com(?:\/(?:product\/([^\/?#]+)|[^\/]*))?/);
      if (m) {
        var subdomain = m[1];
        var product = m[2];
        url = "http://" + subdomain + ".bigcartel.com";
        if (product !== undefined) {
          url = url + "/product/" + product;
        }
      }
      return url;
    },
    validate: function (url, id) {
      var m = /^http:\/\/([^\/]+)\.bigcartel\.com(\/product\/[^\/?#]+)?/.exec(url);
      if (m) {
        var subdomain = m[1];
        var product = m[2];
        if (!/^(images|www)$/.test(subdomain)) {
          switch (id) {
            case LINK_TYPES.mailorder.artist:
              return product === undefined;
            case LINK_TYPES.mailorder.release:
              return product !== undefined;
          }
        }
      }
      return false;
    }
  },
  blogspot: {
    match: [new RegExp("^(https?://)?(www\\.)?[^./]+\\.blogspot\\.([a-z]{2,3}\\.)?[a-z]{2,3}/?","i")],
    clean: function (url) {
      return url.replace(/(www\.)?([^.\/]+)\.blogspot\.([a-z]{2,3}\.)?[a-z]{2,3}(\/)?/, "$2.blogspot.com/");
    }
  },
  bookbrainz: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?bookbrainz\\.org","i")],
    type: LINK_TYPES.bookbrainz,
    clean: function (url) {
      return url.replace(/^(?:https?:\/\/)?(?:[^.]+\.)?bookbrainz\.org\/([^\/]*)\/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})(?:[#\/?].*)?$/, "https://bookbrainz.org/$1/$2");
    },
    validate: function (url, id) {
      return /^https:\/\/bookbrainz\.org\/[^\/]+\/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/.test(url);
    }
  },
  cdbaby_artist: {
    match: [new RegExp("^(https?://)?((store|www)\\.)?cdbaby\\.(com|name)/Artist/","i")],
    type: LINK_TYPES.cdbaby,
    clean: function (url) {
      return url.replace(/(?:https?:\/\/)?(?:(?:store|www)\.)?cdbaby\.(?:com|name)\/Artist\/([a-z0-9]+).*$/i, "https://store.cdbaby.com/Artist/$1");
    },
    validate: function (url, id) {
      return /^https:\/\/store.cdbaby\.com\/Artist\/[a-z0-9]+$/.test(url) && id === LINK_TYPES.cdbaby.artist;
    }
  },
  cdbaby: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?cdbaby\\.(com|name)/(?!Artist/)","i")],
    clean: function (url) {
      var m = url.match(/(?:https?:\/\/)?(?:(?:store|www)\.)?cdbaby\.com\/cd\/([^\/]+)(\/(from\/[^\/]+)?)?/);
      if (m) {
        url = "https://store.cdbaby.com/cd/" + m[1].toLowerCase();
      }
      url = url.replace(/(?:https?:\/\/)?(?:(?:store|www)\.)?cdbaby\.com\/Images\/Album\/([a-z0-9]+)(?:_small)?\.jpg/, "https://store.cdbaby.com/cd/$1");
      return url.replace(/(?:https?:\/\/)?(?:images\.)?cdbaby\.name\/.\/.\/([a-z0-9]+)(?:_small)?\.jpg/, "https://store.cdbaby.com/cd/$1");
    }
  },
  downloadpurchase: {
    match: [
      new RegExp("^(https?://)?([^/]+\\.)?beatport\\.com", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?junodownload\\.com", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?audiojelly\\.com", "i"),
      new RegExp("^(https?://)?play\\.google\\.com/store/music/", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?e-onkyo\\.com", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?ototoy\\.jp", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?hd-music\\.info", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?(7digital\\.com|zdigital\\.com\\.au)", "i"),
      new RegExp("^(https?://)?loudr\.fm/", "i"),
    ],
    type: LINK_TYPES.downloadpurchase,
    clean: function (url) {
      url = url.replace(/^https?:\/\/play\.google\.com\/store\/music\/(artist|album)(?:\/[^?]*)?\?id=([^&#]+)(?:[&#].*)?$/, "https://play.google.com/store/music/$1?id=$2");
      url = url.replace(/^https?:\/\/loudr\.fm\/(artist|release)\/([a-zA-Z0-9_-]+)\/([a-zA-Z0-9_-]{5}).*$/, "https://loudr.fm/$1/$2/$3");
      return url;
    }
  },
  itunes: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?itunes\\.apple\\.com/", "i")],
    type: LINK_TYPES.downloadpurchase,
    clean: function (url) {
      return url.replace(/^https?:\/\/(?:geo\.)?itunes\.apple\.com\/([a-z]{2}\/)?(artist|album|audiobook|music-video|podcast|preorder)\/(?:[^?#\/]+\/)?(id[0-9]+)(?:\?.*)?$/, "https://itunes.apple.com/$1$2/$3");
    },
    validate: function (url, id) {
      var m = /^https:\/\/itunes\.apple\.com\/(?:[a-z]{2}\/)?([a-z-]{3,})\/id[0-9]+$/.exec(url);
      if (m) {
        var prefix = m[1];
        switch (id) {
          case LINK_TYPES.downloadpurchase.artist:
            return prefix === 'artist';
          case LINK_TYPES.downloadpurchase.recording:
            return prefix === 'music-video';
          case LINK_TYPES.downloadpurchase.release:
            return /^(album|audiobook|podcast|preorder)$/.test(prefix);
        }
      }
      return false;
    }
  },
  jamendo: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?jamendo\\.com","i")],
    type: LINK_TYPES.downloadfree,
    clean: function (url) {
      url = url.replace(/jamendo\.com\/(?:\w\w\/)?(album|list|track)\/([^\/]+)(\/.*)?$/, "jamendo.com/$1/$2");
      url = url.replace(/img\.jamendo\.com\/albums\/(\d+)\/covers\/\d+\.\d+\.jpg/, "www.jamendo.com/album/$1/");
      url = url.replace(/jamendo\.com\/\w\w\/artist\//, "jamendo.com/artist/");
      return url;
    }
  },
  license: {
    match: [
      new RegExp("^(https?://)?([^/]+\\.)?artlibre\\.org/licence", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?creativecommons\\.org/(licenses|publicdomain)/", "i")
    ],
    type: LINK_TYPES.license,
    clean: function (url) {
      url = url.replace(/^(https?:\/\/)?([^\/]+\.)?creativecommons\.org\//, "http://creativecommons.org/");
      url = url.replace(/^http:\/\/creativecommons\.org\/(licenses|publicdomain)\/(.+)\/((legalcode|deed)((\.|-)[A-Za-z_]+)?)?/, "http://creativecommons.org/$1/$2/");

      // make sure there is exactly one terminating slash
      url = url.replace(/^(http:\/\/creativecommons\.org\/licenses\/(?:by|(?:by-|)(?:nc|nc-nd|nc-sa|nd|sa)|(?:nc-|)sampling\+?)\/[0-9]+\.[0-9]+(?:\/(?:ar|au|at|be|br|bg|ca|cl|cn|co|cr|hr|cz|dk|ec|ee|fi|fr|de|gr|gt|hk|hu|in|ie|il|it|jp|lu|mk|my|mt|mx|nl|nz|no|pe|ph|pl|pt|pr|ro|rs|sg|si|za|kr|es|se|ch|tw|th|uk|scotland|us|vn)|))\/*$/, "$1/");
      url = url.replace(/^(http:\/\/creativecommons\.org\/publicdomain\/zero\/[0-9]+\.[0-9]+)\/*$/, "$1/");
      url = url.replace(/^(http:\/\/creativecommons\.org\/licenses\/publicdomain)\/*$/, "$1/");

      url = url.replace(/^(https?:\/\/)?([^\/]+\.)?artlibre\.org\//, "http://artlibre.org/");
      url = url.replace(/^http:\/\/artlibre\.org\/licence\.php\/lal\.html/, "http://artlibre.org/licence/lal");
      return url;
    }
  },
  lyrics: {
    match: [
      new RegExp("^(https?://)?([^/]+\\.)?lyrics\\.wikia\\.com", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?directlyrics\\.com", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?decoda\\.com", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?kasi-time\\.com", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?lieder\\.net", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?utamap\\.com", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?j-lyric\\.net", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?lyricsnmusic\\.com", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?muzikum\\.eu", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?genius\\.com", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?gutenberg\\.org", "i"),
    ],
    type: LINK_TYPES.lyrics,
    clean: function (url) {
      url = url.replace(/^https?:\/\/(.+\.)?genius\.com/, "http://$1genius.com");
      return url;
    }
  },
  bbcmusic: {
    match: [new RegExp("^(https?://)?(www\\.)?bbc\\.co\\.uk/music/artists/", "i")],
    type: LINK_TYPES.bbcmusic,
    clean: function (url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?bbc\.co\.uk\/music\/artists\/([0-9a-f-]+).*$/, "http://www.bbc.co.uk/music/artists/$1");
      return url;
    },
    validate: function (url, id) {
      return /^http:\/\/www\.bbc\.co\.uk\/music\/artists\/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/.test(url);
    }
  },
  wikisource: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?wikisource\\.org", "i")],
    type: LINK_TYPES.lyrics,
    clean: function (url) {
      url = url.replace(/^http:\/\/([a-z-]+\.)?wikisource\.org/, "https://$1wikisource.org");
      url = reencode_mediawiki_localpart(url);
      return url;
    },
    validate: function (url, id) {
      return /^https:\/\/(?:[a-z-]+\.)?wikisource\.org\/wiki\//.test(url);
    }
  },
  wikimediacommons: {
    match: [new RegExp("^(https?://)?(commons\\.(?:m\\.)?wikimedia\\.org|upload\\.wikimedia\\.org/wikipedia/commons/)","i")],
    type: _.defaults({}, LINK_TYPES.image, LINK_TYPES.score),
    clean: function (url) {
      url = url.replace(/\/wiki\/[^#]+#(?:mediaviewer|\/media)\/(.*)/, "\/wiki\/$1");
      url = url.replace(/^https?:\/\/upload\.wikimedia\.org\/wikipedia\/commons\/(thumb\/)?[0-9a-z]\/[0-9a-z]{2}\/([^\/]+)(\/[^\/]+)?$/, "https://commons.wikimedia.org/wiki/File:$2");
      url = url.replace(/\?uselang=[a-z-]+$/, "");
      url = url.replace(/#.*$/, "");
      url = reencode_mediawiki_localpart(url);
      return url.replace(/^https?:\/\/commons\.(?:m\.)?wikimedia\.org\/wiki\/(?:File|Image):/, "https://commons.wikimedia.org/wiki/File:");
    },
    validate: function (url, id) {
      return /^https:\/\/commons\.wikimedia\.org\/wiki\/File:[^?#]+$/.test(url);
    }
  },
  unwelcomeimages: { // Block images from sites that don't allow deeplinking
    match: [
      new RegExp("^(https?://)?s\\.pixogs\\.com\/", "i"),
      new RegExp("^(https?://)?(s|img)\\.discogss?\\.com\/", "i"),
    ],
    type: LINK_TYPES.image,
    validate: disallow,
  },
  discographyentry: {
    match: [
      new RegExp("^(https?://)?(www\\.)?naxos\\.com/catalogue/item\\.asp", "i"),
      new RegExp("^(https?://)?(www\\.)?bis\\.se/index\\.php\\?op=album", "i"),
      new RegExp("^(https?://)?(www\\.)?universal-music\\.co\\.jp/([a-z0-9-]+/)?[a-z0-9-]+/products/[a-z]{4}-[0-9]{5}/$", "i"),
      new RegExp("^(https?://)?(www\\.)?lantis\\.jp/release-item2\\.php\\?id=[0-9a-f]{32}$", "i"),
      new RegExp("^(https?://)?(www\\.)?jvcmusic\\.co\\.jp/[a-z-]+/Discography/[A0-9-]+/[A-Z]{4}-[0-9]+\\.html$", "i"),
      new RegExp("^(https?://)?(www\\.)?wmg\\.jp/artist/[A-Za-z0-9]+/[A-Z]{4}[0-9]{9}\\.html$", "i"),
      new RegExp("^(https?://)?(www\\.)?avexnet\\.jp/id/[a-z0-9]{5}/discography/product/[A-Z0-9]{4}-[0-9]{5}\\.html$", "i"),
      new RegExp("^(https?://)?(www\\.)?kingrecords\\.co\\.jp/cs/g/g[A-Z]{4}-[0-9]+/$", "i")
    ],
    type: LINK_TYPES.discographyentry
  },
  cdjapan: {
    match: [new RegExp("^(https?://)?(www\\.)?cdjapan\\.co\\.jp/(product|person)/", "i")],
    type: LINK_TYPES.mailorder,
    clean: function (url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?cdjapan\.co\.jp\/(person|product)\/([^\/?#]+)(?:.*)?$/, "http://www.cdjapan.co.jp/$1/$2");
      return url;
    }
  },
  ozonru: {
    match: [new RegExp("^(https?://)?(www\\.)?ozon\\.ru/context/detail/id/", "i")],
    type: LINK_TYPES.mailorder
  },
  review: {
    match: [
      new RegExp("^(https?://)?(www\\.)?bbc\\.co\\.uk/music/reviews/", "i"),
      new RegExp("^(https?://)?(www\\.)?metal-archives\\.com/reviews/", "i"),
      new RegExp("^(https?://)?(www\\.)?residentadvisor\\.net/review", "i")
    ],
    type: LINK_TYPES.review
  },
  score: {
    match: [
      new RegExp("^(https?://)?(www\\.)?neyzen\\.com", "i"),
      new RegExp("^(https?://)?(www[0-9]?\\.)?cpdl\\.org", "i")
    ],
    type: LINK_TYPES.score,
    clean: function (url) {
      return url.replace(/^(?:https?:\/\/)?(?:www[0-9]?\.)?cpdl\.org/, "http://cpdl.org");
    }
  },
  secondhandsongs: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?secondhandsongs\\.com/", "i")],
    type: LINK_TYPES.secondhandsongs,
    validate: function (url, id) {
      var m = /secondhandsongs\.com\/([a-z]+)\//.exec(url);
      if (m) {
        var prefix = m[1];
        switch (id) {
          case LINK_TYPES.secondhandsongs.artist:
            return prefix === 'artist';
          case LINK_TYPES.secondhandsongs.release:
            return prefix === 'release';
          case LINK_TYPES.secondhandsongs.work:
            return prefix === 'work';
        }
      }
      return false;
    }
  },
  songfacts: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?songfacts\\.com/", "i")],
    type: LINK_TYPES.songfacts
  },
  socialnetwork: {
    match: [
      new RegExp("^(https?://)?([^/]+\\.)?(last\\.fm|lastfm\\.(com\\.br|com\\.tr|at|com|de|es|fr|it|jp|pl|pt|ru|se))/user/", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?plus\\.google\\.com/", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?vine\\.co/", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?vk\\.com/", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?twitter\\.com/", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?weibo\\.com/", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?linkedin\\.com/", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?foursquare\\.com/", "i"),
    ],
    type: LINK_TYPES.socialnetwork,
    clean: function (url) {
      url = url.replace(/^(?:https?:\/\/)?plus\.google\.com\/(?:u\/[0-9]\/)?([0-9]+)(\/.*)?$/, "https://plus.google.com/$1");
      url = url.replace(/^(?:https?:\/\/)?(?:(?:www|mobile)\.)?twitter\.com(?:\/#!)?\/@?([^\/?#]+)(?:[\/?#].*)?$/, "https://twitter.com/$1");
      url = url.replace(/^(https?:\/\/)?((www|cn|m)\.)?(last\.fm|lastfm\.(com\.br|com\.tr|at|com|de|es|fr|it|jp|pl|pt|ru|se))/, "http://www.last.fm");
      url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?weibo\.com\/([^\/?#]+)(?:.*)$/, "http://www.weibo.com/$1");
      url = url.replace(/^https?:\/\/(.+\.)?linkedin\.com/, "https://$1linkedin.com");
      url = url.replace(/^https?:\/\/(.+\.)?foursquare\.com/, "https://foursquare.com");
      return url;
    }
  },
  facebook: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?facebook\\.com/", "i")],
    type: LINK_TYPES.socialnetwork,
    clean: function (url) {
      url = url.replace(/^(https?:\/\/)?([^\/]+\.)?facebook\.com(\/#!)?/, "https://www.facebook.com");
      // Remove ref (where the user came from), sk (subpages in a page, since we want the main link) and a couple others
      url = url.replace(new RegExp("([&?])(__tn__|_fb_noscript|_rdr|acontext|em|entry_point|filter|focus_composer|fref|hc_location|pnref|qsefr|ref|ref_dashboard_filter|ref_type|refsrc|rf|sid_reminder|sk|tab|viewas)=([^?&]*)", "g"), "$1");
      // Ensure the first parameter left uses ? not to break the URL
      url = url.replace(/([&?])&+/, "$1");
      url = url.replace(/[&?]$/, "");
      // Remove trailing slashes
      if (url.match(/\?/)) {
        url = url.replace(/\/\?/, "?");
      } else {
        url = url.replace(/(facebook\.com\/.*)\/$/, "$1");
      }
      url = url.replace(/\/event\.php\?eid=/, "/events/");
      url = url.replace(/\/(?:about|info|photos_stream|timeline)([?#].*)?$/, "$1");
      return url;
    },
    validate: function (url, id) {
      if (/facebook.com\/pages\//.test(url)) {
        return /\/pages\/[^\/?#]+\/\d+/.test(url);
      }
      return true;
    },
  },
  instagram: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?instagram\\.com/", "i")],
    type: LINK_TYPES.socialnetwork,
    clean: function (url) {
      return url.replace(/^(?:https?:\/\/)?(?:[^\/]+\.)?instagram\.com\/([^?#]+[^\/?#])\/*(?:[?#].*)?$/, 'https://www.instagram.com/$1/');
    },
  },
  pinterest: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?pinterest\\.com/","i")],
    type: LINK_TYPES.socialnetwork,
    clean: function (url) {
      url = url.replace(/^(?:https?:\/\/)?(?:[^\/]+\.)?pinterest\.com\/([^?#]*[^\/?#])\/*(?:[?#].*)?$/, "https://www.pinterest.com/$1/");
      return url.replace(/\/(?:boards|pins|likes|followers|following)(?:\/.*)?$/, "/");
    },
  },
  reverbnation: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?reverbnation\\.com/","i")],
    type: LINK_TYPES.socialnetwork,
    clean: function (url) {
      url = url.replace(/^(?:https?:\/\/)?(?:(?:www|m)\.)?reverbnation\.com(?:\/#!)?\//, "http://www.reverbnation.com/");
      url = url.replace(/#.*$/,'');
      url = url.replace(new RegExp("([?&])(?:blog|current_active_tab|fg_og_[^=]+|kick|profile_tour|profile_view_source|utm_[^=]+)=(?:[^?&]*)", "g"), "$1");
      url = url.replace(/([?&])&+/, "$1");
      url = url.replace(/[?&]$/, "");
      return url;
    },
  },
  soundcloud: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?soundcloud\\.com","i")],
    type: LINK_TYPES.soundcloud,
    clean: function (url) {
      return url.replace(/^(https?:\/\/)?((www|m)\.)?soundcloud\.com(\/#!)?/, "https://soundcloud.com");
    },
    validate: function (url, id) {
      return /^https:\/\/soundcloud\.com\/(?!(search|tags)[\/?#])/.test(url);
    }
  },
  blog: {
    match: [
      new RegExp("^(https?://)?([^/]+\\.)?ameblo\\.jp", "i"),
      new RegExp("^(https?://)?([^/]+\\.)?blog\\.livedoor\\.jp", "i"),
      new RegExp("^(https?://)?([^./]+)\\.jugem\\.jp", "i"),
      new RegExp("^(https?://)?([^./]+)\\.exblog\\.jp", "i"),
      new RegExp("^(https?://)?([^./]+)\\.tumblr\\.com", "i")
    ],
    type: LINK_TYPES.blog,
    clean: function (url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?ameblo\.jp\/([^\/]+).*$/, "http://ameblo.jp/$1/");
      return url;
    }
  },
  deezer: {
    match: [
      new RegExp("^(https?://)?([^/]+\\.)?(deezer\\.com)", "i"),
    ],
    type: LINK_TYPES.streamingmusic,
    clean: function (url) {
      url = url.replace(/^https?:\/\/(www\.)?deezer\.com\/(\w+)\/(\d+).*$/, "https://www.deezer.com/$2/$3");
      return url;
    }
  },
  spotifyuseraccount: {
    match: [
      new RegExp("^(https?://)?([^/]+\\.)?(spotify\\.com)/user", "i")
    ],
    type: LINK_TYPES.socialnetwork,
    clean: function (url) {
      url = url.replace(/^(?:https?:\/\/)?(?:play|open)\.spotify\.com\/user\/([a-zA-Z0-9_-]+)\/?(?:[?#].*)?$/, "https://open.spotify.com/user/$1");
      return url;
    },
    validate: function (url, id) {
      return /^https:\/\/open\.spotify\.com\/user\/[a-zA-Z0-9_-]+$/.test(url);
    }
  },
  spotify: {
    match: [
      new RegExp("^(https?://)?([^/]+\\.)?(spotify\\.com)/(?!user)", "i")
    ],
    type: LINK_TYPES.streamingmusic,
    clean: function (url) {
      url = url.replace(/^(?:https?:\/\/)?embed\.spotify\.com\/\?uri=spotify:([a-z]+):([a-zA-Z0-9_-]+)$/, "https://open.spotify.com/$1/$2");
      url = url.replace(/^(?:https?:\/\/)?(?:play|open)\.spotify\.com\/([a-z]+)\/([a-zA-Z0-9_-]+)(?:[/?#].*)?$/, "https://open.spotify.com/$1/$2");
      return url;
    },
    validate: function (url, id) {
      var m = /^https:\/\/open\.spotify\.com\/([a-z]+)\/(?:[a-zA-Z0-9_-]+)$/.exec(url);
      if (m) {
        var prefix = m[1];
        switch (id) {
          case LINK_TYPES.streamingmusic.artist:
            return prefix === 'artist';
          case LINK_TYPES.streamingmusic.release:
            return prefix === 'album';
          case LINK_TYPES.streamingmusic.recording:
            return prefix === 'track';
        }
      }
      return false;
    }
  },
  viaf: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?viaf\\.org", "i")],
    type: LINK_TYPES.viaf,
    clean: function (url) {
      url = url.replace(/^(?:https?:\/\/)?(?:[^\/]+\.)?viaf\.org\/viaf\/([0-9]+).*$/,
        "http://viaf.org/viaf/$1");
      return url;
    },
    validate: function (url, id) {
      return /^http:\/\/viaf\.org\/viaf\/[1-9][0-9]*$/.test(url);
    }
  },
  dailymotion: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?(dailymotion\\.com/)", "i")],
    type: _.defaults({}, LINK_TYPES.videochannel, LINK_TYPES.streamingmusic),
    clean: function (url) {
      var m = /^(?:https?:\/\/)?(?:www\.)?dailymotion\.com\/((([^\/?#]+)(?:\/[^?#]*)?)(?:\?[^#]*)?(?:#(.+)?)?)$/.exec(url);
      if (m) {
        var afterSlash = m[1];
        var path = m[2];
        var root = m[3];
        var fragment = m[4];
        switch (root) {
          case 'playlist':
            afterSlash = /^video=/.test(fragment) ? fragment.replace('=', '/') : afterSlash;
            break;
          case 'video':
            afterSlash = path.replace(/([^_]+).*/, "$1");
            break;
          default:
            afterSlash = new RegExp('^' + root + '/*$').test(path) ? root : afterSlash;
            break;
        }
        return 'http://www.dailymotion.com/' + afterSlash;
      }
      return url;
    },
    validate: function (url, id) {
      var m = /^http:\/\/www\.dailymotion\.com\/(?:(video\/)?[^\/?#]+)$/.exec(url);
      if (m) {
        var prefix = m[1];
        if (_.includes(LINK_TYPES.videochannel, id)) {
          return prefix === undefined;
        } else {
          return prefix === 'video/';
        }
      }
      return false;
    }
  },
  twitch: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?(twitch\\.tv/)", "i")],
    type: _.defaults({}, LINK_TYPES.videochannel, LINK_TYPES.streamingmusic),
    clean: function (url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?twitch\.tv\/((?:videos\/)?[^\/?#]+)(?:.*)?$/, "https://www.twitch.tv/$1");
      return url;
    },
    validate: function (url, id) {
      var m = /^https:\/\/www\.twitch\.tv\/(?:(videos\/)?[^\/?#]+)$/.exec(url);
      if (m) {
        var prefix = m[1];
        if (_.includes(LINK_TYPES.videochannel, id)) {
          return prefix === undefined;
        } else {
          return prefix === 'videos/';
        }
      }
      return false;
    }
  },
  vimeo: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?(vimeo\\.com/)", "i")],
    type: _.defaults({}, LINK_TYPES.videochannel, LINK_TYPES.streamingmusic),
    clean: function (url) {
      url = url.replace(/^(?:https?:\/\/)?(?:[^\/]+\.)?vimeo\.com/, "http://vimeo.com");
      // Remove query string, just the video id should be enough.
      url = url.replace(/\?.*/, "");
      return url;
    }
  },
  youtube: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?(youtube\\.com/|youtu\\.be/)", "i")],
    type: _.defaults({}, LINK_TYPES.youtube, LINK_TYPES.streamingmusic),
    clean: function (url) {
      url = url.replace(/^(https?:\/\/)?([^\/]+\.)?youtube\.com(?:\/#)?/, "https://www.youtube.com");
      // YouTube URL shortener
      url = url.replace(/^(?:https?:\/\/)?(?:[^\/]+\.)?youtu\.be\/([a-zA-Z0-9_-]+).*$/, "https://www.youtube.com/watch?v=$1");
      // YouTube standard watch URL
      url = url.replace(/^https:\/\/www\.youtube\.com\/.*[?&](v=[a-zA-Z0-9_-]+).*$/, "https://www.youtube.com/watch?$1");
      // YouTube embeds
      url = url.replace(/^https:\/\/www\.youtube\.com\/(?:embed|v)\/([a-zA-Z0-9_-]+).*$/, "https://www.youtube.com/watch?v=$1");
      url = url.replace(/\/user\/([^\/\?#]+).*$/, "/user/$1");
      return url;
    },
    validate: function (url, id) {
      return /^https:\/\/www\.youtube\.com\//.test(url);
    }
  },
  vgmdb: {
    match: [new RegExp("^(https?://)?vgmdb\\.(net|com)/", "i")],
    type: LINK_TYPES.vgmdb,
    clean: function (url) {
      return url.replace(/^(?:https?:\/\/)?vgmdb\.(?:net|com)\/(album|artist|event|org)\/([0-9]+).*$/, "http://vgmdb.net/$1/$2");
    },
    validate: function (url, id) {
      var m = /^http:\/\/vgmdb\.net\/(album|artist|org|event)\/[1-9][0-9]*$/.exec(url);
      if (m) {
        var prefix = m[1];
        switch (id) {
          case LINK_TYPES.vgmdb.artist:
            return prefix === 'artist' || prefix === 'org';
          case LINK_TYPES.vgmdb.release:
            return prefix === 'album';
          case LINK_TYPES.vgmdb.label:
            return prefix === 'org';
          case LINK_TYPES.vgmdb.event:
            return prefix === 'event';
        }
      }
      return false;
    }
  },
  wikidata: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?wikidata\\.org","i")],
    type: LINK_TYPES.wikidata,
    clean: function (url) {
      return url.replace(/^(?:https?:\/\/)?(?:[^\/]+\.)?wikidata\.org\/(?:wiki|entity)\/(Q([0-9]+)).*$/, "https://www.wikidata.org/wiki/$1");
    },
    validate: function (url, id) {
      return /^https:\/\/www\.wikidata\.org\/wiki\/Q[1-9][0-9]*$/.test(url);
    }
  },
  bandcamp: {
    match: [new RegExp("^(https?://)?([^/]+)\\.bandcamp\\.com","i")],
    type: LINK_TYPES.bandcamp,
    clean: function (url) {
      return url.replace(/^(?:https?:\/\/)?([^\/]+)\.bandcamp\.com(?:\/(((album|track)\/([^\/\?]+)))?)?.*$/, "http://$1.bandcamp.com/$2");
    },
    validate: function (url, id) {
      switch (id) {
        case LINK_TYPES.bandcamp.artist:
        case LINK_TYPES.bandcamp.label:
          return /^http:\/\/[^\/]+\.bandcamp\.com\/$/.test(url);
      }
      return false;
    }
  },
  bandsintown: {
    match: [new RegExp("^(https?://)?((m|www)\\.)?bandsintown\\.com","i")],
    type: LINK_TYPES.bandsintown,
    clean: function (url) {
      var m = url.match(/^(?:https?:\/\/)?(?:(?:m|www)\.)?bandsintown\.com\/(event|venue)\/0*([1-9][0-9]*)(?:[^0-9].*)?$/);
      if (m) {
        var prefix = m[1];
        var number = m[2];
        url = "https://bandsintown.com/" + prefix + "/" + number;
      } else {
        m = url.match(/^(?:https?:\/\/)?(?:(?:m|www)\.)?bandsintown\.com\/([^\/?#]+)(?:[\/?#].*)?$/);
        if (m) {
          var name = m[1];
          url = "https://bandsintown.com/" + name.toLowerCase();
        }
      }
      return url;
    },
    validate: function (url, id) {
      var m = /^https:\/\/bandsintown\.com\/(?:(event|venue)\/)?([^\/?#]+)$/.exec(url);
      if (m) {
        var prefix = m[1];
        var target = m[2];
        switch (id) {
          case LINK_TYPES.bandsintown.artist:
            return prefix === undefined && target !== undefined;
          case LINK_TYPES.bandsintown.event:
            return prefix === 'event' && /^[1-9][0-9]*$/.test(target);
          case LINK_TYPES.bandsintown.place:
            return prefix === 'venue' && /^[1-9][0-9]*$/.test(target);
        }
      }
      return false;
    }
  },
  songkick: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?songkick\\.com","i")],
    type: LINK_TYPES.songkick,
    clean: function (url) {
      return url.replace(/^http:\/\//, "https://");
    },
    validate: function (url, id) {
      var m = /songkick\.com\/([a-z]+)\//.exec(url);
      if (m) {
        var prefix = m[1];
        switch (id) {
          case LINK_TYPES.songkick.artist:
            return prefix === 'artists';
          case LINK_TYPES.songkick.event:
            return prefix === 'concerts' || prefix === 'festivals';
          case LINK_TYPES.songkick.place:
            return prefix === 'venues' || prefix === 'festivals';
        }
      }
      return false;
    }
  },
  setlistfm: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?setlist\\.fm","i")],
    type: LINK_TYPES.setlistfm,
    validate: function (url, id) {
      var m = /setlist\.fm\/([a-z]+)\//.exec(url);
      if (m) {
        var prefix = m[1];
        switch (id) {
          case LINK_TYPES.setlistfm.artist:
            return prefix === 'setlists';
          case LINK_TYPES.setlistfm.event:
            return prefix === 'setlist' || prefix === 'festival';
          case LINK_TYPES.setlistfm.place:
            return prefix === 'venue';
        }
      }
      return false;
    }
  },
  imslp: {
    match: [new RegExp("^(https?://)?(www\\.)?imslp\\.org/", "i")],
    type: _.defaults({}, LINK_TYPES.imslp, LINK_TYPES.score)
  },
  lastfm: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?(last\\.fm|lastfm\\.(com\\.br|com\\.tr|at|com|de|es|fr|it|jp|pl|pt|ru|se))/(music|label|venue|event|festival)/", "i")],
    type: LINK_TYPES.lastfm,
    clean: function (url) {
      url = url.replace(/^(https?:\/\/)?((www|cn|m)\.)?(last\.fm|lastfm\.(com\.br|com\.tr|at|com|de|es|fr|it|jp|pl|pt|ru|se))/, "http://www.last.fm");
      url = url.replace(/^http:\/\/www\.last\.fm\/music\/([^?]+).*/, "http://www.last.fm/music/$1");
      return url;
    }
  },
  onlinecommunity: {
    match: [new RegExp("^(https?://)?([^/]+\\.)?(last\\.fm|lastfm\\.(com\\.br|com\\.tr|at|com|de|es|fr|it|jp|pl|pt|ru|se))/group/", "i")],
    type: LINK_TYPES.onlinecommunity,
    clean: function (url) {
      url = url.replace(/^(https?:\/\/)?((www|cn|m)\.)?(last\.fm|lastfm\.(com\.br|com\.tr|at|com|de|es|fr|it|jp|pl|pt|ru|se))/, "http://www.last.fm");
      return url;
    }
  },
  otherdatabases: {
    match: [
      new RegExp("^(https?://)?(www\\.)?classicalarchives\\.com/(album|artist|composer|ensemble|work)/", "i"),
      new RegExp("^(https?://)?(www\\.)?rateyourmusic\\.com/", "i"),
      new RegExp("^(https?://)?(www\\.)?worldcat\\.org/", "i"),
      new RegExp("^(https?://)?(www\\.)?musicmoz\\.org/", "i"),
      new RegExp("^(https?://)?(www\\.)?musik-sammler\\.de/", "i"),
      new RegExp("^(https?://)?(www\\.)?discografia\\.dds\\.it/", "i"),
      new RegExp("^(https?://)?(www\\.)?ester\\.ee/", "i"),
      new RegExp("^(https?://)?(www\\.)?encyclopedisque\\.fr/", "i"),
      new RegExp("^(https?://)?(www\\.)?discosdobrasil\\.com\\.br/", "i"),
      new RegExp("^(https?://)?(www\\.)?isrc\\.ncl\\.edu\\.tw/", "i"),
      new RegExp("^(https?://)?(www\\.)?rolldabeats\\.com/", "i"),
      new RegExp("^(https?://)?(www\\.)?psydb\\.net/", "i"),
      new RegExp("^(https?://)?(www\\.)?metal-archives\\.com/(bands?|albums|artists|labels)", "i"),
      new RegExp("^(https?://)?(www\\.)?spirit-of-metal\\.com/", "i"),
      new RegExp("^(https?://)?(www\\.)?ibdb\\.com/", "i"),
      new RegExp("^(https?://)?(www\\.)?lortel.\\org/", "i"),
      new RegExp("^(https?://)?(www\\.)?theatricalia\\.com/", "i"),
      new RegExp("^(https?://)?(www\\.)?ocremix\\.org/", "i"),
      new RegExp("^(https?://)?(www\\.)?(trove\\.)?nla\\.gov\\.au/", "i"),
      new RegExp("^(https?://)?(www\\.)?rockensdanmarkskort\\.dk", "i"),
      new RegExp("^(https?://)?((www|wiki)\\.)?rockinchina\\.com", "i"),
      new RegExp("^(https?://)?(www\\.)?dhhu\\.dk", "i"),
      new RegExp("^(https?://)?(www\\.)?openlibrary\\.org", "i"),
      new RegExp("^(https?://)?(www\\.)?animenewsnetwork\\.com", "i"),
      new RegExp("^(https?://)?(www\\.)?rockipedia\\.no", "i"),
      new RegExp("^(https?://)?(www\\.)?whosampled\\.com", "i"),
      new RegExp("^(https?://)?(www\\.)?maniadb\\.com", "i"),
      new RegExp("^(https?://)?(www\\.)?imvdb\\.com", "i"),
      new RegExp("^(https?://)?(www\\.)?residentadvisor\\.net/(?!review)", "i"),
      new RegExp("^(https?://)?(www\\.)?vkdb\\.jp", "i"),
      new RegExp("^(https?://)?(www\\.)?ci\\.nii\\.ac\\.jp", "i"),
      new RegExp("^(https?://)?(www\\.)?iss\\.ndl\\.go\\.jp/", "i"),
      new RegExp("^(https?://)?(www\\.)?finnmusic\\.net", "i"),
      new RegExp("^(https?://)?(www\\.)?fono\\.fi", "i"),
      new RegExp("^(https?://)?(www\\.)?pomus\\.net", "i"),
      new RegExp("^(https?://)?(www\\.)?stage48\\.net/wiki/index.php", "i"),
      new RegExp("^(https?://)?(www22\\.)?big\\.or\\.jp", "i"),
      new RegExp("^(https?://)?(www\\.)?japanesemetal\\.gooside\\.com", "i"),
      new RegExp("^(https?://)?(www\\.)?d-nb\\.info", "i"),
      new RegExp("^(https?://)?(www\\.)?qim\\.com", "i"),
      new RegExp("^(https?://)?(www\\.)?mainlynorfolk\\.info", "i"),
      new RegExp("^(https?://)?(www\\.)?tedcrane\\.com", "i"),
      new RegExp("^(https?://)?(www\\.)?thedancegypsy\\.com", "i"),
      new RegExp("^(https?://)?(www\\.)?bibliotekapiosenki\\.pl", "i"),
      new RegExp("^(https?://)?(www\\.)?finna\\.fi", "i"),
      new RegExp("^(https?://)?(www\\.)?castalbums\\.org", "i"),
      new RegExp("^(https?://)?(www\\.)?folkwiki\\.se", "i"),
      new RegExp("^(https?://)?(www\\.)?mvdbase\\.com", "i"),
      new RegExp("^(https?://)?(www\\.)?smdb\\.kb\\.se", "i"),
      new RegExp("^(https?://)?(www\\.)?operadis-opera-discography\\.org\\.uk", "i"),
      new RegExp("^(https?://)?(www\\.)?spirit-of-rock\\.com", "i"),
      new RegExp("^(https?://)?(www\\.)?tunearch\\.org", "i"),
      new RegExp("^(https?://)?(www\\.)?videogam\\.in", "i"),
      new RegExp("^(https?://)?(www\\.)?triplejunearthed\\.com", "i"),
    ],
    type: LINK_TYPES.otherdatabases,
    clean: function (url) {
      // Standardising ClassicalArchives.com
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?classicalarchives\.com\/(album|artist|composer|ensemble|work)\/([^\/?#]+)(?:.*)?$/, "http://www.classicalarchives.com/$1/$2");
      // Removing cruft from Worldcat URLs
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?worldcat\.org(?:\/title\/[a-zA-Z0-9_-]+)?\/oclc\/([^&?]+)(?:.*)$/, "http://www.worldcat.org/oclc/$1");
      // Standardising IBDb not to use www
      url = url.replace(/^(https?:\/\/)?(www\.)?ibdb\.com/, "http://ibdb.com");
      // Standardising ESTER to their default parameters
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?ester\.ee\/record=([^~]+)(?:.*)?$/, "http://www.ester.ee/record=$1~S1*est");
      // Standardising Trove
      url = url.replace(/^(?:https?:\/\/)?trove\.nla\.gov\.au\/work\/([^\/?#]+)(?:.*)?$/, "http://trove.nla.gov.au/work/$1");
      url = url.replace(/^(?:https?:\/\/)?trove\.nla\.gov\.au\/people\/([^\/?#]+)(?:.*)?$/, "http://nla.gov.au/nla.party-$1");
      url = url.replace(/^(?:https?:\/\/)?nla\.gov\.au\/(nla\.party-|anbd\.bib-an)([^\/?#]+)(?:.*)?$/, "http://nla.gov.au/$1$2");
      // Standardising Musik-Sammler.de
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?musik-sammler\.de\/(album|artist|media)\/([0-9a-z-]+)(?:[\/?#].*)?$/, "https://www.musik-sammler.de/$1/$2/");
      // Standardising Rockens Danmarkskort
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?rockensdanmarkskort\.dk\/steder\/(.*)+$/, "http://www.rockensdanmarkskort.dk/steder/$1");
      // Standardising RIC
      url = url.replace(/^(?:https?:\/\/)?(wiki|www)\.rockinchina\.com\/w\/(.*)+$/, "http://www.rockinchina.com/w/$2");
      // Standardising Rockipedia
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?rockipedia\.no\/(utgivelser|artister|plateselskap)\/(.+)\/.*$/, "http://www.rockipedia.no/$1/$2/");
      // Standardising DHHU
      url = url.replace(/^(?:https?:\/\/)?(www\.)?dhhu\.dk\/w\/(.*)+$/, "http://www.dhhu.dk/w/$2");
      // Standardising Open Library
      url = url.replace(/^(?:https?:\/\/)?(www\.)?openlibrary\.org\/(authors|books|works)\/(OL[0-9]+[AMW]\/)(.*)*$/, "http://openlibrary.org/$2/$3");
      // Standardising Anime News Network
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?animenewsnetwork\.com\/encyclopedia\/(people|company).php\?id=([0-9]+).*$/, "http://www.animenewsnetwork.com/encyclopedia/$1.php?id=$2");
      return url;
    }
  },
  '45cat': {
    match: [new RegExp("^(https?://)?(www\\.)?45cat\\.com/", "i")],
    type: LINK_TYPES.otherdatabases,
    clean: function (url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?45cat\.com\/([a-z]+\/[^\/?&#]+)(?:[\/?&#].*)?$/, "http://www.45cat.com/$1");
    },
    validate: function (url, id) {
      var m = /^http:\/\/www\.45cat\.com\/([a-z]+)\/[^\/?&#]+$/.exec(url);
      if (m) {
        var prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return prefix === 'artist';
          case LINK_TYPES.otherdatabases.label:
            return prefix === 'label';
          case LINK_TYPES.otherdatabases.release:
            return prefix === 'record';
        }
      }
      return false;
    }
  },
  '45worlds': {
    match: [new RegExp("^(https?://)?(www\\.)?45worlds\\.com/", "i")],
    type: LINK_TYPES.otherdatabases,
    clean: function (url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?45worlds\.com\/([0-9a-z]+\/[a-z]+\/[^\/?&#]+)(?:[\/?&#].*)?$/, "http://www.45worlds.com/$1");
    },
    validate: function (url, id) {
      var m = /^http:\/\/www\.45worlds\.com\/([0-9a-z]+)\/([a-z]+)\/[^\/?&#]+$/.exec(url);
      if (m) {
        var world = m[1];
        var prefix = m[2];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return /^(artist|composer|conductor|orchestra|soloist)$/.test(prefix);
          case LINK_TYPES.otherdatabases.event:
            return prefix === 'listing';
          case LINK_TYPES.otherdatabases.label:
            return prefix === 'label';
          case LINK_TYPES.otherdatabases.place:
            return prefix === 'venue';
          case LINK_TYPES.otherdatabases.release:
            return /^(album|cd|media|music|record)$/.test(prefix);
        }
      }
      return false;
    }
  },
  baidubaike: {
    match: [new RegExp("^(https?://)?baike\\.baidu\\.com/", "i")],
    type: LINK_TYPES.otherdatabases,
    clean: function (url) {
      return url.replace(/^(?:https?:\/\/)?baike\.baidu\.com\/([^?#]+)(?:[?#].*)?$/, "http://baike.baidu.com/$1");
    },
    validate: function (url, id) {
      var m = /^http:\/\/baike\.baidu\.com\/(.+)$/.exec(url);
      if (m) {
        var path = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
          case LINK_TYPES.otherdatabases.release_group:
          case LINK_TYPES.otherdatabases.work:
            return /^view\/[1-9][0-9]*\.htm$/.test(path)
              || /^subview(\/[1-9][0-9]*){2}\.htm$/.test(path)
              || /^item\/[^\/]+(?:\/[1-9][0-9]*)?$/.test(path);
        }
      }
      return false;
    }
  },
  bnfcatalogue: {
    match: [
      new RegExp("^(https?://)?(catalogue|data)\\.bnf\\.fr/", "i"),
      new RegExp("^(https?://)?ark\\.bnf\\.fr/ark:/12148/cb", "i"),
    ],
    type: LINK_TYPES.otherdatabases,
    clean: function (url) {
      var m = /^(?:https?:\/\/)?data\.bnf\.fr\/(?:[a-z-]+\/)?([1-4][0-9]{7})(?:[0-9b-z])?(?:[.\/?#].*)?$/.exec(url);
      if (m) {
        var frBnF = m[1];
        var phbt = '0123456789bcdfghjkmnpqrstvwxz';
        var controlChar = phbt[_.reduce(frBnF, function(sum, c, i) {
          return sum + phbt.indexOf(c) * (i + 3);
        }, 2) % 29];
        url = 'http://catalogue.bnf.fr/ark:/12148/cb' + frBnF + controlChar;
      } else {
        m = /^(?:https?:\/\/)?(?:ark|catalogue|data)\.bnf\.fr\/(ark:\/12148\/cb[1-4][0-9]{7}[0-9b-z])(?:[.\/?#].*)?$/.exec(url);
        if (m) {
          var persistentARK = m[1];
          url = 'http://catalogue.bnf.fr/' + persistentARK;
        }
      }
      return url;
    },
    validate: function (url, id) {
      var m = /^http:\/\/catalogue\.bnf\.fr\/ark:\/12148\/cb([1-4])[0-9]{7}[0-9b-z]$/.exec(url);
      if (m) {
        var digit = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
          case LINK_TYPES.otherdatabases.label:
          case LINK_TYPES.otherdatabases.place:
          case LINK_TYPES.otherdatabases.work:
            return digit === '1' || digit === '2';
          case LINK_TYPES.otherdatabases.event:
          case LINK_TYPES.otherdatabases.release:
            return digit === '3' || digit === '4';
          case LINK_TYPES.otherdatabases.series:
            return true;
        }
      }
      return false;
    }
  },
  cancionerosmewiki: {
    match: [new RegExp("^(https?://)?(www\\.)?cancioneros\\.si/mediawiki/", "i")],
    type: LINK_TYPES.otherdatabases,
    clean: function (url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?cancioneros\.si\/([^#]+)(?:[#].*)?$/, "http://www.cancioneros.si/$1");
    },
    validate: function (url, id) {
      return /^http:\/\/www\.cancioneros\.si\/mediawiki\/index\.php\?title=.+$/.test(url)
        && (id === LINK_TYPES.otherdatabases.artist
          || id === LINK_TYPES.otherdatabases.series
            || id === LINK_TYPES.otherdatabases.work);
    }
  },
  cbfiddlerx: {
    match: [new RegExp("^(https?://)?(www\\.)?cbfiddle\\.com/rx/","i")],
    type: LINK_TYPES.otherdatabases,
    clean: function (url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?cbfiddle\.com\/rx\/(rec\/r|tune\/t)(\d+\.html)(?:#.*$)?$/, "http://www.cbfiddle.com/rx/$1$2");
    },
    validate: function (url, id) {
      var m = /^http:\/\/www\.cbfiddle\.com\/rx\/(rec\/r|tune\/t)\d+\.html$/.exec(url);
      if (m) {
        var prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.release_group:
            return prefix === 'rec/r';
          case LINK_TYPES.otherdatabases.work:
            return prefix === 'tune/t';
        }
      }
      return false;
    }
  },
  generasia: {
    match: [new RegExp("^(https?://)?(www\\.)?generasia\\.com/wiki/", "i")],
    type: LINK_TYPES.otherdatabases,
    clean: function (url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?generasia\.com\/wiki\/(.*)$/, "http://www.generasia.com/wiki/$1");
    },
    validate: function (url, id) {
      return id === LINK_TYPES.otherdatabases.artist
          || id === LINK_TYPES.otherdatabases.label
          || id === LINK_TYPES.otherdatabases.release_group
          || id === LINK_TYPES.otherdatabases.work;
    }
  },
  hmikuwiki: {
    match: [new RegExp("^(https?://)?(?:www5\\.)?atwiki\\.jp/hmiku/", "i")],
    type: LINK_TYPES.otherdatabases,
    clean: function (url) {
      return url.replace(/^(?:https?:\/\/)?(?:www5\.)?atwiki\.jp\/([^#]+)(?:#.*)?$/, "https://www5.atwiki.jp/$1");
    },
    validate: function (url, id) {
      return /^https:\/\/www5\.atwiki\.jp\/hmiku\/pages\/[1-9][0-9]*\.html$/.test(url)
        && (id === LINK_TYPES.otherdatabases.artist
          || id === LINK_TYPES.otherdatabases.release_group
            || id === LINK_TYPES.otherdatabases.work);
    }
  },
  irishtune: {
    match: [new RegExp("^(https?://)?(www\\.)?irishtune\\.info","i")],
    type: LINK_TYPES.otherdatabases,
    clean: function (url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?irishtune\.info\/(album\/[A-Za-z+0-9]+|tune\/\d+)(?:[\/?#].*)?$/, "https://www.irishtune.info/$1/");
    },
    validate: function (url, id) {
      var m = /^https:\/\/www\.irishtune\.info\/(?:(album)\/[A-Za-z+0-9]+|(tune)\/\d+)\/$/.exec(url);
      if (m) {
        var prefix = m[1] || m[2];
        switch (id) {
          case LINK_TYPES.otherdatabases.release_group:
            return prefix === 'album';
          case LINK_TYPES.otherdatabases.work:
            return prefix === 'tune';
        }
      }
      return false;
    }
  },
  livefans: {
    match: [new RegExp("^(https?://)?(www\\.)?livefans\\.jp", "i")],
    type: LINK_TYPES.otherdatabases,
    clean: function (url) {
      url = url.replace(/(venues)\/(?:past|future)\//, "$1/");
      url = url.replace(/(venues)\/facility\?.*v_id=([0-9]+).*$/, "$1/$2");
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?livefans\.jp\/([^?#]+[^/?#])\/*(?:[?#].*)?$/, "http://www.livefans.jp/$1");
    },
    validate: function (url, id) {
      var m = /^http:\/\/www\.livefans\.jp\/([a-z]+)\/[0-9]+$/.exec(url);
      if (m) {
        var prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return prefix === 'artists';
          case LINK_TYPES.otherdatabases.event:
            return prefix === 'events';
          case LINK_TYPES.otherdatabases.series:
            return prefix === 'groups';
          case LINK_TYPES.otherdatabases.place:
            return prefix === 'venues';
        }
      }
      return false;
    }
  },
  musicapopularcl: {
    match: [new RegExp("^(https?://)?(www\\.)?musicapopular\\.cl", "i")],
    type: LINK_TYPES.otherdatabases,
    clean: function (url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?musicapopular\.cl((?:\/[^\/?#]+){2})\/?(?:#.*)?$/, "http://www.musicapopular.cl$1/");
    },
    validate: function (url, id) {
      var m = /^http:\/\/www\.musicapopular\.cl\/(artista|disco|grupo)\/[^\/]+\/$/.exec(url);
      if (m) {
        var prefix = m[1] || m[2];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return prefix === 'artista' || prefix === 'grupo';
          case LINK_TYPES.otherdatabases.release_group:
            return prefix === 'disco';
        }
      }
      return false;
    }
  },
  rockcomar: {
    match: [new RegExp("^(https?://)?(www\\.)?rock\\.com\\.ar", "i")],
    type: LINK_TYPES.otherdatabases,
    clean: function (url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?rock\.com\.ar\/([^#]+)(?:#.*)?$/, "http://rock.com.ar/$1");
      url = url.replace(/^(http:\/\/rock\.com\.ar\/artistas\/[1-9][0-9]*)\/(?:[a-z]*|fotos\/[1-9][0-9]*)?$/, "$1");
      return url;
    },
    validate: function (url, id) {
      var m = /^http:\/\/rock\.com\.ar\/artistas\/[1-9][0-9]*(?:\/(discos|letras)\/[1-9][0-9]*)?$/.exec(url);
      if (m) {
        var subsection = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return !subsection;
          case LINK_TYPES.otherdatabases.release_group:
            return subsection === 'discos';
          case LINK_TYPES.otherdatabases.work:
            return subsection === 'letras';
        }
      }
      // Keep validating URLs from before Rock.com.ar 2017 relaunch
      m = /^http:\/\/rock\.com\.ar\/(?:(bios|discos|letras)(?:\/[0-9]+){2}\.shtml|(artistas)\/.+)$/.exec(url);
      if (m) {
        var prefix = m[1] || m[2];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return prefix === 'artistas' || prefix === 'bios';
          case LINK_TYPES.otherdatabases.release_group:
            return prefix === 'discos';
          case LINK_TYPES.otherdatabases.work:
            return prefix === 'letras';
        }
      }
      return false;
    }
  },
  soundtrackcollector: {
    match: [new RegExp("^(https?://)?(www\\.)?soundtrackcollector\\.com", "i")],
    type: LINK_TYPES.otherdatabases,
    clean: function (url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?soundtrackcollector\.com\/(composer|title)\/([0-9]+).*$/, "http://soundtrackcollector.com/$1/$2/");
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?soundtrackcollector\.com\/.*\?movieid=([0-9]+).*$/, "http://soundtrackcollector.com/title/$1/");
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?soundtrackcollector\.com\/.*\?composerid=([0-9]+).*$/, "http://soundtrackcollector.com/composer/$1/");
      return url;
    },
    validate: function (url, id) {
      var m = /^http:\/\/soundtrackcollector\.com\/([a-z]+)\/[0-9]+\/$/.exec(url);
      if (m) {
        var prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return prefix === 'composer';
          case LINK_TYPES.otherdatabases.release_group:
            return prefix === 'title';
        }
      }
      return false;
    }
  },
  thesession: {
    match: [new RegExp("^(https?://)?(www\\.)?thesession\\.org", "i")],
    type: LINK_TYPES.otherdatabases,
    clean: function (url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?thesession\.org\/(tunes|events|recordings(?:\/artists)?)(?:\/.*)?\/([0-9]+)(?:.*)?$/, "http://thesession.org/$1/$2");
    },
    validate: function (url, id) {
      var m = /^http:\/\/thesession\.org\/([a-z\/]+)\/[0-9]+$/.exec(url);
      if (m) {
        var prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return prefix === 'recordings/artists';
          case LINK_TYPES.otherdatabases.event:
            return prefix === 'events';
          case LINK_TYPES.otherdatabases.release_group:
            return prefix === 'recordings';
          case LINK_TYPES.otherdatabases.work:
            return prefix === 'tunes';
        }
      }
      return false;
    }
  },
  utaitedbvocadb: {
    match: [new RegExp("^(https?://)?(www\\.)?(utaite|voca)db\\.net", "i")],
    type: LINK_TYPES.otherdatabases,
    clean: function (url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?(utaite|voca)db\.net\/((?:[A-Za-z]+\/){1,2}0*[1-9][0-9]*)(?:[\/?#].*)?$/, "http://$1db.net/$2");
      url = url.replace(/Artist\/(Details|Edit|Versions)/, "Ar");
      url = url.replace(/Album\/(Details|DownloadTags|Edit|Related|Versions)/, "Al");
      url = url.replace(/Event\/(Details|Edit|Versions)/, "E");
      return url.replace(/Song\/(Details|Edit|Related|Versions)/, "S");
    },
    validate: function (url, id) {
      var m = /^http:\/\/(?:utaite|voca)db\.net\/([A-Za-z]+(?:\/[A-Za-z]+)?)\/[1-9][0-9]*$/.exec(url);
      if (m) {
        var prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
          case LINK_TYPES.otherdatabases.label:
            return prefix === 'Ar';
          case LINK_TYPES.otherdatabases.event:
            return prefix === 'E';
          case LINK_TYPES.otherdatabases.recording:
          case LINK_TYPES.otherdatabases.work:
            return prefix === 'S';
          case LINK_TYPES.otherdatabases.release_group:
            return prefix === 'Al';
          case LINK_TYPES.otherdatabases.series:
            return prefix === 'Event/SeriesDetails';
        }
      }
      return false;
    }
  },
  patronage: {
    match: [
      new RegExp("^(https?://)?(www\\.)?changetip\\.com/tipme/[^/?#]", "i"),
      new RegExp("^(https?://)?[^/?#]+\\.tip.me([/?#].*)?$", "i"),
      new RegExp("^(https?://)?(www\\.)?flattr\\.com/profile/[^/?#]", "i"),
      new RegExp("^(https?://)?(www\\.)?patreon\\.com/[^/?#]", "i"),
      new RegExp("^(https?://)?(www\\.)?paypal\\.me/[^/?#]", "i"),
      new RegExp("^(https?://)?(www\\.)?tipeee\\.com/[^/?#]", "i"),
    ],
    type: LINK_TYPES.patronage,
    clean: function (url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?changetip\.com\/tipme\/([^\/?#]+)(?:.*)?$/, "https://www.changetip.com/tipme/$1");
      url = url.replace(/^(?:https?:\/\/)?([^\/?#]+)\.tip\.me(?:[\/?#].*)?$/, "https://www.changetip.com/tipme/$1");
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?flattr\.com\/profile\/([^\/?#]+)(?:.*)?$/, "https://flattr.com/profile/$1");
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?patreon\.com\/([^\/?#]+)(?:.*)?$/, "https://www.patreon.com/$1");
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?paypal\.me\/([^\/?#]+)(?:.*)?$/, "https://www.paypal.me/$1");
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?tipeee\.com\/([^\/?#]+)(?:.*)?$/, "https://www.tipeee.com/$1");
      return url;
    }
  },
  crowdfunding: {
    match: [
      new RegExp("^(https?://)?(www\\.)?indiegogo\\.com/(individuals|projects)/", "i"),
      new RegExp("^(https?://)?(www\\.)?kickstarter\\.com/(profile|projects)/", "i"),
    ],
    type: LINK_TYPES.crowdfunding,
    clean: function (url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?indiegogo\.com\/individuals\/(\d+)(?:[\/?#].*)?$/, "https://www.indiegogo.com/individuals/$1");
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?indiegogo\.com\/projects\/([\w\-]+)(?:[\/?#].*)?$/, "https://www.indiegogo.com/projects/$1");
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?kickstarter\.com\/profile\/([\w\-]+)(?:[\/?#].*)?$/, "https://www.kickstarter.com/profile/$1");
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?kickstarter\.com\/projects\/(\d+)\/([\w\-]+)(?:[\/?#].*)?$/, "https://www.kickstarter.com/projects/$1/$2");
      return url;
    }
  }
};

function testAll(tests, text) {
  for (var i = 0; i < tests.length; i++) {
    if (tests[i].test(text)) {
      return true;
    }
  }
}

const validationRules = {};

_.each(LINK_TYPES, function (linkType) {
  _.each(linkType, function (id, entityType) {
    if (!validationRules[id]) {
      validationRules[id] = function (url) {
        var cleanup = _.find(CLEANUPS, function (cleanup) {
          return testAll(cleanup.match, url);
        });
        if (cleanup && cleanup.type && cleanup.type[entityType]) {
          return cleanup.type[entityType] === id
            && (!cleanup.validate || cleanup.validate(url, id));
        } else {
          return RESTRICTED_LINK_TYPES.indexOf(id) === -1;
        }
      };
    }
  });
});

// avoid Wikipedia being added as release-level discography entry
var originalRule = validationRules[LINK_TYPES.discographyentry.release];
validationRules[LINK_TYPES.discographyentry.release] = function (url) {
  if (/^(https?:\/\/)?([^.\/]+\.)?wikipedia\.org\//.test(url)) {
    return false;
  }
  return originalRule(url);
};

function guessType(sourceType, currentURL) {
  var cleanup = _.find(CLEANUPS, function (cleanup) {
    return (cleanup.type || {})[sourceType] && testAll(cleanup.match, currentURL);
  });

  return cleanup && cleanup.type[sourceType];
}

function cleanURL(dirtyURL) {
  dirtyURL = dirtyURL.trim().replace(/(%E2%80%8E|\u200E)$/, "");

  var cleanup = _.find(CLEANUPS, function (cleanup) {
    return cleanup.clean && testAll(cleanup.match, dirtyURL);
  });

  return cleanup ? cleanup.clean(dirtyURL) : dirtyURL;
}

function registerEvents($url) {
  function urlChanged(event) {
    var url = $url.val();
    var clean = cleanURL(url) || url;

    if (url.match(/^\w+\./)) {
      $url.val('http://' + url);
      return;
    }

    // Allow adding spaces while typing; they'll be trimmed later onblur.
    if (url.trim() !== clean) {
      $url.val(clean);
    }
  }

  $url.on('input', urlChanged)
  .on('blur', function () {
    this.value = this.value.trim()
  })
  .parents('form').on('submit', urlChanged);
}

exports.LINK_TYPES = LINK_TYPES;
exports.validationRules = validationRules;
exports.guessType = guessType;
exports.cleanURL = cleanURL;
exports.registerEvents = registerEvents;
