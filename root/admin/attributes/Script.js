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
import loopParity from '../../utility/loopParity.js';

const frequencyLabels = {
  [1]: 'Hidden',
  [2]: 'Other (uncommon)',
  [3]: 'Other',
  [4]: 'Frequently used',
};

type Props = {
  +attributes: Array<ScriptT>,
  +model: string,
};

const Script = ({
  model,
  attributes,
}: Props): React$Element<typeof Layout> => (
  <Layout fullWidth title={model || 'Script'}>
    <h1>
      <a href="/admin/attributes">{'Attributes'}</a>
      {' / Script'}
    </h1>

    <table className="tbl">
      <thead>
        <tr>
          <th>{'ID'}</th>
          <th>{'Name'}</th>
          <th>{'ISO code'}</th>
          <th>{'ISO number'}</th>
          <th>{'Frequency'}</th>
          <th>{'Actions'}</th>
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
            <td>{frequencyLabels[attr.frequency]}</td>
            <td>
              <a href={`/admin/attributes/${model}/edit/${attr.id}`}>
                {'Edit'}
              </a>
              {' | '}
              <a href={`/admin/attributes/${model}/delete/${attr.id}`}>
                {'Remove'}
              </a>
            </td>
          </tr>
        ))}
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

export default Script;
