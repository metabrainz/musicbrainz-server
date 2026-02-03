/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseCatnoList from '../../../../components/ReleaseCatnoList.js';
import ReleaseLabelList from '../../../../components/ReleaseLabelList.js';
import {SanitizedCatalystContext} from '../../../../context.mjs';
import loopParity from '../../../../utility/loopParity.js';
import type {ReleaseWithMediumsAndReleaseGroupT}
  from '../../relationship-editor/types.js';
import formatBarcode from '../utility/formatBarcode.js';
import mediumFormatName from '../utility/mediumFormatName.js';

import ArtistCreditLink from './ArtistCreditLink.js';
import {CDTocTracklistBlock, CDTocTracklistToggle} from './CDTocTracklist.js';
import EntityLink from './EntityLink.js';
import ReleaseEvents from './ReleaseEvents.js';
import TaggerIcon from './TaggerIcon.js';

component CDTocReleaseListRowMediums(
  associatedMedium?: number,
  loopClass: string,
  medium: MediumWithRecordingsT,
) {
  const [hidden, setHidden] = React.useState<boolean>(true);

  function onButtonClick(event: SyntheticMouseEvent<HTMLAnchorElement>) {
    event.preventDefault();
    setHidden(!hidden);
  }

  const cdTocAlreadyAttached =
    Boolean(associatedMedium) && (medium.id === associatedMedium);
  const cannotHaveDiscIds = !medium.may_have_discids;
  const hasLoadedTracks = Boolean(medium.tracks);

  const formatAndPosition = texp.l('{medium_format} {position}', {
    medium_format: mediumFormatName(medium),
    position: medium.position,
  });

  const formatPositionAndName = nonEmpty(medium.name)
    ? texp.l('{medium_format_and_position}: {medium_name}', {
      medium_format_and_position: formatAndPosition,
      medium_name: medium.name,
    }) : formatAndPosition;

  return (
    <>
      <tr className={loopClass}>
        <td className="pos" />
        <td>
          <label>
            {cdTocAlreadyAttached ? (
              <div
                className="cannot-attach-discid icon img"
                title={l('This CDTOC is already attached to this medium.')}
              />
            ) : cannotHaveDiscIds ? (
              <div
                className="cannot-attach-discid icon img"
                title={l(
                  'This medium format cannot have a disc ID attached.',
                )}
              />
            ) : (
              <input name="medium" type="radio" value={medium.id} />
            )}
            {' '}
            {formatPositionAndName}
          </label>
          {hasLoadedTracks ? (
            <CDTocTracklistToggle
              hidden={hidden}
              onButtonClick={onButtonClick}
            />
          ) : null}
          {cdTocAlreadyAttached ? (
            <div className="error">
              {l('This CDTOC is already attached to this medium.')}
            </div>
          ) : null}
        </td>
        <td colSpan={6} />
      </tr>
      {hasLoadedTracks ? (
        <CDTocTracklistBlock hidden={hidden} medium={medium} />
      ) : null}
    </>
  );
}

component CDTocReleaseListRow(
  associatedMedium?: number,
  cdTocTrackCount: number,
  countInReleaseGroup: number,
  release: ReleaseWithMediumsAndReleaseGroupT,
  showArtists: boolean = false,
  wasMbidSearch: boolean = false,
) {
  const $c = React.useContext(SanitizedCatalystContext);

  const loopClass = loopParity(countInReleaseGroup);
  const attachableMediums = release.mediums.filter(medium => (
      medium.cdtoc_track_count === cdTocTrackCount
    ));

  return (
    <>
      <tr className={loopClass}>
        <td colSpan={2}>
          <EntityLink entity={release} />
        </td>
        {showArtists ? (
          <td>
            <ArtistCreditLink artistCredit={release.artistCredit} />
          </td>
        ) : null}
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
        {$c.session?.tport == null ? null : (
          <td>
            <TaggerIcon entityType="release" gid={release.gid} />
          </td>
        )}
      </tr>
      {attachableMediums ? attachableMediums.map((medium) => (
        <CDTocReleaseListRowMediums
          associatedMedium={associatedMedium}
          key={medium.id}
          loopClass={loopClass}
          medium={medium}
        />
      )) : null}
      {wasMbidSearch && attachableMediums?.length === 0 ? (
        <tr className={loopClass}>
          <td className="error" colSpan={7}>
            {l(`None of the mediums on this release can have the given CD TOC
                attached, because they have the wrong number of tracks.`)}
          </td>
        </tr>
      ) : null}
    </>
  );
}

export default CDTocReleaseListRow;
