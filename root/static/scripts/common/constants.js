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

export const AREA_TYPE_COUNTRY = 1;

export const ARTIST_TYPE_PERSON = 1;

export const CONTACT_URL = 'https://metabrainz.org/contact';

export const DARTIST_ID = 2;

export const DLABEL_ID = 1;

export const FAVICON_CLASSES: {
  +[class: string]: {+host: RegExp, +path?: RegExp},
} = {
  allmusic: {host: /^www\.allmusic\.com$/},
  amazon: {host: /^www\.amazon\.(ae|at|com\.au|com\.br|ca|cn|com|de|es|fr|in|it|jp|co\.jp|com\.mx|nl|se|sg|com\.tr|co\.uk)$/},
  amazonmusic: {host: /^music\.amazon\.(ae|at|com\.au|com\.br|ca|cn|com|de|es|fr|in|it|jp|co\.jp|com\.mx|nl|se|sg|com\.tr|co\.uk)$/},
  animenewsnetwork: {host: /^www\.animenewsnetwork\.com$/},
  anisongeneration: {host: /^anison\.info$/},
  applebooks: {host: /^books\.apple\.com$/},
  applemusic: {host: /^music\.apple\.com$/},
  archive: {host: /^archive\.org$/},
  baidu: {host: /^baike\.baidu\.com$/},
  bandcamp: {host: /^[^\/]+\.bandcamp\.com$/},
  bandsintown: {host: /^www\.bandsintown\.com$/},
  beatport: {host: /^(?:sounds|www)\.beatport\.com$/},
  bigcartel: {host: /^[^\/]+\.bigcartel\.com$/},
  bnfcatalogue: {host: /^catalogue\.bnf\.fr$/},
  bookbrainz: {host: /^bookbrainz\.org$/},
  cancioneros: {host: /^www\.cancioneros\.si$/},
  castalbums: {host: /^(?:www\.)?castalbums\.org$/},
  cbfiddlerx: {host: /^www\.cbfiddle\.com$/, path: /^\/rx/},
  ccmixter: {host: /^ccmixter\.org$/},
  cdjapan: {host: /^www\.cdjapan\.co\.jp$/},
  changetip: {host: /^www\.changetip\.com$/},
  cinii: {host: /^(?:www\.)?ci\.nii\.ac\.jp$/},
  classicalarchives: {host: /^www\.classicalarchives\.com$/},
  cpdl: {host: /^cpdl\.org$/},
  dahr: {host: /^adp\.library\.ucsb\.edu$/},
  dailymotion: {host: /^www\.dailymotion\.com$/},
  dancedb: {host: /^(?:www\.)?tedcrane\.com$/, path: /^\/DanceDB/},
  deezer: {host: /^www\.deezer\.com$/},
  dhhu: {host: /^www\.dhhu\.dk$/},
  directlyrics: {host: /^(?:[^/]+\.)?directlyrics\.com$/},
  discogs: {host: /^www\.discogs\.com$/},
  dnb: {host: /^d-nb\.info$/},
  dogmazic: {host: /^play\.dogmazic\.net$/},
  dram: {host: /^www\.dramonline\.org$/},
  encyclopedisque: {host: /^(?:www\.)?encyclopedisque\.fr$/},
  ester: {host: /^www\.ester\.ee$/},
  evestalyric: {host: /^lyric\.evesta\.jp$/},
  facebook: {host: /^www\.facebook\.com$/},
  finna: {host: /^(?:www\.)?finna\.fi$/},
  finnmusic: {host: /^(?:www\.)?finnmusic\.net$/},
  flattr: {host: /^flattr\.com$/},
  fonofi: {host: /^(?:www\.)?fono\.fi$/},
  fortyfivecat: {host: /^www\.45cat\.com$/},
  fortyfiveworlds: {host: /^www\.45worlds\.com$/},
  gakki: {host: /^saisaibatake\.ame-zaiku\.com$/, path: /^\/(?:gakki|musical|musical_instrument)/},
  generasia: {host: /^www\.generasia\.com$/, path: /^\/wiki/},
  genius: {host: /^genius\.com$/},
  geonames: {host: /^sws\.geonames\.org$/},
  gutenberg: {host: /^(?:[^/]+\.)?gutenberg\.org$/},
  hmikuwiki: {host: /^www5\.atwiki\.jp$/, path: /^\/hmiku/},
  hoick: {host: /^hoick\.jp$/},
  ibdb: {host: /^www\.ibdb\.com$/},
  imdb: {host: /^www\.imdb\.com$/},
  imslp: {host: /^imslp\.org$/},
  imvdb: {host: /^(?:www\.)?imvdb\.com$/},
  indiegogo: {host: /^www\.indiegogo\.com$/},
  instagram: {host: /^www\.instagram\.com$/},
  ircam: {host: /^brahms\.ircam\.fr$/},
  irishtune: {host: /^www\.irishtune\.info$/},
  itunes: {host: /^itunes\.apple\.com$/},
  jlyric: {host: /^(?:[^/]+\.)?j-lyric\.net$/},
  joysound: {host: /^www\.joysound\.com$/},
  junodownload: {host: /^(?:[^/]+\.)?junodownload\.com$/},
  kashinavi: {host: /^kashinavi\.com$/},
  kget: {host: /^www\.kget\.jp$/},
  kickstarter: {host: /^www\.kickstarter\.com$/},
  kofi: {host: /^ko-fi\.com$/},
  laboiteauxparoles: {host: /^laboiteauxparoles\.com$/},
  lastfm: {host: /^www\.last\.fm$/},
  lieder: {host: /^(?:[^/]+\.)?lieder\.net$/},
  linkedin: {host: /^(?:[^/]+\.)?linkedin\.com$/},
  livefans: {host: /^www\.livefans\.jp$/},
  loc: {host: /^id\.loc\.gov$/},
  loudr: {host: /^loudr\.fm$/},
  mainlynorfolk: {host: /^mainlynorfolk\.info$/},
  metalarchives: {host: /^www\.metal-archives\.com$/},
  migumusic: {host: /^music\.migu\.cn$/},
  mixcloud: {host: /^www\.mixcloud\.com$/},
  mora: {host: /^mora\.jp$/},
  musicapopularcl: {host: /^www\.musicapopular\.cl$/},
  musiksammler: {host: /^www\.musik-sammler\.de$/},
  musixmatch: {host: /^www\.musixmatch\.com$/},
  musopen: {host: /^musopen\.org$/},
  muziekweb: {host: /^www\.muziekweb\.nl$/},
  muzikum: {host: /^(?:[^/]+\.)?muzikum\.eu$/},
  myspace: {host: /^myspace\.com$/},
  napster: {host: /^[a-z]{2}\.napster\.com$/},
  ndl: {host: /^(?:www\.)?iss\.ndl\.go\.jp$/},
  niconicovideo: {host: /^(?:ch|www)\.nicovideo\.jp$/},
  ocremix: {host: /^ocremix\.org$/},
  offiziellecharts: {host: /^www\.offiziellecharts\.de$/},
  onlinebijbel: {host: /^www\.online-bijbel\.nl$/},
  openlibrary: {host: /^openlibrary\.org$/},
  operabase: {host: /^operabase\.com$/},
  overture: {host: /^overture\.doremus\.org$/},
  patreon: {host: /^www\.patreon\.com$/},
  paypal: {host: /^www\.paypal\.me$/},
  petitlyrics: {host: /^petitlyrics\.com$/},
  pinterest: {host: /^www\.pinterest\.com$/},
  piosenki: {host: /^(?:www\.)?bibliotekapiosenki\.pl$/},
  progarchives: {host: /^www\.progarchives\.com$/},
  psydb: {host: /^(?:www\.)?psydb\.net$/},
  qobuz: {host: /^(?:www\.)?qobuz\.com$/},
  quebecinfomusique: {host: /^www\.qim\.com$/},
  rateyourmusic: {host: /^rateyourmusic\.com$/},
  recochoku: {host: /^recochoku\.jp$/},
  residentadvisor: {host: /^ra\.co$/},
  reverbnation: {host: /^www\.reverbnation\.com$/},
  ric: {host: /^www\.rockinchina\.com$/},
  rockcomar: {host: /^rock\.com\.ar$/},
  rockensdanmarkskort: {host: /^www\.rockensdanmarkskort\.dk$/},
  rockipedia: {host: /^www\.rockipedia\.no$/},
  rolldabeats: {host: /^(?:www\.)?rolldabeats\.com$/},
  runeberg: {host: /^runeberg\.org$/},
  secondhandsongs: {host: /^secondhandsongs\.com$/},
  setlistfm: {host: /^(?:[^/]+\.)?setlist\.fm$/},
  smdb: {host: /^(?:www\.)?smdb\.kb\.se$/},
  snac: {host: /^snaccooperative\.org$/},
  songfacts: {host: /^(?:[^/]+\.)?songfacts\.com$/},
  songkick: {host: /^www\.songkick\.com$/},
  soundcloud: {host: /^soundcloud\.com$/},
  spiritofmetal: {host: /^(?:www\.)?spirit-of-metal\.com$/},
  spiritofrock: {host: /^(?:www\.)?spirit-of-rock\.com$/},
  spotify: {host: /^open\.spotify\.com$/},
  stage48: {host: /^(?:www\.)?stage48\.net$/},
  theatricalia: {host: /^(?:www\.)?theatricalia\.com$/},
  thedancegypsy: {host: /^(?:www\.)?thedancegypsy\.com$/},
  thesession: {host: /^thesession\.org$/},
  tipeee: {host: /^www\.tipeee\.com$/},
  touhoudb: {host: /^touhoudb\.com$/},
  traxsource: {host: /^www\.traxsource\.com$/},
  triplejunearthed: {host: /^(?:www\.)?triplejunearthed\.com$/},
  trove: {host: /^(?:trove\.)?nla\.gov\.au$/},
  tunearch: {host: /^(?:www\.)?tunearch\.org$/},
  twitch: {host: /^www\.twitch\.tv$/},
  twitter: {host: /^twitter\.com$/},
  utaitedb: {host: /^utaitedb\.net$/},
  utamap: {host: /^(?:[^/]+\.)?utamap\.com$/},
  utanet: {host: /^www\.uta-net\.com$/},
  utaten: {host: /^utaten\.com$/},
  vgmdb: {host: /^vgmdb\.net$/},
  viaf: {host: /^viaf\.org$/},
  videogamin: {host: /^(?:www\.)?videogam\.in$/},
  vimeo: {host: /^vimeo\.com$/},
  vk: {host: /^vk\.com$/},
  vkdb: {host: /^(?:www\.)?vkdb\.jp$/},
  vocadb: {host: /^vocadb\.net$/},
  weibo: {host: /^www\.weibo\.com$/},
  whosampled: {host: /^www\.whosampled\.com$/},
  wikidata: {host: /^www\.wikidata\.org$/},
  wikipedia: {host: /^[a-z]+\.wikipedia\.org$/},
  wikisource: {host: /^(?:[a-z-]+\.)?wikisource\.org$/},
  worldcat: {host: /^www\.worldcat\.org$/},
  youtube: {host: /^www\.youtube\.com$/},
  youtubemusic: {host: /^music\.youtube\.com$/},
};

export const PART_OF_SERIES_LINK_TYPES = {
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

export const LANGUAGE_MUL_ID = 284;
export const LANGUAGE_ZXX_ID = 486;
