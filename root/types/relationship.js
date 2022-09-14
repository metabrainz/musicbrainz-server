/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare type LinkAttrT = {
  +credited_as?: string,
  +text_value?: string,
  type: {+gid: string} | LinkAttrTypeT,
  +typeID: number,
  +typeName: string,
};

declare type LinkAttrTypeT = {
  ...OptionTreeT<'link_attribute_type'>,
  +children?: $ReadOnlyArray<LinkAttrTypeT>,
  +creditable: boolean,
  +free_text: boolean,
  +instrument_comment?: string,
  +instrument_type_id?: number,
  +instrument_type_name?: string,
  l_description?: string,
  l_name?: string,
  l_name_normalized?: string,
  level?: number,
  +root_gid: string,
  +root_id: number,
};

declare type LinkTypeAttrTypeT = {
  +max: number | null,
  +min: number | null,
};

declare type LinkTypeT = {
  ...OptionTreeT<'link_type'>,
  +attributes: {+[typeId: StrOrNum]: LinkTypeAttrTypeT},
  +cardinality0: number,
  +cardinality1: number,
  +children?: $ReadOnlyArray<LinkTypeT>,
  +deprecated: boolean,
  +documentation: string | null,
  +examples: $ReadOnlyArray<{
    +name: string,
    +relationship: RelationshipT,
  }>,
  +has_dates: boolean,
  +id: number,
  /*
   * The l_* properties are not sent by the server, but cached client-
   * side by the relationship editor.
   */
  l_description?: string,
  l_link_phrase?: string,
  l_name?: string,
  l_name_normalized?: string,
  l_reverse_link_phrase?: string,
  +link_phrase: string,
  +long_link_phrase: string,
  +orderable_direction: number,
  +reverse_link_phrase: string,
  +root_id: number | null,
  +type0: CoreEntityTypeT,
  +type1: CoreEntityTypeT,
};

declare type PagedLinkTypeGroupT = {
  +backward: boolean,
  +is_loaded: boolean,
  +limit: number,
  +link_type_id: number,
  +offset: number,
  +relationships: $ReadOnlyArray<RelationshipT>,
  +total_relationships: number,
};

declare type PagedTargetTypeGroupT = {
  +[linkTypeIdAndSourceColumn: string]: PagedLinkTypeGroupT,
};

declare type RelationshipT = $ReadOnly<{
  ...DatePeriodRoleT,
  ...EditableRoleT,
  +attributes: $ReadOnlyArray<LinkAttrT>,
  +backward: boolean,
  +entity0?: ?CoreEntityT,
  +entity0_credit: string,
  +entity0_id: number,
  +entity1?: ?CoreEntityT,
  +entity1_credit: string,
  +entity1_id: number,
  +id: number,
  +linkOrder: number,
  +linkTypeID: number,
  +source_id: number | null,
  +source_type: CoreEntityTypeT,
  +target: CoreEntityT,
  +target_type: CoreEntityTypeT,
  +verbosePhrase: string,
}>;
