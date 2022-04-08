/*
 * @flow strict
 * Copyright (C) 2019 Anirudh Jain
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../../layout/index.js';
import {compare} from '../../static/scripts/common/i18n.js';
import yesNo from '../../static/scripts/common/utility/yesNo.js';
import loopParity from '../../utility/loopParity.js';

import {type AttributeT} from './types.js';

type Props = {
  +attributes: Array<AttributeT>,
  +model: string,
};

const extraHeaders = (model: string) => {
  switch (model) {
    case 'MediumFormat': {
      return (
        <>
          <th>{'Year'}</th>
          <th>{'Disc IDs allowed'}</th>
        </>
      );
    }
    case 'SeriesType':
    case 'CollectionType': {
      return <th>{'Entity type'}</th>;
    }
    case 'WorkAttributeType': {
      return <th>{'Free text'}</th>;
    }
    default: return null;
  }
};

const extraColumns = (attribute: AttributeT) => {
  switch (attribute.entityType) {
    case 'medium_format': {
      return (
        <>
          <td>{attribute.year}</td>
          <td>{yesNo(attribute.has_discids)}</td>
        </>
      );
    }
    case 'series_type':
    case 'collection_type': {
      return <td>{attribute.item_entity_type}</td>;
    }
    case 'work_attribute_type': {
      return <td>{yesNo(attribute.free_text)}</td>;
    }
    default: return null;
  }
};

const Attribute = ({
  attributes,
  model,
}: Props): React$Element<typeof Layout> => (
  <Layout fullWidth title={model}>
    <h1>
      <a href="/admin/attributes">{'Attributes'}</a>
      {' / ' + model}
    </h1>
    <table className="tbl">
      <thead>
        <tr>
          <th>{'ID'}</th>
          <th>{'Name'}</th>
          <th>{'Description'}</th>
          <th>{'MBID'}</th>
          <th>{'Child order'}</th>
          <th>{'Parent ID'}</th>
          {extraHeaders(model)}
          <th>{'Actions'}</th>
        </tr>
      </thead>
      <tbody>
        {attributes ? attributes
          .sort((a, b) => compare(a.name, b.name))
          .map((attribute, index) => (
            <tr className={loopParity(index)} key={attribute.id}>
              <td>{attribute.id}</td>
              <td>{attribute.name}</td>
              <td>{exp.l_admin(attribute.description)}</td>
              <td>{attribute.gid}</td>
              <td>{attribute.child_order}</td>
              <td>{attribute.parent_id}</td>
              {extraColumns(attribute)}
              <td>
                <a href={`/admin/attributes/${model}/edit/${attribute.id}`}>
                  {'Edit'}
                </a>
                {' | '}
                <a href={`/admin/attributes/${model}/delete/${attribute.id}`}>
                  {'Remove'}
                </a>
              </td>
            </tr>
          )) : null}
      </tbody>
    </table>
    <p>
      <span className="buttons">
        <a href={`/admin/attributes/${model}/create`}>
          {'Add new attribute'}
        </a>
      </span>
    </p>
  </Layout>
);

export default Attribute;
