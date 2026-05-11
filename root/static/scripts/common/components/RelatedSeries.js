/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {PART_OF_SERIES_LINK_TYPES} from '../constants.js';
import linkedEntities from '../linkedEntities.mjs';
import groupRelationships from '../utility/groupRelationships.js';

import EntityLink from './EntityLink.js';
import StaticRelationshipsDisplay from './StaticRelationshipsDisplay.js';

const seriesPartLinkTypes = new Set(
  Object.values(PART_OF_SERIES_LINK_TYPES),
);

export function isNotSeriesPart(r: RelationshipT): boolean {
  const relTypeGid = linkedEntities.link_type[r.linkTypeID].gid;
  const isPart = seriesPartLinkTypes.has(relTypeGid);
  // For series-series rels, we check it's a part linking back to the series
  const isSeriesPartOfSeries = isPart &&
    relTypeGid === PART_OF_SERIES_LINK_TYPES.series &&
    r.backward === false;
  return !isPart || isSeriesPartOfSeries;
}

component RelatedSeries(seriesIds: $ReadOnlyArray<number>) {
  const parts: Array<React.Node> = [
    /* eslint-disable react/jsx-key */
    <h2 className="related-series">
      {l('Related series')}
    </h2>,
  ];
  for (let i = 0; i < seriesIds.length; i++) {
    const series = linkedEntities.series[seriesIds[i]];
    parts.push(
      <h3 key={'header-' + series.id}>
        <EntityLink entity={series} showIcon />
      </h3>,
      <StaticRelationshipsDisplay
        key={'content-' + series.id}
        relationships={
          groupRelationships(
            series.relationships,
            {filter: isNotSeriesPart},
          )
        }
      />,
    );
  }
  return parts;
}

export default RelatedSeries;
