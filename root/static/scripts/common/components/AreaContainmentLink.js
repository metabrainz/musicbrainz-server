/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import commaOnlyList from '../i18n/commaOnlyList';

import EntityLink from './EntityLink';

const makeLink = (x, i) => <EntityLink entity={x} key={i} />;

const AreaContainmentLink = ({area}) => (
  area.containment
    ? commaOnlyList(area.containment.map(makeLink))
    : null
);

export default AreaContainmentLink;
