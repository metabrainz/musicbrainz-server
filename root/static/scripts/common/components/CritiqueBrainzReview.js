/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../../../../context.mjs';
import formatUserDate from '../../../../utility/formatUserDate';
import hydrate from '../../../../utility/hydrate';
import bracketed from '../utility/bracketed';
import {StaticRatingStars} from '../components/RatingStars';
import DBDefs from '../DBDefs-client.mjs';

import Collapsible from './Collapsible';

type Props = {
  +review: CritiqueBrainzReviewT,
  +title: string,
};

const authorHref = author => (
  DBDefs.CRITIQUEBRAINZ_SERVER + '/user/' + author.id
);

const reviewHref = review => (
  DBDefs.CRITIQUEBRAINZ_SERVER + '/review/' + review.id
);

const CritiqueBrainzReview = ({review, title}: Props) => (
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
          review_link: {href: reviewHref(review), key: 'review_link'},
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

export default (hydrate<Props>(
  'div.critiquebrainz-review',
  CritiqueBrainzReview,
): React.AbstractComponent<Props, void>);
