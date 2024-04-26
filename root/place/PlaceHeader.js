/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityHeader from '../components/EntityHeader.js';
import localizeTypeNameForEntity
  from '../static/scripts/common/i18n/localizeTypeNameForEntity.js';

component PlaceHeader(page: string, place: PlaceT) {
  return (
    <EntityHeader
      entity={place}
      headerClass="placeheader"
      page={page}
      subHeading={localizeTypeNameForEntity(place)}
    />
  );
}

export default PlaceHeader;
