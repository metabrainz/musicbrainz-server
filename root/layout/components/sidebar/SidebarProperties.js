/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

type SidebarPropertyProps = {
  +children: React$Node,
  +className: string,
  +label: string,
};

export const SidebarProperty = ({
  children,
  className,
  label,
}: SidebarPropertyProps): React$Element<typeof React.Fragment> => (
  <>
    <dt>{label}</dt>
    <dd className={className}>
      {children}
    </dd>
  </>
);

type SidebarPropertiesProps = {
  +children: React$Node,
  +className?: string,
};

export const SidebarProperties = ({
  className,
  children,
}: SidebarPropertiesProps): React$Element<'dl'> => {
  let _className = 'properties';
  if (nonEmpty(className)) {
    _className += ' ' + className;
  }
  return (
    <dl className={_className}>
      {children}
    </dl>
  );
};
