/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');
const {l} = require('../static/scripts/common/i18n');
const EntityHeader = require('../components/EntityHeader');
const ArtistCreditLink = require('../static/scripts/common/components/ArtistCreditLink');
const TaggerIcon = require('../static/scripts/common/components/TaggerIcon');
const {artistCreditFromArray} = require('../static/scripts/common/immutable-entities');

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
    __react: true,
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

module.exports = RecordingHeader;
