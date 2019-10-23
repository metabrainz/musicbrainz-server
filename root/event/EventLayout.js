/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';
import type {Node as ReactNode} from 'react';

import Layout from '../layout';
import EventSidebar from '../layout/components/sidebar/EventSidebar';

import EventHeader from './EventHeader';

type Props = {
  +children: ReactNode,
  +entity: EventT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
};

const EventLayout = ({
  children,
  entity: event,
  fullWidth,
  page,
  title,
}: Props) => (
  <Layout
    title={title ? hyphenateTitle(event.name, title) : event.name}
  >
    <div id="content">
      <EventHeader event={event} page={page} />
      {children}
    </div>
    {fullWidth ? null : <EventSidebar event={event} />}
  </Layout>
);

export default EventLayout;
