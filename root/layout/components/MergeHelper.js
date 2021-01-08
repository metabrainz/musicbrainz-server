/*
 * @flow strict-local
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink';
import {returnToCurrentPage} from '../../utility/returnUri';

type Props = {
  +$c: CatalystContextT,
  +merger: MergeQueueT,
};

const MergeHelper = ({$c, merger}: Props): React.Element<'div'> => (
  <div id="current-editing">
    <form
      action={`/${merger.type}/merge?` + returnToCurrentPage($c)}
      method="post"
    >
      <h2>{l('Merge Process')}</h2>
      <p>
        {l('You currently have the following entities selected for merging:')}
      </p>
      <ul>
        {$c.stash.to_merge?.map(entity => (
          <li key={entity.id}>
            <input
              id={`remove.${entity.id}`}
              name="remove"
              type="checkbox"
              value={entity.id}
            />
            <label htmlFor={`remove.${entity.id}`}>
              <DescriptiveLink entity={entity} />
            </label>
          </li>
        ))}
      </ul>
      <p>
        {merger.ready_to_merge
          ? l(
            `When you are ready to merge these, just click the Merge button.
             You may still add more to this merge queue by simply browsing to
             the entities page and following the merge link.`,
          )
          : l(
            `Please navigate to the pages of other entities you wish to merge
             and select the "merge" link.`,
          )
        }
      </p>
      <div className="buttons" style={{display: 'table-cell'}}>
        {merger.ready_to_merge &&
          <button
            className="positive"
            name="submit"
            type="submit"
            value="merge"
          >
            {l('Merge')}
          </button>}
        <button name="submit" type="submit" value="remove">
          {l('Remove selected entities')}
        </button>
        <button
          className="negative"
          name="submit"
          type="submit"
          value="cancel"
        >
          {l('Cancel')}
        </button>
      </div>
    </form>
  </div>
);

export default MergeHelper;
