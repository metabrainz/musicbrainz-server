/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';
import EditLink from '../static/scripts/common/components/EditLink.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import commaOnlyList from '../static/scripts/common/i18n/commaOnlyList.js';
import {bracketedText} from '../static/scripts/common/utility/bracketed.js';
import {formatPluralEntityTypeName}
  from '../static/scripts/common/utility/formatEntityTypeName.js';
import {getEditStatusName} from '../utility/edit.js';

type RelatedEntitiesT = {
  +[type: EditableEntityTypeT]: {
    +[entityId: string]: EditableEntityT,
  },
};

component EditData(
  edit: GenericEditWithIdT,
  rawData: string,
  relatedEntities: RelatedEntitiesT,
) {
  const title = texp.l('Edit data for edit #{id}', {id: edit.id});
  const relatedEntityTypes = Object.keys(relatedEntities).sort();

  return (
    <Layout fullWidth title={title}>
      <h1>{title}</h1>

      <p>
        <strong>{('Type:')}</strong>
        {' '}
        {lp(edit.edit_name, edit.edit_type_name_context)}
        {' '}
        {bracketedText(edit.edit_type)}
      </p>

      <p>
        <strong>{('Status:')}</strong>
        {' '}
        {getEditStatusName(edit)}
        {' '}
        {bracketedText(edit.status)}
      </p>

      <p><strong>{l('Data:')}</strong></p>
      <pre id="edit-raw-data">{rawData}</pre>

      {relatedEntityTypes.length ? (
        <>
          <p><strong>{l('Related entities:')}</strong></p>
          <ul>
            {relatedEntityTypes.map((type, index) => {
              const typeName = formatPluralEntityTypeName(type);
              const relatedEntitiesOfType = relatedEntities[type];
              const entityLinks =
                Object.keys(relatedEntitiesOfType).map(key => (
                  <EntityLink
                    content={key}
                    entity={relatedEntitiesOfType[key]}
                    key={type + '-' + key}
                  />
                ));

              return (
                <li key={index}>
                  {addColonText(typeName)}
                  {' '}
                  {commaOnlyList(entityLinks)}
                </li>
              );
            })}
          </ul>
        </>
      ) : null}

      <p>
        {texp.l(
          `This is the raw data for edit #{id}.
          It is available for debugging purposes.`,
          {id: edit.id},
        )}
        {' '}
        <EditLink
          content={l('View the human-readable rendering instead.')}
          edit={edit}
        />
      </p>
    </Layout>
  );
}

export default EditData;
