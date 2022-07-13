/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Annotation from '../static/scripts/common/components/Annotation';
import Relationships from '../static/scripts/common/components/Relationships';
import WikipediaExtract
  from '../static/scripts/common/components/WikipediaExtract';
import CleanupBanner from '../components/CleanupBanner';
import * as manifest from '../static/manifest.mjs';

import PlaceLayout from './PlaceLayout';

type Props = {
  +eligibleForCleanup: boolean,
  +numberOfRevisions: number,
  +place: PlaceT,
  +wikipediaExtract: WikipediaExtractT | null,
};

const PlaceIndex = ({
  eligibleForCleanup,
  numberOfRevisions,
  place,
  wikipediaExtract,
}: Props): React.Element<typeof PlaceLayout> => (
  <PlaceLayout entity={place} page="index">
    {eligibleForCleanup ? (
      <CleanupBanner entityType="place" />
    ) : null}
    <Annotation
      annotation={place.latest_annotation}
      collapse
      entity={place}
      numberOfRevisions={numberOfRevisions}
    />
    <WikipediaExtract
      cachedWikipediaExtract={wikipediaExtract}
      entity={place}
    />
    <Relationships source={place} />
    {manifest.js('place/index', {async: 'async'})}
  </PlaceLayout>
);

export default PlaceIndex;
