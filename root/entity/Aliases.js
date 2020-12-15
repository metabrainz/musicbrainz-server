/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import chooseLayoutComponent from '../utility/chooseLayoutComponent';
import AliasesComponent from '../components/Aliases';
import ArtistCreditList from '../components/Aliases/ArtistCreditList';
import RelationshipCreditList
  from '../components/Aliases/RelationshipCreditList';

type Props = {
  +$c: CatalystContextT,
  +aliases: $ReadOnlyArray<AliasT>,
  +artistCredits?: $ReadOnlyArray<{+id: number} & ArtistCreditT>,
  +entity: CoreEntityT,
  +relationshipCredits?: $ReadOnlyArray<string>,
};

const Aliases = ({
  $c,
  aliases,
  artistCredits,
  entity,
  relationshipCredits,
}: Props): React.MixedElement => {
  const entityType = entity.entityType;
  const LayoutComponent = chooseLayoutComponent(entityType);

  return (
    <LayoutComponent
      $c={$c}
      entity={entity}
      page="aliases"
      title={l('Aliases')}
    >
      <AliasesComponent $c={$c} aliases={aliases} entity={entity} />
      {artistCredits?.length ? (
        <ArtistCreditList
          $c={$c}
          artistCredits={artistCredits}
          entity={entity}
        />
      ) : null}
      {relationshipCredits?.length ? (
        <RelationshipCreditList
          entity={entity}
          relationshipCredits={relationshipCredits}
        />
      ) : null}
    </LayoutComponent>
  );
};

export default Aliases;
