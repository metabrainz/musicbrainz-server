/*
 * @flow strict-local
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import SearchIcon from '../../static/scripts/common/components/SearchIcon';
import DBDefs from '../../static/scripts/common/DBDefs';
import {compare} from '../../static/scripts/common/i18n';

type SearchOptionValueT =
  (() => string) | null;

type SearchOptionGroupT = {
  +[optionName: string]: SearchOptionValueT,
  ...
};

const TYPE_OPTION_GROUPS: $ReadOnlyArray<SearchOptionGroupT> = [
  {
    artist:        N_l('Artist'),
  },
  { // musical production
    event:         N_l('Event'),
    recording:     N_l('Recording'),
    release:       N_l('Release'),
    release_group: N_l('Release Group'),
    series:        N_lp('Series', 'singular'),
    work:          N_l('Work'),
  },
  { // other core entities
    area:          N_l('Area'),
    instrument:    N_l('Instrument'),
    label:         N_l('Label'),
    place:         N_l('Place'),
  },
  { // derived data
    annotation:    N_l('Annotation'),
    tag:           N_lp('Tag', 'noun'),
  },
  {
    cdstub:        N_l('CD Stub'),
  },
  {
    editor:        N_l('Editor'),
  },
  {
    doc:           DBDefs.GOOGLE_CUSTOM_SEARCH ? N_l('Documentation') : null,
  },
];

function localizedTypeOption(option: SearchOptionValueT) {
  return option ? option() : '';
}

function compareTypeOptionEntries(
  a: [string, SearchOptionValueT],
  b: [string, SearchOptionValueT],
) {
  return compare(
    localizedTypeOption(a[1]),
    localizedTypeOption(b[1]),
  );
}

const SearchOptions = () => (
  <select className="form-control" id="headerid-type" name="type">
    {TYPE_OPTION_GROUPS.map((group) => (
      Object.entries(group)
        // $FlowIssue[incompatible-call]
        .sort(compareTypeOptionEntries)
        .map(([key: string, option: SearchOptionValueT]) => {
          // $FlowIssue[incompatible-call]
          const text = localizedTypeOption(option);
          if (!text) {
            return null;
          }
          return (
            <option key={key} value={key}>
              {text}
            </option>
          );
        })
      ))}
  </select>
);

const Search = (): React.Element<'form'> => (
  <form action="/search" className="d-flex" method="get">
    <input
      aria-label="Search"
      className="form-control"
      id="headerid-query"
      name="query"
      placeholder={l('Search')}
      required
      type="search"
    />
    {' '}
    <SearchOptions />
    {' '}
    <input
      id="headerid-method"
      name="method"
      type="hidden"
      value="indexed"
    />
    <button className="btn btn-primary me-4" type="submit">
      <SearchIcon />
    </button>
  </form>
);

export default Search;
