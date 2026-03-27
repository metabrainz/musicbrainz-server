/*
 * @flow strict
 * Copyright (C) 2019 Anirudh Jain
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../context.mjs';
import {compare} from '../static/scripts/common/i18n.js';
import {isRelationshipEditor}
  from '../static/scripts/common/utility/privileges.js';
import yesNo from '../static/scripts/common/utility/yesNo.js';
import loopParity from '../utility/loopParity.js';

import AttributeLayout from './AttributeLayout.js';
import {type AttributeT} from './types.js';

const extraHeaders = (model: string) => {
  return match (model) {
    'MediumFormat' => (
      <>
        <th>{'Year'}</th>
        <th>{'Disc IDs allowed'}</th>
      </>
    ),
    'CollectionType' | 'SeriesType' => <th>{'Entity type'}</th>,
    'WorkAttributeType' => <th>{'Free text'}</th>,
    _ => null,
  };
};

const extraColumns = (attribute: AttributeT) => {
  return match (attribute) {
    {entityType: 'medium_format', const has_discids, const year, ...} => (
      <>
        <td>{year}</td>
        <td>{yesNo(has_discids)}</td>
      </>
    ),
    {
      entityType: 'collection_type' | 'series_type',
      const item_entity_type,
      ...
    } => (
      <td>{item_entity_type}</td>
    ),
    {entityType: 'work_attribute_type', const free_text, ...} => (
      <td>{yesNo(free_text)}</td>
    ),
    _ => null,
  };
};

component Attribute(
  attributes as passedAttributes: Array<AttributeT>,
  model: string,
) {
  const attributes = [...passedAttributes];
  const $c = React.useContext(CatalystContext);
  const showEditSections = isRelationshipEditor($c.user);

  return (
    <AttributeLayout model={model} showEditSections={showEditSections}>
      <table className="tbl">
        <thead>
          <tr>
            <th>{l('ID')}</th>
            <th>{l('Name')}</th>
            <th>{l('Description')}</th>
            <th>{l('MBID')}</th>
            {showEditSections ? (
              <>
                <th>{l_admin('Child order')}</th>
                <th>{l_admin('Parent ID')}</th>
              </>
            ) : null}
            {extraHeaders(model)}
            {showEditSections ? (
              <th>{l_admin('Actions')}</th>
            ) : null}
          </tr>
        </thead>
        <tbody>
          {attributes ? attributes
            .sort((a, b) => compare(a.name, b.name))
            .map((attribute, index) => {
              const context = attribute.entityType === 'release_group_type'
                ? 'release_group_primary_type'
                : attribute.entityType;
              return (
                <tr className={loopParity(index)} key={attribute.id}>
                  <td>{attribute.id}</td>
                  <td>{lp_attributes(attribute.name, context)}</td>
                  <td>
                    {nonEmpty(attribute.description)
                      ? lp_attributes(attribute.description, context)
                      : null}
                  </td>
                  <td>{attribute.gid}</td>
                  {showEditSections ? (
                    <>
                      <td>{attribute.child_order}</td>
                      <td>{attribute.parent_id}</td>
                    </>
                  ) : null}
                  {extraColumns(attribute)}
                  {showEditSections ? (
                    <td>
                      <a
                        href={
                          `/attributes/${model}/edit/${attribute.id}`
                        }
                      >
                        {l_admin('Edit')}
                      </a>
                      {' | '}
                      <a
                        href={
                          `/attributes/${model}/delete/${attribute.id}`
                        }
                      >
                        {l_admin('Remove')}
                      </a>
                    </td>
                  ) : null}
                </tr>
              );
            }) : null}
        </tbody>
      </table>
    </AttributeLayout>
  );
}

export default Attribute;
