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
  | $ReadOnly<{
      +action: 'add' | 'edit',
      +form: AttributeEditGenericFormT,
      +parentSelectOptions: SelectOptionsT,
      +type:
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
  | $ReadOnly<{
      +action: 'add' | 'edit',
      +entityTypeSelectOptions: {
        [entityType: CollectableEntityTypeT]: CollectableEntityTypeT,
      },
      +form: AttributeEditFormWithEntityTypeT,
      +parentSelectOptions: SelectOptionsT,
      +type: 'CollectionType',
    }>
  | $ReadOnly<{
      +action: 'add' | 'edit',
      +entityTypeSelectOptions: {
        [entityType: SeriesEntityTypeT]: SeriesEntityTypeT,
      },
      +form: AttributeEditFormWithEntityTypeT,
      +parentSelectOptions: SelectOptionsT,
      +type: 'SeriesType',
    }>
  | $ReadOnly<{
      +action: 'add' | 'edit',
      +form: LanguageEditFormT,
      +type: 'Language',
    }>
  | $ReadOnly<{
      +action: 'add' | 'edit',
      +form: MediumFormatEditFormT,
      +parentSelectOptions: SelectOptionsT,
      +type: 'MediumFormat',
    }>
  | $ReadOnly<{
      +action: 'add' | 'edit',
      +form: ScriptEditFormT,
      +type: 'Script',
    }>
  | $ReadOnly<{
      +action: 'add' | 'edit',
      +form: WorkAttributeTypeEditFormT,
      +parentSelectOptions: SelectOptionsT,
      +type: 'WorkAttributeType',
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
  +child_order: FieldT<string>,
  +description: FieldT<string>,
  +name: FieldT<string>,
  +parent_id: FieldT<string>,
};

export type AttributeEditFormWithEntityTypeT = FormT<{
  ...AttributeEditFormCommonSectionT,
  +action: 'add' | 'edit',
  +item_entity_type: FieldT<string>,
}>;

export type LanguageEditFormT = FormT<{
  +frequency: FieldT<string>,
  +iso_code_1: FieldT<string>,
  +iso_code_2b: FieldT<string>,
  +iso_code_2t: FieldT<string>,
  +iso_code_3: FieldT<string>,
  +name: FieldT<string>,
}>;

export type MediumFormatEditFormT = FormT<{
  ...AttributeEditFormCommonSectionT,
  +has_discids: FieldT<boolean>,
  +year: FieldT<string>,
}>;

export type ScriptEditFormT = FormT<{
  +frequency: FieldT<string>,
  +iso_code: FieldT<string>,
  +iso_number: FieldT<string>,
  +name: FieldT<string>,
}>;

export type WorkAttributeTypeEditFormT = FormT<{
  ...AttributeEditFormCommonSectionT,
  +free_text: FieldT<boolean>,
}>;
