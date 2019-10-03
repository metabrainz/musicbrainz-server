/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import primaryAreaCode
  from '../static/scripts/common/utility/primaryAreaCode';

const CountryAbbr = ({country}: {|+country: AreaT|}) => {
  const primaryCode = primaryAreaCode(country);
  if (!primaryCode) {
    return null;
  }
  return (
    <span className={'flag flag-' + primaryCode}>
      <abbr title={l_countries(country.name)}>
        {primaryCode}
      </abbr>
    </span>
  );
};

export default CountryAbbr;
