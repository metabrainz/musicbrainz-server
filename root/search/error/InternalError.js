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
  +error: string,
  +form: SearchFormT | TagLookupFormT,
};

const InternalError = ({
  error,
  form,
}: Props): React$Element<typeof SearchError> => (
  <SearchError form={form}>
    <p>
      {l(`The search server could not fulfill your request
          due to an internal error. This is usually only
          temporary, so please retry your search again later.`)}
    </p>
    <p>
      {exp.l(
        `Below is the error information. If you wish to file
         a bug report, you may do so at {bugs|our bug tracker}.
         The information below will help, so please be sure to include it!`,
        {bugs: 'http://tickets.metabrainz.org/'},
      )}
    </p>
    <pre>
      {error}
    </pre>
  </SearchError>
);

export default InternalError;
