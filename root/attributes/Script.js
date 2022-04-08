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
import Layout from '../layout/index.js';
import {compare} from '../static/scripts/common/i18n.js';
import {l_admin} from '../static/scripts/common/i18n/admin.js';
import {isRelationshipEditor}
  from '../static/scripts/common/utility/privileges.js';
import loopParity from '../utility/loopParity.js';

const frequencyLabels = {
  [1]: N_lp('Hidden', 'script frequency'),
  [2]: N_lp('Other (uncommon)', 'script frequency'),
  [3]: N_lp('Other', 'script frequency'),
  [4]: N_lp('Frequently used', 'script frequency'),
};

type Props = {
  +attributes: Array<ScriptT>,
  +model: string,
};

const Script = ({
  model,
  attributes,
}: Props): React$Element<typeof Layout> => {
  const $c = React.useContext(CatalystContext);
  const showEditSections = isRelationshipEditor($c.user);

  return (
    <Layout fullWidth title={model || l('Script')}>
      <h1>
        <a href="/attributes">{l('Attributes')}</a>
        {' / ' + l('Script')}
      </h1>

      <table className="tbl">
        <thead>
          <tr>
            <th>{l('ID')}</th>
            <th>{l('Name')}</th>
            <th>{l('ISO code')}</th>
            <th>{l('ISO number')}</th>
            <th>{l('Frequency')}</th>
            {showEditSections ? (
              <th>{l_admin('Actions')}</th>
            ) : null}
          </tr>
        </thead>
        {attributes
          .sort((a, b) => (
            (b.frequency - a.frequency) || compare(a.name, b.name)
          ))
          .map((attr, index) => (
            <tr className={loopParity(index)} key={attr.id}>
              <td>{attr.id}</td>
              <td>{attr.name}</td>
              <td>{attr.iso_code}</td>
              <td>{attr.iso_number}</td>
              <td>{frequencyLabels[attr.frequency]()}</td>
              {showEditSections ? (
                <td>
                  <a href={`/attributes/${model}/edit/${attr.id}`}>
                    {l_admin('Edit')}
                  </a>
                  {' | '}
                  <a href={`/attributes/${model}/delete/${attr.id}`}>
                    {l_admin('Remove')}
                  </a>
                </td>
              ) : null}
            </tr>
          ))}
      </table>

      {showEditSections ? (
        <p>
          <span className="buttons">
            <a href={`/attributes/${model}/create`}>
              {l_admin('Add new attribute')}
            </a>
          </span>
        </p>
      ) : null}
    </Layout>
  );
};

export default Script;
