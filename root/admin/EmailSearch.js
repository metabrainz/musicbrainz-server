/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormRowText from '../components/FormRowText';
import FormSubmit from '../components/FormSubmit';
import Layout from '../layout';

import UserList from './components/UserList';

type Props = {
  +$c: CatalystContextT,
  +form: FormT<{
    +email: ReadOnlyFieldT<string>,
  }>,
  +results?: $ReadOnlyArray<UnsanitizedEditorT>,
};

const EmailSearch = ({
  $c,
  form,
  results,
}: Props): React.Element<typeof Layout> => (
  <Layout $c={$c} fullWidth title={l('Search users by email')}>
    <div id="content">
      <h1>{l('Search users by email')}</h1>

      <form action="/admin/email-search" method="post">
        <p>
          {exp.l(
            'Enter a {link|POSIX regular expression}.',
            {
              link: 'https://www.postgresql.org/docs/12/' +
                'functions-matching.html#FUNCTIONS-POSIX-REGEXP',
            },
          )}
        </p>

        <FormRowText
          field={form.field.email}
          label={addColonText(l('Email'))}
          size={50}
          uncontrolled
        />

        <div className="row no-label">
          <FormSubmit
            label={l('Search')}
            name="emailsearch.submit"
            value="1"
          />
        </div>

        {results?.length ? (
          <UserList users={results} />
        ) : null}
      </form>
    </div>
  </Layout>
);

export default EmailSearch;
