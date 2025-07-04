/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import RecordingList from '../components/list/RecordingList.js';
import PaginatedResults from '../components/PaginatedResults.js';
import {SanitizedCatalystContext} from '../context.mjs';
import manifest from '../static/manifest.mjs';
import Filter from '../static/scripts/common/components/Filter.js';
import {type RecordingFilterT}
  from '../static/scripts/common/components/FilterForm.js';
import ListMergeButtonsRow
  from '../static/scripts/common/components/ListMergeButtonsRow.js';
import bracketed from '../static/scripts/common/utility/bracketed.js';
import {returnToCurrentPage} from '../utility/returnUri.js';

import ArtistLayout from './ArtistLayout.js';

component FooterSwitch(
  artist: ArtistT,
  hasStandalone: boolean,
  hasVideo: boolean,
  standaloneOnly: boolean,
  videoOnly: boolean,
) {
  const showAllLink = (
    <a href={`/artist/${artist.gid}/recordings`}>
      {l('Show all recordings')}
    </a>
  );
  const showStandaloneLink = (
    <a href={`/artist/${artist.gid}/recordings?standalone=1`}>
      {l('Show only standalone recordings')}
    </a>
  );
  const showVideosLink = (
    <a href={`/artist/${artist.gid}/recordings?video=1`}>
      {l('Show only videos')}
    </a>
  );

  return (
    <p>
      {standaloneOnly ? (
        <>
          {l('Showing only standalone recordings')}
          {' '}
          {bracketed(
            <>
              {showAllLink}
              {hasVideo ? (
                <>
                  {' / '}
                  {showVideosLink}
                </>
              ) : null}
            </>,
          )}
        </>
      ) : videoOnly ? (
        <>
          {l('Showing only videos')}
          {' '}
          {bracketed(
            <>
              {showAllLink}
              {hasStandalone ? (
                <>
                  {' / '}
                  {showStandaloneLink}
                </>
              ) : null}
            </>,
          )}
        </>
      ) : (
        <>
          {l('Showing all recordings')}
          {' '}
          {hasStandalone && hasVideo ? (
            bracketed(
              <>
                {showStandaloneLink}
                {' / '}
                {showVideosLink}
              </>,
            )
          ) : hasStandalone ? (
            bracketed(showStandaloneLink)
          ) : hasVideo ? (
            bracketed(showVideosLink)
          ) : null}
        </>
      )}
    </p>
  );
}

component ArtistRecordings(
  ajaxFilterFormUrl: string,
  filterForm: ?RecordingFilterT,
  hasFilter: boolean,
  pager: PagerT,
  recordings: $ReadOnlyArray<RecordingWithArtistCreditT>,
  releaseGroupAppearances?: ReleaseGroupAppearancesMapT,
  ...footerSwitchProps: React.PropsOf<FooterSwitch>
) {
  const $c = React.useContext(SanitizedCatalystContext);
  const artist = footerSwitchProps.artist;
  return (
    <ArtistLayout
      entity={artist}
      page="recordings"
      title={l('Recordings')}
    >
      <h2>{l('Recordings')}</h2>

      <Filter
        ajaxFormUrl={ajaxFilterFormUrl}
        initialFilterForm={filterForm}
      />

      {recordings.length ? (
        <form
          action={'/recording/merge_queue?' + returnToCurrentPage($c)}
          method="post"
        >
          <PaginatedResults pager={pager}>
            <RecordingList
              checkboxes="add-to-merge"
              recordings={recordings}
              releaseGroupAppearances={releaseGroupAppearances}
              showRatings
              showReleaseGroups
            />
          </PaginatedResults>
          {$c.user ? (
            <>
              <ListMergeButtonsRow
                label={l('Add selected recordings for merging')}
              />
              {manifest(
                'common/components/ListMergeButtonsRow',
                {async: true},
              )}
            </>
          ) : null}
        </form>
      ) : (
        <p>
          {hasFilter
            ? l('No recordings found that match this search.')
            : l('No recordings found.')}
        </p>
      )}

      <FooterSwitch {...footerSwitchProps} />

      {manifest('common/components/Filter', {async: true})}
      {manifest('common/MB/Control/SelectAll', {async: true})}
      {manifest('common/ratings', {async: true})}
    </ArtistLayout>
  );
}

export default ArtistRecordings;
