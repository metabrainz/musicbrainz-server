/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ENTITIES from '../../../../entities.mjs';

export {ENTITIES};

export const EMPTY_PARTIAL_DATE: PartialDateT = Object.freeze({
  day: null,
  month: null,
  year: null,
});

export const ENTITY_NAMES: {
  area: N_l_T,
  artist: N_l_T,
  event: N_l_T,
  genre: N_l_T,
  instrument: N_l_T,
  label: N_l_T,
  place: N_l_T,
  recording: N_l_T,
  release: N_l_T,
  release_group: N_l_T,
  series: N_l_T,
  url: N_l_T,
  work: N_l_T,
} = {
  area: N_l('Area'),
  artist: N_l('Artist'),
  event: N_l('Event'),
  genre: N_l('Genre'),
  instrument: N_l('Instrument'),
  label: N_l('Label'),
  place: N_l('Place'),
  recording: N_l('Recording'),
  release: N_l('Release'),
  release_group: N_l('Release group'),
  series: N_lp('Series', 'singular'),
  url: N_l('URL'),
  work: N_l('Work'),
};

export const INSTRUMENT_ROOT_ID = 14;

export const VOCAL_ROOT_ID = 3;

export const TASK_ATTRIBUTE_ID = 1150;

export const AREA_TYPE_COUNTRY = 1;

export const ARTIST_TYPE_PERSON = 1;
export const ARTIST_TYPE_GROUP = 2;
export const ARTIST_TYPE_ORCHESTRA = 5;
export const ARTIST_TYPE_CHOIR = 6;

export const ARTIST_GROUP_TYPES: Set<number> = new Set([
  ARTIST_TYPE_CHOIR,
  ARTIST_TYPE_GROUP,
  ARTIST_TYPE_ORCHESTRA,
]);

export const CONTACT_URL = 'https://metabrainz.org/contact';

export const DARTIST_ID = 2;

export const DLABEL_ID = 1;

