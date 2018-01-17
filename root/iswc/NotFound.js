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

const ISWCNotFound = () => (
  <NotFound title={l('ISWC Not Currently Used')}>
    <p>
      {l('This ISWC is not associated with any works. If you wish to associate it with a work, please {search_url|search for the work} and add it.',
        {__react: true, search_url: '/search'})}
    </p>
  </NotFound>
);

module.exports = ISWCNotFound;
