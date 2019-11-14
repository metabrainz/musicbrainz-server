/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const jedData = {
  en: {
    domain: 'mb_server',
    locale_data: {
      attributes: {
        '': {
          domain: 'attributes',
          lang: 'en',
          plural_forms: 'nplurals=2; plural=(n != 1);',
        },
      },
      countries: {
        '': {
          domain: 'countries',
          lang: 'en',
          plural_forms: 'nplurals=2; plural=(n != 1);',
        },
      },
      instrument_descriptions: {
        '': {
          domain: 'instrument_descriptions',
          lang: 'en',
          plural_forms: 'nplurals=2; plural=(n != 1);',
        },
      },
      instruments: {
        '': {
          domain: 'instruments',
          lang: 'en',
          plural_forms: 'nplurals=2; plural=(n != 1);',
        },
      },
      languages: {
        '': {
          domain: 'languages',
          lang: 'en',
          plural_forms: 'nplurals=2; plural=(n != 1);',
        },
      },
      mb_server: {
        '': {
          domain: 'mb_server',
          lang: 'en',
          plural_forms: 'nplurals=2; plural=(n != 1);',
        },
      },
      relationships: {
        '': {
          domain: 'relationships',
          lang: 'en',
          plural_forms: 'nplurals=2; plural=(n != 1);',
        },
      },
      scripts: {
        '': {
          domain: 'scripts',
          lang: 'en',
          plural_forms: 'nplurals=2; plural=(n != 1);',
        },
      },
      statistics: {
        '': {
          domain: 'statistics',
          lang: 'en',
          plural_forms: 'nplurals=2; plural=(n != 1);',
        },
      },
    },
  },
  locale: 'en',
};

function mergeData(domain, lang, newData) {
  if (jedData[lang]) {
    jedData[lang].locale_data[domain] = newData.locale_data[domain];
  } else {
    jedData[lang] = newData;
  }
  jedData.locale = lang;
}

exports.jedData = jedData;
exports.mergeData = mergeData;