export const FAVICON_CLASSES: {
  +[host: string]: string,
} = {
  '7digital.com': 'sevendigital',
  '45cat.com': 'fortyfivecat',
  'abc.net.au/triplejunearthed': 'triplejunearthed',
  'acum.org.il': 'acum',
  'adp.library.ucsb.edu': 'dahr',
  'allmusic.com': 'allmusic',
  'anghami.com': 'anghami',
  'anidb.net': 'anidb',
  'anilist.co': 'anilist',
  'animenewsnetwork.com': 'animenewsnetwork',
  'anison.info': 'anisongeneration',
  'archive.org': 'archive',
  'audiomack.com': 'audiomack',
  'awa.fm': 'awa',
  'baidu.com': 'baidu',
  'bandcamp.com': 'bandcamp',
  'bandsintown.com': 'bandsintown',
  'bbc.co.uk': 'bbc',
  'beatport.com': 'beatport',
  'bibliotekapiosenki.pl': 'piosenki',
  'bigcartel.com': 'bigcartel',
  'bookbrainz.org': 'bookbrainz',
  'books.apple.com': 'applebooks',
  'boomkat.com': 'boomkat',
  'boomplay.com': 'boomplay',
  'bsky.app': 'bluesky',
  'cancioneros.si': 'cancioneros',
  'castalbums.org': 'castalbums',
  'catalogue.bnf.fr': 'bnfcatalogue',
  'cbfiddle.com/rx/': 'cbfiddlerx',
  'ccmixter.org': 'ccmixter',
  'cdjapan.co.jp': 'cdjapan',
  'changetip.com': 'changetip',
  'ci.nii.ac.jp': 'cinii',
  'classicalarchives.com': 'classicalarchives',
  'concerts.livenation.com': 'livenation',
  'cpdl.org': 'cpdl',
  'd-nb.info': 'dnb',
  'dailymotion.com': 'dailymotion',
  'deezer.com': 'deezer',
  'deviantart.com': 'deviantart',
  'dhhu.dk': 'dhhu',
  'directlyrics.com': 'directlyrics',
  'discogs.com': 'discogs',
  'dogmazic.net': 'dogmazic',
  'dramonline.org': 'dram',
  'e-onkyo.com': 'eonkyo',
  'encyclopedisque.fr': 'encyclopedisque',
  'ester.ee': 'ester',
  'facebook.com': 'facebook',
  'finna.fi': 'finna',
  'finnmusic.net': 'finnmusic',
  'flattr.com': 'flattr',
  'fono.fi': 'fonofi',
  'generasia.com/wiki': 'generasia',
  'genie.co.kr': 'genie',
  'genius.com': 'genius',
  'geonames.org': 'geonames',
  'goodreads.com': 'goodreads',
  'gutenberg.org': 'gutenberg',
  'hoerspielforscher.de': 'hoerspielforscher',
  'hoick.jp': 'hoick',
  'ibdb.com': 'ibdb',
  'idref.fr': 'idref',
  'imdb.com': 'imdb',
  'imslp.org': 'imslp',
  'imvdb.com': 'imvdb',
  'indiegogo.com': 'indiegogo',
  'instagram.com': 'instagram',
  'ircam.fr': 'ircam',
  'irishtune.info': 'irishtune',
  'iss.ndl.go.jp': 'ndl',
  'itunes.apple.com': 'itunes',
  'j-lyric.net': 'jlyric',
  'jazzmusicarchives.com': 'jazzmusicarchives',
  'joysound.com': 'joysound',
  'junodownload.com': 'junodownload',
  'kashinavi.com': 'kashinavi',
  'kickstarter.com': 'kickstarter',
  'ko-fi.com': 'kofi',
  'laboiteauxparoles.com': 'laboiteauxparoles',
  'lantis.jp': 'lantis',
  'last.fm': 'lastfm',
  'lesarchivesduspectacle.net': 'archivesduspectacle',
  'librarything.com': 'librarything',
  'librivox.org': 'librivox',
  'lieder.net': 'lieder',
  'linkedin.com': 'linkedin',
  'livefans.jp': 'livefans',
  'loc.gov': 'loc',
  'loudr.fm': 'loudr',
  'mainlynorfolk.info': 'mainlynorfolk',
  'melon.com': 'melon',
  'metacritic.com': 'metacritic',
  'metal-archives.com': 'metalarchives',
  'metalmusicarchives.com': 'metalmusicarchives',
  'mixcloud.com': 'mixcloud',
  'mixesdb.com': 'mixesdb',
  'mobygames.com': 'mobygames',
  'mora.jp': 'mora',
  'music.amazon': 'amazonmusic',
  // eslint-disable-next-line sort-keys
  'classical.music.apple.com': 'appleclassical',
  'music.apple.com': 'applemusic',
  'music.bugs.co.kr': 'bugs',
  'music.migu.cn': 'migumusic',
  'music.yandex': 'yandex',
  'music.youtube.com': 'youtubemusic',
  'musicapopular.cl': 'musicapopularcl',
  'musik-sammler.de': 'musiksammler',
  'musixmatch.com': 'musixmatch',
  'musopen.org': 'musopen',
  'muziekweb.nl': 'muziekweb',
  'muzikum.eu': 'muzikum',
  'myanimelist.net': 'myanimelist',
  'myspace.com': 'myspace',
  'napster.com': 'napster',
  'nicovideo.jp': 'niconicovideo',
  'nla.gov.au': 'trove',
  'oclc.org': 'oclc',
  'ocremix.org': 'ocremix',
  'offiziellecharts.de': 'offiziellecharts',
  'online-bijbel.nl': 'onlinebijbel',
  'opac.kbr.be': 'kbr',
  'openlibrary.org': 'openlibrary',
  'operabase.com': 'operabase',
  'ototoy.jp': 'ototoy',
  'overture.doremus.org': 'overture',
  'patreon.com': 'patreon',
  'paypal.me': 'paypal',
  'petitlyrics.com': 'petitlyrics',
  'pinterest.com': 'pinterest',
  'pixiv.net': 'pixiv',
  'progarchives.com': 'progarchives',
  'psydb.net': 'psydb',
  'qobuz.com': 'qobuz',
  'quebecinfomusique.com': 'quebecinfomusique',
  'ra.co': 'residentadvisor',
  'rateyourmusic.com': 'rateyourmusic',
  'recochoku.jp': 'recochoku',
  'reverbnation.com': 'reverbnation',
  'rism.online': 'rism',
  'rock.com.ar': 'rockcomar',
  'rockensdanmarkskort.dk': 'rockensdanmarkskort',
  'rockinchina.com': 'ric',
  'rockipedia.no': 'rockipedia',
  'rockit.it': 'rockit',
  'rolldabeats.com': 'rolldabeats',
  'runeberg.org': 'runeberg',
  'saisaibatake.ame-zaiku.com/gakki': 'gakki',
  'saisaibatake.ame-zaiku.com/musical': 'gakki',
  'saisaibatake.ame-zaiku.com/musical_instrument': 'gakki',
  'secondhandsongs.com': 'secondhandsongs',
  'setlist.fm': 'setlistfm',
  'shop.tsutaya.co.jp': 'tsutaya',
  'smdb.kb.se': 'smdb',
  'snaccooperative.org': 'snac',
  'songfacts.com': 'songfacts',
  'songkick.com': 'songkick',
  'soundcloud.com': 'soundcloud',
  'spirit-of-metal.com': 'spiritofmetal',
  'spirit-of-rock.com': 'spiritofrock',
  'spotify.com': 'spotify',
  'stage48.net': 'stage48',
  'steamdb.info': 'steamdb',
  'stereo-ve-mono.com': 'stereo-ve-mono',
  'target.com': 'target',
  'tedcrane.com/DanceDB': 'dancedb',
  'theatricalia.com': 'theatricalia',
  'thedancegypsy.com': 'thedancegypsy',
  'themoviedb.org': 'tmdb',
  'thesession.org': 'thesession',
  'threads.com': 'threads',
  'thwiki.cc': 'thbwiki',
  'tidal.com': 'tidal',
  'tiktok.com': 'tiktok',
  'tipeee.com': 'tipeee',
  'tobarandualchais.co.uk': 'tobar',
  'touhoudb.com': 'touhoudb',
  'tower.jp': 'tower',
  'traxsource.com': 'traxsource',
  'triplejunearthed.com': 'triplejunearthed',
  'tunearch.org': 'tunearch',
  'twitch.tv': 'twitch',
  'twitter.com': 'twitter',
  'uta-net.com': 'utanet',
  'utaitedb.net': 'utaitedb',
  'utaten.com': 'utaten',
  'vgmdb.net': 'vgmdb',
  'viaf.org': 'viaf',
  'vibe.naver.com': 'navervibe',
  'vimeo.com/ondemand': 'vimeoondemand',
  // eslint-disable-next-line sort-keys
  'vimeo.com': 'vimeo',
  'vk.com': 'vk',
  'vk.gy': 'vkgy',
  'vkdb.jp': 'vkdb',
  'vndb.org': 'vndb',
  'vocadb.net': 'vocadb',
  'weibo.com': 'weibo',
  'whosampled.com': 'whosampled',
  'wikidata.org': 'wikidata',
  'wikipedia.org': 'wikipedia',
  'wikisource.org': 'wikisource',
  'worldcat.org': 'worldcat',
  'www.amazon': 'amazon',
  'www.livenation.': 'livenation',
  'www.ticketmaster.': 'ticketmaster',
  'www.youtube.com': 'youtube',
  'www5.atwiki.jp/hmiku/': 'hmikuwiki',
  'yesasia.com': 'yesasia',
  'zamp.hr': 'zamp',
  'zemereshet.co.il': 'zemereshet',
};

