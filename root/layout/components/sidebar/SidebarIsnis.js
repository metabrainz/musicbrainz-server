/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import formatIsni from '../../../utility/formatIsni.js';

import {SidebarProperty} from './SidebarProperties.js';

const isniUrl = 'http://www.isni.org/';

const buildSidebarIsni = (isni: IsniCodeT) => (
  <SidebarProperty
    className="isni-code"
    key={'isni-code-' + isni.isni}
    label={l('ISNI code:')}
  >
    <a href={isniUrl + isni.isni}>
      {formatIsni(isni.isni)}
    </a>
  </SidebarProperty>
);

type Props = {
  +entity: $ReadOnly<{...IsniCodesRoleT, ...}>,
};

const SidebarIsnis = ({entity}: Props):
  React.ChildrenArray<React.Element<typeof SidebarProperty>> => (
  entity.isni_codes.map(buildSidebarIsni)
);

export default SidebarIsnis;
