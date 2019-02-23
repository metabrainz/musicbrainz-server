/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import chooseLayoutComponent from '../utility/chooseLayoutComponent';
import AliasesComponent from '../components/Aliases';


type Props = {|
  +aliases: $ReadOnlyArray<AliasT>,
  +entity: CoreEntityT,
|};

const Aliases = ({aliases, entity}: Props) => {
  const entityType = entity.entityType;
  const LayoutComponent = chooseLayoutComponent(entityType);

  return (
    <LayoutComponent entity={entity} page="aliases" title={l('Aliases')}>
      <AliasesComponent aliases={aliases} entity={entity} />
    </LayoutComponent>
  );
};

export default Aliases;
