/*
 * @flow
 * Copyright (C) 2018 Shamroy Pellew
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');
const NotFound = require('../components/NotFound');
const {l} = require('../static/scripts/common/i18n');

const TagNotFound = () => (
  <NotFound title={l('Tag Not Used')}>
    <p>
      {l('No MusicBrainz entities have yet been tagged with "{tag}".', {tag: $c.stash.tag})}
    </p>
    <p>
      {l('If you wish to use this tag, please {url|search} for the entity first and apply the tag using the sidebar.',
        {__react: true, search_url: '/search'})}
    </p>
  </NotFound>
);

module.exports = TagNotFound;
