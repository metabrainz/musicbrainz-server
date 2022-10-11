/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as wrapGettext from './wrapGettext.js';

export const l_scripts: (string) => string =
  wrapGettext.dgettext('scripts');

export const ln_scripts: (string, string, number) => string =
  wrapGettext.dngettext('scripts');

export const lp_scripts: (string, string) => string =
  wrapGettext.dpgettext('scripts');
