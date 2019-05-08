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
  return entityHref(collection, 'collection_collaborator/' + action) +
    entityArg(entity);
}

function hasEntity($c, collection) {
  const containment = $c.stash.containment;
  return !!(containment && containment[collection.id]);
}

type CollectionAddRemoveProps = {|
  +$c: CatalystContextT,
  +collections?: $ReadOnlyArray<CollectionT>,
  +entity: CoreEntityT,
  +noneText: string,
|};

type CollaborativeCollectionListProps = {|
  +collections?: $ReadOnlyArray<CollectionT>,
  +entity: CoreEntityT,
  +noneText: string,
|};

type OwnCollectionListProps = {|
  +addText: string,
  +collections?: $ReadOnlyArray<CollectionT>,
  +entity: CoreEntityT,
  +noneText: string,
|};

type CollectionListProps = {|
  +addCollectionText: string,
  +collaborativeCollections?: $ReadOnlyArray<CollectionT>,
  +collaborativeCollectionsHeader: string,
  +collaborativeCollectionsNoneText: string,
  +entity: CoreEntityT,
  +header: string,
  +ownCollections?: $ReadOnlyArray<CollectionT>,
  +ownCollectionsHeader: string,
  +ownCollectionsNoneText: string,
  +sectionClass: string,
  +usersLink: ReactNode,
|};

const CollectionAddRemove = withCatalystContext(({
  $c,
  collections,
  entity,
  noneText,
}: CollectionAddRemoveProps) => (
  (collections && collections.length) ? (
    collections.map(collection => (
      <li key={collection.id}>
        {hasEntity($c, collection) ? (
          <a href={collectionUrl(collection, entity, 'remove')}>
            {texp.l(
              'Remove from {collection}', {collection: collection.name},
            )}
          </a>
        ) : (
          <a href={collectionUrl(collection, entity, 'add')}>
            {texp.l('Add to {collection}', {collection: collection.name})}
          </a>
        )}
      </li>
    ))
  ) : <li>{noneText}</li>
));

const CollaborativeCollectionList = ({
  collections,
  entity,
  noneText,
}: CollaborativeCollectionListProps) => (
  <ul className="links">
    <CollectionAddRemove
      collections={collections}
      entity={entity}
      noneText={noneText}
    />
  </ul>
);

const OwnCollectionList = ({
  addText,
  collections,
  entity,
  noneText,
}: OwnCollectionListProps) => (
  <ul className="links">
    <CollectionAddRemove
      collections={collections}
      entity={entity}
      noneText={noneText}
    />
    <li>
      <a href={'/collection/create' + entityArg(entity)}>
        {addText}
      </a>
    </li>
  </ul>
);

const CollectionList = ({
  addCollectionText,
  collaborativeCollections,
  collaborativeCollectionsHeader,
  collaborativeCollectionsNoneText,
  entity,
  header,
  ownCollections,
  ownCollectionsHeader,
  ownCollectionsNoneText,
  sectionClass,
  usersLink,
}: CollectionListProps) => (
  <>
    <h2 className={sectionClass}>
      {header}
    </h2>
    <h3>
      {ownCollectionsHeader}
    </h3>
    <OwnCollectionList
      addText={addCollectionText}
      collections={ownCollections}
      entity={entity}
      noneText={ownCollectionsNoneText}
    />
    <li className="separator" role="separator" />
    <h3>
      {collaborativeCollectionsHeader}
    </h3>
    <CollaborativeCollectionList
      collections={collaborativeCollections}
      entity={entity}
      noneText={collaborativeCollectionsNoneText}
    />
    <li className="separator" role="separator" />
    <ul className="links">
      <li>{usersLink}</li>
    </ul>
  </>
);

export default CollectionList;
