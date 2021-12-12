/*
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

import MB from '../../common/MB';

MB.initializeToggleEnded = function (formID) {
  $(function () {
    const endYear = '#' + formID + '\\.period\\.end_date\\.year';
    const ended = '#' + formID + '\\.period\\.ended';

    const wasEnded = $(ended).prop('checked');

    function toggleEnded() {
      const autoEnded = $(endYear).val() != '';
      $(ended).prop('checked', autoEnded || wasEnded);
      $(ended).prop('disabled', autoEnded);
    }

    $(endYear).keyup(toggleEnded).change(toggleEnded);
    toggleEnded();
  });
};

export default MB.initializeToggleEnded;
