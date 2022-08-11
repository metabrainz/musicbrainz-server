/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EditorLink from '../static/scripts/common/components/EditorLink.js';
import isSpecialPurpose
  from '../static/scripts/common/utility/isSpecialPurpose.js';
import chooseLayoutComponent from '../utility/chooseLayoutComponent.js';
import {returnToCurrentPage} from '../utility/returnUri.js';

type Props = {
  +$c: CatalystContextT,
  +entity: CoreEntityT | CollectionT | EditorT,
  +isSpecialEntity: boolean,
  +privateEditors: number,
  +publicEditors: $ReadOnlyArray<EditorT>,
  +subscribed: boolean,
};

const Subscribers = ({
  $c,
  entity,
  privateEditors,
  publicEditors,
  subscribed,
}: Props): React.MixedElement => {
  const entityType = entity.entityType;
  const LayoutComponent = chooseLayoutComponent(entityType);
  const returnTo = '&' + returnToCurrentPage($c);
  const subLink =
    `/account/subscriptions/${entityType}/add?id=${entity.id}` +
    returnTo;
  const unsubLink =
    `/account/subscriptions/${entityType}/remove?id=${entity.id}` +
    returnTo;
  const viewingOwnProfile = Boolean($c.user &&
                            entityType === 'editor' &&
                            $c.user.id === entity.id);

  return (
    <LayoutComponent
      entity={entity}
      page="subscribers"
      title={l('Subscribers')}
    >
      <h2>{l('Subscribers')}</h2>

      {isSpecialPurpose(entity) ? (
        <p>
          {l(`This is a special purpose entity and
              does not support subscriptions.`)}
        </p>
      ) : (
        <>
          {(publicEditors.length || (privateEditors > 0)) ? (
            <>
              <p>
                {entityType === 'editor' ? (
                  viewingOwnProfile ? (
                    texp.ln(
                      `There is currently {num} user subscribed to edits
                        that you make:`,
                      `There are currently {num} users subscribed to edits
                        that you make:`,
                      publicEditors.length + privateEditors,
                      {
                        num: publicEditors.length + privateEditors,
                      },
                    )
                  ) : (
                    texp.ln(
                      `There is currently {num} user subscribed to edits
                        that {user} makes:`,
                      `There are currently {num} users subscribed to edits
                        that {user} makes:`,
                      publicEditors.length + privateEditors,
                      {
                        num: publicEditors.length + privateEditors,
                        user: entity.name,
                      },
                    )
                  )
                ) : (
                  texp.ln(
                    'There is currently {num} user subscribed to {entity}:',
                    'There are currently {num} users subscribed to {entity}:',
                    publicEditors.length + privateEditors,
                    {
                      entity: entity.name,
                      num: publicEditors.length + privateEditors,
                    },
                  )
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
                    {texp.ln(
                      'Plus {n} other anonymous user',
                      'Plus {n} other anonymous users',
                      privateEditors,
                      {n: privateEditors},
                    )}
                  </li>
                ) : (
                  privateEditors > 0 ? (
                    <li>
                      {texp.ln(
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
              {entityType === 'editor' ? (
                viewingOwnProfile ? (
                  l(`There are currently no users subscribed to edits
                     that you make.`)
                ) : (
                  texp.l(`There are currently no users subscribed to edits
                          that {user} makes.`,
                         {user: entity.name})
                )
              ) : (
                texp.l('There are currently no users subscribed to {entity}.',
                       {entity: entity.name})
              )}
            </p>
          )}

          {viewingOwnProfile ? null : (
            <p>
              {subscribed ? (
                exp.l('You are currently subscribed. {unsub|Unsubscribe}?',
                      {unsub: unsubLink})
              ) : (
                (publicEditors.length + privateEditors === 0) ? (
                  exp.l('Be the first! {sub|Subscribe}?',
                        {sub: subLink})
                ) : (
                  exp.l('You are not currently subscribed. {sub|Subscribe}?',
                        {sub: subLink})
                )
              )}
            </p>
          )}
        </>
      )}
    </LayoutComponent>
  );
};

export default Subscribers;
