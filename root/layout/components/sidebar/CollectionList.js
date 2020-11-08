/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../../context';
import typeof EntityLink
  from '../../../static/scripts/common/components/EntityLink';
import entityHref from '../../../static/scripts/common/utility/entityHref';
import {returnToCurrentPage} from '../../../utility/returnUri';

function entityArg(entity) {
  return '?' + entity.entityType + '=' +
    encodeURIComponent(String(entity.id));
}

function collectionUrl($c, collection, entity, action) {
  return entityHref(collection, 'collection_collaborator/' + action) +
    entityArg(entity) +
    '&' + returnToCurrentPage($c);
}

function hasEntity($c, collection) {
  const containment = $c.stash.containment;
  return !!(containment && containment[collection.id]);
}

type CollectionAddRemoveProps = {
  +collections?: $ReadOnlyArray<CollectionT>,
  +entity: CoreEntityT,
  +noneText?: string,
};

type CollaborativeCollectionListProps = {
  +collections?: $ReadOnlyArray<CollectionT>,
  +entity: CoreEntityT,
};

type OwnCollectionListProps = {
  +addText: string,
  +collections?: $ReadOnlyArray<CollectionT>,
  +entity: CoreEntityT,
  +noneText: string,
};

type CollectionListProps = {
  +addCollectionText: string,
  +collaborativeCollections?: $ReadOnlyArray<CollectionT>,
  +collaborativeCollectionsHeader: string,
  +entity: CoreEntityT,
  +header: string,
  +ownCollections?: $ReadOnlyArray<CollectionT>,
  +ownCollectionsHeader: string,
  +ownCollectionsNoneText: string,
  +sectionClass: string,
  +usersLink: React.Element<EntityLink>,
  +usersLinkHeader: string,
};

const CollectionAddRemove = ({
  collections,
  entity,
  noneText,
}: CollectionAddRemoveProps) => (
  collections?.length ? (
    collections.map(collection => (
      <li key={collection.id}>
        <CatalystContext.Consumer>
          {$c => (
            hasEntity($c, collection) ? (
              <a href={collectionUrl($c, collection, entity, 'remove')}>
                {texp.l(
                  'Remove from {collection}', {collection: collection.name},
                )}
              </a>
            ) : (
              <a href={collectionUrl($c, collection, entity, 'add')}>
                {texp.l('Add to {collection}', {collection: collection.name})}
              </a>
            )
          )}
        </CatalystContext.Consumer>
      </li>
    ))
  ) : <li>{noneText}</li>
);

const CollaborativeCollectionList = ({
  collections,
  entity,
}: CollaborativeCollectionListProps) => (
  <ul className="links">
    <CollectionAddRemove
      collections={collections}
      entity={entity}
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
  entity,
  header,
  ownCollections,
  ownCollectionsHeader,
  ownCollectionsNoneText,
  sectionClass,
  usersLink,
  usersLinkHeader,
}: CollectionListProps): React.MixedElement => (
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
    {collaborativeCollections?.length ? (
      <>
        <h3>
          {collaborativeCollectionsHeader}
        </h3>
        <CollaborativeCollectionList
          collections={collaborativeCollections}
          entity={entity}
        />
        <li className="separator" role="separator" />
      </>
    ) : null}
    <h3>
      {usersLinkHeader}
    </h3>
    <ul className="links">
      <li>{usersLink}</li>
    </ul>
  </>
);

export default CollectionList;
