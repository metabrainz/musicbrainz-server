/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as Sentry from '@sentry/browser';

import {MAX_RECENT_ENTITIES} from '../../constants.js';
import localizeLanguageName from '../../i18n/localizeLanguageName.js';
import linkedEntities from '../../linkedEntities.mjs';
import isDatabaseRowId from '../../utility/isDatabaseRowId.js';
import isGuid from '../../utility/isGuid.js';
import {localStorage} from '../../utility/storage.js';

import {formatLinkTypePhrases} from './formatters.js';
import type {
  EntityItemT,
  OptionItemT,
} from './types.js';

/*
 * `entityTypeKey` is typically just the entity type.
 *
 * An example where this is not the case is the relationship type
 * autocomplete in the relationship editor. The entity type would be
 * 'link_type' there, but we don't want to mix recent link types for
 * artists with recent link types for areas, for example, so we'd
 * instead use keys of the form 'link_type-artist'.
 */
type RecentEntitiesT = {[entityTypeKey: string]: mixed};

type WsJsEntitiesDataT<+T: EntityItemT> = {
  +results: {+[id: string]: ?T},
};

function _getStoredMap(): RecentEntitiesT {
  const recentEntitiesJson = localStorage('recentAutocompleteEntities');
  if (nonEmpty(recentEntitiesJson)) {
    try {
      const recentEntities = JSON.parse(recentEntitiesJson);
      if (recentEntities && typeof recentEntities === 'object') {
        return recentEntities;
      }
    } catch (e) {
      Sentry.captureException(e);
    }
  }
  return {};
}

function _getGidOrId(object: {...}): string | null {
  if (hasOwnProp(object, 'gid')) {
    // $FlowIgnore[prop-missing]
    const gid = object.gid;
    if (typeof gid === 'string') {
      return gid;
    }
  }
  if (hasOwnProp(object, 'id')) {
    // $FlowIgnore[prop-missing]
    const id = object.id;
    /*
     * This shouldn't check `isDatabaseRowId`, because we want pending
     * entities (e.g. batch-created works in the release relationship editor)
     * to appear in the list.  We do filter these out before saving them to
     * localStorage.
     */
    if (typeof id === 'number') {
      return String(id);
    }
  }
  return null;
}

function _getRecentEntityIds(
  key: string,
): Set<string> {
  const ids: Set<string> = new Set();
  const storedMap = _getStoredMap();
  const storedValueList = storedMap[key];

  if (storedValueList != null && Array.isArray(storedValueList)) {
    for (const value of storedValueList) {
      /*
       * We previously stored recent entities in their entirety, as
       * JSON objects, but that caused issues when the expected
       * format changed from what was stored. This is why we now
       * only deal with MBIDs and fetch those from the web service
       * instead.
       */
      switch (typeof value) {
        case 'object': {
          if (value) {
            const id = _getGidOrId(value);
            if (id != null) {
              ids.add(id);
            }
          }
          break;
        }
        case 'string': {
          ids.add(value);
          break;
        }
      }
      if (ids.size >= MAX_RECENT_ENTITIES) {
        break;
      }
    }
  }

  return ids;
}

function _filterFakeIds(
  ids: Set<string>,
): $ReadOnlyArray<string> {
  /*
   * Some of the recent item IDs may actually be pending entities
   * (e.g. batch-created works in the release relationship editor).
   * Filter out the fake IDs from real ones.
   */
  const validIds = [];
  for (const id of ids) {
    if (isGuid(id) || isDatabaseRowId(+id)) {
      validIds.push(id);
    }
  }
  return validIds;
}

function _setRecentEntityIds(
  key: string,
  ids: Set<string> | null,
): void {
  const storedMap = _getStoredMap();
  storedMap[key] = ids ? _filterFakeIds(ids) : [];

  localStorage(
    'recentAutocompleteEntities',
    JSON.stringify(storedMap),
  );
}

export function clearRecentItems(
  key: string,
): void {
  _setRecentEntityIds(key, null);
  _recentItemsCache.set(key, []);
}

const _recentItemsCache =
  new Map<string, $ReadOnlyArray<OptionItemT<EntityItemT>>>();

