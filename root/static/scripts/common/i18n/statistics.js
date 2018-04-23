/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import wrapGettext from './wrapGettext';

const l_statistics = wrapGettext('dgettext', 'statistics');
const ln_statistics = wrapGettext('dngettext', 'statistics');
const lp_statistics = wrapGettext('dpgettext', 'statistics');

export {
  l_statistics,
  ln_statistics,
  lp_statistics,
};
