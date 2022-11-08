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
import expand2react from '../static/scripts/common/i18n/expand2react.js';
import {formatPluralEntityTypeName}
  from '../static/scripts/common/utility/formatEntityTypeName.js';
import FormRow from '../static/scripts/edit/components/FormRow.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';
import UserInlineList from '../user/components/UserInlineList.js';

import CollectionLayout from './CollectionLayout.js';

type PropsForEntity<T: CollectableCoreEntityT> = {
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
  const $c = React.useContext(SanitizedCatalystContext);
  const {
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
    </CollectionLayout>
  );
};

export default CollectionIndex;
