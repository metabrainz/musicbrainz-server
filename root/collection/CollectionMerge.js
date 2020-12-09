/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import type {ColumnOptions} from 'react-table';

import FieldErrors from '../components/FieldErrors';
import Table from '../components/Table';
import Layout from '../layout';
import {ENTITY_NAMES} from '../static/scripts/common/constants';
import {sortByString, uniqBy} from '../static/scripts/common/utility/arrays';
import UserInlineList from '../user/components/UserInlineList';
import {
  defineCheckboxColumn,
  defineNameColumn,
  defineTextColumn,
  defineTypeColumn,
  removeFromMergeColumn,
} from '../utility/tableColumns';

type Props = {
  +$c: CatalystContextT,
  +form: MergeFormT,
  +toMerge: $ReadOnlyArray<CollectionT>,
  +typesDiffer?: boolean,
};

const CollectionMergeTable = ({
  collections,
  form,
}) => {
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
          accessor: 'entity_count',
          Header: l('Entities'),
          id: 'size',
        };
      const collaboratorsColumn:
        ColumnOptions<CollectionT, $ReadOnlyArray<EditorT>> = {
          accessor: 'collaborators',
          Cell: ({cell: {value}}) => value.length,
          Header: l('Collaborators'),
          id: 'collaborators',
        };
      const privacyColumn:
        ColumnOptions<CollectionT, boolean> = {
          accessor: 'public',
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

  return <Table columns={columns} data={collections} />;
};

const CollectionMerge = ({
  $c,
  form,
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
    <Layout $c={$c} fullWidth title={l('Merge collections')}>
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
        <form action={$c.req.uri} method="post">
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
