/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Jed from 'jed';

import nonEmpty from '../static/scripts/common/utility/nonEmpty.js';
import jedData from '../static/scripts/jed-data.mjs';
import invariant from '../utility/invariant.js';

import * as poFile from './gettext/poFile.mjs';

export const jedInstance: Jed = new Jed(jedData.en);
jedInstance.locale = 'en';

export function setLocale(locale: string) {
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
}

export function loadDomain(domain: string) {
  const locale = jedInstance.locale;
  invariant(nonEmpty(locale), 'Expected a locale');
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
}

export const dgettext = (
  domain: string,
  key: string,
): string => jedInstance.dgettext(domain, key);

export const dngettext = (
  domain: string,
  singularKey: string,
  pluralKey: string,
  value: number,
): string => jedInstance.dngettext(
  domain,
  singularKey,
  pluralKey,
  value,
);

export const dpgettext = (
  domain: string,
  context: string,
  key: string,
): string => jedInstance.dpgettext(domain, context, key);
