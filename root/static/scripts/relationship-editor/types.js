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
  out T0 extends RelatableEntityT,
  out T1 extends RelatableEntityT,
> = {
  /*
   * _lineage is purely to help debug how a piece of relationship
   * state was created.  It should be appended to whenever
   * `cloneRelationshipState` is used.
   */
  readonly _lineage: ReadonlyArray<string>,
  readonly _original: RelationshipStateT | null,
  readonly _status: RelationshipEditStatusT,
  readonly attributes: tree.ImmutableTree<LinkAttrT> | null,
  readonly begin_date: PartialDateT | null,
  readonly editsPending: boolean,
  readonly end_date: PartialDateT | null,
  readonly ended: boolean,
  readonly entity0: T0,
  readonly entity0_credit: string,
  readonly entity1: T1,
  readonly entity1_credit: string,
  readonly id: number,
  readonly linkOrder: number,
  readonly linkTypeID: number | null,
};

export type RelationshipStateT =
  RelationshipStateForTypesT<RelatableEntityT, RelatableEntityT>;

export type RelationshipPhraseGroupT = {
  readonly relationships: tree.ImmutableTree<RelationshipStateT>,
  readonly textPhrase: string,
};

export type RelationshipLinkTypeGroupT = {
  readonly backward: boolean,
  readonly phraseGroups: tree.ImmutableTree<RelationshipPhraseGroupT>,
  // Null types are represented by 0.
  readonly typeId: number,
};

export type RelationshipLinkTypeGroupKeyT = {
  readonly backward: boolean,
  readonly typeId: number,
};

export type RelationshipLinkTypeGroupsT =
  tree.ImmutableTree<RelationshipLinkTypeGroupT>;

export type RelationshipTargetTypeGroupT =
  [RelatableEntityTypeT, RelationshipLinkTypeGroupsT];

export type RelationshipTargetTypeGroupsT =
  tree.ImmutableTree<RelationshipTargetTypeGroupT>;

export type RelationshipSourceGroupT =
  [RelatableEntityT, RelationshipTargetTypeGroupsT];

export type RelationshipSourceGroupsT =
  tree.ImmutableTree<RelationshipSourceGroupT>;

export type NonReleaseRelatableEntityT =
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

export type NonReleaseRelatableEntityTypeT =
  NonReleaseRelatableEntityT['entityType'];

export type RelationshipDialogLocationT = {
  readonly backward?: ?boolean,
  readonly batchSelection?: ?boolean,
  readonly linkTypeId?: ?number,
  readonly relationshipId?: ?number,
  readonly source: RelatableEntityT,
  readonly targetType?: ?RelatableEntityTypeT,
  readonly textPhrase?: ?string,
  readonly track?: ?TrackWithRecordingT,
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
  readonly dialogLocation: RelationshipDialogLocationT | null,
  readonly entity: NonReleaseRelatableEntityT,
  // existing = relationships that exist in the database
  readonly existingRelationshipsBySource: RelationshipSourceGroupsT,
  readonly reducerError: Error | null,
  readonly relationshipsBySource: RelationshipSourceGroupsT,
};

export type RelationshipDialogStateT = {
  readonly attributes: DialogAttributesStateT,
  readonly backward: boolean,
  readonly datePeriod: DialogDatePeriodStateT,
  readonly isHelpVisible: boolean,
  readonly linkOrder: number,
  readonly linkType: DialogLinkTypeStateT,
  readonly sourceEntity: DialogSourceEntityStateT,
  readonly targetEntity: DialogTargetEntityStateT,
};

export type DialogBooleanAttributeStateT = Readonly<{
  ...DialogLinkAttributeStateT,
  readonly control: 'checkbox',
  readonly enabled: boolean,
}>;

export type DialogMultiselectAttributeStateT = Readonly<{
  ...DialogLinkAttributeStateT,
  readonly control: 'multiselect',
  readonly linkType: LinkTypeT,
  readonly values: ReadonlyArray<DialogMultiselectAttributeValueStateT>,
}>;

export type DialogMultiselectAttributeValueStateT = {
  readonly autocomplete: AutocompleteStateT<LinkAttrTypeT>,
  readonly control: 'multiselect-value',
  readonly creditedAs?: string,
  readonly error?: string,
  readonly key: number,
  readonly removed: boolean,
};

export type DialogTextAttributeStateT = Readonly<{
  ...DialogLinkAttributeStateT,
  readonly control: 'text',
  readonly textValue: string,
}>;

export type DialogAttributeT =
  | DialogBooleanAttributeStateT
  | DialogMultiselectAttributeStateT
  | DialogTextAttributeStateT;

export type DialogAttributesT = ReadonlyArray<DialogAttributeT>;

