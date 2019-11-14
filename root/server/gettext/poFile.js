// Copyright (C) 2015-2018 MetaBrainz Foundation
//
// This file is part of MusicBrainz, the open internet music database,
// and is licensed under the GPL version 2, or (at your option) any
// later version: http://www.gnu.org/licenses/gpl-2.0.txt

/* eslint-disable import/no-commonjs */

const fs = require('fs');
const path = require('path');

const po2json = require('po2json');

const LOCALE_EXT = new RegExp('_[a-zA-Z]+\\.po$');
const PO_DIR = path.resolve(__dirname, '../../../po');

exports.path = function (domain, locale) {
  return path.resolve(PO_DIR, `${domain}.${locale}.po`);
};

exports.find = function (domain, locale) {
  let fpath = exports.path(domain, locale);

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
};

exports.loadFromPath = function (fpath, domain) {
  return po2json.parseFileSync(fpath, {format: 'jed1.x', domain});
};

exports.load = function (name, locale, domain = name) {
  return exports.loadFromPath(exports.find(name, locale), domain);
};
