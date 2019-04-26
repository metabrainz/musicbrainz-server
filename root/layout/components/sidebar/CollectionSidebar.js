/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import RequestLogin from '../../../components/RequestLogin';
import {withCatalystContext} from '../../../context';
import EditorLink from '../../../static/scripts/common/components/EditorLink';
import EntityLink from '../../../static/scripts/common/components/EntityLink';

import {SidebarProperties, SidebarProperty} from './SidebarProperties';

type Props = {|
  +$c: CatalystContextT,
  +collection: CollectionT,
|};

const CollectionSidebar = ({$c, collection}: Props) => (
  <div id="sidebar">
    <h2 className="collection-information">
      {l('Collection information')}
    </h2>

    <SidebarProperties>
      <SidebarProperty className="" label={l('Owner:')}>
        <EditorLink editor={collection.editor} />
      </SidebarProperty>

      {collection.typeName ? (
        <SidebarProperty className="type" label={l('Type:')}>
          {lp_attributes(collection.typeName, 'collection_type')}
        </SidebarProperty>
      ) : null}
    </SidebarProperties>

    <h2 className="editing">{l('Editing')}</h2>

    <ul className="links">
      {$c.user_exists ? (
        <>
          <li>
            <EntityLink
              content={l('Open edits')}
              entity={collection}
              subPath="open_edits"
            />
          </li>
          <li>
            <EntityLink
              content={l('Editing history')}
              entity={collection}
              subPath="edits"
            />
          </li>
        </>
      ) : (
        <li>
          <RequestLogin $c={$c} text={l('Log in to edit')} />
        </li>
      )}
    </ul>

    {$c.user_exists ? (
      <>
        <h2 className="subscriptions">{l('Subscriptions')}</h2>
        <ul className="links">
          {$c.stash.subscribed ? (
            <li>
              <a href={'/account/subscriptions/collection/remove?id=' + String(collection.id)}>
                {l('Unsubscribe')}
              </a>
            </li>
          ) : (
            <li>
              <a href={'/account/subscriptions/collection/add?id=' + String(collection.id)}>
                {l('Subscribe')}
              </a>
            </li>
          )}
          <li>
            <EntityLink
              content={l('Subscribers')}
              entity={collection}
              subPath="subscribers"
            />
          </li>
        </ul>
      </>
    ) : null}
  </div>
);

export default withCatalystContext(CollectionSidebar);
