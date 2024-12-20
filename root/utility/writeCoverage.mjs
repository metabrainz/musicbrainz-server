/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable import/newline-after-import */
import crypto from 'crypto';
import fs from 'fs';
// $FlowIssue[cannot-resolve-module]
import fsPromises from 'fs/promises';
import path from 'path';

import * as DBDefs from '../static/scripts/common/DBDefs.mjs';

const COVERAGE_DIR = path.resolve(DBDefs.MB_SERVER_ROOT, '.nyc_output');

if (!fs.existsSync(COVERAGE_DIR)) {
  fs.mkdirSync(COVERAGE_DIR);
}

export default async function writeCoverage(
  fileName: string,
  coverageString: string,
): Promise<void> {
  const uniqueExt = crypto.randomBytes(8).toString('hex');
  const coverageFileName = `${fileName}-${uniqueExt}.json`;
  const fd = await fsPromises.open(
    path.resolve(COVERAGE_DIR, coverageFileName),
    'w',
    0o755,
  );
  await fsPromises.writeFile(fd, coverageString);
  await fd.close();
}
