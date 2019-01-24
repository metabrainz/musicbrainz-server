/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import * as manifest from '../../../manifest';
import {l} from '../../common/i18n';

const WarningIcon = () => (
  <img
    alt={l('Warning')}
    className="warning"
    src={manifest.pathTo('/images/icons/warning.png')}
  />
);

export default WarningIcon;
