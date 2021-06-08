/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import SearchError from '../components/SearchError';

type Props = {
  +form: SearchFormT | TagLookupFormT,
  +query: string,
  +type: string,
};

const NoResults = ({
  form,
  query,
  type,
}: Props): React.Element<typeof SearchError> => (
  <SearchError form={form}>
    <p>
      {exp.l(
        `Sorry, but your query “(<code>{query}</code>)”
         did not find any results of the type “{type}”.
         Please check you used the correct spelling. 
         Sometimes searching for fewer or different words may also help.`,
        {
          query: query,
          type: type,
        },
      )}
    </p>
  </SearchError>
);

export default NoResults;
