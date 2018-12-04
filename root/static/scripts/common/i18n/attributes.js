// Copyright (C) 2018 MetaBrainz Foundation
//
// This file is part of MusicBrainz, the open internet music database,
// and is licensed under the GPL version 2, or (at your option) any
// later version: http://www.gnu.org/licenses/gpl-2.0.txt

import wrapGettext from './wrapGettext';

const l_attributes = wrapGettext('dgettext', 'attributes');
const ln_attributes = wrapGettext('dngettext', 'attributes');
const lp_attributes = wrapGettext('dpgettext', 'attributes');

export {
  l_attributes,
  ln_attributes,
  lp_attributes,
};
