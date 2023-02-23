/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as tree from 'weight-balanced-tree';

import type {
  OptionItemT as AutocompleteOptionItemT,
  StateT as AutocompleteStateT,
} from '../common/components/Autocomplete2/types.js';
import type {LazyReleaseStateT} from '../release/types.js';

import type {RelationshipEditStatusT} from './constants.js';

export type CreditChangeOptionT =
  | ''
  | 'all'
  | 'same-entity-types'
  | 'same-relationship-type';

export type RelationshipStateForTypesT<
  +T0: CoreEntityT,
  +T1: CoreEntityT,
> = {
  /*
   * _lineage is purely to help debug how a piece of relationship
   * state was created.  It should be appended to whenever
   * `cloneRelationshipState` is used.
   */
  +_lineage: $ReadOnlyArray<string>,
  +_original: RelationshipStateT | null,
  +_status: RelationshipEditStatusT,
  +attributes: tree.ImmutableTree<LinkAttrT> | null,
  +begin_date: PartialDateT | null,
  +editsPending: boolean,
  +end_date: PartialDateT | null,
  +ended: boolean,
  +entity0: T0,
  +entity0_credit: string,
  +entity1: T1,
  +entity1_credit: string,
  +id: number,
  +linkOrder: number,
  +linkTypeID: number | null,
};

export type RelationshipStateT =
  RelationshipStateForTypesT<CoreEntityT, CoreEntityT>;

export type RelationshipPhraseGroupT = {
  +relationships: tree.ImmutableTree<RelationshipStateT> | null,
  +textPhrase: string,
};

export type RelationshipLinkTypeGroupT = {
  +backward: boolean,
  +phraseGroups: tree.ImmutableTree<RelationshipPhraseGroupT> | null,
  // Null types are represented by 0.
  +typeId: number,
};

export type RelationshipLinkTypeGroupKeyT = {
  +backward: boolean,
  +typeId: number,
};

export type RelationshipLinkTypeGroupsT =
  tree.ImmutableTree<RelationshipLinkTypeGroupT> | null;

export type RelationshipTargetTypeGroupT =
  [CoreEntityTypeT, RelationshipLinkTypeGroupsT];

export type RelationshipTargetTypeGroupsT =
  tree.ImmutableTree<RelationshipTargetTypeGroupT> | null;

export type RelationshipSourceGroupT =
  [CoreEntityT, RelationshipTargetTypeGroupsT];

export type RelationshipSourceGroupsT =
  tree.ImmutableTree<RelationshipSourceGroupT> | null;

export type NonReleaseCoreEntityT =
  | AreaT
  | ArtistT
  | EventT
  | GenreT
  | InstrumentT
  | LabelT
  | PlaceT
  | RecordingT
  | ReleaseGroupT
  | SeriesT
  | UrlT
  | WorkT;

export type NonReleaseCoreEntityTypeT =
  NonReleaseCoreEntityT['entityType'];

export type RelationshipDialogLocationT = {
  +backward?: ?boolean,
  +batchSelection?: ?boolean,
  +linkTypeId?: ?number,
  +relationshipId?: ?number,
  +source: CoreEntityT,
  +targetType?: ?CoreEntityTypeT,
  +textPhrase?: ?string,
  +track?: ?TrackWithRecordingT,
};

export type RelationshipEditorStateT = {
  /*
   * Instead of storing dialog openness as local component state, we store a
   * `dialogLocation` in the top-level state.  This makes it easier to
   * control relationship dialogs from userscripts, since we only have to
   * expose the top-level dispatch function from here -- rather than many
   * individual "setState" callbacks which can be hard to identify.
   *
   * `dialogLocation` is threaded downstream throughout the component tree,
   * but only where applicable; it should be passed as null where not
   * applicable in order to not defeat component memoization and not trigger
   * a cascade of unnecessary updates across the entire page.
   */
  +dialogLocation: RelationshipDialogLocationT | null,
  +entity: NonReleaseCoreEntityT,
  // existing = relationships that exist in the database
  +existingRelationshipsBySource: RelationshipSourceGroupsT,
  +reducerError: Error | null,
  +relationshipsBySource: RelationshipSourceGroupsT,
};

export type RelationshipDialogStateT = {
  +attributes: DialogAttributesStateT,
  +backward: boolean,
  +datePeriodField: DatePeriodFieldT,
  +isAttributesHelpVisible: boolean,
  +isRelationshipHelpVisible: boolean,
  +linkOrder: number,
  +linkType: DialogLinkTypeStateT,
  +resultingDatePeriod: DatePeriodRoleT,
  +sourceEntity: DialogSourceEntityStateT,
  +targetEntity: DialogTargetEntityStateT,
};

export type DialogBooleanAttributeStateT = $ReadOnly<{
  ...DialogLinkAttributeStateT,
  +control: 'checkbox',
  +enabled: boolean,
}>;

export type DialogMultiselectAttributeStateT = $ReadOnly<{
  ...DialogLinkAttributeStateT,
  +control: 'multiselect',
  +linkType: LinkTypeT,
  +values: $ReadOnlyArray<DialogMultiselectAttributeValueStateT>,
}>;

export type DialogMultiselectAttributeValueStateT = {
  +autocomplete: AutocompleteStateT<LinkAttrTypeT>,
  +control: 'multiselect-value',
  +creditedAs?: string,
  +error?: string,
  +key: number,
  +removed: boolean,
};

