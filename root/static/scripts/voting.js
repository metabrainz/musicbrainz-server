// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const querystring = require('querystring');

require('./common/MB/Control/EditList');
require('./common/MB/Control/EditSummary');

$('.edit-list').each(function () {
  MB.Control.EditSummary(this);
});

$('#only-open-edits').on('change', function () {
  let search = window.location.search.replace(/^\?/, '');
  let args = querystring.parse(search);

  if (this.checked) {
    args.open = 1;
  } else {
    delete args.open;
  }

  this.disabled = true;
  window.location.search = '?' + querystring.stringify(args);
});
