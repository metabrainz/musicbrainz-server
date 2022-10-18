/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as wrapGettext from './wrapGettext.js';

export const l_instrument_descriptions: (string) => string =
  wrapGettext.dgettext('instrument_descriptions');

export const ln_instrument_descriptions: (string, string, number) => string =
  wrapGettext.dngettext('instrument_descriptions');

export const lp_instrument_descriptions: (string, string) => string =
  wrapGettext.dpgettext('instrument_descriptions');
