/*
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  isModule,
  runSucraseTransform,
} from './sucraseLoader.mjs';

export {
  globalPreload as getGlobalPreloadCode,
} from './sucraseLoader.mjs';

export async function getFormat(url, context, defaultGetFormat) {
  if (await isModule(url)) {
    return {format: 'module'};
  }
  return defaultGetFormat(url, context, defaultGetFormat);
}

export async function transformSource(url, context, defaultTransformSource) {
  if (context.format === 'module') {
    const {source: rawSource} =
      await defaultTransformSource(url, context, defaultTransformSource);
    return {source: runSucraseTransform(rawSource)};
  }
  return defaultTransformSource(url, context, defaultTransformSource);
}
