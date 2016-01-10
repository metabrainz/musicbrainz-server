// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const entityLink = require('./entityLink');
const {commaOnlyList} = require('../../common/i18n');

function areaContainmentLink(area) {
  return commaOnlyList(area.containment.map(entityLink));
}

module.exports = areaContainmentLink;
