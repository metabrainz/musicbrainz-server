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
  type: {
    +gid: string,
  },
  +typeID: number,
  +typeName: string,
};

declare type LinkAttrTypeT = {
  ...OptionTreeT<'link_attribute_type'>,
  +children?: $ReadOnlyArray<LinkAttrTypeT>,
  +creditable: boolean,
  +free_text: boolean,
  +instrument_comment?: string,
  +root_gid: string,
  +root_id: number,
};

declare type LinkTypeAttrTypeT = {
  +max: number | null,
  +min: number | null,
};

declare type LinkTypeT = {
  ...OptionTreeT<'link_type'>,
  +attributes: {+[typeId: number]: LinkTypeAttrTypeT},
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
  +link_phrase: string,
  +long_link_phrase: string,
  +orderable_direction: number,
  +reverse_link_phrase: string,
  +root_id: number | null,
  +type0: string,
  +type1: string,
};

declare type PagedLinkTypeGroupT = {
  +direction: 'backward' | 'forward',
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

declare type RelationshipT = {
  ...DatePeriodRoleT,
  ...EditableRoleT,
  // `attributes` may not exist when seeding.
  +attributes?: $ReadOnlyArray<LinkAttrT>,
  +direction?: 'backward',
  +entity0?: CoreEntityT,
  +entity0_credit: string,
  +entity0_id: number,
  +entity1?: CoreEntityT,
  +entity1_credit: string,
  +entity1_id: number,
  +id: number,
  +linkOrder: number,
  +linkTypeID: number,
  +source_type: string,
  +target: CoreEntityT,
  +target_type: string,
};
