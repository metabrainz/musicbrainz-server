/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';

type Props = {|
  +action?: string,
  +question: React.Node,
  +title: string,
|};

const ConfirmLayout = ({action, question, title}: Props) => (
  <Layout fullWidth title={title}>
    <h1>{title}</h1>
    <p>{question}</p>
    <form action={action} method="post">
      <span className="buttons">
        <button
          name="confirm.submit"
          type="submit"
          value="1"
        >
          {l('Yes, I am sure')}
        </button>
        <button
          className="negative"
          name="confirm.cancel"
          type="submit"
          value="1"
        >
          {l('Cancel')}
        </button>
      </span>
    </form>
  </Layout>
);

export default ConfirmLayout;
