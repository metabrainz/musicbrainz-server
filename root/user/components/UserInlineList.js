/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/license/gpl-2.0.txt
 */

import * as React from 'react';

import {l} from '../../static/scripts/common/i18n';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import commaOnlyList from '../../static/scripts/common/i18n/commaOnlyList';

type Props = {|
  +editors: EditorT,
|};

const UserInlineList = ({editors}: Props) => {
  <p>
    {editors.size ? (
      {commaOnList(
        editors.map((editor) => (
          <EntityLink entity={editor} />
        )),
        {react: true},
      )}
      : l('No users found')
    }
  </p>
};