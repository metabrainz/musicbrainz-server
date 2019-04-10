/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import EntityLink from '../static/scripts/common/components/EntityLink';

type Props = {|
  +content: string,
  +entity: CoreEntityT | CollectionT,
  +selected: boolean,
  +subPath: string,
|};

const EntityTabLink = ({selected, ...linkProps}: Props) => (
  <li className={selected ? 'sel' : null}>
    <EntityLink {...linkProps} />
  </li>
);

export default EntityTabLink;
