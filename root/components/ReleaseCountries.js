/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

const buildReleaseCountry = (event) => {
  const country = event.country;
  if (!country) {
    return null;
  }
  return (
    <li key={country.id}>
      <span className={'flag flag-' + country.primary_code}>
        <abbr title={l_countries(country.name)}>
          {country.primary_code}
        </abbr>
      </span>
    </li>
  );
};

type ReleaseEventsProps = {|
  +events?: $ReadOnlyArray<ReleaseEventT>,
|};

const ReleaseCountries = ({events}: ReleaseEventsProps) => (
  events && events.length ? (
    <ul className="links">
      {events.map(buildReleaseCountry)}
    </ul>
  ) : null
);

export default ReleaseCountries;
