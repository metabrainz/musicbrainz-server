// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

'use strict';

import fs from 'fs';
import path from 'path';
import Gettext from 'node-gettext';

const EN_HANDLE = new Gettext();
const GETTEXT_HANDLES = new Map();
const PO_DIR = path.resolve(__dirname, '../../po');

const TEXT_DOMAINS = [
  //'attributes',
  //'countries',
  //'instrument_descriptions',
  //'instruments',
  //'languages',
  'mb_server',
  //'relationships',
  //'scripts',
  //'statistics',
];

export function findObjectFile(domain, lang, ext) {
  let fpath = path.resolve(PO_DIR, `${domain}.${lang}.${ext}`);

  try {
    fs.statSync(fpath);
  } catch (err) {
    if (err.code === 'ENOENT' && /_/.test(lang)) {
      let fallback = fpath.replace(new RegExp(`_[a-zA-Z]+\\.${ext}$`), `.${ext}`);

      console.warn(`Warning: ${fpath} does not exist, trying ${fallback}`);

      fpath = fallback;
    } else {
      throw err;
    }
  }

  return fpath;
}

export function loadMoFiles(lang) {
  let gettext = new Gettext();

  TEXT_DOMAINS.forEach(domain => {
    gettext.addTextdomain(
      domain,
      fs.readFileSync(findObjectFile(domain, lang, 'mo'))
    );
  });

  GETTEXT_HANDLES.set(lang, gettext);
  return gettext;
}

export function getHandle(lang) {
  let handle;
  if (!lang) {
    handle = EN_HANDLE;
  } else if (GETTEXT_HANDLES.has(lang)) {
    handle = GETTEXT_HANDLES.get(lang) || EN_HANDLE;
  } else if (lang === 'en') {
    handle = EN_HANDLE;
  } else {
    try {
      handle = loadMoFiles(lang);
    } catch (e) {
      console.warn(e);
      GETTEXT_HANDLES.set(lang, null);
      handle = EN_HANDLE;
    }
  }
  return handle;
}

export function clearHandles() {
  GETTEXT_HANDLES.clear();
}
