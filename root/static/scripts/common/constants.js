/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

exports.ENTITIES = require('../../../../entities');

exports.AREA_TYPE_COUNTRY = 1;

exports.DARTIST_ID = 2;

exports.FAVICON_CLASSES = {
  '45cat.com': 'fortyfivecat',
  '45worlds.com': 'fortyfiveworlds',
  'allmusic.com': 'allmusic',
  'amazon': 'amazon',
  'animenewsnetwork.com': 'animenewsnetwork',
  'baidu.com': 'baidu',
  'bandcamp.com': 'bandcamp',
  'bandsintown.com': 'bandsintown',
  'bbc.co.uk': 'bbcmusic',
  'bibliotekapiosenki.pl': 'piosenki',
  'bigcartel.com': 'bigcartel',
  'cancioneros.si': 'cancioneros',
  'castalbums.org': 'castalbums',
  'catalogue.bnf.fr': 'bnfcatalogue',
  'cbfiddle.com/rx/': 'cbfiddlerx',
  'cdbaby.com': 'cdbaby',
  'changetip.com': 'changetip',
  'ci.nii.ac.jp': 'cinii',
  'cpdl.org': 'cpdl',
  'd-nb.info': 'dnb',
  'dailymotion.com': 'dailymotion',
  'dhhu.dk': 'dhhu',
  'discogs.com': 'discogs',
  'encyclopedisque.fr': 'encyclopedisque',
  'ester.ee': 'ester',
  'facebook.com': 'facebook',
  'finna.fi': 'finna',
  'finnmusic.net': 'finnmusic',
  'flattr.com': 'flattr',
  'fono.fi': 'fonofi',
  'generasia.com': 'generasia',
  'genius.com': 'genius',
  'ibdb.com': 'ibdb',
  'imdb.com': 'imdb',
  'imslp.org': 'imslp',
  'imvdb.com': 'imvdb',
  'indiegogo.com': 'indiegogo',
  'instagram.com': 'instagram',
  'irishtune.info': 'irishtune',
  'iss.ndl.go.jp': 'ndl',
  'itunes.apple.com': 'itunes',
  'kickstarter.com': 'kickstarter',
  'last.fm': 'lastfm',
  'lieder.net': 'lieder',
  'linkedin.com': 'linkedin',
  'livefans.jp': 'livefans',
  'loudr.fm': 'loudr',
  'mainlynorfolk.info': 'mainlynorfolk',
  'metal-archives.com': 'metalarchives',
  'musicapopular.cl': 'musicapopularcl',
  'musik-sammler.de': 'musiksammler',
  'myspace.com': 'myspace',
  'nla.gov.au': 'trove',
  'ocremix.org': 'ocremix',
  'openlibrary.org': 'openlibrary',
  'operabase.com': 'operabase',
  'patreon.com': 'patreon',
  'paypal.me': 'paypal',
  'play.google.com': 'googleplay',
  'plus.google.com': 'googleplus',
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
  'secondhandsongs.com': 'secondhandsongs',
  'setlist.fm': 'setlistfm',
  'smdb.kb.se': 'smdb',
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
  'triplejunearthed.com': 'triplejunearthed',
  'tunearch.org': 'tunearch',
  'twitch.tv': 'twitch',
  'twitter.com': 'twitter',
  'utaitedb.net': 'utaitedb',
  'vgmdb.net': 'vgmdb',
  'viaf.org': 'viaf',
  'videogam.in': 'videogamin',
  'vimeo.com': 'vimeo',
  'vk.com': 'vk',
  'vkdb.jp': 'vkdb',
  'vocadb.net': 'vocadb',
  'whosampled.com': 'whosampled',
  'wikidata.org': 'wikidata',
  'wikipedia.org': 'wikipedia',
  'worldcat.org': 'worldcat',
  'www5.atwiki.jp/hmiku/': 'hmikuwiki',
  'youtube.com': 'youtube',
};

exports.PART_OF_SERIES_LINK_TYPES = {
  event: '707d947d-9563-328a-9a7d-0c5b9c3a9791',
  recording: 'ea6f0698-6782-30d6-b16d-293081b66774',
  release: '3fa29f01-8e13-3e49-9b0a-ad212aa2f81d',
  release_group: '01018437-91d8-36b9-bf89-3f885d53b5bd',
  work: 'b0d44366-cdf0-3acb-bee6-0f65a77a6ef0',
};

// orchestrator, orchestra performed, conductor, concertmaster
exports.PROBABLY_CLASSICAL_LINK_TYPES = [40, 45, 46, 150, 151, 300, 759, 760];

exports.RT_SLAVE = 2;

exports.SERIES_ORDERING_ATTRIBUTE = 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a';

exports.SERIES_ORDERING_TYPE_AUTOMATIC = 1;

exports.SERIES_ORDERING_TYPE_MANUAL = 2;

exports.UUID_REGEXP_STR = '[0-9a-f]{8}-[0-9a-f]{4}-[345][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}';

exports.VARTIST_GID = '89ad4ac3-39f7-470e-963a-56509c546377';

exports.VARTIST_ID = 1;

exports.VARTIST_NAME = 'Various Artists';

exports.VIDEO_ATTRIBUTE_ID = 582;

exports.VIDEO_ATTRIBUTE_GID = '112054d5-e706-4dd8-99ea-09aabee36cd6';

exports.MAX_LENGTH_DIFFERENCE = 10500;

exports.MAX_RECENT_ENTITIES = 10;

exports.MIN_NAME_SIMILARITY = 0.75;

exports.ENTITIES_WITH_RELATIONSHIP_CREDITS = {
  area: true,
  artist: true,
  place: true,
};
