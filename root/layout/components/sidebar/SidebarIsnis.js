/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {l} from '../../../static/scripts/common/i18n';
import formatIsni from '../../../utility/formatIsni';

import {SidebarProperty} from './SidebarProperties';

const isniUrl = 'http://www.isni.org/';

const buildSidebarIsni = (isni, index) => (
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

type Props = {|
  +entity: {...IsniCodesRoleT},
|};

const SidebarIsnis = ({entity}: Props):
  React.ChildrenArray<React.Element<typeof SidebarProperty>> => (
  entity.isni_codes.map(buildSidebarIsni)
);

export default SidebarIsnis;
