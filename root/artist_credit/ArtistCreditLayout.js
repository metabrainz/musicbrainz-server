/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Tabs from '../components/Tabs.js';
import Layout from '../layout/index.js';
import ArtistCreditUsageLink
  from '../static/scripts/common/components/ArtistCreditUsageLink.js';
import {reduceArtistCredit}
  from '../static/scripts/common/immutable-entities.js';

const tabLinks: $ReadOnlyArray<[string, () => string]> = [
  ['', N_l('Overview')],
  ['/release-group', N_l('Release groups')],
  ['/release', N_l('Releases')],
  ['/recording', N_l('Recordings')],
  ['/track', N_l('Tracks')],
];

component ArtistCreditLayout(
  artistCredit: $ReadOnly<{...ArtistCreditT, +id: number}>,
  children: React$Node,
  page: string,
  title?: string,
) {
  return (
    <Layout
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
          <ArtistCreditUsageLink
            artistCredit={artistCredit}
            content={texp.l(
              'Artist credit “{artist_credit}”',
              {artist_credit: reduceArtistCredit(artistCredit)},
            )}
            showEditsPending
          />
        </h1>
        <Tabs>
          {tabLinks.map(link => (
            <li className={page === link[0] ? 'sel' : ''} key={link[0]}>
              <ArtistCreditUsageLink
                artistCredit={artistCredit}
                content={link[1]()}
                subPath={link[0].replace(/^\//, '')}
              />
            </li>
          ))}
        </Tabs>
        {children}
      </div>
    </Layout>
  );
}

export default ArtistCreditLayout;
