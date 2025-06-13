/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import * as ReactDOMServer from 'react-dom/server';

import {Artwork} from '../../../components/Artwork.js';
import {CatalystContext} from '../../../context.mjs';
import manifest from '../../../static/manifest.mjs';
import CommonsImage
  from '../../../static/scripts/common/components/CommonsImage.js';
import {
  WIKIMEDIA_COMMONS_IMAGES_ENABLED,
} from '../../../static/scripts/common/DBDefs.mjs';
import areDatesEqual
  from '../../../static/scripts/common/utility/areDatesEqual.js';
import entityHref from '../../../static/scripts/common/utility/entityHref.js';
import {isDateNonEmpty}
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

component EventSidebar(event: EventT) {
  const $c = React.useContext(CatalystContext);
  const hasBegin = isDateNonEmpty(event.begin_date);
  const hasEnd = isDateNonEmpty(event.end_date);
  const eventArtwork = $c.stash.event_artwork;
  const eventArtPresence = event.event_art_presence;

  return (
    <div id="sidebar">
      {(eventArtPresence === 'present' || !$c.stash.commons_image) ? (
        <div className="event-art">
          {eventArtPresence === 'present' && eventArtwork ? (
            <>
              <Artwork
                artwork={eventArtwork}
                message={ReactDOMServer.renderToStaticMarkup(exp.l(
                  'Image failed to load correctly.' +
                  '<br/>{all|View all images}.',
                  {all: entityHref(event, 'event-art')},
                ))}
              />
              {manifest('common/loadArtwork', {async: true})}
              {manifest('common/artworkViewer', {async: true})}
            </>
          ) : eventArtPresence === 'darkened' ? (
            l(`Images for this item have been hidden
               by the Internet Archive because of a takedown request.`)
          ) : (
            <p className="event-art-note" style={{textAlign: 'left'}}>
              {eventArtPresence === 'present' ? (
                <>
                  {l('No poster available.')}
                  <br />
                  <a href={entityHref(event, 'event-art')}>
                    {l('View all artwork')}
                  </a>
                </>
              ) : l('No images available.')}
            </p>
          )}
        </div>
      ) : WIKIMEDIA_COMMONS_IMAGES_ENABLED ? (
        <>
          <CommonsImage
            cachedImage={$c.stash.commons_image}
            entity={event}
          />
          {manifest('common/components/CommonsImage', {async: true})}
        </>
      ) : null}

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
}

export default EventSidebar;
