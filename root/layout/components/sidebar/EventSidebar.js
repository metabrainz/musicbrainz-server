/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../../context.mjs';
import CommonsImage
  from '../../../static/scripts/common/components/CommonsImage.js';
import areDatesEqual
  from '../../../static/scripts/common/utility/areDatesEqual.js';
import isDateEmpty
  from '../../../static/scripts/common/utility/isDateEmpty.js';
import ExternalLinks from '../ExternalLinks.js';

import AnnotationLinks from './AnnotationLinks.js';
import CollectionLinks from './CollectionLinks.js';
import EditLinks from './EditLinks.js';
import LastUpdated from './LastUpdated.js';
import MergeLink from './MergeLink.js';
import SidebarBeginDate from './SidebarBeginDate.js';
import SidebarEndDate from './SidebarEndDate.js';
import SidebarLicenses from './SidebarLicenses.js';
import {SidebarProperties, SidebarProperty} from './SidebarProperties.js';
import SidebarRating from './SidebarRating.js';
import SidebarTags from './SidebarTags.js';
import SidebarType from './SidebarType.js';

type Props = {
  +event: EventT,
};

const EventSidebar = ({event}: Props): React$Element<'div'> => {
  const $c = React.useContext(CatalystContext);
  const hasBegin = !isDateEmpty(event.begin_date);
  const hasEnd = !isDateEmpty(event.end_date);

  return (
    <div id="sidebar">
      <CommonsImage
        cachedImage={$c.stash.commons_image}
        entity={event}
      />

      <h2 className="event-information">
        {l('Event information')}
      </h2>

      <SidebarProperties>
        <SidebarType entity={event} typeType="event_type" />

        {hasBegin || hasEnd ? (
          areDatesEqual(event.begin_date, event.end_date) ? (
            <SidebarBeginDate
              entity={event}
              label={addColonText(l('Date'))}
            />
          ) : (
            <>
              <SidebarBeginDate
                entity={event}
                label={addColonText(l('Start date'))}
              />
              <SidebarEndDate
                entity={event}
                label={addColonText(l('End date'))}
              />
            </>
          )
        ) : null}

        {event.time ? (
          <SidebarProperty
            className="time"
            label={addColonText(lp('Time', 'event'))}
          >
            {event.time}
          </SidebarProperty>
        ) : null}
      </SidebarProperties>

      <SidebarRating entity={event} />

      <SidebarTags entity={event} />

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

      <CollectionLinks entity={event} />

      <SidebarLicenses entity={event} />

      <LastUpdated entity={event} />
    </div>
  );
};

export default EventSidebar;
