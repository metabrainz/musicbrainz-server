/*
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable import/no-commonjs */

const {WEBPACK_MODE} = require('./constants');

const GLOBAL_JS_NAMESPACE = '__MB__';

module.exports = {
  /*
   * Use `__DEV__` to conditionalize code that should run during
   * testing/development only. Will be eliminated as dead code by
   * Webpack in production.
   */
  __DEV__: JSON.stringify(WEBPACK_MODE === 'development'),
  GLOBAL_JS_NAMESPACE: JSON.stringify(GLOBAL_JS_NAMESPACE),
  MUSICBRAINZ_RUNNING_TESTS:
    JSON.stringify(!!process.env.MUSICBRAINZ_RUNNING_TESTS),
};
