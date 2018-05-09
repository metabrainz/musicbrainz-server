/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import Layout from '../layout';
import {l} from '../static/scripts/common/i18n';
import EditorLink from '../static/scripts/common/components/EditorLink';

const Nominate = ({candidate}: {+candidate: EditorT}) => (
  <Layout fullWidth title={l('Auto-editor elections')}>
    <h1>{l('Nominate a candidate for auto-editor')}</h1>
    <p>
      {l('Are you sure you want to nominate the editor {editor} for auto-editor status?', {
        __react: true,
        editor: <EditorLink editor={candidate} key='editor' />,
      })}
    </p>
    <form method="post">
      <span className="buttons">
        <button className="negative" name="confirm.cancel" type="submit" value="1">{l('Cancel')}</button>
        <button name="confirm.submit" type="submit" value="1">{l('Yes, I am sure')}</button>
      </span>
    </form>
  </Layout>
);

export default Nominate;
