/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Annotation from '../static/scripts/common/components/Annotation';
import WikipediaExtract
  from '../static/scripts/common/components/WikipediaExtract';
import formatSetlist from '../static/scripts/common/utility/formatSetlist';
import CleanupBanner from '../components/CleanupBanner';
import Relationships from '../components/Relationships';
import * as manifest from '../static/manifest.mjs';

import EventLayout from './EventLayout';

type Props = {
  +eligibleForCleanup: boolean,
  +event: EventT,
  +numberOfRevisions: number,
  +wikipediaExtract: WikipediaExtractT,
};

const EventIndex = ({
  eligibleForCleanup,
  event,
  numberOfRevisions,
  wikipediaExtract,
}: Props): React.Element<typeof EventLayout> => {
  const setlist = event.setlist;

  return (
    <EventLayout entity={event} page="index">
      {eligibleForCleanup ? (
        <CleanupBanner entityType="event" />
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
      {setlist ? (
        <>
          <h2 className="setlist">{l('Setlist')}</h2>
          <p className="setlist">
            {formatSetlist(setlist)}
          </p>
        </>
      ) : null}
      {manifest.js('event/index', {async: 'async'})}
    </EventLayout>
  );
};

export default EventIndex;
