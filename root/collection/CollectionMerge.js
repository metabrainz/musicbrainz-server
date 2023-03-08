/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import type {ColumnOptions} from 'react-table';

import useTable from '../hooks/useTable.js';
import Layout from '../layout/index.js';
import {ENTITY_NAMES} from '../static/scripts/common/constants.js';
import {
  sortByString,
  uniqBy,
} from '../static/scripts/common/utility/arrays.js';
import FieldErrors from '../static/scripts/edit/components/FieldErrors.js';
import UserInlineList from '../user/components/UserInlineList.js';
import {
  defineCheckboxColumn,
  defineNameColumn,
  defineTextColumn,
  defineTypeColumn,
  removeFromMergeColumn,
} from '../utility/tableColumns.js';

type Props = {
  +form: MergeFormT,
  +privaciesDiffer?: boolean,
  +toMerge: $ReadOnlyArray<CollectionT>,
  +typesDiffer?: boolean,
};

type CollectionMergeTablePropsT = {
  +collections: $ReadOnlyArray<CollectionT>,
  +form: MergeFormT,
};

const CollectionMergeTable = ({
  collections,
  form,
}: CollectionMergeTablePropsT) => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = defineCheckboxColumn({mergeForm: form});
      const nameColumn = defineNameColumn<CollectionT>({
        title: l('Collection'),
      });
      const typeColumn = defineTypeColumn({typeContext: 'collection_type'});
      const entityTypeColumn = defineTextColumn<CollectionT>({
        columnName: 'item_entity_type',
        getText: entity => entity.item_entity_type
          ? ENTITY_NAMES[entity.item_entity_type]()
          : '',
        title: l('Entity Type'),
      });
      const sizeColumn:
        ColumnOptions<CollectionT, number> = {
          accessor: x => x.entity_count,
          Header: l('Entities'),
          id: 'size',
        };
      const collaboratorsColumn:
        ColumnOptions<CollectionT, $ReadOnlyArray<EditorT>> = {
          accessor: x => x.collaborators,
          Cell: ({cell: {value}}) => value.length,
          Header: l('Collaborators'),
          id: 'collaborators',
        };
      const privacyColumn:
        ColumnOptions<CollectionT, boolean> = {
          accessor: x => x.public,
          Cell: ({row: {original}}) => original.public
            ? l('Public')
            : l('Private'),
          Header: l('Privacy'),
          id: 'privacy',
        };

      return [
        checkboxColumn,
        nameColumn,
        typeColumn,
        entityTypeColumn,
        sizeColumn,
        collaboratorsColumn,
        privacyColumn,
        ...(collections.length > 2 ? [removeFromMergeColumn] : []),
      ];
    },
    [collections, form],
  );

  return useTable<CollectionT>({columns, data: collections});
};

const CollectionMerge = ({
  form,
  privaciesDiffer,
  toMerge,
  typesDiffer,
}: Props): React.Element<typeof Layout> => {
  const collections = sortByString(toMerge, collection => collection.name);
  const collaborators = sortByString(
    uniqBy(
      collections.flatMap(collection => collection.collaborators),
      collaborator => collaborator.id,
    ),
    collaborator => collaborator.name,
  );

  return (
    <Layout fullWidth title={l('Merge collections')}>
      <div id="content">
        <h1>{l('Merge collections')}</h1>
        <p>
          {l(`You are about to merge all these collections into a single one.
              Please select the collection all others
              should be merged into:`)}
        </p>
        {typesDiffer /*:: === true */ ? (
          <div className="warning warning-types-differ">
            <p>
              {collections.length > 2 ? (
                exp.l(
                  `<strong>Warning:</strong> These collections are
                  for different entity types. Please remove some collections
                  from the merge queue until you only have collections
                  for the same entity type.`,
                )
              ) : (
                exp.l(
                  `<strong>Warning:</strong> These collections are
                  for different entity types. Only collections
                  for the same entity type can be merged.`,
                )
              )}
            </p>
          </div>
        ) : null}
        {privaciesDiffer /*:: === true */ ? (
          <div className="warning warning-privacy-differs">
            <p>
              {exp.l(
                `<strong>Warning:</strong> Some of these collections are
                 public and some are private. Keep in mind the privacy
                 setting of the destination collection will apply. If you
                 merge your private collections into a public one, the
                 final result will be visible to other users.`,
              )}
            </p>
          </div>
        ) : null}
        <form method="post">
          <CollectionMergeTable collections={collections} form={form} />

          {collaborators.length ? (
            <>
              <p>
                {l(`The merged collection will have
                    the following collaborators:`)}
              </p>

              <UserInlineList editors={collaborators} />
            </>
          ) : null}

          <FieldErrors field={form.field.target} />

          <p>
            {l(`This process cannot be reverted.
                Are you sure you want to enter a merge?`)}
          </p>

          <div className="buttons">
            <button
              className="submit positive"
              disabled={typesDiffer}
              type="submit"
            >
              {l('Confirm')}
            </button>

            <button
              className="negative"
              name="submit"
              type="submit"
              value="cancel"
            >
              {l('Cancel')}
            </button>
          </div>
        </form>
      </div>
    </Layout>
  );
};

export default CollectionMerge;
