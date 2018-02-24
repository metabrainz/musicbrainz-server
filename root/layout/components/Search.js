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

const TYPE_OPTIONS = {
  annotation: l('Annotation'),
  area: l('Area'),
  artist: l('Artist'),
  cdstub: l('CD Stub'),
  doc: DBDefs.GOOGLE_CUSTOM_SEARCH ? l('Documentation') : null,
  editor: l('Editor'),
  event: l('Event'),
  instrument: l('Instrument'),
  label: l('Label'),
  place: l('Place'),
  recording: l('Recording'),
  release: l('Release'),
  release_group: l('Release Group'),
  series: lp('Series', 'singular'),
  tag: lp('Tag', 'noun'),
  work: l('Work'),
};

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
