/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import path from 'path';

import MB_SERVER_ROOT from '../root/utility/serverRootDir.mjs';

export const PO_DIR = path.resolve(MB_SERVER_ROOT, 'po');
export const ROOT_DIR = path.resolve(MB_SERVER_ROOT, 'root');
export const STATIC_DIR = path.resolve(ROOT_DIR, 'static');
export const BUILD_DIR = process.env.MBS_STATIC_BUILD_DIR ||
                         path.resolve(STATIC_DIR, 'build');
export const SCRIPTS_DIR = path.resolve(STATIC_DIR, 'scripts');
export const IMAGES_DIR = path.resolve(STATIC_DIR, 'images');

export const WEBPACK_MODE = (typeof process.env.WEBPACK_MODE === 'undefined')
  ? (process.env.NODE_ENV === 'production' ? 'production' : 'development')
  : process.env.WEBPACK_MODE;

export const GETTEXT_DOMAINS = [
  'attributes',
  'countries',
  'history',
  'instrument_descriptions',
  'instruments',
  'languages',
  'mb_server',
  'relationships',
  'scripts',
  'statistics',
];

export const PRODUCTION_MODE = WEBPACK_MODE === 'production';
