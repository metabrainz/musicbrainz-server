/*
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';

import MB from '../common/MB.js';

MB.releaseEditor = {
  rootField: {
    release: ko.observable(),
    makeVotable: ko.observable(false),
    editNote: ko.observable(''),
  },
};

export default MB.releaseEditor;
