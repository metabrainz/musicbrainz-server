// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2017 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const reload = require('require-reload')(require);

const DBDefs = Object.create(null);

DBDefs.reload = function () {
  const newDefs = reload('../static/scripts/common/DBDefs');

  let key;
  for (key in this) {
    if (key !== 'reload') {
      delete this[key];
    }
  }

  for (key in newDefs) {
    this[key] = newDefs[key];
  }
};

DBDefs.reload();

module.exports = DBDefs;
