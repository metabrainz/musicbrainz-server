/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../../layout/index.js';
import loopParity from '../../utility/loopParity.js';

component StatisticsEventIndex(events: Array<StatisticsEventT>) {
  return (
    <Layout fullWidth title="Statistics events">
      <h1>{'Statistics events'}</h1>
      <table className="tbl">
        <thead>
          <tr>
            <th>{'Date'}</th>
            <th>{'Title'}</th>
            <th>{'Description'}</th>
            <th>{'Link'}</th>
            <th>{'Actions'}</th>
          </tr>
        </thead>
        <tbody>
          {events ? events
            .map((event, index) => (
              <tr className={loopParity(index)} key={event.date}>
                <td>{event.date}</td>
                <td>{event.title}</td>
                <td>{exp.l_admin(event.description)}</td>
                <td>
                  <a href={event.link}>{event.link}</a>
                </td>
                <td>
                  <a href={`/admin/statistics-events/edit/${event.date}`}>
                    {'Edit'}
                  </a>
                  {' | '}
                  <a href={`/admin/statistics-events/delete/${event.date}`}>
                    {'Remove'}
                  </a>
                </td>
              </tr>
            )) : null}
        </tbody>
      </table>
      <p>
        <span className="buttons">
          <a href="/admin/statistics-events/create">
            {'Add new event'}
          </a>
        </span>
      </p>
    </Layout>
  );
}

export default StatisticsEventIndex;
