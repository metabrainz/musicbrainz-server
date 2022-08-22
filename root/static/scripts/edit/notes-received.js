/*
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

import setCookie from '../common/utility/setCookie.js';

$('#alert-new-edit-notes')
  .on('change', function () {
    setCookie('alert_new_edit_notes', String(this.checked));
  });
