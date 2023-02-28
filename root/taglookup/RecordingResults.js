/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {RecordingResultsInline}
  from '../search/components/RecordingResults.js';

import TagLookupResults from './Results.js';
import type {TagLookupResultsPropsT} from './types.js';

const TagLookupRecordingResults = (
  props: TagLookupResultsPropsT<RecordingWithArtistCreditT>,
): React.Element<typeof TagLookupResults> => (
  <TagLookupResults {...props}>
    <RecordingResultsInline
      pager={props.pager}
      query={props.query}
      results={props.results}
    />
  </TagLookupResults>
);

export default TagLookupRecordingResults;
