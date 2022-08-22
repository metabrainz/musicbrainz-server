/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityHeader from '../components/EntityHeader.js';
import * as manifest from '../static/manifest.mjs';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import TaggerIcon from '../static/scripts/common/components/TaggerIcon.js';
import bracketed from '../static/scripts/common/utility/bracketed.js';

type Props = {
  +page?: string,
  +release: ReleaseT,
};

const ReleaseHeader = ({
  release,
  page,
}: Props): React.Element<typeof EntityHeader> => {
  const rgLink = release.releaseGroup
    ? texp.ln(
      'see all versions of this release, {count} available',
      'see all versions of this release, {count} available',
      release.releaseGroup.release_count,
      {count: release.releaseGroup.release_count},
    ) : null;
  const subHeading = (
    <>
      {exp.l('Release by {artist}', {
        artist: <ArtistCreditLink artistCredit={release.artistCredit} />,
      })}
      {' '}
      {release.releaseGroup ? (
        <span className="small">
          {bracketed(
            <EntityLink
              content={rgLink}
              entity={release.releaseGroup}
              nameVariation={false}
            />,
          )}
        </span>
      ) : null}
    </>
  );
  return (
    <EntityHeader
      entity={release}
      headerClass="releaseheader"
      page={page}
      preHeader={
        <>
          <TaggerIcon entityType="release" gid={release.gid} />
          {manifest.js('common/components/TaggerIcon', {async: 'async'})}
        </>
      }
      subHeading={subHeading}
    />
  );
};

export default ReleaseHeader;