export type DialogAttributesStateT = {
  readonly attributesList: DialogAttributesT,
  readonly resultingLinkAttributes: tree.ImmutableTree<LinkAttrT>,
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

export type DialogDatePeriodStateT = {
  readonly field: DatePeriodFieldT,
  readonly result: DatePeriodRoleT,
};

/*
 * Represents a LinkAttrT that may come from an external userscript.
 * The primary difference is that typeID/typeName are not required.
 */
export type ExternalLinkAttrT = {
  readonly credited_as?: string,
  readonly text_value?: string,
  readonly type: {readonly gid: string, ...},
};

export type DialogLinkTypeStateT = {
  readonly autocomplete: AutocompleteStateT<LinkTypeT>,
  readonly error: React.Node,
};

export type DialogSourceEntityStateT = Readonly<{
  ...DialogEntityCreditStateT,
  readonly entityType: RelatableEntityTypeT,
  readonly error: React.Node,
}>;

export type TargetTypeOptionT = {
  readonly text: string,
  readonly value: RelatableEntityTypeT,
};

export type TargetTypeOptionsT = ReadonlyArray<TargetTypeOptionT>;

export type DialogTargetEntityStateT = Readonly<{
  ...DialogEntityCreditStateT,
  readonly allowedTypes: TargetTypeOptionsT | null,
  readonly autocomplete: AutocompleteStateT<NonUrlRelatableEntityT> | null,
  readonly error: string,
  readonly relationshipId: number,
  readonly target: RelatableEntityT,
  readonly targetType: RelatableEntityTypeT,
}>;

export type DialogEntityCreditStateT = {
  readonly creditedAs: string,
  readonly creditsToChange: CreditChangeOptionT,
  readonly releaseHasUnloadedTracks: boolean,
};

export type LinkAttributeShapeT = {
  readonly credited_as?: string,
  readonly text_value?: string,
  readonly type: LinkAttrTypeT | null,
  ...
};

export type LinkAttributesByRootIdT =
  Map<number, Array<LinkAttributeShapeT>>;

export type BatchCreateWorksDialogStateT = {
  readonly attributes: DialogAttributesStateT,
  readonly datePeriod: DialogDatePeriodStateT,
  readonly languages: MultiselectLanguageStateT,
  readonly linkType: DialogLinkTypeStateT,
  readonly workType: number | null,
};

export type EditWorkDialogStateT = {
  readonly languages: MultiselectLanguageStateT,
  readonly name: string,
  readonly workType: number | null,
};

export type MultiselectLanguageValueStateT = {
  readonly autocomplete: AutocompleteStateT<LanguageT>,
  readonly key: number,
  readonly removed: boolean,
};

export type MultiselectLanguageStateT = {
  readonly max: number | null,
  readonly staticItems: ReadonlyArray<AutocompleteOptionItemT<LanguageT>>,
  readonly values: ReadonlyArray<MultiselectLanguageValueStateT>,
};

/*
 * Release relationship editor types
 */

export type ReleaseWithMediumsAndReleaseGroupT = Readonly<{
  ...ReleaseWithMediumsT,
  readonly releaseGroup: ReleaseGroupT,
}>;

// Associates a recording ID with all of the medium IDs it appears on.
export type RecordingMediumsT = Map<number, Array<MediumWithRecordingsT>>;

export type MediumWorkStateT = {
  readonly isSelected: boolean,
  readonly targetTypeGroups: RelationshipTargetTypeGroupsT,
  readonly work: WorkT,
};

export type MediumWorkStateTreeT =
  tree.ImmutableTree<MediumWorkStateT>;

export type MediumRecordingStateT = {
  readonly isSelected: boolean,
  readonly recording: RecordingT,
  readonly relatedWorks: MediumWorkStateTreeT,
  readonly targetTypeGroups: RelationshipTargetTypeGroupsT,
};

export type MediumRecordingStateTreeT =
  tree.ImmutableTree<MediumRecordingStateT>;

export type MediumStateTreeT = tree.ImmutableTree<[
  MediumWithRecordingsT,
  MediumRecordingStateTreeT,
]>;

export type ReleaseRelationshipEditorStateT = Readonly<{
  ...$Exact<LazyReleaseStateT>,
  ...$Exact<RelationshipEditorStateT>,
  readonly editNoteField: FieldT<string>,
  readonly enterEditForm: FormT<{
    readonly make_votable: FieldT<boolean>,
  }>,
  readonly entity: ReleaseWithMediumsAndReleaseGroupT,
  readonly mediums: MediumStateTreeT,
  readonly mediumsByRecordingId: RecordingMediumsT,
  readonly selectedRecordings: tree.ImmutableTree<RecordingT>,
  readonly selectedWorks: tree.ImmutableTree<WorkT>,
  readonly submissionError: ?string,
  readonly submissionInProgress: boolean,
}>;

export type RelationshipSourceGroupsContextT = {
  readonly existing: RelationshipSourceGroupsT,
  readonly pending: RelationshipSourceGroupsT,
};
