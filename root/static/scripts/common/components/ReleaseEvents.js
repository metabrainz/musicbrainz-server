/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import CountryAbbr from '../../../../components/CountryAbbr';
import {bracketedText} from '../utility/bracketed';
import formatDate from '../utility/formatDate';
import isDateEmpty from '../utility/isDateEmpty';

import EntityLink from './EntityLink';

const TO_SHOW_BEFORE = 2;
const TO_SHOW_AFTER = 1;
const TO_TRIGGER_COLLAPSE = TO_SHOW_BEFORE + TO_SHOW_AFTER + 2;

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
  const [expanded, setExpanded] = React.useState<boolean>(false);

  const expand = React.useCallback(event => {
    event.preventDefault();
    setExpanded(true);
  });

  const collapse = React.useCallback(event => {
    event.preventDefault();
    setExpanded(false);
  });

  const containerProps = {
    'aria-label': l('Release events'),
    'className': 'release-events' +
      (abbreviated ? ' abbreviated' : ' links'),
  };

  const tooManyEvents = events
    ? events.length >= TO_TRIGGER_COLLAPSE
    : false;

  return (
    (events && events.length) ? (
      <>
        {(tooManyEvents && !expanded) ? (
          <>
            <ul {...containerProps}>
              {events.slice(0, TO_SHOW_BEFORE).map(
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
                    n: events.length - (TO_SHOW_BEFORE + TO_SHOW_AFTER),
                  }))}
                </a>
              </li>
              {events.slice(-TO_SHOW_AFTER).map(
                event => buildReleaseEventRow(event, abbreviated),
              )}
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

export default (hydrate<ReleaseEventsProps>(
  'div.release-events-container',
  ReleaseEvents,
): React.AbstractComponent<ReleaseEventsProps, void>);
