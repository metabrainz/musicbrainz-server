/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';

import {ENTITIES} from '../constants.js';

const leadingSlash = /^\/?(.*)/;

type LinkableEntity =
  | {readonly discid: string, readonly entityType: 'cdtoc', ...}
  | {readonly discid: string, readonly entityType: 'cdstub', ...}
  | {readonly entityType: 'editor', readonly name: string, ...}
  | {readonly entityType: 'isrc', readonly isrc: string, ...}
  | {readonly entityType: 'iswc', readonly iswc: string, ...}
  | {readonly entityType: RelatableEntityTypeT, readonly gid: string, ...}
  | {readonly entityType: 'collection', readonly gid: string, ...}
  | {readonly entityType: 'link_type', readonly gid: string, ...}
  | {readonly entityType: 'track', readonly gid?: string, ...};

function generateHref(
  path: string,
  id: string,
  subPath: ?string,
  anchorPath?: string,
) {
  let href = '/' + path + '/';
  href += encodeURIComponent(id);

  if (nonEmpty(subPath)) {
    const cleanedSubPath = subPath.replace(leadingSlash, '$1');
    if (cleanedSubPath) {
      href += '/' + cleanedSubPath;
    }
  }

  if (nonEmpty(anchorPath)) {
    if (anchorPath) {
      href += '#' + anchorPath;
    }
  }

  return href;
}

export function editHref(
  edit: GenericEditWithIdT,
  subPath?: string,
): string {
  if (edit.id == null) {
    throw new Error(`An edit missing an ID was passed.
                     Ensure you are not using this on a preview.`);
  }
  return generateHref('edit', edit.id.toString(), subPath);
}

function entityHref(
  entity: LinkableEntity,
  subPath?: string,
  anchorPath?: string,
): string {
  const entityProps = ENTITIES[entity.entityType];
  const path = entityProps.url;
  let id = '';

  match (entity) {
    {entityType: 'isrc', const isrc, ...} => {
      id = isrc;
    }
    {entityType: 'iswc', const iswc, ...} => {
      id = iswc;
    }
    {entityType: 'cdstub' | 'cdtoc', const discid, ...} => {
      id = discid;
    }
    {entityType: 'editor', const name, ...} => {
      id = name;
    }
    _ as entity => {
      if (entityProps.mbid && nonEmpty(entity.gid)) {
        id = ko.unwrap(entity.gid);
      }
    }
  }

  return generateHref(path, id, subPath, anchorPath);
}

export default entityHref;