export function getRecentItems<+T: EntityItemT>(
  key: string,
): $ReadOnlyArray<OptionItemT<T>> {
  // $FlowIgnore[incompatible-return]
  return _recentItemsCache.get(key) ?? [];
}

function getEntityName(
  entity: EntityItemT,
  isLanguageForWorks?: boolean,
): string {
  switch (entity.entityType) {
    case 'language': {
      return localizeLanguageName(entity, isLanguageForWorks);
    }
    case 'link_type': {
      return formatLinkTypePhrases(entity);
    }
    default: {
      return entity.name;
    }
  }
}

export async function getOrFetchRecentItems<+T: EntityItemT>(
  entityType: string,
  key?: string = entityType,
): Promise<$ReadOnlyArray<OptionItemT<T>>> {
  const ids = _getRecentEntityIds(key);
  const cachedList: Array<OptionItemT<T>> = [...getRecentItems<T>(key)];

  _recentItemsCache.set(key, cachedList);

  for (const item of cachedList) {
    const id = _getGidOrId(item.entity);
    if (id != null) {
      ids.delete(id);
    }
  }

  if (ids.size) {
    const isLanguageForWorks = key === 'language-lyrics';

    // Convert ids to an array since we delete in the loop.
    for (const id of Array.from(ids)) {
      const entity: ?T = linkedEntities[entityType]?.[id];
      if (entity) {
        cachedList.push({
          entity: entity,
          id: String(entity.id) + '-recent',
          name: getEntityName(entity, isLanguageForWorks),
          type: 'option',
        });
        ids.delete(id);
      }
    }
  }

  if (ids.size) {
    const rowIds = _filterFakeIds(ids);
    if (rowIds.length) {
      return fetch(
        '/ws/js/entities/' +
        entityType + '/' +
        rowIds.join('+'),
      ).then((resp) => {
        if (!resp.ok) {
          return null;
        }
        return resp.json();
      }).then((data: WsJsEntitiesDataT<T> | null) => {
        if (!data) {
          return cachedList;
        }

        const results = data.results;

        for (const id of ids) {
          const entity = results[id];
          if (entity && entity.entityType === entityType) {
            cachedList.push({
              entity,
              id: String(entity.id) + '-recent',
              name: getEntityName(entity),
              type: 'option',
            });
          }
        }

        return cachedList;
      });
    }
  }

  return Promise.resolve(cachedList);
}

export function pushRecentItem<+T: EntityItemT>(
  item: OptionItemT<T>,
  key?: string = item.entity.entityType,
): $ReadOnlyArray<OptionItemT<T>> {
  const entity = item.entity;
  const entityId = _getGidOrId(entity);

  const cachedList: Array<OptionItemT<T>> = [...getRecentItems<T>(key)];
  _recentItemsCache.set(key, cachedList);

  if (entityId == null) {
    return cachedList;
  }

  // Push this MBID/ID to the top of the list.
  const ids = new Set([entityId]);

  for (const prevId of _getRecentEntityIds(key)) {
    ids.add(prevId);
    if (ids.size >= MAX_RECENT_ENTITIES) {
      break;
    }
  }

  _setRecentEntityIds(key, ids);

  const itemCopy = {
    ...item,
    id: String(item.entity.id) + '-recent',
  };
  /*
   * The recent items are displayed as a flat list. If there's a tree
   * hierarchy, it wouldn't make sense here, so we should remove any
   * `level`. There probably wouldn't have been a separator on an
   * entity option, but strip that too just in case.
   */
  delete itemCopy.level;
  delete itemCopy.separator;

  if (cachedList.length) {
    const existingIndex = cachedList.findIndex((otherItem) => (
      entityId === _getGidOrId(otherItem.entity)
    ));

    if (existingIndex >= 0) {
      cachedList.splice(existingIndex, 1);
    }
    cachedList.unshift(itemCopy);

    if (cachedList.length > MAX_RECENT_ENTITIES) {
      cachedList.splice(
        MAX_RECENT_ENTITIES,
        cachedList.length - MAX_RECENT_ENTITIES,
      );
    }
  } else {
    cachedList.push(itemCopy);
  }

  return cachedList;
}
