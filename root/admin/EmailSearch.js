/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormRowText from '../components/FormRowText.js';
import FormSubmit from '../components/FormSubmit.js';
import Layout from '../layout/index.js';
import expand2react from '../static/scripts/common/i18n/expand2react.js';

import UserList from './components/UserList.js';

type Props = {
  +form: FormT<{
    +email: ReadOnlyFieldT<string>,
  }>,
  +results?: $ReadOnlyArray<UnsanitizedEditorT>,
};

const EmailSearch = ({
  form,
  results,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Search users by email')}>
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
             by email providers, both of these are ignored from the registered
             email addresses by this search to help you find address aliases.
             Please remove these parts from the user side of the address.
             Don’t forget you still need to escape periods with a backslash
             (<code>\\.</code>) in the host side of your search, otherwise
             they’ll be understood as special regular expression characters!
             For example, <code>user@host\\.name</code> search will match both
             <code>user@host.name</code> and
             <code>us.er+alias@host.name</code>, but neither
             <code>user@sub.host.name</code> nor <code>user@host-name</code>.
             Counter-example: <code>us\\.er\\+alias@host\\.name</code> search
             will match neither <code>us.er+alias@host.name</code> nor
             <code>user@host.name</code> email addresses.`,
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

        {results ? (
          results.length ? (
            <UserList users={results} />
          ) : (
            <p>{l('No results found.')}</p>
          )
        ) : null}
      </form>
    </div>
  </Layout>
);

export default EmailSearch;
