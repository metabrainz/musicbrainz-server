/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ArtLinks from '../components/ArtLinks.js';
import {Artwork} from '../components/Artwork.js';
import RequestLogin from '../components/RequestLogin.js';
import {RELEASE_STATUS_PSEUDORELEASE} from '../constants.js';
import {SanitizedCatalystContext} from '../context.mjs';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import {commaOnlyListText}
  from '../static/scripts/common/i18n/commaOnlyList.js';

import ReleaseLayout from './ReleaseLayout.js';

type Props = {
  +coverArt: $ReadOnlyArray<ArtworkT>,
  +release: ReleaseT,
};

const CoverArt = ({
  coverArt,
  release,
}: Props): React$Element<typeof ReleaseLayout> => {
  const $c = React.useContext(SanitizedCatalystContext);
  const title = lp('Cover art', 'plural, header');

  return (
    <ReleaseLayout entity={release} page="cover-art" title={title}>
      <h2>
        {release.cover_art_presence === 'darkened'
          ? lp('Cannot show cover art', 'plural, header')
          : title}
      </h2>

      {release.cover_art_presence === 'darkened' ? (
        <p>
          {l(`Cover art for this release has been hidden
              by the Internet Archive because of a takedown request.`)}
        </p>
      ) : coverArt.length ? (
        <>
          {coverArt.map(artwork => (
            <div
              className={
                'artwork-cont' +
                (artwork.editsPending ? ' mp' : '')
              }
              key={artwork.id}
            >
              <div className="artwork" style={{position: 'relative'}}>
                <Artwork artwork={artwork} />
              </div>
              <p>
                {l('Types:')}
                {' '}
                {artwork.types?.length ? (
                  commaOnlyListText(artwork.types.map(
                    type => lp_attributes(type, 'cover_art_type'),
                  ))
                ) : lp('-', 'missing data')}
              </p>
              {artwork.comment ? (
                <p>
                  {artwork.comment}
                </p>
              ) : null}
              <p className="small">
                {l('All sizes:')}
                {' '}
                <ArtLinks artwork={artwork} />
              </p>
              {$c.user ? (
                <div className="buttons">
                  <a
                    href={'/release/' + release.gid +
                          '/edit-cover-art/' + artwork.id}
                  >
                    {lp('Edit', 'verb, interactive')}
                  </a>
                  <a
                    href={'/release/' + release.gid +
                          '/remove-cover-art/' + artwork.id}
                  >
                    {l('Remove')}
                  </a>
                </div>
              ) : null}
            </div>
          ))}

          <p>
            {exp.l(
              `These images provided by the {caa|Cover Art Archive}.
               You can also see them at the {ia|Internet Archive}.`,
              {
                caa: '//coverartarchive.org',
                ia: 'https://archive.org/details/mbid-' + release.gid,
              },
            )}
          </p>
        </>
      ) : (
        <>
          <p>
            {exp.l(
              'We do not currently have any cover art for {release}.',
              {release: <EntityLink entity={release} />},
            )}
          </p>
          {release.status?.id === RELEASE_STATUS_PSEUDORELEASE ? (
            <p>
              {exp.l(
                `Keep in mind pseudo-releases generally shouldn’t have
                 cover art. See {doc|the guidelines for pseudo-releases}
                 for more info.`,
                {
                  doc:
                    '/doc/Style/Specific_types_of_releases/Pseudo-Releases',
                },
              )}
            </p>
          ) : null}
        </>
      )}

      {release.may_have_cover_art /*:: === true */ ? (
        $c.user ? (
          <div className="buttons ui-helper-clearfix">
            <EntityLink
              content={lp('Add cover art', 'plural, interactive')}
              entity={release}
              subPath="add-cover-art"
            />
            {coverArt.length > 1 ? (
              <EntityLink
                content={lp('Reorder cover art', 'plural, interactive')}
                entity={release}
                subPath="reorder-cover-art"
              />
            ) : null}
          </div>
        ) : (
          <p>
            <RequestLogin
              text={lp('Log in to upload cover art', 'plural, interactive')}
            />
          </p>
        )
      ) : null}
    </ReleaseLayout>
  );
};

export default CoverArt;
