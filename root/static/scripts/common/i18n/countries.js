/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as wrapGettext from './wrapGettext.js';

export const l_countries: (string) => string =
  wrapGettext.dgettext('countries');

export const ln_countries: (string, string, number) => string =
  wrapGettext.dngettext('countries');

export const lp_countries: (string, string) => string =
  wrapGettext.dpgettext('countries');
