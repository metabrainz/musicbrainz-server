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
import {compare, l, lp} from '../../static/scripts/common/i18n';

const TYPE_OPTION_GROUPS = [
  {
    artist:        l('Artist'),
  },
  { // musical production
    event:         l('Event'),
    recording:     l('Recording'),
    release:       l('Release'),
    release_group: l('Release Group'),
    series:        lp('Series', 'singular'),
    work:          l('Work'),
  },
  { // other core entities
    area:          l('Area'),
    instrument:    l('Instrument'),
    label:         l('Label'),
    place:         l('Place'),
  },
  { // derived data
    annotation:    l('Annotation'),
    tag:           lp('Tag', 'noun'),
  },
  {
    cdstub:        l('CD Stub'),
  },
  {
    editor:        l('Editor'),
  },
  {
    doc:           DBDefs.GOOGLE_CUSTOM_SEARCH ? l('Documentation') : null,
  },
];

const searchOptions = (
  <select id="headerid-type" name="type">
    {TYPE_OPTION_GROUPS.map(<TogT: {}>(group: TogT, groupIndex) => (
      Object.keys(group).sort(function (a, b) {
        return compare(group[a], group[b]);
      }).map(function (key, index) {
        const text = group[key];
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
