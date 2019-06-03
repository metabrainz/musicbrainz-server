/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import Annotation from '../static/scripts/common/components/Annotation';
import WikipediaExtract
  from '../static/scripts/common/components/WikipediaExtract';
import expand2react from '../static/scripts/common/i18n/expand2react';
import Relationships from '../components/Relationships';
import * as manifest from '../static/manifest';

import EventLayout from './EventLayout';

type Props = {|
  +eligibleForCleanup: boolean,
  +event: EventT,
  +numberOfRevisions: number,
  +wikipediaExtract: WikipediaExtractT,
|};

const EventIndex = ({
  eligibleForCleanup,
  event,
  numberOfRevisions,
  wikipediaExtract,
}: Props) => (
  <EventLayout entity={event} page="index">
    {eligibleForCleanup ? (
      <p className="cleanup">
        {l(
          `This event has no relationships and will be removed automatically 
           in the next few days. If this is not intended, 
           please add more data to this event.`,
        )}
      </p>
    ) : null}
    <Annotation
      annotation={event.latest_annotation}
      collapse
      entity={event}
      numberOfRevisions={numberOfRevisions}
    />
    <WikipediaExtract
      cachedWikipediaExtract={wikipediaExtract || null}
      entity={event}
    />
    <Relationships source={event} />
    {event.setlist ? (
      <>
        <h2 className="setlist">{l('Setlist')}</h2>
        <p className="setlist">
          {expand2react(event.setlist)}
        </p>
      </>
    ) : null}
    {manifest.js('event/index.js', {async: 'async'})}
  </EventLayout>
);

export default EventIndex;
