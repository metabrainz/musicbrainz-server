/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {QUALITY_NAMES} from '../../../static/scripts/common/constants';

import {SidebarProperty} from './SidebarProperties';

type Props = {
  +quality: QualityT,
};

const SidebarDataQuality = ({quality}: Props) => {
  const name = QUALITY_NAMES.get(quality);
  return name ? (
    <SidebarProperty
      className="data-quality"
      label={addColonText(l('Data Quality'))}
    >
      {name()}
    </SidebarProperty>
  ) : null;
};

export default SidebarDataQuality;
