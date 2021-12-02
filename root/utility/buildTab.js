/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

const buildTab = (
  page?: string,
  title: string,
  path: string,
  tabPage: string,
  className?: string,
): React.Element<'li'> => {
  const isSelected = tabPage === page;
  const passedClass = nonEmpty(className) ? className : null;
  const tabClass = isSelected && nonEmpty(passedClass)
    ? 'sel ' + passedClass
    : isSelected
      ? 'sel'
      : passedClass;
  return (
    <li className={tabClass} key={tabPage}>
      <a href={path}>{title}</a>
    </li>
  );
};

export default buildTab;
