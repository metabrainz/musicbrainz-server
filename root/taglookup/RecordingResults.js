/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {RecordingResultsInline} from '../search/components/RecordingResults';

import TagLookupResults from './Results';
import type {TagLookupResultsPropsT} from './types';

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
