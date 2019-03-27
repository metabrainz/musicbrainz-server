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

type Props = {
  attributes: Array<ScriptT>,
  model: string,
};

const Script = ({model, attributes}: Props) => (
  <Layout fullWidth title={model ? model : l('Script')}>
    <h1>
      <a href="/admin/attributes">{l('Attributes')}</a>
      {'/' + l('Script')}
    </h1>

    <table className="tbl">
      <thead>
        <tr>
          <th>{l('ID')}</th>
          <th>{l('Name')}</th>
          <th>{l('ISO code')}</th>
          <th>{l('ISO number')}</th>
          <th>{l('Frequency')}</th>
          <th>{l('Actions')}</th>
        </tr>
      </thead>
      {attributes.sort((a, b) => (b.frequency - a.frequency) ||
        compare(a.name, b.name))
        .map((attr) => (
          <tr key={attr.id}>
            <td>{attr.id}</td>
            <td>{attr.name}</td>
            <td>{attr.iso_code}</td>
            <td>{attr.iso_number}</td>
            <td>{attr.frequency}</td>
            <td>
              <a href={`/admin/attributes/${model}/edit/${attr.id}`}>{l('Edit')}</a>
              {' | '}
              <a href={`/admin/attributes/${model}/delete/${attr.id}`}>{l('Remove')}</a>
            </td>
          </tr>
        ))}
    </table>

    <p>
      <span className="buttons">
        <a href={`/admin/attributes/${model}/create`}>{l('Add new attribute')}</a>
      </span>
    </p>
  </Layout>
);

export default Script;
