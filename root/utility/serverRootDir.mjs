/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import path from 'path';

/*
 * This module exports MB_SERVER_ROOT for cases where the DBDefs module is
 * unavailable; for example, when building production Docker images.
 */

const importMetaUrl = import.meta.url;
if (importMetaUrl == null) {
  throw new Error('import.meta.url is not defined');
}

const MB_SERVER_ROOT: string =
  path.resolve(path.dirname(new URL(importMetaUrl).pathname), '../../');

export default MB_SERVER_ROOT;
