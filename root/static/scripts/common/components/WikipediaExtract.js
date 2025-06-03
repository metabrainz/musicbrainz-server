/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as Sentry from '@sentry/browser';
import * as React from 'react';

import {minimalEntity} from '../../../../utility/hydrate.js';
import entityHref from '../utility/entityHref.js';

import Collapsible from './Collapsible.js';

type EntityWithWikipediaExtractT =
  | AreaT
  | ArtistT
  | EventT
  | GenreT
  | InstrumentT
  | LabelT
  | PlaceT
  | ReleaseGroupT
  | SeriesT
  | WorkT;

type MinimalEntityWithWikipediaExtractT = {
  +entityType: EntityWithWikipediaExtractT['entityType'],
  +gid: string,
};

type WikipediaExtractRequestCallbackT = (WikipediaExtractT | null) => void;

function loadWikipediaExtract(
  entity: EntityWithWikipediaExtractT | MinimalEntityWithWikipediaExtractT,
  callback: WikipediaExtractRequestCallbackT,
): void {
  const url = entityHref(entity, '/wikipedia-extract');

  fetch(url)
    .then(resp => resp.json())
    .then((reqData) => {
      try {
        callback(reqData.wikipediaExtract);
      } catch (error) {
        console.error(error);
        Sentry.captureException(error);
      }
    })
    .catch(console.error);
}

component WikipediaExtract(
  cachedWikipediaExtract: WikipediaExtractT | null,
  entity: EntityWithWikipediaExtractT | MinimalEntityWithWikipediaExtractT,
) {
  const [wikipediaExtract, setWikipediaExtract] =
    React.useState(cachedWikipediaExtract);

  React.useEffect(() => {
    if (cachedWikipediaExtract == null) {
      loadWikipediaExtract(entity, setWikipediaExtract);
    }
  }, [entity]);

  return wikipediaExtract ? (
    <>
      <h2 className="wikipedia">{l('Wikipedia')}</h2>
      <Collapsible
        className="wikipedia-extract"
        html={wikipediaExtract.content}
      />
      <a href={wikipediaExtract.url}>
        {l('Continue reading at Wikipedia...')}
      </a>
      {' '}
      <small>
        {exp.l(
          `Wikipedia content provided under the terms of the
            {license_link|Creative Commons BY-SA license}`,
          {license_link: 'https://creativecommons.org/licenses/by-sa/3.0/'},
        )}
      </small>
    </>
  ) : null;
}

export default (hydrate<React.PropsOf<WikipediaExtract>>(
  'div.wikipedia-extract',
  WikipediaExtract,
  minimalEntity,
): component(...React.PropsOf<WikipediaExtract>));
