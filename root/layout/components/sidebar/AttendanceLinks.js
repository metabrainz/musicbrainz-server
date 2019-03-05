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
  const allCollections = $c.stash.all_collections;
  if (!$c.user_exists || !allCollections) {
    return null;
  }
  return (
    <>
      <h2 className="attendance">
        {l('Attendance')}
      </h2>
      <CollectionList
        addText={l('Add to a new list')}
        entity={event}
        noneText={l('You have no attendance lists!')}
        usersLink={
          <EntityLink
            content={texp.ln(
              'Found in {num} attendance list',
              'Found in {num} attendance lists',
              allCollections.length,
              {num: allCollections.length},
            )}
            entity={event}
            subPath="attendance"
          />
        }
      />
    </>
  );
};

export default withCatalystContext(AttendanceLinks);
