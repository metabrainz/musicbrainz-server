/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import type {ColumnOptions} from 'react-table';

import Table from '../components/Table.js';
import UserAccountLayout, {type AccountLayoutUserT}
  from '../components/UserAccountLayout.js';
import {formatPluralEntityTypeName}
  from '../static/scripts/common/utility/formatEntityTypeName.js';
import {
  defineNameColumn,
  defineTypeColumn,
  subscriptionColumn,
  defineActionsColumn,
} from '../utility/tableColumns.js';

type Props = {
  +$c: CatalystContextT,
  +collaborativeCollections: CollectionListT,
  +ownCollections: CollectionListT,
  +user: AccountLayoutUserT,
};

type CollectionWithSubscribedT = $ReadOnly<{
  ...CollectionT,
  subscribed: boolean,
}>;

type CollectionListT = {
  +[entityType: string]: $ReadOnlyArray<CollectionWithSubscribedT>,
};

const collectionsListTitles = {
  area: N_l('Area Collections'),
  artist: N_l('Artist Collections'),
  event: N_l('Event Collections'),
  instrument: N_l('Instrument Collections'),
  label: N_l('Label Collections'),
  place: N_l('Place Collections'),
  recording: N_l('Recording Collections'),
  release: N_l('Release Collections'),
  release_group: N_l('Release Group Collections'),
  series: N_lp('Series Collections', 'plural'),
  work: N_l('Work Collections'),
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

type CollectionsEntityTypeSectionPropsT = {
  +activeUserId: number | void,
  +collections: $ReadOnlyArray<CollectionWithSubscribedT>,
  +isCollaborative: boolean,
  +type: string,
  +user: AccountLayoutUserT,
};

const CollectionsEntityTypeSection = ({
  activeUserId,
  collections,
  isCollaborative,
  type,
  user,
}: CollectionsEntityTypeSectionPropsT) => {
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
          Header: formatPluralEntityTypeName(type),
          accessor: x => x.entity_count,
          id: 'size',
        };
      const collaboratorsColumn:
        ColumnOptions<CollectionT, $ReadOnlyArray<EditorT>> = {
          Cell: ({cell: {value}}) => (
            formatCollaboratorNumber(value, activeUserId)
          ),
          Header: l('Collaborators'),
          accessor: x => x.collaborators,
          id: 'collaborators',
        };
      const privacyColumn:
        ColumnOptions<CollectionT, boolean> = {
          Cell: ({row: {original}}) => formatPrivacy(
            original,
            activeUserId,
            isCollaborative,
          ),
          Header: l('Privacy'),
          accessor: x => x.public,
          id: 'privacy',
        };
      const actionsColumn = defineActionsColumn({
        actions: [
          [l('Edit'), '/own_collection/edit'],
          [l('Remove'), '/own_collection/delete'],
        ],
      });

      return [
        nameColumn,
        typeColumn,
        sizeColumn,
        collaboratorsColumn,
        ...(activeUserId == null ? [] : [subscriptionColumn]),
        ...(viewingOwnProfile || isCollaborative ? [privacyColumn] : []),
        ...(viewingOwnProfile && !isCollaborative ? [actionsColumn] : []),
      ];
    },
    [activeUserId, isCollaborative, type, user.id],
  );

  return (
    <>
      <h3>{collectionsListTitles[type]()}</h3>
      <Table columns={columns} data={collections} />
    </>
  );
};

const UserCollections = ({
  $c,
  ownCollections,
  collaborativeCollections,
  user,
}: Props): React.Element<typeof UserAccountLayout> => {
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
        <p><a href="/collection/create">{l('Create a new collection')}</a></p>
      ) : null}
    </UserAccountLayout>
  );
};

export default UserCollections;
