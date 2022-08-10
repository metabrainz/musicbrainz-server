/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormSubmit from '../components/FormSubmit.js';
import RecordingList from '../components/list/RecordingList.js';
import PaginatedResults from '../components/PaginatedResults.js';
import Filter from '../static/scripts/common/components/Filter.js';
import {type FilterFormT}
  from '../static/scripts/common/components/FilterForm.js';
import bracketed from '../static/scripts/common/utility/bracketed.js';
import {returnToCurrentPage} from '../utility/returnUri.js';

import ArtistLayout from './ArtistLayout.js';

type FooterSwitchProps = {
  +artist: ArtistT,
  +hasStandalone: boolean,
  +hasVideo: boolean,
  +standaloneOnly: boolean,
  +videoOnly: boolean,
};

type Props = {
  ...ReleaseGroupAppearancesRoleT,
  +$c: CatalystContextT,
  +ajaxFilterFormUrl: string,
  +artist: ArtistT,
  +filterForm: ?FilterFormT,
  +hasFilter: boolean,
  +hasStandalone: boolean,
  +hasVideo: boolean,
  +pager: PagerT,
  +recordings: $ReadOnlyArray<RecordingWithArtistCreditT>,
  +standaloneOnly: boolean,
  +videoOnly: boolean,
};

const FooterSwitch = ({
  artist,
  hasStandalone,
  hasVideo,
  standaloneOnly,
  videoOnly,
}: FooterSwitchProps): React.Element<'p'> => {
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
};

const ArtistRecordings = ({
  $c,
  ajaxFilterFormUrl,
  artist,
  filterForm,
  hasFilter,
  hasStandalone,
  hasVideo,
  pager,
  recordings,
  releaseGroupAppearances,
  standaloneOnly,
  videoOnly,
}: Props): React.Element<typeof ArtistLayout> => (
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
          <div className="row">
            <FormSubmit label={l('Add selected recordings for merging')} />
          </div>
        ) : null}
      </form>
    ) : (
      <p>
        {hasFilter
          ? l('No recordings found that match this search.')
          : l('No recordings found.')}
      </p>
    )}

    <FooterSwitch
      artist={artist}
      hasStandalone={hasStandalone}
      hasVideo={hasVideo}
      standaloneOnly={standaloneOnly}
      videoOnly={videoOnly}
    />
  </ArtistLayout>
);

export default ArtistRecordings;
