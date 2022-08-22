/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as wrapGettext from './wrapGettext.js';

export const l_instruments: (string) => string =
  wrapGettext.dgettext('instruments');

export const ln_instruments: (string, string, number) => string =
  wrapGettext.dngettext('instruments');

export const lp_instruments: (string, string) => string =
  wrapGettext.dpgettext('instruments');
