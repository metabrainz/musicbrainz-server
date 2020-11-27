/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormSubmit from '../components/FormSubmit';
import PaginatedResults from '../components/PaginatedResults';
import UserAccountLayout, {
  type AccountLayoutUserT,
} from '../components/UserAccountLayout';
import EditorLink from '../static/scripts/common/components/EditorLink';
import EntityLink from '../static/scripts/common/components/EntityLink';
import loopParity from '../utility/loopParity';

const titleByEntityType = {
  artist: N_l('Artist Subscriptions'),
  collection: N_l('Collection Subscriptions'),
  editor: N_l('Editor Subscriptions'),
  label: N_l('Label Subscriptions'),
  series: N_l('Series Subscriptions'),
};

type UserSubscriptionsTableProps = {
  +entities: $ReadOnlyArray<
    ArtistT | CollectionT | EditorT | LabelT | SeriesT>,
  +viewingOwnProfile: boolean,
};

const UserSubscriptionsTable = ({
  entities,
  viewingOwnProfile,
}: UserSubscriptionsTableProps): React.Element<'table'> => (
  <table className="tbl">
    <thead>
      <tr>
        {viewingOwnProfile ? <th style={{width: '1em'}} /> : null}
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

type UserSubscriptionsProps = {
  +$c: CatalystContextT,
  +entities: $ReadOnlyArray<
    ArtistT | CollectionT | EditorT | LabelT | SeriesT>,
  +pager: PagerT,
  +privateCollectionCount?: number,
  +summary: {
    +artist: number,
    +collection: number,
    +editor: number,
    +label: number,
    +series: number,
  },
  +type: 'artist' | 'collection' | 'editor' | 'label' | 'series',
  +user: AccountLayoutUserT,
};

const UserSubscriptions = ({
  $c,
  entities,
  pager,
  privateCollectionCount,
  summary,
  type,
  user,
}: UserSubscriptionsProps): React.Element<typeof UserAccountLayout> => {
  const action = `/account/subscriptions/${type}/remove`;
  const showSummary = summary.artist > 0 || summary.collection > 0 ||
                      summary.editor > 0 || summary.label > 0 ||
                      summary.series > 0;
  const title = titleByEntityType[type]();
  const viewingOwnProfile = Boolean($c.user && $c.user.id === user.id);

  return (
    <UserAccountLayout
      $c={$c}
      entity={user}
      page="subscriptions"
      title={title}
    >
      <h2>{title}</h2>

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

      {entities.length > 0 ? (
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
      ) : <p>{l('No subscriptions.')}</p>}

      {privateCollectionCount == null ? null : (
        <p>
          {viewingOwnProfile ? (
            exp.ln(
              'You are subscribed to {n} private collection.',
              'You are subscribed to {n} private collections.',
              privateCollectionCount,
              {n: privateCollectionCount},
            )
          ) : (
            exp.ln(
              '{editor} is subscribed to {n} private collection.',
              '{editor} is subscribed to {n} private collections.',
              privateCollectionCount,
              {
                editor: <EditorLink editor={user} />,
                n: privateCollectionCount,
              },
            )
          )}
        </p>
      )}
    </UserAccountLayout>
  );
};

export default UserSubscriptions;
