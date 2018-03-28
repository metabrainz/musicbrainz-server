/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import wrapGettext from './wrapGettext';

const l_instruments = wrapGettext('dgettext', 'instruments');
const ln_instruments = wrapGettext('dngettext', 'instruments');
const lp_instruments = wrapGettext('dpgettext', 'instruments');

export {
  l_instruments,
  ln_instruments,
  lp_instruments,
};
