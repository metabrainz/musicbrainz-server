/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import LabelsList from '../components/LabelsList';
import PaginatedResults from '../components/PaginatedResults';

import AreaLayout from './AreaLayout';

type Props = {|
  +area: AreaT,
  +labels: $ReadOnlyArray<LabelT>,
  +pager: PagerT,
|};

const AreaLabels = ({
  area,
  labels,
  pager,
}: Props) => (
  <AreaLayout entity={area} page="labels" title={l('Labels')}>
    <h2>{l('Labels')}</h2>

    {labels.length > 0 ? (
      <PaginatedResults pager={pager}>
        <LabelsList
          labels={labels}
          noAreas
        />
      </PaginatedResults>
    ) : (
      <p>
        {l('This area is not currently associated with any labels.')}
      </p>
    )}
  </AreaLayout>
);

export default AreaLabels;
