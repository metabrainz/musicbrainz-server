/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityLink from '../static/scripts/common/components/EntityLink.js';

type Props = {
  +content: string,
  +disabled?: boolean,
  +entity: RelatableEntityT | CollectionT,
  +selected: boolean,
  +subPath: string,
};

const EntityTabLink = ({
  disabled = false,
  selected,
  ...linkProps
}: Props): React$Element<'li'> => (
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

export default EntityTabLink;
