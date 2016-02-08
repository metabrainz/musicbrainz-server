// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const React = require('react');

const {l} = require('../../static/scripts/common/i18n');
const DescriptiveLink = require('../../static/scripts/common/components/DescriptiveLink');

const MergeHelper = () => (
  <div id="current-editing">
    <form action={$c.stash.merge_link} method="get">
      <h2>{l('Merge Process')}</h2>
      <p>{l('You currently have the following entities selected for merging:')}</p>
      <ul>
        {$c.stash.to_merge.map(entity =>
          <li>
            <input type="checkbox" id={`remove.${entity.id}`} name="remove" value={entity.id} />
            <label htmlFor={`remove.${entity.id}`}>
              <DescriptiveLink entity={entity} />
            </label>
          </li>
        )}
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
          <button type="submit" name="submit" value="merge" className="positive">{l('Merge')}</button>}
        <button type="submit" name="submit" value="remove">{l('Remove selected entities')}</button>
        <button type="submit" name="submit" value="cancel" className="negative">{l('Cancel')}</button>
      </div>
    </form>
  </div>
);

module.exports = MergeHelper;