export const PART_OF_SERIES_LINK_TYPES: {
  +[type: RelatableEntityTypeT]: string | null,
} = {
  area: null,
  artist: 'd1a845d1-8c03-3191-9454-e4e8d37fa5e0',
  event: '707d947d-9563-328a-9a7d-0c5b9c3a9791',
  genre: null,
  instrument: null,
  label: null,
  place: null,
  recording: 'ea6f0698-6782-30d6-b16d-293081b66774',
  release: '3fa29f01-8e13-3e49-9b0a-ad212aa2f81d',
  release_group: '01018437-91d8-36b9-bf89-3f885d53b5bd',
  series: null,
  url: null,
  work: 'b0d44366-cdf0-3acb-bee6-0f65a77a6ef0',
};

export const PART_OF_SERIES_LINK_TYPE_GIDS: $ReadOnlyArray<string> =
  (Object.values(PART_OF_SERIES_LINK_TYPES).filter(Boolean));

export const PART_OF_SERIES_LINK_TYPE_IDS: $ReadOnlyArray<number> = [
  740, // recording
  741, // release
  742, // release group
  743, // work
  802, // event
  996, // artist
];

export const RECORDING_OF_LINK_TYPE_ID: number = 278;

export const RECORDING_OF_LINK_TYPE_GID: string =
  'a3005666-a872-32c3-ad06-98af558e99b0';

export const RT_MIRROR = 2;

export const TIME_ATTRIBUTE = 'ebd303c3-7f57-452a-aa3b-d780ebad868d';

