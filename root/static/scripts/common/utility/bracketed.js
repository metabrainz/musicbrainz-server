// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const {l} = require('../i18n');

function bracketed(text) {
  if (text) {
    return l(' ({text})', {text});
  }
  return '';
}

module.exports = bracketed;
