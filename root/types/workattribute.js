/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// MusicBrainz::Server::Entity::WorkAttribute::TO_JSON
declare type WorkAttributeT = {
  // Generally shouldn't be null, but the id isn't stored in edit data.
  +id: number | null,
  // N.B. TypeRoleT requires typeID to be nullable.
  +typeID: number,
  +typeName: string,
  +value: string,
  +value_id: number | null,
};

declare type WorkAttributeTypeAllowedValueT = {
  ...OptionTreeT<'work_attribute_type_allowed_value'>,
  +value: string,
  +workAttributeTypeID: number,
};

// See MusicBrainz::Server::Controller::Work::stash_work_form_json
declare type WorkAttributeTypeAllowedValueTreeT = {
  ...WorkAttributeTypeAllowedValueT,
  +children?: $ReadOnlyArray<WorkAttributeTypeAllowedValueTreeT>,
};

declare type WorkAttributeTypeAllowedValueTreeRootT =
  {+children: $ReadOnlyArray<WorkAttributeTypeAllowedValueTreeT>};

declare type WorkAttributeTypeT = {
  ...CommentRoleT,
  ...OptionTreeT<'work_attribute_type'>,
  +free_text: boolean,
};

// See MusicBrainz::Server::Controller::Work::stash_work_form_json
declare type WorkAttributeTypeTreeT = {
  ...WorkAttributeTypeT,
  +children?: $ReadOnlyArray<WorkAttributeTypeTreeT>,
};

declare type WorkAttributeTypeTreeRootT =
  {+children: $ReadOnlyArray<WorkAttributeTypeTreeT>};
