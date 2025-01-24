/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import RecordingList from '../components/list/RecordingList.js';
import PaginatedResults from '../components/PaginatedResults.js';
import {SanitizedCatalystContext} from '../context.mjs';
import manifest from '../static/manifest.mjs';
import ListMergeButtonsRow
  from '../static/scripts/common/components/ListMergeButtonsRow.js';

import InstrumentLayout from './InstrumentLayout.js';

component InstrumentRecordings(
  instrument: InstrumentT,
  instrumentCreditsAndRelTypes: InstrumentCreditsAndRelTypesT,
  pager: PagerT,
  recordings: $ReadOnlyArray<RecordingWithArtistCreditT>,
) {
  const $c = React.useContext(SanitizedCatalystContext);
  return (
    <InstrumentLayout
      entity={instrument}
      page="recordings"
      title={l('Recordings')}
    >
      <h2>{l('Recordings')}</h2>

      {recordings && recordings.length > 0 ? (
        <form
          action="/recording/merge_queue"
          method="post"
        >
          <PaginatedResults pager={pager}>
            <RecordingList
              checkboxes="add-to-merge"
              instrumentCreditsAndRelTypes={instrumentCreditsAndRelTypes}
              recordings={recordings}
              showInstrumentCreditsAndRelTypes
              showRatings
            />
          </PaginatedResults>
          {$c.user ? (
            <>
              <ListMergeButtonsRow
                label={l('Add selected recordings for merging')}
              />
              {manifest(
                'common/components/ListMergeButtonsRow',
                {async: 'async'},
              )}
            </>
          ) : null}
        </form>
      ) : (
        <p>
          {l('No recordings found.')}
        </p>
      )}
      {manifest('common/MB/Control/SelectAll', {async: 'async'})}
    </InstrumentLayout>
  );
}

export default InstrumentRecordings;
