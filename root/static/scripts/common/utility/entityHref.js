/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';

import {ENTITIES} from '../constants';

import nonEmpty from './nonEmpty';

const leadingSlash = /^\/?(.*)/;

type LinkableEntity =
  | CDStubT
  | CollectionT
  | CoreEntityT
  | EditorT
  | IsrcT
  | IswcT
  | MinimalCoreEntityT
  | SanitizedEditorT;

function entityHref(
  entity: LinkableEntity,
  subPath?: string,
) {
  const entityType = entity.entityType;
  const entityProps = ENTITIES[entityType];
  let href = '/' + entityProps.url + '/';
  let id: string;

  if (entityProps.mbid) {
    id = ko.unwrap((entity: any).gid);
  } else if (entityType === 'isrc' || entityType === 'iswc') {
    id = (entity: any)[entityType];
  } else if (entityType === 'cdstub') {
    id = (entity: any).discid;
  } else {
    id = (entity: any).name;
  }

  href += encodeURIComponent(id);

  if (nonEmpty(subPath)) {
    subPath = subPath.replace(leadingSlash, '$1');
    if (subPath) {
      href += '/' + subPath;
    }
  }

  return href;
}

export default entityHref;
