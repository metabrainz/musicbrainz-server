/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import linkedEntities from '../static/scripts/common/linkedEntities';

export default function releaseGroupType(
  releaseGroup: ReleaseGroupT,
) {
  const types = [];
  let id = releaseGroup.typeID;
  if (id) {
    types.push(lp_attributes(
      linkedEntities.release_group_primary_type[id].name,
      'release_group_primary_type',
    ));
  }
  const secondaryTypeIDs = releaseGroup.secondaryTypeIDs;
  for (let i = 0; i < secondaryTypeIDs.length; i++) {
    id = secondaryTypeIDs[i];
    types.push(lp_attributes(
      linkedEntities.release_group_secondary_type[id].name,
      'release_group_secondary_type',
    ));
  }
  return types.join(' + ');
}
