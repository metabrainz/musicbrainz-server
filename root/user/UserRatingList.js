/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import UserAccountLayout, {type AccountLayoutUserT}
  from '../components/UserAccountLayout.js';
import {SanitizedCatalystContext} from '../context.mjs';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink.js';
import RatingStars, {StaticRatingStars}
  from '../static/scripts/common/components/RatingStars.js';

type Props = {
  +ratings: {
    +[entityType: RatableEntityTypeT]: $ReadOnlyArray<RatableT>,
  },
  +user: AccountLayoutUserT,
};

export const headingText: {+[entity: RatableEntityTypeT]: () => string} = {
  artist: N_l('Artist ratings'),
  event: N_l('Event ratings'),
  label: N_l('Label ratings'),
  place: N_l('Place ratings'),
  recording: N_l('Recording ratings'),
  release_group: N_l('Release group ratings'),
  work: N_l('Work ratings'),
};

const UserRatingList = ({
  ratings,
  user,
}: Props): React$Element<typeof UserAccountLayout> => {
  const $c = React.useContext(SanitizedCatalystContext);
  const hasRatings = Object.values(ratings).some(
    entityTypeRatings => entityTypeRatings.length > 0,
  );
  const viewingOwnProfile = Boolean($c.user && $c.user.id === user.id);

  return (
    <UserAccountLayout entity={user} page="ratings" title={l('Ratings')}>
      {hasRatings ? (
        Object.keys(ratings).sort().map((entityType) => {
          const typeRatings = ratings[entityType];

          return (
            typeRatings.length > 0 ? (
              <>
                <h2>{headingText[entityType]()}</h2>
                <ul>
                  {typeRatings.map((entity) => (
                    <li key={entity.gid}>
                      {viewingOwnProfile
                        ? <RatingStars entity={entity} />
                        : <StaticRatingStars rating={entity.rating} />}
                      {' - '}
                      <DescriptiveLink entity={entity} />
                    </li>
                  ))}
                  <li key="view-all">
                    <a
                      href={'/user/' + encodeURIComponent(user.name) +
                            '/ratings/' + encodeURIComponent(entityType)}
                    >
                      {l('View all ratings')}
                    </a>
                  </li>
                </ul>
              </>
            ) : null
          );
        })
      ) : (
        <>
          <h2>{l('Ratings')}</h2>
          <p>{exp.l('{user} has not rated anything.', {user: user.name})}</p>
        </>
      )}
    </UserAccountLayout>
  );
};

export default UserRatingList;
