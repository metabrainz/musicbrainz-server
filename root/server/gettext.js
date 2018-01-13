// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

'use strict';

const fs = require('fs');
const Gettext = require('node-gettext');
const path = require('path');

const poFile = require('./gettext/poFile');

const EN_HANDLE = new Gettext();
const GETTEXT_HANDLES = {};
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

function loadMoFiles(lang) {
  let gettext = new Gettext();

  TEXT_DOMAINS.forEach(domain => {
    gettext.addTextdomain(
      domain,
      fs.readFileSync(poFile.find(domain, lang, 'mo'))
    );
  });

  GETTEXT_HANDLES[lang] = gettext;
  return gettext;
}

function getHandle(lang) {
  let handle;
  if (!lang) {
    handle = EN_HANDLE;
  } else if (GETTEXT_HANDLES[lang]) {
    handle = GETTEXT_HANDLES[lang] || EN_HANDLE;
  } else if (lang === 'en') {
    handle = EN_HANDLE;
  } else {
    try {
      handle = loadMoFiles(lang);
    } catch (e) {
      console.warn(e);
      GETTEXT_HANDLES[lang] = null;
      handle = EN_HANDLE;
    }
  }
  return handle;
}

exports.loadMoFiles = loadMoFiles;
exports.getHandle = getHandle;
