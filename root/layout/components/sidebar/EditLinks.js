/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import RequestLogin from '../../../components/RequestLogin.js';
import {CatalystContext} from '../../../context.mjs';
import EntityLink
  from '../../../static/scripts/common/components/EntityLink.js';

type Props = {
  +children?: React$Node,
  +entity: EditableEntityT,
  +requiresPrivileges?: boolean,
};

const EditLinks = ({
  children,
  entity,
  requiresPrivileges = false,
}: Props): React$Element<React$FragmentType> => {
  const $c = React.useContext(CatalystContext);
  return (
    <>
      <h2 className="editing">{l('Editing')}</h2>
      <ul className="links">
        {$c.user ? children : requiresPrivileges ? null : (
          <>
            <li>
              <RequestLogin text={l('Log in to edit')} />
            </li>
            <li className="separator" role="separator" />
          </>
        )}
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
      </ul>
    </>
  );
};

export default EditLinks;
