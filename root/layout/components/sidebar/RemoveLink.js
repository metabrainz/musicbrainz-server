/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../../context.mjs';
import entityHref from '../../../static/scripts/common/utility/entityHref.js';

type Props = {
  +entity:
    | AreaT
    | GenreT
    | InstrumentT
    | LabelT
    | RecordingT
    | ReleaseT,
};

const RemoveLink = ({entity}: Props): React.Element<'li'> | null => {
  const $c = React.useContext(CatalystContext);
  if (!$c.stash.can_delete /*:: === true */) {
    return null;
  }

  return (
    <li>
      <a href={entityHref(entity, 'delete')}>
        {l('Remove')}
      </a>
    </li>
  );
};

export default RemoveLink;
