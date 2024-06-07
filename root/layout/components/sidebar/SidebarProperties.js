/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export component SidebarProperty(
  children: React.Node,
  className: string,
  label: string,
) {
  return (
    <>
      <dt>{label}</dt>
      <dd className={className}>
        {children}
      </dd>
    </>
  );
}

export component SidebarProperties(children: React.Node, className?: string) {
  let _className = 'properties';
  if (nonEmpty(className)) {
    _className += ' ' + className;
  }
  return (
    <dl className={_className}>
      {children}
    </dl>
  );
}
