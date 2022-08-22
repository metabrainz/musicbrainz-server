/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {editHref} from '../utility/entityHref.js';

type Props = {
  +content: string,
  +edit: GenericEditWithIdT,
  +subPath?: string,
};

const EditLink = ({
  edit,
  content,
  subPath,
}: Props): React.Element<'a'> => (
  <a href={editHref(edit, subPath)}>
    <bdi>
      {content}
    </bdi>
  </a>
);

export default EditLink;
