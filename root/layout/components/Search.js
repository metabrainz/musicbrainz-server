/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import * as manifest from '../../static/manifest';
import * as DBDefs from '../../static/scripts/common/DBDefs';
import {compare, l, lp, N_l, N_lp} from '../../static/scripts/common/i18n';

const TYPE_OPTION_GROUPS = [
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

function localizedTypeOption(group, key) {
  return (key === 'series' || key === 'tag') ? lp(group[key])
    : (key === 'doc' && group[key] === null) ? null
      : l(group[key]);
}

const searchOptions = (
  <select id="headerid-type" name="type">
    {TYPE_OPTION_GROUPS.map(<TogT: {}>(group: TogT, groupIndex) => (
      Object.keys(group).sort(function (a, b) {
        return compare(
          localizedTypeOption(group, a),
          localizedTypeOption(group, b),
        );
      }).map(function (key, index) {
        const text = localizedTypeOption(group, key);
        if (!text) {
          return null;
        }
        return <option key={groupIndex + '.' + index} value={key}>{text}</option>;
      })
    ))}
  </select>
);

const Search = () => (
  <form action="/search" method="get">
    <input
      id="headerid-query"
      name="query"
      placeholder={l('Search')}
      required
      type="text"
    />
    {' '}{searchOptions}{' '}
    <input
      id="headerid-method"
      name="method"
      type="hidden"
      value="indexed"
    />
    <button type="submit">
      <img alt="" src={manifest.pathTo('/images/icons/search.svg')} />
    </button>
  </form>
);

export default Search;
