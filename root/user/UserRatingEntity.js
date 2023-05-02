/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../components/PaginatedResults.js';
import UserAccountLayout, {type AccountLayoutUserT}
  from '../components/UserAccountLayout.js';
import {SanitizedCatalystContext} from '../context.mjs';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink.js';
import RatingStars, {StaticRatingStars}
  from '../static/scripts/common/components/RatingStars.js';

import {headingText} from './UserRatingList.js';

type UserTagEntityProps = {
  +entityType: RatableEntityTypeT,
  +pager: PagerT,
  +ratings: $ReadOnlyArray<RatableT>,
  +user: AccountLayoutUserT,
};

const UserRatingEntity = ({
  entityType,
  pager,
  ratings,
  user,
}: UserTagEntityProps): React$Element<typeof UserAccountLayout> => {
  const $c = React.useContext(SanitizedCatalystContext);
  const title = headingText[entityType]();
  const viewingOwnProfile = Boolean($c.user && $c.user.id === user.id);

  return (
    <UserAccountLayout entity={user} page="ratings" title={title}>
      <h2>{title}</h2>
      {ratings.length > 0 ? (
        <PaginatedResults pager={pager}>
          <ul>
            {ratings.map((entity) => (
              <li key={entity.gid}>
                {viewingOwnProfile
                  ? <RatingStars entity={entity} />
                  : <StaticRatingStars rating={entity.rating} />}
                {' - '}
                <DescriptiveLink entity={entity} />
              </li>
            ))}
          </ul>
        </PaginatedResults>
      ) : (
        <p>{l('No ratings.')}</p>
      )}
    </UserAccountLayout>
  );
};

export default UserRatingEntity;
