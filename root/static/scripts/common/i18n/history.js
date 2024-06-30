/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as wrapGettext from './wrapGettext.js';

export const l_history: (string) => string =
  wrapGettext.dgettext('history');

export const ln_history: (string, string, number) => string =
  wrapGettext.dngettext('history');

export const lp_history: (string, string) => string =
  wrapGettext.dpgettext('history');

export const N_l_history = (key: string): (() => string) => (
  () => l_history(key)
);

export const N_lp_history = (
  key: string,
  context: string,
// eslint-disable-next-line function-paren-newline -- likely eslint bug
): (() => string) => (
  () => lp_history(key, context)
);
