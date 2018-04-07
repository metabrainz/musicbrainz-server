/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');
const {withCatalystContext} = require('../context');
const {l} = require('../static/scripts/common/i18n');
const {lp_attributes} = require('../static/scripts/common/i18n/attributes');
const AreaContainmentLink = require('../static/scripts/common/components/AreaContainmentLink');
const EntityHeader = require('../components/EntityHeader');

type Props = {|
  +$c: CatalystContextT,
  +area: AreaT,
  +page: string,
|};

const AreaHeader = ({$c, area, page}: Props) => {
  const areaType = area.typeName ? lp_attributes(area.typeName, 'area_type') : l('Area');
  let subHeading = areaType;
  if (area.containment.length) {
    const parentAreas = <AreaContainmentLink area={area} />;
    subHeading = l('{area_type} in {parent_areas}', {
      __react: true,
      area_type: areaType,
      parent_areas: parentAreas,
    });
  }
  return (
    <EntityHeader
      entity={area}
      headerClass="areaheader"
      hideEditTab={!($c.user && $c.user.is_location_editor)}
      page={page}
      subHeading={subHeading}
    />
  );
};

export default withCatalystContext(AreaHeader);
