/* Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import wrapGettext from './wrapGettext';

const l_instrument_descriptions = wrapGettext('dgettext', 'instrument_descriptions');
const ln_instrument_descriptions = wrapGettext('dngettext', 'instrument_descriptions');
const lp_instrument_descriptions = wrapGettext('dpgettext', 'instrument_descriptions');

export {
  l_instrument_descriptions,
  ln_instrument_descriptions,
  lp_instrument_descriptions,
};
