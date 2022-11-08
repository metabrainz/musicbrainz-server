/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ArtistCreditList from '../components/Aliases/ArtistCreditList.js';
import AliasesComponent from '../components/Aliases/index.js';
import chooseLayoutComponent from '../utility/chooseLayoutComponent.js';

type Props = {
  +aliases: $ReadOnlyArray<AliasT>,
  +artistCredits?: $ReadOnlyArray<{+id: number} & ArtistCreditT>,
  +entity: EntityWithAliasesT,
};

const Aliases = ({
  aliases,
  artistCredits,
  entity,
}: Props): React.MixedElement => {
  const entityType = entity.entityType;
  const LayoutComponent = chooseLayoutComponent(entityType);

  return (
    <LayoutComponent
      entity={entity}
      page="aliases"
      title={l('Aliases')}
    >
      <AliasesComponent aliases={aliases} entity={entity} />
      {artistCredits?.length ? (
        <ArtistCreditList
          artistCredits={artistCredits}
          // $FlowIgnore[unclear-type] Only artists have credits
          entity={((entity: any): ArtistT)}
        />
      ) : null}
    </LayoutComponent>
  );
};

export default Aliases;
