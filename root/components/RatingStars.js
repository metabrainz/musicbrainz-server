/*
 * @flow strict-local
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../context.mjs';
import ratingTooltip from '../utility/ratingTooltip';
import {returnToCurrentPage} from '../utility/returnUri';

const ratingURL = (
  $c: SanitizedCatalystContextT,
  entity: RatableT,
  rating: number,
) => (
  '/rating/rate/?entity_type=' +
  encodeURIComponent(entity.entityType) +
  '&entity_id=' +
  encodeURIComponent(String(entity.id)) +
  '&rating=' +
  encodeURIComponent(String(rating * 20)) +
  '&' + returnToCurrentPage($c)
);

const ratingInts = [1, 2, 3, 4, 5];

type StaticRatingStarsProps = {
  +rating: ?number,
};

type RatingStarsProps = {
  +entity: RatableT,
};

export const StaticRatingStars = ({
  rating,
}: StaticRatingStarsProps): React.Element<'span'> => {
  const starRating = rating == null ? 0 : (5 * rating / 100);
  return (
    <span className="inline-rating">
      <span className="star-rating" tabIndex="-1">
        <span
          className="current-rating"
          style={{width: `${rating ?? 0}%`}}
        >
          {starRating}
        </span>
      </span>
    </span>
  );
};

const RatingStars = ({entity}: RatingStarsProps): React.Element<'span'> => {
  const currentStarRating =
    entity.user_rating == null ? 0 : (5 * entity.user_rating / 100);
  const $c = React.useContext(SanitizedCatalystContext);

  return (
    <span className="inline-rating">
      <span className="star-rating" tabIndex="-1">
        {entity.user_rating == null ? (
          entity.rating == null ? null : (
            <span
              className="current-rating"
              style={{width: `${entity.rating}%`}}
            >
              {5 * entity.rating / 100}
            </span>
          )
        ) : (
          <span
            className="current-user-rating"
            style={{width: `${entity.user_rating}%`}}
          >
            {currentStarRating}
          </span>
        )}

        {$c.user?.has_confirmed_email_address ? (
          ratingInts.map(rating => {
            const isCurrentRating = rating === currentStarRating;
            const newRating = isCurrentRating ? 0 : rating;

            return (
              <a
                className={`stars-${rating} ${isCurrentRating
                  ? 'remove-rating'
                  : 'set-rating'}`}
                href={ratingURL($c, entity, newRating)}
                key={rating}
                title={ratingTooltip(newRating)}
              >
                {rating}
              </a>
            );
          })
        ) : null}
      </span>
    </span>
  );
};

export default RatingStars;
