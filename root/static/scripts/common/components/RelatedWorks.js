/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import linkedEntities from '../linkedEntities.mjs';
import groupRelationships from '../utility/groupRelationships.js';

import EntityLink from './EntityLink.js';
import StaticRelationshipsDisplay from './StaticRelationshipsDisplay.js';

const targetEntityTypes = [
  'area',
  'artist',
  'event',
  'label',
  'place',
  'work',
];

type Props = {
  +workIds: $ReadOnlyArray<number>,
};

const RelatedWorks = ({workIds}: Props): React.MixedElement => {
  const createArgs = [
    React.Fragment,
    null,
    /* eslint-disable react/jsx-key */
    <h2 className="related-works">
      {l('Related works')}
    </h2>,
  ];
  for (let i = 0; i < workIds.length; i++) {
    const work = linkedEntities.work[workIds[i]];
    createArgs.push(
      <h3>
        <EntityLink entity={work} showIcon />
      </h3>,
      <StaticRelationshipsDisplay
        relationships={
          groupRelationships(work.relationships, {types: targetEntityTypes})
        }
      />,
    );
  }
  return React.createElement.apply(React, createArgs);
};

export default RelatedWorks;
