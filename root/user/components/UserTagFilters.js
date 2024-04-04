/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import FormRow from '../../static/scripts/edit/components/FormRow.js';
import InlineSubmitButton
  from '../../static/scripts/edit/components/InlineSubmitButton.js';

component UserTagFilters(
  showDownvoted: boolean,
  showSortSelect: boolean = false,
  showVotesSelect: boolean = false,
  sortBy?: 'count' | 'countdesc' | 'name',
) {
  return (
    (showSortSelect || showVotesSelect) ? (
      <form style={{marginTop: '1em'}}>
        {showVotesSelect ? (
          <FormRow>
            <label>
              {addColonText(lp(
                'Show votes',
                'folksonomy tag upvotes or downvotes',
              ))}
              {' '}
              <select
                defaultValue={showDownvoted ? '1' : '0'}
                name="show_downvoted"
              >
                <option value="0">{lp('upvotes', 'folksonomy tag')}</option>
                <option value="1">{lp('downvotes', 'folksonomy tag')}</option>
              </select>
            </label>
            {showSortSelect ? null : <InlineSubmitButton />}
          </FormRow>
        ) : null}
        {showSortSelect ? (
          <FormRow>
            <label>
              {addColonText(l('Sort by'))}
              {' '}
              <select defaultValue={sortBy ?? 'name'} name="order">
                <option value="name">{l('name')}</option>
                <option value="count">{l('count (more first)')}</option>
                <option value="countdesc">{l('count (less first)')}</option>
              </select>
            </label>
            {showVotesSelect ? null : <InlineSubmitButton />}
          </FormRow>
        ) : null}
        {showSortSelect && showVotesSelect ? (
          <FormRow>
            <button type="submit">{l('Submit')}</button>
          </FormRow>
        ) : null}
      </form>
    ) : null
  );
}

export default UserTagFilters;
