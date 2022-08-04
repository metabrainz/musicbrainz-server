/*
 * @flow strict-local
 * Copyright (C) 2015–2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import commaOnlyList from '../../common/i18n/commaOnlyList';

import EntityLink from './EntityLink';

const makeContainmentLink = (x: AreaT, i: number) => (
  <EntityLink entity={x} key={i + 1} />
);

type Props = {
  +allowNew?: boolean,
  +area: AreaT,
  +content?: Expand2ReactOutput,
  +deletedCaption?: string,
  +disableLink?: boolean,
  +showDisambiguation?: boolean,
  +showIcon?: boolean,
  +subPath?: string,
  +target?: '_blank',
};

const AreaWithContainmentLink = ({
  area,
  ...props
}: Props): Expand2ReactOutput => {
  const areaLink = <EntityLink entity={area} key={0} {...props} />;

  return area.containment ? commaOnlyList(
    [areaLink].concat(area.containment.map(makeContainmentLink)),
  ) : areaLink;
};

export default AreaWithContainmentLink;
