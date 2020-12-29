/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ENTITIES from '../../../../entities';

export {ENTITIES};

export const ENTITY_NAMES: {
  +[entityType: CoreEntityTypeT]: () => string,
  ...
} = {
  area: N_l('Area'),
  artist: N_l('Artist'),
  event: N_l('Event'),
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

export const AREA_TYPE_COUNTRY = 1;

export const CONTACT_URL = 'https://metabrainz.org/contact';

export const DARTIST_ID = 2;

export const DLABEL_ID = 1;

export const FAVICON_CLASSES = {
  '45cat.com': 'fortyfivecat',
  '45worlds.com': 'fortyfiveworlds',
  'adp.library.ucsb.edu': 'dahr',
  'allmusic.com': 'allmusic',
  'animenewsnetwork.com': 'animenewsnetwork',
  'anison.info': 'anisongeneration',
  'baidu.com': 'baidu',
  'bandcamp.com': 'bandcamp',
  'bandsintown.com': 'bandsintown',
  'bbc.co.uk': 'bbcmusic',
  'beatport.com': 'beatport',
  'bibliotekapiosenki.pl': 'piosenki',
  'bigcartel.com': 'bigcartel',
  'bookbrainz.org': 'bookbrainz',
  'books.apple.com': 'applebooks',
  'cancioneros.si': 'cancioneros',
  'castalbums.org': 'castalbums',
  'catalogue.bnf.fr': 'bnfcatalogue',
  'cbfiddle.com/rx/': 'cbfiddlerx',
  'ccmixter.org': 'ccmixter',
  'changetip.com': 'changetip',
  'ci.nii.ac.jp': 'cinii',
  'classicalarchives.com': 'classicalarchives',
  'cpdl.org': 'cpdl',
  'd-nb.info': 'dnb',
  'dailymotion.com': 'dailymotion',
  'deezer.com': 'deezer',
  'dhhu.dk': 'dhhu',
  'directlyrics.com': 'directlyrics',
  'discogs.com': 'discogs',
  'dramonline.org': 'dram',
  'encyclopedisque.fr': 'encyclopedisque',
  'ester.ee': 'ester',
  'facebook.com': 'facebook',
  'finna.fi': 'finna',
  'finnmusic.net': 'finnmusic',
  'flattr.com': 'flattr',
  'fono.fi': 'fonofi',
  'generasia.com/wiki': 'generasia',
  'genius.com': 'genius',
  'gutenberg.org': 'gutenberg',
  'hoick.jp': 'hoick',
  'ibdb.com': 'ibdb',
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
  'joysound.com': 'joysound',
  'junodownload.com': 'junodownload',
  'kashinavi.com': 'kashinavi',
  'kget.jp': 'kget',
  'kickstarter.com': 'kickstarter',
  'ko-fi.com': 'kofi',
  'laboiteauxparoles.com': 'laboiteauxparoles',
  'last.fm': 'lastfm',
  'lieder.net': 'lieder',
  'linkedin.com': 'linkedin',
  'livefans.jp': 'livefans',
  'loc.gov': 'loc',
  'loudr.fm': 'loudr',
  'lyric.evesta.jp': 'evestalyric',
  'lyricsnmusic.com': 'lyricsnmusic',
  'mainlynorfolk.info': 'mainlynorfolk',
  'metal-archives.com': 'metalarchives',
  'mixcloud.com': 'mixcloud',
  'music.amazon': 'amazonmusic',
  'music.apple.com': 'applemusic',
  'music.migu.cn': 'migumusic',
  'musicapopular.cl': 'musicapopularcl',
  'musik-sammler.de': 'musiksammler',
  'musixmatch.com': 'musixmatch',
  'musopen.org': 'musopen',
  'muziekweb.eu': 'muziekweb',
  'muzikum.eu': 'muzikum',
  'myspace.com': 'myspace',
  'napster.com': 'napster',
  'nicovideo.jp': 'niconicovideo',
  'nla.gov.au': 'trove',
  'ocremix.org': 'ocremix',
  'offiziellecharts.de': 'offiziellecharts',
  'online-bijbel.nl': 'onlinebijbel',
  'openlibrary.org': 'openlibrary',
  'operabase.com': 'operabase',
  'patreon.com': 'patreon',
  'paypal.me': 'paypal',
  'petitlyrics.com': 'petitlyrics',
  'progarchives.com': 'progarchives',
  'psydb.net': 'psydb',
  'qim.com': 'quebecinfomusique',
  'rateyourmusic.com': 'rateyourmusic',
  'residentadvisor.net': 'residentadvisor',
  'reverbnation.com': 'reverbnation',
  'rock.com.ar': 'rockcomar',
  'rockensdanmarkskort.dk': 'rockensdanmarkskort',
  'rockinchina.com': 'ric',
  'rockipedia.no': 'rockipedia',
  'rolldabeats.com': 'rolldabeats',
  'runeberg.org': 'runeberg',
  'saisaibatake.ame-zaiku.com/gakki': 'gakki',
  'saisaibatake.ame-zaiku.com/musical': 'gakki',
  'saisaibatake.ame-zaiku.com/musical_instrument': 'gakki',
  'secondhandsongs.com': 'secondhandsongs',
  'setlist.fm': 'setlistfm',
  'smdb.kb.se': 'smdb',
  'snaccooperative.org': 'snac',
  'songfacts.com': 'songfacts',
  'songkick.com': 'songkick',
  'soundcloud.com': 'soundcloud',
  'spirit-of-metal.com': 'spiritofmetal',
  'spirit-of-rock.com': 'spiritofrock',
  'spotify.com': 'spotify',
  'stage48.net': 'stage48',
  'tedcrane.com/DanceDB': 'dancedb',
  'theatricalia.com': 'theatricalia',
  'thedancegypsy.com': 'thedancegypsy',
  'thesession.org': 'thesession',
  'tipeee.com': 'tipeee',
  'touhoudb.com': 'touhoudb',
  'traxsource.com': 'traxsource',
  'triplejunearthed.com': 'triplejunearthed',
  'tunearch.org': 'tunearch',
  'twitch.tv': 'twitch',
  'twitter.com': 'twitter',
  'uta-net.com': 'utanet',
  'utaitedb.net': 'utaitedb',
  'utamap.com': 'utamap',
  'utaten.com': 'utaten',
  'vgmdb.net': 'vgmdb',
  'viaf.org': 'viaf',
  'videogam.in': 'videogamin',
  'vimeo.com': 'vimeo',
  'vk.com': 'vk',
  'vkdb.jp': 'vkdb',
  'vocadb.net': 'vocadb',
  'weibo.com': 'weibo',
  'whosampled.com': 'whosampled',
  'wikidata.org': 'wikidata',
  'wikipedia.org': 'wikipedia',
  'wikisource.org': 'wikisource',
  'worldcat.org': 'worldcat',
  'www.amazon': 'amazon',
  'www5.atwiki.jp/hmiku/': 'hmikuwiki',
  'youtube.com': 'youtube',
};

export const PART_OF_SERIES_LINK_TYPES = {
  event: '707d947d-9563-328a-9a7d-0c5b9c3a9791',
  recording: 'ea6f0698-6782-30d6-b16d-293081b66774',
  release: '3fa29f01-8e13-3e49-9b0a-ad212aa2f81d',
  release_group: '01018437-91d8-36b9-bf89-3f885d53b5bd',
  work: 'b0d44366-cdf0-3acb-bee6-0f65a77a6ef0',
};

// orchestrator, orchestra performed, conductor, concertmaster
export const PROBABLY_CLASSICAL_LINK_TYPES =
  [40, 45, 46, 150, 151, 300, 759, 760];

export const RT_SLAVE = 2;

export const SERIES_ORDERING_ATTRIBUTE =
  'a59c5830-5ec7-38fe-9a21-c7ea54f6650a';

export const SERIES_ORDERING_TYPE_AUTOMATIC = 1;

export const SERIES_ORDERING_TYPE_MANUAL = 2;

export const MBID_REGEXP: RegExp =
  /[0-9a-f]{8}-[0-9a-f]{4}-[345][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}/;

export const VARTIST_GID = '89ad4ac3-39f7-470e-963a-56509c546377';

export const VARTIST_ID = 1;

export const VARTIST_NAME = 'Various Artists';

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
  instrument: true,
  label: true,
  place: true,
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

export const LANGUAGE_MUL_ID = 284;
export const LANGUAGE_ZXX_ID = 486;
