/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// MusicBrainz::Server::Entity::Label::TO_JSON
declare type LabelT = $ReadOnly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'label'>,
  ...DatePeriodRoleT,
  ...IpiCodesRoleT,
  ...IsniCodesRoleT,
  ...RatableRoleT,
  ...TypeRoleT<LabelTypeT>,
  +area: AreaT | null,
  +label_code: number,
  +primaryAlias?: string | null,
}>;

declare type LabelTypeT = OptionTreeT<'label_type'>;
