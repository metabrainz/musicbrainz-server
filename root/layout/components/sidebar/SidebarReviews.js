/*
 * @flow strict-local
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import CritiqueBrainzLinks from '../../../components/CritiqueBrainzLinks.js';

component SidebarReviews(entity: ReviewableT, heading?: string) {
  return (
    <>
      <h2 className="reviews">
        {nonEmpty(heading) ? heading : l('Reviews')}
      </h2>
      <p>
        <CritiqueBrainzLinks entity={entity} isSidebar />
      </p>
    </>
  );
}

export default SidebarReviews;
