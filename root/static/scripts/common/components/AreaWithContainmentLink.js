/*
 * @flow strict
 * Copyright (C) 2015–2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import commaOnlyList from '../../common/i18n/commaOnlyList.js';

import EntityLink from './EntityLink.js';

type Props = {
  +allowNew?: boolean,
  +area: AreaT,
  +content?: Expand2ReactOutput,
  +deletedCaption?: string,
  +disableLink?: boolean,
  +showDisambiguation?: boolean,
  +showEditsPending?: boolean,
  +showIcon?: boolean,
  +subPath?: string,
  +target?: '_blank',
};

const AreaWithContainmentLink = ({
  area,
  showDisambiguation = true,
  showEditsPending = true,
  showIcon = false,
  ...props
}: Props): Expand2ReactOutput => {
  const sharedProps = {
    showDisambiguation,
    showEditsPending,
    showIcon,
  };

  const areaLink = (
    <EntityLink
      entity={area}
      key={0}
      {...props}
      {...sharedProps}
    />
  );

  return area.containment ? commaOnlyList(
    [areaLink].concat(area.containment.map((containingArea, index) => (
      <EntityLink
        entity={containingArea}
        key={index + 1}
        {...sharedProps}
      />
    ))),
  ) : areaLink;
};

export default AreaWithContainmentLink;
