/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityLink from '../static/scripts/common/components/EntityLink.js';

component EntityTabLink(
  disabled: boolean = false,
  selected: boolean,
  ...linkProps: {
    +content: string,
    +entity: RelatableEntityT | CollectionT,
    +subPath: string,
  }
) {
  return (
    <li
      className={
        selected || disabled
          ? (selected ? 'sel' : '') +
            (selected && disabled ? ' ' : '') +
            (disabled ? 'disabled' : '')
          : null
      }
    >
      <EntityLink {...linkProps} />
    </li>
  );
}

export default EntityTabLink;
