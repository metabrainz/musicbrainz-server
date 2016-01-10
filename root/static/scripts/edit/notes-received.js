// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const setCookie = require('../common/utility/setCookie');

$('#alert-new-edit-notes')
  .on('change', function () {
    setCookie('alert_new_edit_notes', String(this.checked));
  });
