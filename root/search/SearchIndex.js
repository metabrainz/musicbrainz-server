/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout/index.js';
import TagLookupForm from '../taglookup/Form.js';
import OtherLookupForm from '../otherlookup/OtherLookupForm.js';
import type {OtherLookupFormT} from '../otherlookup/types.js';

import SearchForm from './components/SearchForm.js';

type Props = {
  +otherLookupForm: OtherLookupFormT,
  +searchForm: SearchFormT,
  +tagLookupForm: TagLookupFormT,
};

const SearchIndex = ({
  otherLookupForm,
  searchForm,
  tagLookupForm,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Search')}>
    <div id="content">
      <h1>{l('Search')}</h1>
      <SearchForm form={searchForm} />
      <h2>{l('Tag lookup')}</h2>
      <TagLookupForm form={tagLookupForm} />
      <h2>{l('Other lookups')}</h2>
      <OtherLookupForm form={otherLookupForm} />
    </div>
  </Layout>
);

export default SearchIndex;
