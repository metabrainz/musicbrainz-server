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

const SEARCH_TYPE_KEY = 'mb_search_type';
const SEARCH_TYPE_TIMESTAMP = 'mb_search_type_timestamp';
const SEARCH_TYPE_PERSIST_KEY = 'mb_search_remember_enabled';
const DEFAULT_TYPE = 'artist';
const TIMEOUT = 48 * 60 * 60 * 1000; // 48 hours

function getSavedType() {
  if (typeof window === 'undefined') return DEFAULT_TYPE;
  if (window.localStorage.getItem(SEARCH_TYPE_PERSIST_KEY) !== 'true') return DEFAULT_TYPE;
  const savedType = window.localStorage.getItem(SEARCH_TYPE_KEY);
  const savedTs = parseInt(window.localStorage.getItem(SEARCH_TYPE_TIMESTAMP), 10);
  if (savedType && savedTs && (Date.now() - savedTs) < TIMEOUT) {
    return savedType;
  }
  return DEFAULT_TYPE;
}

function saveType(type) {
  if (typeof window !== 'undefined') {
    window.localStorage.setItem(SEARCH_TYPE_KEY, type);
    window.localStorage.setItem(SEARCH_TYPE_TIMESTAMP, Date.now().toString());
  }
}

type SearchOptionValueT =
  (() => string) | null;
type SearchOptionGroupT = {
  +[optionName: string]: SearchOptionValueT,
  ...
};
const TYPE_OPTION_GROUPS: $ReadOnlyArray<SearchOptionGroupT> = [
  { artist: N_l('Artist') },
  {
    event: N_l('Event'),
    recording: N_l('Recording'),
    release: N_l('Release'),
    release_group: N_l('Release group'),
    series: N_lp('Series', 'singular'),
    work: N_l('Work'),
  },
  {
    area: N_l('Area'),
    instrument: N_l('Instrument'),
    label: N_l('Label'),
    place: N_l('Place'),
  },
  {
    annotation: N_l('Annotation'),
    tag: N_lp('Tag', 'noun, folksonomy'),
  },
  { cdstub: N_l('CD stub') },
  { editor: N_l('Editor') },
  { doc: GOOGLE_CUSTOM_SEARCH ? N_l('Documentation') : null },
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

function SearchOptions({type, onTypeChange}) {
  return (
    <select
      id="headerid-type"
      name="type"
      value={type}
      onChange={onTypeChange}
      required
    >
      {TYPE_OPTION_GROUPS.map((group) =>
        Object.entries(group)
          .sort(compareTypeOptionEntries)
          .map(([key, option]) => {
            const text = localizedTypeOption(option);
            if (!text) return null;
            return (
              <option key={key} value={key}>
                {text}
              </option>
            );
          })
      )}
    </select>
  );
}

function Search() {
  const [rememberEnabled, setRememberEnabled] = React.useState(
    typeof window !== 'undefined' && window.localStorage.getItem(SEARCH_TYPE_PERSIST_KEY) === 'true'
  );
  const [type, setType] = React.useState(getSavedType());

  // Restore from localStorage on mount (cross-tab sync)
  React.useEffect(() => {
    setType(getSavedType());
  }, []);

  function handleTypeChange(e) {
    setType(e.target.value);
    if (rememberEnabled) saveType(e.target.value);
  }

  function handleRememberToggle(e) {
    setRememberEnabled(e.target.checked);
    if (typeof window !== 'undefined') {
      window.localStorage.setItem(SEARCH_TYPE_PERSIST_KEY, e.target.checked.toString());
      if (!e.target.checked) {
        window.localStorage.removeItem(SEARCH_TYPE_KEY);
        window.localStorage.removeItem(SEARCH_TYPE_TIMESTAMP);
      }
    }
  }

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
      <SearchOptions type={type} onTypeChange={handleTypeChange} />
      <label style={{marginLeft: '1em'}}>
        <input
          type="checkbox"
          checked={rememberEnabled}
          onChange={handleRememberToggle}
        />
        Remember last used search type (48h)
      </label>
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
