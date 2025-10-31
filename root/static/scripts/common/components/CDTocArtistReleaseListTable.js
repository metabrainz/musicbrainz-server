/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../../../../context.mjs';
import type {ReleaseWithMediumsAndReleaseGroupT}
  from '../../relationship-editor/types.js';

import CDTocReleaseListRow from './CDTocReleaseListRow.js';
import EntityLink from './EntityLink.js';

component CDTocArtistReleaseListTable(
  cdTocTrackCount: number,
  releases: $ReadOnlyArray<ReleaseWithMediumsAndReleaseGroupT>,
) {
  const $c = React.useContext(SanitizedCatalystContext);
  const showTagger = Boolean($c?.session?.tport);
  let currentReleaseGroup = '';
  let countInReleaseGroup = 0;

  return (
    <table className="tbl">
      <thead>
        <tr>
          <th colSpan={2}>{l('Release')}</th>
          <th>{l('Artist')}</th>
          <th>{l('Country') + lp('/', 'and') + l('Date')}</th>
          <th>{l('Label')}</th>
          <th>{l('Catalog#')}</th>
          <th>{l('Barcode')}</th>
          {showTagger ? <th>{lp('Tagger', 'audio file metadata')}</th> : null}
        </tr>
      </thead>
      <tbody>
        {releases.map((release, index) => {
          const releaseGroup = release.releaseGroup;
          const showSubHeader =
            releaseGroup.gid !== currentReleaseGroup;
          currentReleaseGroup = releaseGroup.gid;
          countInReleaseGroup = showSubHeader
            ? 0
            : countInReleaseGroup + 1;

          return (
            <React.Fragment key={index}>
              {showSubHeader ? (
                <tr className="subh">
                  <th colSpan={showTagger ? 9 : 8}>
                    {exp.l(
                      'Release group: {release_group_link}',
                      {
                        release_group_link: (
                          <EntityLink entity={releaseGroup} />
                        ),
                      },
                    )}
                  </th>
                </tr>
              ) : null}
              <CDTocReleaseListRow
                cdTocTrackCount={cdTocTrackCount}
                countInReleaseGroup={countInReleaseGroup}
                release={release}
                showArtists
              />
            </React.Fragment>
          );
        })}
      </tbody>
    </table>
  );
}

export default (hydrate<React.PropsOf<CDTocArtistReleaseListTable>>(
  'div.cd-toc-release-list-table-container',
  CDTocArtistReleaseListTable,
): component(...React.PropsOf<CDTocArtistReleaseListTable>));
