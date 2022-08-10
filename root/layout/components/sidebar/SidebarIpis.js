/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';


import {SidebarProperty} from './SidebarProperties.js';

const buildSidebarIpi = (ipi: IpiCodeT) => (
  <SidebarProperty
    className="ipi-code"
    key={'ipi-code-' + ipi.ipi}
    label={l('IPI code:')}
  >
    {ipi.ipi}
  </SidebarProperty>
);

type Props = {
  +entity: $ReadOnly<{...IpiCodesRoleT, ...}>,
};

const SidebarIpis = ({entity}: Props):
  React.ChildrenArray<React.Element<typeof SidebarProperty>> => (
  entity.ipi_codes.map(buildSidebarIpi)
);

export default SidebarIpis;
