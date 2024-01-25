/*
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';
import test from 'tape';

import '../../release-editor/actions.js';

import MB from '../../common/MB.js';
import fields from '../../release-editor/fields.js';
import {
  watchTrackForChanges,
} from '../../release-editor/recordingAssociation.js';

MB.mediumFormatDates = {1: 1982};

test('MBS-13327: Recording is not unlinked when removing feat. artists', function (t) {
  t.plan(1);

  const release = new fields.Release({
    name: '',
  });

  const medium = new fields.Medium({
    name: '',
    position: 1,
    format_id: null,
    tracks: [],
  }, release);

  const track = new fields.Track({
    artistCredit: {
      names: [
        {
          artist: {
            gid: '4a3818b4-0d35-445c-988e-e62770b196d4',
            name: 'Qaballah Steppers',
          },
          joinPhrase: '',
          name: 'Qaballah Steppers',
        },
      ],
    },
    name: 'Brooklyn Rumba (feat. Dr. Israel & Marc Ribot)',
    recording: {
      gid: 'ce4c77f3-12f9-49d2-a8a0-8e42cbabf138',
      name: 'Brooklyn Rumba (feat. Dr. Israel & Marc Ribot)',
    },
  }, medium);

  ko.computed(function () {
    watchTrackForChanges(track);
  });

  track.name('Brooklyn Rumba');

  t.equal(
    track.recordingGID(),
    'ce4c77f3-12f9-49d2-a8a0-8e42cbabf138',
    'recording is still linked after removing feat. artists from the title',
  );
});
