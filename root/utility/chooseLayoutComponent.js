/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ReleaseGroupLayout from '../release_group/ReleaseGroupLayout';

const layoutPicker = {
  release_group: ReleaseGroupLayout,
};

export default function chooseLayoutComponent(typeName: string) {
  return layoutPicker[typeName];
}
