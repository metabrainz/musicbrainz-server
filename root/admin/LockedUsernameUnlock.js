/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';
import expand2text from '../static/scripts/common/i18n/expand2text.js';
import FormCsrfToken
  from '../static/scripts/edit/components/FormCsrfToken.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';

type Props = {
  +form: SecureConfirmFormT,
  +username: string,
};

const LockedUsernameUnlock = ({
  form,
  username,
}: Props): React$Element<typeof Layout> => (
  <Layout fullWidth title="Unlock username">
    <div id="content">
      <h1>{'Unlock username'}</h1>
      <p>
        {expand2text(
          `Are you sure you wish to unlock
           the username “{username}” for reuse?`,
          {username: username},
        )}
      </p>
      <form method="post" name="confirm">
        <FormCsrfToken form={form} />
        <FormSubmit
          label="Yes, I am sure"
          name="confirm.submit"
          value="1"
        />
      </form>
    </div>
  </Layout>
);

export default LockedUsernameUnlock;
