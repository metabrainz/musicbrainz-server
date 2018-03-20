/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import wrapGettext from './wrapGettext';

const l_relationships = wrapGettext('dgettext', 'relationships');
const ln_relationships = wrapGettext('dngettext', 'relationships');
const lp_relationships = wrapGettext('dpgettext', 'relationships');

export {
  l_relationships,
  ln_relationships,
  lp_relationships,
};
