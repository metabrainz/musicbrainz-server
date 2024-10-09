/*
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import path from 'path';

import MB_SERVER_ROOT from '../root/utility/serverRootDir.mjs';

import {GETTEXT_DOMAINS} from './constants.mjs';

const commonPath =
  path.resolve(MB_SERVER_ROOT, 'root/static/scripts/common/');
const i18nPath = path.resolve(commonPath, 'i18n');
const addColonPath = path.resolve(i18nPath, 'addColon');
const addQuotesPath = path.resolve(i18nPath, 'addQuotes');
const lAdminPath = path.resolve(i18nPath, 'admin');
const lReportsPath = path.resolve(i18nPath, 'reports');
const lStatisticsPath = path.resolve(i18nPath, 'statistics');
const hyphenateTitlePath = path.resolve(i18nPath, 'hyphenateTitle');
const expandPath = path.resolve(i18nPath, 'expand2react');
const expandTextPath = path.resolve(i18nPath, 'expand2text');
const nonEmptyPath = path.resolve(commonPath, 'utility/nonEmpty');
const hydratePath = path.resolve(MB_SERVER_ROOT, 'root/utility/hydrate');
const invariantPath = path.resolve(MB_SERVER_ROOT, 'root/utility/invariant');

const providePluginConfig = {
  'addColon': [addColonPath, 'default'],
  'addColonText': [addColonPath, 'addColonText'],
  'addQuotes': [addQuotesPath, 'default'],
  'addQuotesText': [addQuotesPath, 'addQuotesText'],
  'empty': [nonEmptyPath, 'empty'],
  'hydrate': [hydratePath, 'default'],
  'hyphenateTitle': [hyphenateTitlePath, 'default'],
  'invariant': [invariantPath, 'default'],
  'nonEmpty': [nonEmptyPath, 'default'],

  /* eslint-disable sort-keys */
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

  'l_admin': [lAdminPath, 'l_admin'],

  'exp.l_admin': [expandPath, 'l_admin'],
  'exp.ln_admin': [expandPath, 'ln_admin'],

  'texp.l_admin': [expandTextPath, 'l_admin'],
  'texp.ln_admin': [expandTextPath, 'ln_admin'],

  'l_reports': [lReportsPath, 'l_reports'],

  'N_l_reports': [lReportsPath, 'N_l_reports'],

  'N_l_statistics': [lStatisticsPath, 'N_l_statistics'],
  'N_lp_statistics': [lStatisticsPath, 'N_lp_statistics'],

  'exp.l_reports': [expandPath, 'l_reports'],

  'exp.l_statistics': [expandPath, 'l_statistics'],
  'exp.ln_statistics': [expandPath, 'ln_statistics'],
  'exp.lp_statistics': [expandPath, 'lp_statistics'],

  'texp.l_statistics': [expandTextPath, 'l_statistics'],
  'texp.ln_statistics': [expandTextPath, 'ln_statistics'],
  'texp.lp_statistics': [expandTextPath, 'lp_statistics'],
  /* eslint-enable sort-keys */
};

GETTEXT_DOMAINS.forEach(domain => {
  if (domain === 'mb_server') {
    return;
  }
  const domainPath = path.resolve(i18nPath, domain);
  ['l', 'ln', 'lp'].forEach(func => {
    const domainFunc = func + '_' + domain;
    providePluginConfig[domainFunc] = [domainPath, domainFunc];
  });
});

export default providePluginConfig;
