/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React, {useCallback, useState} from 'react';

import CountryAbbr from '../../../../components/CountryAbbr';
import hydrate from '../../../../utility/hydrate';
import {bracketedText} from '../utility/bracketed';
import formatDate from '../utility/formatDate';
import isDateEmpty from '../utility/isDateEmpty';

import EntityLink from './EntityLink';

const COLLAPSE_THRESHOLD = 4;

const releaseEventKey = event => (
  String(event.country ? event.country.id : '') + '\0' +
  formatDate(event.date)
);

const buildReleaseEventRow = (event, abbreviated) => {
  const country = event.country;
  const hasDate = !isDateEmpty(event.date);

  return (
    <li
      aria-label={l('Release event')}
      className="release-event"
      key={releaseEventKey(event)}
    >
      {country ? (
        abbreviated ? (
          <CountryAbbr
            className="release-country"
            country={country}
            withLink
          />
        ) : (
          <EntityLink entity={country} />
        )
      ) : (
        abbreviated ? (
          <span
            className="release-country no-country"
            title={l('Missing country')}
          >
            {lp('-', 'missing data')}
          </span>
        ) : null
      )}

      {(abbreviated || !country || !hasDate) ? null : <br />}

      {hasDate ? (
        <span className="release-date">
          {formatDate(event.date)}
        </span>
      ) : (
        abbreviated ? (
          <span
            className="release-date no-date"
            title={l('Missing date')}
          >
            {lp('-', 'missing data')}
          </span>
        ) : null
      )}
    </li>
  );
};

type ReleaseEventsProps = {|
  +abbreviated?: boolean,
  +events: ?$ReadOnlyArray<ReleaseEventT>,
|};

const ReleaseEvents = ({
  abbreviated = true,
  events,
}: ReleaseEventsProps) => {
  const [expanded, setExpanded] = useState<boolean>(false);

  const expand = useCallback(event => {
    event.preventDefault();
    setExpanded(true);
  });

  const collapse = useCallback(event => {
    event.preventDefault();
    setExpanded(false);
  });

  const containerProps = {
    'aria-label': l('Release events'),
    'className': 'release-events' +
      (abbreviated ? ' abbreviated' : ' links'),
  };

  const tooManyEvents = events
    ? events.length > COLLAPSE_THRESHOLD
    : false;

  return (
    (events && events.length) ? (
      <>
        {(tooManyEvents && !expanded) ? (
          <>
            <ul {...containerProps}>
              {events.slice(0, COLLAPSE_THRESHOLD - 2).map(
                event => buildReleaseEventRow(event, abbreviated),
              )}
              <li className="show-all" key="show-all">
                <a
                  href="#"
                  onClick={expand}
                  role="button"
                  title={l('Show all release events')}
                >
                  {bracketedText(texp.l('show {n} more', {
                    n: events.length - COLLAPSE_THRESHOLD,
                  }))}
                </a>
              </li>
              {buildReleaseEventRow(events[events.length - 1], abbreviated)}
            </ul>
          </>
        ) : (
          <ul {...containerProps}>
            {events.map(event => buildReleaseEventRow(event, abbreviated))}
            {tooManyEvents && expanded ? (
              <li className="show-less" key="show-less">
                <a
                  href="#"
                  onClick={collapse}
                  role="button"
                  title={l('Show less release events')}
                >
                  {bracketedText(l('show less'))}
                </a>
              </li>
            ) : null}
          </ul>
        )}
      </>
    ) : null
  );
};

export default hydrate<ReleaseEventsProps>(
  'div.release-events-container',
  ReleaseEvents,
);
