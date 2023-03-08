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
};

const UriTooLarge = ({
  form,
}: Props): React$Element<typeof SearchError> => (
  <SearchError form={form}>
    <p>{l('Sorry, your query was too large.')}</p>
  </SearchError>
);

export default UriTooLarge;