export type DialogTextAttributeStateT = $ReadOnly<{
  ...DialogLinkAttributeStateT,
  +control: 'text',
  +textValue: string,
}>;

export type DialogAttributeT =
  | DialogBooleanAttributeStateT
  | DialogMultiselectAttributeStateT
  | DialogTextAttributeStateT;

export type DialogAttributesT = $ReadOnlyArray<DialogAttributeT>;

export type DialogAttributesStateT = {
  +attributesList: DialogAttributesT,
  +resultingLinkAttributes: tree.ImmutableTree<LinkAttrT> | null,
};

export type DialogLinkAttributeStateT = {
  creditedAs?: string,
  error: string,
  key: number,
  max: number | null,
  min: number | null,
  textValue?: string,
  type: LinkAttrTypeT,
};

/*
 * Represents a LinkAttrT that may come from an external userscript.
 * The primary difference is that typeID/typeName are not required.
 */
export type ExternalLinkAttrT = {
  +credited_as?: string,
  +text_value?: string,
  +type: {+gid: string, ...},
};

export type DialogLinkTypeStateT = {
  +autocomplete: AutocompleteStateT<LinkTypeT>,
  +error: React$Node,
};

export type DialogSourceEntityStateT = $ReadOnly<{
  ...DialogEntityCreditStateT,
  +entityType: CoreEntityTypeT,
  +error: React$Node,
}>;

export type TargetTypeOptionT = {
  +text: string,
  +value: CoreEntityTypeT,
};

export type TargetTypeOptionsT = $ReadOnlyArray<TargetTypeOptionT>;

export type DialogTargetEntityStateT = $ReadOnly<{
  ...DialogEntityCreditStateT,
  +allowedTypes: TargetTypeOptionsT | null,
  +autocomplete: AutocompleteStateT<NonUrlCoreEntityT> | null,
  +error: string,
  +relationshipId: number,
  +target: CoreEntityT,
  +targetType: CoreEntityTypeT,
}>;

export type DialogEntityCreditStateT = {
  +creditedAs: string,
  +creditsToChange: CreditChangeOptionT,
  +releaseHasUnloadedTracks: boolean,
};

export type LinkAttributeShapeT = {
  +credited_as?: string,
  +text_value?: string,
  +type: LinkAttrTypeT | null,
  ...
};

export type LinkAttributesByRootIdT =
  Map<number, Array<LinkAttributeShapeT>>;

export type BatchCreateWorksDialogStateT = {
  +attributes: DialogAttributesStateT,
  +languages: MultiselectLanguageStateT,
  +linkType: DialogLinkTypeStateT,
  +workType: number | null,
};

export type EditWorkDialogStateT = {
  +languages: MultiselectLanguageStateT,
  +name: string,
  +workType: number | null,
};

export type MultiselectLanguageValueStateT = {
  +autocomplete: AutocompleteStateT<LanguageT>,
  +key: number,
  +removed: boolean,
};

export type MultiselectLanguageStateT = {
  +max: number | null,
  +staticItems: $ReadOnlyArray<AutocompleteOptionItemT<LanguageT>>,
  +values: $ReadOnlyArray<MultiselectLanguageValueStateT>,
};

/*
 * Release relationship editor types
 */

export type ReleaseWithMediumsAndReleaseGroupT = $ReadOnly<{
  ...ReleaseWithMediumsT,
  +releaseGroup: ReleaseGroupT,
}>;

// Associates a recording ID with all of the medium IDs it appears on.
export type RecordingMediumsT = Map<number, Array<MediumWithRecordingsT>>;

export type MediumWorkStateT = {
  +isSelected: boolean,
  +targetTypeGroups: RelationshipTargetTypeGroupsT,
  +work: WorkT,
};

export type MediumWorkStateTreeT =
  tree.ImmutableTree<MediumWorkStateT> | null;

export type MediumRecordingStateT = {
  +isSelected: boolean,
  +recording: RecordingT,
  +relatedWorks: MediumWorkStateTreeT,
  +targetTypeGroups: RelationshipTargetTypeGroupsT,
};

export type MediumRecordingStateTreeT =
  tree.ImmutableTree<MediumRecordingStateT> | null;

export type MediumStateTreeT = tree.ImmutableTree<[
  MediumWithRecordingsT,
  MediumRecordingStateTreeT,
]> | null;

export type ReleaseRelationshipEditorStateT = {
  ...$Exact<LazyReleaseStateT>,
  ...$Exact<RelationshipEditorStateT>,
  +editNoteField: ReadOnlyFieldT<string>,
  +enterEditForm: ReadOnlyFormT<{
    +make_votable: ReadOnlyFieldT<boolean>,
  }>,
  +entity: ReleaseWithMediumsAndReleaseGroupT,
  +mediums: MediumStateTreeT,
  +mediumsByRecordingId: RecordingMediumsT,
  +selectedRecordings: tree.ImmutableTree<RecordingT> | null,
  +selectedWorks: tree.ImmutableTree<WorkT> | null,
  +submissionError: ?string,
  +submissionInProgress: boolean,
};

export type RelationshipSourceGroupsContextT = {
  +existing: RelationshipSourceGroupsT,
  +pending: RelationshipSourceGroupsT,
};
