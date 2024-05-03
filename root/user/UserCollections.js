/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import type {ColumnOptions} from 'react-table';

import UserAccountLayout, {type AccountLayoutUserT}
  from '../components/UserAccountLayout.js';
import {SanitizedCatalystContext} from '../context.mjs';
import useTable from '../hooks/useTable.js';
import {formatPluralEntityTypeName}
  from '../static/scripts/common/utility/formatEntityTypeName.js';
import {
  defineActionsColumn,
  defineNameColumn,
  defineTypeColumn,
  subscriptionColumn,
} from '../utility/tableColumns.js';

type CollectionWithSubscribedT = $ReadOnly<{
  ...CollectionT,
  subscribed: boolean,
}>;

type CollectionListT = {
  +[entityType: string]: $ReadOnlyArray<CollectionWithSubscribedT>,
};

const collectionsListTitles = {
  area: N_l('Area collections'),
  artist: N_l('Artist collections'),
  event: N_l('Event collections'),
  instrument: N_l('Instrument collections'),
  label: N_l('Label collections'),
  place: N_l('Place collections'),
  recording: N_l('Recording collections'),
  release: N_l('Release collections'),
  release_group: N_l('Release group collections'),
  series: N_lp('Series collections', 'plural'),
  work: N_l('Work collections'),
};

function formatCollaboratorNumber(
  collaborators: $ReadOnlyArray<EditorT>,
  activeUserId: ?number,
) {
  const isCollaborator = activeUserId != null && collaborators.some(
    collaborator => collaborator.id === activeUserId,
  );

  return isCollaborator ? (
    texp.l('{collaborator_number} (including you)',
           {collaborator_number: collaborators.length})
  ) : (
    collaborators.length
  );
}

function formatPrivacy(
  collection: CollectionT,
  activeUserId: ?number,
  isCollaborativeSection: boolean,
) {
  return (collection.public ? l('Public') : l('Private')) + (
    isCollaborativeSection && activeUserId != null && !!collection.editor &&
    collection.editor.id === activeUserId
      ? ' ' + l('(your collection)') : ''
  );
}

component CollectionsEntityTypeSection(
  activeUserId: number | void,
  collections: $ReadOnlyArray<CollectionWithSubscribedT>,
  isCollaborative: boolean,
  type: string,
  user: AccountLayoutUserT,
) {
  const columns = React.useMemo(
    () => {
      const viewingOwnProfile =
        activeUserId != null && activeUserId === user.id;
      const nameColumn = defineNameColumn<CollectionT>({
        title: l('Collection'),
      });
      const typeColumn = defineTypeColumn({typeContext: 'collection_type'});
      const sizeColumn:
        ColumnOptions<CollectionT, number> = {
          accessor: x => x.entity_count,
          Header: formatPluralEntityTypeName(type),
          id: 'size',
        };
      const collaboratorsColumn:
        ColumnOptions<CollectionT, $ReadOnlyArray<EditorT>> = {
          accessor: x => x.collaborators,
          Cell: ({cell: {value}}) => (
            formatCollaboratorNumber(value, activeUserId)
          ),
          Header: l('Collaborators'),
          id: 'collaborators',
        };
      const privacyColumn:
        ColumnOptions<CollectionT, boolean> = {
          accessor: x => x.public,
          Cell: ({row: {original}}) => formatPrivacy(
            original,
            activeUserId,
            isCollaborative,
          ),
          Header: l('Privacy'),
          id: 'privacy',
        };
      const actionsColumn = defineActionsColumn({
        actions: [
          [lp('Edit', 'verb, interactive'), '/own_collection/edit'],
          [l('Remove'), '/own_collection/delete'],
        ],
      });

      return [
        nameColumn,
        typeColumn,
        sizeColumn,
        collaboratorsColumn,
        (activeUserId == null) ? null : subscriptionColumn,
        (viewingOwnProfile || isCollaborative) ? privacyColumn : null,
        (viewingOwnProfile && !isCollaborative) ? actionsColumn : null,
      ].filter(Boolean);
    },
    [activeUserId, isCollaborative, type, user.id],
  );

  const table = useTable<CollectionWithSubscribedT>({
    columns,
    data: collections,
  });

  return (
    <>
      <h3>{collectionsListTitles[type]()}</h3>
      {table}
    </>
  );
}

component UserCollections(
  collaborativeCollections: CollectionListT,
  ownCollections: CollectionListT,
  user: AccountLayoutUserT,
) {
  const $c = React.useContext(SanitizedCatalystContext);
  const activeUser = $c.user;
  const viewingOwnProfile = !!(activeUser && activeUser.id === user.id);
  const ownCollectionTypes = Object.keys(ownCollections);
  const collaborativeCollectionTypes = Object.keys(collaborativeCollections);

  return (
    <UserAccountLayout
      entity={user}
      page="collections"
      title={l('Collections')}
    >
      <h2>{l('My collections')}</h2>
      {ownCollectionTypes.length > 0 ? (
        ownCollectionTypes.sort().map(type => (
          <CollectionsEntityTypeSection
            activeUserId={activeUser?.id}
            collections={ownCollections[type]}
            isCollaborative={false}
            key={type}
            type={type}
            user={user}
          />
        ))
      ) : (
        <p>
          {viewingOwnProfile ? (
            l('You have no collections.')
          ) : (
            texp.l('{user} has no public collections.', {user: user.name})
          )}
        </p>
      )}
      <h2>{l('Collaborative collections')}</h2>
      {collaborativeCollectionTypes.length > 0 ? (
        collaborativeCollectionTypes.sort().map(type => (
          <CollectionsEntityTypeSection
            activeUserId={$c.user?.id}
            collections={collaborativeCollections[type]}
            isCollaborative
            key={type}
            type={type}
            user={user}
          />
        ))
      ) : (
        <p>
          {viewingOwnProfile ? (
            l('You aren’t collaborating in any collections.')
          ) : (
            texp.l('{user} isn’t collaborating in any public collections.',
                   {user: user.name})
          )}
        </p>
      )}
      {viewingOwnProfile ? (
        <p>
          <a href="/collection/create">
            {lp('Add a new collection', 'interactive')}
          </a>
        </p>
      ) : null}
    </UserAccountLayout>
  );
}

export default UserCollections;
