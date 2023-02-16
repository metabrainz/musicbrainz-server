/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko, {
  type ObservableArray as KnockoutObservableArray,
} from 'knockout';

export default function getRelatedArtists(
  relationships: ?(
    | $ReadOnlyArray<RelationshipT>
    | KnockoutObservableArray<RelationshipT>
  ),
): Array<ArtistT> {
  if (!relationships) {
    return [];
  }
  return ko.unwrap(relationships).reduce((accum, r) => {
    if (r.target.entityType === 'artist') {
      accum.push(r.target);
    }
    return accum;
  }, []);
}
