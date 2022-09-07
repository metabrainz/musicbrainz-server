/*
 * @flow
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {minimalEntity} from '../../../../utility/hydrate.js';
import loadCritiqueBrainzReviews, {type ReviewDataT}
  from '../utility/loadCritiqueBrainzReviews.js';

import CritiqueBrainzLinks from './CritiqueBrainzLinks.js';
import CritiqueBrainzReview from './CritiqueBrainzReview.js';

export type ReviewsRequestCallbackT = (ReviewDataT | null) => void;

function loadReviews(
  entity: ReviewableT,
  callback: ReviewsRequestCallbackT,
): void {
  loadCritiqueBrainzReviews(entity)
    .then((reqData) => {
      callback(reqData);
    })
    .finally(() => {
      // Passing null to the callback does setLoading(false).
      callback(null);
    });
}

component CritiqueBrainzReviewsSection(entity: ReviewableT) {
  const [reviews, setReviews] = React.useState<ReviewDataT>({
    mostPopularReview: null,
    mostRecentReview: null,
    reviewCount: null,
  });

  const [isLoading, setLoading] = React.useState(true);

  const loadCallback: ReviewsRequestCallbackT =
  React.useCallback((data) => {
    if (data == null) {
      setLoading(false);
    } else {
      setReviews(data);
    }
  }, [setReviews, setLoading]);

  React.useEffect(() => {
    loadReviews(entity, loadCallback);
  }, [entity, loadCallback]);

  return (
    <>
      <h2>{l('Reviews')}</h2>

      {isLoading ? (
        <p className="loading-message">
          {l('Loading...')}
        </p>
      ) : (
        <>
          <CritiqueBrainzLinks
            entity={entity}
            reviewCount={reviews.reviewCount}
          />
          <div id="critiquebrainz-reviews">
            {reviews.mostRecentReview ? (
              <CritiqueBrainzReview
                review={reviews.mostRecentReview}
                title={l('Most recent')}
              />
            ) : null}
            {reviews.mostPopularReview && reviews.mostRecentReview &&
              reviews.mostPopularReview.id !== reviews.mostRecentReview.id ? (
                <CritiqueBrainzReview
                  review={reviews.mostPopularReview}
                  title={l('Most popular')}
                />
              ) : null}
          </div>
        </>
      )}
    </>
  );
}

export default (hydrate<React.PropsOf<CritiqueBrainzReviewsSection>>(
  'div.critiquebrainz-reviews-section',
  CritiqueBrainzReviewsSection,
  minimalEntity,
): component(...React.PropsOf<CritiqueBrainzReviewsSection>));
