/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as wrapGettext from './wrapGettext';

const l_scripts = wrapGettext.dgettext('scripts');
const ln_scripts = wrapGettext.dngettext('scripts');
const lp_scripts = wrapGettext.dpgettext('scripts');

export {
  l_scripts,
  ln_scripts,
  lp_scripts,
};
