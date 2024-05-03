/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context.mjs';
import Layout from '../../layout/index.js';
import formatUserDate from '../../utility/formatUserDate.js';

import SearchForm from './SearchForm.js';

component ResultsLayout(
  children: React$Node,
  form: SearchFormT,
  lastUpdated?: string,
) {
  const $c = React.useContext(CatalystContext);

  return (
    <Layout fullWidth title={l('Search results')}>
      <div id="content">
        <h1>{l('Search results')}</h1>
        {nonEmpty(lastUpdated) ? (
          <p>
            {texp.l(
              'Last updated: {date}',
              {date: formatUserDate($c, lastUpdated)},
            )}
          </p>
        ) : null}
        {children}
        <SearchForm form={form} />
      </div>
    </Layout>
  );
}

export default ResultsLayout;
