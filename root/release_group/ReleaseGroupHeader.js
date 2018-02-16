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
const {artistCreditFromArray} = require('../static/scripts/common/immutable-entities');

type Props = {|
  page: string,
  releaseGroup: ReleaseGroupT,
|};

const ReleaseGroupHeader = ({releaseGroup, page}: Props) => {
  const artistCredit = (
    <ArtistCreditLink
      artistCredit={artistCreditFromArray(releaseGroup.artistCredit)}
    />
  );
  return (
    <EntityHeader
      entity={releaseGroup}
      headerClass="rgheader"
      page={page}
      subHeading={l('Release group by {artist}', {
        __react: true,
        artist: artistCredit,
      })}
    />
  );
};

module.exports = ReleaseGroupHeader;
