/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import EntityLink from '../static/scripts/common/components/EntityLink';

type PropsT = {
  +moods: $ReadOnlyArray<MoodT>,
};

const MoodListPage = ({
  moods,
}: PropsT): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Mood List')}>
    <div id="content">
      <h1>{l('Mood List')}</h1>
      <p>
        {exp.l(
          `These are all the {mood_url|moods} 
           currently available for use in MusicBrainz.`,
          {mood_url: '/doc/Mood'},
        )}
      </p>
      <p>
        {l(`To associate a mood with an entity,
            tag the entity with the mood name.`)}
      </p>
      <ul>
        {moods.map(mood => (
          <li key={mood.id}>
            <EntityLink entity={mood} />
          </li>
        ))}
      </ul>
      <p>
        {exp.l(`Is a mood missing from the list?
                Request it by {link|adding a style ticket}.`,
               {
                 link: 'https://tickets.metabrainz.org/secure/CreateIssueDetails!init.jspa?pid=10032&issuetype=2&summary=Enter%20the%20mood%20name%20here!&components=10699',
               })}
      </p>
    </div>
  </Layout>
);

export default MoodListPage;
