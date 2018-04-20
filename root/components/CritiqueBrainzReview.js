/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';
import type {ElementRef, Node as ReactNode} from 'react';

import {withCatalystContext} from '../context';
import DBDefs from '../static/scripts/common/DBDefs';
import {l} from '../static/scripts/common/i18n';
import formatUserDate from '../utility/formatUserDate';

import Frag from './Frag';

type Props = {|
  +$c: CatalystContextT,
  +review: CritiqueBrainzReviewT,
  +title: string,
|};

const authorHref = author => (
  DBDefs.CRITIQUEBRAINZ_SERVER + '/user/' + author.id
);

const reviewHref = review => (
  DBDefs.CRITIQUEBRAINZ_SERVER + '/review/' + review.id
);

const CritiqueBrainzReview = ({$c, review, title}: Props) => (
  <Frag>
    <h3>{title}</h3>
    <p className="review-metadata">
      {l('{review_link|Review} by {author} on {date}', {
        __react: true,
        author: (
          <a href={authorHref(review.author)} key="author">
            {review.author.name}
          </a>
        ),
        date: formatUserDate($c.user, review.created, {dateOnly: true}),
        review_link: {href: reviewHref(review), key: 'review_link'},
      })}
    </p>
    <div
      className="review-body review-collapse"
      dangerouslySetInnerHTML={{__html: review.body}}
    />
  </Frag>
);

export default withCatalystContext(CritiqueBrainzReview);