export const SERIES_ORDERING_ATTRIBUTE =
  'a59c5830-5ec7-38fe-9a21-c7ea54f6650a';

export const SERIES_ORDERING_TYPE_AUTOMATIC = 1;

export const SERIES_ORDERING_TYPE_MANUAL = 2;

export const MBID_REGEXP: RegExp =
  /[0-9a-f]{8}-[0-9a-f]{4}-[345][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}/i;

export const VARTIST_GID = '89ad4ac3-39f7-470e-963a-56509c546377';

export const VARTIST_ID = 1;

export const VARTIST_NAME = 'Various Artists';

export const ANON_ARTIST_GID = 'f731ccc4-e22a-43af-a747-64213329e088';
export const ANON_ARTIST_ID = 15071;

export const DATA_ARTIST_GID = '33cf029c-63b0-41a0-9855-be2a3665fb3b';
export const DATA_ARTIST_ID = 41744;

export const DIALOGUE_ARTIST_GID = '314e1c25-dde7-4e4d-b2f4-0a7b9f7c56dc';
export const DIALOGUE_ARTIST_ID = 92121;

export const NO_ARTIST_GID = 'eec63d3c-3b81-4ad4-b1e4-7c147d4d2b61';
export const NO_ARTIST_ID = 105725;

export const TRAD_ARTIST_GID = '9be7f096-97ec-4615-8957-8d40b5dcbc41';
export const TRAD_ARTIST_ID = 762646;

export const UNKNOWN_ARTIST_GID = '125ec42a-7229-4250-afc5-e057484327fe';
export const UNKNOWN_ARTIST_ID = 97546;

export const SPECIAL_ARTIST_GIDS: $ReadOnlyArray<string> = [
  VARTIST_GID,
  ANON_ARTIST_GID,
  DATA_ARTIST_GID,
  DIALOGUE_ARTIST_GID,
  NO_ARTIST_GID,
  TRAD_ARTIST_GID,
  UNKNOWN_ARTIST_GID,
];

export const SPECIAL_ARTIST_IDS: $ReadOnlyArray<number> = [
  DARTIST_ID,
  VARTIST_ID,
  ANON_ARTIST_ID,
  DATA_ARTIST_ID,
  DIALOGUE_ARTIST_ID,
  NO_ARTIST_ID,
  TRAD_ARTIST_ID,
  UNKNOWN_ARTIST_ID,
];

export const NOLABEL_GID = '157afde4-4bf5-4039-8ad2-5a15acc85176';

export const NOLABEL_ID = 3267;

export const VIDEO_ATTRIBUTE_ID = 582;

export const VIDEO_ATTRIBUTE_GID = '112054d5-e706-4dd8-99ea-09aabee36cd6';

export const MAX_LENGTH_DIFFERENCE = 10500;

export const MAX_RECENT_ENTITIES = 10;

export const MIN_NAME_SIMILARITY = 0.75;

export const ENTITIES_WITH_RELATIONSHIP_CREDITS = {
  area: true,
  artist: true,
  event: false,
  genre: false,
  instrument: true,
  label: true,
  place: true,
  recording: false,
  release: false,
  release_group: false,
  series: false,
  url: false,
  work: false,
};

export const QUALITY_NAMES: Map<QualityT, () => string> = new Map([
  [0, N_l('Low')],
  [-1, N_l('Normal')],
  [1, N_l('Normal')],
  [2, N_l('High')],
]);

export const FLUENCY_NAMES:
  {+[fluency: string]: () => string,
  ...
} = {
  advanced: N_l('Advanced'),
  basic: N_l('Basic'),
  intermediate: N_l('Intermediate'),
  native: N_l('Native'),
};

export const LANGUAGE_ENG_ID = 120;
export const LANGUAGE_MUL_ID = 284;
export const LANGUAGE_ZXX_ID = 486;

export const COUNTRY_JA_AREA_ID = 107;

export const DISPLAY_NONE_STYLE = Object.freeze({display: 'none'});

export const WS_EDIT_RESPONSE_OK: WS_EDIT_RESPONSE_OK_T = 1;
export const WS_EDIT_RESPONSE_NO_CHANGES: WS_EDIT_RESPONSE_NO_CHANGES_T = 2;

export const BRACKET_PAIRS = [
  ['(', ')'],
  ['[', ']'],
  ['<', '>'],
  ['（', '）'],
  ['［', '］'],
  ['{', '}'],
  ['【', '】'],
];
