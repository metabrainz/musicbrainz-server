/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {isPerfectMatch} from '../cdtoc/utils.js';
import {CatalystContext} from '../context.mjs';
import CDTocLink
  from '../static/scripts/common/components/CDTocLink.js';
import {groupBy} from '../static/scripts/common/utility/arrays.js';
import formatTrackLength
  from '../static/scripts/common/utility/formatTrackLength.js';
import mediumFormatName
  from '../static/scripts/common/utility/mediumFormatName.js';
import loopParity from '../utility/loopParity.js';

import ReleaseLayout from './ReleaseLayout.js';

component CDTocRow(
  index: number,
  mediumCDToc: MediumCDTocT,
  showEditColumn: boolean,
) {
  const cdtoc = mediumCDToc.cdtoc;
  const medium = mediumCDToc.medium;
  if (!medium) {
    throw new Error('Expected a medium');
  }

  return (
    <tr className={loopParity(index)}>
      <td>
        {mediumCDToc.editsPending ? (
          <span className="mp">
            <code><CDTocLink cdToc={cdtoc} /></code>
          </span>
        ) : (
          <code><CDTocLink cdToc={cdtoc} /></code>
        )}
      </td>
      <td>{cdtoc.track_count}</td>
      <td>{formatTrackLength(cdtoc.length)}</td>
      {showEditColumn ? (
        <td>
          {isPerfectMatch(medium, cdtoc) ? null : (
            <>
              <a
                href={
                  `/cdtoc/${cdtoc.discid}/set-durations?medium=${medium.id}`
                }
              >
                {l('Set track lengths')}
              </a>
              {' | '}
            </>
          )}
          <a
            href={`/cdtoc/remove?medium_id=${medium.id}&cdtoc_id=${cdtoc.id}`}
          >
            {l('Remove')}
          </a>
          {' | '}
          <a href={`/cdtoc/move?toc=${mediumCDToc.id}`}>
            {l('Move')}
          </a>
        </td>
      ) : null}
    </tr>
  );
}

component DiscIds(
  hasCDTocs: boolean,
  mediumCDTocs: $ReadOnlyArray<MediumCDTocT>,
  release: ReleaseT,
) {
  const $c = React.useContext(CatalystContext);
  const showEditColumn = Boolean($c.user);

  const groupedMediumCDTocs = groupBy(mediumCDTocs, x => x.medium?.id ?? 0);

  return (
    <ReleaseLayout entity={release} page="discids" title={l('Disc IDs')}>
      <h2>{l('Disc IDs')}</h2>
      {hasCDTocs ? (
        <table className="tbl">
          <thead>
            <tr>
              <th>{l('Disc ID')}</th>
              <th>{l('Tracks')}</th>
              <th>{l('Length')}</th>
              {showEditColumn ? (
                <th>{lp('Edit', 'verb, header')}</th>
              ) : null}
            </tr>
          </thead>
          <tbody>
            {/* $FlowIgnore[incompatible-use] has cdtocs so has mediums */}
            {release.mediums.map(medium => {
              const mediumCDTocs = groupedMediumCDTocs.get(medium.id) ?? [];
              return (
                <React.Fragment key={medium.id}>
                  <tr className="subh">
                    <td colSpan={showEditColumn ? 4 : 3}>
                      <a
                        href={`/medium/${medium.gid}`}
                        id={`disc${medium.position}`}
                      >
                        {mediumFormatName(medium)}
                        {' '}
                        {medium.position}
                        {nonEmpty(medium.name) ? ': ' + medium.name : null}
                      </a>
                    </td>
                  </tr>
                  {mediumCDTocs.map((mediumCDToc, index) => (
                    <CDTocRow
                      index={index}
                      key={mediumCDToc.id}
                      mediumCDToc={mediumCDToc}
                      showEditColumn={showEditColumn}
                    />
                  ))}
                </React.Fragment>
              );
            })}
          </tbody>
        </table>
      ) : release.may_have_discids /*:: === true */ ? (
        <p>
          {exp.l(
            `There are no disc IDs attached to this release;
             to find out more about how to add one,
             see {doc|How to Add Disc IDs}.`,
            {doc: '/doc/How_to_Add_Disc_IDs'},
          )}
        </p>
      ) : (
        <p>{l('This release has no mediums that can have disc IDs.')}</p>
      )}
    </ReleaseLayout>
  );
}

export default DiscIds;
