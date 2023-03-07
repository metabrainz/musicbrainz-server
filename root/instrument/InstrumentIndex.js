/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as manifest from '../static/manifest.mjs';
import Annotation from '../static/scripts/common/components/Annotation.js';
import Relationships
  from '../static/scripts/common/components/Relationships.js';
import WikipediaExtract
  from '../static/scripts/common/components/WikipediaExtract.js';
import expand2react from '../static/scripts/common/i18n/expand2react.js';

import InstrumentLayout from './InstrumentLayout.js';

type Props = {
  +instrument: InstrumentT,
  +numberOfRevisions: number,
  +wikipediaExtract: WikipediaExtractT | null,
};

const InstrumentIndex = ({
  instrument,
  numberOfRevisions,
  wikipediaExtract,
}: Props): React$Element<typeof InstrumentLayout> => (
  <InstrumentLayout entity={instrument} page="index">
    {instrument.description ? (
      <>
        <h2>{l('Description')}</h2>
        <p>
          {expand2react(
            l_instrument_descriptions(instrument.description),
          )}
        </p>
      </>
    ) : null}
    <Annotation
      annotation={instrument.latest_annotation}
      collapse
      entity={instrument}
      numberOfRevisions={numberOfRevisions}
    />
    <WikipediaExtract
      cachedWikipediaExtract={wikipediaExtract}
      entity={instrument}
    />
    <Relationships source={instrument} />
    {manifest.js('instrument/index', {async: 'async'})}
  </InstrumentLayout>
);

export default InstrumentIndex;
