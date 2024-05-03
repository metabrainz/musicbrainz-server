/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EventSidebar from '../layout/components/sidebar/EventSidebar.js';
import Layout from '../layout/index.js';

import EventHeader from './EventHeader.js';

component EventLayout(
  children: React$Node,
  entity as event: EventT,
  fullWidth: boolean = false,
  page: string,
  title?: string,
) {
  return (
    <Layout
      title={nonEmpty(title) ? hyphenateTitle(event.name, title) : event.name}
    >
      <div id="content">
        <EventHeader event={event} page={page} />
        {children}
      </div>
      {fullWidth ? null : <EventSidebar event={event} />}
    </Layout>
  );
}

export default EventLayout;
