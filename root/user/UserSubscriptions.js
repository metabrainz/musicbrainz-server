/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../components/PaginatedResults.js';
import UserAccountLayout, {
  type AccountLayoutUserT,
} from '../components/UserAccountLayout.js';
import {SanitizedCatalystContext} from '../context.mjs';
import EditorLink from '../static/scripts/common/components/EditorLink.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';
import loopParity from '../utility/loopParity.js';
import {returnToCurrentPage} from '../utility/returnUri.js';

const titleByEntityType = {
  artist: N_l('Artist Subscriptions'),
  collection: N_l('Collection Subscriptions'),
  editor: N_l('Editor Subscriptions'),
  label: N_l('Label Subscriptions'),
  series: N_l('Series Subscriptions'),
};

type UserSubscriptionsTableProps = {
  +entities: $ReadOnlyArray<SubscribableEntityT>,
  +viewingOwnProfile: boolean,
};

const UserSubscriptionsTable = ({
  entities,
  viewingOwnProfile,
}: UserSubscriptionsTableProps): React$Element<'table'> => (
  <table className="tbl">
    <thead>
      <tr>
        {viewingOwnProfile ? (
          <th className="checkbox-cell">
            <input type="checkbox" />
          </th>
        ) : null}
        <th>{l('Name')}</th>
      </tr>
    </thead>
    <tbody>
      {entities.map((entity, index) => (
        <tr className={loopParity(index)} key={entity.id}>
          {viewingOwnProfile ? (
            <td>
              <input name="id" type="checkbox" value={entity.id} />
            </td>
          ) : null}
          <td>
            {entity.entityType === 'editor'
              ? <EditorLink editor={entity} />
              : <EntityLink entity={entity} />}
          </td>
        </tr>
      ))}
    </tbody>
  </table>
);

type UserSubscriptionsSectionProps = {
  +action: string,
  +entities: $ReadOnlyArray<SubscribableEntityT>,
  +pager: PagerT,
  +viewingOwnProfile: boolean,
};

const UserSubscriptionsSection = ({
  action,
  entities,
  pager,
  viewingOwnProfile,
}: UserSubscriptionsSectionProps): React$Element<typeof PaginatedResults> => (
  viewingOwnProfile ? (
    <PaginatedResults pager={pager}>
      <form action={action} method="post">
        <UserSubscriptionsTable
          entities={entities}
          viewingOwnProfile={viewingOwnProfile}
        />
        <div className="row">
          <FormSubmit label={l('Unsubscribe')} />
        </div>
      </form>
    </PaginatedResults>
  ) : (
    <PaginatedResults pager={pager}>
      <UserSubscriptionsTable
        entities={entities}
        viewingOwnProfile={viewingOwnProfile}
      />
    </PaginatedResults>
  )
);

type UserSubscriptionsProps = {
  +entities: $ReadOnlyArray<SubscribableEntityT>,
  +hiddenPrivateCollectionCount?: number,
  +pager: PagerT,
  +summary: {
    +artist: number,
    +collection: number,
    +editor: number,
    +label: number,
    +series: number,
  },
  +type: SubscribableEntityTypeT,
  +user: AccountLayoutUserT,
  +visiblePrivateCollections?: $ReadOnlyArray<CollectionT>,
};

