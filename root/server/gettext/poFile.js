// Copyright (C) 2015-2018 MetaBrainz Foundation
//
// This file is part of MusicBrainz, the open internet music database,
// and is licensed under the GPL version 2, or (at your option) any
// later version: http://www.gnu.org/licenses/gpl-2.0.txt

const fs = require('fs');
const path = require('path');
const po2json = require('po2json');

const PO_DIR = path.resolve(__dirname, '../../../po');

exports.find = function (domain, locale, ext) {
  let fpath = path.resolve(PO_DIR, `${domain}.${locale}.${ext}`);

  try {
    fs.statSync(fpath);
  } catch (err) {
    if (err.code === 'ENOENT' && /_/.test(locale)) {
      const fallback = fpath.replace(
        new RegExp(`_[a-zA-Z]+\\.${ext}$`),
        `.${ext}`,
      );

      console.warn(`Warning: ${fpath} does not exist, trying ${fallback}`);

      fpath = fallback;
    } else {
      throw err;
    }
  }

  return fpath;
};

exports.load = function (name, locale, domain = name) {
  return po2json.parseFileSync(
    exports.find(name, locale),
    {format: 'jed1.x', domain},
  );
};
