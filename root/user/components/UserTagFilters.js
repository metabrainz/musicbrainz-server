/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormRow from '../../components/FormRow';

type PropsT = {
  +$c: CatalystContextT,
  +showDownvoted: boolean,
  +showSortSelect?: boolean,
  +showVotesSelect?: boolean,
  +sortBy?: 'count' | 'countdesc' | 'name',
};

const InlineSubmitButton = (): React.Element<typeof React.Fragment> => (
  <>
    {' '}
    <button type="submit">
      {l('Submit')}
    </button>
  </>
);

const UserTagFilters = ({
  $c,
  showDownvoted,
  showSortSelect = false,
  showVotesSelect = false,
  sortBy,
}: PropsT): Expand2ReactOutput | null => (
  (showSortSelect || showVotesSelect) ? (
    <form action={$c.req.uri} style={{marginTop: '1em'}}>
      {showVotesSelect ? (
        <FormRow>
          <label>
            {addColonText(lp('Show votes', 'tag upvotes or downvotes'))}
            {' '}
            <select
              defaultValue={showDownvoted ? '1' : '0'}
              name="show_downvoted"
            >
              <option value="0">{lp('upvotes', 'tag')}</option>
              <option value="1">{lp('downvotes', 'tag')}</option>
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

export default UserTagFilters;
