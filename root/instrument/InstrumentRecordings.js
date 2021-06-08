/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import RecordingList from '../components/list/RecordingList';
import PaginatedResults from '../components/PaginatedResults';
import {returnToCurrentPage} from '../utility/returnUri';

import InstrumentLayout from './InstrumentLayout';

type Props = {|
  ...InstrumentCreditsAndRelTypesRoleT,
  +$c: CatalystContextT,
  +instrument: InstrumentT,
  +pager: PagerT,
  +recordings: $ReadOnlyArray<RecordingWithArtistCreditT>,
|};

const InstrumentRecordings = ({
  $c,
  instrument,
  instrumentCreditsAndRelTypes,
  pager,
  recordings,
}: Props): React.Element<typeof InstrumentLayout> => (
  <InstrumentLayout
    entity={instrument}
    page="recordings"
    title={l('Recordings')}
  >
    <h2>{l('Recordings')}</h2>

    {recordings && recordings.length > 0 ? (
      <form
        action={'/recording/merge_queue?' + returnToCurrentPage($c)}
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
          <div className="row">
            <span className="buttons">
              <button type="submit">
                {l('Add selected recordings for merging')}
              </button>
            </span>
          </div>
        ) : null}
      </form>
    ) : (
      <p>
        {l('No recordings found.')}
      </p>
    )}
  </InstrumentLayout>
);

export default InstrumentRecordings;
