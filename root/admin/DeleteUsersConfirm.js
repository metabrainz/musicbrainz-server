/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout/index.js';
import PostParameters, {
  type PostParametersT,
} from '../static/scripts/common/components/PostParameters.js';
import FormCsrfToken
  from '../static/scripts/edit/components/FormCsrfToken.js';

import UserList from './components/UserList.js';

type Props = {
  +form: DeleteUsersFormT,
  +incorrectUsernames?: $ReadOnlyArray<string>,
  +postParameters: PostParametersT | null,
  +users?: $ReadOnlyArray<UnsanitizedEditorT>,
};

const DeleteUsersConfirm = ({
  form,
  incorrectUsernames,
  postParameters,
  users,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title="Confirm user deletion">
    <div id="content">
      <h1>{'Confirm user deletion'}</h1>

      {incorrectUsernames?.length ? (
        <>
          <p>
            {'The following usernames are not in use:'}
          </p>
          <ul>
            {incorrectUsernames.map((username, index) => (
              <li key={index}>{username}</li>
            ))}
          </ul>
        </>
      ) : null}

      {users?.length ? (
        <>
          <UserList users={users} />

          <p>
            {'Are you sure you want to remove the users above?'}
          </p>

          <form action="/admin/delete-users" method="post">
            <FormCsrfToken form={form} />

            {postParameters
              ? <PostParameters params={postParameters} />
              : null}

            <span className="buttons">
              <button
                name="delete-users.submit"
                type="submit"
                value="confirmed"
              >
                {'Yes, I am sure'}
              </button>
              <button
                className="negative"
                name="delete-users.cancel"
                type="submit"
                value="1"
              >
                {'Cancel'}
              </button>
            </span>
          </form>
        </>
      ) : (
        <p>
          {'No valid users selected.'}
        </p>
      )}
    </div>
  </Layout>
);

export default DeleteUsersConfirm;