const UserSubscriptions = ({
  entities,
  hiddenPrivateCollectionCount,
  pager,
  summary,
  type,
  user,
  visiblePrivateCollections,
}: UserSubscriptionsProps): React$Element<typeof UserAccountLayout> => {
  const $c = React.useContext(SanitizedCatalystContext);
  const viewingOwnProfile = Boolean($c.user && $c.user.id === user.id);
  const isAdminViewingPrivate = Boolean(
    $c.user && !viewingOwnProfile && !user.preferences.public_subscriptions,
  );
  const action = `/account/subscriptions/${type}/remove?` +
    returnToCurrentPage($c);
  const showSummary = summary.artist > 0 || summary.collection > 0 ||
                      summary.editor > 0 || summary.label > 0 ||
                      summary.series > 0;
  const title = titleByEntityType[type]();
  const hasPrivateSubscriptions =
    visiblePrivateCollections?.length ||
    hiddenPrivateCollectionCount != null && hiddenPrivateCollectionCount > 0;

  return (
    <UserAccountLayout
      entity={user}
      page="subscriptions"
      title={title}
    >
      <h2>{title}</h2>

      {isAdminViewingPrivate ? null : (
        <>
          <p>
            {'[ '}
            <a href={`/user/${user.name}/subscriptions/artist`}>
              {titleByEntityType.artist()}
            </a>
            {' | '}
            <a href={`/user/${user.name}/subscriptions/collection`}>
              {titleByEntityType.collection()}
            </a>
            {' | '}
            <a href={`/user/${user.name}/subscriptions/label`}>
              {titleByEntityType.label()}
            </a>
            {' | '}
            <a href={`/user/${user.name}/subscriptions/series`}>
              {titleByEntityType.series()}
            </a>
            {' | '}
            <a href={`/user/${user.name}/subscriptions/editor`}>
              {titleByEntityType.editor()}
            </a>
            {' ]'}
          </p>

          {showSummary ? (
            <>
              <p>
                {exp.l(
                  '{editor} is subscribed to:',
                  {editor: <EditorLink editor={user} />},
                )}
              </p>
              <ul>
                {summary.artist > 0 ? (
                  <li>
                    {exp.ln(
                      '{num} artist',
                      '{num} artists',
                      summary.artist,
                      {num: summary.artist},
                    )}
                  </li>
                ) : null}

                {summary.collection > 0 ? (
                  <li>
                    {exp.ln(
                      '{num} collection',
                      '{num} collections',
                      summary.collection,
                      {num: summary.collection},
                    )}
                  </li>
                ) : null}

                {summary.editor > 0 ? (
                  <li>
                    {exp.ln(
                      '{num} editor',
                      '{num} editors',
                      summary.editor,
                      {num: summary.editor},
                    )}
                  </li>
                ) : null}

                {summary.label > 0 ? (
                  <li>
                    {exp.ln(
                      '{num} label',
                      '{num} labels',
                      summary.label,
                      {num: summary.label},
                    )}
                  </li>
                ) : null}

                {summary.series > 0 ? (
                  <li>
                    {exp.ln(
                      '{num} series',
                      '{num} series',
                      summary.series,
                      {num: summary.series},
                    )}
                  </li>
                ) : null}
              </ul>
            </>
          ) : null}
        </>
      )}

      {entities.length ? (
        <UserSubscriptionsSection
          action={action}
          entities={entities}
          pager={pager}
          viewingOwnProfile={viewingOwnProfile}
        />
      ) : hasPrivateSubscriptions
        ? <p>{l('No public subscriptions.')}</p>
        : <p>{l('No subscriptions.')}</p>}

      {visiblePrivateCollections?.length ? (
        <>
          <h3>{l('Private collections')}</h3>
          <UserSubscriptionsSection
            action={action}
            entities={visiblePrivateCollections}
            pager={pager}
            viewingOwnProfile={viewingOwnProfile}
          />
        </>
      ) : null}

      {hiddenPrivateCollectionCount == null ? null : (
        <p>
          {visiblePrivateCollections?.length ? (
            exp.ln(
              '{editor} is also subscribed to {n} other private collection.',
              '{editor} is also subscribed to {n} other private collections.',
              hiddenPrivateCollectionCount,
              {
                editor: <EditorLink editor={user} />,
                n: hiddenPrivateCollectionCount,
              },
            )
          ) : (
            exp.ln(
              '{editor} is subscribed to {n} private collection.',
              '{editor} is subscribed to {n} private collections.',
              hiddenPrivateCollectionCount,
              {
                editor: <EditorLink editor={user} />,
                n: hiddenPrivateCollectionCount,
              },
            )
          )}
        </p>
      )}
    </UserAccountLayout>
  );
};

export default UserSubscriptions;
