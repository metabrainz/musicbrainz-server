/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import path from 'path';

import {
  MB_SERVER_ROOT,
} from '../root/static/scripts/common/DBDefs.js';

const PO_DIR = path.resolve(MB_SERVER_ROOT, 'po');
const ROOT_DIR = path.resolve(MB_SERVER_ROOT, 'root');
const STATIC_DIR = path.resolve(ROOT_DIR, 'static');
const BUILD_DIR = process.env.MBS_STATIC_BUILD_DIR ||
                  path.resolve(STATIC_DIR, 'build');
const SCRIPTS_DIR = path.resolve(STATIC_DIR, 'scripts');
const IMAGES_DIR = path.resolve(STATIC_DIR, 'images');

export default {
  BUILD: BUILD_DIR,
  CHECKOUT: MB_SERVER_ROOT,
  IMAGES: IMAGES_DIR,
  PO: PO_DIR,
  ROOT: ROOT_DIR,
  SCRIPTS: SCRIPTS_DIR,
  STATIC: STATIC_DIR,
};
