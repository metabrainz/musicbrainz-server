/*
 * Copyright (C) 2015-2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import fs from 'fs';
import path from 'path';

import po2json from 'po2json';

import MB_SERVER_ROOT from '../../utility/serverRootDir.mjs';

const LOCALE_EXT = new RegExp('_[a-zA-Z]+\\.po$');
const PO_DIR = path.resolve(MB_SERVER_ROOT, 'po');

function getPath(domain, locale) {
  return path.resolve(PO_DIR, `${domain}.${locale}.po`);
}

export function find(domain, locale) {
  let fpath = getPath(domain, locale);

  try {
    fs.statSync(fpath);
  } catch (err) {
    if (err.code === 'ENOENT' && /_/.test(locale)) {
      const fallback = fpath.replace(LOCALE_EXT, '.po');

      console.warn(`Warning: ${fpath} does not exist, trying ${fallback}`);

      fpath = fallback;
    } else {
      throw err;
    }
  }

  return fpath;
}

export function loadFromPath(fpath, domain) {
  return po2json.parseFileSync(fpath, {format: 'jed1.x', domain});
}

export function load(name, locale, domain = name) {
  return loadFromPath(find(name, locale), domain);
}
