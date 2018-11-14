/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import DBDefs from '../static/scripts/common/DBDefs';
import {l, ln} from '../static/scripts/common/i18n';

const seeReviewsHref = (releaseGroup) => (
  DBDefs.CRITIQUEBRAINZ_SERVER +
  '/release-group/' +
  releaseGroup.gid
);

const writeReviewLink = (releaseGroup) => (
  DBDefs.CRITIQUEBRAINZ_SERVER +
  '/review/write?release_group=' +
  releaseGroup.gid
);

type Props = {|
  +releaseGroup: ReleaseGroupT,
|};

const CritiqueBrainzLinks = ({releaseGroup}: Props) => {
  const reviewCount = releaseGroup.review_count;

  if (reviewCount == null) {
    return null;
  }
  if (reviewCount === 0) {
    return l('No one has reviewed this release group yet. Be the first to {write_link|write a review}.', {
      __react: true,
      write_link: writeReviewLink(releaseGroup),
    });
  }
  return ln(
    'There’s {reviews_link|{review_count} review} on CritiqueBrainz. You can also {write_link|write your own}.',
    'There are {reviews_link|{review_count} reviews} on CritiqueBrainz. You can also {write_link|write your own}.',
    reviewCount,
    {
      __react: true,
      review_count: reviewCount,
      reviews_link: seeReviewsHref(releaseGroup),
      write_link: writeReviewLink(releaseGroup),
    },
  );
};

export default CritiqueBrainzLinks;
