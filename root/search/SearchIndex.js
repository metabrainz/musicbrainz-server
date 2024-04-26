/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';
import OtherLookupForm from '../otherlookup/OtherLookupForm.js';
import type {OtherLookupFormT} from '../otherlookup/types.js';
import TagLookupForm from '../taglookup/Form.js';

import SearchForm from './components/SearchForm.js';

component SearchIndex(
  otherLookupForm: OtherLookupFormT,
  searchForm: SearchFormT,
  tagLookupForm: TagLookupFormT,
) {
  return (
    <Layout fullWidth title={l('Search')}>
      <div id="content">
        <h1>{l('Search')}</h1>
        <SearchForm form={searchForm} />
        <h2>{lp('Tag lookup', 'audio file metadata')}</h2>
        <TagLookupForm form={tagLookupForm} />
        <h2>{l('Other lookups')}</h2>
        <OtherLookupForm form={otherLookupForm} />
      </div>
    </Layout>
  );
}

export default SearchIndex;
