/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseCatnoList from '../../../../components/ReleaseCatnoList.js';
import ReleaseLabelList from '../../../../components/ReleaseLabelList.js';
import loopParity from '../../../../utility/loopParity.js';
import formatBarcode from '../utility/formatBarcode.js';
import mediumFormatName from '../utility/mediumFormatName.js';

import ArtistCreditLink from './ArtistCreditLink.js';
import CDTocEditColumn from './CDTocEditColumn.js';
import {CDTocTracklistBlock, CDTocTracklistToggle} from './CDTocTracklist.js';
import EntityLink from './EntityLink.js';
import ReleaseEvents from './ReleaseEvents.js';
import TaggerIcon from './TaggerIcon.js';

component CDTocMediumListRow(
  index: number,
  mediumCDToc: MediumCDTocT,
  releaseMap: {[releaseId: number]: ReleaseT},
  showEditColumn: boolean = false,
  showTagger: boolean = false,
) {
  const loopClass = loopParity(index);
  const editsPendingClass = mediumCDToc.editsPending ? ' mp' : '';
  const medium = mediumCDToc.medium;
  invariant(medium, 'No medium found');
  const release = releaseMap[medium.release_id];
  const releaseMediumCount = release.mediums?.length;
  invariant(releaseMediumCount != null, 'No medium count found');
  const hasLoadedTracks = Boolean(medium.tracks);

  const [hidden, setHidden] = React.useState<boolean>(true);

  function onButtonClick(event: SyntheticMouseEvent<HTMLAnchorElement>) {
    event.preventDefault();
    setHidden(!hidden);
  }

  return (
    <>
      <tr className={loopClass + editsPendingClass}>
        <td>
          {medium.position + '/' + releaseMediumCount}
          {hasLoadedTracks ? (
            <CDTocTracklistToggle
              hidden={hidden}
              onButtonClick={onButtonClick}
            />
          ) : null}
        </td>
        <td>
          <EntityLink entity={release} />
        </td>
        <td>
          <ArtistCreditLink artistCredit={release.artistCredit} />
        </td>
        <td>{mediumFormatName(medium)}</td>
        <td>
          <ReleaseEvents events={release.events} />
        </td>
        <td>
          <ReleaseLabelList labels={release.labels} />
        </td>
        <td>
          <ReleaseCatnoList labels={release.labels} />
        </td>
        <td className="barcode-cell">
          {formatBarcode(release.barcode)}
        </td>
        {showTagger ? (
          <td>
            <TaggerIcon entityType="release" gid={release.gid} />
          </td>
        ) : null}
        {showEditColumn ? (
          <CDTocEditColumn mediumCDToc={mediumCDToc} />
        ) : null}
      </tr>
      {hasLoadedTracks ? (
        <CDTocTracklistBlock hidden={hidden} medium={medium} />
      ) : null}
    </>
  );
}

export default CDTocMediumListRow;
