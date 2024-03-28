/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ArtLinks from '../components/ArtLinks.js';
import {Artwork} from '../components/Artwork.js';
import RequestLogin from '../components/RequestLogin.js';
import {SanitizedCatalystContext} from '../context.mjs';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import {commaOnlyListText}
  from '../static/scripts/common/i18n/commaOnlyList.js';
import {isAccountAdmin} from '../static/scripts/common/utility/privileges.js';

import EventLayout from './EventLayout.js';

type Props = {
  +event: EventT,
  +eventArt: $ReadOnlyArray<EventArtT>,
};

const EventArt = ({
  eventArt,
  event,
}: Props): React$Element<typeof EventLayout> => {
  const $c = React.useContext(SanitizedCatalystContext);
  const title = lp('Event art', 'plural, header');

  return (
    <EventLayout entity={event} page="cover-art" title={title}>
      <h2>
        {event.event_art_presence === 'darkened'
          ? lp('Cannot show event art', 'plural, header')
          : title}
      </h2>

      {event.event_art_presence === 'darkened' ? (
        <p>
          {l(`Artwork for this event has been hidden
              by the Internet Archive because of a takedown request.`)}
        </p>
      ) : eventArt.length ? (
        <>
          {eventArt.map(artwork => (
            <div
              className={
                'artwork-cont' +
                (artwork.editsPending ? ' mp' : '')
              }
              key={artwork.id}
            >
              <div className="artwork" style={{position: 'relative'}}>
                <Artwork artwork={artwork} />
              </div>
              <p>
                {l('Types:')}
                {' '}
                {artwork.types?.length ? (
                  commaOnlyListText(artwork.types.map(
                    type => lp_attributes(type, 'event_art_type'),
                  ))
                ) : lp('-', 'missing data')}
              </p>
              {artwork.comment ? (
                <p>
                  {artwork.comment}
                </p>
              ) : null}
              <p className="small">
                {l('All sizes:')}
                {' '}
                <ArtLinks artwork={artwork} />
              </p>
              {isAccountAdmin($c.user) ? (
                <div className="buttons">
                  <a
                    href={'/event/' + event.gid +
                          '/edit-event-art/' + artwork.id}
                  >
                    {lp('Edit', 'verb, interactive')}
                  </a>
                  <a
                    href={'/event/' + event.gid +
                          '/remove-event-art/' + artwork.id}
                  >
                    {l('Remove')}
                  </a>
                </div>
              ) : null}
            </div>
          ))}

          <p>
            {exp.l(
              `These images provided by the {eaa|Event Art Archive}.
               You can also see them at the {ia|Internet Archive}.`,
              {
                eaa: '//eventartarchive.org',
                ia: 'https://archive.org/details/mbid-' + event.gid,
              },
            )}
          </p>
        </>
      ) : (
        <p>
          {exp.l(
            'We do not currently have any event art for {event}.',
            {event: <EntityLink entity={event} />},
          )}
        </p>
      )}

      {event.may_have_event_art /*:: === true */ ? (
        isAccountAdmin($c.user) ? (
          <div className="buttons ui-helper-clearfix">
            <EntityLink
              content={lp('Add event art', 'plural, interactive')}
              entity={event}
              subPath="add-event-art"
            />
            {eventArt.length > 1 ? (
              <EntityLink
                content={lp('Reorder event art', 'plural, interactive')}
                entity={event}
                subPath="reorder-event-art"
              />
            ) : null}
          </div>
        ) : (
          <p>
            <RequestLogin
              text={lp('Log in to upload event art', 'plural, interactive')}
            />
          </p>
        )
      ) : null}
    </EventLayout>
  );
};

export default EventArt;
