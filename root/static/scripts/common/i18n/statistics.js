/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as wrapGettext from './wrapGettext.js';

export const l_statistics: (string) => string =
  wrapGettext.dgettext('statistics');

export const ln_statistics: (string, string, number) => string =
  wrapGettext.dngettext('statistics');

export const lp_statistics: (string, string) => string =
  wrapGettext.dpgettext('statistics');

export const N_l_statistics = (key: string): (() => string) => (
  () => l_statistics(key)
);
