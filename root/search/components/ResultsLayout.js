/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../../layout';
import formatUserDate from '../../utility/formatUserDate';

import SearchForm from './SearchForm';

type Props = {
  +$c: CatalystContextT,
  +children: React.Node,
  +form: SearchFormT,
  +lastUpdated?: string,
};

const ResultsLayout = ({
  $c,
  children,
  form,
  lastUpdated,
}: Props): React.Element<typeof Layout> => (
  <Layout $c={$c} fullWidth title={l('Search Results')}>
    <div id="content">
      <h1>{l('Search Results')}</h1>
      {nonEmpty(lastUpdated) ? (
        <p>
          {exp.l(
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

export default ResultsLayout;
