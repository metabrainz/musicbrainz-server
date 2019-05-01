/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import TagLink from '../static/scripts/common/components/TagLink';

type PropsT = {|
  +genres: $ReadOnlyArray<GenreT>,
|};

const GenreList = ({genres}: PropsT) => (
  <Layout fullWidth title={l('Genre List')}>
    <div id="content">
      <h1>{l('Genre List')}</h1>
      <p>
        {l('These are all the tags that will be understood as genres by the tag system.')}
      </p>
      <ul>
        {genres.map(genre => (
          <li key={genre.id}>
            <TagLink tag={genre.name} />
          </li>
        ))}
      </ul>
      <p>
        {exp.l('Is a genre missing from the list? Request it by {link|adding a style ticket}.', {
          link: 'https://tickets.metabrainz.org/secure/CreateIssueDetails!init.jspa?pid=10032&issuetype=2&summary=Enter%20the%20genre%20name%20here!&components=10699',
        })}
      </p>
    </div>
  </Layout>
);


export default GenreList;
