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
  0: 'Hidden',
  1: 'Other',
  2: 'Frequently used',
};

type Props = {
  +attributes: Array<LanguageT>,
  +model: string,
};

const Language = ({
  model,
  attributes,
}: Props): React$Element<typeof Layout> => {
  return (
    <Layout fullWidth title={model || 'Language'}>
      <h1>
        <a href="/admin/attributes">{'Attributes'}</a>
        {' / Language'}
      </h1>
      <table className="tbl">
        <thead>
          <tr>
            <th>{'ID'}</th>
            <th>{'Name'}</th>
            <th>{'ISO 639-1'}</th>
            <th>{'ISO 639-2/B'}</th>
            <th>{'ISO 639-2/T'}</th>
            <th>{'ISO 639-3'}</th>
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
              <td>{attr.iso_code_1}</td>
              <td>{attr.iso_code_2b}</td>
              <td>{attr.iso_code_2t}</td>
              <td>{attr.iso_code_3}</td>
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
};

export default Language;
