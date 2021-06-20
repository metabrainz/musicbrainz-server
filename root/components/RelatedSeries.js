/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityLink from '../static/scripts/common/components/EntityLink';
import linkedEntities from '../static/scripts/common/linkedEntities';
import groupRelationships from '../utility/groupRelationships';

import {isNotSeriesPart} from './Relationships';
import StaticRelationshipsDisplay from './StaticRelationshipsDisplay';

type Props = {
  +seriesIds: $ReadOnlyArray<number>,
};

const RelatedSeries = ({seriesIds}: Props): React.MixedElement => {
  const createArgs = [
    React.Fragment,
    null,
    /* eslint-disable react/jsx-key */
    <h2 className="related-series">
      {l('Related series')}
    </h2>,
  ];
  for (let i = 0; i < seriesIds.length; i++) {
    const series = linkedEntities.series[seriesIds[i]];
    createArgs.push(
      <h3>
        <EntityLink entity={series} />
      </h3>,
      <StaticRelationshipsDisplay
        relationships={
          groupRelationships(
            series.relationships,
            {filter: isNotSeriesPart},
          )
        }
      />,
    );
  }
  return React.createElement.apply(React, createArgs);
};

export default RelatedSeries;
