/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Tabs from '../components/Tabs';
import Layout from '../layout';
import {reduceArtistCredit}
  from '../static/scripts/common/immutable-entities';

type Props = {
  +$c: CatalystContextT,
  +artistCredit: $ReadOnly<{...ArtistCreditT, +id: number}>,
  +children: React.Node,
  +page: string,
  +title?: string,
};

const tabLinks: $ReadOnlyArray<[string, () => string]> = [
  ['', N_l('Overview')],
  ['/release-group', N_l('Release Groups')],
  ['/release', N_l('Releases')],
  ['/recording', N_l('Recordings')],
  ['/track', N_l('Tracks')],
];

const ArtistCreditLayout = ({
  $c,
  artistCredit,
  children,
  page,
  title,
}: Props): React.Element<typeof Layout> => (
  <Layout
    $c={$c}
    fullWidth
    title={
      nonEmpty(title)
        ? hyphenateTitle(texp.l(
          'Artist credit “{artist_credit}”',
          {artist_credit: reduceArtistCredit(artistCredit)},
        ), title)
        : texp.l(
          'Artist credit “{artist_credit}”',
          {artist_credit: reduceArtistCredit(artistCredit)},
        )
    }
  >
    <div id="content">
      <h1>
        <a href={'/artist-credit/' + artistCredit.id}>
          {texp.l(
            'Artist credit “{artist_credit}”',
            {artist_credit: reduceArtistCredit(artistCredit)},
          )}
        </a>
      </h1>
      <Tabs>
        {tabLinks.map(link => (
          <li className={page === link[0] ? 'sel' : ''} key={link[0]}>
            <a href={'/artist-credit/' + artistCredit.id + link[0]}>
              {link[1]()}
            </a>
          </li>
        ))}
      </Tabs>
      {children}
    </div>
  </Layout>
);

export default ArtistCreditLayout;
