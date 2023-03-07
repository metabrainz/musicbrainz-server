/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  createRelatableEntityObject,
  createSeriesObject,
} from '../entity2.js';

/*
 * `getCatalystContext` can be used to retrieve the sanitized Catalyst context
 * data stored in the global JS namespace
 * (see root/layout/components/globalsScript.mjs).  This is mainly for use
 * outside of a React component; inside a component you can and should just
 * use the React context (not to be confused with the Catalyst context) API.
 */
export function getCatalystContext(): SanitizedCatalystContextT {
  const $c = window[GLOBAL_JS_NAMESPACE]?.$c;
  invariant($c, 'Catalyst context not found in GLOBAL_JS_NAMESPACE');
  return $c;
}

export function getSourceEntityData():
    | CoreEntityT
    | {
        +entityType: CoreEntityTypeT,
        +isNewEntity: true,
        +name?: string,
        +orderingTypeID?: number,
      }
    | null {
  const $c = getCatalystContext();
  return $c.stash.source_entity ?? null;
}

export function getSourceEntityDataForRelationshipEditor(): CoreEntityT {
  let source = getSourceEntityData();
  invariant(
    source,
    'Source entity data not found in global Catalyst stash',
  );
  if (source.isNewEntity) {
    switch (source.entityType) {
      case 'series': {
        source = createSeriesObject({
          orderingTypeID: parseInt(
            source.orderingTypeID,
            10,
          ) || 1,
        });
        break;
      }
      default: {
        source = createRelatableEntityObject(
          source.entityType,
          {name: source.name ?? ''},
        );
        break;
      }
    }
  }
  return source;
}
