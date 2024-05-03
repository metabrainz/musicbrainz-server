/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import CleanupBanner from '../components/CleanupBanner.js';
import PaginatedResults from '../components/PaginatedResults.js';
import ReleaseCatnoList from '../components/ReleaseCatnoList.js';
import ReleaseLabelList from '../components/ReleaseLabelList.js';
import {CatalystContext} from '../context.mjs';
import * as manifest from '../static/manifest.mjs';
import Annotation from '../static/scripts/common/components/Annotation.js';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import Relationships
  from '../static/scripts/common/components/Relationships.js';
import ReleaseEvents
  from '../static/scripts/common/components/ReleaseEvents.js';
import TaggerIcon from '../static/scripts/common/components/TaggerIcon.js';
import WikipediaExtract
  from '../static/scripts/common/components/WikipediaExtract.js';
import formatBarcode from '../static/scripts/common/utility/formatBarcode.js';
import FormRow from '../static/scripts/edit/components/FormRow.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';
import loopParity from '../utility/loopParity.js';
import releaseGroupType from '../utility/releaseGroupType.js';
import {returnToCurrentPage} from '../utility/returnUri.js';

import ReleaseGroupLayout from './ReleaseGroupLayout.js';

function buildReleaseStatusTable(
  $c: CatalystContextT,
  releaseStatusGroup: $ReadOnlyArray<ReleaseT>,
  releaseGroupCreditId: number | void,
) {
  const status = releaseStatusGroup[0].status;
  return (
    <React.Fragment key={status ? status.name : 'no-status'}>
      <tr className="subh">
        {$c.user ? <th /> : null}
        <th colSpan={$c.session?.tport == null ? 8 : 9}>
          {status?.name
            ? lp_attributes(status.name, 'release_status')
            : lp('(unknown)', 'release status')}
        </th>
      </tr>
      {releaseStatusGroup.map((release, index) => (
        <tr className={loopParity(index)} key={release.id}>
          {$c.user
            ? (
              <td>
                <input
                  name="add-to-merge"
                  type="checkbox"
                  value={release.id}
                />
              </td>
            ) : null}
          <td>
            <EntityLink entity={release} showCaaPresence />
          </td>
          {/* The class being added is for usage with userscripts */}
          <td className={
            releaseGroupCreditId === release.artistCredit.id
              ? null
              : 'artist-credit-variation'}
          >
            <ArtistCreditLink artistCredit={release.artistCredit} />
          </td>
          <td>
            {nonEmpty(release.combined_format_name)
              ? release.combined_format_name
              : l('[missing media]')}
          </td>
          <td>
            {nonEmpty(release.combined_track_count)
              ? release.combined_track_count
              : lp('-', 'missing data')}
          </td>
          <td>
            <ReleaseEvents events={release.events} />
            {manifest.js(
              'common/components/ReleaseEvents',
              {async: 'async'},
            )}
          </td>
          <td>
            <ReleaseLabelList labels={release.labels} />
          </td>
          <td>
            <ReleaseCatnoList labels={release.labels} />
          </td>
          <td className="barcode-cell">{formatBarcode(release.barcode)}</td>
          {$c.session?.tport == null ? null : (
            <td>
              <TaggerIcon entityType="release" gid={release.gid} />
            </td>
          )}
        </tr>
      ))}
    </React.Fragment>
  );
}

component ReleaseGroupIndex(
  eligibleForCleanup: boolean,
  numberOfRevisions: number,
  pager: PagerT,
  releaseGroup: ReleaseGroupT,
  releases: $ReadOnlyArray<$ReadOnlyArray<ReleaseT>>,
  wikipediaExtract: WikipediaExtractT | null,
) {
  const $c = React.useContext(CatalystContext);
  const firstReleaseGid = releases.length ? releases[0][0].gid : null;

  return (
    <ReleaseGroupLayout
      entity={releaseGroup}
      firstReleaseGid={firstReleaseGid}
      page="index"
    >
      {eligibleForCleanup ? (
        <CleanupBanner entityType="release_group" />
      ) : null}
      <Annotation
        annotation={releaseGroup.latest_annotation}
        collapse
        entity={releaseGroup}
        numberOfRevisions={numberOfRevisions}
      />
      <WikipediaExtract
        cachedWikipediaExtract={wikipediaExtract}
        entity={releaseGroup}
      />
      {releases.length ? (
        <>
          <h2>{releaseGroupType(releaseGroup)}</h2>
          <form
            action={'/release/merge_queue?' + returnToCurrentPage($c)}
            method="post"
          >
            <PaginatedResults pager={pager}>
              <table className="tbl">
                <thead>
                  <tr>
                    {$c.user ? (
                      <th className="checkbox-cell">
                        <input type="checkbox" />
                      </th>
                    ) : null}
                    <th>{l('Release')}</th>
                    <th>{l('Artist')}</th>
                    <th>{l('Format')}</th>
                    <th>{l('Tracks')}</th>
                    <th>{l('Country') + lp('/', 'and') + l('Date')}</th>
                    <th>{l('Label')}</th>
                    <th>{l('Catalog#')}</th>
                    <th>{l('Barcode')}</th>
                    {$c.session?.tport == null
                      ? null
                      : <th>{lp('Tagger', 'audio file metadata')}</th>}
                  </tr>
                </thead>
                <tbody>
                  {releases.map(releaseStatusGroup => buildReleaseStatusTable(
                    $c,
                    releaseStatusGroup,
                    releaseGroup.artistCredit.id,
                  ))}
                </tbody>
              </table>
            </PaginatedResults>
            {$c.user ? (
              <FormRow>
                <FormSubmit label={l('Add selected releases for merging')} />
              </FormRow>
            ) : null}
          </form>
        </>
      ) : (
        <p>{l('No releases found.')}</p>
      )}
      <Relationships source={releaseGroup} />
      {manifest.js('release-group/index', {async: 'async'})}
      {manifest.js('common/components/TaggerIcon', {async: 'async'})}
    </ReleaseGroupLayout>
  );
}

export default ReleaseGroupIndex;
