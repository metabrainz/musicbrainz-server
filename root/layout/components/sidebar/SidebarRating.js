/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import manifest from '../../../static/manifest.mjs';
import EntityLink
  from '../../../static/scripts/common/components/EntityLink.js';
import RatingStars
  from '../../../static/scripts/common/components/RatingStars.js';

component SidebarRating(entity: RatableT, heading?: string) {
  return (
    <>
      <h2 className="rating">{nonEmpty(heading) ? heading : l('Rating')}</h2>
      <p>
        <RatingStars entity={entity} />
        {entity.rating_count != null && entity.rating_count > 0 ? (
          <>
            {' ('}
            <EntityLink
              content={l('see all ratings')}
              entity={entity}
              subPath="ratings"
            />
            {')'}
          </>
        ) : null}
      </p>
      {manifest('common/ratings', {async: true})}
    </>
  );
}

export default SidebarRating;
