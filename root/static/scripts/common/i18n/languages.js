/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as wrapGettext from './wrapGettext.js';

export const l_languages: (string) => string =
  wrapGettext.dgettext('languages');

export const ln_languages: (string, string, number) => string =
  wrapGettext.dngettext('languages');

export const lp_languages: (string, string) => string =
  wrapGettext.dpgettext('languages');
