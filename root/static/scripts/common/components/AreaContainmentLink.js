/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import commaOnlyList from '../../common/i18n/commaOnlyList.js';

import EntityLink from './EntityLink.js';

const makeLink = (
  area: AreaT,
  key: number,
) => <EntityLink entity={area} key={key} />;

type Props = {
  +area: AreaT,
};

const AreaContainmentLink = ({area}: Props): Expand2ReactOutput | null => (
  area.containment
    ? commaOnlyList(area.containment.map(makeLink))
    : null
);

export default AreaContainmentLink;
