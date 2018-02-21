exports.ENTITIES = require('../../../../entities');

exports.AREA_TYPE_COUNTRY = 1;

exports.DARTIST_ID = 2;

exports.FAVICON_CLASSES = {
    'amazon':                       'amazon',
    'allmusic.com':                 'allmusic',
    'animenewsnetwork.com':         'animenewsnetwork',
    'bbc.co.uk':                    'bbcmusic',
    'wikipedia.org':                'wikipedia',
    'facebook.com':                 'facebook',
    'generasia.com':                'generasia',
    'last.fm':                      'lastfm',
    'myspace.com':                  'myspace',
    'twitter.com':                  'twitter',
    'youtube.com':                  'youtube',
    'discogs.com':                  'discogs',
    'secondhandsongs.com':          'secondhandsongs',
    'songfacts.com':                'songfacts',
    'soundcloud.com':               'soundcloud',
    'ibdb.com':                     'ibdb',
    'imdb.com':                     'imdb',
    'imslp.org':                    'imslp',
    'instagram.com':                'instagram',
    'ester.ee':                     'ester',
    'worldcat.org':                 'worldcat',
    '45cat.com':                    'fortyfivecat',
    'rateyourmusic.com':            'rateyourmusic',
    'rolldabeats.com':              'rolldabeats',
    'psydb.net':                    'psydb',
    'metal-archives.com':           'metalarchives',
    'spirit-of-metal.com':          'spiritofmetal',
    'theatricalia.com':             'theatricalia',
    'whosampled.com':               'whosampled',
    'ocremix.org':                  'ocremix',
    'musik-sammler.de':             'musiksammler',
    'encyclopedisque.fr':           'encyclopedisque',
    'nla.gov.au':                   'trove',
    'rockensdanmarkskort.dk':       'rockensdanmarkskort',
    'rockinchina.com':              'ric',
    'rockipedia.no':                'rockipedia',
    'vgmdb.net':                    'vgmdb',
    'viaf.org':                     'viaf',
    'vk.com':                       'vk',
    'vkdb.jp':                      'vkdb',
    'dhhu.dk':                      'dhhu',
    'thesession.org':               'thesession',
    'plus.google.com':              'googleplus',
    'openlibrary.org':              'openlibrary',
    'bandcamp.com':                 'bandcamp',
    'play.google.com':              'googleplay',
    'itunes.apple.com':             'itunes',
    'spotify.com':                  'spotify',
    'wikidata.org':                 'wikidata',
    'lieder.net':                   'lieder',
    'loudr.fm':                     'loudr',
    'genius.com':                   'genius',
    'imvdb.com':                    'imvdb',
    'residentadvisor.net':          'residentadvisor',
    'd-nb.info':                    'dnb',
    'iss.ndl.go.jp':                'ndl',
    'ci.nii.ac.jp':                 'cinii',
    'finnmusic.net':                'finnmusic',
    'fono.fi':                      'fonofi',
    'stage48.net':                  'stage48',
    'tedcrane.com/DanceDB':         'dancedb',
    'finna.fi':                     'finna',
    'mainlynorfolk.info':           'mainlynorfolk',
    'bibliotekapiosenki.pl':        'piosenki',
    'qim.com':                      'quebecinfomusique',
    'thedancegypsy.com':            'thedancegypsy',
    'videogam.in':                  'videogamin',
    'spirit-of-rock.com':           'spiritofrock',
    'tunearch.org':                 'tunearch',
    'castalbums.org':               'castalbums',
    'smdb.kb.se':                   'smdb',
    'triplejunearthed.com':         'triplejunearthed',
    'cdbaby.com':                   'cdbaby',
    'changetip.com':                'changetip',
    'flattr.com':                   'flattr',
    'patreon.com':                  'patreon',
    'paypal.me':                    'paypal',
    'tipeee.com':                   'tipeee',
    'indiegogo.com':                'indiegogo',
    'kickstarter.com':              'kickstarter',
    'setlist.fm':                   'setlistfm',
    'vimeo.com':                    'vimeo',
    'songkick.com':                 'songkick',
    'reverbnation.com':             'reverbnation',
    'linkedin.com':                 'linkedin',
    'www5.atwiki.jp/hmiku/':        'hmikuwiki',
    'baidu.com':                    'baidu',
    'cancioneros.si':               'cancioneros',
    'rock.com.ar':                  'rockcomar',
    'musicapopular.cl':             'musicapopularcl',
    'catalogue.bnf.fr':             'bnfcatalogue',
    'utaitedb.net':                 'utaitedb',
    'vocadb.net':                   'vocadb',
    'irishtune.info':               'irishtune',
    'cbfiddle.com/rx/':             'cbfiddlerx',
    '45worlds.com':                 'fortyfiveworlds',
    'cpdl.org':                     'cpdl',
    'bandsintown.com':              'bandsintown',
    'livefans.jp':                  'livefans',
    'twitch.tv':                    'twitch',
    'dailymotion.com':              'dailymotion',
    'bigcartel.com':                'bigcartel',
    'operabase.com':                'operabase',
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
