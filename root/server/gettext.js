/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable import/no-commonjs */

const Jed = require('jed');

const jedData = require('../static/scripts/jed-data');
const poFile = require('./gettext/poFile');

const jedInstance/*: Jed */ = new Jed(jedData.en);
jedInstance.locale = 'en';

exports.setLocale = function (locale /*: string */) {
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

  jedInstance.locale = locale;
  jedInstance.options = options;
};

exports.loadDomain = function (domain /*: string */) {
  const locale = jedInstance.locale;
  const localeData = jedInstance.options.locale_data;

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

exports.jedInstance = jedInstance;

exports.dgettext = (
  domain/*: string */,
  key/*: string */,
)/*: string */ => jedInstance.dgettext(domain, key);

exports.dngettext = (
  domain/*: string */,
  singularKey/*: string */,
  pluralKey/*: string */,
  value/*: number */,
)/*: string */ => jedInstance.dngettext(
  domain,
  singularKey,
  pluralKey,
  value,
);

exports.dpgettext = (
  domain/*: string */,
  context/*: string */,
  key/*: string */,
)/*: string */ => jedInstance.dpgettext(domain, context, key);
