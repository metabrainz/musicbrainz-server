/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../../layout/index.js';
import FormSubmit from '../../static/scripts/edit/components/FormSubmit.js';

type PropsT = {
  +event: StatisticsEventT,
};

const DeleteStatisticsEvent = ({
  event,
}: PropsT): React$Element<typeof Layout> => (
  <Layout fullWidth title="Remove statistics event">
    <h2>{'Remove statistics event'}</h2>
    <table className="details">
      <tr>
        <th>{'Date:'}</th>
        <td>{event.date}</td>
      </tr>
      <tr>
        <th>{'Title:'}</th>
        <td>{event.title}</td>
      </tr>
      <tr>
        <th>{'Description:'}</th>
        <td>{exp.l_admin(event.description)}</td>
      </tr>
      <tr>
        <th>{'Link:'}</th>
        <td><a href={event.link}>{event.link}</a></td>
      </tr>
    </table>
    <p>
      {'Are you sure you want to remove this statistics event?'}
    </p>
    <form method="post">
      <FormSubmit label="Remove statistics event" />
    </form>
  </Layout>
);

export default DeleteStatisticsEvent;
