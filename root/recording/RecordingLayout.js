/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import RecordingSidebar
  from '../layout/components/sidebar/RecordingSidebar.js';
import Layout from '../layout/index.js';
import {
  reduceArtistCredit,
} from '../static/scripts/common/immutable-entities.js';

import RecordingHeader from './RecordingHeader.js';

component RecordingLayout(
  children: React$Node,
  entity as recording: RecordingWithArtistCreditT,
  fullWidth: boolean = false,
  page: string,
  title?: string,
) {
  const titleArgs = {
    artist: reduceArtistCredit(recording.artistCredit),
    name: recording.name,
  };
  const mainTitle = recording.video
    ? texp.l('Video “{name}” by {artist}', titleArgs)
    : texp.l('Recording “{name}” by {artist}', titleArgs);
  return (
    <Layout
      title={nonEmpty(title) ? hyphenateTitle(mainTitle, title) : mainTitle}
    >
      <div id="content">
        <RecordingHeader page={page} recording={recording} />
        {children}
      </div>
      {fullWidth ? null : <RecordingSidebar recording={recording} />}
    </Layout>
  );
}


export default RecordingLayout;
