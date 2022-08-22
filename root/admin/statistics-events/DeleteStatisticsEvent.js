/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../../layout/index.js';
import expand2react from '../../static/scripts/common/i18n/expand2react.js';
import FormSubmit from '../../static/scripts/edit/components/FormSubmit.js';

import type {StatisticsEventT} from './types.js';

type PropsT = {
  +event: StatisticsEventT,
};

const DeleteStatisticsEvent = ({
  event,
}: PropsT): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Remove statistics event')}>
    <h2>{l('Remove statistics event')}</h2>
    <table className="details">
      <tr>
        <th>{addColonText(l('Date'))}</th>
        <td>{event.date}</td>
      </tr>
      <tr>
        <th>{addColonText(l('Title'))}</th>
        <td>{event.title}</td>
      </tr>
      <tr>
        <th>{addColonText(l('Description'))}</th>
        <td>{expand2react(event.description)}</td>
      </tr>
      <tr>
        <th>{addColonText(l('Link'))}</th>
        <td><a href={event.link}>{event.link}</a></td>
      </tr>
    </table>
    <p>
      {l('Are you sure you want to remove this statistics event?')}
    </p>
    <form method="post">
      <FormSubmit label={l('Remove statistics event')} />
    </form>
  </Layout>
);

export default DeleteStatisticsEvent;
