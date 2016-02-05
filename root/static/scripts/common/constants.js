exports.ENTITIES = require('../../../../entities');

exports.AREA_TYPE_COUNTRY = 1;

exports.PART_OF_SERIES_LINK_TYPES = {
  event: '707d947d-9563-328a-9a7d-0c5b9c3a9791',
  recording: 'ea6f0698-6782-30d6-b16d-293081b66774',
  release: '3fa29f01-8e13-3e49-9b0a-ad212aa2f81d',
  release_group: '01018437-91d8-36b9-bf89-3f885d53b5bd',
  work: 'b0d44366-cdf0-3acb-bee6-0f65a77a6ef0',
};

// orchestrator, orchestra performed, conductor, concertmaster
exports.PROBABLY_CLASSICAL_LINK_TYPES = [40, 45, 46, 150, 151, 300, 759, 760];

exports.SERIES_ORDERING_ATTRIBUTE = 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a';

exports.SERIES_ORDERING_TYPE_AUTOMATIC = 1;

exports.SERIES_ORDERING_TYPE_MANUAL = 2;

exports.UUID_REGEXP_STR = '[0-9a-f]{8}-[0-9a-f]{4}-[345][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}';

exports.VARTIST_GID = '89ad4ac3-39f7-470e-963a-56509c546377';

exports.VARTIST_NAME = 'Various Artists';

exports.VIDEO_ATTRIBUTE_ID = 582;

exports.VIDEO_ATTRIBUTE_GID = '112054d5-e706-4dd8-99ea-09aabee36cd6';

exports.MAX_LENGTH_DIFFERENCE = 10500;

exports.MAX_RECENT_ENTITIES = 10;

exports.MIN_NAME_SIMILARITY = 0.75;
