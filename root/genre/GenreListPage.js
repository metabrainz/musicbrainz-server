/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';

component GenreListPage(genres: $ReadOnlyArray<GenreT>) {
  return (
    <Layout fullWidth title={l('Genre list')}>
      <div id="content">
        <h1>{l('Genre list')}</h1>
        <p>
          {exp.l(
            `These are all the {genre_url|genres} 
             currently available for use in MusicBrainz.`,
            {genre_url: '/doc/Genre'},
          )}
        </p>
        <p>
          {l(`To associate a genre with an entity,
              tag the entity with the genre name.`)}
        </p>
        <ul>
          {genres.map(genre => (
            <li key={genre.id}>
              <EntityLink entity={genre} />
            </li>
          ))}
        </ul>
        <p>
          {exp.l(`Is a genre missing from the list?
                  Request it by {link|adding a style ticket}.`,
                 {
                   link: 'https://tickets.metabrainz.org/secure/CreateIssueDetails!init.jspa?pid=10032&issuetype=2&summary=Enter%20the%20genre%20name%20here!&components=10699',
                 })}
        </p>
      </div>
    </Layout>
  );
}

export default GenreListPage;
