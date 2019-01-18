/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import Aliases from '../components/Aliases';
import {l} from '../static/scripts/common/i18n';

import ReleaseGroupLayout from './ReleaseGroupLayout';

type Props = {|
  +aliases: $ReadOnlyArray<AliasT>,
  +entity: ReleaseGroupT,
|};

const ReleaseGroupAliases = ({aliases, entity}: Props) => (
  <ReleaseGroupLayout entity={entity} page="aliases" title={l('Aliases')}>
    <Aliases aliases={aliases} entity={entity} />
  </ReleaseGroupLayout>
);

export default ReleaseGroupAliases;
