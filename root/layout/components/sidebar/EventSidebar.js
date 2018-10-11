/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../../../context';
import CommonsImage from '../../../static/scripts/common/components/CommonsImage';
import {l} from '../../../static/scripts/common/i18n';
import isDateEmpty from '../../../static/scripts/common/utility/isDateEmpty';
import areDatesEqual from '../../../utility/areDatesEqual';
import ExternalLinks from '../ExternalLinks';

import AnnotationLinks from './AnnotationLinks';
import AttendanceLinks from './AttendanceLinks';
import EditLinks from './EditLinks';
import LastUpdated from './LastUpdated';
import MergeLink from './MergeLink';
import SidebarBeginDate from './SidebarBeginDate';
import SidebarEndDate from './SidebarEndDate';
import SidebarLicenses from './SidebarLicenses';
import {SidebarProperty, SidebarProperties} from './SidebarProperties';
import SidebarRating from './SidebarRating';
import SidebarTags from './SidebarTags';
import SidebarType from './SidebarType';

type Props = {|
  +$c: CatalystContextT,
  +event: EventT,
|};

const EventSidebar = ({$c, event}: Props) => {
  const hasBegin = !isDateEmpty(event.begin_date);
  const hasEnd = !isDateEmpty(event.end_date);

  return (
    <div id="sidebar">
      <CommonsImage
        entity={event}
        image={$c.stash.commons_image}
      />

      <h2 className="event-information">
        {l('Event information')}
      </h2>

      <SidebarProperties>
        <SidebarType entity={event} typeType="event_type" />

        {hasBegin || hasEnd ? (
          areDatesEqual(event.begin_date, event.end_date) ? (
            <SidebarBeginDate entity={event} label={l('Date:')} />
          ) : (
            <>
              <SidebarBeginDate entity={event} label={l('Start Date:')} />
              <SidebarEndDate entity={event} label={l('End Date:')} />
            </>
          )
        ) : null}

        {event.time ? (
          <SidebarProperty className="time" label={l('Time:')}>
            {event.time}
          </SidebarProperty>
        ) : null}
      </SidebarProperties>

      <SidebarRating entity={event} />

      <SidebarTags
        aggregatedTags={$c.stash.top_tags}
        entity={event}
        more={!!$c.stash.more_tags}
        userTags={$c.stash.user_tags}
      />

      <ExternalLinks empty entity={event} />

      <EditLinks entity={event}>
        {$c.user ? (
          <>
            <AnnotationLinks entity={event} />

            <MergeLink entity={event} />

            <li className="separator" role="separator" />
          </>
        ) : null}
      </EditLinks>

      <AttendanceLinks event={event} />

      <SidebarLicenses entity={event} />

      <LastUpdated entity={event} />
    </div>
  );
};

export default withCatalystContext(EventSidebar);
