/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../../layout/index.js';
import FormCsrfToken
  from '../../static/scripts/edit/components/FormCsrfToken.js';
import FormSubmit from '../../static/scripts/edit/components/FormSubmit.js';

type Props = {
  +form: SecureConfirmFormT,
  +page: string,
};

const DeleteWikiDoc = ({
  form,
  page,
}: Props): React$Element<typeof Layout> => (
  <Layout fullWidth title={l('Remove Page')}>
    <div id="content">
      <h1>{l('Remove Page')}</h1>
      <p>
        {exp.l(`Are you sure you wish to remove the page
                “{page_uri|{page_name}}” from the transclusion table?`,
               {
                 page_name: page,
                 page_uri: '/doc/' + encodeURIComponent(page),
               })}
      </p>
      <form method="post" name="confirm">
        <FormCsrfToken form={form} />
        <FormSubmit
          label={l('Yes, I am sure')}
          name="confirm.submit"
          value="1"
        />
      </form>
    </div>
  </Layout>
);

export default DeleteWikiDoc;
