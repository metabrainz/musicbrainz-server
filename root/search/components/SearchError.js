/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import StatusPage from '../../components/StatusPage';
import TagLookupForm from '../../taglookup/Form';

import SearchForm from './SearchForm';

type Props = {
  +children: React.Node,
  +form: SearchFormT | TagLookupFormT,
};

const SearchError = ({
  children,
  form,
}: Props): React.Element<typeof StatusPage> => (
  <StatusPage title={l('Search Error')}>
    {children}
    <p>
      {exp.l(
        `For assistance in writing effective advanced search queries,
         read the {doc|syntax documentation}.`,
        {doc: '/doc/Indexed_Search_Syntax'},
      )}
    </p>
    {form.name === 'tag-lookup'
      ? <TagLookupForm form={form} />
      : <SearchForm form={form} />}
  </StatusPage>
);

export default SearchError;
