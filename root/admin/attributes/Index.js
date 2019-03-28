/*
 * @flow
 * eslint-disable flowtype/no-mutable-array
 * Copyright (C) 2019 Anirudh Jain
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import Layout from '../../layout';
import {compare} from '../../static/scripts/common/i18n';

type attributeT = {
  childOrder: number,
  description: string,
  entityType: string,
  freeText: boolean,
  has_discids: boolean,
  id: number,
  name: string,
  parentID: number,
  year: number,
};

type Props = {
  attributes: Array<attributeT> | null,
  model: string,
  models: Array<string> | null,
};

const renderAttributesHeaderAccordingToModel = (model) => {
  switch (model) {
    case 'MediumFormat': {
      return (
        <>
          <th>{l('Year')}</th>
          <th>{l('Disc IDs allowed')}</th>
        </>
      );
    }
    case 'SeriesType':
    case 'CollectionType': {
      return <th>{l('Entity type')}</th>;
    }
    case 'WorkAttributeType': {
      return <th>{l('Free text')}</th>;
    }
    default: return null;
  }
};

const renderAttributesAccordingToModel = (model, attribute) => {
  switch (model) {
    case 'MediumFormat': {
      return (
        <>
          <td>{attribute.year}</td>
          <td>{attribute.has_discids ? 'Yes' : 'No'}</td>
        </>
      );
    }
    case 'SeriesType':
    case 'CollectionType': {
      return <td>{attribute.entityType}</td>;
    }
    case 'WorkAttributeType': {
      return <td>{attribute.freeText ? 'Yes' : 'No'}</td>;
    }
    default: return null;
  }
};

const Attributes = ({models, attributes, model}: Props) => (
  <Layout fullWidth title={model ? model : l('Attributes')}>
    {models ? (
      <div>
        <h1>{l('Attributes')}</h1>
        <ul>
          {models ? models.sort().map((item) => (<li key={item}><a href={'/admin/attributes/' + item}>{item}</a></li>)) : null}
        </ul>
      </div>
    ) : (
      <div>
        <h1>
          <a href="/admin/attributes">{l('Attributes')}</a>
          {' / ' + model}
        </h1>
        <table className="tbl">
          <thead>
            <tr>
              <th>{l('ID')}</th>
              <th>{l('Name')}</th>
              <th>{l('Description')}</th>
              <th>{l('Child order')}</th>
              <th>{l('Parent ID')}</th>
              {renderAttributesHeaderAccordingToModel(model)}
              <th>{l('Actions')}</th>
            </tr>
          </thead>
          <tbody>
            {attributes ? attributes.sort((a, b) => compare(a.name, b.name))
              .map((attribute) => (
                <tr key={attribute.id}>
                  <td>{attribute.id}</td>
                  <td>{attribute.name}</td>
                  <td>{attribute.description}</td>
                  <td>{attribute.childOrder}</td>
                  <td>{attribute.parentID}</td>
                  {renderAttributesAccordingToModel(model, attribute)}
                  <td>
                    <a href={`/admin/attributes/${model}/edit/${attribute.id}`}>{l('Edit')}</a>
                    {' | '}
                    <a href={`/admin/attributes/${model}/delete/${attribute.id}`}>{l('Remove')}</a>
                  </td>
                </tr>
              )) : null}
          </tbody>
        </table>
        <p><span className="buttons"><a href={`/admin/attributes/${model}/create`}>{l('Add new attribute')}</a></span></p>
      </div>
    )}
  </Layout>
);

export default Attributes;
