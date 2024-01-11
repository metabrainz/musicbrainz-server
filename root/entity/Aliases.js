/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ArtistCreditList from '../components/Aliases/ArtistCreditList.js';
import AliasesComponent from '../components/Aliases/index.js';
import RelationshipCreditList
  from '../components/Aliases/RelationshipCreditList.js';
import chooseLayoutComponent from '../utility/chooseLayoutComponent.js';

type Props = {
  +aliases: $ReadOnlyArray<AnyAiasT>,
  +artistCredits?: $ReadOnlyArray<{+id: number} & ArtistCreditT>,
  +entity: EntityWithAliasesT,
  +relationshipCredits?: $ReadOnlyArray<string>,
};

const Aliases = ({
  aliases,
  artistCredits,
  entity,
  relationshipCredits,
}: Props): React$MixedElement => {
  const entityType = entity.entityType;
  const LayoutComponent = chooseLayoutComponent(entityType);

  return (
    <LayoutComponent
      entity={entity}
      page="aliases"
      title={l('Aliases')}
    >
      <AliasesComponent aliases={aliases} entity={entity} />
      {/*:: entity.entityType === 'artist' && */ artistCredits?.length ? (
        <ArtistCreditList
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
