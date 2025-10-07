/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityHeader from '../components/EntityHeader.js';
import manifest from '../static/manifest.mjs';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink.js';
import TaggerIcon from '../static/scripts/common/components/TaggerIcon.js';

component RecordingHeader(
  page: string,
  recording: RecordingT,
) {
  const lArgs = {
    artist: <ArtistCreditLink artistCredit={recording.artistCredit} />,
  };
  return (
    <EntityHeader
      entity={recording}
      headerClass="recordingheader"
      page={page}
      preHeader={
        <>
          <TaggerIcon entityType="recording" gid={recording.gid} />
          {manifest('common/components/TaggerIcon', {async: true})}
        </>
      }
      subHeading={recording.video
        ? exp.l('Video by {artist}', lArgs)
        : exp.l('Recording by {artist}', lArgs)}
    />
  );
}

export default RecordingHeader;
