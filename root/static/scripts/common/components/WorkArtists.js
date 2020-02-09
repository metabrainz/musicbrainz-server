/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React, {useCallback, useState} from 'react';

import hydrate from '../../../../utility/hydrate';
import {bracketedText} from '../utility/bracketed';

import ArtistCreditLink from './ArtistCreditLink';

const COLLAPSE_THRESHOLD = 4;

const buildWorkArtistRow = (artistCredit: ArtistCreditT) => {
  return (
    <li key={artistCredit.id}>
      <ArtistCreditLink artistCredit={artistCredit} />
    </li>
  );
};

type WorkArtistsProps = {
  +artists: ?$ReadOnlyArray<ArtistCreditT>,
};

const WorkArtists = ({artists}: WorkArtistsProps) => {
  const [expanded, setExpanded] = useState<boolean>(false);

  const expand = useCallback(event => {
    event.preventDefault();
    setExpanded(true);
  });

  const collapse = useCallback(event => {
    event.preventDefault();
    setExpanded(false);
  });

  const containerProps = {
    'aria-label': l('Work Artists'),
    'className': 'work-artists',
  };

  const tooManyArtists = artists
    ? artists.length > COLLAPSE_THRESHOLD
    : false;

  return (
    (artists && artists.length) ? (
      <>
        {(tooManyArtists && !expanded) ? (
          <>
            <ul {...containerProps}>
              {artists.slice(0, COLLAPSE_THRESHOLD).map(
                artist => buildWorkArtistRow(artist),
              )}
              <li className="show-all" key="show-all">
                <a
                  href="#"
                  onClick={expand}
                  role="button"
                  title={l('Show all artists')}
                >
                  {bracketedText(texp.l('show {n} more', {
                    n: artists.length - COLLAPSE_THRESHOLD,
                  }))}
                </a>
              </li>
            </ul>
          </>
        ) : (
          <ul {...containerProps}>
            {artists.map(artist => buildWorkArtistRow(artist))}
            {tooManyArtists && expanded ? (
              <li className="show-less" key="show-less">
                <a
                  href="#"
                  onClick={collapse}
                  role="button"
                  title={l('Show less artists')}
                >
                  {bracketedText(l('show less'))}
                </a>
              </li>
            ) : null}
          </ul>
        )}
      </>
    ) : null
  );
};

export default hydrate<WorkArtistsProps>(
  'div.work-artists-container',
  WorkArtists,
);
