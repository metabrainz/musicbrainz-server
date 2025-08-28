/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import AreaList from '../components/list/AreaList.js';
import ArtistList from '../components/list/ArtistList.js';
import EventList from '../components/list/EventList.js';
import GenreList from '../components/list/GenreList.js';
import InstrumentList from '../components/list/InstrumentList.js';
import LabelList from '../components/list/LabelList.js';
import PlaceList from '../components/list/PlaceList.js';
import RecordingList from '../components/list/RecordingList.js';
import ReleaseGroupList from '../components/list/ReleaseGroupList.js';
import ReleaseList from '../components/list/ReleaseList.js';
import SeriesList from '../components/list/SeriesList.js';
import WorkList from '../components/list/WorkList.js';
import PaginatedResults from '../components/PaginatedResults.js';
import {SanitizedCatalystContext} from '../context.mjs';
import manifest from '../static/manifest.mjs';
import expand2react from '../static/scripts/common/i18n/expand2react.js';
import {formatPluralEntityTypeName}
  from '../static/scripts/common/utility/formatEntityTypeName.js';
import {isBeginner} from '../static/scripts/common/utility/privileges.js';
import FormRow from '../static/scripts/edit/components/FormRow.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';
import UserInlineList from '../user/components/UserInlineList.js';

import CollectionLayout from './CollectionLayout.js';

type PropsForEntity<T: CollectableEntityT> = {
  +collection: CollectionT,
  +collectionEntityType: T['entityType'],
  +entities: $ReadOnlyArray<T>,
  +order: string,
  +pager: PagerT,
};

type Props =
  | PropsForEntity<AreaT>
  | PropsForEntity<ArtistT>
  | PropsForEntity<EventT>
  | PropsForEntity<GenreT>
  | PropsForEntity<InstrumentT>
  | PropsForEntity<LabelT>
  | PropsForEntity<PlaceT>
  | PropsForEntity<RecordingT>
  | PropsForEntity<ReleaseGroupT>
  | PropsForEntity<ReleaseT>
  | PropsForEntity<SeriesT>
  | PropsForEntity<WorkT>;

const listPicker = (
  props: Props,
  canRemoveFromCollection: boolean,
) => {
  const sharedProps = {
    checkboxes: canRemoveFromCollection ? 'remove' : '',
    order: props.order,
    sortable: true,
  };

  return match (props) {
    {collectionEntityType: 'area', const entities, ...} => (
      <AreaList
        areas={entities}
        {...sharedProps}
      />
    ),
    {collectionEntityType: 'artist', const entities, ...} => (
      <ArtistList
        artists={entities}
        showBeginEnd
        showRatings
        {...sharedProps}
      />
    ),
    {collectionEntityType: 'event', const entities, ...} => (
      <EventList
        events={entities}
        showArtists
        showLocation
        showRatings
        showType
        {...sharedProps}
      />
    ),
    {collectionEntityType: 'genre', const entities, ...} => (
      <GenreList
        genres={entities}
        {...sharedProps}
      />
    ),
    {collectionEntityType: 'instrument', const entities, ...} => (
      <InstrumentList
        instruments={entities}
        {...sharedProps}
      />
    ),
    {collectionEntityType: 'label', const entities, ...} => (
      <LabelList
        labels={entities}
        showRatings
        {...sharedProps}
      />
    ),
    {collectionEntityType: 'place', const entities, ...} => (
      <PlaceList
        places={entities}
        showRatings
        {...sharedProps}
      />
    ),
    {collectionEntityType: 'recording', const entities, ...} => (
      <RecordingList
        recordings={entities}
        showRatings
        {...sharedProps}
      />
    ),
    {collectionEntityType: 'release', const entities, ...} => (
      <ReleaseList
        releases={entities}
        showRatings
        {...sharedProps}
      />
    ),
    {collectionEntityType: 'release_group', const entities, ...} => (
      <ReleaseGroupList
        releaseGroups={entities}
        showRatings
        {...sharedProps}
      />
    ),
    {collectionEntityType: 'series', const entities, ...} => (
      <SeriesList
        series={entities}
        {...sharedProps}
      />
    ),
    {collectionEntityType: 'work', const entities, ...} => (
      <WorkList
        showRatings
        works={entities}
        {...sharedProps}
      />
    ),
  };
};

component CollectionIndex(...props: Props) {
  const $c = React.useContext(SanitizedCatalystContext);
  const {
    collection,
    collectionEntityType,
    entities,
    pager,
  } = props;

  const user = $c.user;
  const canRemoveFromCollection = user != null &&
    collection.editor != null &&
    (user.id === collection.editor.id ||
      collection.collaborators.some(x => x.id === user.id));

  const recordingMbids = props.collectionEntityType === 'recording' &&
                         props.entities.length > 0
    ? props.entities.map(entity => entity.gid)
    : null;

  return (
    <CollectionLayout
      entity={collection}
      page="index"
      recordingMbids={recordingMbids}
    >
      <div className="description">
        {collection.description_html ? (
          <>
            <h2>{l('Description')}</h2>
            {($c.user || !isBeginner(collection.editor)) ? (
              expand2react(collection.description_html)
            ) : (
              <p className="deleted">
                {exp.l(`This content is hidden to prevent spam.
                        To view it, please {url|log in}.`,
                       {url: '/login'})}
              </p>
            )}
          </>
        ) : null}
      </div>
      <div className="collaborators">
        {collection.collaborators.length ? (
          <>
            <h2>{l('Collaborators')}</h2>
            <UserInlineList editors={collection.collaborators} />
          </>
        ) : null}
      </div>
      <h2>{formatPluralEntityTypeName(collectionEntityType)}</h2>
      {entities.length > 0 ? (
        <form method="post">
          <PaginatedResults pager={pager}>
            {listPicker(props, canRemoveFromCollection)}
          </PaginatedResults>
          {canRemoveFromCollection ? (
            <FormRow>
              <FormSubmit
                label={l('Remove selected items from collection')}
              />
            </FormRow>
          ) : null}
        </form>
      ) : <p>{l('This collection is empty.')}</p>}
      {manifest('common/ratings', {async: true})}
    </CollectionLayout>
  );
}

export default CollectionIndex;
