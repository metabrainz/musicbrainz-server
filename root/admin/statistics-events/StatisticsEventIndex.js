/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../../layout/index.js';
import expand2react from '../../static/scripts/common/i18n/expand2react.js';
import loopParity from '../../utility/loopParity.js';

import type {StatisticsEventT} from './types.js';

type PropsT = {
  +events: Array<StatisticsEventT>,
};

const StatisticsEventIndex = ({
  events,
}: PropsT): React$Element<typeof Layout> => (
  <Layout fullWidth title={l('Statistics Events')}>
    <h1>{l('Statistics Events')}</h1>
    <table className="tbl">
      <thead>
        <tr>
          <th>{l('Date')}</th>
          <th>{l('Title')}</th>
          <th>{l('Description')}</th>
          <th>{l('Link')}</th>
          <th>{l('Actions')}</th>
        </tr>
      </thead>
      <tbody>
        {events ? events
          .map((event, index) => (
            <tr className={loopParity(index)} key={event.date}>
              <td>{event.date}</td>
              <td>{event.title}</td>
              <td>{expand2react(event.description)}</td>
              <td>
                <a href={event.link}>{event.link}</a>
              </td>
              <td>
                <a href={`/admin/statistics-events/edit/${event.date}`}>
                  {l('Edit')}
                </a>
                {' | '}
                <a href={`/admin/statistics-events/delete/${event.date}`}>
                  {l('Remove')}
                </a>
              </td>
            </tr>
          )) : null}
      </tbody>
    </table>
    <p>
      <span className="buttons">
        <a href="/admin/statistics-events/create">
          {lp('Add new event', 'statistics event')}
        </a>
      </span>
    </p>
  </Layout>
);

export default StatisticsEventIndex;
