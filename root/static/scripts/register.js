/*
 * @flow
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

import debounce from './common/utility/debounce';

$(function () {
  function warnAboutEmailAsUsername() {
    const username =
    $('#id-register\\\.username').val();
    const isPossibleEmail = /\w+@\w+\.\w+/.test(username);
    $('#email-username-warning').toggle(isPossibleEmail);
  }

  $('#id-register\\\.username')
    .keyup(debounce(warnAboutEmailAsUsername, 500))
    .change(debounce(warnAboutEmailAsUsername, 500));

  warnAboutEmailAsUsername();
});
