/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseList from '../components/list/ReleaseList.js';
import PaginatedResults from '../components/PaginatedResults.js';
import {SanitizedCatalystContext} from '../context.mjs';
import {returnToCurrentPage} from '../utility/returnUri.js';

import InstrumentLayout from './InstrumentLayout.js';

component InstrumentReleases(
  instrument: InstrumentT,
  instrumentCreditsAndRelTypes: InstrumentCreditsAndRelTypesT,
  pager: PagerT,
  releases: $ReadOnlyArray<ReleaseT>,
) {
  const $c = React.useContext(SanitizedCatalystContext);
  return (
    <InstrumentLayout
      entity={instrument}
      page="releases"
      title={l('Releases')}
    >
      <h2>{l('Releases')}</h2>

      {releases && releases.length > 0 ? (
        <form
          action={'/release/merge_queue?' + returnToCurrentPage($c)}
          method="post"
        >
          <PaginatedResults pager={pager}>
            <ReleaseList
              checkboxes="add-to-merge"
              instrumentCreditsAndRelTypes={instrumentCreditsAndRelTypes}
              releases={releases}
              showInstrumentCreditsAndRelTypes
            />
          </PaginatedResults>
          {$c.user ? (
            <div className="row">
              <span className="buttons">
                <button type="submit">
                  {l('Add selected releases for merging')}
                </button>
              </span>
            </div>
          ) : null}
        </form>
      ) : (
        <p>
          {l('No releases found.')}
        </p>
      )}
    </InstrumentLayout>
  );
}

export default InstrumentReleases;
