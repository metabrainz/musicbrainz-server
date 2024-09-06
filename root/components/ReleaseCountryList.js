/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import CountryAbbr from '../static/scripts/common/components/CountryAbbr.js';
import commaOnlyList from '../static/scripts/common/i18n/commaOnlyList.js';

const displayCountry = (
  country: AreaT,
): React.Element<typeof CountryAbbr> => (
  <CountryAbbr className="release-country" country={country} />
);

component ReleaseCountryList(
  events as releaseEvents?: $ReadOnlyArray<ReleaseEventT>
) {
  if (!releaseEvents || !releaseEvents.length) {
    return null;
  }
  const countries = new Set<AreaT>();
  for (const releaseEvent of releaseEvents) {
    const country = releaseEvent.country;
    if (country) {
      countries.add(country);
    }
  }
  return commaOnlyList(Array.from(countries.values()).map(displayCountry));
}

export default ReleaseCountryList;
