/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const DBDefs = require('../root/static/scripts/common/DBDefs');

module.exports = {
  dirs: require('./dirs'),
  PUBLIC_PATH: DBDefs.STATIC_RESOURCES_LOCATION + '/',
};
