/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import entityHref from '../static/scripts/common/utility/entityHref';
import primaryAreaCode
  from '../static/scripts/common/utility/primaryAreaCode';

type Props = {
  +className?: string,
  +country: AreaT,
  +withLink?: boolean,
};

const CountryAbbr = ({
  className,
  country,
  withLink = false,
}: Props): React.Element<'span'> | null => {
  const primaryCode = primaryAreaCode(country);
  if (!nonEmpty(primaryCode)) {
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
};

export default CountryAbbr;
