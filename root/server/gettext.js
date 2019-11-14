// Copyright (C) 2018 MetaBrainz Foundation
//
// This file is part of MusicBrainz, the open internet music database,
// and is licensed under the GPL version 2, or (at your option) any
// later version: http://www.gnu.org/licenses/gpl-2.0.txt

/* eslint-disable import/no-commonjs */

const Jed = require('jed');

const {jedData} = require('../static/scripts/jed-data');

const poFile = require('./gettext/poFile');

const gettext = new Jed({});

gettext.setLocale = function (locale) {
  let options = jedData[locale];

  if (!options) {
    try {
      options = poFile.load('mb_server', locale);
      jedData[locale] = options;
    } catch (e) {
      console.warn(e);
      options = jedData.en;
    }
  }

  gettext.locale = locale;
  gettext.options = options;
};

gettext.loadDomain = function (domain) {
  const locale = gettext.locale;
  const localeData = gettext.options.locale_data;

  if (!localeData[domain]) {
    try {
      Object.assign(
        localeData,
        poFile.load(domain, locale).locale_data,
      );
    } catch (e) {
      console.warn(e);
      localeData[domain] = jedData.en.locale_data[domain];
    }
  }
};

gettext.setLocale('en');
gettext.loadDomain('mb_server');

module.exports = gettext;
