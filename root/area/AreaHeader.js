/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityHeader from '../components/EntityHeader.js';
import AreaContainmentLink
  from '../static/scripts/common/components/AreaContainmentLink.js';
import localizeTypeNameForEntity
  from '../static/scripts/common/i18n/localizeTypeNameForEntity.js';

component AreaHeader(area: AreaT, page: string) {
  const areaType = localizeTypeNameForEntity(area);
  let subHeading: Expand2ReactOutput = areaType;
  if (area.containment?.length) {
    const parentAreas = <AreaContainmentLink area={area} />;
    subHeading = exp.l('{area_type} in {parent_areas}', {
      area_type: areaType,
      parent_areas: parentAreas,
    });
  }
  return (
    <EntityHeader
      entity={area}
      headerClass="areaheader"
      page={page}
      subHeading={subHeading}
    />
  );
}

export default AreaHeader;
