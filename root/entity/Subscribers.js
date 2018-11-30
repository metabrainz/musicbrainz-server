/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {l, ln} from '../static/scripts/common/i18n';
import EditorLink from '../static/scripts/common/components/EditorLink';
import chooseLayoutComponent from '../utility/chooseLayoutComponent';

type Props = {|
  +entity: CoreEntityT | CollectionT,
  +privateEditors: number,
  +publicEditors: $ReadOnlyArray<EditorT>,
  +subscribed: boolean,
|};

const Subscribers = ({
  entity,
  privateEditors,
  publicEditors,
  subscribed,
}: Props) => {
  const entityType = entity.entityType;
  const LayoutComponent = chooseLayoutComponent(entityType);

  return (
    <LayoutComponent entity={entity} page="subscribers" title={l('Subscribers')}>
      <h2>{l('Subscribers')}</h2>

      {(publicEditors.length || (privateEditors > 0)) ? (
        <>
          <p>
            {ln(
              'There is currently {num} user subscribed to {entity}:',
              'There are currently {num} users subscribed to {entity}:',
              publicEditors.length + privateEditors,
              {
                entity: entity.name,
                num: publicEditors.length + privateEditors,
              },
            )}
          </p>

          <ul>
            {publicEditors.map(editor => (
              <li key={editor.id}>
                <EditorLink editor={editor} />
              </li>
            ))}
            {publicEditors.length && (privateEditors > 0) ? (
              <li>
                {ln(
                  'Plus {n} other anonymous user',
                  'Plus {n} other anonymous users',
                  privateEditors,
                  {n: privateEditors},
                )}
              </li>
            ) : (
              privateEditors > 0 ? (
                <li>
                  {ln(
                    'An anonymous user',
                    '{n} anonymous users',
                    privateEditors,
                    {n: privateEditors},
                  )}
                </li>
              ) : null
            )}
          </ul>
        </>
      ) : (
        <p>
          {l('There are currently no users subscribed to {entity}.',
            {entity: entity.name})}
        </p>
      )}

      {subscribed ? (
        <p>
          {l('You are currently subscribed. {unsub|Unsubscribe}?',
            {unsub: '/account/subscriptions/' + entityType + '/remove?id=' + entity.id})}
        </p>
      ) : (
        (publicEditors.length + privateEditors === 0) ? (
          <p>
            {l('Be the first! {sub|Subscribe}?',
              {sub: '/account/subscriptions/' + entityType + '/add?id=' + entity.id})}
          </p>
        ) : (
          <p>
            {l('You are not currently subscribed. {sub|Subscribe}?',
              {sub: '/account/subscriptions/' + entityType + '/add?id=' + entity.id})}
          </p>
        )
      )}
    </LayoutComponent>
  );
};

export default Subscribers;
