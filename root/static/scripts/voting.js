/*
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import querystring from 'querystring';

import $ from 'jquery';

import MB from './common/MB';
import './common/MB/Control/EditList';
import './common/MB/Control/EditSummary';

$('.edit-list').each(function () {
  MB.Control.EditSummary(this);
});

$('#only-open-edits').on('change', function () {
  const search = window.location.search.replace(/^\?/, '');
  const args = querystring.parse(search);

  if (this.checked) {
    args.open = 1;
  } else {
    delete args.open;
  }

  this.disabled = true;
  window.location.search = '?' + querystring.stringify(args);
});
