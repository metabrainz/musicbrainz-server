/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../../../context';
import EntityLink from '../../../static/scripts/common/components/EntityLink';

import CollectionList from './CollectionList';

type Props = {|
  +$c: CatalystContextT,
  +event: EventT,
|};

const AttendanceLinks = ({$c, event}: Props) => {
  const numberOfCollections = $c.stash.number_of_collections || 0;
  if (!$c.user_exists) {
    return null;
  }
  return (
    <CollectionList
      addCollectionText={l('Add to a new list')}
      collaborativeCollections={$c.stash.collaborative_collections}
      collaborativeCollectionsHeader={l('Collaborative lists')}
      collaborativeCollectionsNoneText={
        l('Not collaborating on any attendance lists!')
      }
      entity={event}
      header={l('Attendance')}
      ownCollections={$c.stash.own_collections}
      ownCollectionsHeader={l('My attendance lists')}
      ownCollectionsNoneText={l('You have no attendance lists!')}
      sectionClass="attendance"
      usersLink={
        <EntityLink
          content={texp.ln(
            'Found in {num} attendance list',
            'Found in {num} attendance lists',
            numberOfCollections,
            {num: numberOfCollections},
          )}
          entity={event}
          subPath="attendance"
        />
      }
    />
  );
};

export default withCatalystContext(AttendanceLinks);
