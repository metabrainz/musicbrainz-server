/*
 * @flow
 * Copyright (C) 2010 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

import {arraysEqual} from '../common/utility/arrays.js';

type EntityTypes = string | $ReadOnlyArray<string>;

type EntityTypesMap = {
  +[entityType: RelatableEntityTypeT]: EntityTypes,
};

type EntityTypeMap = {
  +[entityType: RelatableEntityTypeT]: string,
};

type LinkTypeMap = {
  +[type: string]: EntityTypeMap,
};

export type RelationshipTypeT =
  | string // Single type
  | $ReadOnlyArray<string>; // A type combination

// See https://musicbrainz.org/relationships (but deprecated ones)
export const LINK_TYPES: LinkTypeMap = {
  allmusic: {
    artist: '6b3e3c85-0002-4f34-aca6-80ace0d7e846',
    genre: '6da144de-911b-49c5-81eb-bd8303b3f6b4',
    recording: '54482490-5ff1-4b1c-9382-b4d0ef8e0eac',
    release: '90ff18ad-3e9d-4472-a3d1-71d4df7e8484',
    release_group: 'a50a1d20-2b20-4d2c-9a29-eb771dd78386',
    work: 'ca9c9f46-11bd-423a-b134-9109cbebe9d7',
  },
  amazon: {
    release: '4f2e710d-166c-480c-a293-2e2c8d658d87',
  },
  artgallery: {
    artist: '8203341a-27be-40bb-b755-08d8ca9d7a9c',
  },
  bandcamp: {
    artist: 'c550166e-0548-4a18-b1d4-e2ae423a3e88',
    genre: 'ad28869f-0f9e-4bd5-b786-70125cc69c3c',
    label: 'c535de4c-a112-4974-b138-5e0daa56eab5',
  },
  bandsintown: {
    artist: 'ea45ed3d-2d5e-456e-8c32-94b6f51426e2',
    event: '81bc32b3-7039-486a-a92f-52486fb7e162',
    place: '0e41b9de-20d8-4d1a-869d-7018e1045439',
  },
  bbcmusic: {
    artist: 'd028a975-000c-4525-9333-d3c8425e4b54',
  },
  blog: {
    artist: 'eb535226-f8ca-499d-9b18-6a144df4ae6f',
    label: '1b431eba-0d25-4f27-9151-1bb607f5c8f8',
    place: 'e3051f32-527b-4c47-9993-71250a6cd99c',
  },
  bookbrainz: {
    artist: 'f82f9342-a08d-46b7-ab7a-d8b6330c805d',
    label: 'b7be2ca4-bdb7-4d87-9619-f2fa50120409',
    release: '63b84620-ba52-4630-9bfe-8ad3b5504dff',
    release_group: '27cfc95c-d368-45a9-ae0d-308c274c2017',
    series: 'fe60d685-8064-4501-baab-e2de8ff52a27',
    work: '0ea7cf4e-93dd-4bc4-b748-0f1073cf951c',
  },
  cdbaby: {
    artist: '4c21e5f5-2960-4abc-88a1-62ce491bb96e',
  },
  cpdl: {
    artist: '991d7d60-01ee-41de-9b62-9ef3f86c2447',
  },
  crowdfunding: {
    artist: '93883cf6-e818-4938-990e-75863f8db2d3',
    event: '61187747-04d3-4d15-889a-0ceedaecf0aa',
    label: '16f681e4-93c9-4888-ae5e-3163f01269ab',
    place: '09328447-f070-463e-a760-a419ffc115bf',
    recording: 'f9d9946e-0cea-4e47-9d3b-be4be55397a8',
    release: 'e1434bc9-5e54-4b10-b3f6-db09e6f0cb44',
    release_group: '6aec99c1-8817-4d91-8fd0-1028cb467b62',
    series: 'b4894e57-5e32-479f-b1e7-bc561048ce48',
  },
  discography: {
    artist: '4fb0eeec-a6eb-4ae3-ad52-b55765b94e8f',
  },
  discographyentry: {
    release: '823656dd-0309-4247-b282-b92d287d59c5',
  },
  discogs: {
    artist: '04a5b104-a4c2-4bac-99a1-7b837c37d9e4',
    genre: '4c8510c9-1dc2-49b9-9693-27bdc5cc8311',
    label: '5b987f87-25bc-4a2d-b3f1-3618795b8207',
    place: '1c140ac8-8dc2-449e-92cb-52c90d525640',
    release: '4a78823c-1c53-4176-a5f3-58026c76f2bc',
    release_group: '99e550f3-5ab4-3110-b5b9-fe01d970b126',
    series: '338811ef-b1a9-449d-954e-115846f33a44',
    work: 'd78b7280-eb9e-4a57-86c3-cedaa1aa2175',
  },
  downloadfree: {
    artist: '34ae77fe-defb-43ea-95d4-63c7540bac78',
    label: '46505eea-05d6-48cc-ad78-1f79abc556e1',
    recording: '45d0cbc5-d65b-4e77-bdfd-8a75207cb5c5',
    release: '9896ecd0-6d29-482d-a21e-bd5d1b5e3425',
  },
  downloadpurchase: {
    artist: 'f8319a2f-f824-4617-81c8-be6560b3b203',
    label: 'dc1a65f4-6458-4f3d-bbb1-57e58668d6e7',
    recording: '92777657-504c-4acb-bd33-51a201bd57e1',
    release: '98e08c20-8402-4163-8970-53504bb6a1e4',
  },
  geonames: {
    area: 'c52f14c0-e9ac-4a8a-8f7a-c47328de168f',
    place: 'c4c6356f-9cbc-4e26-ae76-63eef96d059d',
  },
  image: {
    artist: '221132e9-e30e-43f2-a741-15afc4c5fa7c',
    instrument: 'f64eacbd-1ea1-381e-9886-2cfb552b7d90',
    label: 'b35f7822-bf3c-4148-b306-fb723c63ee8b',
    place: '68a4537c-f2a6-49b8-81c5-82a62b0976b7',
  },
  imdb: {
    artist: '94c8b0cc-4477-4106-932c-da60e63de61c',
    label: 'dfd36bc7-0c06-49fa-8b79-96978778c716',
    place: '815bc5ca-c2fb-4dc6-a89b-9150888b0d4d',
    // recording and release are the "samples from" version of the IMDb rel
    recording: 'dad34b86-5a1a-4628-acf5-a48ccb0785f2',
    release: '7387c5a2-9abe-4515-b667-9eb5ed4dd4ce',
    release_group: '85b0a010-3237-47c7-8476-6fcefd4761af',
    work: 'e5c75559-4dda-452e-a900-ae375935164c',
  },
  imslp: {
    artist: '8147b6a2-ad14-4ce7-8f0a-697f9a31f68f',
  },
  interview: {
    artist: '1f171391-1f98-4f45-b191-038ec3b12395',
  },
  lastfm: {
    artist: '08db8098-c0df-4b78-82c3-c8697b4bba7f',
    event: 'fd86b01d-c8f7-4f0a-a077-81855a9cfeef',
    label: 'e3390a1d-3083-4bc9-9295-aff9da18612c',
    place: 'c3ddb53d-a7df-4486-8cc7-c1b7baec994e',
  },
  license: {
    recording: 'f25e301d-b87b-4561-86a0-5d2df6d26c0a',
    release: '004bd0c3-8a45-4309-ba52-fa99f3aa3d50',
    work: '770ea9f4-cba0-4194-b77f-fe2740055e34',
  },
  lyrics: {
    artist: 'e4d73442-3762-45a8-905c-401da65544ed',
    label: '9eb3977f-2aa2-41dd-bbff-0cadda5ad484',
    release_group: '156344d3-da8b-40c6-8b10-7b1c22727124',
    work: 'e38e65aa-75e0-42ba-ace0-072aeb91a538',
  },
  mailorder: {
    artist: '611b1862-67af-4253-a64f-34adba305d1d',
    label: '607deff9-31a8-4b8c-a971-d873cf59ef16',
    release: '3ee51e05-a06a-415e-b40c-b3f740dedfd7',
  },
  myspace: {
    artist: 'bac47923-ecde-4b59-822e-d08f0cd10156',
    label: '240ba9dc-9898-4505-9bf7-32a53a695612',
    place: 'c809cb4a-2835-44fb-bc64-fd4882bd389c',
  },
  onlinecommunity: {
    artist: '35b3a50f-bf0e-4309-a3b4-58eeed8cee6a',
  },
  otherdatabases: {
    artist: 'd94fb61c-fa20-4e3c-a19a-71a949fb2c55',
    event: '1e06fb0b-831d-49cf-abfd-52acb5b56e05',
    genre: '1873eeea-f2e6-4e08-a754-cc92567983ea',
    instrument: '41930af2-cb94-488d-a4f0-d232f6ef391a',
    label: '83eca2b3-5ae1-43f5-a732-56fa9a8591b1',
    place: '87a0a644-0a69-46c0-9e48-0656b8240d89',
    recording: 'bc21877b-e993-42ed-a7ce-9187ec9b638f',
    release: 'c74dee45-3c85-41e9-a804-92ab1c654446',
    release_group: '38320e40-9f4a-3ae7-8cb2-3f3c9c5d856d',
    series: '8a08d0f5-c7c4-4572-9d22-cee92693d820',
    work: '190ea031-4355-405d-a43e-53eb4c5c4ada',
  },
  patronage: {
    artist: '6f77d54e-1d81-4e1a-9ea5-37947577151b',
    event: 'f0f05915-64ac-45fb-a9b3-1bf24cd191d9',
    label: 'e3d9c283-0146-4d91-9471-1b491a9c17ef',
    place: 'f14b4e5f-0884-4bb0-b3fa-134cc2734f0e',
    series: '492a4e07-0ea9-4e82-870b-cab942b0576f',
  },
  purevolume: {
    artist: 'b6f02157-a9d3-4f24-9057-0675b2dbc581',
  },
  review: {
    release_group: 'c3ac9c3b-f546-4d15-873f-b294d2c1b708',
  },
  score: {
    work: '0cc8527e-ea40-40dd-b144-3b7588e759bf',
  },
  secondhandsongs: {
    artist: '79c5b84d-a206-4f4c-9832-78c028c312c3',
    label: 'e46c1166-2aae-4623-ade9-34bd067dfe02',
    recording: 'a98fb02f-f289-4778-b34e-2625d922e28f',
    release: '0e555925-1b7d-475c-9b25-b9c349dcc3f3',
    work: 'b80dff64-9560-445a-b824-c8b432d77a52',
  },
  setlistfm: {
    artist: 'bf5d0d5e-27a1-4e94-9df7-3cdc67b3b207',
    event: '027fce0c-c621-4fd1-b728-1678ae08f280',
    place: '751e8fb1-ed8d-4a94-b71b-a38065054f5d',
    series: 'de143a8b-ea80-4b26-9246-f1ce498d4b01',
  },
  shownotes: {
    release: '2d24d075-9943-4c4d-a659-8ce52e6e6b57',
  },
  socialnetwork: {
    artist: '99429741-f3f6-484b-84f8-23af51991770',
    event: '68f5fcaa-b58c-3bfe-9b7c-75c2b56e839a',
    label: '5d217d99-bc05-4a76-836d-c91eec4ba818',
    place: '040de4d5-ace5-4cfb-8a45-95c5c73bce01',
    series: '80d5e037-9aa7-3d80-80da-fb01d6dbc25b',
  },
  songfacts: {
    work: '80402bbc-1aec-41d1-a5be-b599b89bc3c3',
  },
  songkick: {
    artist: 'aac9c4bc-a5b9-30b8-9839-e3ac314c6e58',
    event: '125afc57-4d33-3b63-ab41-848a3a18d3a6',
    place: '3eb58d3e-6f00-36a8-a115-3dad616b7391',
  },
  soundcloud: {
    artist: '89e4a949-0976-440d-bda1-5f772c1e5710',
    label: 'a31d05ba-3b82-47b2-ab8b-1fe73b5459e2',
    place: '1cd2eb89-2997-4901-87e9-838ac9a68da9',
    series: '4789521b-57b9-4689-9644-46de63190f66',
  },
  streamingfree: {
    artist: '769085a1-c2f7-4c24-a532-2375a77693bd',
    label: '5b3d2907-5cd0-459b-9a33-d4398a544388',
    recording: '7e41ef12-a124-4324-afdb-fdbae687a89c',
    release: '08445ccf-7b99-4438-9f9a-fb9ac18099ee',
  },
  streamingpaid: {
    artist: '63cc5d1f-f096-4c94-a43f-ecb32ea94161',
    label: 'cbe05bdd-a877-4cc6-8060-7ba43a2516ef',
    recording: 'b5f3058a-666c-406f-aafb-f9249fc7b122',
    release: '320adf26-96fa-4183-9045-1f5f32f833cb',
  },
  ticketing: {
    artist: '34beaf28-cbdd-4bf7-bc41-e7de18135245',
    event: 'bf0f91b9-d97e-4a7b-9114-f1db1e0b61de',
    label: '705f4b36-b12e-41e4-a5f2-57e2de83ca6a',
    place: '914021c7-01f9-4578-b3e3-1a4b0f6453a7',
    series: 'bb8ad711-4667-4395-9bfa-453b1299a79b',
  },
  vgmdb: {
    artist: '0af15ab3-c615-46d6-b95b-a5fcd2a92ed9',
    event: '5d3e0348-71a8-3dc1-b847-3a8f1d5de688',
    label: '8a2d3e55-d291-4b99-87a0-c59c6b121762',
    place: 'f11ffda6-d59a-45bf-9b07-74b08335b5fa',
    release: '6af0134a-df6a-425a-96e2-895f9cd342ba',
    work: 'bb250727-5090-4568-af7b-be8545c034bc',
  },
  viaf: {
    artist: 'e8571dcc-35d4-4e91-a577-a3382fd84460',
    label: 'c4bee4f4-e622-4c74-b80b-585989de27f4',
    place: '49a08641-0aed-4e10-8311-ec220b8c50ad',
    series: '67764397-d154-4f9a-8aa8-cbc4de4df5b8',
    work: 'b6eaef52-68a0-4b50-b875-8acd7d9212ba',
  },
  videochannel: {
    artist: 'd86c9450-b6d0-4760-a275-e7547495b48b',
    event: '1f3df2eb-3d0b-44f1-9599-1309c692bc7c',
    label: '20ad367c-cba0-4c02-bd61-2df3ae8cc799',
    place: 'e5c5a0f6-9581-44d8-a5fb-d3688254dc9f',
    series: '71774032-781b-468c-9cbf-8a9a2f8eda13',
  },
  wikidata: {
    area: '85c5256f-aef1-484f-979a-42007218a1c2',
    artist: '689870a4-a1e4-4912-b17f-7b2664215698',
    event: 'b022d060-e6a8-340f-8c73-6b21b1d090b9',
    genre: '11a13c3b-15cb-4c1c-accc-0417f7f2019b',
    instrument: '1486fccd-cf59-35e4-9399-b50e2b255877',
    label: '75d87e83-d927-4580-ba63-44dc76256f98',
    place: 'e6826618-b410-4b8d-b3b5-52e29eac5e1f',
    release_group: 'b988d08c-5d86-4a57-9557-c83b399e3580',
    series: 'a1eecd98-f2f2-420b-ba8e-e5bc61697869',
    work: '587fdd8f-080e-46a9-97af-6425ebbcb3a2',
  },
  wikipedia: {
    area: '9228621d-9720-35c3-ad3f-327d789464ec',
    artist: '29651736-fa6d-48e4-aadc-a557c6add1cb',
    event: '08a982f7-d754-39b2-8315-d7cae474c641',
    instrument: 'b21fd997-c813-3bc6-99cc-c64323bd15d3',
    label: '51e9db21-8864-49b3-aa58-470d7b81fa50',
    place: '82680bbb-0391-4344-9687-4f419df4b97a',
    release_group: '6578f0e9-1ace-4095-9de8-6e517ddb1ceb',
    series: 'b2b9407a-dd32-30f4-aa48-b2fd2077d1d2',
    work: 'b45a88d6-851e-4a6e-9ec8-9a5f4ebe76ab',
  },
  youtube: {
    artist: '6a540e5b-58c6-4192-b6ba-dbc71ec8fcf0',
    event: 'fea46163-dc45-3af9-917e-1798f325d21a',
    label: 'd9c71059-ba9d-4135-b909-481d12cf84e3',
    place: '22ec436d-bb65-4c83-a268-0fdb0dbd8834',
    series: 'f23802a4-36be-3751-8e4d-93422e08b3e8',
  },
  youtubemusic: {
    artist: '631712a0-7525-42ba-b7a3-605aa7a238c4',
  },
};

// See https://musicbrainz.org/doc/Style/Relationships/URLs#Restricted_relationships

export const RESTRICTED_LINK_TYPES: $ReadOnlyArray<string> = [
  LINK_TYPES.allmusic,
  LINK_TYPES.amazon,
  LINK_TYPES.bandcamp,
  LINK_TYPES.bandsintown,
  LINK_TYPES.bbcmusic,
  LINK_TYPES.bookbrainz,
  LINK_TYPES.cpdl,
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
].reduce(function (result, linkType) {
  return result.concat(Object.values(linkType));
}, []);

export const ERROR_TARGETS = {
  ENTITY: 'entity',
  NONE: 'none',
  RELATIONSHIP: 'relationship',
  URL: 'url',
};

function reencodeMediawikiLocalPart(url: string) {
  const m = url.match(/^(https?:\/\/[^/]+\/wiki\/)([^?#]+)(.*)$/);
  if (m) {
    url = m[1] + encodeURIComponent(decodeURIComponent(m[2])).replace(/%20/g, '_').replace(/%24/g, '$')
      .replace(/%2C/g, ',')
      .replace(/%2F/g, '/')
      .replace(/%3A/g, ':')
      .replace(/%3B/g, ';')
      .replace(/%40/g, '@') + m[3];
  }
  return url;
}

function findAmazonTld(url: string) {
  let tld = '';
  let m;

  if ((m = url.match(/(?:amazon|amzn)\.([a-z.]+)\//))) {
    tld = m[1];
    if (tld === 'jp') {
      tld = 'co.jp';
    }
    if (tld === 'at') {
      tld = 'de';
    }
  }
  return tld;
}

const linkToChannelMsg = N_l(
  `Please link to a channel, not a specific video.
   Videos should be linked to the appropriate
   recordings or releases instead.`,
);

const noLinkToSearchMsg = N_l(
  `This is a link to a search result. Please link to any page in the results
   that is relevant to this entity instead, if available.`,
);

const linkToVideoMsg = N_l(
  `Please link to a specific video. Add channel pages
   to the relevant artist, label, etc. instead.`,
);

const linkAsLyricsMsg = N_l(
  `This is a lyrics site. As such, links to the site should be added
   at the release group level with the “lyrics” relationship,
   rather than directly to any specific release.`,
);

/*
 * CLEANUPS entries have 2 to 5 of the following properties:
 *
 * - match: Array of regexps to match a given URL with the entry.
 *          It is the only mandatory property.
 * - restrict: Array of possible relationship types for the matched URL.
 *             May contain 1 or more relationship type by entity type.
 *             You can use multiple() to combine multiple types.
 *             Will be used in auto-selection and validation.
 *             If there's only one type or type combination,
 *             it will be auto-selected.
 * - select: Custom function for auto-selection of relationship type(s).
 *           To select a single type, return a string,
 *           e.g: LINK_TYPES.otherdatabases.release.
 *           To select multiple types, return an array of strings,
 *           e.g: [
 *             LINK_TYPES.otherdatabases.work,
 *             LINK_TYPES.lyrics.work,
 *           ].
 *           If it can't be determined, return false,
 *           that'll fall back to traditional auto-selection using `restrict`.
 * - clean: Function to clean up/normalize matched URL.
 * - validate: Function to validate matched (clean) URL
 *             for an auto-selected relationship type.
 */

type ValidationResult = {
  +error?: React.Node,
  result: boolean,
  +target?: $Values<typeof ERROR_TARGETS>,
};

type CleanupEntry = {
  +clean?: (url: string) => string,
  +match: $ReadOnlyArray<RegExp>,
  +restrict?: $ReadOnlyArray<EntityTypesMap>,
  +select?:
    (url: string, sourceType: RelatableEntityTypeT) =>
    | RelationshipTypeT
    | false, // No match
  +validate?: (url: string, id: string) => ValidationResult,
};

type CleanupEntries = {
  +[type: string]: CleanupEntry,
};

