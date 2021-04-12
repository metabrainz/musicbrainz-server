/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {Artwork} from '../components/Artwork';
import RequestLogin from '../components/RequestLogin';
import EntityLink from '../static/scripts/common/components/EntityLink';
import {commaOnlyListText} from '../static/scripts/common/i18n/commaOnlyList';
import entityHref from '../static/scripts/common/utility/entityHref';

import ReleaseLayout from './ReleaseLayout';

type Props = {
  +$c: CatalystContextT,
  +coverArt: $ReadOnlyArray<ArtworkT>,
  +release: ReleaseT,
};

const CoverArtLinks = ({
  artwork,
}: {artwork: ArtworkT}): React.Element<typeof React.Fragment> => (
  <>
    {artwork.small_thumbnail ? (
      <>
        <a href={artwork.small_thumbnail}>{l('250px')}</a>
        {' | '}
      </>
    ) : null}
    {artwork.large_thumbnail ? (
      <>
        <a href={artwork.large_thumbnail}>{l('500px')}</a>
        {' | '}
      </>
    ) : null}
    {artwork.huge_thumbnail ? (
      <>
        <a href={artwork.huge_thumbnail}>{l('1200px')}</a>
        {' | '}
      </>
    ) : null}
    <a href={artwork.image}>{l('original')}</a>
  </>
);

const CoverArt = ({
  $c,
  coverArt,
  release,
}: Props): React.Element<typeof ReleaseLayout> => {
  const title = l('Cover Art');

  return (
    <ReleaseLayout $c={$c} entity={release} page="cover-art" title={title}>
      <h2>
        {release.cover_art_presence === 'darkened'
          ? l('Cannot show cover art')
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
                <CoverArtLinks artwork={artwork} />
              </p>
              {$c.user ? (
                <div className="buttons">
                  <a
                    href={'/release/' + release.gid +
                          '/edit-cover-art/' + artwork.id}
                  >
                    {l('Edit')}
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
          {nonEmpty(release.cover_art_url) ? (
            <p>
              {exp.l(
                `The artwork in the sidebar is being provided
                 by a {relationships|URL relationship}.`,
                {relationships: entityHref(release)},
              )}
            </p>
          ) : null}
        </>
      )}

      {release.may_have_cover_art /*:: === true */ ? (
        $c.user ? (
          <div className="buttons ui-helper-clearfix">
            <EntityLink
              content={lp('Add Cover Art', 'button/menu')}
              entity={release}
              subPath="add-cover-art"
            />
            {coverArt.length > 1 ? (
              <EntityLink
                content={lp('Reorder Cover Art', 'button/menu')}
                entity={release}
                subPath="reorder-cover-art"
              />
            ) : null}
          </div>
        ) : (
          <p>
            <RequestLogin $c={$c} text={l('Log in to upload cover art')} />
          </p>
        )
      ) : null}
    </ReleaseLayout>
  );
};

export default CoverArt;
