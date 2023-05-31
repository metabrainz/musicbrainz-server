/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../../../../context.mjs';
import type {SearchResultT} from '../../../../search/types.js';
import type {ReleaseWithMediumsAndReleaseGroupT}
  from '../../relationship-editor/types.js';

import CDTocReleaseListRow from './CDTocReleaseListRow.js';
import EntityLink from './EntityLink.js';

type Props = {
  +associatedMedium?: number,
  +cdTocTrackCount: number,
  +results: $ReadOnlyArray<
    SearchResultT<ReleaseWithMediumsAndReleaseGroupT>
  >,
  +wasMbidSearch?: boolean,
};

const CDTocReleaseListTable = ({
  associatedMedium,
  cdTocTrackCount,
  results,
  wasMbidSearch = false,
}: Props): React.Element<'table'> => {
  const $c = React.useContext(SanitizedCatalystContext);
  const showTagger = Boolean($c?.session?.tport);
  let currentReleaseGroup = '';
  let countInReleaseGroup = 0;

  return (
    <table className="tbl">
      <thead>
        <tr>
          <th colSpan="2">{l('Release')}</th>
          <th>{l('Artist')}</th>
          <th>{l('Country') + lp('/', 'and') + l('Date')}</th>
          <th>{l('Label')}</th>
          <th>{l('Catalog#')}</th>
          <th>{l('Barcode')}</th>
          {showTagger ? <th>{l('Tagger')}</th> : null}
        </tr>
      </thead>
      <tbody>
        {results.map((result, index) => {
          const release = result.entity;
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
                  <th colSpan={showTagger ? '9' : '8'}>
                    {exp.l(
                      'Release Group: {release_group_link}',
                      {
                        release_group_link: (
                          <EntityLink
                            entity={releaseGroup}
                          />
                        ),
                      },
                    )}
                  </th>
                </tr>
              ) : null}
              <CDTocReleaseListRow
                associatedMedium={associatedMedium}
                cdTocTrackCount={cdTocTrackCount}
                countInReleaseGroup={countInReleaseGroup}
                release={release}
                showArtists
                wasMbidSearch={wasMbidSearch}
              />
            </React.Fragment>
          );
        })}
      </tbody>
    </table>
  );
};

export default (hydrate<Props>(
  'div.cd-toc-release-list-table-container',
  CDTocReleaseListTable,
): React.AbstractComponent<Props, void>);
