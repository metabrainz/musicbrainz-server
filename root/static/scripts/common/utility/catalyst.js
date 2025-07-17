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
  const $c = maybeGetCatalystContext();
  invariant($c, 'Catalyst context not found in GLOBAL_JS_NAMESPACE');
  return $c;
}

export function maybeGetCatalystContext(): ?SanitizedCatalystContextT {
  // $FlowFixMe[prop-missing]
  return globalThis[GLOBAL_JS_NAMESPACE]?.$c;
}

const sourceEntityDataCache:
  WeakMap<CatalystContextT | SanitizedCatalystContextT, RelatableEntityT> =
    new WeakMap();
export function getSourceEntityData<T: RelatableEntityTypeT | void>(
  $c: CatalystContextT | SanitizedCatalystContextT,
  /*
   * Note: `entityType` is optional, but can't be marked with `?`, or else
   * the conditional return type won't work. Flow still allows you to omit
   * the parameter just fine.
   */
  entityType: T,
): T extends void
    ? RelatableEntityT
    : Extract<RelatableEntityT, {+entityType: T, ...}> {
  let source: RelatableEntityT | void = sourceEntityDataCache.get($c);
  if (source === undefined) {
    const sourceData = $c.stash.source_entity;
    invariant(
      sourceData,
      'Source entity data not found in global Catalyst stash',
    );
    if (sourceData.isNewEntity) {
      match (sourceData) {
        {entityType: 'series', ...} => {
          source = createSeriesObject({
            orderingTypeID: parseInt(
              sourceData.orderingTypeID,
              10,
            ) || 1,
          });
        }
        _ => {
          source = createRelatableEntityObject(
            sourceData.entityType,
            {name: sourceData.name ?? ''},
          );
        }
      }
    } else {
      source = sourceData;
    }
    sourceEntityDataCache.set($c, Object.freeze(source));
  }
  if (entityType !== undefined) {
    invariant(
      source.entityType === entityType,
      'Source entity data did not match the expected type, ' +
      JSON.stringify(entityType),
    );
  }
  // $FlowExpectedError[incompatible-type]
  return source;
}
