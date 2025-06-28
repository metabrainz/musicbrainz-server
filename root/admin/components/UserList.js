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
import manifest from '../../static/manifest.mjs';
import {
  StandaloneSpammerButton,
} from '../../static/scripts/admin/components/SpammerButton.js';
import EditorLink from '../../static/scripts/common/components/EditorLink.js';
import {commaOnlyListText}
  from '../../static/scripts/common/i18n/commaOnlyList.js';
import bracketed from '../../static/scripts/common/utility/bracketed.js';
import {
  isAddingNotesDisabled,
  isEditingDisabled,
  isSpammer,
  isUntrusted,
  isVotingDisabled,
} from '../../static/scripts/common/utility/privileges.js';
import formatUserDate from '../../utility/formatUserDate.js';
import loopParity from '../../utility/loopParity.js';

component UserList(users: $ReadOnlyArray<UnsanitizedEditorT>) {
  const $c = React.useContext(CatalystContext);

  return (
    <table className="tbl">
      <thead>
        <tr>
          <th>{'Editor'}</th>
          <th>{'Restrictions'}</th>
          <th>{'Member since'}</th>
          <th>{'Website'}</th>
          <th>{'Email'}</th>
          <th>{'Verified on'}</th>
          <th>{'Last login'}</th>
          <th>{'Bio'}</th>
          <th>{'Action'}</th>
        </tr>
      </thead>
      <tbody>
        {users.map((user, index) => {
          const restrictions = [];
          if (isEditingDisabled(user)) {
            restrictions.push('Editing');
          }
          if (isVotingDisabled(user)) {
            restrictions.push('Voting');
          }
          if (isAddingNotesDisabled(user)) {
            restrictions.push('Notes');
          }
          if (isUntrusted(user)) {
            restrictions.push('Untrusted');
          }
          if (isSpammer(user)) {
            restrictions.push('Spammer');
          }

          return (
            <tr className={loopParity(index)} key={user.name}>
              <td>
                <EditorLink editor={user} />
                {user.deleted ? null : (
                  <>
                    {' '}
                    {bracketed(
                      <a
                        href={
                          '/admin/user/delete/' +
                          encodeURIComponent(user.name)
                        }
                      >
                        {'delete'}
                      </a>,
                    )}
                  </>
                )}
              </td>
              <td>{commaOnlyListText(restrictions)}</td>
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
              <td>
                {isSpammer(user) ? null : (
                  <>
                    <StandaloneSpammerButton
                      user={{id: user.id, privileges: user.privileges}}
                    />
                    {manifest(
                      'admin/components/SpammerButton',
                      {async: true},
                    )}
                  </>
                )}
              </td>
            </tr>
          );
        })}
      </tbody>
    </table>
  );
}

export default UserList;
