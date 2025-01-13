/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {SanitizedCatalystContext} from '../../../../context.mjs';
import formatUserDate from '../../../../utility/formatUserDate.js';
import hydrate from '../../../../utility/hydrate.js';
import {CRITIQUEBRAINZ_SERVER} from '../DBDefs-client.mjs';
import bracketed from '../utility/bracketed.js';

import Collapsible from './Collapsible.js';
import {StaticRatingStars} from './RatingStars.js';

const authorHref = (author: CritiqueBrainzUserT) => (
  CRITIQUEBRAINZ_SERVER + '/user/' + author.id
);

const reviewHref = (review: CritiqueBrainzReviewT) => (
  CRITIQUEBRAINZ_SERVER + '/review/' + review.id
);

component CritiqueBrainzReview(review: CritiqueBrainzReviewT, title: string) {
  return (
    <>
      <h3>{title}</h3>
      <p className="review-metadata">
        <SanitizedCatalystContext.Consumer>
          {$c => exp.l('{review_link|Review} by {author} on {date}', {
            author: (
              <a href={authorHref(review.author)} key="author">
                {review.author.name}
              </a>
            ),
            date: formatUserDate($c, review.created, {dateOnly: true}),
            review_link: {href: reviewHref(review)},
          })}
        </SanitizedCatalystContext.Consumer>
        {review.rating == null ? null : (
          <>
            {' '}
            {bracketed(
              <StaticRatingStars rating={review.rating} />,
            )}
          </>
        )}
      </p>
      <Collapsible className="review" html={review.body} />
    </>
  );
}

export default (hydrate<React.PropsOf<CritiqueBrainzReview>>(
  'div.critiquebrainz-review',
  CritiqueBrainzReview,
): React.AbstractComponent<React.PropsOf<CritiqueBrainzReview>>);
