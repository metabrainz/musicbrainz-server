/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {CatalystContext} from '../../../context.mjs';
import typeof EntityLink
  from '../../../static/scripts/common/components/EntityLink.js';
import entityHref from '../../../static/scripts/common/utility/entityHref.js';
import {returnToCurrentPage} from '../../../utility/returnUri.js';

function entityArg(entity: CollectableEntityT) {
  return '?' + entity.entityType + '=' +
    encodeURIComponent(String(entity.id));
}

function collectionUrl(
  $c: CatalystContextT,
  collection: CollectionT,
  entity: CollectableEntityT,
  action: string,
) {
  return entityHref(collection, 'collection_collaborator/' + action) +
    entityArg(entity) +
    '&' + returnToCurrentPage($c);
}

function hasEntity(
  $c: CatalystContextT,
  collection: CollectionT,
) {
  const containment = $c.stash.containment;
  return !!(containment && containment[collection.id]);
}

component CollectionAddRemove(
  collections?: $ReadOnlyArray<CollectionT>,
  entity: CollectableEntityT,
  noneText?: string,
) {
  return (
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
                  {texp.l('Add to {collection}',
                          {collection: collection.name})}
                </a>
              )
            )}
          </CatalystContext.Consumer>
        </li>
      ))
    ) : <li>{noneText}</li>
  );
}

component CollaborativeCollectionList(
  collections?: $ReadOnlyArray<CollectionT>,
  entity: CollectableEntityT,
) {
  return (
    <ul className="links">
      <CollectionAddRemove
        collections={collections}
        entity={entity}
      />
      <li className="separator" role="separator" />
    </ul>
  );
}

component OwnCollectionList(
  addText: string,
  collections?: $ReadOnlyArray<CollectionT>,
  entity: CollectableEntityT,
  noneText: string,
) {
  return (
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
      <li className="separator" role="separator" />
    </ul>
  );
}

component CollectionList(
  addCollectionText: string,
  collaborativeCollections?: $ReadOnlyArray<CollectionT>,
  collaborativeCollectionsHeader: string,
  entity: CollectableEntityT,
  header: string,
  ownCollections?: $ReadOnlyArray<CollectionT>,
  ownCollectionsHeader: string,
  ownCollectionsNoneText: string,
  sectionClass: string,
  userExists: boolean,
  usersLink: React$Element<EntityLink>,
  usersLinkHeader: string,
) {
  return (
    <>
      <h2 className={sectionClass}>
        {header}
      </h2>
      {userExists ? (
        <>
          <h3>
            {ownCollectionsHeader}
          </h3>
          <OwnCollectionList
            addText={addCollectionText}
            collections={ownCollections}
            entity={entity}
            noneText={ownCollectionsNoneText}
          />
          {collaborativeCollections?.length ? (
            <>
              <h3>
                {collaborativeCollectionsHeader}
              </h3>
              <CollaborativeCollectionList
                collections={collaborativeCollections}
                entity={entity}
              />
            </>
          ) : null}
          <h3>
            {usersLinkHeader}
          </h3>
        </>
      ) : null}
      <ul className="links">
        <li>{usersLink}</li>
      </ul>
    </>
  );
}

export default CollectionList;
