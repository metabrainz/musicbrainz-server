/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityTabLink from '../../../../components/EntityTabLink.js';
import loadCritiqueBrainzReviews
  from '../utility/loadCritiqueBrainzReviews.js';

type ReviewCountRequestCallbackT = (number | null) => void;

function loadReviewCount(
  entity: ReviewableT,
  callback: ReviewCountRequestCallbackT,
): void {
  loadCritiqueBrainzReviews(entity)
    .then((reqData) => {
      callback(reqData.reviewCount);
    })
    .catch(() => {
      callback(null);
    });
}

component ReviewsTab(
  entity: ReviewableT,
  page?: string,
) {
  const [reviewCount, setReviewCount] = React.useState<number | null>(null);

  const loadCallback: ReviewCountRequestCallbackT =
    React.useCallback((data) => {
      setReviewCount(data);
    }, [setReviewCount]);

  React.useEffect(() => {
    loadReviewCount(entity, loadCallback);
  }, [entity, loadCallback]);

  const title = reviewCount == null ? l('Reviews') : texp.l(
    'Reviews ({num})',
    {num: reviewCount || 0},
  );
  const subPath = 'ratings';

  return (
    <EntityTabLink
      content={title}
      entity={entity}
      key={subPath}
      selected={subPath === page}
      subPath={subPath}
    />
  );
}

export default (
  hydrate<React.PropsOf<ReviewsTab>>(
    'div.reviews-tab',
    ReviewsTab,
  ): React.AbstractComponent<React.PropsOf<ReviewsTab>>
);
