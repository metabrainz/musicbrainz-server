/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 * Copyright (C) 2018 Theodore Fabian Rudy
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/license/gpl-2.0.txt
 */

import * as React from 'react';

import {l} from '../../static/scripts/common/i18n';
import EditorLink from '../../static/scripts/common/components/EditorLink';
import commaOnlyList from '../../static/scripts/common/i18n/commaOnlyList';

type Props = {|
  +editors: $ReadOnlyArray<EditorT>,
|};

const UserInlineList = ({editors}: Props) => (
  <p>
    {editors.length ? (
      commaOnlyList(
        editors.map((editor) => (
          <EditorLink editor={editor} key={editor.id} />
        )),
        {react: true},
      )
    )
      : l('No users found')
    }
  </p>
);

export default UserInlineList;
