/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

declare type LinkAttrT = {
  readonly credited_as?: string,
  readonly text_value?: string,
  type: {readonly gid: string} | LinkAttrTypeT,
  readonly typeID: number,
  readonly typeName: string,
};

declare type LinkAttrTypeT = {
  ...OptionTreeT<'link_attribute_type'>,
  readonly children?: ReadonlyArray<LinkAttrTypeT>,
  readonly creditable: boolean,
  readonly free_text: boolean,
  readonly instrument_aliases?: ReadonlyArray<string>,
  readonly instrument_comment?: string,
  readonly instrument_type_id?: number,
  readonly instrument_type_name?: string,
  l_description?: string,
  l_name?: string,
  level?: number,
  readonly root_gid: string,
  readonly root_id: number,
};

declare type LinkTypeAttrTypeT = Readonly<{
  ...TypeRoleT<LinkAttrTypeT>,
  readonly max: number | null,
  readonly min: number | null,
}>;

declare type LinkTypeT = {
  ...OptionTreeT<'link_type'>,
  readonly attributes: {readonly [typeId: StrOrNum]: LinkTypeAttrTypeT},
  readonly cardinality0: number,
  readonly cardinality1: number,
  readonly children?: ReadonlyArray<LinkTypeT>,
  readonly deprecated: boolean,
  readonly documentation: string | null,
  readonly examples: ReadonlyArray<{
    readonly name: string,
    readonly relationship: RelationshipT,
  }> | null,
  readonly has_dates: boolean,
  readonly id: number,
  /*
   * The l_* properties are not sent by the server, but cached client-
   * side by the relationship editor.
   */
  l_description?: string,
  l_link_phrase?: string,
  l_name?: string,
  l_reverse_link_phrase?: string,
  readonly link_phrase: string,
  readonly long_link_phrase: string,
  readonly orderable_direction: OrderableDirectionT,
  readonly reverse_link_phrase: string,
  readonly root_id: number | null,
  readonly type0: RelatableEntityTypeT,
  readonly type1: RelatableEntityTypeT,
};

declare type OrderableDirectionT = 0 | 1 | 2;

declare type PagedLinkTypeGroupT = {
  readonly backward: boolean,
  readonly is_loaded: boolean,
  readonly limit: number,
  readonly link_type_id: number,
  readonly offset: number,
  readonly relationships: ReadonlyArray<RelationshipT>,
  readonly total_relationships: number,
};

declare type PagedTargetTypeGroupT = {
  readonly [linkTypeIdAndSourceColumn: string]: PagedLinkTypeGroupT,
};

declare type RelationshipT = Readonly<{
  ...DatePeriodRoleT,
  ...PendingEditsRoleT,
  readonly attributes: ReadonlyArray<LinkAttrT>,
  readonly backward: boolean,
  readonly entity0?: ?RelatableEntityT,
  readonly entity0_credit: string,
  readonly entity0_id: number,
  readonly entity1?: ?RelatableEntityT,
  readonly entity1_credit: string,
  readonly entity1_id: number,
  readonly id: number,
  readonly linkOrder: number,
  readonly linkTypeID: number,
  readonly source_id: number | null,
  readonly source_type: RelatableEntityTypeT,
  readonly target: RelatableEntityT,
  readonly target_type: RelatableEntityTypeT,
  readonly verbosePhrase: string,
}>;

declare type SeededRelationshipT = Readonly<{
  ...RelationshipT,
  readonly entity0_id: number | null,
  readonly entity1_id: number | null,
  readonly id: null,
  readonly linkTypeID: number | null,
}>;
