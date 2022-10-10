/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityLink from '../../../common/components/EntityLink.js';
import {l} from '../../../common/i18n.js';
import {keyBy} from '../../../common/utility/arrays.js';
import formatDate from '../../../common/utility/formatDate.js';
import {
  CLASS_MAP,
  DELETE,
  INSERT,
} from '../../utility/editDiff.js';

function areReleaseCountriesEqual(a: ReleaseEventT, b: ReleaseEventT) {
  return !!(
    !(a.country || b.country) ||
    (a.country && b.country && a.country.id === b.country.id)
  );
}

function areReleaseDatesEqual(a: ReleaseEventT, b: ReleaseEventT) {
  return formatDate(a.date) === formatDate(b.date);
}

const getCountryId = (x: ReleaseEventT) => String(x.country?.id ?? null);

const changeSide = (
  oldEvent: ?ReleaseEventT,
  newEvent: ?ReleaseEventT,
  type: typeof INSERT | typeof DELETE,
) => {
  const sideA = type === DELETE ? oldEvent : newEvent;
  const sideB = type === DELETE ? newEvent : oldEvent;
  const sideACountry = sideA?.country;

  const countryDisplay = (sideACountry /*:: && sideA */) ? (
    <EntityLink
      content={
        sideB && areReleaseCountriesEqual(sideA, sideB)
          ? sideACountry.name
          : <span className={CLASS_MAP[type]}>{sideACountry.name}</span>
      }
      entity={sideACountry}
    />
  ) : null;

  const dateDisplay = (sideA && sideA.date) ? (
    <>
      {countryDisplay ? <br /> : null}
      {sideB && areReleaseDatesEqual(sideA, sideB)
        ? formatDate(sideA.date)
        : <span className={CLASS_MAP[type]}>{formatDate(sideA.date)}</span>
      }
    </>
  ) : null;

  return (
    <li>
      {countryDisplay}
      {dateDisplay}
    </li>
  );
};

type Props = {
  +newEvents: $ReadOnlyArray<ReleaseEventT>,
  +oldEvents: $ReadOnlyArray<ReleaseEventT>,
};

const ReleaseEventsDiff = ({
  newEvents,
  oldEvents,
}: Props): React.Element<'tr'> => {
  const oldEventsByCountry = keyBy(oldEvents, getCountryId);
  const newEventsByCountry = keyBy(newEvents, getCountryId);

  const oldKeys = Array.from(oldEventsByCountry.keys()).sort();
  const newKeys = Array.from(newEventsByCountry.keys()).sort();

  const oldSide = [];
  const newSide = [];

  for (let i = 0; i < oldKeys.length; i++) {
    const key = oldKeys[i];
    const oldEvent = oldEventsByCountry.get(key);
    let newEvent = newEventsByCountry.get(key);
    /*
     * If this country was removed, compare against the new entry at
     * the same position visually.
     */
    if (!newEvent && i < newKeys.length) {
      newEvent = newEventsByCountry.get(newKeys[i]);
    }
    oldSide.push(changeSide(oldEvent, newEvent, DELETE));
  }

  for (let i = 0; i < newKeys.length; i++) {
    const key = newKeys[i];
    let oldEvent = oldEventsByCountry.get(key);
    /*
     * If this country was added, compare against the old entry at
     * the same position visually.
     */
    if (!oldEvent && i < oldKeys.length) {
      oldEvent = oldEventsByCountry.get(oldKeys[i]);
    }
    const newEvent = newEventsByCountry.get(key);
    newSide.push(changeSide(oldEvent, newEvent, INSERT));
  }

  return (
    <tr className="release-events-diff">
      <th>{l('Release events:')}</th>
      <td className="old">
        <ul>
          {React.createElement(React.Fragment, null, ...oldSide)}
        </ul>
      </td>
      <td className="new">
        <ul>
          {React.createElement(React.Fragment, null, ...newSide)}
        </ul>
      </td>
    </tr>
  );
};

export default ReleaseEventsDiff;
