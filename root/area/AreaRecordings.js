/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import RelationshipsTable from '../components/RelationshipsTable';

import AreaLayout from './AreaLayout';

type Props = {
  +$c: CatalystContextT,
  +area: AreaT,
};

const AreaRecordings = ({
  $c,
  area,
}: Props): React.Element<typeof AreaLayout> => (
  <AreaLayout $c={$c} entity={area} page="recordings" title={l('Recordings')}>
    <RelationshipsTable
      entity={area}
      fallbackMessage={l(
        'This area has no relationships to any recordings.',
      )}
      heading={l('Relationships')}
      showCredits
    />
  </AreaLayout>
);

export default AreaRecordings;
