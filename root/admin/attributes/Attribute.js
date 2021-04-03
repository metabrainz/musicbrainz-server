/*
 * @flow strict-local
 * Copyright (C) 2019 Anirudh Jain
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../../layout';
import {compare} from '../../static/scripts/common/i18n';
import expand2react from '../../static/scripts/common/i18n/expand2react';
import yesNo from '../../static/scripts/common/utility/yesNo';
import loopParity from '../../utility/loopParity';

type AttributeT =
  | AreaTypeT
  | ArtistTypeT
  | CollectionTypeT
  | CoverArtTypeT
  | EventTypeT
  | GenderT
  | InstrumentTypeT
  | LabelTypeT
  | MediumFormatT
  | PlaceTypeT
  | ReleaseGroupSecondaryTypeT
  | ReleaseGroupTypeT
  | ReleasePackagingT
  | ReleaseStatusT
  | SeriesTypeT
  | WorkAttributeTypeT
  | WorkTypeT;

type Props = {
  +attributes: Array<AttributeT>,
  +model: string,
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

const renderAttributes = (attribute) => {
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
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={model}>
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
        {attributes ? attributes
          .sort((a, b) => compare(a.name, b.name))
          .map((attribute, index) => (
            <tr className={loopParity(index)} key={attribute.id}>
              <td>{attribute.id}</td>
              <td>{attribute.name}</td>
              <td>{expand2react(attribute.description)}</td>
              <td>{attribute.child_order}</td>
              <td>{attribute.parent_id}</td>
              {renderAttributes(attribute)}
              <td>
                <a href={`/admin/attributes/${model}/edit/${attribute.id}`}>
                  {l('Edit')}
                </a>
                {' | '}
                <a href={`/admin/attributes/${model}/delete/${attribute.id}`}>
                  {l('Remove')}
                </a>
              </td>
            </tr>
          )) : null}
      </tbody>
    </table>
    <p>
      <span className="buttons">
        <a href={`/admin/attributes/${model}/create`}>
          {l('Add new attribute')}
        </a>
      </span>
    </p>
  </Layout>
);

export default Attribute;
