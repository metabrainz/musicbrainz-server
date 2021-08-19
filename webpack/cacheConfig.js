/*
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const path = require('path');

const constants = require('./constants');
const dirs = require('./dirs');

module.exports = {
  type: 'filesystem',
  buildDependencies: {
    config: [path.resolve(dirs.CHECKOUT, 'webpack') + path.sep],
  },
  version: (
    constants.WEBPACK_MODE + '-' +
    String(process.env.NODE_ENV) + '-' +
    String(process.env.MUSICBRAINZ_RUNNING_TESTS)
  ),
};
