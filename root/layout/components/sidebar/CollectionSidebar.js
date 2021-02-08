/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EditorLink from '../../../static/scripts/common/components/EditorLink';
import EntityLink from '../../../static/scripts/common/components/EntityLink';
import {returnToCurrentPage} from '../../../utility/returnUri';

import {SidebarProperties, SidebarProperty} from './SidebarProperties';

type Props = {
  +$c: CatalystContextT,
  +collection: CollectionT,
};

const CollectionSidebar = ({
  $c,
  collection,
}: Props): React.Element<'div'> => {
  const typeName = collection.typeName;

  return (
    <div id="sidebar">
      <h2 className="collection-information">
        {l('Collection information')}
      </h2>

      <SidebarProperties>
        <SidebarProperty className="" label={l('Owner:')}>
          <EditorLink editor={collection.editor} />
        </SidebarProperty>

        {nonEmpty(typeName) ? (
          <SidebarProperty className="type" label={l('Type:')}>
            {lp_attributes(typeName, 'collection_type')}
          </SidebarProperty>
        ) : null}
      </SidebarProperties>

      <h2 className="editing">{l('Editing')}</h2>

      <ul className="links">
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
      </ul>

      {$c.user ? (
        <>
          <h2 className="subscriptions">{l('Subscriptions')}</h2>
          <ul className="links">
            {$c.stash.subscribed /*:: === true */ ? (
              <li>
                <a
                  href={
                    '/account/subscriptions/collection/remove?id=' +
                    String(collection.id) +
                    '&' + returnToCurrentPage($c)
                  }
                >
                  {l('Unsubscribe')}
                </a>
              </li>
            ) : (
              <li>
                <a
                  href={
                    '/account/subscriptions/collection/add?id=' +
                    String(collection.id) +
                    '&' + returnToCurrentPage($c)
                  }
                >
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
};

export default CollectionSidebar;
