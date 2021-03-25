/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

type PropsT = {
  +$c: CatalystContextT,
  +showDownvoted: boolean,
};

const UserTagVoteSelection = ({
  $c,
  showDownvoted,
}: PropsT): Expand2ReactOutput | null => (
  <form action={$c.req.uri} style={{marginTop: '1em'}}>
    <label>
      {addColonText(lp('Show votes', 'tag upvotes or downvotes'))}
      {' '}
      <select defaultValue={showDownvoted ? '1' : '0'} name="show_downvoted">
        <option value="0">{lp('upvotes', 'tag')}</option>
        <option value="1">{lp('downvotes', 'tag')}</option>
      </select>
      {' '}
      <button type="submit">
        {l('Submit')}
      </button>
    </label>
  </form>
);

export default UserTagVoteSelection;
