/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import AreaList from '../components/list/AreaList';
import ArtistList from '../components/list/ArtistList';
import EventList from '../components/list/EventList';
import FormRow from '../components/FormRow';
import FormSubmit from '../components/FormSubmit';
import InstrumentList from '../components/list/InstrumentList';
import LabelList from '../components/list/LabelList';
import PlaceList from '../components/list/PlaceList';
import RecordingList from '../components/list/RecordingList';
import ReleaseGroupList from '../components/list/ReleaseGroupList';
import ReleaseList from '../components/list/ReleaseList';
import SeriesList from '../components/list/SeriesList';
import WorkList from '../components/list/WorkList';
import PaginatedResults from '../components/PaginatedResults';
import expand2react from '../static/scripts/common/i18n/expand2react';
import {formatPluralEntityTypeName}
  from '../static/scripts/common/utility/formatEntityTypeName';
import UserInlineList from '../user/components/UserInlineList';

import CollectionLayout from './CollectionLayout';

type PropsForEntity<T: CoreEntityT> = {
  +$c: CatalystContextT,
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
  | PropsForEntity<InstrumentT>
  | PropsForEntity<LabelT>
  | PropsForEntity<PlaceT>
  | PropsForEntity<RecordingWithArtistCreditT>
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

  switch (props.collectionEntityType) {
    case 'area':
      return (
        <AreaList
          areas={props.entities}
          {...sharedProps}
        />
      );
    case 'artist':
      return (
        <ArtistList
          artists={props.entities}
          showBeginEnd
          showRatings
          {...sharedProps}
        />
      );
    case 'event':
      return (
        <EventList
          events={props.entities}
          showArtists
          showLocation
          showRatings
          showType
          {...sharedProps}
        />
      );
    case 'instrument':
      return (
        <InstrumentList
          instruments={props.entities}
          {...sharedProps}
        />
      );
    case 'label':
      return (
        <LabelList
          labels={props.entities}
          showRatings
          {...sharedProps}
        />
      );
    case 'place':
      return (
        <PlaceList
          places={props.entities}
          showRatings
          {...sharedProps}
        />
      );
    case 'recording':
      return (
        <RecordingList
          recordings={props.entities}
          showRatings
          {...sharedProps}
        />
      );
    case 'release':
      return (
        <ReleaseList
          releases={props.entities}
          showRatings
          {...sharedProps}
        />
      );
    case 'release_group':
      return (
        <ReleaseGroupList
          releaseGroups={props.entities}
          showRatings
          {...sharedProps}
        />
      );
    case 'series':
      return (
        <SeriesList
          series={props.entities}
          {...sharedProps}
        />
      );
    case 'work':
      return (
        <WorkList
          showRatings
          works={props.entities}
          {...sharedProps}
        />
      );
    default:
      throw `Unsupported entity type value: ${props.collectionEntityType}`;
  }
};

const CollectionIndex = (props: Props):
React.Element<typeof CollectionLayout> => {
  const {
    $c,
    collection,
    collectionEntityType,
    entities,
    pager,
  } = props;

  const user = $c.user;
  const canRemoveFromCollection = !!user && !!collection.editor &&
    (user.id === collection.editor.id ||
      collection.collaborators.some(x => x.id === user.id));

  return (
    <CollectionLayout entity={collection} page="index">
      <div className="description">
        {collection.description_html ? (
          <>
            <h2>{l('Description')}</h2>
            {($c.user || !collection.editor_is_limited) ? (
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
        <form action={$c.req.uri} method="post">
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
    </CollectionLayout>
  );
};

export default CollectionIndex;
