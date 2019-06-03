/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import Annotation from '../static/scripts/common/components/Annotation';
import WikipediaExtract
  from '../static/scripts/common/components/WikipediaExtract';
import Relationships from '../components/Relationships';
import * as manifest from '../static/manifest';

import PlaceLayout from './PlaceLayout';

type Props = {|
  +eligibleForCleanup: boolean,
  +numberOfRevisions: number,
  +place: PlaceT,
  +wikipediaExtract: WikipediaExtractT | null,
|};

const PlaceIndex = ({
  eligibleForCleanup,
  numberOfRevisions,
  place,
  wikipediaExtract,
}: Props) => (
  <PlaceLayout entity={place} page="index">
    {eligibleForCleanup ? (
      <p className="cleanup">
        {l(
          `This place has no relationships and will be removed automatically
           in the next few days. If this is not intended,
           please add more data to this place.`,
        )}
      </p>
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
    {manifest.js('place/index.js', {async: 'async'})}
  </PlaceLayout>
);

export default PlaceIndex;
