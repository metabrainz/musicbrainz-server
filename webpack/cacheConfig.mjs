/*
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import path from 'path';

import MB_SERVER_ROOT from '../root/utility/serverRootDir.mjs';

import {WEBPACK_MODE} from './constants.mjs';

export default {
  buildDependencies: {
    config: [path.resolve(MB_SERVER_ROOT, 'webpack') + path.sep],
  },
  type: 'filesystem',
  version: (
    WEBPACK_MODE + '-' +
    String(process.env.NODE_ENV) + '-' +
    String(process.env.MODERN_BROWSERS === '1') + '-' +
    String(process.env.MUSICBRAINZ_RUNNING_TESTS)
  ),
};
