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
import ArtistCreditList from '../components/Aliases/ArtistCreditList';

type Props = {|
  +aliases: $ReadOnlyArray<AliasT>,
  +artistCredits?: $ReadOnlyArray<{
    +id: number,
    +names: ArtistCreditT,
  }>,
  +entity: CoreEntityT,
|};

const Aliases = ({aliases, artistCredits, entity}: Props) => {
  const entityType = entity.entityType;
  const LayoutComponent = chooseLayoutComponent(entityType);

  return (
    <LayoutComponent entity={entity} page="aliases" title={l('Aliases')}>
      <AliasesComponent aliases={aliases} entity={entity} />
      {artistCredits && artistCredits.length > 0 ? (
        <ArtistCreditList artistCredits={artistCredits} entity={entity} />
      ) : null}
    </LayoutComponent>
  );
};

export default Aliases;
