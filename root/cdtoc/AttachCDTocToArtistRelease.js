/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../components/PaginatedResults.js';
import Layout from '../layout/index.js';
import manifest from '../static/manifest.mjs';
import CDTocArtistReleaseListTable
  from '../static/scripts/common/components/CDTocArtistReleaseListTable.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';
import type {ReleaseWithMediumsAndReleaseGroupT}
  from '../static/scripts/relationship-editor/types.js';

component AttachCDTocToArtistRelease(
  artist: ArtistT,
  cdToc: CDTocT,
  pager?: PagerT,
  releases: $ReadOnlyArray<ReleaseWithMediumsAndReleaseGroupT>,
  tocString: StrOrNum,
) {
  const title = lp('Attach CD TOC', 'header');
  const cdTocTrackCount = cdToc.track_count;

  return (
    <Layout fullWidth title={title}>
      <h1>{title}</h1>

      <p>
        {exp.l(
          'You are viewing releases by {artist}.',
          {artist: <EntityLink entity={artist} />},
        )}
      </p>

      {releases.length > 0 ? (
        <>
          <p>
            {l('Please select the medium you wish to attach this CD TOC to.')}
          </p>

          <form method="GET">
            <input name="toc" type="hidden" value={tocString} />
            <input name="artist" type="hidden" value={artist.id} />

            {pager ? (
              <PaginatedResults pager={pager}>
                <CDTocArtistReleaseListTable
                  cdTocTrackCount={cdTocTrackCount}
                  releases={releases}
                />
                {manifest(
                  'common/components/CDTocArtistReleaseListTable',
                  {async: true},
                )}
                {manifest(
                  'common/components/ReleaseEvents',
                  {async: true},
                )}
              </PaginatedResults>
            ) : null}
            <p>
              <FormSubmit label={lp('Attach CD TOC', 'interactive')} />
            </p>
          </form>
        </>
      ) : (
        <p>
          {exp.ln(
            '{artist} has no releases which have only {n} track.',
            '{artist} has no releases which have {n} tracks.',
            cdTocTrackCount,
            {artist: <EntityLink entity={artist} />, n: cdTocTrackCount},
          )}
        </p>
      )}

      <h2>{l('Add a new release')}</h2>
      <p>
        {l(`If you don't see the release you are looking for,
            you can still add a new one, using this CD TOC:`)}
      </p>

      <form action="/release/add" method="post">
        <input
          name="artist_credit.names.0.mbid"
          type="hidden"
          value={artist.gid}
        />
        <input
          name="mediums.0.toc"
          type="hidden"
          value={tocString}
        />
        <FormSubmit label={l('Add a new release')} />
      </form>
    </Layout>
  );
}

export default AttachCDTocToArtistRelease;
