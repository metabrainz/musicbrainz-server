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
  | {+discid: string, +entityType: 'cdtoc', ...}
  | {+discid: string, +entityType: 'cdstub', ...}
  | {+entityType: 'editor', +name: string, ...}
  | {+entityType: 'isrc', +isrc: string, ...}
  | {+entityType: 'iswc', +iswc: string, ...}
  | {+entityType: CoreEntityTypeT, +gid: string, ...}
  | {+entityType: 'collection', +gid: string, ...}
  | {+entityType: 'link_type', +gid: string, ...};

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

  switch (entity.entityType) {
    case 'isrc':
      id = entity.isrc;
      break;

    case 'iswc':
      id = entity.iswc;
      break;

    case 'cdstub':
    case 'cdtoc':
      id = entity.discid;
      break;

    case 'editor':
      id = entity.name;
      break;

    default:
      if (entityProps.mbid && entity.gid) {
        id = ko.unwrap(entity.gid);
      }
  }

  return generateHref(path, id, subPath, anchorPath);
}

export default entityHref;
