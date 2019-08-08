/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable import/no-commonjs */
/* eslint-disable multiline-comment-style */
/* eslint-disable sort-keys */
/* eslint-disable spaced-comment */

/*::
type LinkedEntities = {
  artist_type: {|
    +[number]: ArtistTypeT,
  |},
  language: {|
    +[number]: LanguageT,
  |},
  link_attribute_type: {|
    +[number]: LinkAttrTypeT,
  |},
  link_type: {|
    +[number]: LinkTypeT,
  |},
  link_type_tree: {|
    +[string]: $ReadOnlyArray<LinkTypeT>,
  |},
  release_group_primary_type: {|
    [number]: ReleaseGroupTypeT,
  |},
  release_group_secondary_type: {|
    [number]: ReleaseGroupSecondaryTypeT,
  |},
  release_packaging: {|
    +[number]: ReleasePackagingT,
  |},
  release_status: {|
    +[number]: ReleaseStatusT,
  |},
  script: {|
    +[number]: ScriptT,
  |},
  series: {|
    +[number]: SeriesT,
  |},
  series_ordering_type: {|
    +[number]: SeriesOrderingTypeT,
  |},
  series_type: {|
    +[number]: SeriesTypeT,
  |},
  work: {|
    +[number]: WorkT,
  |},
  work_attribute_type: {|
    +[number]: WorkAttributeTypeT,
  |},
};
*/

const EMPTY_OBJECT = Object.freeze({});

const linkedEntities/*: LinkedEntities */ = Object.create(Object.seal({
  artist_type:                    EMPTY_OBJECT,
  language:                       EMPTY_OBJECT,
  link_attribute_type:            EMPTY_OBJECT,
  link_type:                      EMPTY_OBJECT,
  link_type_tree:                 EMPTY_OBJECT,
  release_group_primary_type:     EMPTY_OBJECT,
  release_group_secondary_type:   EMPTY_OBJECT,
  release_packaging:              EMPTY_OBJECT,
  release_status:                 EMPTY_OBJECT,
  script:                         EMPTY_OBJECT,
  series:                         EMPTY_OBJECT,
  series_ordering_type:           EMPTY_OBJECT,
  series_type:                    EMPTY_OBJECT,
  work:                           EMPTY_OBJECT,
  work_attribute_type:            EMPTY_OBJECT,

  mergeLinkedEntities(update/*: ?LinkedEntities */) {
    if (update) {
      for (const [type, entities] of Object.entries(update)) {
        if (Object.prototype.hasOwnProperty.call(linkedEntities, type)) {
          Object.assign(linkedEntities[type], entities);
        } else {
          linkedEntities[type] = entities;
        }
      }
    }
  },

  setLinkedEntities(update/*: ?LinkedEntities */) {
    for (const key of Object.keys(linkedEntities)) {
      delete linkedEntities[key];
    }
    if (update) {
      Object.assign(linkedEntities, update);
    }
  },
}));

module.exports = linkedEntities;
