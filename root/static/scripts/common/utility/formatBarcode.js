// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2017 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const {l} = require('../i18n');

function formatBarcode(code) {
  if (code == null) {
    return '';
  }
  if (code === '') {
    return l('[none]');
  }
  return code;
}

module.exports = formatBarcode;
