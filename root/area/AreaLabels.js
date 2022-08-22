/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import LabelList from '../components/list/LabelList.js';
import PaginatedResults from '../components/PaginatedResults.js';
import {SanitizedCatalystContext} from '../context.mjs';
import {returnToCurrentPage} from '../utility/returnUri.js';

import AreaLayout from './AreaLayout.js';

type Props = {
  +area: AreaT,
  +labels: $ReadOnlyArray<LabelT>,
  +pager: PagerT,
};

const AreaLabels = ({
  area,
  labels,
  pager,
}: Props): React.Element<typeof AreaLayout> => {
  const $c = React.useContext(SanitizedCatalystContext);
  return (
    <AreaLayout entity={area} page="labels" title={l('Labels')}>
      <h2>{l('Labels')}</h2>

      {labels.length > 0 ? (
        <form
          action={'/label/merge_queue?' + returnToCurrentPage($c)}
          method="post"
        >
          <PaginatedResults pager={pager}>
            <LabelList
              checkboxes="add-to-merge"
              labels={labels}
              showRatings
            />
          </PaginatedResults>
          {$c.user ? (
            <div className="row">
              <span className="buttons">
                <button type="submit">
                  {l('Add selected labels for merging')}
                </button>
              </span>
            </div>
          ) : null}
        </form>
      ) : (
        <p>
          {l('This area is not currently associated with any labels.')}
        </p>
      )}
    </AreaLayout>
  );
};

export default AreaLabels;
