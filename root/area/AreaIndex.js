/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import manifest from '../static/manifest.mjs';
import Annotation from '../static/scripts/common/components/Annotation.js';
import Relationships
  from '../static/scripts/common/components/Relationships.js';
import WikipediaExtract
  from '../static/scripts/common/components/WikipediaExtract.js';

import AreaLayout from './AreaLayout.js';

component AreaIndex(
  area: AreaT,
  numberOfRevisions: number,
  wikipediaExtract: WikipediaExtractT | null,
) {
  return (
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
      {manifest('area/index', {async: 'async'})}
    </AreaLayout>
  );
}

export default AreaIndex;
