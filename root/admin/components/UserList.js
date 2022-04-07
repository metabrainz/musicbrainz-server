/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context.mjs';
import EditorLink from '../../static/scripts/common/components/EditorLink.js';
import bracketed from '../../static/scripts/common/utility/bracketed.js';
import formatUserDate from '../../utility/formatUserDate.js';
import loopParity from '../../utility/loopParity.js';

type UserListRowProps = {
  +$c: CatalystContextT,
  +index: number,
  +stats: EditorStatsT | null,
  +user: UnsanitizedEditorT,
};

type UserListProps = {
  +stats?: {+[id: number]: EditorStatsT},
  +users: $ReadOnlyArray<UnsanitizedEditorT>,
};

const UserListRow = ({
  $c,
  index,
  stats,
  user,
}: UserListRowProps): React.Element<'tr'> => (
  <tr className={loopParity(index)}>
    <td>
      <EditorLink editor={user} />
      {user.deleted ? null : (
        <>
          {' '}
          {bracketed(
            <a
              href={
                '/admin/user/delete/' + encodeURIComponent(user.name)
              }
            >
              {l('delete')}
            </a>,
          )}
        </>
      )}
    </td>
    <td>{formatUserDate($c, user.registration_date)}</td>
    <td>
      {nonEmpty(user.website) ? user.website : null}
    </td>
    <td>{user.email}</td>
    <td>
      {nonEmpty(user.email_confirmation_date) ? (
        formatUserDate($c, user.email_confirmation_date)
      ) : null}
    </td>
    <td>
      {nonEmpty(user.last_login_date) ? (
        formatUserDate($c, user.last_login_date)
      ) : null}
    </td>
    <td>
      {nonEmpty(user.biography) ? user.biography : null}
    </td>
    {stats ? (
      <>
        <td>{stats.edit_stats.total_count}</td>
        <td>
          {stats.vote_stats[stats.vote_stats.length - 1].all.count}
        </td>
        <td>
          {(stats.secondary_stats.upvoted_tag_count ?? 0) +
            (stats.secondary_stats.downvoted_tag_count ?? 0)}
        </td>
        <td>{stats.secondary_stats.rating_count}</td>
      </>
    ) : null}
  </tr>
);

const UserList = ({
  stats,
  users,
}: UserListProps): React.Element<'table'> => {
  const $c = React.useContext(CatalystContext);
  return (
    <table className="tbl">
      <thead>
        <tr>
          <th>{'Editor'}</th>
          <th>{'Member since'}</th>
          <th>{'Website'}</th>
          <th>{'Email'}</th>
          <th>{'Verified on'}</th>
          <th>{'Last login'}</th>
          <th>{'Bio'}</th>
          {stats ? (
            <>
              <th>{'Edits'}</th>
              <th>{'Votes'}</th>
              <th>{'Tags'}</th>
              <th>{'Ratings'}</th>
            </>
          ) : null}
        </tr>
      </thead>
      <tbody>
        {users.map((user, index) => (
          <UserListRow
            $c={$c}
            index={index}
            key={user.name}
            stats={stats ? stats[user.id] : null}
            user={user}
          />
        ))}
      </tbody>
    </table>
  );
};

export default UserList;
