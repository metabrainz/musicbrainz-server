/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../../context';
import EntityLink from '../../../static/scripts/common/components/EntityLink';
import {returnToCurrentPage} from '../../../utility/returnUri';

type Props = {
  +entity: CoreEntityT,
};

const SubscriptionLinks = ({
  entity,
}: Props): React.Element<typeof React.Fragment> => {
  const $c = React.useContext(CatalystContext);
  const entityType = entity.entityType;
  const id = encodeURIComponent(String(entity.id));
  const urlPrefix = `/account/subscriptions/${entityType}`;

  return (
    <>
      <h2 className="subscriptions">
        {l('Subscriptions')}
      </h2>
      <ul className="links">
        {$c.stash.subscribed /*:: === true */ ? (
          <li>
            <a
              href={
                `${urlPrefix}/remove?id=${id}&${returnToCurrentPage($c)}`
              }
            >
              {l('Unsubscribe')}
            </a>
          </li>
        ) : (
          <li>
            <a
              href={
                `${urlPrefix}/add?id=${id}&${returnToCurrentPage($c)}`
              }
            >
              {l('Subscribe')}
            </a>
          </li>
        )}
        <li>
          <EntityLink
            content={l('Subscribers')}
            entity={entity}
            subPath="subscribers"
          />
        </li>
      </ul>
    </>
  );
};

export default SubscriptionLinks;
