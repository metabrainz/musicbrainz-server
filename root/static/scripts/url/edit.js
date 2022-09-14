/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// $FlowIgnore[untyped-import]
import $ from 'jquery';

import './components/UrlRelationshipEditor.js';

import {registerEvents} from '../edit/URLCleanup.js';

$(function () {
  registerEvents($('#id-edit-url\\.url'));
});
