/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import groupRelationships from '../../../../utility/groupRelationships.js';
import {PART_OF_SERIES_LINK_TYPES} from '../constants.js';
import linkedEntities from '../linkedEntities.mjs';

import EntityLink from './EntityLink.js';
import StaticRelationshipsDisplay from './StaticRelationshipsDisplay.js';

type Props = {
  +seriesIds: $ReadOnlyArray<number>,
};

const seriesPartLinkTypes = new Set(
  Object.values(PART_OF_SERIES_LINK_TYPES),
);

export function isNotSeriesPart(r: RelationshipT): boolean {
  return !seriesPartLinkTypes.has(linkedEntities.link_type[r.linkTypeID].gid);
}

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
        <EntityLink entity={series} showIcon />
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
