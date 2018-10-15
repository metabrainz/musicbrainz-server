/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {l_attributes} from '../static/scripts/common/i18n/attributes';

export default function releaseGroupType(
  $c: CatalystContextT,
  releaseGroup: ReleaseGroupT,
) {
  const types = [];
  let id = releaseGroup.typeID;
  if (id) {
    types.push(l_attributes(
      $c.linked_entities.release_group_primary_type[id].name,
    ));
  }
  const secondaryTypeIDs = releaseGroup.secondaryTypeIDs;
  for (let i = 0; i < secondaryTypeIDs.length; i++) {
    id = secondaryTypeIDs[i];
    types.push(l_attributes(
      $c.linked_entities.release_group_secondary_type[id].name,
    ));
  }
  return types.join(' + ');
}
