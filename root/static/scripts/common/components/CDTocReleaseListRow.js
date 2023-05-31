/*
 * @flow strict-local
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
import MediumTracklist from '../../../../medium/MediumTracklist.js';
import loopParity from '../../../../utility/loopParity.js';
import type {ReleaseWithMediumsAndReleaseGroupT}
  from '../../relationship-editor/types.js';
import bracketed from '../utility/bracketed.js';
import formatBarcode from '../utility/formatBarcode.js';
import mediumFormatName from '../utility/mediumFormatName.js';

import ArtistCreditLink from './ArtistCreditLink.js';
import EntityLink from './EntityLink.js';
import ReleaseEvents from './ReleaseEvents.js';
import TaggerIcon from './TaggerIcon.js';

type Props = {
  +associatedMedium?: number,
  +cdTocTrackCount: number,
  +countInReleaseGroup: number,
  +release: ReleaseWithMediumsAndReleaseGroupT,
  +showArtists?: boolean,
  +wasMbidSearch?: boolean,
};

const CDTocReleaseListRow = ({
  associatedMedium,
  cdTocTrackCount,
  countInReleaseGroup,
  release,
  showArtists = false,
  wasMbidSearch = false,
}: Props): React.Element<typeof React.Fragment> => {
  const $c = React.useContext(SanitizedCatalystContext);

  const [hidden, setHidden] = React.useState<boolean>(true);

  function onButtonClick(event: SyntheticMouseEvent<HTMLAnchorElement>) {
    event.preventDefault();
    hidden ? setHidden(false) : setHidden(true);
  }

  const attachableMediums = release.mediums.filter(medium => (
      medium.cdtoc_track_count === cdTocTrackCount
    ));

  return (
    <>
      <tr className={loopParity(countInReleaseGroup)}>
        <td colSpan="2">
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
      {attachableMediums ? attachableMediums.map((medium, index) => {
        const cdTocAlreadyAttached =
          Boolean(associatedMedium) && (medium.id === associatedMedium);
        const cannotHaveDiscIds = !medium.may_have_discids;
        const hasLoadedTracks = Boolean(medium.tracks);

        return (
          <React.Fragment key={index}>
            <tr className={loopParity(countInReleaseGroup)}>
              <td className="pos" />
              <td>
                <label>
                  {cdTocAlreadyAttached ? (
                    <div
                      className="cannot-attach-discid icon img"
                      title={l(
                        'This CDTOC is already attached to this medium.',
                      )}
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
                  {mediumFormatName(medium)}
                  {' '}
                  {medium.position}
                  {nonEmpty(medium.name) ? (
                    <>
                      {': '}
                      {medium.name}
                    </>
                  ) : null}
                </label>
                {hasLoadedTracks ? (
                  <>
                    {' '}
                    <small>
                      {bracketed(
                        <a
                          className="toggle"
                          onClick={onButtonClick}
                          style={{cursor: 'pointer'}}
                        >
                          {hidden ? l('show tracklist') : l('hide tracklist')}
                        </a>,
                      )}
                    </small>
                  </>
                ) : null}
                {cdTocAlreadyAttached ? (
                  <div className="error">
                    {l('This CDTOC is already attached to this medium.')}
                  </div>
                ) : null}
              </td>
              <td colSpan="6" />
            </tr>
            {hasLoadedTracks ? (
              <tr
                className="tracklist"
                style={hidden ? {display: 'none'} : {}}
              >
                <td />
                <td colSpan="6">
                  <table style={{borderCollapse: 'collapse'}}>
                    <tbody>
                      <MediumTracklist tracks={medium.tracks} />
                    </tbody>
                  </table>
                </td>
              </tr>
            ) : null}
          </React.Fragment>
        );
      }) : null}
      {wasMbidSearch && attachableMediums?.length === 0 ? (
        <tr className={loopParity(countInReleaseGroup)}>
          <td className="error" colSpan="7">
            {l(`None of the mediums on this release can have the given CD TOC
                attached, because they have the wrong number of tracks.`)}
          </td>
        </tr>
      ) : null}
    </>
  );
};

export default CDTocReleaseListRow;
