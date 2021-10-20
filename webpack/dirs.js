/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable import/no-commonjs */

const path = require('path');

const CHECKOUT_DIR = path.resolve(__dirname, '..');
const PO_DIR = path.resolve(CHECKOUT_DIR, 'po');
const ROOT_DIR = path.resolve(CHECKOUT_DIR, 'root');
const STATIC_DIR = path.resolve(ROOT_DIR, 'static');
const BUILD_DIR = process.env.MBS_STATIC_BUILD_DIR ||
                  path.resolve(STATIC_DIR, 'build');
const SCRIPTS_DIR = path.resolve(STATIC_DIR, 'scripts');
const IMAGES_DIR = path.resolve(STATIC_DIR, 'images');

module.exports = {
  BUILD: BUILD_DIR,
  CHECKOUT: CHECKOUT_DIR,
  IMAGES: IMAGES_DIR,
  PO: PO_DIR,
  ROOT: ROOT_DIR,
  SCRIPTS: SCRIPTS_DIR,
  STATIC: STATIC_DIR,
};
