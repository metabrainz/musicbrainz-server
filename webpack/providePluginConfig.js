/*
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const path = require('path');

const {GETTEXT_DOMAINS} = require('./constants');

const commonPath = path.resolve(__dirname, '../root/static/scripts/common/');
const i18nPath = path.resolve(commonPath, 'i18n');
const addColonPath = path.resolve(i18nPath, 'addColon');
const hyphenateTitlePath = path.resolve(i18nPath, 'hyphenateTitle');
const expandPath = path.resolve(i18nPath, 'expand2react');
const expandTextPath = path.resolve(i18nPath, 'expand2text');
const hasOwnPropPath = path.resolve(commonPath, 'utility/hasOwnProp');
const nonEmptyPath = path.resolve(commonPath, 'utility/nonEmpty');
const invariantPath = path.resolve(__dirname, '../root/utility/invariant');

module.exports = {
  'addColon': [addColonPath, 'default'],
  'addColonText': [addColonPath, 'addColonText'],
  'hasOwnProp': [hasOwnPropPath, 'default'],
  'hyphenateTitle': [hyphenateTitlePath, 'default'],
  'invariant': [invariantPath, 'default'],
  'nonEmpty': [nonEmptyPath, 'default'],

  'l': [i18nPath, 'l'],
  'ln': [i18nPath, 'ln'],
  'lp': [i18nPath, 'lp'],

  'N_l': [i18nPath, 'N_l'],
  'N_ln': [i18nPath, 'N_ln'],
  'N_lp': [i18nPath, 'N_lp'],

  'exp.l': [expandPath, 'l'],
  'exp.ln': [expandPath, 'ln'],
  'exp.lp': [expandPath, 'lp'],

  'texp.l': [expandTextPath, 'l'],
  'texp.ln': [expandTextPath, 'ln'],
  'texp.lp': [expandTextPath, 'lp'],
};

GETTEXT_DOMAINS.forEach(domain => {
  if (domain === 'mb_server') {
    return;
  }
  const domainPath = path.resolve(i18nPath, domain);
  ['l', 'ln', 'lp'].forEach(func => {
    const domainFunc = func + '_' + domain;
    module.exports[domainFunc] = [domainPath, domainFunc];
  });
});
