/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../../../context';
import {l} from '../../../static/scripts/common/i18n';
import EntityLink from '../../../static/scripts/common/components/EntityLink';
import returnUri from '../../../utility/returnUri';

type Props = {|
  +$c: CatalystContextT,
  +children?: React.Node,
  +entity: CoreEntityT,
|};

const EditLinks = ({$c, children, entity}: Props) => (
  <>
    <h2 className="editing">{l('Editing')}</h2>
    <ul className="links">
      {$c.user_exists ? (
        <>
          {children}
          <li>
            <EntityLink
              content={l('Open edits')}
              entity={entity}
              subPath="open_edits"
            />
          </li>
          <li>
            <EntityLink
              content={l('Editing history')}
              entity={entity}
              subPath="edits"
            />
          </li>
        </>
      ) : (
        <li>
          <a href={returnUri($c, '/login')}>
            {l('Log in to edit')}
          </a>
        </li>
      )}
    </ul>
  </>
);

export default withCatalystContext(EditLinks);
