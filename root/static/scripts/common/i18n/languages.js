/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import wrapGettext from './wrapGettext';

const l_languages = wrapGettext('dgettext', 'languages');
const ln_languages = wrapGettext('dngettext', 'languages');
const lp_languages = wrapGettext('dpgettext', 'languages');

export {
  l_languages,
  ln_languages,
  lp_languages,
};
