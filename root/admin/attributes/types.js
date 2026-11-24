/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type AttributeT =
  | AreaTypeT
  | ArtistTypeT
  | CollectionTypeT
  | CoverArtTypeT
  | EventTypeT
  | GenderT
  | InstrumentTypeT
  | LabelTypeT
  | MediumFormatT
  | PlaceTypeT
  | ReleaseGroupSecondaryTypeT
  | ReleaseGroupTypeT
  | ReleasePackagingT
  | ReleaseStatusT
  | SeriesTypeT
  | WorkAttributeTypeT
  | WorkTypeT;

export type CreateOrEditAttributePropsT =
  | Readonly<{
      readonly action: 'add' | 'edit',
      readonly form: AttributeEditGenericFormT,
      readonly parentSelectOptions: SelectOptionsT,
      readonly type:
        | 'AreaType'
        | 'ArtistType'
        | 'CoverArtType'
        | 'EventType'
        | 'Gender'
        | 'InstrumentType'
        | 'LabelType'
        | 'PlaceType'
        | 'ReleaseGroupType'
        | 'ReleaseGroupSecondaryType'
        | 'ReleaseStatus'
        | 'ReleasePackaging'
        | 'WorkType',
    }>
  | Readonly<{
      readonly action: 'add' | 'edit',
      readonly entityTypeSelectOptions: {
        [entityType: CollectableEntityTypeT]: CollectableEntityTypeT,
      },
      readonly form: AttributeEditFormWithEntityTypeT,
      readonly parentSelectOptions: SelectOptionsT,
      readonly type: 'CollectionType',
    }>
  | Readonly<{
      readonly action: 'add' | 'edit',
      readonly entityTypeSelectOptions: {
        [entityType: SeriesEntityTypeT]: SeriesEntityTypeT,
      },
      readonly form: AttributeEditFormWithEntityTypeT,
      readonly parentSelectOptions: SelectOptionsT,
      readonly type: 'SeriesType',
    }>
  | Readonly<{
      readonly action: 'add' | 'edit',
      readonly form: LanguageEditFormT,
      readonly type: 'Language',
    }>
  | Readonly<{
      readonly action: 'add' | 'edit',
      readonly form: MediumFormatEditFormT,
      readonly parentSelectOptions: SelectOptionsT,
      readonly type: 'MediumFormat',
    }>
  | Readonly<{
      readonly action: 'add' | 'edit',
      readonly form: ScriptEditFormT,
      readonly type: 'Script',
    }>
  | Readonly<{
      readonly action: 'add' | 'edit',
      readonly form: WorkAttributeTypeEditFormT,
      readonly parentSelectOptions: SelectOptionsT,
      readonly type: 'WorkAttributeType',
    }>;

export type AnyAttributeEditFormT =
  | AttributeEditFormWithEntityTypeT
  | AttributeEditGenericFormT
  | MediumFormatEditFormT
  | WorkAttributeTypeEditFormT;

export type AttributeEditGenericFormT = FormT<{
  ...AttributeEditFormCommonSectionT,
}>;

export type AttributeEditFormCommonSectionT = {
  readonly child_order: FieldT<string>,
  readonly description: FieldT<string>,
  readonly name: FieldT<string>,
  readonly parent_id: FieldT<string>,
};

export type AttributeEditFormWithEntityTypeT = FormT<{
  ...AttributeEditFormCommonSectionT,
  readonly action: 'add' | 'edit',
  readonly item_entity_type: FieldT<string>,
}>;

export type LanguageEditFormT = FormT<{
  readonly frequency: FieldT<string>,
  readonly iso_code_1: FieldT<string>,
  readonly iso_code_2b: FieldT<string>,
  readonly iso_code_2t: FieldT<string>,
  readonly iso_code_3: FieldT<string>,
  readonly name: FieldT<string>,
}>;

export type MediumFormatEditFormT = FormT<{
  ...AttributeEditFormCommonSectionT,
  readonly has_discids: FieldT<boolean>,
  readonly year: FieldT<string>,
}>;

export type ScriptEditFormT = FormT<{
  readonly frequency: FieldT<string>,
  readonly iso_code: FieldT<string>,
  readonly iso_number: FieldT<string>,
  readonly name: FieldT<string>,
}>;

export type WorkAttributeTypeEditFormT = FormT<{
  ...AttributeEditFormCommonSectionT,
  readonly free_text: FieldT<boolean>,
}>;
