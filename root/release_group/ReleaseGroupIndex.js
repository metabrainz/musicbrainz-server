/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Annotation from '../static/scripts/common/components/Annotation';
import Relationships from '../static/scripts/common/components/Relationships';
import WikipediaExtract
  from '../static/scripts/common/components/WikipediaExtract';
import CritiqueBrainzLinks from '../components/CritiqueBrainzLinks';
import CritiqueBrainzReview, {type CritiqueBrainzReviewT}
  from '../static/scripts/common/components/CritiqueBrainzReview';
import PaginatedResults from '../components/PaginatedResults';
import TaggerIcon from '../static/scripts/common/components/TaggerIcon';
import loopParity from '../utility/loopParity';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink';
import EntityLink from '../static/scripts/common/components/EntityLink';
import CleanupBanner from '../components/CleanupBanner';
import FormRow from '../components/FormRow';
import FormSubmit from '../components/FormSubmit';
import ReleaseEvents from '../static/scripts/common/components/ReleaseEvents';
import ReleaseLabelList from '../components/ReleaseLabelList';
import ReleaseCatnoList from '../components/ReleaseCatnoList';
import formatBarcode from '../static/scripts/common/utility/formatBarcode';
import * as manifest from '../static/manifest.mjs';
import releaseGroupType from '../utility/releaseGroupType';
import {returnToCurrentPage} from '../utility/returnUri';

import ReleaseGroupLayout from './ReleaseGroupLayout';

type Props = {
  +$c: CatalystContextT,
  +eligibleForCleanup: boolean,
  +mostPopularReview: CritiqueBrainzReviewT,
  +mostRecentReview: CritiqueBrainzReviewT,
  +numberOfRevisions: number,
  +pager: PagerT,
  +releaseGroup: ReleaseGroupT,
  +releases: $ReadOnlyArray<$ReadOnlyArray<ReleaseT>>,
  +wikipediaExtract: WikipediaExtractT | null,
};

function buildReleaseStatusTable(
  $c,
  releaseStatusGroup,
  releaseGroupCreditId,
) {
  const status = releaseStatusGroup[0].status;
  return (
    <React.Fragment key={status ? status.name : 'no-status'}>
      <tr className="subh">
        {$c.user ? <th /> : null}
        <th colSpan={$c.session && $c.session.tport ? 9 : 8}>
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
          <td>{release.combined_format_name || l('[missing media]')}</td>
          <td>{release.combined_track_count || lp('-', 'missing data')}</td>
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

const ReleaseGroupIndex = ({
  $c,
  eligibleForCleanup,
  pager,
  mostPopularReview,
  mostRecentReview,
  numberOfRevisions,
  releaseGroup,
  releases,
  wikipediaExtract,
}: Props): React.Element<typeof ReleaseGroupLayout> => (
  <ReleaseGroupLayout
    $c={$c}
    entity={releaseGroup}
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
                  {$c.session?.tport
                    ? <th>{l('Tagger')}</th> : null}
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
    {releaseGroup.review_count === null ? null : (
      <>
        <h2>{l('CritiqueBrainz Reviews')}</h2>
        <CritiqueBrainzLinks releaseGroup={releaseGroup} />
        <div id="critiquebrainz-reviews">
          {mostRecentReview ? (
            <CritiqueBrainzReview
              review={mostRecentReview}
              title={l('Most Recent')}
            />
          ) : null}
          {mostPopularReview &&
            mostPopularReview.id !== mostRecentReview.id ? (
              <CritiqueBrainzReview
                review={mostPopularReview}
                title={l('Most Popular')}
              />
            ) : null}
        </div>
      </>
    )}
    {manifest.js('release-group/index', {async: 'async'})}
    {manifest.js('common/components/TaggerIcon', {async: 'async'})}
  </ReleaseGroupLayout>
);

export default ReleaseGroupIndex;
