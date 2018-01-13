// Copyright (C) 2018 MetaBrainz Foundation
//
// This file is part of MusicBrainz, the open internet music database,
// and is licensed under the GPL version 2, or (at your option) any
// later version: http://www.gnu.org/licenses/gpl-2.0.txt

const Jed = require('jed');

const poFile = require('./gettext/poFile');

const gettext = new Jed({});

const TEXT_DOMAINS = [
  'attributes',
  'countries',
  'instrument_descriptions',
  'instruments',
  'languages',
  'mb_server',
  'relationships',
  'scripts',
  'statistics',
];

const jedOptions = {
  en: {
    locale_data: {},
    domain: 'mb_server',
  },
};

TEXT_DOMAINS.forEach(function (domain) {
  jedOptions.en.locale_data[domain] = {
    '': {
      domain,
      lang: 'en',
      plural_forms: 'nplurals=2; plural=(n != 1);',
    },
  };
});

gettext.setLocale = function (locale) {
  let options = jedOptions[locale];

  if (!options) {
    try {
      options = poFile.load('mb_server', locale);
      jedOptions[locale] = options;
    } catch (e) {
      console.warn(e);
      options = jedOptions.en;
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
      localeData[domain] = jedOptions.en.locale_data[domain];
    }
  }
};

gettext.setLocale('en');
gettext.loadDomain('mb_server');

module.exports = gettext;
