/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable import/no-commonjs */

let WEBPACK_MODE = process.env.WEBPACK_MODE;
if (typeof WEBPACK_MODE === 'undefined') {
  if (process.env.NODE_ENV === 'production') {
    WEBPACK_MODE = 'production';
  } else {
    WEBPACK_MODE = 'development';
  }
}

module.exports = {
  dirs: require('./dirs'),
  GETTEXT_DOMAINS: [
    'attributes',
    'countries',
    'instrument_descriptions',
    'instruments',
    'languages',
    'mb_server',
    'relationships',
    'scripts',
    'statistics',
  ],
  PRODUCTION_MODE: WEBPACK_MODE === 'production',
  WEBPACK_MODE: WEBPACK_MODE,
};
