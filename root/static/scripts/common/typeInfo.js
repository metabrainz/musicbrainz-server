/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const linkTypeInfoByTypes: {+[string]: $ReadOnlyArray<LinkTypeInfoT>} = {};

const linkTypeInfoById: {+[number | string]: LinkTypeInfoT} = {};

const linkAttributeTypeInfoById: {+[number | string]: AttrInfoT} = {};

module.exports = {
  link_attribute_type: linkAttributeTypeInfoById,
  link_type: {
    byId: linkTypeInfoById,
    byTypes: linkTypeInfoByTypes,
  },
};
