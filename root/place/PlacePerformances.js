/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import RelationshipsTable from '../components/RelationshipsTable';

import PlaceLayout from './PlaceLayout';

type Props = {
  +$c: CatalystContextT,
  +place: PlaceT,
};

const PlacePerformances = ({
  $c,
  place,
}: Props): React.Element<typeof PlaceLayout> => (
  <PlaceLayout $c={$c} entity={place} page="performances" title={l('Performances')}>
    <RelationshipsTable
      entity={place}
      fallbackMessage={l(
        'No recordings, releases or release groups are linked to this place.',
      )}
      heading={l('Performances')}
    />
  </PlaceLayout>
);

export default PlacePerformances;
