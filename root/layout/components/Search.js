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
import {l, lp} from '../../static/scripts/common/i18n';

/* eslint-disable sort-keys, flowtype/sort-keys */
const TYPE_OPTIONS = {
  artist:        l('Artist'),
  release_group: l('Release Group'),
  release:       l('Release'),
  recording:     l('Recording'),
  work:          l('Work'),
  label:         l('Label'),
  area:          l('Area'),
  place:         l('Place'),
  annotation:    l('Annotation'),
  cdstub:        l('CD Stub'),
  editor:        l('Editor'),
  tag:           lp('Tag', 'noun'),
  instrument:    l('Instrument'),
  series:        lp('Series', 'singular'),
  event:         l('Event'),
  doc:           DBDefs.GOOGLE_CUSTOM_SEARCH ? l('Documentation') : null,
};
/* eslint-enable sort-keys, flowtype/sort-keys */

const searchOptions = (
  <select id="headerid-type" name="type">
    {Object.keys(TYPE_OPTIONS).map(function (key, index) {
      const text = TYPE_OPTIONS[key];
      if (!text) {
        return null;
      }
      return <option key={index} value={key}>{text}</option>;
    })}
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
