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
import WikipediaExtract
  from '../static/scripts/common/components/WikipediaExtract';
import Relationships from '../components/Relationships';
import * as manifest from '../static/manifest';

import AreaLayout from './AreaLayout';

type Props = {
  +area: AreaT,
  +numberOfRevisions: number,
  +wikipediaExtract: WikipediaExtractT | null,
};

const AreaIndex = ({
  area,
  numberOfRevisions,
  wikipediaExtract,
}: Props): React.Element<typeof AreaLayout> => (
  <AreaLayout entity={area} page="index">
    <Annotation
      annotation={area.latest_annotation}
      collapse
      entity={area}
      numberOfRevisions={numberOfRevisions}
    />
    <WikipediaExtract
      cachedWikipediaExtract={wikipediaExtract}
      entity={area}
    />
    <Relationships source={area} />
    {manifest.js('area/index.js', {async: 'async'})}
  </AreaLayout>
);

export default AreaIndex;
