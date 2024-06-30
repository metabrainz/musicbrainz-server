/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';

component MusicBrainzHistory(events: $ReadOnlyArray<StatisticsEventT>) {
  return (
    <Layout fullWidth title={l_history('History')}>
      <h1>{l_history('Our glorious history')}</h1>
      {events.length
        ? events.map((event) => {
          const title = exp.l_history(
            '{date} - {title}',
            {date: event.date, title: l_statistics(event.title)},
          );
          return (
            <div key={event.date}>
              <h2>
                {event.link ? (
                  <a href={event.link}>{title}</a>
                ) : title}
              </h2>
              <p>{l_statistics(event.description)}</p>
              <hr />
            </div>
          );
        }) : (
          <p>
            {l_history('It seems we have no history to show at all!')}
          </p>
        )}
    </Layout>
  );
}

export default MusicBrainzHistory;
