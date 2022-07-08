/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import DBDefs from '../static/scripts/common/DBDefs-client.mjs';

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

type Props = {
  +releaseGroup: ReleaseGroupT,
};

const CritiqueBrainzLinks = ({
  releaseGroup,
}: Props): null | Expand2ReactOutput => {
  const reviewCount = releaseGroup.review_count;

  if (reviewCount == null) {
    return null;
  }
  if (reviewCount === 0) {
    return exp.l(
      `No one has reviewed this release group yet.
       Be the first to {write_link|write a review}.`,
      {write_link: writeReviewLink(releaseGroup)},
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
      reviews_link: seeReviewsHref(releaseGroup),
      write_link: writeReviewLink(releaseGroup),
    },
  );
};

export default CritiqueBrainzLinks;
