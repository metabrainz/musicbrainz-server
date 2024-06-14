/*
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

import './common/MB/Control/EditList.js';
import './common/MB/Control/EditSummary.js';

import MB from './common/MB.js';

$('.edit-list').each(function () {
  MB.Control.EditSummary(this);
});
