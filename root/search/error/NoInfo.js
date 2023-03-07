/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import SearchError from '../components/SearchError.js';

type Props = {
  +form: SearchFormT | TagLookupFormT,
  +query: string,
};

const NoInfo = ({
  form,
  query,
}: Props): React$Element<typeof SearchError> => (
  <SearchError form={form}>
    <p>
      {exp.l(
        `Sorry, your query “(<code>{query}</code>)” does not contain
         enough information to carry out a search.`,
        {query: query},
      )}
    </p>
  </SearchError>
);

export default NoInfo;
