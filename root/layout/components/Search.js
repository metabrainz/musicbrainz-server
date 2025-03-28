/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import SearchIcon from '../../static/scripts/common/components/SearchIcon.js';
import {GOOGLE_CUSTOM_SEARCH} from '../../static/scripts/common/DBDefs.mjs';
import {compare} from '../../static/scripts/common/i18n.js';

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
    release_group: N_l('Release group'),
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
    tag:           N_lp('Tag', 'noun, folksonomy'),
  },
  {
    cdstub:        N_l('CD stub'),
  },
  {
    editor:        N_l('Editor'),
  },
  {
    doc:           GOOGLE_CUSTOM_SEARCH ? N_l('Documentation') : null,
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

component SearchOptions() {
  return (
    <select id="headerid-type" name="type">
      {TYPE_OPTION_GROUPS.map((group) => (
        Object.entries(group)
          .sort(compareTypeOptionEntries)
          .map(([key, option]) => {
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
}

component Search() {
  return (
    <form action="/search" method="get">
      <input
        id="headerid-query"
        name="query"
        placeholder={l('Search')}
        required
        type="text"
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
      <button type="submit">
        <SearchIcon />
      </button>
    </form>
  );
}

export default Search;
