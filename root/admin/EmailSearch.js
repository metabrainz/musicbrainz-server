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
import expand2react from '../static/scripts/common/i18n/expand2react';

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
        <p>
          {expand2react(
            `Since periods (<code>.</code>) and tags preceded with a
             <code>+</code> sign on the user side of the address (that is,
             before the <code>@</code> sign) are often used as “free aliases”
             by email providers, both of these are ignored by this search
             to help you find address aliases. This will only get triggered
             if your query includes <code>@</code> (so, both
             <code>example@example\\.com</code> and <code>example\\+mb@</code>
             will match the address <code>exam.ple+mb@example.com</code>,
             but simply <code>example\\+mb</code> will not).
             <br/>
             Don’t forget you still need to escape these symbols
             (<code>\\.</code> and <code>\\+</code> respectively), otherwise
             they’ll be understood as special regular expression characters!`,
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
