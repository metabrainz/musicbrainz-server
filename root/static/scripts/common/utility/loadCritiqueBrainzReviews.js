/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import entityHref from './entityHref.js';

export type ReviewDataT = {
  mostPopularReview: CritiqueBrainzReviewT | null,
  mostRecentReview: CritiqueBrainzReviewT | null,
  reviewCount: number | null,
};

let _reviewsCache: Promise<ReviewDataT>;

function loadCritiqueBrainzReviews(
  entity: ReviewableT,
): Promise<ReviewDataT> {
  const url = entityHref(entity, '/critiquebrainz-reviews');

  const reviews = _reviewsCache ||= fetch(url)
    .then(resp => resp.json());

  return reviews;
}

export default loadCritiqueBrainzReviews;
