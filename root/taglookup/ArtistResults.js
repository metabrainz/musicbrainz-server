/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {ArtistResultsInline} from '../search/components/ArtistResults';

import {TagLookupResultsReactTable} from './Results';
import type {TagLookupResultsReactTablePropsT} from './types';

const TagLookupArtistResults = (
  props: TagLookupResultsReactTablePropsT<ArtistT>,
): React.Element<typeof TagLookupResultsReactTable> => (
  <TagLookupResultsReactTable {...props}>
    <ArtistResultsInline
      $c={props.$c}
      entities={props.entities}
      pager={props.pager}
      query={props.query}
      resultsNumber={props.resultsNumber}
      scores={props.scores}
    />
  </TagLookupResultsReactTable>
);

export default TagLookupArtistResults;
