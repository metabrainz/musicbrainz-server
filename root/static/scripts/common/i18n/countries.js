/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as wrapGettext from './wrapGettext';

const l_countries = wrapGettext.dgettext('countries');
const ln_countries = wrapGettext.dngettext('countries');
const lp_countries = wrapGettext.dpgettext('countries');

export {
  l_countries,
  ln_countries,
  lp_countries,
};
