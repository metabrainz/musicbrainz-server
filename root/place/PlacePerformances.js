/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import RelationshipsTable from '../components/RelationshipsTable.js';

import PlaceLayout from './PlaceLayout.js';

type Props = {
  +pagedLinkTypeGroup: ?PagedLinkTypeGroupT,
  +pager: ?PagerT,
  +place: PlaceT,
};

const PlacePerformances = ({
  pagedLinkTypeGroup,
  pager,
  place,
}: Props): React.Element<typeof PlaceLayout> => (
  <PlaceLayout
    entity={place}
    page="performances"
    title={l('Performances')}
  >
    <RelationshipsTable
      entity={place}
      fallbackMessage={l(
        'No recordings, releases or release groups are linked to this place.',
      )}
      heading={l('Performances')}
      pagedLinkTypeGroup={pagedLinkTypeGroup}
      pager={pager}
    />
  </PlaceLayout>
);

export default PlacePerformances;
