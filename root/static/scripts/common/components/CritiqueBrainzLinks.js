/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {minimalEntity} from '../../../../utility/hydrate.js';
import DBDefs from '../DBDefs-client.mjs';
import loadCritiqueBrainzReviews
  from '../utility/loadCritiqueBrainzReviews.js';

import EntityLink from './EntityLink.js';

type ReviewCountRequestCallbackT = (number | null) => void;

const seeReviewsHref = (entity: ReviewableT) => {
  const reviewUrlEntity = entity.entityType === 'release_group'
    ? 'release-group'
    : entity.entityType;
  return (
    DBDefs.CRITIQUEBRAINZ_SERVER +
    `/${reviewUrlEntity}/` +
    entity.gid
  );
};

const writeReviewLink = (entity: ReviewableT) => (
  DBDefs.CRITIQUEBRAINZ_SERVER +
  `/review/write?${entity.entityType}=` +
  entity.gid
);

function loadReviewCount(
  entity: ReviewableT,
  callback: ReviewCountRequestCallbackT,
): void {
  loadCritiqueBrainzReviews(entity)
    .then((reqData) => {
      callback(reqData.reviewCount);
    })
    .finally(() => {
      // Passing null to the callback does setLoading(false).
      callback(null);
    });
}

component CritiqueBrainzLinks(
  entity: ReviewableT,
  isSidebar: boolean = false,
  reviewCount as passedReviewCount: number | null = null,
) {
  const linkClassName = isSidebar ? 'wrap-anywhere' : '';

  const [reviewCount, setReviewCount] = React.useState(passedReviewCount);

  const [isLoading, setLoading] = React.useState(passedReviewCount == null);

  const loadCallback: ReviewCountRequestCallbackT =
    React.useCallback((data) => {
      if (data == null) {
        setLoading(false);
      } else {
        setReviewCount(data);
      }
    }, [setReviewCount, setLoading]);

  React.useEffect(() => {
    if (passedReviewCount == null) {
      loadReviewCount(entity, loadCallback);
    }
  }, [entity, loadCallback]);

  if (isLoading) {
    return (
      <p className="loading-message">
        {l('Loading...')}
      </p>
    );
  }
  if (reviewCount == null) {
    return l('An error occurred when loading reviews.');
  }
  if (reviewCount === 0) {
    return exp.l(
      `No one has reviewed {entity} yet.
        Be the first to {write_link|write a review}.`,
      {
        entity: (
          <EntityLink
            className={linkClassName}
            entity={entity}
          />
        ),
        write_link: writeReviewLink(entity),
      },
    );
  }
  return exp.ln(
    `There’s {reviews_link|{review_count} review} on CritiqueBrainz.
     You can also {write_link|write your own}.`,
    `There are {reviews_link|{review_count} reviews} on CritiqueBrainz.
     You can also {write_link|write your own}.`,
    reviewCount,
    {
      review_count: reviewCount,
      reviews_link: seeReviewsHref(entity),
      write_link: writeReviewLink(entity),
    },
  );
}

export default (hydrate<React.PropsOf<CritiqueBrainzLinks>>(
  'div.critiquebrainz-links',
  CritiqueBrainzLinks,
  minimalEntity,
): component(...React.PropsOf<CritiqueBrainzLinks>));
