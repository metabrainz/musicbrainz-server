/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import EditorLink from '../static/scripts/common/components/EditorLink';
import chooseLayoutComponent from '../utility/chooseLayoutComponent';
import {withCatalystContext} from '../context';

type Props = {|
  +$c: CatalystContextT,
  +entity: CoreEntityT | CollectionT | EditorT,
  +privateEditors: number,
  +publicEditors: $ReadOnlyArray<EditorT>,
  +subscribed: boolean,
|};

const Subscribers = ({
  $c,
  entity,
  privateEditors,
  publicEditors,
  subscribed,
}: Props) => {
  const entityType = entity.entityType;
  const LayoutComponent = chooseLayoutComponent(entityType);
  const subLink = `/account/subscriptions/${entityType}/add?id=${entity.id}`;
  const unsubLink =
    `/account/subscriptions/${entityType}/remove?id=${entity.id}`;
  const viewingOwnProfile = $c.user &&
                            entityType === 'editor' &&
                            $c.user.id === entity.id;

  return (
    <LayoutComponent
      entity={entity}
      page="subscribers"
      title={l('Subscribers')}
    >
      <h2>{l('Subscribers')}</h2>

      {(publicEditors.length || (privateEditors > 0)) ? (
        <>
          {entityType === 'editor' ? (
            viewingOwnProfile ? (
              <p>
                {texp.ln(
                  `There is currently {num} user subscribed to edits
                   that you make:`,
                  `There are currently {num} users subscribed to edits
                   that you make:`,
                  publicEditors.length + privateEditors,
                  {
                    num: publicEditors.length + privateEditors,
                  },
                )}
              </p>
            ) : (
              <p>
                {texp.ln(
                  `There is currently {num} user subscribed to edits
                   that {user} makes:`,
                  `There are currently {num} users subscribed to edits
                   that {user} makes:`,
                  publicEditors.length + privateEditors,
                  {
                    num: publicEditors.length + privateEditors,
                    user: entity.name,
                  },
                )}
              </p>
            )
          ) : (
            <p>
              {texp.ln(
                'There is currently {num} user subscribed to {entity}:',
                'There are currently {num} users subscribed to {entity}:',
                publicEditors.length + privateEditors,
                {
                  entity: entity.name,
                  num: publicEditors.length + privateEditors,
                },
              )}
            </p>
          )}
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
        entityType === 'editor' ? (
          viewingOwnProfile ? (
            <p>
              {l(`There are currently no users subscribed to edits
                  that you make.`)}
            </p>
          ) : (
            <p>
              {texp.l(`There are currently no users subscribed to edits
                       that {user} makes.`,
                      {user: entity.name})}
            </p>
          )
        ) : (
          <p>
            {texp.l('There are currently no users subscribed to {entity}.',
                    {entity: entity.name})}
          </p>
        )
      )}

      {viewingOwnProfile ? null : (
        subscribed ? (
          <p>
            {exp.l('You are currently subscribed. {unsub|Unsubscribe}?',
                   {unsub: unsubLink})
            }
          </p>
        ) : (
          (publicEditors.length + privateEditors === 0) ? (
            <p>
              {exp.l('Be the first! {sub|Subscribe}?',
                     {sub: subLink})
              }
            </p>
          ) : (
            <p>
              {exp.l('You are not currently subscribed. {sub|Subscribe}?',
                     {sub: subLink})
              }
            </p>
          )
        )
      )
      }
    </LayoutComponent>
  );
};

export default withCatalystContext(Subscribers);
