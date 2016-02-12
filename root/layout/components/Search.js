// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const React = require('react');

const {l, lp} = require('../../static/scripts/common/i18n');

let TYPE_OPTIONS = {
  artist:         l('Artist'),
  release_group:  l('Release Group'),
  release:        l('Release'),
  recording:      l('Recording'),
  work:           l('Work'),
  label:          l('Label'),
  area:           l('Area'),
  place:          l('Place'),
  annotation:     l('Annotation'),
  cdstub:         l('CD Stub'),
  editor:         l('Editor'),
  freedb:         l('FreeDB'),
  tag:            lp('Tag', 'noun'),
  instrument:     l('Instrument'),
  series:         lp('Series', 'singular'),
  event:          l('Event')
};

if (process.env.GOOGLE_CUSTOM_SEARCH) {
  TYPE_OPTIONS.doc = l('Documentation');
}

const searchOptions = (
  <select id="headerid-type" name="type">
    {Object.keys(TYPE_OPTIONS).map((key, index) =>
      <option key={index} value={key}>{TYPE_OPTIONS[key]}</option>
    )}
  </select>
);

const Search = () => (
  <form action="/search" method="get">
    <input type="text" id="headerid-query" name="query" placeholder={l('Search')} required={true} />
    {' '}{searchOptions}{' '}
    <input type="hidden" id="headerid-method" name="method" value="indexed" />
    <button type="submit">
      <img src="/static/images/icons/search.svg" />
    </button>
  </form>
);

module.exports = Search;
