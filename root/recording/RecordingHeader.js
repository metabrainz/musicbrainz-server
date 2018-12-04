/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {l} from '../static/scripts/common/i18n';
import EntityHeader from '../components/EntityHeader';
import ArtistCreditLink from '../static/scripts/common/components/ArtistCreditLink';
import TaggerIcon from '../static/scripts/common/components/TaggerIcon';
import {artistCreditFromArray} from '../static/scripts/common/immutable-entities';

type Props = {|
  +page: string,
  +recording: RecordingT,
|};

const RecordingHeader = ({recording, page}: Props) => {
  const artistCredit = (
    <ArtistCreditLink
      artistCredit={artistCreditFromArray(recording.artistCredit)}
    />
  );
  const lArgs = {
    artist: artistCredit,
  };
  return (
    <EntityHeader
      entity={recording}
      headerClass="recordingheader"
      page={page}
      preHeader={<TaggerIcon entity={recording} />}
      subHeading={recording.video ? l('Video by {artist}', lArgs) : l('Recording by {artist}', lArgs)}
    />
  );
};

export default RecordingHeader;
