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
import formatDate from '../utility/formatDate';
import isDateEmpty from '../utility/isDateEmpty';

import CollapsibleList from './CollapsibleList';
import EntityLink from './EntityLink';

const releaseEventKey = event => (
  String(event.country ? event.country.id : '') + '\0' +
  formatDate(event.date)
);

const buildReleaseEventRow = (event, props) => {
  const abbreviated = !!(props?.abbreviated);
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
}: ReleaseEventsProps) => (
  <CollapsibleList
    ariaLabel={l('Release events')}
    buildRow={buildReleaseEventRow}
    buildRowProps={{abbreviated: abbreviated}}
    className={'release-events' + (abbreviated ? ' abbreviated' : ' links')}
    rows={events}
    showAllTitle={l('Show all release events')}
    showLessTitle={l('Show less release events')}
    toShowAfter={1}
    toShowBefore={2}
  />
);

export default (hydrate<ReleaseEventsProps>(
  'div.release-events-container',
  ReleaseEvents,
): React.AbstractComponent<ReleaseEventsProps, void>);
