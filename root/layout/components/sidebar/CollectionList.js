/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';
import type {Node as ReactNode} from 'react';

import {withCatalystContext} from '../../../context';
import entityHref from '../../../static/scripts/common/utility/entityHref';

function entityArg(entity) {
  return '?' + entity.entityType + '=' +
    encodeURIComponent(String(entity.id));
}

function collectionUrl(collection, entity, action) {
  return entityHref(collection, 'own_collection/' + action) +
    entityArg(entity);
}

function hasEntity($c, collection) {
  const containment = $c.stash.containment;
  return !!(containment && containment[collection.id]);
}

type Props = {|
  +$c: CatalystContextT,
  +addText: string,
  +entity: CoreEntityT,
  +noneText: string,
  +usersLink: ReactNode,
|};

const CollectionList = ({
  $c,
  addText,
  entity,
  noneText,
  usersLink,
}: Props) => (
  <ul className="links">
    {($c.stash.collections && $c.stash.collections.length) ? (
      $c.stash.collections.map(collection => (
        <li key={collection.id}>
          {hasEntity($c, collection) ? (
            <a href={collectionUrl(collection, entity, 'remove')}>
              {texp.l('Remove from {collection}', {collection: collection.name})}
            </a>
          ) : (
            <a href={collectionUrl(collection, entity, 'add')}>
              {texp.l('Add to {collection}', {collection: collection.name})}
            </a>
          )}
        </li>
      ))
    ) : <li>{noneText}</li>}
    <li>
      <a href={'/collection/create' + entityArg(entity)}>
        {addText}
      </a>
    </li>
    <li>{usersLink}</li>
  </ul>
);

export default withCatalystContext(CollectionList);
