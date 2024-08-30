/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import entityHref from '../utility/entityHref.js';
import primaryAreaCode from '../utility/primaryAreaCode.js';

component CountryAbbr(
  className?: string,
  country: AreaT,
  withLink: boolean = false,
) {
  const primaryCode = primaryAreaCode(country);
  if (empty(primaryCode)) {
    return null;
  }
  const combinedClass =
    ('flag flag-' + primaryCode) +
    (nonEmpty(className) ? (' ' + className) : '');
  let content: React.MixedElement = (
    <abbr title={l_countries(country.name)}>
      {primaryCode}
    </abbr>
  );
  if (withLink) {
    content = (
      <a href={entityHref(country)}>
        {content}
      </a>
    );
  }
  return (
    <span className={combinedClass}>
      {content}
    </span>
  );
}

export default CountryAbbr;
