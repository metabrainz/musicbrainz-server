/*
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable import/no-commonjs */

const DBDefs = require('../root/static/scripts/common/DBDefs');

const GLOBAL_JS_NAMESPACE = '__MB__';

module.exports = {
  /*
   * Use `__DEV__` to conditionalize code that should run during
   * testing/development only. Will be eliminated as dead code by
   * Webpack in production.
   */
  __DEV__: JSON.stringify(
    !!(DBDefs.DEVELOPMENT_SERVER || process.env.NODE_ENV === 'test'),
  ),
  GLOBAL_JS_NAMESPACE: JSON.stringify(GLOBAL_JS_NAMESPACE),
};
