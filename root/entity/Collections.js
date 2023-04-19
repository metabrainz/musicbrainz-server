/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EditorLink from '../static/scripts/common/components/EditorLink.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import chooseLayoutComponent from '../utility/chooseLayoutComponent.js';

type DetailsProps = {
  +entity: CollectableEntityT,
  +privateCollectionCount: number,
  +publicCollections: $ReadOnlyArray<CollectionT>,
};

const Details = ({
  entity,
  publicCollections,
  privateCollectionCount,
}: DetailsProps): React$MixedElement => {
  const entityType = entity.entityType;
  const LayoutComponent = chooseLayoutComponent(entityType);
  const publicCollectionCount = publicCollections.length;
  const totalCollections = publicCollectionCount + privateCollectionCount;
  return (
    <LayoutComponent
      entity={entity}
      page="collections"
      title={l('Collections')}
    >
      <h2>{l('Collections')}</h2>
      {totalCollections > 0 ? (
        <>
          <p>
            {exp.ln(
              '{entity} has been added to {num} collection:',
              '{entity} has been added to {num} collections:',
              totalCollections,
              {entity: entity.name, num: totalCollections},
            )}
          </p>
          <ul>
            {publicCollections.map((collection) => (
              <li key={collection.id}>
                {exp.l(
                  '{collection} by {owner}',
                  {
                    collection: <EntityLink entity={collection} />,
                    owner: <EditorLink editor={collection.editor} />,
                  },
                )}
              </li>
            ))}
            {privateCollectionCount > 0
              ? publicCollectionCount > 0 ? (
                <li>
                  {exp.ln(
                    'plus {n} other private collection',
                    'plus {n} other private collections',
                    privateCollectionCount,
                    {n: privateCollectionCount},
                  )}
                </li>
              ) : (
                <li>
                  {exp.ln(
                    'A private collection',
                    '{n} private collections',
                    privateCollectionCount,
                    {n: privateCollectionCount},
                  )}
                </li>
              ) : null}
          </ul>
        </>
      ) : (
        <p>
          {exp.l(
            '{entity} has not been added to any collections.',
            {entity: entity.name},
          )}
        </p>
      )}
    </LayoutComponent>
  );
};

export default Details;
