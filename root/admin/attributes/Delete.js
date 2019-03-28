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

type attributeT = {
  id: number,
  name: string,
};

type Props = {
  attribute: attributeT,
  model: string,
};

const Delete = ({attribute, model}: Props) => (
  <Layout fullWidth title={l('Remove Attribute')}>
    <div id="content">
      <h1>{l('Remove Attribute')}</h1>

      <p>
        {l('Are you sure you wish to remove the ')}
        <strong>{l(attribute.name)}</strong>
        {l(' attribute?')}
      </p>

      <form action={`/admin/attributes/${model}/delete/${attribute.id}`} method="post">
        <span className="buttons">
          <button name="confirm.submit" type="submit">{l('Remove')}</button>
        </span>
      </form>
    </div>
  </Layout>
);

export default Delete;
