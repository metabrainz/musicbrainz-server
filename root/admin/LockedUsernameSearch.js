/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormRowCheckbox from '../components/FormRowCheckbox';
import FormRowText from '../components/FormRowText';
import FormSubmit from '../components/FormSubmit';
import Layout from '../layout';
import expand2react from '../static/scripts/common/i18n/expand2react';
import bracketed from '../static/scripts/common/utility/bracketed';

type Props = {
  +form: FormT<{
    +use_regular_expression: ReadOnlyFieldT<boolean>,
    +username: ReadOnlyFieldT<string>,
  }>,
  +results?: $ReadOnlyArray<string>,
  +showResults: boolean,
};

const LockedUsernameSearch = ({
  form,
  results,
  showResults,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title="Search locked usernames">
    <div id="content">
      <h1>{'Search locked usernames'}</h1>

      <form action="/admin/locked-usernames/search" method="post">
        <p>
          {expand2react(
            'Enter a username or a {link|POSIX regular expression}.',
            {
              link: 'https://www.postgresql.org/docs/12/' +
                'functions-matching.html#FUNCTIONS-POSIX-REGEXP',
            },
          )}
        </p>

        <FormRowText
          field={form.field.username}
          label="Username:"
          size={50}
          uncontrolled
        />

        <FormRowCheckbox
          field={form.field.use_regular_expression}
          label="Search using regular expression"
          uncontrolled
        />

        <div className="row no-label">
          <FormSubmit
            label="Search"
            name="lockedusernamesearch.submit"
            value="1"
          />
        </div>

        {showResults ? (
          <>
            <h3>{'Matching locked names:'}</h3>
            {results?.length ? (
              <ul>
                {results.map(result => (
                  <li key={result}>
                    {result}
                    {' '}
                    {bracketed(
                      <a href={`/admin/locked-usernames/unlock/${result}`}>
                        {'unlock'}
                      </a>,
                    )}
                  </li>
                ))}
              </ul>
            ) : (
              <p>
                {'No locked usernames matched your search.'}
              </p>
            )}
          </>
        ) : null}
      </form>
    </div>
  </Layout>
);

export default LockedUsernameSearch;
