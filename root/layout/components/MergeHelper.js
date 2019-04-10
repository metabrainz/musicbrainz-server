/*
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2015 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {withCatalystContext} from '../../context';
import DescriptiveLink from '../../static/scripts/common/components/DescriptiveLink';

const MergeHelper = ({$c}) => (
  <div id="current-editing">
    <form action={$c.stash.merge_link} method="get">
      <h2>{l('Merge Process')}</h2>
      <p>{l('You currently have the following entities selected for merging:')}</p>
      <ul>
        {$c.stash.to_merge.map(entity => (
          <li>
            <input id={`remove.${entity.id}`} name="remove" type="checkbox" value={entity.id} />
            <label htmlFor={`remove.${entity.id}`}>
              <DescriptiveLink entity={entity} />
            </label>
          </li>
        ))}
      </ul>
      <p>
        {$c.session.merger.ready_to_merge
          ? l('When you are ready to merge these, just click the Merge button. ' +
              'You may still add more to this merge queue by simply browsing to ' +
              'the entities page and following the merge link.')
          : l('Please navigate to the pages of other entities you wish to merge and select the "merge" link.')
        }
      </p>
      <div className="buttons" style={{display: 'table-cell'}}>
        {$c.session.merger.ready_to_merge &&
          <button className="positive" name="submit" type="submit" value="merge">{l('Merge')}</button>}
        <button name="submit" type="submit" value="remove">{l('Remove selected entities')}</button>
        <button className="negative" name="submit" type="submit" value="cancel">{l('Cancel')}</button>
      </div>
    </form>
  </div>
);

export default withCatalystContext(MergeHelper);