/* eslint-disable sort-keys */
const CLEANUPS: CleanupEntries = {
  '7digital': {
    match: [/^(https?:\/\/)?([^/]+\.)?(7digital\.com|zdigital\.com\.au)/i],
    restrict: [LINK_TYPES.downloadpurchase],
    clean(url) {
      // Standardise to https
      url = url.replace(/^https?:\/\/(.*)$/, 'https://$1');
      // Remove yourmusic + id from link for own purchases
      url = url.replace(/^https:\/\/([^/]+\.)?(7digital\.com|zdigital\.com\.au)\/yourmusic\/(.*)\/[\d]+\/?$/, 'https://$1$2/$3');
      url = url.replace(/([^&?#]+)(?:.*)$/, '$1');
      return url;
    },
  },
  '45cat': {
    match: [/^(https?:\/\/)?(www\.)?45cat\.com\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?45cat\.com\/([a-z]+\/[^/?&#]+)(?:[/?&#].*)?$/, 'https://www.45cat.com/$1');
    },
    validate(url, id) {
      const m = /^https:\/\/www\.45cat\.com\/([a-z]+)\/[^/?&#]+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.label:
            return {
              result: prefix === 'label',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release_group:
            return {
              result: prefix === 'record',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  '45worlds': {
    match: [/^(https?:\/\/)?(www\.)?45worlds\.com\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?45worlds\.com\/([0-9a-z]+\/[a-z]+\/[^/?&#]+)(?:[/?&#].*)?$/, 'https://www.45worlds.com/$1');
    },
    validate(url, id) {
      const m = /^https:\/\/www\.45worlds\.com\/([0-9a-z]+)\/([a-z]+)\/[^/?&#]+$/.exec(url);
      if (m) {
        const prefix = m[2];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: /^(artist|composer|conductor|orchestra|soloist)$/.test(prefix),
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.event:
            return {
              result: prefix === 'listing',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.label:
            return {
              result: prefix === 'label',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.place:
            return {
              result: prefix === 'venue',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release_group:
            return {
              result: /^(album|cd|media|music|record)$/.test(prefix),
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'allmusic': {
    match: [/^(https?:\/\/)?([^/]+\.)?allmusic\.com/i],
    restrict: [LINK_TYPES.allmusic],
    clean(url) {
      return url.replace(/^https?:\/\/(?:[^.]+\.)?allmusic\.com\/(artist|album(?:\/release)?|composition|genre|song|style|performance)\/(?:[^/]*-)?((?:ma|mn|mw|mc|mt|mq|mr)[0-9]+).*/, 'https://www.allmusic.com/$1/$2');
    },
    validate(url, id) {
      const m = /^https:\/\/www\.allmusic\.com\/([a-z/]+)[0-9]{10}$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.allmusic.artist:
            return {
              result: prefix === 'artist/mn',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.allmusic.genre:
            return {
              result: prefix === 'genre/ma' || prefix === 'style/ma',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.allmusic.recording:
            return {
              result: prefix === 'performance/mq',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.allmusic.release:
            if (prefix === 'album/mw') {
              return {
                error: exp.l(
                  `Allmusic “{album_url_pattern}” links should be added to
                   release groups.
                   To find the appropriate release link for this release,
                   please check the Releases tab from {album_url|your link}.`,
                  {
                    album_url: {
                      href: url,
                      rel: 'noopener noreferrer',
                      target: '_blank',
                    },
                    album_url_pattern: (
                      <span className="url-quote">{'/album'}</span>
                    ),
                  },
                ),
                result: false,
                target: ERROR_TARGETS.ENTITY,
              };
            }
            return {
              result: prefix === 'album/release/mr',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.allmusic.release_group:
            return {
              result: prefix === 'album/mw',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.allmusic.work:
            return {
              result: prefix === 'composition/mc' ||
                prefix === 'song/mt',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'amazon': {
    match: [
      /^(https?:\/\/)?(((?!music)[^/])+\.)?(amazon\.(ae|at|com\.au|com\.br|ca|cn|com|de|eg|es|fr|in|it|jp|co\.jp|com\.mx|nl|pl|sa|se|sg|com\.tr|co\.uk)|amzn\.com)/i,
      /^(https?:\/\/)?([^/]+\.)?amzn\.to/i,
    ],
    restrict: [LINK_TYPES.amazon],
    clean(url) {
      /*
       * determine tld, asin from url, and build standard format [1],
       * if both were found. There used to be another [2], but we'll
       * stick to the new one for now.
       *
       * [1] "https://www.amazon.<tld>/gp/product/<ASIN>"
       * [2] "http://www.amazon.<tld>/exec/obidos/ASIN/<ASIN>"
       */
      let tld = '';
      let asin = '';
      let m;

      tld = findAmazonTld(url);

      if ((m = url.match(/\/e\/([A-Z0-9]{10})(?:[/?&%#]|$)/))) { // artist pages
        return 'https://www.amazon.' + tld + '/-/e/' + m[1];
      } else if ((m = url.match(/\/(?:product|dp)\/(B[0-9A-Z]{9}|[0-9]{9}[0-9X])(?:[/?&%#]|$)/))) { // strict regex to catch most ASINs
        asin = m[1];
      } else if ((m = url.match(/(?:\/|\ba=)([A-Z0-9]{10})(?:[/?&%#]|$)/))) { // if all else fails, find anything that could be an ASIN
        asin = m[1];
      }

      if (tld !== '' && asin !== '') {
        return 'https://www.amazon.' + tld + '/gp/product/' + asin;
      }

      return url;
    },
    validate(url) {
      if (/amzn\.to\//i.test(url)) {
        return {
          error: exp.l(
            `This is a redirect link. Please follow {redirect_url|your link}
             and add the link it redirects to instead.`,
            {
              redirect_url: {
                href: url,
                rel: 'noopener noreferrer',
                target: '_blank',
              },
            },
          ),
          result: false,
          target: ERROR_TARGETS.URL,
        };
      }

      if (/^https:\/\/www\.amazon\.[^/]+\/vdp\//i.test(url)) {
        return {
          error: l(
            `This is a link to a user video and should not be added. Please
             add the product link instead, if relevant.`,
          ),
          result: false,
          target: ERROR_TARGETS.URL,
        };
      }

      // If you change this, please update the BadAmazonURLs report.
      return {
        result: /^https:\/\/www\.amazon\.(ae|at|com\.au|com\.br|ca|cn|com|de|eg|es|fr|in|it|jp|co\.jp|com\.mx|nl|pl|sa|se|sg|com\.tr|co\.uk)\//.test(url),
        target: ERROR_TARGETS.URL,
      };
    },
  },
  'amazonmusic': {
    match: [/^(https?:\/\/)?music\.amazon\.(ae|at|com\.au|com\.br|ca|cn|com|de|es|fr|in|it|jp|co\.jp|com\.mx|nl|pl|se|sg|com\.tr|co\.uk)\/(albums|artists)/i],
    restrict: [LINK_TYPES.streamingpaid],
    clean(url) {
      /*
       * determine tld, asin from url, and build standard format [1],
       * if both were found.
       *
       * [1] "https://www.amazon.<tld>/(albums|artists)/<ASIN>"
       */
      let tld = '';
      let type = '';
      let asin = '';

      tld = findAmazonTld(url);

      const m = url.match(/\/(albums|artists)\/(B[0-9A-Z]{9}|[0-9]{9}[0-9X])(?:[/?&%#]|$)/);
      if (m) {
        type = m[1];
        asin = m[2];

        if (tld !== '' && asin !== '') {
          return 'https://music.amazon.' + tld + '/' + type + '/' + asin;
        }
      }

      return url;
    },
    validate(url, id) {
      // If you change this, please update the BadAmazonURLs report.
      const m = /^https:\/\/music\.amazon\.(?:ae|at|com\.au|com\.br|ca|cn|com|de|eg|es|fr|in|it|jp|co\.jp|com\.mx|nl|pl|sa|se|sg|com\.tr|co\.uk)\/(albums|artists)/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.streamingpaid.artist:
            return {
              result: prefix === 'artists',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.streamingpaid.release:
            return {
              result: prefix === 'albums',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'anghami': {
    match: [/^(?:https?:\/\/)?(?:(?:play|www)\.)?anghami\.com\//i],
    restrict: [LINK_TYPES.streamingfree],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:(?:play|www)\.)?anghami\.com\/(album|artist|song|video)\/([0-9]+).*$/, 'https://play.anghami.com/$1/$2');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/play\.anghami\.com\/(album|artist|song|video)\/[0-9]+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.streamingfree.artist:
            return {
              result: prefix === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.streamingfree.release:
            return {
              result: prefix === 'album',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.streamingfree.recording:
            return {
              result: prefix === 'song' || prefix === 'video',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'anidb': {
    match: [/^(?:https?:\/\/)?(?:www\.)?anidb\.net\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?anidb\.net\/(character|collection|creator|song)\/([0-9]+).*$/, 'https://anidb.net/$1/$2');
    },
    validate(url, id) {
      const m = /^https:\/\/anidb\.net\/(character|collection|creator|song)\/([0-9]+)$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'character' || prefix === 'creator',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release:
            return {
              result: prefix === 'collection',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.recording:
            return {
              result: prefix === 'song',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'animenewsnetwork': {
    match: [/^(https?:\/\/)?(www\.)?animenewsnetwork\.com/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?animenewsnetwork\.com\/encyclopedia\/(people|company).php\?id=([0-9]+).*$/, 'https://www.animenewsnetwork.com/encyclopedia/$1.php?id=$2');
      return url;
    },
  },
  'anisongeneration': {
    match: [/^(?:https?:\/\/)?anison\.info\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?anison\.info\/data\/(person|source|song)\/([0-9]+)\.html.*$/, 'http://anison.info/data/$1/$2.html');
    },
    validate(url, id) {
      const m = /^http:\/\/anison\.info\/data\/(person|source|song)\/([0-9]+)\.html$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'person',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release:
            return {
              result: prefix === 'source',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.recording:
            return {
              result: prefix === 'song',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'applebooks': {
    match: [/^(https?:\/\/)?([^/]+\.)?books\.apple\.com\//i],
    restrict: [LINK_TYPES.downloadpurchase],
    clean(url) {
      url = url.replace(/^https?:\/\/books\.apple\.com\/([a-z]{2}\/)?(audiobook|author|book)\/(?:[^?#/]+\/)?(?:id)?([0-9]+)(?:\?.*)?$/, 'https://books.apple.com/$1$2/id$3');
      // US page is the default, add its country-code to clarify (MBS-10623)
      url = url.replace(/^(https:\/\/books\.apple\.com)\/([a-z-]{3,})\//, '$1/us/$2/');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/books\.apple\.com\/[a-z]{2}\/([a-z-]{3,})\/id[0-9]+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.downloadpurchase.artist:
            if (prefix === 'author') {
              return {result: true};
            }
            return {
              result: false,
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.release:
            if (prefix === 'book') {
              return {
                error: exp.l(
                  `Only Apple Books audiobooks can be added
                   to MusicBrainz. Consider adding books to
                   {bookbrainz_url|BookBrainz} instead.`,
                  {bookbrainz_url: 'https://bookbrainz.org/'},
                ),
                result: false,
              };
            }
            return {
              result: prefix === 'audiobook',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'applemusic': {
    match: [
      /^(https?:\/\/)?([^/]+\.)?music\.apple\.com\//i,
      /^(https?:\/\/)?([^/]+\.)?apple\.co\//i,
    ],
    restrict: [
      LINK_TYPES.downloadpurchase,
      LINK_TYPES.streamingpaid,
      multiple(LINK_TYPES.downloadpurchase, LINK_TYPES.streamingpaid),
    ],
    clean(url) {
      url = url.replace(/^https?:\/\/(?:(?:beta|geo)\.)?music\.apple\.com\//, 'https://music.apple.com/');
      // US page is the default, add its country-code to clarify (MBS-10623)
      url = url.replace(/^(https:\/\/music\.apple\.com)\/([a-z-]{3,})\//, '$1/us/$2/');
      url = url.replace(/^(https:\/\/music\.apple\.com\/[a-z]{2})\/album\/[^?#/]+\/[0-9]+\?i=([0-9]+)$/, '$1/song/$2');
      url = url.replace(/^(https:\/\/music\.apple\.com\/[a-z]{2})\/(artist|album|author|label|music-video|song)\/(?:[^?#/]+\/)?(?:id)?([0-9]+)(?:\?.*)?$/, '$1/$2/$3');
      return url;
    },
    validate(url, id) {
      if (/^(?:https?:\/\/)?(?:[^/]+\.)?apple\.co\//i.test(url)) {
        return {
          error: exp.l(
            `This is a redirect link. Please follow {redirect_url|your link}
             and add the link it redirects to instead.`,
            {
              redirect_url: {
                href: url,
                rel: 'noopener noreferrer',
                target: '_blank',
              },
            },
          ),
          result: false,
          target: ERROR_TARGETS.URL,
        };
      }

      const m = /^https:\/\/music\.apple\.com\/[a-z]{2}\/([a-z-]{3,})\/[0-9]+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.downloadpurchase.artist:
          case LINK_TYPES.streamingpaid.artist:
            if (prefix === 'artist') {
              return {result: true};
            }
            return {
              result: false,
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.label:
          case LINK_TYPES.streamingpaid.label:
            if (prefix === 'label') {
              return {result: true};
            }
            return {
              result: false,
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.recording:
          case LINK_TYPES.streamingpaid.recording:
            return {
              result: prefix === 'music-video' || prefix === 'song',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.release:
          case LINK_TYPES.streamingpaid.release:
            return {
              result: prefix === 'album' || prefix === 'music-video',
              target: ERROR_TARGETS.ENTITY,
            };
        }
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'archive': {
    match: [/^(https?:\/\/)?([^/]+\.)?archive\.org\//i],
    clean(url) {
      url = url.replace(/^https?:\/\/(www.)?archive.org\//, 'https://archive.org/');
      // clean up links to files
      url = url.replace(/\?cnt=\d+$/, '');
      url = url.replace(/^https?:\/\/(?:.*)\.archive.org\/\d+\/items\/(.*)\/(.*)/, 'https://archive.org/download/$1/$2');
      // clean up links to items
      return url.replace(/^(https:\/\/archive\.org\/details\/[A-Za-z0-9._-]+)\/$/, '$1');
    },
  },
  'artstation': {
    match: [/^(https?:\/\/)?(www\.)?artstation\.com/i],
    restrict: [LINK_TYPES.artgallery],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?artstation\.com\/([^/#?]+).*$/, 'https://www.artstation.com/$1');
      return url;
    },
    validate(url) {
      const m = /^https:\/\/www\.artstation\.com\/([^/]+)$/.exec(url);
      if (m) {
        const userName = m[1];
        if (userName === 'search') {
          return {
            error: noLinkToSearchMsg(),
            result: false,
            target: ERROR_TARGETS.URL,
          };
        }
        const hardcodedPaths = [
          'artwork',
          'blogs',
          'challenges',
          'hire',
          'jobs',
          'learning',
          'marketplace',
          'prints',
          'schools',
          'studios',
        ];
        if (hardcodedPaths.includes(userName)) {
          return {
            result: false,
            target: ERROR_TARGETS.URL,
          };
        }
        return {result: true};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'audiomack': {
    match: [/^(https?:\/\/)?([^/]+\.)?audiomack\.com\//i],
    restrict: [LINK_TYPES.streamingfree],
    clean(url) {
      url = url.replace(
        /^https?:\/\/(?:www.)?audiomack.com\/([^/?&#]+(?:\/(album|song)\/[^/?&#]+)?).*$/,
        'https://audiomack.com/$1',
      );
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/audiomack\.com\/[^/?&#]+(?:\/(album|song)\/[^/?&#]+)?$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.streamingfree.artist:
            return {
              result: !prefix,
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.streamingfree.release:
            return {
              result: prefix === 'album',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.streamingfree.recording:
            return {
              result: prefix === 'song',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'baidubaike': {
    match: [/^(https?:\/\/)?baike\.baidu\.com\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?baike\.baidu\.com\/([^?#]+)(?:[?#].*)?$/, 'https://baike.baidu.com/$1');
    },
    validate(url, id) {
      const m = /^https:\/\/baike\.baidu\.com\/(.+)$/.exec(url);
      if (m) {
        const path = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
          case LINK_TYPES.otherdatabases.label:
          case LINK_TYPES.otherdatabases.release_group:
          case LINK_TYPES.otherdatabases.work:
            return {
              result: /^view\/[1-9][0-9]*\.htm$/.test(path) ||
                /^subview(\/[1-9][0-9]*){2}\.htm$/.test(path) ||
                /^item\/[^/]+(?:\/[1-9][0-9]*)?$/.test(path),
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'bandcamp': {
    match: [/^(https?:\/\/)?(((?!daily\.)[^/])+\.)?bandcamp\.com(?!\/(?:campaign|merch)\/)/i],
    restrict: [
      LINK_TYPES.bandcamp,
      ...anyCombinationOf(
        'recording',
        [
          LINK_TYPES.downloadfree.recording,
          LINK_TYPES.downloadpurchase.recording,
          LINK_TYPES.streamingfree.recording,
        ],
      ),
      ...anyCombinationOf(
        'release',
        [
          LINK_TYPES.downloadfree.release,
          LINK_TYPES.downloadpurchase.release,
          LINK_TYPES.streamingfree.release,
          LINK_TYPES.mailorder.release,
        ],
      ),
      {
        work: LINK_TYPES.lyrics.work,
      },
    ],
    clean(url) {
      // To reject /videoframe links without breaking the ?video_id parameter
      if (/^https?:\/\/bandcamp.com\/videoframe/.test(url)) {
        return url;
      }
      url = url.replace(/^(?:https?:\/\/)?([^/]+\.)?bandcamp\.com(?:\/([^?#]*))?.*$/, 'https://$1bandcamp.com/$2');
      url = url.replace(/^https:\/\/([^/]+)\.bandcamp\.com\/(?:((?:album|track)\/[^/]+))?.*$/, 'https://$1.bandcamp.com/$2');
      url = url.replace(/^https:\/\/bandcamp\.com\/(?:discover|tag)\/([^/]+).*$/, 'https://bandcamp.com/discover/$1');
      return url;
    },
    validate(url, id) {
      if (/^https:\/\/(?:[^/]+\.)?bandcamp\.com\/videoframe/.test(url)) {
        return {
          error: exp.l(
            `Please do not add “{blocked_url_pattern}” links,
             link to the appropriate “{wanted_url_pattern}” page instead.`,
            {
              blocked_url_pattern: (
                <span className="url-quote">{'/videoframe'}</span>
              ),
              wanted_url_pattern: (
                <span className="url-quote">{'/track'}</span>
              ),
            },
          ),
          result: false,
          target: ERROR_TARGETS.URL,
        };
      }
      switch (id) {
        case LINK_TYPES.bandcamp.artist:
          if (/^https:\/\/[^/]+\.bandcamp\.com\/(album|track)/.test(url)) {
            return {
              error: l(
                `Please link to the main page for the artist,
                 not to a specific album or track.`,
              ),
              result: false,
              target: ERROR_TARGETS.ENTITY,
            };
          }
          return {result: /^https:\/\/[^/]+\.bandcamp\.com\/$/.test(url)};
        case LINK_TYPES.bandcamp.genre:
          return {
            result: /^https:\/\/bandcamp\.com\/discover\/[\w-]+$/.test(url),
            target: ERROR_TARGETS.ENTITY,
          };
        case LINK_TYPES.bandcamp.label:
          if (/^https:\/\/[^/]+\.bandcamp\.com\/(album|track)/.test(url)) {
            return {
              error: l(
                `Please link to the main page for the label,
                 not to a specific album or track.`,
              ),
              result: false,
              target: ERROR_TARGETS.ENTITY,
            };
          }
          return {
            result: /^https:\/\/[^/]+\.bandcamp\.com\/$/.test(url),
            target: ERROR_TARGETS.ENTITY,
          };
        case LINK_TYPES.lyrics.work:
          return {
            result: /^https:\/\/[^/]+\.bandcamp\.com\/track\/[\w-]+$/.test(url),
            target: ERROR_TARGETS.ENTITY,
          };
        case LINK_TYPES.downloadfree.recording:
        case LINK_TYPES.downloadpurchase.recording:
        case LINK_TYPES.streamingfree.recording:
          if (/^(https?:\/\/)?([^/]+)\.bandcamp\.com\/?$/.test(url)) {
            return {
              error: exp.l(
                `This is a Bandcamp profile, not a page for a specific
                 recording. Even if it shows a single recording right now,
                 that can change when the artist releases another.
                 Please find and add the appropriate recording page
                 (“{single_url_pattern}”)
                 instead, and feel free to add this profile link
                 to the appropriate artist or label.`,
                {
                  single_url_pattern: (
                    <span className="url-quote">{'/track'}</span>
                  ),
                },
              ),
              result: false,
              target: ERROR_TARGETS.URL,
            };
          }
          return {
            result: /^https:\/\/[^/]+\.bandcamp\.com\/track\/[\w-]+$/.test(url),
            target: ERROR_TARGETS.ENTITY,
          };
        case LINK_TYPES.downloadfree.release:
        case LINK_TYPES.downloadpurchase.release:
        case LINK_TYPES.mailorder.release:
        case LINK_TYPES.streamingfree.release:
          if (/^(https?:\/\/)?([^/]+)\.bandcamp\.com\/?$/.test(url)) {
            return {
              error: exp.l(
                `This is a Bandcamp profile, not a page for a specific
                 release. Even if it shows this release right now,
                 that can change when the artist releases another.
                 Please find and add the appropriate release page
                 (“{album_url_pattern}” or “{single_url_pattern}”)
                 instead, and feel free to add this profile link
                 to the appropriate artist or label.`,
                {
                  album_url_pattern: (
                    <span className="url-quote">{'/album'}</span>
                  ),
                  single_url_pattern: (
                    <span className="url-quote">{'/track'}</span>
                  ),
                },
              ),
              result: false,
              target: ERROR_TARGETS.URL,
            };
          }
          return {
            result: /^https:\/\/[^/]+\.bandcamp\.com\/(?:album|track)\/[\w-]+$/.test(url),
            target: ERROR_TARGETS.ENTITY,
          };
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'bandcampcampaign': {
    match: [/^(https?:\/\/)?([^/]+)\.bandcamp\.com\/campaign/i],
    restrict: [LINK_TYPES.crowdfunding],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?([^/]+)\.bandcamp\.com\/campaign\/([^?#/]+).*$/, 'https://$1.bandcamp.com/campaign/$2');
    },
    validate(url, id) {
      switch (id) {
        case LINK_TYPES.crowdfunding.release:
          return {result: /^https:\/\/[^/]+\.bandcamp\.com\/campaign\/[^?#/]+$/.test(url)};
      }
      return {result: false, target: ERROR_TARGETS.ENTITY};
    },
  },
  'bandcampdaily': {
    match: [/^(https?:\/\/)?daily\.bandcamp\.com/i],
    restrict: [{
      ...LINK_TYPES.interview,
      ...LINK_TYPES.review,
    }],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?daily\.bandcamp\.com\/((?:\d+\/\d+\/\d+|[\w-]+)\/[\w-]+)(?:\/.*)?$/, 'https://daily.bandcamp.com/$1/');
    },
    validate(url, id) {
      switch (id) {
        case LINK_TYPES.interview.artist:
          return {
            result: /^https:\/\/daily\.bandcamp\.com\/(?:\d+\/\d+\/\d+|[\w-]+)\/[\w-]+-interview\/$/.test(url),
            target: ERROR_TARGETS.ENTITY,
          };
        case LINK_TYPES.review.release_group:
          return {
            result: /^https:\/\/daily\.bandcamp\.com\/(?:\d+\/\d+\/\d+|[\w-]+)\/[\w-]+-review\/$/.test(url),
            target: ERROR_TARGETS.ENTITY,
          };
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'bandcampmerch': {
    match: [/^(https?:\/\/)?([^/]+)\.bandcamp\.com\/merch/i],
    restrict: [LINK_TYPES.mailorder],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?([^/]+)\.bandcamp\.com\/merch\/([^/]+)?.*$/, 'https://$1.bandcamp.com/merch/$2');
    },
    validate(url, id) {
      switch (id) {
        case LINK_TYPES.mailorder.release:
          return {result: /^https:\/\/[^/]+\.bandcamp\.com\/merch\/[\w-]+$/.test(url)};
      }
      return {result: false, target: ERROR_TARGETS.ENTITY};
    },
  },
  'bandsintown': {
    match: [/^(https?:\/\/)?((m|www)\.)?bandsintown\.com/i],
    restrict: [LINK_TYPES.bandsintown],
    clean(url) {
      let m = url.match(/^(?:https?:\/\/)?(?:(?:m|www)\.)?bandsintown\.com\/(?:[a-z]{2}\/)?(a(?=rtist|\/)|e(?=vent|\/)|f|v(?=enue|\/))[a-z]*\/0*([1-9][0-9]*)(?:[^0-9].*)?$/);
      if (m) {
        const prefix = m[1];
        const number = m[2];
        url = 'https://www.bandsintown.com/' + prefix + '/' + number;
      } else {
        m = url.match(/^(?:https?:\/\/)?(?:(?:m|www)\.)?bandsintown\.com\/([^/?#]+)(?:[/?#].*)?$/);
        if (m) {
          const name = m[1];
          url = 'https://www.bandsintown.com/' + name.toLowerCase();
        }
      }
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/www.bandsintown\.com\/(?:([aefv])\/)?([^/?#]+)$/.exec(url);
      if (m) {
        const prefix = m[1];
        const target = m[2];
        switch (id) {
          case LINK_TYPES.bandsintown.artist:
            return {
              result: (prefix === undefined && target !== undefined) ||
                (prefix === 'a' && /^[1-9][0-9]*$/.test(target)),
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.bandsintown.event:
            return {
              result: (prefix === 'e' || prefix === 'f') &&
                      /^[1-9][0-9]*$/.test(target),
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.bandsintown.place:
            return {
              result: prefix === 'v' && /^[1-9][0-9]*$/.test(target),
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'bbcevents': {
    match: [/^(https?:\/\/)?(www\.)?bbc\.co\.uk\/events\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?bbc\.co\.uk\/events\/([\w]+).*$/, 'https://www.bbc.co.uk/events/$1');
      return url;
    },
    validate(url, id) {
      const isCorrectlyFormatted = /^https:\/\/www\.bbc\.co\.uk\/events\/[\w]+$/.test(url);
      if (isCorrectlyFormatted) {
        if (id === LINK_TYPES.otherdatabases.event) {
          return {result: true};
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'bbcmusic': {
    match: [/^(https?:\/\/)?(www\.)?bbc\.co\.uk\/music\/artists\//i],
    restrict: [LINK_TYPES.bbcmusic],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?bbc\.co\.uk\/music\/artists\/([0-9a-f-]+).*$/, 'https://www.bbc.co.uk/music/artists/$1');
      return url;
    },
    validate(url) {
      return {
        result: /^https:\/\/www\.bbc\.co\.uk\/music\/artists\/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/.test(url),
        target: ERROR_TARGETS.URL,
      };
    },
  },
  'bbcreview': {
    match: [/^(https?:\/\/)?(www\.)?bbc\.co\.uk\/music\/reviews\//i],
    restrict: [LINK_TYPES.review],
  },
  'beatport': {
    match: [/^(https?:\/\/)?([^/]+\.)?beatport\.com/i],
    restrict: [LINK_TYPES.downloadpurchase],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:(?:classic|pro|www)\.)?beatport\.com\//, 'https://www.beatport.com/');
      const m = url.match(/^(https:\/\/www\.beatport\.com)\/[\w-]+\/html\/content\/([\w-]+)\/detail\/0*([0-9]+)\/([^/?&#]*).*$/);
      if (m) {
        const slug = m[4].toLowerCase()
          .replace(/%21/g, '!')
          .replace(/%23/g, '-pound-')
          .replace(/%24/g, '-money-')
          .replace(/\$/g, '-money-')
          .replace(/%25/g, '-percent-')
          .replace(/%26/g, '-and-')
          .replace(/%40/g, '-at-')
          .replace(/@/g, '-at-')
          .replace(/%[0-9a-f]{2}/g, '-')
          .replace(/%/g, '-percent-')
          .replace(/[^a-z0-9!]/g, '-')
          .replace(/-+/g, '-')
          .replace(/^-|-$/g, '')
          .replace(/^$/, '---');
        url = [m[1], m[2], slug, m[3]].join('/');
      }
      url = url.replace(/^(https:\/\/www\.beatport\.com)\/([\w-]+)\/([\w!-]+)\/0*([0-9]+).*$/, '$1/$2/$3/$4');
      url = url.replace(/^(https:\/\/www\.beatport\.com)\/([\w-]+)\/\/0*([0-9]+)(?![\w!-]|\/[0-9]).*$/, '$1/$2/---/$3');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/(?:sounds|www)\.beatport\.com\/([\w-]+)\/[\w!%-]+\/[1-9][0-9]*$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.downloadpurchase.artist:
            return {
              result: prefix === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.recording:
            return {
              result: prefix === 'track' || prefix === 'stem',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.release:
            return {
              result: prefix === 'release' ||
                prefix === 'chart' ||
                prefix === 'stem-pack',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.label:
            return {
              result: prefix === 'label',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'behance': {
    match: [/^(https?:\/\/)?(www\.)?behance\.net/i],
    restrict: [LINK_TYPES.artgallery],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?behance\.net\/([^/#?]+).*$/, 'https://www.behance.net/$1');
      return url;
    },
    validate(url) {
      const m = /^https:\/\/www\.behance\.net\/([^/]+)$/.exec(url);
      if (m) {
        const userName = m[1];
        if (userName === 'search') {
          return {
            error: noLinkToSearchMsg(),
            result: false,
            target: ERROR_TARGETS.URL,
          };
        }
        const hardcodedPaths = [
          'assets',
          'for_you',
          'galleries',
          'gallery',
          'hire',
          'joblist',
          'privacy',
        ];
        if (hardcodedPaths.includes(userName)) {
          return {
            result: false,
            target: ERROR_TARGETS.URL,
          };
        }
        return {result: true};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'bigcartel': {
    match: [/^(https?:\/\/)?[^/]+\.bigcartel\.com/i],
    restrict: [LINK_TYPES.mailorder],
    clean(url) {
      const m = url.match(/^(?:https?:\/\/)?([^/]+)\.bigcartel\.com(?:\/(?:product\/([^/?#]+)|[^/]*))?/);
      if (m) {
        const subdomain = m[1];
        const product = m[2];
        url = 'https://' + subdomain + '.bigcartel.com';
        if (product !== undefined) {
          url = url + '/product/' + product;
        }
      }
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/([^/]+)\.bigcartel\.com(\/product\/[^/?#]+)?/.exec(url);
      if (m) {
        const subdomain = m[1];
        const product = m[2];
        if (!/^(images|www)$/.test(subdomain)) {
          switch (id) {
            case LINK_TYPES.mailorder.artist:
            case LINK_TYPES.mailorder.label:
              if (product === undefined) {
                return {result: true};
              }
              return {
                error: id === LINK_TYPES.mailorder.artist
                  ? l(`Please link to the main page for the artist,
                       not a specific product.`)
                  : l(`Please link to the main page for the label,
                       not a specific product.`),
                result: false,
                target: ERROR_TARGETS.ENTITY,
              };
            case LINK_TYPES.mailorder.release:
              return {
                result: product !== undefined,
                target: ERROR_TARGETS.ENTITY,
              };
          }
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'blog': {
    match: [
      /^(https?:\/\/)?([^/]+\.)?ameblo\.jp/i,
      /^(https?:\/\/)?([^/]+\.)?blog\.livedoor\.jp/i,
      /^(https?:\/\/)?([^./]+)\.jugem\.jp/i,
      /^(https?:\/\/)?([^./]+)\.exblog\.jp/i,
      /^(https?:\/\/)?([^./]+)\.tumblr\.com/i,
    ],
    restrict: [LINK_TYPES.blog],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?ameblo\.jp\/([^/]+).*$/, 'https://ameblo.jp/$1/');
      return url;
    },
  },
  'blogspot': {
    match: [/^(https?:\/\/)?(www\.)?[^./]+\.blogspot\.([a-z]{2,3}\.)?[a-z]{2,3}\/?/i],
    clean(url) {
      return url.replace(/(?:www\.)?([^./]+)\.blogspot\.(?:[a-z]{2,3}\.)?[a-z]{2,3}(?:\/)?/, '$1.blogspot.com/');
    },
  },
  'bnfcatalogue': {
    match: [
      /^(https?:\/\/)?(catalogue|data)\.bnf\.fr\//i,
      /^(https?:\/\/)?ark\.bnf\.fr\/ark:\/12148\/cb/i,
      /^(https?:\/\/)?n2t\.net\/ark:\/12148\/cb/i,
    ],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      let m = /^(?:https?:\/\/)?data\.bnf\.fr\/(?:[a-z-]+\/)?([1-4][0-9]{7})(?:[0-9b-z])?(?:[./?#].*)?$/.exec(url);
      if (m) {
        const frBnF = m[1];
        const phbt = '0123456789bcdfghjkmnpqrstvwxz';
        const controlChar = phbt[Array.from(frBnF).reduce((sum, c, i) => {
          return sum + (phbt.indexOf(c) * (i + 3));
        }, 2) % 29];
        url = 'https://catalogue.bnf.fr/ark:/12148/cb' + frBnF + controlChar;
      } else {
        m = /^(?:https?:\/\/)?(?:n2t\.net|(?:ark|catalogue|data)\.bnf\.fr)\/(ark:\/12148\/cb[1-4][0-9]{7}[0-9b-z])(?:[./?#].*)?$/.exec(url);
        if (m) {
          const persistentARK = m[1];
          url = 'https://catalogue.bnf.fr/' + persistentARK;
        }
      }
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/catalogue\.bnf\.fr\/ark:\/12148\/cb([1-4])[0-9]{7}[0-9b-z]$/.exec(url);
      if (m) {
        const digit = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
          case LINK_TYPES.otherdatabases.instrument:
          case LINK_TYPES.otherdatabases.label:
          case LINK_TYPES.otherdatabases.place:
          case LINK_TYPES.otherdatabases.work:
            return {
              result: digit === '1' || digit === '2',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.event:
          case LINK_TYPES.otherdatabases.release:
            return {
              result: digit === '3' || digit === '4',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.series:
            return {result: true};
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'bookbrainz': {
    match: [/^(https?:\/\/)?([^/]+\.)?bookbrainz\.org/i],
    restrict: [LINK_TYPES.bookbrainz],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:[^.]+\.)?bookbrainz\.org\/([^/]*)\/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})(?:[#/?].*)?$/, 'https://bookbrainz.org/$1/$2');
    },
    validate(url) {
      return {
        result: /^https:\/\/bookbrainz\.org\/[^/]+\/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/.test(url),
        target: ERROR_TARGETS.URL,
      };
    },
  },
  'boomkat': {
    match: [/^(https?:\/\/)?(www\.)?boomkat\.com/i],
    restrict: [
      {
        artist: [
          LINK_TYPES.downloadpurchase.artist,
          LINK_TYPES.mailorder.artist,
        ],
        label: [
          LINK_TYPES.downloadpurchase.label,
          LINK_TYPES.mailorder.label,
        ],
      },
      LINK_TYPES.downloadpurchase,
      LINK_TYPES.mailorder,
    ],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)(?:www\.)?boomkat\.com\/([a-z]+)\/([^/#?]+).*$/, 'https://boomkat.com/$1/$2');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/boomkat\.com\/([a-z]+)\/.*$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.downloadpurchase.artist:
          case LINK_TYPES.mailorder.artist:
            return {
              result: prefix === 'artists',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.label:
          case LINK_TYPES.mailorder.label:
            return {
              result: prefix === 'labels',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.release:
          case LINK_TYPES.mailorder.release:
            return {
              result: prefix === 'products',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'boomplay': {
    match: [/^(https?:\/\/)?([^/]+\.)?boomplay\.com\//i],
    restrict: [LINK_TYPES.streamingfree],
    clean(url) {
      url = url.replace(
        /^https?:\/\/(?:www.)?boomplay.com\/((?:albums|artists|songs)\/\d+).*$/,
        'https://www.boomplay.com/$1',
      );
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/www\.boomplay\.com\/(albums|artists|songs)\/\d+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.streamingfree.artist:
            return {
              result: prefix === 'artists',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.streamingfree.release:
            return {
              result: prefix === 'albums',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.streamingfree.recording:
            return {
              result: prefix === 'songs',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'brahms': {
    match: [/^(https?:\/\/)?brahms\.ircam\.fr\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?brahms\.ircam\.fr\/(?:(?:en|fr)\/)?((works\/work)(?:\/)([0-9]+)|(?!works)[^?/#]+).*$/, 'http://brahms.ircam.fr/$1');
    },
    validate(url, id) {
      const m = /^(?:https?:\/\/)?brahms\.ircam\.fr\/(works\/work|(?!works)[^?/#]+).*$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.work:
            return {
              result: prefix === 'works/work',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix !== 'works/work',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'bugs': {
    match: [
      /^(https?:\/\/)?(music|m)\.bugs\.co\.kr\//i,
    ],
    restrict: [
      multiple(LINK_TYPES.downloadpurchase, LINK_TYPES.streamingpaid),
      LINK_TYPES.streamingpaid,
    ],
    select(url, sourceType) {
      const m = /^https:\/\/music\.bugs\.co\.kr\/(album|artist|track|mv)/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (prefix) {
          case 'album':
            if (sourceType === 'release') {
              return [
                LINK_TYPES.downloadpurchase.release,
                LINK_TYPES.streamingpaid.release,
              ];
            }
            break;
          case 'artist':
            if (sourceType === 'artist') {
              return [
                LINK_TYPES.downloadpurchase.artist,
                LINK_TYPES.streamingpaid.artist,
              ];
            }
            break;
          case 'track':
            if (sourceType === 'recording') {
              return [
                LINK_TYPES.downloadpurchase.recording,
                LINK_TYPES.streamingpaid.recording,
              ];
            }
            break;
          default: // mv
            if (sourceType === 'release') {
              return [
                LINK_TYPES.downloadpurchase.release,
                LINK_TYPES.streamingpaid.release,
              ];
            } else if (sourceType === 'recording') {
              return [
                LINK_TYPES.downloadpurchase.recording,
                LINK_TYPES.streamingpaid.recording,
              ];
            }
            break;
        }
      }
      return false;
    },
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:music|m)\.bugs\.co\.kr\//, 'https://music.bugs.co.kr/');
      url = url.replace(/^(https:\/\/music\.bugs\.co\.kr)\/(album|artist|track|mv)\/(\d+)(?:[/.?#].*)?$/, '$1/$2/$3');
      return url;
    },
    validate(url, id) {
      if (/https:\/\/music\.bugs\.co\.kr\/search\//.test(url)) {
        return {
          error: noLinkToSearchMsg(),
          result: false,
          target: ERROR_TARGETS.URL,
        };
      }
      const m = /^https:\/\/music\.bugs\.co\.kr\/(album|artist|track|mv)\/\d+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.downloadpurchase.release:
          case LINK_TYPES.streamingpaid.release:
            return {
              result: prefix === 'album' || prefix === 'mv',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.artist:
          case LINK_TYPES.streamingpaid.artist:
            return {
              result: prefix === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.recording:
          case LINK_TYPES.streamingpaid.recording:
            return {
              result: prefix === 'track' || prefix === 'mv',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'buymeacoffee': {
    match: [/^(https?:\/\/)?(www\.)?buymeacoffee\.com\/[^/?#]/i],
    restrict: [LINK_TYPES.patronage],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?buymeacoffee\.com\/([^/?#]+).*$/, 'https://www.buymeacoffee.com/$1');
    },
  },
  'cancionerosmewiki': {
    match: [/^(https?:\/\/)?(www\.)?cancioneros\.si\/mediawiki\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?cancioneros\.si\/([^#]+)(?:[#].*)?$/, 'http://www.cancioneros.si/$1');
    },
    validate(url, id) {
      if (/^http:\/\/www\.cancioneros\.si\/mediawiki\/index\.php\?title=.+$/.test(url)) {
        if (id === LINK_TYPES.otherdatabases.artist ||
            id === LINK_TYPES.otherdatabases.series ||
            id === LINK_TYPES.otherdatabases.work) {
          return {result: true};
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'cbfiddlerx': {
    match: [/^(https?:\/\/)?(www\.)?cbfiddle\.com\/rx\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?cbfiddle\.com\/rx\/(rec\/r|tune\/t)(\d+\.html)(?:#.*$)?$/, 'https://www.cbfiddle.com/rx/$1$2');
    },
    validate(url, id) {
      const m = /^https:\/\/www\.cbfiddle\.com\/rx\/(rec\/r|tune\/t)\d+\.html$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.release_group:
            return {
              result: prefix === 'rec/r',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.work:
            return {
              result: prefix === 'tune/t',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'ccmixter': {
    match: [/^(https?:\/\/)?(www\.)?ccmixter\.org\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?ccmixter\.org/, 'http://ccmixter.org');
      return url;
    },
    validate(url, id) {
      const m = /^http:\/\/ccmixter\.org\/(files|people)\/\w+(?:\/\d+)?$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'people',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.recording:
            return {
              result: prefix === 'files',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'cdbaby_artist': {
    match: [/^(https?:\/\/)?((store|www)\.)?cdbaby\.(com|name)\/Artist\//i],
    restrict: [LINK_TYPES.cdbaby],
  },
  'cdjapan': {
    match: [/^(https?:\/\/)?(www\.)?cdjapan\.co\.jp\/(detailview|product|person)/i],
    restrict: [LINK_TYPES.mailorder],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?cdjapan\.co\.jp\//, 'https://www.cdjapan.co.jp/');
      url = url.replace(/^(https:\/\/www\.cdjapan\.co\.jp)\/detailview\.html\?KEY=([^/?#]+).*$/, '$1/product/$2');
      url = url.replace(/^(https:\/\/www\.cdjapan\.co\.jp)\/(person|product)\/([^/?#]+).*$/, '$1/$2/$3');
      return url;
    },
  },
  'changetip': {
    match: [
      /^(https?:\/\/)?(www\.)?changetip\.com\/tipme\/[^/?#]/i,
      /^(https?:\/\/)?[^/?#]+\.tip.me([/?#].*)?$/i,
    ],
    restrict: [LINK_TYPES.patronage],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?changetip\.com\/tipme\/([^/?#]+).*$/, 'https://www.changetip.com/tipme/$1');
      url = url.replace(/^(?:https?:\/\/)?([^/?#]+)\.tip\.me(?:[/?#].*)?$/, 'https://www.changetip.com/tipme/$1');
      return url;
    },
  },
  'classicalarchives': {
    match: [
      /^(https?:\/\/)?(www\.)?classicalarchives\.com\/(album|artist|composer|ensemble|work)\//i,
      /^(https?:\/\/)?(www\.)?classicalarchives\.com\/newca\/#!\/(Album|Composer|Performer|Work)\//i,
    ],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?classicalarchives\.com\//, 'https://www.classicalarchives.com/');
      /*
       * Both newca and "old-style" links work, old redirects to new
       * unless requested otherwise. CA claimed they'll support both
       * going forward, so mapping all to old-style for now.
       * newca entities match except Performer, where the old type
       * is determined by the first letter of the ID: ensemble (e)
       * or artist (p)
       * newca Album links are allowed since they can't be autoconverted
       */
      url = url.replace(/^(https:\/\/www\.classicalarchives\.com)\/newca\/#!\/Composer\/([^/?#]+)/, '$1/composer/$2.html');
      url = url.replace(/^(https:\/\/www\.classicalarchives\.com)\/newca\/#!\/Work\/([^/?#]+)/, '$1/work/$2.html');
      url = url.replace(/^(https:\/\/www\.classicalarchives\.com)\/newca\/#!\/Performer\/e([^/?#]+)/, '$1/ensemble/$2.html');
      url = url.replace(/^(https:\/\/www\.classicalarchives\.com)\/newca\/#!\/Performer\/p([^/?#]+)/, '$1/artist/$2.html');
      url = url.replace(/^(https:\/\/www\.classicalarchives\.com)\/newca\/#!\/Album\/([^/?#]+).*$/, '$1/newca/#!/Album/$2');
      url = url.replace(/^(https:\/\/www\.classicalarchives\.com)\/(album|artist|composer|ensemble|work)\/([^/?#]+).*$/, '$1/$2/$3');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/www\.classicalarchives\.com\/(?:newca\/#!\/)?([Aa]lbum|artist|composer|ensemble|work)\/([^/?#]+)$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: ['artist', 'composer', 'ensemble'].includes(prefix),
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release:
            return {
              result: prefix === 'album' || prefix === 'Album',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.work:
            return {
              result: prefix === 'work',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'cpdl': {
    match: [/^(https?:\/\/)?(www[0-9]?\.)?cpdl\.org/i],
    restrict: [{...LINK_TYPES.score, ...LINK_TYPES.cpdl}],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www[0-9]?\.)?cpdl\.org/, 'http://cpdl.org');
    },
  },
  'dahr': {
    match: [
      /^(https?:\/\/)?adp\.library\.ucsb\.edu\/index\.php\/(mastertalent|matrix|objects|talent)/i,
      /^(https?:\/\/)?adp\.library\.ucsb\.edu\/names\//i,
    ],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?adp\.library\.ucsb\.edu\//, 'https://adp.library.ucsb.edu/');
      url = url.replace(/^(https:\/\/adp\.library\.ucsb\.edu)\/index\.php\/([a-z]+)\/[a-z]+\/([\d]+).*$/, '$1/index.php/$2/detail/$3');
      url = url.replace(/^(https:\/\/adp\.library\.ucsb\.edu)\/names\/([\d]+).*$/, '$1/names/$2');
      // mastertalent URLs match 1:1 to a names permalink so we use that
      url = url.replace(/^(https:\/\/adp\.library\.ucsb\.edu)\/index\.php\/mastertalent\/detail\/([\d]+).*$/, '$1/names/$2');
      return url;
    },
    validate(url, id) {
      const isNamesPermalink = url.match(/^https:\/\/adp\.library\.ucsb\.edu\/names\/[\d]+$/);
      if (isNamesPermalink && id === LINK_TYPES.otherdatabases.artist) {
        return {result: true};
      }
      const m = /^https:\/\/adp\.library\.ucsb\.edu\/index\.php\/([a-z]+)\/detail\/[\d]+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'talent',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.recording:
            return {
              result: prefix === 'matrix',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release:
            return {
              result: prefix === 'objects',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'dailymotion': {
    match: [/^(https?:\/\/)?([^/]+\.)?(dailymotion\.com\/)/i],
    restrict: [{...LINK_TYPES.streamingfree, ...LINK_TYPES.videochannel}],
    clean(url) {
      const m = /^(?:https?:\/\/)?(?:www\.)?dailymotion\.com\/((([^/?#]+)(?:\/[^?#]*)?)(?:\?[^#]*)?(?:#(.+)?)?)$/.exec(url);
      if (m) {
        let afterSlash = m[1];
        const path = m[2];
        const root = m[3];
        const fragment = m[4];
        switch (root) {
          case 'playlist':
            afterSlash = /^video=/.test(fragment) ? fragment.replace('=', '/') : afterSlash;
            break;
          case 'video':
            afterSlash = path.replace(/([^_]+).*/, '$1');
            break;
          default:
            afterSlash = new RegExp('^' + root + '/*$').test(path)
              ? root
              : afterSlash;
            break;
        }
        return 'https://www.dailymotion.com/' + afterSlash;
      }
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/www\.dailymotion\.com\/(?:(video\/)?[^/?#]+)$/.exec(url);
      if (m) {
        const prefix = m[1];
        if (Object.values(LINK_TYPES.videochannel).includes(id)) {
          if (prefix === 'video/') {
            return {
              error: linkToChannelMsg(),
              result: false,
              target: ERROR_TARGETS.ENTITY,
            };
          }
          return {result: prefix === undefined};
        }
        if (prefix === 'video/') {
          return {result: true};
        }
        return {
          error: linkToVideoMsg(),
          result: false,
          target: ERROR_TARGETS.ENTITY,
        };
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'deezer': {
    match: [/^(https?:\/\/)?([^/]+\.)?(deezer\.com)/i],
    restrict: [LINK_TYPES.streamingfree],
    clean(url) {
      url = url.replace(/^https?:\/\/(?:www\.)?deezer\.com\/(?:[a-z]{2}\/)?(\w+)\/(\d+).*$/, 'https://www.deezer.com/$1/$2');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/www\.deezer\.com\/([a-z]+)\/(?:\d+)$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.streamingfree.artist:
            return {
              result: prefix === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.streamingfree.release:
            return {
              result: prefix === 'album',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.streamingfree.recording:
            return {
              result: prefix === 'track' || prefix === 'episode',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'deviantart': {
    match: [/^(https?:\/\/)?(www\.)?deviantart\.com/i],
    restrict: [LINK_TYPES.artgallery],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?deviantart\.com\/([^/?#]+).*$/, 'https://www.deviantart.com/$1');
      return url;
    },
    validate(url) {
      const m = /^https:\/\/www\.deviantart\.com\/([^/?#]+)$/.exec(url);
      if (m) {
        const userName = m[1];
        if (userName === 'search') {
          return {
            error: noLinkToSearchMsg(),
            result: false,
            target: ERROR_TARGETS.URL,
          };
        }
        const hardcodedPaths = [
          'about',
          'core-membership',
          'forum',
          'groups',
          'join',
          'shop',
          'team',
          'users',
        ];
        if (hardcodedPaths.includes(userName)) {
          return {
            result: false,
            target: ERROR_TARGETS.URL,
          };
        }
        return {result: true};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'dhhu': {
    match: [/^(https?:\/\/)?(www\.)?dhhu\.dk/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?dhhu\.dk\/w\/(.*)+$/, 'http://www.dhhu.dk/w/$1');
      return url;
    },
  },
  'discographyentry': {
    match: [
      /^(https?:\/\/)?(www\.)?naxos\.com\/catalogue\/item\.asp/i,
      /^(https?:\/\/)?(www\.)?bis\.se\/index\.php\?op=album/i,
      /^(https?:\/\/)?(www\.)?universal-music\.co\.jp\/([a-z0-9-]+\/)?[a-z0-9-]+\/products\/[a-z]{4}-[0-9]{5}\/$/i,
      /^(https?:\/\/)?(www\.)?jvcmusic\.co\.jp\/[a-z-]+\/Discography\/[A0-9-]+\/[A-Z]{4}-[0-9]+\.html$/i,
      /^(https?:\/\/)?(www\.)?wmg\.jp\/artist\/[A-Za-z0-9]+\/[A-Z]{4}[0-9]{9}\.html$/i,
      /^(https?:\/\/)?(www\.)?avexnet\.jp\/id\/[a-z0-9]{5}\/discography\/product\/[A-Z0-9]{4}-[0-9]{5}\.html$/i,
      /^(https?:\/\/)?(www\.)?kingrecords\.co\.jp\/cs\/g\/g[A-Z]{4}-[0-9]+\/$/i,
    ],
    restrict: [LINK_TYPES.discographyentry],
  },
  'discogs': {
    match: [/^(https?:\/\/)?([^/]+\.)?discogs\.com/i],
    restrict: [LINK_TYPES.discogs],
    clean(url) {
      url = url.replace(/\/viewimages\?release=([0-9]*)/, '/release/$1');
      url = url.replace(/^https?:\/\/(?:[^.]+\.)?discogs\.com\/(?:.*\/)?((?:genre|style|user)\/[^/#?]+|(?:composition\/[^-]+-[^-]+-[^-]+-[^-]+-[^-]+)|(?:artist|release|master(?:\/view)?|label)\/[0-9]+)(?:[/#?-].*)?$/, 'https://www.discogs.com/$1');
      url = url.replace(/^(https:\/\/www\.discogs\.com\/master)\/view\/([0-9]+)$/, '$1/$2');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/www\.discogs\.com\/(?:(artist|label|master|release)\/[1-9][0-9]*|(genre|style|user)\/.+|(composition)\/(?:[^-]*-){4}[^-]*)$/.exec(url);
      if (m) {
        const prefix = m[1] || m[2] || m[3];
        switch (id) {
          case LINK_TYPES.discogs.artist:
            return {
              result: prefix === 'artist' || prefix === 'user',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.discogs.genre:
            return {
              result: prefix === 'genre' || prefix === 'style',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.discogs.label:
          case LINK_TYPES.discogs.series:
            return {
              result: prefix === 'label',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.discogs.place:
            return {
              result: prefix === 'artist' || prefix === 'label',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.discogs.release_group:
            return {
              result: prefix === 'master',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.discogs.release:
            if (prefix === 'master') {
              return {
                error: exp.l(
                  `Discogs “{master_url_pattern}” links group several
                   releases,
                   so this should be added to the release group instead.`,
                  {
                    master_url_pattern: (
                      <span className="url-quote">{'/master'}</span>
                    ),
                  },
                ),
                result: false,
                target: ERROR_TARGETS.ENTITY,
              };
            }
            return {
              result: prefix === 'release',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.discogs.work:
            return {
              result: prefix === 'composition',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'dnb': {
    match: [
      /^(https?:\/\/)?([^/]+\.)?d-nb\.info/i,
      /^(https?:\/\/)?([^/]+\.)?dnb\.de/i,
    ],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?d-nb\.info\//, 'https://d-nb.info/');
      url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?dnb\.de\/opac(?:\.htm\?)?.*\bquery=nid%3D([0-9X-]+).*$/, 'https://d-nb.info/gnd/$1');
      url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?dnb\.de\/opac(?:\.htm\?)?.*\bquery=idn%3D([0-9X-]+).*$/, 'https://d-nb.info/$1');
      return url;
    },
    validate(url, id) {
      switch (id) {
        case LINK_TYPES.otherdatabases.artist:
        case LINK_TYPES.otherdatabases.place:
        case LINK_TYPES.otherdatabases.series:
        case LINK_TYPES.otherdatabases.work:
          return {
            result: /^https:\/\/d-nb\.info\/(?:gnd\/)?[0-9X-]+$/.test(url),
            target: ERROR_TARGETS.ENTITY,
          };
        case LINK_TYPES.otherdatabases.label:
          return {
            result: /^https:\/\/d-nb\.info\/(?:(?:dnbn|gnd)\/)?[0-9X-]+$/.test(url),
            target: ERROR_TARGETS.ENTITY,
          };
        case LINK_TYPES.otherdatabases.release:
          return {
            result: /^https:\/\/d-nb\.info\/[0-9X-]+$/.test(url),
            target: ERROR_TARGETS.ENTITY,
          };
      }
      return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
    },
  },
  'dogmazic': {
    match: [/^(https?:\/\/)?([^/]+\.)?(dogmazic\.net)/i],
    restrict: [LINK_TYPES.streamingfree],
    clean(url) {
      url = url.replace(/^https?:\/\/(?:(?:play|www)\.)?dogmazic\.net\//, 'https://play.dogmazic.net/');
      // Drop one-word fragments such as '#albums' used for list display
      url = url.replace(/^(https:\/\/play\.dogmazic\.net)\/([^#]+)#(?:\w+)?$/, '$1/$2');
      // Drop current path when fragment contains a path to a PHP script
      url = url.replace(/^(https:\/\/play\.dogmazic\.net)\/(?:[^#]+)#(\w+\.php)/, '$1/$2');
      // Drop parents in path
      url = url.replace(/^(https:\/\/play\.dogmazic\.net)\/(?:[^?#]+)\/(\w+\.php)/, '$1/$2');
      // Overwrite path and query after query parameter with numeric value
      const m = /^(https:\/\/play\.dogmazic\.net)\/\w+\.php\?(?:[^#]+&)?[\w%]+=([\w%]+)&([\w%]+)=(\d+)/.exec(url);
      if (m) {
        const host = m[1];
        const type = m[2];
        const key = m[3];
        const value = m[4];
        switch (key) {
          case 'album':
            return `${host}/albums.php?action=show&${key}=${value}`;
          case 'artist':
            return `${host}/artists.php?action=show&${key}=${value}`;
          case 'label':
            return `${host}/labels.php?action=show&${key}=${value}`;
          case 'song_id':
            return `${host}/song.php?action=show&${key}=${value}`;
          case 'id':
          case 'id%5B0%5D':
          case 'object_id':
          case 'oid':
            switch (type) {
              case 'album':
                return `${host}/albums.php?action=show&${type}=${value}`;
              case 'artist':
                return `${host}/artists.php?action=show&${type}=${value}`;
              case 'label':
                return `${host}/labels.php?action=show&${type}=${value}`;
              case 'song':
                return `${host}/song.php?action=show&song_id=${value}`;
            }
        }
      }
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/play\.dogmazic\.net\/(\w+)\.php\?action=show&(\w+)=\d+$/.exec(url);
      if (m) {
        const path = m[1];
        const query = m[2];
        switch (id) {
          case LINK_TYPES.streamingfree.artist:
            return {
              result: path === 'artists' && query === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.streamingfree.label:
            return {
              result: path === 'labels' && query === 'label',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.streamingfree.release:
            return {
              result: path === 'albums' && query === 'album',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.streamingfree.recording:
            return {
              result: path === 'song' && query === 'song_id',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'downloadpurchase': {
    match: [
      /^(https?:\/\/)?([^/]+\.)?audiojelly\.com/i,
      /^(https?:\/\/)?([^/]+\.)?hd-music\.info/i,
      /^(https?:\/\/)?([^/]+\.)?musa24\.fi/i,
    ],
    restrict: [LINK_TYPES.downloadpurchase],
  },
  'dram': {
    match: [/^(https?:\/\/)?([^/]+\.)?dramonline\.org\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?dramonline\.org\/((?:instruments\/)?[a-z-]+)\/([\w-]+).*$/, 'https://www.dramonline.org/$1/$2');
    },
    validate(url, id) {
      const m = /^https:\/\/www\.dramonline\.org\/([a-z-]+(?:\/[a-z-]+)?)\/[\w-]+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: /^(composers|ensembles|performers)$/.test(prefix),
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release:
            return {
              result: prefix === 'albums',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.label:
            return {
              result: prefix === 'labels',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.instrument:
            return {
              result: /^instruments\/[a-z-]+$/.test(prefix),
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'dribbble': {
    match: [/^(https?:\/\/)?(www\.)?dribbble\.com/i],
    restrict: [LINK_TYPES.artgallery],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?dribbble\.com\/([^/#?]+).*$/, 'https://dribbble.com/$1');
      return url;
    },
    validate(url) {
      const m = /^https:\/\/www\.artstation\.com\/([^/]+)$/.exec(url);
      if (m) {
        const userName = m[1];
        if (userName === 'search') {
          return {
            error: noLinkToSearchMsg(),
            result: false,
            target: ERROR_TARGETS.URL,
          };
        }
        const hardcodedPaths = [
          'directories',
          'for-designers',
          'hiring',
          'learn',
          'pro',
          'shots',
          'tags',
        ];
        if (hardcodedPaths.includes(userName)) {
          return {
            result: false,
            target: ERROR_TARGETS.URL,
          };
        }
        return {result: true};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'drip': {
    match: [
      /^(https?:\/\/)?(www\.)?d\.rip\/[^/?#]/i,
      /^(https?:\/\/)?(www\.)?drip\.kickstarter.com\/[^/?#]/i,
    ],
    restrict: [LINK_TYPES.patronage],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?d\.rip\/([^/?#]+).*$/, 'https://d.rip/$1');
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?drip\.kickstarter.com\/([^/?#]+).*$/, 'https://d.rip/$1');
      return url;
    },
  },
  'dynamicrangedb': {
    match: [/^(https?:\/\/)?dr\.loudness-war\.info/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^https:/, 'http:');
    },
    validate(url, id) {
      return {
        result: id === LINK_TYPES.otherdatabases.release,
        target: ERROR_TARGETS.ENTITY,
      };
    },
  },
  'eonkyo': {
    match: [/^(https?:\/\/)?([^/]+\.)?e-onkyo\.com/i],
    restrict: [LINK_TYPES.downloadpurchase],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?e-onkyo\.com\//, 'https://www.e-onkyo.com/');
      return url.replace(/^(https:\/\/www\.e-onkyo\.com)\/(?:music|sp)\/album\/([a-z0-9]+).*$/, '$1/music/album/$2/');
    },
    validate(url, id) {
      if (/e-onkyo\.com\/search\//.test(url)) {
        return {
          error: noLinkToSearchMsg(),
          result: false,
          target: ERROR_TARGETS.URL,
        };
      }
      const m = /^https:\/\/www\.e-onkyo\.com\/music\/album\/[a-z0-9]+\/$/.exec(url);
      if (m) {
        switch (id) {
          case LINK_TYPES.downloadpurchase.release:
            return {
              result: true,
            };
          case LINK_TYPES.downloadpurchase.artist:
          case LINK_TYPES.downloadpurchase.label:
          case LINK_TYPES.downloadpurchase.recording:
            return {
              result: false,
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'ester': {
    match: [/^(https?:\/\/)?(www\.)?ester\.ee\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?ester\.ee\/record=([^~]+).*$/, 'http://www.ester.ee/record=$1~S1*est');
      return url;
    },
  },
  'facebook': {
    match: [/^(https?:\/\/)?([\w.-]*\.)?(facebook|fb)\.com\//i],
    restrict: [LINK_TYPES.socialnetwork],
    clean(url) {
      url = url.replace(/^(https?:\/\/)?([\w.-]*\.)?(facebook|fb)\.com(\/#!)?/, 'https://www.facebook.com');
      // Remove unneeded pg section
      url = url.replace(/(facebook\.com\/)pg\//, '$1');
      /*
       * Remove ref (where the user came from),
       * sk (subpages in a page, since we want the main link)
       * and a couple others
       */
      url = url.replace(new RegExp(
        '([&?])(__tn__|_fb_noscript|_rdr|acontext|em|entry_point|filter|' +
        'focus_composer|fref|hc_location|pnref|qsefr|ref|' +
        'ref_dashboard_filter|ref_page_id|ref_type|refsrc|rf|' +
        'sid_reminder|sk|tab|viewas)=([^?&]*)',
        'g',
      ), '$1');
      // Ensure the first parameter left uses ? not to break the URL
      url = url.replace(/([&?])&+/, '$1');
      url = url.replace(/[&?]$/, '');
      // Remove trailing slashes
      if (url.match(/\?/)) {
        url = url.replace(/\/\?/, '?');
      } else {
        url = url.replace(/(facebook\.com\/.*)\/$/, '$1');
      }
      url = url.replace(/\/event\.php\?eid=/, '/events/');
      url = url.replace(/\/(?:about|info|photos_stream|timeline)([?#].*)?$/, '$1');
      return url;
    },
    validate(url) {
      if (/https:\/\/www\.facebook\.com\/search\//.test(url)) {
        return {
          error: noLinkToSearchMsg(),
          result: false,
          target: ERROR_TARGETS.URL,
        };
      }
      if (/facebook.com\/pages\//.test(url)) {
        return {
          result: /\/pages\/[^/?#]+\/\d+/.test(url),
          target: ERROR_TARGETS.URL,
        };
      }
      return {result: true, target: ERROR_TARGETS.URL};
    },
  },
  'flattr': {
    match: [/^(https?:\/\/)?(www\.)?flattr\.com\/profile\/[^/?#]/i],
    restrict: [LINK_TYPES.patronage],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?flattr\.com\/profile\/([^/?#]+).*$/, 'https://flattr.com/profile/$1');
      return url;
    },
  },
  'foursquare': {
    match: [/^(https?:\/\/)?([^/]+\.)?foursquare\.com\//i],
    restrict: [LINK_TYPES.socialnetwork],
    clean(url) {
      return url.replace(/^https?:\/\/(?:[^/]+\.)?foursquare\.com/, 'https://foursquare.com');
    },
  },
  'gakki': {
    match: [/^(https?:\/\/)?(www\.)?saisaibatake\.ame-zaiku\.com\/(gakki|gakki_illustration|musical|musical_instrument)\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(
        /^(?:https?:\/\/)?(?:www\.)?saisaibatake\.ame-zaiku\.com\/(gakki|gakki_illustration|musical|musical_instrument)\/(.*)$/,
        'https://saisaibatake.ame-zaiku.com/$1/$2',
      );
    },
    validate(url, id) {
      return {
        result: id === LINK_TYPES.otherdatabases.instrument,
        target: ERROR_TARGETS.ENTITY,
      };
    },
  },
  'generasia': {
    match: [/^(https?:\/\/)?(www\.)?generasia\.com\/wiki\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?generasia\.com\/wiki\/(.*)$/, 'https://www.generasia.com/wiki/$1');
    },
    validate(url, id) {
      return {
        result: id === LINK_TYPES.otherdatabases.artist ||
          id === LINK_TYPES.otherdatabases.label ||
          id === LINK_TYPES.otherdatabases.release_group ||
          id === LINK_TYPES.otherdatabases.work,
        target: ERROR_TARGETS.ENTITY,
      };
    },
  },
  'genie': {
    match: [
      /^(https?:\/\/)?((www|mw)\.)?genie\.co\.kr\//i,
    ],
    restrict: [
      multiple(LINK_TYPES.downloadpurchase, LINK_TYPES.streamingpaid),
      LINK_TYPES.streamingpaid,
    ],
    select(url, sourceType) {
      const m = /^https:\/\/www\.genie\.co\.kr\/detail\/(albumInfo|artistInfo|songInfo|mediaInfo)/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (prefix) {
          case 'albumInfo':
            if (sourceType === 'release') {
              return [
                LINK_TYPES.downloadpurchase.release,
                LINK_TYPES.streamingpaid.release,
              ];
            }
            break;
          case 'artistInfo':
            if (sourceType === 'artist') {
              return [
                LINK_TYPES.downloadpurchase.artist,
                LINK_TYPES.streamingpaid.artist,
              ];
            }
            break;
          case 'songInfo':
            if (sourceType === 'recording') {
              return [
                LINK_TYPES.downloadpurchase.recording,
                LINK_TYPES.streamingpaid.recording,
              ];
            }
            break;
          default: // mediaInfo
            if (sourceType === 'release') {
              return [
                LINK_TYPES.downloadpurchase.release,
                LINK_TYPES.streamingpaid.release,
              ];
            } else if (sourceType === 'recording') {
              return [
                LINK_TYPES.downloadpurchase.recording,
                LINK_TYPES.streamingpaid.recording,
              ];
            }
            break;
        }
      }
      return false;
    },
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:(?:www|mw)\.)?genie\.co\.kr\//, 'https://www.genie.co.kr/');
      url = url.replace(/^https:\/\/www\.genie\.co\.kr\/detail\/artist(?:Info|Album|Song|Mv)\?xxnm=(\d+)(?:[&#/].*)?$/, 'https://www.genie.co.kr/detail/artistInfo?xxnm=$1');
      url = url.replace(/^(https:\/\/www\.genie\.co\.kr\/detail\/(?:albumInfo\?ax|songInfo\?xg|mediaInfo\?xv)nm=\d+)(?:[&#/].*)?$/, '$1');
      return url;
    },
    validate(url, id) {
      if (/https:\/\/www\.genie\.co\.kr\/search\//.test(url)) {
        return {
          error: noLinkToSearchMsg(),
          result: false,
          target: ERROR_TARGETS.URL,
        };
      }
      const m = /^https:\/\/www\.genie\.co\.kr\/detail\/(albumInfo|artistInfo|songInfo|mediaInfo)\?(?:ax|xx|xg|xv)nm=\d+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.downloadpurchase.release:
          case LINK_TYPES.streamingpaid.release:
            return {
              result: prefix === 'albumInfo' || prefix === 'mediaInfo',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.artist:
          case LINK_TYPES.streamingpaid.artist:
            return {
              result: prefix === 'artistInfo',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.recording:
          case LINK_TYPES.streamingpaid.recording:
            return {
              result: prefix === 'songInfo' || prefix === 'mediaInfo',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'genius': {
    match: [/^(https?:\/\/)?([^/]+\.)?genius\.com/i],
    restrict: [{
      ...LINK_TYPES.lyrics,
      place: LINK_TYPES.otherdatabases.place,
    }],
    clean(url) {
      url = url.replace(/^https?:\/\/([^/]+\.)?genius\.com/, 'https://genius.com');
      url = url.replace(/^https:\/\/genius\.com\/artists\/([\w-]+)(?:\/.*)?/, 'https://genius.com/artists/$1');
      return url;
    },
    validate(url, id) {
      switch (id) {
        case LINK_TYPES.lyrics.artist:
        case LINK_TYPES.lyrics.label:
        case LINK_TYPES.otherdatabases.place:
          return {
            result: /^https:\/\/genius\.com\/artists\/[\w-]+$/.test(url),
            target: ERROR_TARGETS.ENTITY,
          };
        case LINK_TYPES.lyrics.release_group:
          return {
            result: /^https:\/\/genius\.com\/albums\/[\w-]+\/[\w-]+$/.test(url),
            target: ERROR_TARGETS.ENTITY,
          };
        case LINK_TYPES.lyrics.work:
          return {
            result: /^https:\/\/genius\.com\/(?!(?:artists|albums)\/)[\w-]+-lyrics$/.test(url),
            target: ERROR_TARGETS.ENTITY,
          };
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'geonames': {
    match: [/^https?:\/\/([a-z]+\.)?geonames\.org\/([0-9]+)\/.*$/i],
    restrict: [LINK_TYPES.geonames],
    clean(url) {
      return url.replace(/^https?:\/\/(?:[a-z]+\.)?geonames.org\/([0-9]+)\/.*$/, 'http://sws.geonames.org/$1/');
    },
  },
  'goodreads': {
    match: [/^(https?:\/\/)?(www\.)?goodreads\.com/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?goodreads\.com\/(author|book|series)\/(?:[a-z]+\/)?([0-9]+).*$/, 'https://www.goodreads.com/$1/show/$2');
    },
    validate(url, id) {
      const m = /^https:\/\/www\.goodreads\.com\/(author|book|series)\/show\/[0-9]+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'author',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release:
            return {
              result: prefix === 'book',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.series:
            return {
              result: prefix === 'series',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'googleplay': {
    match: [/^(https?:\/\/)?play\.google\.com\/store\/music\//i],
    clean(url) {
      return url.replace(/^https?:\/\/play\.google\.com\/store\/music\/(artist|album)(?:\/[^?]*)?\?id=([^&#]+)(?:[&#].*)?$/, 'https://play.google.com/store/music/$1?id=$2');
    },
  },
  'googleplus': {
    match: [/^(https?:\/\/)?([^/]+\.)?plus\.google\.com\//i],
    restrict: [LINK_TYPES.socialnetwork],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?plus\.google\.com\/(?:u\/[0-9]\/)?([0-9]+)(\/.*)?$/, 'https://plus.google.com/$1');
    },
  },
  'hmikuwiki': {
    match: [/^(https?:\/\/)?(?:www5\.)?atwiki\.jp\/hmiku\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www5\.)?atwiki\.jp\/([^#]+)(?:#.*)?$/, 'https://www5.atwiki.jp/$1');
    },
    validate(url, id) {
      if (/^https:\/\/www5\.atwiki\.jp\/hmiku\/pages\/[1-9][0-9]*\.html$/.test(url)) {
        if (id === LINK_TYPES.otherdatabases.artist ||
            id === LINK_TYPES.otherdatabases.release_group ||
            id === LINK_TYPES.otherdatabases.work) {
          return {result: true};
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'hoick': {
    match: [/^(https?:\/\/)?([^/]+\.)?hoick\.jp\//i],
    restrict: [{...LINK_TYPES.mailorder, ...LINK_TYPES.lyrics}],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?hoick\.jp\/(mdb\/detail\/\d+|mdb\/author|products\/detail\/\d+)\/([^/?#]+).*$/, 'https://hoick.jp/$1/$2');
    },
    validate(url, id) {
      const m = /^https:\/\/hoick\.jp\/(mdb|products)\/(author|detail)(\/\d+)?\/[^/?#]+$/.exec(url);
      if (m) {
        const db = m[1];
        const type = m[2];
        const slashRef = m[3];
        switch (id) {
          case LINK_TYPES.lyrics.artist:
            return {
              result: db === 'mdb' &&
                type === 'author' &&
                slashRef === undefined,
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.mailorder.release:
            return {
              result: db === 'products' &&
                type === 'detail' &&
                slashRef !== undefined,
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.lyrics.work:
            return {
              result: db === 'mdb' &&
                type === 'detail' &&
                slashRef !== undefined,
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'ibdb': {
    match: [/^(https?:\/\/)?(www\.)?ibdb\.com\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(https?:\/\/)?(?:www\.)?ibdb\.com/, 'https://www.ibdb.com');
      return url;
    },
  },
  'idref': {
    match: [/^(https?:\/\/)?(www\.)?idref\.fr\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?idref\.fr/, 'https://www.idref.fr');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/www\.idref\.fr\/[\dX]+?$/.exec(url);
      if (m) {
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
          case LINK_TYPES.otherdatabases.genre:
          case LINK_TYPES.otherdatabases.instrument:
          case LINK_TYPES.otherdatabases.label:
          case LINK_TYPES.otherdatabases.place:
          case LINK_TYPES.otherdatabases.series:
          case LINK_TYPES.otherdatabases.work:
            return {result: true};
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'imdb': {
    match: [/^(https?:\/\/)?([^/]+\.)?imdb\./i],
    restrict: [LINK_TYPES.imdb],
    clean(url) {
      return url.replace(/^https?:\/\/([^.]+\.)?imdb\.(com|de|it|es|fr|pt)\/([a-z]+\/[a-z0-9]+)(\/.*)*$/, 'https://www.imdb.com/$3/');
    },
    validate(url, id) {
      const m = /^https:\/\/www\.imdb\.com\/(name\/nm|title\/tt|character\/ch|company\/co)[0-9]{7,}\/$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.imdb.artist:
            return {
              result: prefix === 'name/nm' ||
                prefix === 'character/ch' ||
                prefix === 'company/co',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.imdb.label:
          case LINK_TYPES.imdb.place:
            return {
              result: prefix === 'company/co',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.imdb.recording:
          case LINK_TYPES.imdb.release:
          case LINK_TYPES.imdb.release_group:
          case LINK_TYPES.imdb.work:
            return {
              result: prefix === 'title/tt',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'imslp': {
    match: [/^(https?:\/\/)?(www\.)?imslp\.org\//i],
    restrict: [{...LINK_TYPES.score, ...LINK_TYPES.imslp}],
    clean(url) {
      // Standardise to https
      return url.replace(/^https?:\/\/(?:www\.)?(.*)$/, 'https://$1');
    },
    validate(url, id) {
      switch (id) {
        case LINK_TYPES.imslp.artist:
          if (/^https:\/\/imslp\.org\/wiki\/Category:/.test(url)) {
            return {result: true};
          }
          return {
            error: exp.l(
              `Only IMSLP “{category_url_pattern}” links are allowed
               for artists. Please link work pages to the specific
               work in question.`,
              {
                category_url_pattern: (
                  <span className="url-quote">{'Category:'}</span>
                ),
              },
            ),
            result: false,
            target: ERROR_TARGETS.ENTITY,
          };
        case LINK_TYPES.score.work:
          if (/^https:\/\/imslp\.org\/wiki\/(?!Category:)/.test(url)) {
            return {result: true};
          }
          return {
            error: exp.l(
              `IMSLP “{category_url_pattern}” links are only allowed
               for artists. Please link the specific work page to this
               work instead, if available.`,
              {
                category_url_pattern: (
                  <span className="url-quote">{'Category:'}</span>
                ),
              },
            ),
            result: false,
            target: ERROR_TARGETS.ENTITY,
          };
      }
      return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
    },
  },
  'indiegogo': {
    match: [/^(https?:\/\/)?(www\.)?indiegogo\.com\/(individuals|projects)\//i],
    restrict: [LINK_TYPES.crowdfunding],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?indiegogo\.com\/individuals\/(\d+)(?:[/?#].*)?$/, 'https://www.indiegogo.com/individuals/$1');
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?indiegogo\.com\/projects\/([\w-]+)(?:[/?#].*)?$/, 'https://www.indiegogo.com/projects/$1');
      return url;
    },
  },
  'instagram': {
    match: [/^(https?:\/\/)?([^/]+\.)?instagram\.com\//i],
    restrict: [{...LINK_TYPES.streamingfree, ...LINK_TYPES.socialnetwork}],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?instagram\.com\/(?:p|tv)\/([^/?#]+).*$/, 'https://www.instagram.com/p/$1/');
      // Ignore explore URLs since we'll block them anyway
      if (!(/^https:\/\/www\.instagram\.com\/(explore|p)\//.test(url))) {
        // Point /stories/ sections to the main user profile instead
        url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?instagram\.com\/stories\/([^/?#]+).*$/, 'https://www.instagram.com/$1/');
        url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?instagram\.com\/([^/?#]+).*$/, 'https://www.instagram.com/$1/');
      }
      return url;
    },
    validate(url, id) {
      if (/^https:\/\/www\.instagram\.com\/explore\//.test(url)) {
        return {
          error: exp.l(
            `Instagram “{explore_url_pattern}” links are not allowed.
             Please link to a profile instead, if there is one.`,
            {
              explore_url_pattern: (
                <span className="url-quote">{'/explore'}</span>
              ),
            },
          ),
          result: false,
          target: ERROR_TARGETS.URL,
        };
      }
      const m = /^https:\/\/www\.instagram\.com\/([^/]+)\/([^/?#]+\/)?$/.exec(url);
      if (m) {
        const prefix = m[1];
        const target = m[2];
        if (
          id === LINK_TYPES.streamingfree.recording ||
          id === LINK_TYPES.streamingfree.release
        ) {
          return {
            result: prefix === 'p' && target !== undefined,
            target: ERROR_TARGETS.RELATIONSHIP,
          };
        } else if (Object.values(LINK_TYPES.socialnetwork).includes(id)) {
          if (prefix === 'p') {
            return {
              error: exp.l(
                `Please do not link directly to images,
                 link to the appropriate Instagram profile page instead.
                 If you want to link to a video,
                 {url|add a standalone recording} for it instead.`,
                {
                  url: {
                    href: '/recording/create',
                    target: '_blank',
                  },
                },
              ),
              result: false,
              target: ERROR_TARGETS.URL,
            };
          }
          if ([
            'accounts',
            'accounts_center',
            'direct',
            'email',
            'push',
            'session',
          ].includes(prefix)) {
            return {
              error: l(
                `This is an internal Instagram page and should not be added.`,
              ),
              result: false,
              target: ERROR_TARGETS.URL,
            };
          }
          return {
            result: /^(?!(?:explore|p|stories|tv)$)/.test(prefix) &&
              target === undefined,
            target: ERROR_TARGETS.RELATIONSHIP,
          };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'irishtune': {
    match: [/^(https?:\/\/)?(www\.)?irishtune\.info/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?irishtune\.info\/(album\/[A-Za-z+0-9]+|tune\/\d+)(?:[/?#].*)?$/, 'https://www.irishtune.info/$1/');
    },
    validate(url, id) {
      const m = /^https:\/\/www\.irishtune\.info\/(?:(album)\/[A-Za-z+0-9]+|(tune)\/\d+)\/$/.exec(url);
      if (m) {
        const prefix = m[1] || m[2];
        switch (id) {
          case LINK_TYPES.otherdatabases.release_group:
            return {
              result: prefix === 'album',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.work:
            return {
              result: prefix === 'tune',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'irombook': {
    match: [/^https:\/\/static\.metabrainz\.org\/irombook\//],
    restrict: [LINK_TYPES.image],
    validate(url, id) {
      return {
        result: id === LINK_TYPES.image.instrument,
        target: ERROR_TARGETS.RELATIONSHIP,
      };
    },
  },
  'itunes': {
    match: [/^(https?:\/\/)?([^/]+\.)?itunes\.apple\.com\//i],
    restrict: [LINK_TYPES.downloadpurchase],
    clean(url) {
      url = url.replace(/^https?:\/\/(?:geo\.)?itunes\.apple\.com\/([a-z]{2}\/)?(artist|album|audiobook|author|music-video|podcast|preorder)\/(?:[^?#/]+\/)?(?:id)?([0-9]+)(?:\?.*)?$/, 'https://itunes.apple.com/$1$2/id$3');
      // Author seems to be a different interface for artist with the same ID
      url = url.replace(/^(https:\/\/itunes\.apple\.com(?:\/[a-z]{2})?)\/author\//, '$1/artist/');
      // US store is the default, add its country-code to clarify (MBS-10623)
      url = url.replace(/^(https:\/\/itunes\.apple\.com)\/([a-z-]{3,})\//, '$1/us/$2/');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/itunes\.apple\.com\/[a-z]{2}\/([a-z-]{3,})\/id[0-9]+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.downloadpurchase.artist:
            if (prefix === 'artist') {
              return {result: true};
            }
            return {
              result: false,
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.recording:
            return {
              result: prefix === 'music-video',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.release:
            return {
              result: /^(album|audiobook|podcast|preorder)$/.test(prefix),
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'jamendo': {
    match: [/^(https?:\/\/)?([^/]+\.)?jamendo\.com/i],
    restrict: [multiple(LINK_TYPES.downloadfree, LINK_TYPES.streamingfree)],
    clean(url) {
      url = url.replace(/jamendo\.com\/(?:\w\w\/)?(album|list|track)\/([^/]+)(\/.*)?$/, 'jamendo.com/$1/$2');
      url = url.replace(/img\.jamendo\.com\/albums\/(\d+)\/covers\/\d+\.\d+\.jpg/, 'www.jamendo.com/album/$1/');
      url = url.replace(/jamendo\.com\/\w\w\/artist\//, 'jamendo.com/artist/');
      return url;
    },
  },
  'jaxsta': {
    match: [/^(https?:\/\/)?(www\.)?jaxsta\.com/i],
    restrict: [
      LINK_TYPES.otherdatabases,
      {work: [LINK_TYPES.otherdatabases.work, LINK_TYPES.lyrics.work]},
    ],
    select(url, sourceType) {
      const m = /^https:\/\/jaxsta\.com\/(\w+)\/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}(?:\/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})?$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (prefix) {
          case 'work':
            if (sourceType === 'work') {
              return LINK_TYPES.otherdatabases.work;
            }
            break;
        }
      }
      return false;
    },
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?jaxsta\.com\/([^#?]+).*$/, 'https://jaxsta.com/$1');
      url = url.replace(/^https:\/\/jaxsta\.com\/(\w+)\/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})(\/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})?.*$/, 'https://jaxsta.com/$1/$2$3');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/jaxsta\.com\/(\w+)\/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}(\/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})?$/.exec(url);
      if (m) {
        const type = m[1];
        const hasVariant = Boolean(m[2]);
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: type === 'profile',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.label:
            return {
              result: type === 'profile',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.recording:
            return {
              result: type === 'recording',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release:
            return {
              result: type === 'release' && hasVariant,
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.lyrics.work:
          case LINK_TYPES.otherdatabases.work:
            return {
              result: type === 'work',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'jazzmusicarchives': {
    match: [/^(https?:\/\/)?(www\.)?jazzmusicarchives\.com/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?jazzmusicarchives\.com\/([^#?]+).*$/, 'https://www.jazzmusicarchives.com/$1');
      url = url.replace(/\/+$/, '');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/www\.jazzmusicarchives\.com\/(\w+)\/(?:[\w%()-]+\/)?[\w%()-]*$/.exec(url);
      if (m) {
        const type = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: type === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.recording:
            return {
              result: type === 'video',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release_group:
            return {
              result: type === 'album',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'joysound': {
    match: [/^(https?:\/\/)?([^/]+\.)?joysound\.com\//i],
    restrict: [LINK_TYPES.lyrics],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?joysound\.com\/(web\/search\/(?:artist|song)\/\d+).*$/, 'https://www.joysound.com/$1');
    },
    validate(url, id) {
      const m = /^https:\/\/www.joysound\.com\/web\/search\/(artist|song)\/\d+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.lyrics.artist:
            return {
              result: prefix === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.lyrics.work:
            return {
              result: prefix === 'song',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'junodownload': {
    match: [/^(?:https?:\/\/)?(?:www\.)?junodownload\.com/i],
    restrict: [LINK_TYPES.downloadpurchase],
    clean(url) {
      url = url.replace(/^https?:\/\/(?:www\.)?junodownload\.com\/([^?#]+).*$/, 'https://www.junodownload.com/$1');
      url = url.replace(/^https:\/\/www\.junodownload\.com\/(artists|labels)\/([^/]+).*$/, 'https://www.junodownload.com/$1/$2/');
      url = url.replace(/^https:\/\/www\.junodownload\.com\/products\/(?:[\w\d-]+\/)?([\d-]+)(?:.htm)?.*$/, 'https://www.junodownload.com/products/$1/');
      return url;
    },
    validate(url, id) {
      if (/https:\/\/www\.junodownload\.com\/search\//.test(url)) {
        return {
          error: noLinkToSearchMsg(),
          result: false,
          target: ERROR_TARGETS.URL,
        };
      }
      const m = /^https:\/\/www\.junodownload\.com\/(artists|labels|products)\/[\w\d+-]+\/$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.downloadpurchase.artist:
            return {
              result: prefix === 'artists',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.label:
            return {
              result: prefix === 'labels',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.release:
            return {
              result: prefix === 'products',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'kashinavi': {
    match: [/^(https?:\/\/)?([^/]+\.)?kashinavi\.com\//i],
    restrict: [LINK_TYPES.lyrics],
    clean(url) {
      const m = /^(?:https?:\/\/)?(?:[^/]+\.)?kashinavi\.com\/(.*)$/.exec(url);
      if (m) {
        let tail = m[1];
        tail = tail.replace(/^(song_view\.html\?\d+).*$/, '$1');
        tail = tail.replace(/^(kashu\.php\?).*(artist=\d+).*$/, '$1$2');
        url = 'https://kashinavi.com/' + tail;
      }
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/kashinavi\.com\/(.+)$/.exec(url);
      if (m) {
        const tail = m[1];
        switch (id) {
          case LINK_TYPES.lyrics.artist:
            return {
              result: /^kashu\.php\?artist=\d+$/.test(tail),
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.lyrics.work:
            return {
              result: /^song_view\.html\?\d+$/.test(tail),
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'kbr': {
    match: [/^(https?:\/\/)?opac\.kbr\.be\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      // Standardise to https
      return url.replace(/^https?:\/\/(?:www\.)?(.*)$/, 'https://$1');
    },
    validate(url, id) {
      const m = /^https:\/\/opac\.kbr\.be\/LIBRARY\/doc\/(AUTHORITY|SYRACUSE)\/[0-9]+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
          case LINK_TYPES.otherdatabases.label:
            return {
              result: prefix === 'AUTHORITY',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release:
            return {
              result: prefix === 'SYRACUSE',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'kickstarter': {
    match: [/^(https?:\/\/)?(www\.)?kickstarter\.com\/(profile|projects)\//i],
    restrict: [LINK_TYPES.crowdfunding],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?kickstarter\.com\/profile\/([\w-]+)(?:[/?#].*)?$/, 'https://www.kickstarter.com/profile/$1');
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?kickstarter\.com\/projects\/(\d+)\/([\w-]+)(?:[/?#].*)?$/, 'https://www.kickstarter.com/projects/$1/$2');
      return url;
    },
  },
  'kofi': {
    match: [/^(https?:\/\/)?(www\.)?ko-fi\.com\/(?!s\/)/i],
    restrict: [LINK_TYPES.patronage],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?ko-fi\.com\/([^/?#]+).*$/, 'https://ko-fi.com/$1');
      return url;
    },
  },
  'laboiteauxparoles': {
    match: [/^(https?:\/\/)?([^/]+\.)?laboiteauxparoles\.com/i],
    restrict: [LINK_TYPES.lyrics],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?laboiteauxparoles\.com\/(auteur|editeur|interprete|titre)\/([^/?#]+).*$/, 'https://laboiteauxparoles.com/$1/$2');
    },
    validate(url, id) {
      const m = /^https:\/\/laboiteauxparoles\.com\/(auteur|editeur|interprete|titre)\//.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.lyrics.artist:
            return {
              result: /^(?:auteur|interprete)$/.test(prefix),
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.lyrics.label:
            return {
              result: prefix === 'editeur',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.lyrics.work:
            return {
              result: prefix === 'titre',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'lantis': {
    match: [
      /^(https?:\/\/)?(www\.)?lantis\.jp\/release-item2\.php\?id=[0-9a-f]{32}$/i,
      /^(https?:\/\/)?(www\.)?lantis\.jp\/release-item\/[A-Z]+-\d+(\.html)?$/i,
    ],
    restrict: [LINK_TYPES.discographyentry],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?lantis\.jp\//, 'https://www.lantis.jp/');
      url = url.replace(/^(https:\/\/www\.lantis\.jp)\/release-item\/([A-Z]+-\d+)$/, '$1/release-item/$2.html');
      return url;
    },
  },
  'lastfm': {
    match: [/^(https?:\/\/)?([^/]+\.)?(last\.fm|lastfm\.(com\.br|com\.tr|at|com|de|es|fr|it|jp|pl|pt|ru|se))\/([a-z]{2}\/)?(music|label|venue|event|festival)\//i],
    restrict: [LINK_TYPES.lastfm],
    clean(url) {
      url = url.replace(/^(https?:\/\/)?((www|cn|m)\.)?(last\.fm|lastfm\.(com\.br|com\.tr|at|com|de|es|fr|it|jp|pl|pt|ru|se))\/([a-z]{2}\/)?/, 'https://www.last.fm/');
      url = url.replace(/^https:\/\/www\.last\.fm\/(?:[a-z]{2}\/)?([a-z]+)\/([^?#]+).*$/, 'https://www.last.fm/$1/$2');
      return url;
    },
  },
  'lastfm_user': {
    match: [/^(https?:\/\/)?([^/]+\.)?(last\.fm|lastfm\.(com\.br|com\.tr|at|com|de|es|fr|it|jp|pl|pt|ru|se))\/user\//i],
    restrict: [LINK_TYPES.socialnetwork],
    clean(url) {
      return url.replace(/^(https?:\/\/)?((www|cn|m)\.)?(last\.fm|lastfm\.(com\.br|com\.tr|at|com|de|es|fr|it|jp|pl|pt|ru|se))/, 'https://www.last.fm');
    },
  },
  'libraryofcongress': {
    match: [/^(https?:\/\/)?id\.loc\.gov\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(id\.loc\.gov\/authorities\/names\/[a-z]+\d+)(?:[.#].*)?$/, 'http://$1');
    },
    validate(url, id) {
      if (/^http:\/\/id\.loc\.gov\/authorities\/names\/[a-z]+\d+$/.test(url)) {
        if (id === LINK_TYPES.otherdatabases.artist ||
            id === LINK_TYPES.otherdatabases.label ||
            id === LINK_TYPES.otherdatabases.place ||
            id === LINK_TYPES.otherdatabases.series ||
            id === LINK_TYPES.otherdatabases.work) {
          return {result: true};
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'librarything': {
    match: [/^(https?:\/\/)?(www\.)?librarything\.com/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?librarything\.com\/(author|nseries|work)\/([0-9a-z-]+)(?:[/?#].*)?$/, 'https://www.librarything.com/$1/$2');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/www\.librarything\.com\/([a-z]+)\/[0-9a-z-]+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'author',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.series:
            return {
              result: prefix === 'nseries',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release_group:
          case LINK_TYPES.otherdatabases.work:
            return {
              result: prefix === 'work',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'librivox': {
    match: [/^(https?:\/\/)?(www\.)?librivox\.org/i],
    restrict: [LINK_TYPES.downloadfree],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?librivox\.org\/((?:author|reader)\/[\d]+|[\w\d-]+).*$/, 'https://librivox.org/$1');
    },
    validate(url, id) {
      if (/^https:\/\/librivox\.org\/search$/.test(url)) {
        return {
          error: noLinkToSearchMsg(),
          result: false,
          target: ERROR_TARGETS.URL,
        };
      }

      const isArtist = /^https:\/\/librivox\.org\/(?:author|reader)\/[\d]+$/.test(url);
      const isRelease = /^https:\/\/librivox\.org\/[\w\d-]+$/.test(url);
      if (isArtist || isRelease) {
        switch (id) {
          case LINK_TYPES.downloadfree.artist:
            return {
              result: isArtist,
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadfree.release:
            return {
              result: isRelease,
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'license': {
    match: [
      /^(https?:\/\/)?([^/]+\.)?artlibre\.org\/licence/i,
      /^(https?:\/\/)?([^/]+\.)?creativecommons\.org\/(licenses|publicdomain)\//i,
    ],
    restrict: [LINK_TYPES.license],
    clean(url) {
      url = url.replace(/^(https?:\/\/)?([^/]+\.)?creativecommons\.org\//, 'https://creativecommons.org/');
      url = url.replace(/^https:\/\/creativecommons\.org\/(licenses|publicdomain)\/(.+)\/(?:(?:legalcode|deed)(?:[.-][A-Za-z_]+)?)?/, 'https://creativecommons.org/$1/$2/');
      // make sure there is exactly one terminating slash
      url = url.replace(/^(https:\/\/creativecommons\.org\/licenses\/(?:by|(?:by-|)(?:nc|nc-nd|nc-sa|nd|sa)|(?:nc-|)sampling\+?)\/[0-9]+\.[0-9]+(?:\/(?:ar|au|at|be|br|bg|ca|cl|cn|co|cr|hr|cz|dk|ec|ee|fi|fr|de|gr|gt|hk|hu|in|ie|il|it|jp|lu|mk|my|mt|mx|nl|nz|no|pe|ph|pl|pt|pr|ro|rs|sg|si|za|kr|es|se|ch|tw|th|uk|scotland|us|vn)|))\/*$/, '$1/');
      url = url.replace(/^(https:\/\/creativecommons\.org\/publicdomain\/zero\/[0-9]+\.[0-9]+)\/*$/, '$1/');
      url = url.replace(/^(https:\/\/creativecommons\.org\/licenses\/publicdomain)\/*$/, '$1/');

      url = url.replace(/^(https?:\/\/)?([^/]+\.)?artlibre\.org\//, 'http://artlibre.org/');
      url = url.replace(/^http:\/\/artlibre\.org\/licence\.php\/lal\.html/, 'http://artlibre.org/licence/lal');
      return url;
    },
  },
  'linkedin': {
    match: [/^(https?:\/\/)?([^/]+\.)?linkedin\.com\//i],
    restrict: [LINK_TYPES.socialnetwork],
    clean(url) {
      return url.replace(/^https?:\/\/(?:[^/]+\.)?linkedin\.com\/([^?#]+).*$/, 'https://www.linkedin.com/$1');
    },
  },
  'livefans': {
    match: [/^(https?:\/\/)?(www\.)?livefans\.jp/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/(venues)\/(?:past|future)\//, '$1/');
      url = url.replace(/(venues)\/facility\?.*v_id=([0-9]+).*$/, '$1/$2');
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?livefans\.jp\/([^?#]+[^/?#])\/*(?:[?#].*)?$/, 'https://www.livefans.jp/$1');
    },
    validate(url, id) {
      const m = /^https:\/\/www\.livefans\.jp\/([a-z]+)\/[0-9]+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'artists',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.event:
            return {
              result: prefix === 'events',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.series:
            return {
              result: prefix === 'groups',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.place:
            return {
              result: prefix === 'venues',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'livenation': {
    match: [/^(https?:\/\/)?(?:(?:concerts|www)\.)?livenation\.(?:[a-z]{2,3}?\.)?[a-z]{2,4}\//i],
    restrict: [LINK_TYPES.ticketing],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?concerts\.livenation\.com\/(?:[\w\d-]+\/)?event\/([0-9A-F]+).*$/, 'https://concerts.livenation.com/event/$1');
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?livenation\.com\/(artist|event|venue)\/([\w-]+).*$/, 'https://www.livenation.com/$1/$2');
      // International sites use somewhat different formats
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?livenation\.((?:[a-z]{2,3}?\.)?[a-z]{2,4})\/(show|venue)\/([\w-]+).*$/, 'https://www.livenation.$1/$2/$3');
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?livenation\.((?:[a-z]{2,3}?\.)?[a-z]{2,4})\/artist-[\w\d-]+-([0-9]+).*$/, 'https://www.livenation.$1/artist-$2');
      return url;
    },
    validate(url, id) {
      let m = /^https:\/\/(concerts|www)\.livenation\.(?:[a-z]{2,3}?\.)?[a-z]{2,4}\/(artist|event|show|venue)\/[\w-]+$/.exec(url);
      if (!m) {
        m = /^https:\/\/(www)\.livenation\.(?:[a-z]{2,3}?\.)?[a-z]{2,4}\/(artist)-[0-9]+$/.exec(url);
      }
      if (m) {
        const subdomain = m[1];
        const prefix = m[2];
        switch (id) {
          case LINK_TYPES.ticketing.artist:
            if (prefix === 'artist' && subdomain === 'www') {
              return {result: true};
            }
            return {result: false, target: ERROR_TARGETS.ENTITY};
          case LINK_TYPES.ticketing.event:
            if (prefix === 'event' || prefix === 'show') {
              return {result: true};
            }
            return {result: false, target: ERROR_TARGETS.ENTITY};
          case LINK_TYPES.ticketing.place:
            if (prefix === 'venue' && subdomain === 'www') {
              return {result: true};
            }
            return {result: false, target: ERROR_TARGETS.ENTITY};
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'loudr': {
    match: [/^(https?:\/\/)?loudr\.fm\//i],
    restrict: [LINK_TYPES.downloadpurchase],
    clean(url) {
      url = url.replace(/^https?:\/\/loudr\.fm\/(artist|release)\/([a-zA-Z0-9_-]+)\/([a-zA-Z0-9_-]{5}).*$/, 'https://loudr.fm/$1/$2/$3');
      return url;
    },
  },
  'lyricevesta': {
    match: [/^(https?:\/\/)?([^/]+\.)?lyric\.evesta\.jp\//i],
    restrict: [LINK_TYPES.lyrics],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?lyric\.evesta\.jp\/([al]\w+\.html).*$/, 'http://lyric.evesta.jp/$1');
    },
    validate(url, id) {
      const m = /^http:\/\/lyric\.evesta\.jp\/([al])\w+\.html$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.lyrics.artist:
            return {
              result: prefix === 'a',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.lyrics.work:
            return {
              result: prefix === 'l',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'lyrics': {
    match: [
      /^(https?:\/\/)?([^/]+\.)?directlyrics\.com/i,
      /^(https?:\/\/)?([^/]+\.)?lieder\.net/i,
      /^(https?:\/\/)?([^/]+\.)?utamap\.com/i,
      /^(https?:\/\/)?([^/]+\.)?j-lyric\.net/i,
      /^(https?:\/\/)?([^/]+\.)?muzikum\.eu/i,
      /^(https?:\/\/)?([^/]+\.)?gutenberg\.org/i,
    ],
    restrict: [LINK_TYPES.lyrics],
  },
  'mainlynorfolk': {
    match: [/^(https?:\/\/)?(www\.)?mainlynorfolk\.info/i],
    restrict: [
      LINK_TYPES.otherdatabases,
      {work: [LINK_TYPES.otherdatabases.work, LINK_TYPES.lyrics.work]},
    ],
    select(url, sourceType) {
      const m = /^https:\/\/mainlynorfolk\.info\/(?:[^/]+)\/(records|songs)?/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (prefix) {
          case 'songs':
            if (sourceType === 'work') {
              return LINK_TYPES.otherdatabases.work;
            }
            break;
        }
      }
      return false;
    },
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?mainlynorfolk\.info\//, 'https://mainlynorfolk.info/');
      url = url.replace(/^https:\/\/mainlynorfolk\.info\/([^/]+)(?:\/index\.html)?$/, 'https://mainlynorfolk.info/$1/');
      return url;
    },
    validate(url, id) {
      if (id === LINK_TYPES.otherdatabases.artist) {
        return {
          result: /^https:\/\/mainlynorfolk\.info\/(?:[^/]+)\/$/.test(url),
          target: ERROR_TARGETS.RELATIONSHIP,
        };
      }
      const m = /^https:\/\/mainlynorfolk\.info\/(?:[^/]+)\/(records|songs)\/(?:[^/]+)$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.release:
            return {
              result: prefix === 'records',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.lyrics.work:
          case LINK_TYPES.otherdatabases.work:
            return {
              result: prefix === 'songs',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'maniadb': {
    match: [/^(https?:\/\/)?(www\.)?maniadb\.com/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?maniadb\.com\/(?:index.php\/)?(album|artist)(?:\/|\.asp[?][ap]=)([0-9]+).*$/, 'http://www.maniadb.com/$1/$2');
    },
    validate(url, id) {
      const m = /^http:\/\/www\.maniadb\.com\/(album|artist)\/[0-9]+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release_group:
            return {
              result: prefix === 'album',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'melon': {
    match: [/^(https?:\/\/)?((www|m2)\.)?melon\.com\//i],
    restrict: [
      multiple(LINK_TYPES.downloadpurchase, LINK_TYPES.streamingpaid),
      LINK_TYPES.streamingpaid,
    ],
    select(url, sourceType) {
      const m = /^https:\/\/www\.melon\.com\/(album|artist|song|video)/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (prefix) {
          case 'album':
            if (sourceType === 'release') {
              return [
                LINK_TYPES.downloadpurchase.release,
                LINK_TYPES.streamingpaid.release,
              ];
            }
            break;
          case 'artist':
            if (sourceType === 'artist') {
              return [
                LINK_TYPES.downloadpurchase.artist,
                LINK_TYPES.streamingpaid.artist,
              ];
            }
            break;
          case 'song':
            if (sourceType === 'recording') {
              return [
                LINK_TYPES.downloadpurchase.recording,
                LINK_TYPES.streamingpaid.recording,
              ];
            }
            break;
          default: // video
            if (sourceType === 'release') {
              return [
                LINK_TYPES.downloadpurchase.release,
                LINK_TYPES.streamingpaid.release,
              ];
            } else if (sourceType === 'recording') {
              return [
                LINK_TYPES.downloadpurchase.recording,
                LINK_TYPES.streamingpaid.recording,
              ];
            }
            break;
        }
      }
      return false;
    },
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:(?:www|m2)\.)?melon\.com\//, 'https://www.melon.com/');
      url = url.replace(/^(https:\/\/www\.melon\.com\/album)\/(?:detail|music)\.htm\?(albumId=\d+)(?:[/#&].*)?$/, '$1/detail.htm?$2');
      url = url.replace(/^(https:\/\/www\.melon\.com\/artist)\/(?:timeline|detail|song|album|video|photo|fan|hifi|song\/all|detail\/info|magazine)\.htm\?(artistId=\d+)(?:[/#&].*)?$/, '$1/detail.htm?$2');
      url = url.replace(/^(https:\/\/www\.melon\.com\/song\/detail\.htm\?songId=\d+)(?:[/#&].*)?$/, '$1');
      url = url.replace(/^(https:\/\/www\.melon\.com\/video)\/detail2?\.htm\?(mvId=\d+)(?:[/#&].*)?$/, '$1/detail2.htm?$2');
      return url;
    },
    validate(url, id) {
      if (/https:\/\/www\.melon\.com\/search\//.test(url)) {
        return {
          error: noLinkToSearchMsg(),
          result: false,
          target: ERROR_TARGETS.URL,
        };
      }
      const m = /^https:\/\/www\.melon\.com\/(album|artist|song|video)\/detail.htm\?(?:albumId|artistId|songId|mvId)=\d+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.downloadpurchase.release:
          case LINK_TYPES.streamingpaid.release:
            return {
              result: prefix === 'album' || prefix === 'video',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.artist:
          case LINK_TYPES.streamingpaid.artist:
            return {
              result: prefix === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.recording:
          case LINK_TYPES.streamingpaid.recording:
            return {
              result: prefix === 'song' || prefix === 'video',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'metacritic': {
    match: [/^(https?:\/\/)?(www\.)?metacritic\.com/i],
    restrict: [LINK_TYPES.review],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?metacritic\.com\/music\/([\w-]+\/[\w-]+).*$/, 'https://www.metacritic.com/music/$1');
    },
    validate(url, id) {
      const isReview = /^https:\/\/www\.metacritic\.com\/music\/[\w-]+\/[\w-]+$/.test(url);
      if (isReview) {
        return {
          result: id === LINK_TYPES.review.release_group,
          target: ERROR_TARGETS.ENTITY,
        };
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'metalarchives': {
    match: [/^(https?:\/\/)?(www\.)?metal-archives\.com\//i],
    restrict: [{...LINK_TYPES.otherdatabases, ...LINK_TYPES.review}],
    clean(url) {
      return url.replace(
        /^(?:https?:\/\/)?(?:www\.)?metal-archives\.com\/([a-z]+(?:\/[^/?#]+)+).*$/,
        'https://www.metal-archives.com/$1',
      );
    },
    validate(url, id) {
      const m = /^https:\/\/www\.metal-archives\.com\/([a-z]+)\/[^?#]+[^/?#]$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: /^(?:artists?|bands?)$/.test(prefix),
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.label:
            return {
              result: prefix === 'labels',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release:
            return {
              result: prefix === 'albums',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.review.release_group:
            return {
              result: prefix === 'reviews',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'metalmusicarchives': {
    match: [/^(https?:\/\/)?(www\.)?metalmusicarchives\.com/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?metalmusicarchives\.com\/([^#?]+).*$/, 'https://www.metalmusicarchives.com/$1');
      url = url.replace(/\/+$/, '');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/www\.metalmusicarchives\.com\/(\w+)\/(?:[\w%()-]+\/)?[\w%()-]*$/.exec(url);
      if (m) {
        const type = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: type === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.recording:
            return {
              result: type === 'video',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release_group:
            return {
              result: type === 'album',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'migumusic': {
    match: [/^(https?:\/\/)?[^/]*music\.migu\.cn/i],
    restrict: [LINK_TYPES.streamingfree],
    clean(url) {
      url = url.replace(
        /^(?:https?:\/\/)?(?:cdn|www\.)?music\.migu\.cn\/v3\/(live|(?:music|video)\/\w+)\/([^/?#]+).*$/,
        'https://music.migu.cn/v3/$1/$2',
      );
      url = url.replace(/\/digital_album\//, '/album/');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/music\.migu\.cn\/v3\/(live|[a-z]+\/\w+)\/(?:[^/?#]+)$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.streamingfree.artist:
            return {
              result: prefix === 'music/artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.streamingfree.recording:
            return {
              result: ['live', 'music/song', 'video/mv'].includes(prefix),
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.streamingfree.release:
            return {
              result: prefix === 'music/album',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'mixcloud': {
    match: [/^(https?:\/\/)?([^/]+\.)?mixcloud\.com\//i],
    restrict: [LINK_TYPES.socialnetwork],
    clean(url) {
      return url.replace(/^https?:\/\/(?:[^/]+\.)?mixcloud\.com/, 'https://www.mixcloud.com');
    },
  },
  'mobygames': {
    match: [/^(https?:\/\/)?(www\.)?mobygames\.com/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?mobygames\.com\/(company|person)\/([\d]+).*$/, 'https://www.mobygames.com/$1/$2');
    },
    validate(url, id) {
      const m = /^https:\/\/www\.mobygames\.com\/(company|person)\/[\d]+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'person',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.label:
            return {
              result: prefix === 'company',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'mora': {
    match: [/^(https?:\/\/)?([^/]+\.)?mora\.jp/i],
    restrict: [LINK_TYPES.downloadpurchase],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:[^.]+\.)?mora\.jp\/package\/([0-9]+)\/([a-zA-Z0-9_-]+)(\/)?.*$/, 'https://mora.jp/package/$1/$2/');
    },
  },
  'musicapopularcl': {
    match: [/^(https?:\/\/)?(www\.)?musicapopular\.cl/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?musicapopular\.cl((?:\/[^/?#]+){2})\/?(?:#.*)?$/, 'http://www.musicapopular.cl$1/');
    },
    validate(url, id) {
      const m = /^http:\/\/www\.musicapopular\.cl\/(artista|disco|grupo)\/[^/]+\/$/.exec(url);
      if (m) {
        const prefix = m[1] || m[2];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'artista' || prefix === 'grupo',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release_group:
            return {
              result: prefix === 'disco',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'musiksammler': {
    match: [/^(https?:\/\/)?(www\.)?musik-sammler\.de\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?musik-sammler\.de\/artist\/([0-9a-zA-Z-%]+)(?:[/?#].*)?$/, 'https://www.musik-sammler.de/artist/$1/');
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?musik-sammler\.de\/album\/(?:[^/]+-(?=[\d/]))?(\d+)(?:[/?#].*)?$/, 'https://www.musik-sammler.de/album/$1/');
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?musik-sammler\.de\/(?:media|release)\/(?:[^/]+-(?=[\d/]))?(\d+)(?:[/?#].*)?$/, 'https://www.musik-sammler.de/release/$1/');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/www\.musik-sammler\.de\/(\w+)\/[^?#]+\/$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release:
            return {
              result: prefix === 'release',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release_group:
            return {
              result: prefix === 'album',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'musixmatch': {
    match: [/^(https?:\/\/)?([^/]+\.)?musixmatch\.com\//i],
    restrict: [LINK_TYPES.lyrics],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?musixmatch\.com\/(artist)\/([^/?#]+).*$/, 'https://www.musixmatch.com/$1/$2');
      url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?musixmatch\.com\/(album|lyrics)\/([^/?#]+)\/([^/?#]+).*$/, 'https://www.musixmatch.com/$1/$2/$3');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/www.musixmatch\.com\/(album|artist|lyrics)\/[^?#]+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.lyrics.artist:
            return {
              result: prefix === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.lyrics.release_group:
            if (prefix === 'album') {
              return {
                error: exp.l(
                  `Musixmatch “{album_url_pattern}” pages are a bad match
                   for MusicBrainz release groups, and linking to them
                   is currently disallowed. Please consider adding Musixmatch
                   links to the relevant artists and works instead.`,
                  {
                    album_url_pattern: (
                      <span className="url-quote">{'/album'}</span>
                    ),
                  },
                ),
                result: false,
                target: ERROR_TARGETS.ENTITY,
              };
            }
            return {result: false, target: ERROR_TARGETS.ENTITY};
          case LINK_TYPES.lyrics.work:
            return {
              result: prefix === 'lyrics',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'musopen': {
    match: [/^(https?:\/\/)?([^/]+\.)?musopen\.org\//i],
    restrict: [LINK_TYPES.score],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?musopen\.org\/music\/(\d+).*$/, 'https://musopen.org/music/$1/');
    },
    validate(url) {
      return {
        result: /^https:\/\/musopen\.org\/music\/\d+\/$/.test(url),
        target: ERROR_TARGETS.URL,
      };
    },
  },
  'muziekweb': {
    match: [/^(https?:\/\/)?www\.muziekweb\.(com|eu|nl)\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?muziekweb\.(?:com|eu|nl)\/(?:[a-z]{2}\/)?Link\/([A-Z]{1,3}\d+(?:\/(?:CLASSICAL(?:\/COMPOSER)?|POPULAR))?).*$/, 'https://www.muziekweb.nl/Link/$1/');
    },
    validate(url, id) {
      const m = /^https:\/\/www\.muziekweb\.nl\/Link\/(.*)\/$/.exec(url);
      if (m) {
        const subpath = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: /^M\d{11}\/(CLASSICAL(?:\/COMPOSER)?|POPULAR)$/.test(subpath),
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.label:
            return {
              result: /^L\d{11}$/.test(subpath),
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release:
            return {
              result: /^[A-Z]{2,3}\d{4,6}$/.test(subpath),
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.work:
            return {
              result: /^U\d{11}\/(CLASSICAL|POPULAR)$/.test(subpath),
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'myspace': {
    match: [/^(https?:\/\/)?([^/]+\.)?myspace\.(com|de|fr)/i],
    restrict: [LINK_TYPES.myspace],
    clean(url) {
      return url.replace(/^(https?:\/\/)?([^.]+\.)?myspace\.(com|de|fr)/, 'https://myspace.com');
    },
    validate(url) {
      return {result: /^https:\/\/myspace\.com\//.test(url), target: ERROR_TARGETS.URL};
    },
  },
  'napster': {
    match: [/^(https?:\/\/)?((app|www|[a-z]{2})\.)?napster\.com/i],
    restrict: [LINK_TYPES.streamingpaid],
    clean(url) {
      url = url.replace(/^http:\/\//, 'https://');
      // Standardise on US (host country) for multi-country redirect
      url = url.replace(/^https:\/\/((app|www)\.)?napster/, 'https://us.napster');
      url = url.replace(/[#?].*$/, '');
      return url;
    },
    validate(url, id) {
      if (/\/(alb|art|tra)\.[\d]+/i.test(url)) {
        return {
          error: exp.l(
            `This is a redirect link. Please follow {redirect_url|your link}
             and add the link it redirects to instead.`,
            {
              redirect_url: {
                href: url,
                rel: 'noopener noreferrer',
                target: '_blank',
              },
            },
          ),
          result: false,
          target: ERROR_TARGETS.URL,
        };
      }
      switch (id) {
        case LINK_TYPES.streamingpaid.artist:
          return {
            result: /^https:\/\/[a-z]{2}\.napster\.com\/artist\/[\w-]+$/.test(url),
            target: ERROR_TARGETS.ENTITY,
          };
        case LINK_TYPES.streamingpaid.recording:
          return {
            result: /^https:\/\/[a-z]{2}\.napster\.com\/artist\/[\w-]+\/album\/[\w-]+\/track\/[\w-]+$/.test(url),
            target: ERROR_TARGETS.ENTITY,
          };
        case LINK_TYPES.streamingpaid.release:
          return {
            result: /^https:\/\/[a-z]{2}\.napster\.com\/artist\/[\w-]+\/album\/[\w-]+$/.test(url),
            target: ERROR_TARGETS.ENTITY,
          };
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'ndlauth': {
    match: [/^(https?:\/\/)?id\.ndl\.go\.jp\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(id\.ndl\.go\.jp\/auth\/ndlna\/\d+)(?:[.#].*)?$/, 'https://$1');
    },
    validate(url, id) {
      if (/^https:\/\/id\.ndl\.go\.jp\/auth\/ndlna\/\d+$/.test(url)) {
        if (id === LINK_TYPES.otherdatabases.artist) {
          return {result: true};
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'neyzen': {
    match: [/^(https?:\/\/)?(www\.)?neyzen\.com/i],
    restrict: [LINK_TYPES.score],
  },
  'niconicovideo': {
    match: [/^(https?:\/\/)?((?!commons)[^/]+\.)?(nicovideo\.jp\/)/i],
    restrict: [{...LINK_TYPES.streamingfree, ...LINK_TYPES.videochannel}],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?ch\.nicovideo\.jp\/([^/]+).*$/, 'https://ch.nicovideo.jp/$1');
      url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?nicovideo\.jp\/(user\/[0-9]+|watch\/(?:sm|so|nm|ax|ca|cw|nl|z[a-d])[0-9]+).*$/, 'https://www.nicovideo.jp/$1');
      return url;
    },
    validate(url, id) {
      const m = /^(?:https?:\/\/)?(ch|www)\.nicovideo\.jp\/(?:(user)\/[0-9]+|(watch)\/(?:sm|so|nm|ax|ca|cw|nl|z[a-d])[0-9]+|[^/]+)$/.exec(url);
      if (m) {
        const subdomain = m[1];
        const prefix = m[2] || m[3];
        if (Object.values(LINK_TYPES.videochannel).includes(id)) {
          if (prefix === 'watch') {
            return {
              error: linkToChannelMsg(),
              result: false,
              target: ERROR_TARGETS.ENTITY,
            };
          }
          return {
            result: subdomain === 'ch' || prefix === 'user',
            target: ERROR_TARGETS.RELATIONSHIP,
          };
        }

        if (subdomain === 'ch' || prefix === 'user') {
          return {
            error: linkToVideoMsg(),
            result: false,
            target: ERROR_TARGETS.ENTITY,
          };
        }
        return {
          result: prefix === 'watch',
          target: ERROR_TARGETS.RELATIONSHIP,
        };
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'ocremix': {
    match: [/^(https?:\/\/)?(www\.)?ocremix\.org\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?ocremix\.org\//, 'https://ocremix.org/');
      url = url.replace(/^https:\/\/ocremix\.org\/(album|artist|game|org|remix|song)\/([^/?#]+).*$/, 'https://ocremix.org/$1/$2');
      return url;
    },
  },
  'offiziellecharts': {
    match: [/^(https?:\/\/)?([^/]+\.)?offiziellecharts\.de\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?offiziellecharts\.de\/(?:charts\/)?([^/?#]+).*$/, 'https://www.offiziellecharts.de/charts/$1');
    },
    validate(url, id) {
      const m = /^https:\/\/www\.offiziellecharts\.de\/charts\/(album|compilation|titel)-details-[\d]+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.recording:
            return {
              result: prefix === 'titel',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release_group:
            return {
              result: prefix === 'album' || prefix === 'compilation',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'onlinebijbel': {
    match: [/^(https?:\/\/)?([^/]+\.)?online-bijbel\.nl\//i],
    restrict: [LINK_TYPES.lyrics],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?online-bijbel\.nl\/(12gezang|gezang|psalm)\/(\d+).*$/, 'http://www.online-bijbel.nl/$1/$2/');
    },
    validate(url, id) {
      if (/^http:\/\/www.online-bijbel\.nl\/(12gezang|gezang|psalm)\/\d+\/$/.test(url)) {
        if (id === LINK_TYPES.lyrics.work) {
          return {result: true};
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'onlinecommunity': {
    match: [/^(https?:\/\/)?([^/]+\.)?(last\.fm|lastfm\.(com\.br|com\.tr|at|com|de|es|fr|it|jp|pl|pt|ru|se))\/([a-z]{2}\/)?group\//i],
    restrict: [LINK_TYPES.onlinecommunity],
    clean(url) {
      url = url.replace(/^(https?:\/\/)?((www|cn|m)\.)?(last\.fm|lastfm\.(com\.br|com\.tr|at|com|de|es|fr|it|jp|pl|pt|ru|se))\/([a-z]{2}\/)?/, 'https://www.last.fm/');
      return url;
    },
  },
  'openlibrary': {
    match: [/^(https?:\/\/)?(www\.)?openlibrary\.org/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?openlibrary\.org\/(authors|books|works)\/(OL[0-9]+[AMW]).*$/, 'https://openlibrary.org/$1/$2');
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?openlibrary\.org\/publishers\/([^/?#]+).*$/, 'https://openlibrary.org/publishers/$1');
      return url;
    },
    validate(url, id) {
      let m = /^https:\/\/openlibrary\.org\/(authors|books|works)\/OL[0-9]+[AMW]$/.exec(url);
      if (!m) {
        m = /^https:\/\/openlibrary\.org\/(publishers)\/[^/?#]+$/.exec(url);
      }
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'authors',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.label:
            return {
              result: prefix === 'publishers',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release:
            return {
              result: prefix === 'books',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.work:
            return {
              result: prefix === 'works',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'operabase': {
    match: [/^(https?:\/\/)?(www\.)?operabase\.com/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?operabase\.com\//, 'https://operabase.com/');
      url = url.replace(/^https:\/\/operabase\.com\/(venues\/[\w-]+|works)\/(?:[^0-9]+)?([0-9]+).*$/, 'https://operabase.com/$1/$2');
      url = url.replace(/^https:\/\/operabase\.com\/artists\/(?:[^0-9]+)?([0-9]+).*$/, 'https://operabase.com/a$1');
      url = url.replace(/^https:\/\/operabase\.com\/[\w-]+(a|o)([0-9]+).*$/, 'https://operabase.com/$1$2');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/operabase\.com\/(?:(a|o)|(venues)\/[\w-]+\/|(works)\/)[0-9]+$/.exec(url);
      if (m) {
        const prefix = m[1] || m[2] || m[3];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'a' || prefix === 'o',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.place:
            return {
              result: prefix === 'venues',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.work:
            return {
              result: prefix === 'works',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'otherdatabases': {
    match: [
      /^(https?:\/\/)?(www\.)?musicmoz\.org\//i,
      /^(https?:\/\/)?(www\.)?discografia\.dds\.it\//i,
      /^(https?:\/\/)?(www\.)?encyclopedisque\.fr\//i,
      /^(https?:\/\/)?(www\.)?discosdobrasil\.com\.br\//i,
      /^(https?:\/\/)?(www\.)?isrc\.ncl\.edu\.tw\//i,
      /^(https?:\/\/)?(www\.)?rolldabeats\.com\//i,
      /^(https?:\/\/)?(www\.)?psydb\.net\//i,
      /^(https?:\/\/)?(www\.)?spirit-of-metal\.com\//i,
      /^(https?:\/\/)?(www\.)?lortel\.org\//i,
      /^(https?:\/\/)?(www\.)?theatricalia\.com\//i,
      /^(https?:\/\/)?(www\.)?imvdb\.com/i,
      /^(https?:\/\/)?(www\.)?vkdb\.jp/i,
      /^(https?:\/\/)?(www\.)?ci\.nii\.ac\.jp/i,
      /^(https?:\/\/)?(www\.)?iss\.ndl\.go\.jp\//i,
      /^(https?:\/\/)?(www\.)?finnmusic\.net/i,
      /^(https?:\/\/)?(www\.)?fono\.fi/i,
      /^(https?:\/\/)?(www\.)?pomus\.net/i,
      /^(https?:\/\/)?(www\.)?stage48\.net\/wiki\/index.php/i,
      /^(https?:\/\/)?(www22\.)?big\.or\.jp/i,
      /^(https?:\/\/)?(www\.)?japanesemetal\.gooside\.com/i,
      /^(https?:\/\/)?(www\.)?tedcrane\.com/i,
      /^(https?:\/\/)?(www\.)?thedancegypsy\.com/i,
      /^(https?:\/\/)?(www\.)?bibliotekapiosenki\.pl/i,
      /^(https?:\/\/)?(www\.)?finna\.fi/i,
      /^(https?:\/\/)?(www\.)?castalbums\.org/i,
      /^(https?:\/\/)?(www\.)?folkwiki\.se/i,
      /^(https?:\/\/)?(www\.)?mvdbase\.com/i,
      /^(https?:\/\/)?(www\.)?smdb\.kb\.se/i,
      /^(https?:\/\/)?(www\.)?operadis-opera-discography\.org\.uk/i,
      /^(https?:\/\/)?(www\.)?spirit-of-rock\.com/i,
      /^(https?:\/\/)?(www\.)?tunearch\.org/i,
      /^(https?:\/\/)?(www\.)?videogam\.in/i,
    ],
    restrict: [LINK_TYPES.otherdatabases],
  },
  'ototoy': {
    match: [/^(https?:\/\/)?([^/]+\.)?ototoy\.jp/i],
    restrict: [LINK_TYPES.downloadpurchase],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?ototoy\.jp\/(labels|_\/default\/[ap])\/(\d+).*$/, 'https://ototoy.jp/$1/$2');
    },
    validate(url, id) {
      const m = /^https:\/\/ototoy\.jp\/(labels|_\/default\/[ap])\/\d+$/.exec(url);
      if (m) {
        const suffix = m[1];
        switch (id) {
          case LINK_TYPES.downloadpurchase.label:
            return {
              result: suffix === 'labels',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.release:
            return {
              result: /_\/default\/p/.test(suffix),
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.artist:
            return {
              result: /_\/default\/a/.test(suffix),
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'overture': {
    match: [/^(https?:\/\/)?overture\.doremus\.org\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?overture\.doremus\.org\//, 'https://overture.doremus.org/');
    },
    validate(url, id) {
      const m = /^https:\/\/overture\.doremus\.org\/(artist|expression|performance)\/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.event:
            return {
              result: prefix === 'performance',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.work:
            return {
              result: prefix === 'expression',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'ozonru': {
    match: [/^(https?:\/\/)?(www\.)?ozon\.ru\/context\/detail\/id\//i],
    restrict: [LINK_TYPES.mailorder],
  },
  'patreon': {
    match: [/^(https?:\/\/)?(www\.)?patreon\.com\/[^/?#]/i],
    restrict: [LINK_TYPES.patronage],
    clean(url) {
      url = url.replace(/^((?:https?:\/\/)?(?:www\.)?patreon\.com\/user)\/(?:community|posts)(\?u=\d+).*$/, '$1$2');
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?patreon\.com\/(user\?u=\d+|(?!posts\/)\w+).*$/, 'https://www.patreon.com/$1');
      return url;
    },
    validate(url) {
      return {
        result: /^https?:\/\/(?:www\.)?patreon\.com\/(?:user\?u=\d+|(?!posts$)\w+)$/.test(url),
        target: ERROR_TARGETS.URL,
      };
    },
  },
  'paypal': {
    match: [/^(https?:\/\/)?(www\.)?paypal\.me\/[^/?#]/i],
    restrict: [LINK_TYPES.patronage],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?paypal\.me\/([^/?#]+).*$/, 'https://www.paypal.me/$1');
      return url;
    },
  },
  'petitlyrics': {
    match: [/^(https?:\/\/)?([^/]+\.)?petitlyrics\.com\//i],
    restrict: [LINK_TYPES.lyrics],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?petitlyrics\.com\/(lyrics(?:\/artist)?\/\d+|lyrics\/album\/[^?]+).*$/, 'https://petitlyrics.com/$1');
    },
    validate(url, id) {
      const m = /^https:\/\/petitlyrics\.com\/(lyrics(?:\/album|\/artist)?)\/.+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.lyrics.artist:
            return {
              result: prefix === 'lyrics/artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.lyrics.release_group:
            return {
              result: prefix === 'lyrics/album',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.lyrics.work:
            return {
              result: prefix === 'lyrics',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'pinterest': {
    match: [/^(https?:\/\/)?([^/]+\.)?pinterest\.com\//i],
    restrict: [LINK_TYPES.socialnetwork],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?pinterest\.com\/([^?#]*[^/?#])\/*(?:[?#].*)?$/, 'https://www.pinterest.com/$1/');
      return url.replace(/\/(?:boards|pins|likes|followers|following)(?:\/.*)?$/, '/');
    },
  },
  'pixiv': {
    match: [/^(https?:\/\/)?(www\.)?pixiv\.net/i],
    restrict: [LINK_TYPES.artgallery],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?pixiv\.net\/(?:[a-z]+\/)users\/([0-9]+).*$/, 'https://www.pixiv.net/users/$1');
      return url;
    },
    validate(url) {
      if (/^https:\/\/www\.pixiv\.net\/users\/([0-9]+)$/.test(url)) {
        return {result: true};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'progarchives': {
    match: [/^(https?:\/\/)?(www\.)?progarchives\.com/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?progarchives\.com\/([^#]+)(?:#.*)?$/, 'https://www.progarchives.com/$1');
      url = url.replace(/id=0*([1-9])/, 'id=$1');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/www\.progarchives\.com\/(\w+)\.asp\?id=[1-9]\d*$/.exec(url);
      if (m) {
        const type = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: type === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.recording:
            return {
              result: type === 'video',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release_group:
            return {
              result: type === 'album',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'purevolume': {
    match: [/^(https?:\/\/)?([^/]+\.)?purevolume\.com/i],
    restrict: [LINK_TYPES.purevolume],
  },
  'qobuz': {
    match: [/^(https?:\/\/)?(www\.)?qobuz\.com\//i],
    restrict: [
      LINK_TYPES.streamingpaid,
      multiple(LINK_TYPES.downloadpurchase, LINK_TYPES.streamingpaid),
    ],
    select(url, sourceType) {
      switch (sourceType) {
        case 'artist':
          return LINK_TYPES.streamingpaid.artist;
        case 'label':
          return LINK_TYPES.streamingpaid.label;
        case 'release':
          return LINK_TYPES.streamingpaid.release;
      }
      return false;
    },
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?qobuz\.com\//, 'https://www.qobuz.com/');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/www\.qobuz\.com\/(?:[a-z]{2}-[a-z]{2}\/)?(album|interpreter|label)\/[\w\d-]+\/(?:[\w\d-]+\/)?[\w\d]+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.downloadpurchase.artist:
          case LINK_TYPES.streamingpaid.artist:
            return {
              result: prefix === 'interpreter',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.label:
          case LINK_TYPES.streamingpaid.label:
            return {
              result: prefix === 'label',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.release:
          case LINK_TYPES.streamingpaid.release:
            return {
              result: prefix === 'album',
              target: ERROR_TARGETS.ENTITY,
            };
        }
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'quebecinfomusique': {
    match: [/^(https?:\/\/)?(www\.)?(qim|quebecinfomusique)\.com/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(
        /^(?:https?:\/\/)?(?:www\.)?(?:qim|quebecinfomusique)\.com\/([^#]+).*$/i,
        'http://www.qim.com/$1',
      );
      url = url.replace(
        /^(http:\/\/www\.qim\.com\/artistes)\/(?:albums|oeuvres)\b/,
        '$1/biographie',
      );
      return url;
    },
    validate(url, id) {
      const m = /^http:\/\/www\.qim\.com\/(\w+)\/(\w+)\.asp\?(.+)$/.exec(url);
      if (m) {
        const [/* matched string */, type, page, query] = m;
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: type === 'artistes' &&
                page === 'biographie' &&
                /^artistid=\d+$/.test(query),
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release_group:
            return {
              result: type === 'albums' &&
                page === 'description' &&
                /^albumid=\d+$/.test(query),
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.work:
            return {
              result: type === 'oeuvres' &&
                page === 'oeuvre' &&
                /^oeuvreid=\d+&albumid=\d+$/.test(query),
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'rateyourmusic': {
    match: [/^(https?:\/\/)?([^/]+\.)?rateyourmusic\.com\/(?!feature)/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?rateyourmusic\.com\/([^#?]+).*$/, 'https://rateyourmusic.com/$1');
    },
    validate(url, id) {
      const m = /^https:\/\/rateyourmusic\.com\/(\w+)\/(?:(\w+)\/)?/.exec(url);
      if (m) {
        const prefix = m[1];
        const subPath = m[2];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.event:
            return {
              result: prefix === 'concert',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.genre:
            return {
              result: prefix === 'genre',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.label:
            return {
              result: prefix === 'label',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.place:
            return {
              result: prefix === 'venue',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.recording:
            return {
              error: l('Only RYM music videos can be linked to recordings.'),
              result: prefix === 'release' && subPath === 'musicvideo',
              target: ERROR_TARGETS.RELATIONSHIP,
            };
          case LINK_TYPES.otherdatabases.release:
          case LINK_TYPES.otherdatabases.release_group:
            return {
              result: prefix === 'release',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.series:
            return {
              result: prefix === 'classifiers',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.work:
            return {
              result: prefix === 'work',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'rateyourmusicfeature': {
    match: [/^(https?:\/\/)?(www\.)?rateyourmusic\.com\/feature/i],
    restrict: [LINK_TYPES.interview],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?rateyourmusic\.com\//, 'https://rateyourmusic.com/');
    },
  },
  'recochoku': {
    match: [/^(https?:\/\/)?([^/]+\.)?recochoku\.jp/i],
    restrict: [LINK_TYPES.downloadpurchase],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:[^.]+\.)?recochoku\.jp\/(album|artist|song)\/([a-zA-Z0-9]+)(\/)?.*$/, 'https://recochoku.jp/$1/$2/');
    },
  },
  'residentadvisor': {
    match: [
      /^(https?:\/\/)?([^/]+\.)?ra\.co\/(?!exchange)/i,
      /^(https?:\/\/)?(www\.)?residentadvisor\.net\//i,
    ],
    restrict: [{
      ...LINK_TYPES.otherdatabases,
      ...LINK_TYPES.review,
      ...LINK_TYPES.discographyentry,
    }],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?ra\.co\//, 'https://ra.co/');
      url = url.replace(/^https:\/\/ra\.co\/(clubs|dj|events|labels|podcast|reviews|tracks)\/([^/?#]+).*$/, 'https://ra.co/$1/$2');
      return url;
    },
    validate(url, id) {
      if (/^https?:\/\/(?:www\.)?residentadvisor\.net\//.test(url)) {
        return {
          error: exp.l(
            `This is a link to the old Resident Advisor domain. Please
             follow {ra_url|your link}, make sure the link it redirects
             to is still the correct one and, if so, add that link instead.`,
            {
              ra_url: {
                href: url,
                rel: 'noopener noreferrer',
                target: '_blank',
              },
            },
          ),
          result: false,
          target: ERROR_TARGETS.URL,
        };
      }
      const m = /^https:\/\/ra\.co\/([^/]+)/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.discographyentry.release:
            return {
              result: prefix === 'podcast',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'dj',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.event:
            return {
              result: prefix === 'events',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.label:
            return {
              result: prefix === 'labels',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.place:
            return {
              result: prefix === 'clubs',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.recording:
            return {
              result: prefix === 'tracks',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.review.release_group:
            return {
              result: prefix === 'reviews',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  // TODO: Merge with residentadvisor after MBS-9902 is implemented
  'residentadvisorexchange': {
    match: [/^(https?:\/\/)?(www\.)?ra\.co\/exchange/i],
    restrict: [LINK_TYPES.shownotes],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?ra\.co\/exchange\/([^/?#]+).*$/, 'https://ra.co/exchange/$1');
    },
  },
  'reverbnation': {
    match: [/^(https?:\/\/)?([^/]+\.)?reverbnation\.com\//i],
    restrict: [LINK_TYPES.socialnetwork],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:(?:www|m)\.)?reverbnation\.com(?:\/#!)?\//, 'https://www.reverbnation.com/');
      url = url.replace(/#.*$/, '');
      url = url.replace(/([?&])(?:blog|current_active_tab|fb_og_[^=]+|kick|player_client_id|profile_tour|profile_view_source|utm_[^=]+)=(?:[^?&]*)/g, '$1');
      url = url.replace(/([?&])&+/, '$1');
      url = url.replace(/[?&]$/, '');
      return url;
    },
  },
  'rism': {
    match: [/^(https?:\/\/)?(www\.)?rism\.online/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?rism\.online\/(\w+)\/(\d+).*$/, 'https://rism.online/$1/$2');
    },
    validate(url, id) {
      const m = /^https:\/\/rism\.online\/(\w+)\/(\d+)$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'people',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'rockcomar': {
    match: [/^(https?:\/\/)?(www\.)?rock\.com\.ar/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?rock\.com\.ar\/([^#]+)(?:#.*)?$/, 'http://rock.com.ar/$1');
      url = url.replace(/^(http:\/\/rock\.com\.ar\/artistas\/[1-9][0-9]*)\/(?:[a-z]*|fotos\/[1-9][0-9]*)?$/, '$1');
      return url;
    },
    validate(url, id) {
      let m = /^http:\/\/rock\.com\.ar\/artistas\/[1-9][0-9]*(?:\/(discos|letras)\/[1-9][0-9]*)?$/.exec(url);
      if (m) {
        const subsection = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: !subsection,
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release_group:
            return {
              result: subsection === 'discos',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.work:
            return {
              result: subsection === 'letras',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      // Keep validating URLs from before Rock.com.ar 2017 relaunch
      m = /^http:\/\/rock\.com\.ar\/(?:(bios|discos|letras)(?:\/[0-9]+){2}\.shtml|(artistas)\/.+)$/.exec(url);
      if (m) {
        const prefix = m[1] || m[2];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'artistas' || prefix === 'bios',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release_group:
            return {
              result: prefix === 'discos',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.work:
            return {
              result: prefix === 'letras',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'rockensdanmarkskort': {
    match: [/^(https?:\/\/)?(www\.)?rockensdanmarkskort\.dk/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?rockensdanmarkskort\.dk\/steder\/(.*)+$/, 'http://www.rockensdanmarkskort.dk/steder/$1');
      return url;
    },
  },
  'rockinchina': {
    match: [/^(https?:\/\/)?((www|wiki)\.)?rockinchina\.com/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:wiki|www)\.rockinchina\.com\/w\/(.*)+$/, 'http://www.rockinchina.com/w/$1');
      return url;
    },
  },
  'rockipedia': {
    match: [/^(https?:\/\/)?(www\.)?rockipedia\.no/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?rockipedia\.no\/(utgivelser|artister|plateselskap)\/(.+)\/.*$/, 'https://www.rockipedia.no/$1/$2/');
      return url;
    },
  },
  'runeberg': {
    match: [/^(https?:\/\/)?([^/]+\.)?runeberg\.org\//i],
    restrict: [LINK_TYPES.lyrics],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?runeberg\.org\/(.*)$/, 'http://runeberg.org/$1');
    },
    validate(url, id) {
      if (/^http:\/\/runeberg\.org\/[\w-/]+\/\d+\.html$/.test(url)) {
        if (id === LINK_TYPES.lyrics.work) {
          return {result: true};
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'secondhandsongs': {
    match: [/^(https?:\/\/)?([^/]+\.)?secondhandsongs\.com\//i],
    restrict: [LINK_TYPES.secondhandsongs],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?secondhandsongs\.com/, 'https://secondhandsongs.com');
      url = url.replace(/^(https:\/\/secondhandsongs\.com\/\w+\/[\d+]+)[/#?-].*$/, '$1');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/secondhandsongs\.com\/(\w+)\/[\d+]+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.secondhandsongs.artist:
            return {
              result: prefix === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.secondhandsongs.label:
            return {
              result: prefix === 'label',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.secondhandsongs.recording:
            return {
              result: prefix === 'performance',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.secondhandsongs.release:
            return {
              result: prefix === 'release',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.secondhandsongs.work:
            return {
              result: prefix === 'work',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'setlistfm': {
    match: [/^(https?:\/\/)?([^/]+\.)?setlist\.fm/i],
    restrict: [LINK_TYPES.setlistfm],
    clean(url) {
      return url.replace(/^http:\/\//, 'https://');
    },
    validate(url, id) {
      const m = /setlist\.fm\/([a-z]+)\//.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.setlistfm.artist:
            return {
              result: prefix === 'setlists',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.setlistfm.event:
            return {
              result: prefix === 'setlist' || prefix === 'festival',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.setlistfm.place:
            return {
              result: prefix === 'venue',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.setlistfm.series:
            return {
              result: prefix === 'festivals',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'snac': {
    match: [
      /^(https?:\/\/)?([^/]+\.)?snaccooperative\.org\//i,
      /^(https?:\/\/)?([^/]+\.)?n2t\.net\/ark:\/99166\//i,
    ],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(
        /^(?:https?:\/\/)?(?:\/+\.)?(?:n2t\.net|snaccooperative\.org)\/(ark:\/99166\/\w+)(?:[./?#].*)?$/,
        'http://snaccooperative.org/$1',
      );
    },
    validate(url, id) {
      switch (id) {
        case LINK_TYPES.otherdatabases.artist:
        case LINK_TYPES.otherdatabases.label:
        case LINK_TYPES.otherdatabases.place:
          return {
            result: /^http:\/\/snaccooperative\.org\/ark:\/99166\/[a-z0-9]+$/.test(url),
            target: ERROR_TARGETS.URL,
          };
      }
      return {result: false, target: ERROR_TARGETS.ENTITY};
    },
  },
  'songfacts': {
    match: [/^(https?:\/\/)?([^/]+\.)?songfacts\.com\//i],
    restrict: [LINK_TYPES.songfacts],
  },
  'songkick': {
    match: [/^(https?:\/\/)?([^/]+\.)?songkick\.com/i],
    restrict: [LINK_TYPES.songkick],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?songkick\.com\//, 'https://www.songkick.com/');
      url = url.replace(/^(https:\/\/www\.songkick\.com\/[a-z]+\/[0-9]+)(?:-[\w-]*)?(\/id\/[0-9]+)?(?:[-/?#].*)?$/, '$1$2');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/www\.songkick\.com\/([a-z]+)\/[0-9]+(?:\/(id)\/[0-9]+)?$/.exec(url);
      if (m) {
        const prefix = m[1];
        if ((m[2] === 'id') !== (prefix === 'festivals')) {
          return {result: false, target: ERROR_TARGETS.URL};
        }
        switch (id) {
          case LINK_TYPES.songkick.artist:
            return {
              result: prefix === 'artists',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.songkick.event:
            return {
              result: prefix === 'concerts' || prefix === 'festivals',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.songkick.place:
            return {
              result: prefix === 'venues',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'soundcloud': {
    match: [/^(https?:\/\/)?([^/]+\.)?soundcloud\.com/i],
    restrict: [
      LINK_TYPES.soundcloud,
      ...anyCombinationOf(
        'recording',
        [
          LINK_TYPES.downloadfree.recording,
          LINK_TYPES.downloadpurchase.recording,
          LINK_TYPES.streamingfree.recording,
          LINK_TYPES.streamingpaid.recording,
        ],
      ),
      ...anyCombinationOf(
        'release',
        [
          LINK_TYPES.downloadfree.release,
          LINK_TYPES.downloadpurchase.release,
          LINK_TYPES.streamingfree.release,
          LINK_TYPES.streamingpaid.release,
        ],
      ),
    ],
    clean(url) {
      url = url.replace(/^(https?:\/\/)?((www|m)\.)?soundcloud\.com(\/#!)?/, 'https://soundcloud.com');
      url = url.replace(/^(https:\/\/soundcloud\.com\/)(?!(?:search|tags)[/?#])([^?]+).*$/, '$1$2');
      return url;
    },
    validate(url) {
      return {
        result: /^https:\/\/soundcloud\.com\/(?!(search|tags)[/?#])/.test(url),
        target: ERROR_TARGETS.URL,
      };
    },
  },
  'soundtrackcollector': {
    match: [/^(https?:\/\/)?(www\.)?soundtrackcollector\.com/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?soundtrackcollector\.com\/(composer|title)\/([0-9]+).*$/, 'http://soundtrackcollector.com/$1/$2/');
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?soundtrackcollector\.com\/.*\?movieid=([0-9]+).*$/, 'http://soundtrackcollector.com/title/$1/');
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?soundtrackcollector\.com\/.*\?composerid=([0-9]+).*$/, 'http://soundtrackcollector.com/composer/$1/');
      return url;
    },
    validate(url, id) {
      const m = /^http:\/\/soundtrackcollector\.com\/([a-z]+)\/[0-9]+\/$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'composer',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release_group:
            return {
              result: prefix === 'title',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'spotify': {
    match: [/^(https?:\/\/)?(((?!shop)[^/])+\.)?(spotify\.(?:com|link))\/(?!(?:intl-[a-z]+\/)?user)/i],
    restrict: [LINK_TYPES.streamingfree],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?embed\.spotify\.com\/\?uri=spotify:([a-z]+):([a-zA-Z0-9_-]+)$/, 'https://open.spotify.com/$1/$2');
      url = url.replace(/^(?:https?:\/\/)?(?:play|open)\.spotify\.com\/(?:intl-[a-z]+\/)?([a-z]+)\/([a-zA-Z0-9_-]+)(?:[/?#].*)?$/, 'https://open.spotify.com/$1/$2');
      return url;
    },
    validate(url, id) {
      if (/spotify\.link\//i.test(url)) {
        return {
          error: exp.l(
            `This is a redirect link. Please follow {redirect_url|your link}
             and add the link it redirects to instead.`,
            {
              redirect_url: {
                href: url,
                rel: 'noopener noreferrer',
                target: '_blank',
              },
            },
          ),
          result: false,
          target: ERROR_TARGETS.URL,
        };
      }
      const m = /^https:\/\/open\.spotify\.com\/([a-z]+)\/(?:[a-zA-Z0-9_-]+)$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.streamingfree.artist:
            return {
              result: prefix === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.streamingfree.release:
            return {
              result: prefix === 'album' || prefix === 'prerelease',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.streamingfree.recording:
            return {
              result: prefix === 'track' || prefix === 'episode',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'spotifyshop': {
    match: [/^(https?:\/\/)?shop\.spotify\.com\//i],
    restrict: [LINK_TYPES.downloadpurchase, LINK_TYPES.mailorder],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?shop\.spotify\.com\/([^?#]+)(?:[?#].*)?$/, 'https://shop.spotify.com/$1');
      return url;
    },
    validate(url, id) {
      switch (id) {
        case LINK_TYPES.downloadpurchase.recording:
        case LINK_TYPES.downloadpurchase.release:
        case LINK_TYPES.mailorder.recording:
        case LINK_TYPES.mailorder.release:
          return {
            result: /^https:\/\/shop\.spotify\.com\/[^?#]+$/.test(url),
            target: ERROR_TARGETS.URL,
          };
      }
      return {result: false, target: ERROR_TARGETS.ENTITY};
    },
  },
  'spotifyuseraccount': {
    match: [/^(https?:\/\/)?([^/]+\.)?(spotify\.com)\/(?:intl-[a-z]+\/)?user/i],
    restrict: [LINK_TYPES.socialnetwork],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:play|open)\.spotify\.com\/(?:intl-[a-z]+\/)?user\/([^/?#]+)\/?(?:[?#].*)?$/, 'https://open.spotify.com/user/$1');
      return url;
    },
    validate(url) {
      return {
        result: /^https:\/\/open\.spotify\.com\/user\/[^/?#]+$/.test(url),
        target: ERROR_TARGETS.URL,
      };
    },
  },
  'target': {
    match: [/^(https?:\/\/)?((intl|www)\.)?target\.com\/(b|p)/i],
    restrict: [LINK_TYPES.mailorder],
    clean(url) {
      url = url.replace(
        /^(?:https?:\/\/)?(?:intl\.|www\.)?target\.com\//,
        'https://www.target.com/',
      );
      url = url.replace(
        /^(https:\/\/www\.target\.com)\/(b|p)\/(?:.*\/)?([AN]-[^/?#]+).*$/,
        '$1/$2/$3',
      );
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/www\.target\.com\/(b|p)\/[AN]-\w+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.mailorder.label:
            return {
              result: prefix === 'b',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.mailorder.release:
            return {
              result: prefix === 'p',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'thesession': {
    match: [/^(https?:\/\/)?(www\.)?thesession\.org/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?thesession\.org\/(tunes|events|recordings(?:\/artists)?|sessions)(?:\/.*)?\/([0-9]+).*$/, 'https://thesession.org/$1/$2');
    },
    validate(url, id) {
      const m = /^https:\/\/thesession\.org\/([a-z/]+)\/[0-9]+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'recordings/artists',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.event:
            return {
              result: prefix === 'events',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.place:
            return {
              result: prefix === 'sessions',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release_group:
            return {
              result: prefix === 'recordings',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.work:
            return {
              result: prefix === 'tunes',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'threads': {
    match: [/^(https?:\/\/)?([^/]+\.)?threads\.net\//i],
    restrict: [{...LINK_TYPES.streamingfree, ...LINK_TYPES.socialnetwork}],
    clean(url) {
      return url.replace(
        /^(?:https?:\/\/)?(?:www\.)?threads\.net(?:\/#!)?\//,
        'https://www.threads.net/',
      );
    },
    validate(url, id) {
      const isAProfile = /^https:\/\/www\.threads\.net\/@[^/]+$/.test(url);
      const isAThread = /^https:\/\/www\.threads\.net\/t\/[^/]+$/.test(url);
      if (Object.values(LINK_TYPES.streamingfree).includes(id)) {
        return {
          result: isAThread &&
            (id === LINK_TYPES.streamingfree.recording),
          target: ERROR_TARGETS.ENTITY,
        };
      } else if (isAThread) {
        return {
          error: l('Please link to Threads profiles, not threads.'),
          result: false,
          target: ERROR_TARGETS.ENTITY,
        };
      }
      return {result: isAProfile, target: ERROR_TARGETS.URL};
    },
  },
  'ticketmaster': {
    match: [/^(https?:\/\/)?(www\.)?ticketmaster\.(?:[a-z]{2,3}?\.)?[a-z]{2,4}/i],
    restrict: [LINK_TYPES.ticketing],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?ticketmaster\.((?:[a-z]{2,3}?\.)?[a-z]{2,4})\/(?:[\w-]+\/)?(artist|event|venue)\/(?:[\w-]+\/)?(\w+).*$/, 'https://www.ticketmaster.$1/$2/$3');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/www\.ticketmaster\.(?:[a-z]{2,3}?\.)?[a-z]{2,4}\/(artist|event|venue)\/\w+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.ticketing.artist:
            if (prefix === 'artist') {
              return {result: true};
            }
            return {result: false, target: ERROR_TARGETS.ENTITY};
          case LINK_TYPES.ticketing.event:
            if (prefix === 'event') {
              return {result: true};
            }
            return {result: false, target: ERROR_TARGETS.ENTITY};
          case LINK_TYPES.ticketing.place:
            if (prefix === 'venue') {
              return {result: true};
            }
            return {result: false, target: ERROR_TARGETS.ENTITY};
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'tidal': {
    match: [/^(https?:\/\/)?(([^/]+\.)*(desktop|listen|stage|www)\.)?tidal\.com\/.*(album|artist|track|video)\//i],
    restrict: [LINK_TYPES.streamingpaid],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:(?:[^/]+\.)*(?:desktop|listen|stage|www)\.)?tidal\.com\/(?:#!\/)?([\w/]+).*$/, 'https://tidal.com/$1');
      url = url.replace(/^https:\/\/tidal\.com\/(?:[a-z]{2}\/)?(?:browse\/|store\/)?(?:[a-z]+\/\d+\/)?([a-z]+)\/(\d+)(?:\/[\w]*)?$/, 'https://tidal.com/$1/$2');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/tidal\.com\/([a-z]+)\/\d+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.streamingpaid.artist:
            if (prefix === 'artist') {
              return {result: true};
            }
            return {result: false, target: ERROR_TARGETS.ENTITY};
          case LINK_TYPES.streamingpaid.release:
            if (prefix === 'album' || prefix === 'video') {
              return {result: true};
            }
            return {result: false, target: ERROR_TARGETS.ENTITY};
          case LINK_TYPES.streamingpaid.recording:
            if (prefix === 'track' || prefix === 'video') {
              return {result: true};
            }
            return {result: false, target: ERROR_TARGETS.ENTITY};
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'tidalstore': {
    match: [/^(https?:\/\/)?store\.tidal\.com\/(?:[a-z]{2}\/)?(album|artist)\//i],
    restrict: [LINK_TYPES.downloadpurchase],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?store\.tidal\.com\/(?:[a-z]{2}\/)?/, 'https://store.tidal.com/');
    },
    validate(url, id) {
      const m = /^https:\/\/store\.tidal\.com\/([a-z]+)\/\d+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.downloadpurchase.artist:
            if (prefix === 'artist') {
              return {result: true};
            }
            return {result: false, target: ERROR_TARGETS.ENTITY};
          case LINK_TYPES.downloadpurchase.release:
            if (prefix === 'album') {
              return {result: true};
            }
            return {result: false, target: ERROR_TARGETS.ENTITY};
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'tiktok': {
    match: [/^(https?:\/\/)?(www\.)?tiktok\.com/i],
    restrict: [{...LINK_TYPES.streamingfree, ...LINK_TYPES.socialnetwork}],
    clean(url) {
      return url.replace(
        /^(?:https?:\/\/)(?:www\.)?tiktok\.com\/@([\w.]+(?:\/video\/\d+)?)(?:[/?#].*)?$/,
        'https://www.tiktok.com/@$1',
      );
    },
    validate(url, id) {
      const m = /^https:\/\/www\.tiktok\.com\/@[\w.]+(\/video\/\d+)?$/.exec(url);
      if (m) {
        const isAVideo = m[1] != null;
        if (Object.values(LINK_TYPES.streamingfree).includes(id)) {
          return {
            result: isAVideo &&
              (id === LINK_TYPES.streamingfree.recording),
            target: ERROR_TARGETS.ENTITY,
          };
        } else if (isAVideo) {
          return {
            error: l('Please link to TikTok profiles, not videos.'),
            result: false,
            target: ERROR_TARGETS.ENTITY,
          };
        }
        switch (id) {
          case LINK_TYPES.socialnetwork.artist:
          case LINK_TYPES.socialnetwork.label:
          case LINK_TYPES.socialnetwork.place:
          case LINK_TYPES.socialnetwork.series:
            return {result: true};
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'tipeee': {
    match: [/^(https?:\/\/)?(?:[^/]+\.)?tipeee\.com\/[^/?#]/i],
    restrict: [LINK_TYPES.patronage],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?tipeee\.com\/([^/?#]+).*$/, 'https://www.tipeee.com/$1');
      return url;
    },
  },
  'tmdb': {
    match: [/^(https?:\/\/)?(www\.)?themoviedb\.org/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?themoviedb\.org\/person\/([0-9]*)(?:[^0-9].*)?$/, 'https://www.themoviedb.org/person/$1');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/www\.themoviedb\.org\/person\/[0-9]*$/.exec(url);
      if (m) {
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {result: true};
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'tobarandualchais': {
    match: [/^(https?:\/\/)?([^/]+\.)?tobarandualchais\.co\.uk/i],
    restrict: [
      {artist: LINK_TYPES.otherdatabases.artist},
      {
        recording: [
          LINK_TYPES.otherdatabases.recording,
          LINK_TYPES.streamingfree.recording,
        ],
      },
    ],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?tobarandualchais\.co\.uk\/(person|track)\/([^/?#]+).*$/, 'https://www.tobarandualchais.co.uk/$1/$2');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/www\.tobarandualchais\.co\.uk\/(person|track)\/\d+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'person',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.recording:
          case LINK_TYPES.streamingfree.recording:
            return {
              result: prefix === 'track',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'tower': {
    match: [/^(https?:\/\/)?(www\.)?tower\.jp/i],
    restrict: [LINK_TYPES.mailorder],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?tower\.jp\/(artist|item)\/(\d+)(?:\/.*)?$/, 'https://tower.jp/$1/$2');
      url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?tower\.jp\/artist\/discography\/(\d+)(?:\/.*)?$/, 'https://tower.jp/artist/$1');
      url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?tower\.jp\/ec\/collection\/item\/summary\/(\d+)(?:\/.*)?$/, 'https://tower.jp/item/$1');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/tower\.jp\/(artist|item)\/\d+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.mailorder.artist:
            return {
              result: prefix === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.mailorder.release:
            return {
              result: prefix === 'item',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'traxsource': {
    match: [/^(https?:\/\/)?(www\.)?traxsource\.com/i],
    restrict: [LINK_TYPES.downloadpurchase],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)(?:www\.)?traxsource\.com\/([a-z]+)\/([0-9]+).*$/, 'https://www.traxsource.com/$1/$2');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/www\.traxsource\.com\/([a-z]+)\/[0-9]+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.downloadpurchase.artist:
            return {
              result: prefix === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.label:
            return {
              result: prefix === 'label',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.recording:
            return {
              result: prefix === 'track',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.downloadpurchase.release:
            return {
              result: prefix === 'title',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'triplejunearthed': {
    match: [
      /^(https?:\/\/)?(www\.)?abc\.net\.au\/triplejunearthed/i,
      /^(https?:\/\/)?(www\.)?triplejunearthed\.com/i,
    ],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?triplejunearthed\.com\//, 'https://www.abc.net.au/triplejunearthed/');
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?abc\.net\.au\/triplejunearthed\//, 'https://www.abc.net.au/triplejunearthed/');
      return url;
    },
  },
  'trove': {
    match: [/^(https?:\/\/)?(www\.)?(trove\.)?nla\.gov\.au\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?trove\.nla\.gov\.au\/work\/([^/?#]+).*$/, 'https://trove.nla.gov.au/work/$1');
      url = url.replace(/^(?:https?:\/\/)?trove\.nla\.gov\.au\/people\/([^/?#]+).*$/, 'https://nla.gov.au/nla.party-$1');
      url = url.replace(/^(?:https?:\/\/)?nla\.gov\.au\/(nla\.party-|anbd\.bib-an)([^/?#]+).*$/, 'https://nla.gov.au/$1$2');
      return url;
    },
  },
  'tsutaya': {
    match: [/^(https?:\/\/)?shop\.tsutaya\.co\.jp\//i],
    restrict: [LINK_TYPES.mailorder],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?shop\.tsutaya\.co\.jp\/cd\/product\/(\d+).*$/, 'https://shop.tsutaya.co.jp/cd/product/$1/');
      url = url.replace(/^(?:https?:\/\/)?shop\.tsutaya\.co\.jp\/dir_result\.html\?searchType=3&artistCd=(\d+).*$/, 'https://shop.tsutaya.co.jp/dir_result.html?searchType=3&artistCd=$1');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/shop\.tsutaya\.co.jp\/(?:(cd)\/product\/\d+\/|(dir_result)\.html\?searchType=3&artistCd=\d+)$/.exec(url);
      if (m) {
        const suffix = m[1] || m[2];
        switch (id) {
          case LINK_TYPES.mailorder.artist:
            return {
              result: suffix === 'dir_result',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.mailorder.release:
            return {
              result: suffix === 'cd',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'twitch': {
    match: [/^(https?:\/\/)?([^/]+\.)?twitch\.(?:com|tv)\//i],
    restrict: [{...LINK_TYPES.streamingfree, ...LINK_TYPES.videochannel}],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:(?:m|www)\.)?twitch\.(?:com|tv)\/((?:videos\/)?[^/?#]+).*$/, 'https://www.twitch.tv/$1');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/www\.twitch\.tv\/(?:(videos\/)?[^/?#]+)$/.exec(url);
      if (m) {
        const prefix = m[1];
        if (Object.values(LINK_TYPES.videochannel).includes(id)) {
          if (prefix === 'videos/') {
            return {
              error: linkToChannelMsg(),
              result: false,
              target: ERROR_TARGETS.ENTITY,
            };
          }
          return {result: prefix === undefined};
        }
        if (prefix === 'videos/') {
          return {result: true};
        }
        return {
          error: linkToVideoMsg(),
          result: true,
          target: ERROR_TARGETS.ENTITY,
        };
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'twitter': {
    match: [/^(https?:\/\/)?([^/]+\.)?(twitter|x)\.com\//i],
    restrict: [{...LINK_TYPES.streamingfree, ...LINK_TYPES.socialnetwork}],
    clean(url) {
      url = url.replace(
        /^(?:https?:\/\/)?(?:(?:www|mobile)\.)?(?:twitter|x)\.com(?:\/#!)?\//,
        'https://twitter.com/',
      );
      url = url.replace(
        /^(https:\/\/twitter\.com)\/intent\/user\/?\?screen_name=([^/?#]+)/,
        '$1/$2',
      );
      url = url.replace(
        /^(https:\/\/twitter\.com)\/@?([^/?#]+(?:\/status\/\d+)?)(?:[/?#].*)?$/,
        '$1/$2',
      );
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/twitter\.com\/([^/?#]+)(\/status\/\d+)?$/.exec(url);
      if (m) {
        const username = m[1];
        if (['privacy', 'rules', 'tos'].includes(username)) {
          return {
            error: l(
              'This is not a profile, but a Twitter documentation page.',
            ),
            result: false,
          };
        }
        const isATweet = m[2] != null;
        if (Object.values(LINK_TYPES.streamingfree).includes(id)) {
          return {
            result: isATweet &&
              (id === LINK_TYPES.streamingfree.recording),
            target: ERROR_TARGETS.ENTITY,
          };
        } else if (isATweet) {
          return {
            error: l('Please link to Twitter profiles, not tweets.'),
            result: false,
            target: ERROR_TARGETS.ENTITY,
          };
        }
        return {result: true};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'unwelcomeimages': { // Block images from sites that don't allow deeplinking
    match: [
      /^(https?:\/\/)?s\.pixogs\.com\//i,
      /^(https?:\/\/)?(s|img)\.discogss?\.com\//i,
    ],
    restrict: [LINK_TYPES.image],
    validate() {
      return {
        error: l('This site does not allow direct links to their images.'),
        result: false,
        target: ERROR_TARGETS.URL,
      };
    },
  },
  'utaitedbvocadbtouhoudb': {
    match: [/^(https?:\/\/)?(www\.)?((utaite|voca)db\.net|touhoudb\.com)/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?(utaite|voca|touhou)db(\.net|\.com)\/((?:[A-Za-z]+\/){1,2}0*[1-9][0-9]*)(?:[/?#].*)?$/, 'https://$1db$2/$3');
      url = url.replace(/Artist\/(Details|Edit|Versions)/, 'Ar');
      url = url.replace(/Album\/(Details|DownloadTags|Edit|Related|Versions)/, 'Al');
      url = url.replace(/Event\/(Details|Edit|Versions)/, 'E');
      url = url.replace(/Event\/SeriesDetails/, 'Es');
      return url.replace(/Song\/(Details|Edit|Related|Versions)/, 'S');
    },
    validate(url, id) {
      const m = /^https:\/\/(?:(?:utaite|voca)db\.net|touhoudb\.com)\/([A-Za-z]+(?:\/[A-Za-z]+)?)\/[1-9][0-9]*$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
          case LINK_TYPES.otherdatabases.label:
            return {
              result: prefix === 'Ar',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.event:
            return {
              result: prefix === 'E',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.recording:
          case LINK_TYPES.otherdatabases.work:
            return {
              result: prefix === 'S',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release_group:
            return {
              result: prefix === 'Al',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.series:
            return {
              result: prefix === 'Es',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'utanet': {
    match: [/^(https?:\/\/)?([^/]+\.)?uta-net\.com\//i],
    restrict: [LINK_TYPES.lyrics],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?uta-net\.com\/(artist|composer|lyricist|song)\/(\d+).*$/, 'https://www.uta-net.com/$1/$2/');
    },
    validate(url, id) {
      const m = /^https:\/\/www\.uta-net\.com\/(artist|composer|lyricist|song)\/\d+\/$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.lyrics.artist:
            return {
              result: /^(artist|composer|lyricist)$/.test(prefix),
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.lyrics.work:
            return {
              result: prefix === 'song',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'utaten': {
    match: [/^(https?:\/\/)?([^/]+\.)?utaten\.com\//i],
    restrict: [LINK_TYPES.lyrics],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?utaten\.com\/(artist|songWriter|lyric\/.+)\/([^/?#]+).*$/, 'https://utaten.com/$1/$2');
    },
    validate(url, id) {
      const m = /^https:\/\/utaten\.com\/(artist|songWriter|lyric)\/.+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.lyrics.artist:
            return {
              result: prefix === 'artist' || prefix === 'songWriter',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.lyrics.work:
            return {
              result: prefix === 'lyric',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'vgmdb': {
    match: [/^(https?:\/\/)?vgmdb\.(net|com)\//i],
    restrict: [LINK_TYPES.vgmdb],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?vgmdb\.(?:net|com)\/(album|artist|event|org|product)\/([0-9]+).*$/, 'https://vgmdb.net/$1/$2');
    },
    validate(url, id) {
      const m = /^https:\/\/vgmdb\.net\/(album|artist|org|event|product)\/[1-9][0-9]*$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.vgmdb.artist:
            return {
              result: prefix === 'artist' || prefix === 'org',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.vgmdb.event:
            return {
              result: prefix === 'event',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.vgmdb.label:
            return {
              result: prefix === 'org',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.vgmdb.place:
            return {
              result: prefix === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.vgmdb.release:
            return {
              result: prefix === 'album',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.vgmdb.work:
            return {
              result: prefix === 'product',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'viaf': {
    match: [/^(https?:\/\/)?([^/]+\.)?viaf\.org/i],
    restrict: [LINK_TYPES.viaf],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?viaf\.org\/viaf\/([0-9]+).*$/,
                        'http://viaf.org/viaf/$1');
      return url;
    },
    validate(url) {
      return {
        result: /^http:\/\/viaf\.org\/viaf\/[1-9][0-9]*$/.test(url),
        target: ERROR_TARGETS.URL,
      };
    },
  },
  'vimeo': {
    match: [/^(https?:\/\/)?([^/]+\.)?vimeo\.com\/(?!(?:ondemand|store\/ondemand))/i],
    restrict: [{...LINK_TYPES.streamingfree, ...LINK_TYPES.videochannel}],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?vimeo\.com/, 'https://vimeo.com');
      // Remove query string, just the video id should be enough.
      url = url.replace(/\?.*/, '');
      return url;
    },
  },
  'vimeoondemand': {
    match: [/^(https?:\/\/)?([^/]+\.)?vimeo\.com\/(?:ondemand|store\/ondemand)/i],
    restrict: [
      LINK_TYPES.downloadpurchase,
      LINK_TYPES.streamingpaid,
      multiple(LINK_TYPES.downloadpurchase, LINK_TYPES.streamingpaid),
    ],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?vimeo\.com\/ondemand\/([^/?#]+)(?:.*)$/, 'https://vimeo.com/ondemand/$1');
      return url;
    },
    validate(url, id) {
      const isStoreLink = /vimeo\.com\/store\/ondemand/.test(url);
      if (isStoreLink) {
        return {
          error: exp.l(
            `Please link to the “{allowed_url_pattern}” page
             rather than this “{current_url_pattern}” link.`,
            {
              allowed_url_pattern: (
                <span className="url-quote">{'/ondemand'}</span>
              ),
              current_url_pattern: (
                <span className="url-quote">{'/store/ondemand'}</span>
              ),
            },
          ),
          result: false,
          target: ERROR_TARGETS.URL,
        };
      }
      switch (id) {
        case LINK_TYPES.downloadpurchase.recording:
        case LINK_TYPES.downloadpurchase.release:
        case LINK_TYPES.streamingpaid.recording:
        case LINK_TYPES.streamingpaid.release:
          return {
            result: /^https:\/\/vimeo\.com\/ondemand\/([^/?#]+)*$/.test(url),
            target: ERROR_TARGETS.URL,
          };
      }
      return {result: false, target: ERROR_TARGETS.ENTITY};
    },
  },
  'vine': {
    match: [/^(https?:\/\/)?([^/]+\.)?vine\.co\//i],
    restrict: [LINK_TYPES.socialnetwork],
  },
  'vk': {
    match: [/^(https?:\/\/)?([^/]+\.)?vk\.com\/(?!(?:artist|audio|music|video))/i],
    restrict: [LINK_TYPES.socialnetwork],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?vk\.com/, 'https://vk.com');
    },
  },
  'vkgy': {
    match: [/^(https?:\/\/)?(www\.)?vk\.gy/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?vk\.gy\/(.*)$/, 'https://vk.gy/$1');
    },
    validate(url, id) {
      const m = /^https:\/\/vk\.gy\/(\w+)\/((?:[\w-]+\/){0,2}[\w-]+)\/$/.exec(url);
      if (m) {
        const type = m[1];
        const ending = m[2];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: (
                (type === 'artists' && /^[\w-]+$/.test(ending)) ||
                (type === 'musicians' && /^[\d]+\/[\w-]+$/.test(ending))
              ),
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.event:
            return {
              result: type === 'lives' && /^[\d]+\/[\w-]+$/.test(ending),
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.label:
            return {
              result: type === 'labels' && /^[\w-]+$/.test(ending),
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.place:
            return {
              result: type === 'livehouses' && /^[\w-]+$/.test(ending),
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.release:
            return {
              result: type === 'releases' &&
                      /^[\w-]+\/[\d]+\/[\w-]+$/.test(ending),
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'vkmusic': {
    match: [/^(https?:\/\/)?([^/]+\.)?vk\.com\/(?:artist|audio|music|video)/i],
    restrict: [LINK_TYPES.streamingfree],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?vk\.com/, 'https://vk.com');
      // Remove 'ref' and 'from' parameters
      url = url.replace(/([&?])(?:from|ref)=[^?&]*/g, '$1');
      // Ensure the first parameter left uses ? not to break the URL
      url = url.replace(/([&?])&+/, '$1');
      url = url.replace(/[&?]$/, '');
      url = url.replace(/^https:\/\/vk\.com\/(?:artist\/\w+\?z|audio\?act)=audio_playlist-(\d+_\d+).*$/, 'https://vk.com/music/album/-$1');
      url = url.replace(/^https:\/\/vk\.com\/artist\/\w+\?z=video-(\d+_\d+).*$/, 'https://vk.com/video-$1');
      url = url.replace(/^https:\/\/vk\.com\/((?:audio|video|music\/album\/)-\d+_\d+).*$/, 'https://vk.com/$1');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/vk\.com\/(?:(artist)\/\w+|(audio|video)-\d+_\d+|(music\/album)\/-\d+_\d+)$/.exec(url);
      if (m) {
        const prefix = m[1] || m[2] || m[3];
        switch (id) {
          case LINK_TYPES.streamingfree.artist:
            return {
              result: prefix === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.streamingfree.recording:
            return {
              result: prefix === 'audio' || prefix === 'video',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.streamingfree.release:
            return {
              result: prefix === 'music/album',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'vndb': {
    match: [/^(https?:\/\/)?(www\.)?vndb\.org\//i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)(?:www\.)?vndb\.org\/((?:c|p|s)[0-9]+).*$/, 'https://vndb.org/$1');
    },
    validate(url, id) {
      const m = /^https:\/\/vndb\.org\/(c|p|s)[0-9]+$/.exec(url);
      if (m) {
        const prefix = m[1];
        switch (id) {
          case LINK_TYPES.otherdatabases.artist:
            return {
              result: prefix === 'c' || prefix === 's',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.otherdatabases.label:
            return {
              result: prefix === 'p',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'weibo': {
    match: [/^(https?:\/\/)?([^/]+\.)?weibo\.com\//i],
    restrict: [LINK_TYPES.socialnetwork],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?weibo\.com\/(u\/)?([^/?#]+)(?:.*)$/, 'https://www.weibo.com/$1$2');
    },
  },
  'whosampled': {
    match: [/^(https?:\/\/)?(www\.)?whosampled\.com/i],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:www\.)?whosampled\.com\/(.+)$/, 'https://www.whosampled.com/$1');
    },
    validate(url, id) {
      if (/[?#]/.test(url)) {
        return {
          error: l(
            `There is an unencoded “?” or “#” character in this URL.
             Please check whether it is useless and should be removed,
             or whether it is an error and the URL is misencoded.`,
          ),
          result: false,
          target: ERROR_TARGETS.URL,
        };
      }
      const m = /^https:\/\/www\.whosampled\.com(\/[^?#]+)$/.exec(url);
      if (m) {
        const path = m[1];
        const mp = /^\/([^/]+)/.exec(path);
        if (mp) {
          const topLevelSegment = mp[1];
          switch (topLevelSegment) {
            case 'cover':
            case 'remix':
            case 'sample':
              return {
                error: exp.l(
                  `Please do not link directly to WhoSampled
                   “{unwanted_url_pattern}” pages.
                   Link to the appropriate WhoSampled artist, track
                   or album page instead.`,
                  {
                    unwanted_url_pattern: (
                      <span className="url-quote">
                        {'/' + topLevelSegment}
                      </span>
                    ),
                  },
                ),
                result: false,
                target: ERROR_TARGETS.URL,
              };
            case 'album':
              if (id === LINK_TYPES.otherdatabases.release_group) {
                return {result: true};
              }
              return {
                error: exp.l(
                  `Please link WhoSampled “{album_url_pattern}” pages to
                   release groups.`,
                  {
                    album_url_pattern: (
                      <span className="url-quote">{'/album'}</span>
                    ),
                  },
                ),
                result: false,
                target: ERROR_TARGETS.ENTITY,
              };
            default:
              if (/^\/[^/]+(?:\/)?$/.test(path)) {
                if (id === LINK_TYPES.otherdatabases.artist) {
                  return {result: true};
                }
                return {
                  error: l(
                    'Please link WhoSampled artist pages to artists.',
                  ),
                  result: false,
                  target: ERROR_TARGETS.ENTITY,
                };
              }
              if (/^\/[^/]+\/[^/]+(?:\/)?$/.test(path)) {
                if (id === LINK_TYPES.otherdatabases.recording) {
                  return {result: true};
                }
                return {
                  error: l(
                    'Please link WhoSampled track pages to recordings.',
                  ),
                  result: false,
                  target: ERROR_TARGETS.ENTITY,
                };
              }
          }
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'wikidata': {
    match: [/^(https?:\/\/)?([^/]+\.)?wikidata\.org/i],
    restrict: [LINK_TYPES.wikidata],
    clean(url) {
      return url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?wikidata\.org\/(?:wiki(?:\/Special:EntityPage)?|entity)\/(Q([0-9]+)).*$/, 'https://www.wikidata.org/wiki/$1');
    },
    validate(url) {
      return {
        result: /^https:\/\/www\.wikidata\.org\/wiki\/Q[1-9][0-9]*$/.test(url),
        target: ERROR_TARGETS.URL,
      };
    },
  },
  'wikimediacommons': {
    match: [/^(https?:\/\/)?(commons\.(?:m\.)?wikimedia\.org|upload\.wikimedia\.org\/wikipedia\/commons\/)/i],
    restrict: [{...LINK_TYPES.score, ...LINK_TYPES.image}],
    clean(url) {
      url = url.replace(/\/wiki\/[^#]+#(?:mediaviewer|\/media)\/(.*)/, '/wiki/$1');
      url = url.replace(/^https?:\/\/upload\.wikimedia\.org\/wikipedia\/commons\/(?:thumb\/)?[0-9a-z]\/[0-9a-z]{2}\/([^/]+)(\/[^/]+)?$/, 'https://commons.wikimedia.org/wiki/File:$1');
      url = url.replace(/\?uselang=[a-z-]+$/, '');
      url = url.replace(/#.*$/, '');
      url = reencodeMediawikiLocalPart(url);
      return url.replace(/^https?:\/\/commons\.(?:m\.)?wikimedia\.org\/wiki\/(?:File|Image):/, 'https://commons.wikimedia.org/wiki/File:');
    },
    validate(url) {
      return {
        result: /^https:\/\/commons\.wikimedia\.org\/wiki\/File:[^?#]+$/.test(url),
        target: ERROR_TARGETS.URL,
      };
    },
  },
  'wikipedia': {
    match: [/^(https?:\/\/)?(([^/]+\.)?wikipedia|secure\.wikimedia)\./i],
    restrict: [LINK_TYPES.wikipedia],
    clean(url) {
      url = url.replace(/^https:\/\/secure\.wikimedia\.org\/wikipedia\/([a-z-]+)\/wiki\/(.*)/, 'https://$1.wikipedia.org/wiki/$2');
      url = url.replace(/^http:\/\/wikipedia\.org\/(.+)$/, 'https://en.wikipedia.org/$1');
      url = url.replace(/\.wikipedia\.org\/w\/index\.php\?title=([^&]+).*/, '.wikipedia.org/wiki/$1');
      url = url.replace(/\?oldformat=true$/, '');
      url = url.replace(/^(?:https?:\/\/)?([a-z-]+)(?:\.m)?\.wikipedia\.org\/[a-z-]+\/([^?]+)$/, 'https://$1.wikipedia.org/wiki/$2');
      url = reencodeMediawikiLocalPart(url);
      return url;
    },
    validate(url, id) {
      if (/^(https?:\/\/)?([^./]+\.)?wikipedia\.org\/.*#/.test(url)) {
        return {
          error: exp.l(
            `Links to specific sections of Wikipedia articles are not
             allowed. Please remove “{fragment}” if still appropriate.
             See the {url|guidelines}.`,
            {
              fragment: (
                <span className="url-quote">
                  {url.replace(
                    /^(?:https?:\/\/)?(?:[^./]+\.)?wikipedia\.org\/[^#]*#(.*)$/,
                    '#$1',
                  )}
                </span>
              ),
              url: {
                href: '/relationship/' + id,
                target: '_blank',
              },
            },
          ),
          result: false,
          target: ERROR_TARGETS.URL,
        };
      }
      if (/^(https?:\/\/)?([^./]+\.)?wikipedia\.org\/wiki\/User:.*/.test(url)) {
        return {
          error: l(
            `Links to Wikipedia user pages are not allowed. Please link only
             to actual Wikipedia articles.`,
          ),
          result: false,
          target: ERROR_TARGETS.URL,
        };
      }
      return {
        result: /^https:\/\/[a-z]+\.wikipedia\.org\/wiki\//.test(url),
        target: ERROR_TARGETS.URL,
      };
    },
  },
  'wikisource': {
    match: [/^(https?:\/\/)?([^/]+\.)?wikisource\.org/i],
    restrict: [LINK_TYPES.lyrics],
    clean(url) {
      url = url.replace(/^http:\/\/([a-z-]+\.)?wikisource\.org/, 'https://$1wikisource.org');
      url = reencodeMediawikiLocalPart(url);
      return url;
    },
    validate(url) {
      return {
        result: /^https:\/\/(?:[a-z-]+\.)?wikisource\.org\/wiki\//.test(url),
        target: ERROR_TARGETS.URL,
      };
    },
  },
  'worldcat': {
    match: [
      /^(https?:\/\/)?(?:entities|id)\.oclc\.org\/worldcat\//i,
      /^(https?:\/\/)?(www\.)?worldcat\.org\//i,
    ],
    restrict: [LINK_TYPES.otherdatabases],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:entities|id)\.oclc\.org\/(worldcat\/entity\/[^./?&#]+).*$/, 'https://id.oclc.org/$1');
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?worldcat\.org/, 'https://www.worldcat.org');
      url = url.replace(/^https:\/\/www\.worldcat\.org(?:\/title\/[a-zA-Z0-9_-]+)?\/oclc\/([^&?]+)(?:.*)$/, 'https://www.worldcat.org/oclc/$1');
      // oclc permalinks have no ending slash but identities ones do
      url = url.replace(/^https:\/\/www\.worldcat\.org\/(?:wc)?identities\/([^&?/]+)(?:.*)$/, 'https://www.worldcat.org/identities/$1/');
      return url;
    },
  },
  'yandex': {
    match: [/^(https?:\/\/)?music\.yandex\.(?:com|by|kz|ru|uz)\/(?!video)/i],
    restrict: [LINK_TYPES.streamingfree],
    clean(url) {
      url = url.replace(/^https?:\/\/music\.yandex\.(?:com|by|kz|ru|uz)\//, 'https://music.yandex.com/');
      url = url.replace(/^https:\/\/music\.yandex\.com\/(?:#!\/)?(album|artist|label)\/(\d+)(\/track\/\d+)?$/, 'https://music.yandex.com/$1/$2$3');
      url = url.replace(/^https:\/\/music\.yandex\.com\/iframe\/#album?\/(\d+)$/, 'https://music.yandex.com/album/$1');
      url = url.replace(/^https:\/\/music\.yandex\.com\/iframe\/#track?\/(\d+):(\d+)$/, 'https://music.yandex.com/album/$2/track/$1');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/music\.yandex\.com\/(album|artist|label)\/\d+(\/track\/\d+)?$/.exec(url);
      if (m) {
        const prefix = m[1];
        const isTrack = Boolean(m[2]);
        switch (id) {
          case LINK_TYPES.streamingfree.artist:
            return {
              result: prefix === 'artist',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.streamingfree.label:
            return {
              result: prefix === 'label',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.streamingfree.release:
            return {
              result: prefix === 'album' && !isTrack,
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.streamingfree.recording:
            return {
              result: prefix === 'album' && isTrack,
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'yesasia': {
    match: [/^(https?:\/\/)?(www\.)?yesasia\.com\//i],
    restrict: [LINK_TYPES.mailorder],
    clean(url) {
      url = url.replace(/^(?:https?:\/\/)?(?:www\.)?yesasia\.com\//, 'https://www.yesasia.com/');
      url = url.replace(/^(https:\/\/www\.yesasia\.com)\/(?:global\/)?(?:[^/]*\/)?([\w.-]+)(?:en|ja|zh_CN|zh_TW)\/((?:info|list).html)(?:#.*)?$/, '$1/$2en/$3');
      return url;
    },
    validate(url, id) {
      const m = /^https:\/\/www\.yesasia\.com\/(?:[\w.-]+)en\/(info|list).html$/.exec(url);
      if (m) {
        const suffix = m[1];
        switch (id) {
          case LINK_TYPES.mailorder.artist:
            return {
              result: suffix === 'list',
              target: ERROR_TARGETS.ENTITY,
            };
          case LINK_TYPES.mailorder.release:
            return {
              result: suffix === 'info',
              target: ERROR_TARGETS.ENTITY,
            };
        }
        return {result: false, target: ERROR_TARGETS.ENTITY};
      }
      return {result: false, target: ERROR_TARGETS.URL};
    },
  },
  'youtube': {
    match: [/^(https?:\/\/)?(((?!music)[^/])+\.)?(youtube\.com\/|youtu\.be\/)/i],
    restrict: [{...LINK_TYPES.streamingfree, ...LINK_TYPES.youtube}],
    clean(url) {
      url = url.replace(/^(https?:\/\/)?([^/]+\.)?youtube\.com(?:\/#)?/, 'https://www.youtube.com');
      // YouTube /c/ user channels (/c/ is unneeded)
      url = url.replace(/^https:\/\/www\.youtube\.com\/c\//, 'https://www.youtube.com/');
      // Drop channel subsections (/user or /channel version)
      url = url.replace(/\/(channel|user)\/([^/?#]+).*$/, '/$1/$2');
      // Drop channel subsections (channel name only version)
      url = url.replace(
        /^https:\/\/www\.youtube\.com\/([a-zA-Z0-9_-]+)\/(?:about|channels|community|featured|playlists|videos)(?:[/?&#].*)?$/,
        'https://www.youtube.com/$1',
      );
      // YouTube handle
      url = url.replace(/^https:\/\/www\.youtube\.com\/(@[a-zA-Z0-9_.-]{3,30}).*$/, 'https://www.youtube.com/$1');
      // YouTube URL shortener
      url = url.replace(/^(?:https?:\/\/)?(?:[^/]+\.)?youtu\.be\/([a-zA-Z0-9_-]+).*$/, 'https://www.youtube.com/watch?v=$1');
      // YouTube standard watch URL
      url = url.replace(/^https:\/\/www\.youtube\.com\/.*[?&](v=[a-zA-Z0-9_-]+).*$/, 'https://www.youtube.com/watch?$1');
      // YouTube embeds
      url = url.replace(/^https:\/\/www\.youtube\.com\/(?:embed|v)\/([a-zA-Z0-9_-]+).*$/, 'https://www.youtube.com/watch?v=$1');
      // YouTube playlists
      url = url.replace(/^https:\/\/www\.youtube\.com\/playlist.*[?&](list=[a-zA-Z0-9_-]+).*$/, 'https://www.youtube.com/playlist?$1');
      return url;
    },
    validate(url, id) {
      if (/https:\/\/www\.youtube\.com\/results\?/.test(url)) {
        return {
          error: noLinkToSearchMsg(),
          result: false,
          target: ERROR_TARGETS.URL,
        };
      }
      switch (id) {
        case LINK_TYPES.youtube.artist:
        case LINK_TYPES.youtube.event:
        case LINK_TYPES.youtube.label:
        case LINK_TYPES.youtube.place:
          if (/^https:\/\/www\.youtube\.com\/playlist\?list=[a-zA-Z0-9_-]+/.test(url)) {
            return {
              error: l(
                `This is a playlist link, which isn’t a video channel and is
                 not guaranteed to be officially approved. Please link to the
                 official channel for this entity, if it exists, instead.`,
              ),
              result: false,
              target: ERROR_TARGETS.URL,
            };
          }
          if (/^https:\/\/www\.youtube\.com\/watch\?v=[a-zA-Z0-9_-]+$/.test(url)) {
            return {
              error: linkToChannelMsg(),
              result: false,
              target: ERROR_TARGETS.ENTITY,
            };
          }
          return {result: true};
        case LINK_TYPES.youtube.series:
          if (/^https:\/\/www\.youtube\.com\/(?!watch\?v=[a-zA-Z0-9_-])/.test(url)) {
            return {result: true};
          }
          return {
            error: linkToChannelMsg(),
            result: false,
            target: ERROR_TARGETS.ENTITY,
          };
        case LINK_TYPES.streamingfree.recording:
          if (/^https:\/\/www\.youtube\.com\/watch\?v=[a-zA-Z0-9_-]+$/.test(url)) {
            return {result: true};
          }
          return {
            error: linkToVideoMsg(),
            result: false,
            target: ERROR_TARGETS.ENTITY,
          };
        case LINK_TYPES.streamingfree.release:
          if (/^https:\/\/www\.youtube\.com\/(watch\?v=[a-zA-Z0-9_-]+|playlist\?list=[a-zA-Z0-9_-]+)$/.test(url)) {
            return {result: true};
          }
          return {
            error: l(
              'Only video and playlist links are allowed on releases.',
            ),
            result: false,
            target: ERROR_TARGETS.ENTITY,
          };
      }
      return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
    },
  },
  'youtubemusic': {
    match: [/^(https?:\/\/)?music\.youtube\.com\//i],
    restrict: [
      LINK_TYPES.youtubemusic,
      {
        recording: LINK_TYPES.streamingfree.recording,
        release: LINK_TYPES.streamingfree.release,
      },
      {
        recording: LINK_TYPES.streamingpaid.recording,
        release: LINK_TYPES.streamingpaid.release,
      },
    ],
    clean(url) {
      url = url.replace(/^(https?:\/\/)?music\.youtube\.com(?:\/#)?/, 'https://music.youtube.com');
      // Channel (artist) URL
      url = url.replace(/\/channel\/([^/?#]+).*$/, '/channel/$1');
      // Video (track) URL
      url = url.replace(/^https:\/\/music\.youtube\.com\/.*[?&](v=[a-zA-Z0-9_-]+).*$/, 'https://music.youtube.com/watch?$1');
      // Playlist (release) URL
      url = url.replace(/^https:\/\/music\.youtube\.com\/playlist.*[?&](list=[a-zA-Z0-9_-]+).*$/, 'https://music.youtube.com/playlist?$1');
      return url;
    },
    validate(url, id) {
      if (/https:\/\/music\.youtube\.com\/search\?/.test(url)) {
        return {
          error: noLinkToSearchMsg(),
          result: false,
          target: ERROR_TARGETS.URL,
        };
      }
      switch (id) {
        case LINK_TYPES.youtubemusic.artist:
          if (/^https:\/\/www\.youtube\.com\/playlist\?list=[a-zA-Z0-9_-]+/.test(url)) {
            return {
              error: l(
                `This is a release (playlist) link, not an artist channel.
                 Please link to the artist channel instead.`,
              ),
              result: false,
              target: ERROR_TARGETS.ENTITY,
            };
          }
          if (/^https:\/\/www\.youtube\.com\/watch\?v=[a-zA-Z0-9_-]+$/.test(url)) {
            return {
              error: linkToChannelMsg(),
              result: false,
              target: ERROR_TARGETS.ENTITY,
            };
          }
          return {
            result: /^https:\/\/music\.youtube\.com\/channel\/[^/?#]+$/.test(url),
            target: ERROR_TARGETS.URL,
          };
        case LINK_TYPES.streamingfree.recording:
        case LINK_TYPES.streamingpaid.recording:
          if (/^https:\/\/music\.youtube\.com\/watch\?v=[a-zA-Z0-9_-]+$/.test(url)) {
            return {result: true};
          }
          return {
            error: linkToVideoMsg(),
            result: false,
            target: ERROR_TARGETS.ENTITY,
          };
        case LINK_TYPES.streamingfree.release:
        case LINK_TYPES.streamingpaid.release:
          if (/^https:\/\/music\.youtube\.com\/playlist\?list=[a-zA-Z0-9_-]+$/.test(url)) {
            return {result: true};
          }
          if (/^https:\/\/music\.youtube\.com\/watch\?v=[a-zA-Z0-9_-]+$/.test(url)) {
            return {
              error: l(
                `Please link to a specific release (playlist) link. Add track
                (video) links to the relevant recordings instead.`,
              ),
              result: false,
              target: ERROR_TARGETS.ENTITY,
            };
          }
          if (/^https:\/\/music\.youtube\.com\/channel\/[^/?#]+$/.test(url)) {
            return {
              error: l(
                `Please link to a specific release (playlist) link. Add
                 channel links to the relevant artists instead.`,
              ),
              result: false,
              target: ERROR_TARGETS.ENTITY,
            };
          }
          if (/^https:\/\/music\.youtube\.com\/browse\//.test(url)) {
            return {
              error: exp.l(
                `This is likely a redirect link. Please follow
                 {redirect_url|your link} and add the release (playlist)
                 link it redirects to instead.`,
                {
                  redirect_url: {
                    href: url,
                    rel: 'noopener noreferrer',
                    target: '_blank',
                  },
                },
              ),
              result: false,
              target: ERROR_TARGETS.URL,
            };
          }
      }
      return {result: false, target: ERROR_TARGETS.RELATIONSHIP};
    },
  },
};
/* eslint-enable sort-keys */

function testAll(tests: $ReadOnlyArray<RegExp>, text: string) {
  for (let i = 0; i < tests.length; i++) {
    if (tests[i].test(text)) {
      return true;
    }
  }

  return false;
}

const CLEANUP_ENTRIES: Array<CleanupEntry> = Object.values(CLEANUPS);

const entitySpecificRules: {
  [entityType: RelatableEntityTypeT]: (string) => ValidationResult,
} = {};

// Avoid Wikipedia/Wikidata being added as release-level relationship
entitySpecificRules.release = function (url) {
  if (/^(https?:\/\/)?([^./]+\.)?wikipedia\.org\//.test(url)) {
    return {
      error: l(
        `Wikipedia normally has no entries for specific releases,
         so adding Wikipedia links to a release is currently blocked.
         Please add this Wikipedia link to the release group instead,
         if appropriate.`,
      ),
      result: false,
      target: ERROR_TARGETS.ENTITY,
    };
  }
  if (/^(https?:\/\/)?([^./]+\.)?wikidata\.org\//.test(url)) {
    return {
      error: l(
        `Wikidata normally has no entries for specific releases,
         so adding Wikidata links to a release is currently blocked.
         Please add this Wikidata link to the release group instead,
         if appropriate.`,
      ),
      result: false,
      target: ERROR_TARGETS.ENTITY,
    };
  }
  if (/^(https?:\/\/)?([^./]+\.)?genius\.com\//.test(url)) {
    return {
      error: linkAsLyricsMsg(),
      result: false,
      target: ERROR_TARGETS.ENTITY,
    };
  }
  return {result: true};
};

// Disallow non-daily Bandcamp URLs at release group level
entitySpecificRules.release_group = function (url) {
  if (/^(https?:\/\/)?(((?!daily\.)[^/])+\.)?bandcamp\.com/.test(url)) {
    return {
      result: false,
      target: ERROR_TARGETS.ENTITY,
    };
  }
  if (/^(https?:\/\/)?vgmdb\.(?:net|com)/.test(url)) {
    return {
      result: false,
      target: ERROR_TARGETS.ENTITY,
    };
  }
  return {result: true};
};

/**
 * Allows for every combination of the given types for the given entity type.
 * Useful for cases where we want to restrict the options to just a specific
 * subset of relationships (e.g. "get the music" ones), but without making
 * extra assumptions about how that subset can be used.
 *
 * e.g: anyCombinationOf('release', [1, 2, 3]) allows for:
 * 1, 2, 3, [1, 2], [1, 3], [2, 3], [1, 2, 3]
 */
function anyCombinationOf(
  entityType: string,
  types: $ReadOnlyArray<string>,
): $ReadOnlyArray<EntityTypesMap> {
  const result = [];
  const numCombinations = (1 << types.length) - 1;
  for (let i = 1; i <= numCombinations; i++) {
    const combination = types.filter((e2, j) => i & (1 << j));
    if (combination.length === 0) {
      // The empty subset is technically valid, but not of interest to us
      continue;
    }
    if (combination.length === 1) {
      // One-type subsets are expected as a string, not a 1-element array
      result.push({[entityType]: combination[0]});
    } else {
      result.push({[entityType]: combination});
    }
  }

  return result;
}

/**
 * Merge multiple link types into one object.
 *
 * e.g: multiple(LINK_TYPES.downloadfree, LINK_TYPES.streamingfree)
 * returns: {
 *   release: [
 *     LINK_TYPES.downloadfree.release,
 *     LINK_TYPES.streamingfree.release
 *   ],
 *   ...
 * }
 */
function multiple(...types: $ReadOnlyArray<EntityTypeMap>): EntityTypesMap {
  const result: {[entityType: RelatableEntityTypeT]: Array<string>} = {};
  types.forEach(function (type: EntityTypeMap) {
    for (const [entityType, id] of Object.entries(type)) {
      (result[entityType] ||= []).push(id);
    }
  });
  return result;
}

export class Checker {
  url: string;

  entityType: RelatableEntityTypeT;

  cleanup: ?CleanupEntry;

  constructor(url: string, entityType: RelatableEntityTypeT) {
    this.url = url;
    this.entityType = entityType;
    this.cleanup = CLEANUP_ENTRIES.find(function (cleanup) {
      return testAll(cleanup.match, url);
    });
  }

  /*
   * Relationship type auto-selection.
   *
   * Guess a relationship type or a type combination,
   * return false if it can't be determined.
   */
  guessType(): RelationshipTypeT | false {
    const cleanup = this.cleanup;
    const sourceType = this.entityType;
    const types = this.filterApplicableTypes();
    // If not applicable to current entity
    if (types.length === 0) {
      return false;
    }
    // If there is a `select` function, use its return value directly
    if (cleanup && cleanup.select) {
      const result = cleanup.select(this.url, sourceType);
      if (result) {
        return result;
      }
    }
    // If there's only one possible type, then select it
    if (types.length === 1) {
      return types[0];
    }
    return false;
  }

  /*
   * Relationship type restriction.
   *
   * Returns possible relationship types of given URL with given entity.
   */
  getPossibleTypes(): Array<RelationshipTypeT> | false {
    const types = this.filterApplicableTypes();
    // If not applicable to current entity
    if (types.length === 0) {
      return false;
    }
    return types;
  }

  /*
   * Check a single relationship.
   *
   * @param id: Link type uuid
   * @param entityType: Source entity type.
   *        If not specified, the one specified in constructor is used.
   */
  checkRelationship(
    id: string,
    entityType: RelatableEntityTypeT = this.entityType,
  ): ValidationResult {
    // Perform entity-specific validation
    const rules = entitySpecificRules[this.entityType];
    if (rules) {
      const check = rules(this.url);
      if (!check.result) {
        return check;
      }
    }

    const cleanup = this.cleanup;
    const types = this.filterApplicableTypes(entityType);
    // Check if given relationship type is applicable to entity
    if (cleanup && types.length > 0) {
      const validation = cleanup.validate
        ? cleanup.validate(this.url, id)
        : {result: true};
      /*
       * Check if given type is specified in `types`,
       * either as a single type or in a combination.
       */
      const isRelationshipValid = types.some(
        ids => typeof ids === 'string' ? ids === id : ids.includes(id),
      );
      validation.result &&= isRelationshipValid;
      return validation;
    }
    return {
      result: RESTRICTED_LINK_TYPES.indexOf(id) === -1,
      target: ERROR_TARGETS.RELATIONSHIP,
    };
  }

  /*
   * Validate relationship type combination.
   * Should only be triggered after every single type
   * has passed validation.
   */
  checkRelationships(
    selectedTypes: $ReadOnlyArray<string>,
    allowedTypes: $ReadOnlyArray<RelationshipTypeT> | false,
  ): ValidationResult {
    if (!allowedTypes) {
      return {result: true};
    }
    // Only a single type is selected
    if (selectedTypes.length === 1) {
      const type = selectedTypes[0];
      const result = allowedTypes.some(
        allowedType => allowedType === type,
      );
      if (!result) {
        return {
          error: l('Some relationship types are missing for this URL.'),
          result: false,
          target: ERROR_TARGETS.URL,
        };
      }
      return {result: true};
    }
    // Multiple types are selected
    const result = allowedTypes.some(
      (allowedType) => typeof allowedType === 'object' &&
        arraysEqual(
          [...selectedTypes].sort(),
          [...allowedType].sort(),
        ),
    );
    if (!result) {
      return {
        error: l('This relationship type combination is invalid.'),
        result: false,
        target: ERROR_TARGETS.URL,
      };
    }
    return {result: true};
  }

  filterApplicableTypes(
    sourceType: RelatableEntityTypeT = this.entityType,
  ): Array<RelationshipTypeT> {
    if (!this.cleanup || !this.cleanup.restrict) {
      return [];
    }
    return this.cleanup.restrict.reduce((result, type: EntityTypesMap) => {
      if (type[sourceType]) {
        result.push(type[sourceType]);
      }
      return result.sort();
    }, []);
  }
}

export function cleanURL(dirtyURL: string): string {
  dirtyURL = dirtyURL.trim().replace(/(%E2%80%8E|\u200E)$/, '');

  const cleanup = CLEANUP_ENTRIES.find(function (cleanup) {
    return cleanup.clean && testAll(cleanup.match, dirtyURL);
  });

  return (cleanup && cleanup.clean) ? cleanup.clean(dirtyURL) : dirtyURL;
}

export function registerEvents($url: typeof $) {
  function urlChanged() {
    const url = $url.val();
    const clean = cleanURL(url) || url;

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
    .on('blur', function (this: HTMLInputElement) {
      this.value = this.value.trim();
    })
    .parents('form')
    .on('submit', urlChanged);
}
