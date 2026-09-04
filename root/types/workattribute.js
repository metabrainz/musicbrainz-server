/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

// MusicBrainz::Server::Entity::WorkAttribute::TO_JSON
declare type WorkAttributeT = {
  // Generally shouldn't be null, but the id isn't stored in edit data.
  readonly id: number | null,
  // N.B. TypeRoleT requires typeID to be nullable.
  readonly typeID: number,
  readonly typeName: string,
  readonly value: string,
  readonly value_id: number | null,
};

declare type WorkAttributeTypeAllowedValueT = {
  ...OptionTreeT<'work_attribute_type_allowed_value'>,
  readonly value: string,
  readonly workAttributeTypeID: number,
};

// See MusicBrainz::Server::Controller::Work::stash_work_form_json
declare type WorkAttributeTypeAllowedValueTreeT = {
  ...WorkAttributeTypeAllowedValueT,
  readonly children?: ReadonlyArray<WorkAttributeTypeAllowedValueTreeT>,
};

declare type WorkAttributeTypeAllowedValueTreeRootT =
  {readonly children: ReadonlyArray<WorkAttributeTypeAllowedValueTreeT>};

declare type WorkAttributeTypeT = {
  ...CommentRoleT,
  ...OptionTreeT<'work_attribute_type'>,
  readonly free_text: boolean,
};

// See MusicBrainz::Server::Controller::Work::stash_work_form_json
declare type WorkAttributeTypeTreeT = {
  ...WorkAttributeTypeT,
  readonly children?: ReadonlyArray<WorkAttributeTypeTreeT>,
};

declare type WorkAttributeTypeTreeRootT =
  {readonly children: ReadonlyArray<WorkAttributeTypeTreeT>};
