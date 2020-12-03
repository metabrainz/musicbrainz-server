/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EditorLink from '../../static/scripts/common/components/EditorLink';
import bracketed from '../../static/scripts/common/utility/bracketed';
import formatUserDate from '../../utility/formatUserDate';
import loopParity from '../../utility/loopParity';

type Props = {
  +$c: CatalystContextT,
  +users: $ReadOnlyArray<UnsanitizedEditorT>,
};

const UserList = ({$c, users}: Props): React.Element<'table'> => (
  <table className="tbl">
    <thead>
      <tr>
        <th>{l('Editor')}</th>
        <th>{l('Member since')}</th>
        <th>{l('Email')}</th>
        <th>{l('Verified on')}</th>
        <th>{l('Last login')}</th>
      </tr>
    </thead>
    <tbody>
      {users.map((user, index) => (
        <tr className={loopParity(index)} key={user.name}>
          <td>
            <EditorLink editor={user} />
            {' '}
            {bracketed(
              <a href={'/admin/user/delete/' + encodeURIComponent(user.name)}>
                {l('delete')}
              </a>,
            )}
          </td>
          <td>{formatUserDate($c, user.registration_date)}</td>
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
        </tr>
      ))}
    </tbody>
  </table>
);

export default UserList;
