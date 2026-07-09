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
  ActionT as AutocompleteActionT,
} from '../../common/components/Autocomplete2/types.js';
import type {
  ActionT as DateRangeFieldsetActionT,
} from '../../edit/components/DateRangeFieldset.js';
import type {
  MultiselectActionT,
} from '../../edit/components/Multiselect.js';
import type {
  WorkTypeSelectActionT,
} from '../../release/components/WorkTypeSelect.js';
import type {LazyReleaseActionT} from '../../release/types.js';
import type {
  CreditChangeOptionT,
  ExternalLinkAttrT,
  MediumRecordingStateTreeT,
  MediumWorkStateT,
  RelationshipDialogLocationT,
  RelationshipPhraseGroupT,
  RelationshipStateT,
} from '../types.js';

export type DialogEntityCreditActionT =
 | {
     readonly creditedAs: string,
     readonly type: 'set-credit',
    }
 | {
     readonly type: 'set-credits-to-change',
     readonly value: CreditChangeOptionT,
   };

export type DialogLinkOrderActionT = {
  readonly newLinkOrder: number,
  readonly type: 'update-link-order',
};

export type DialogActionT =
  | {
      readonly type: 'change-direction',
    }
  | {
      readonly attributes: ReadonlyArray<ExternalLinkAttrT>,
      readonly type: 'set-attributes',
    }
  | {readonly type: 'toggle-help'}
  | {
      readonly action: DialogEntityCreditActionT,
      readonly type: 'update-source-entity',
    }
  | {
      readonly action: DialogTargetEntityActionT,
      readonly source: RelatableEntityT,
      readonly type: 'update-target-entity',
    }
  | {
      readonly source: RelatableEntityT,
      readonly targetType: RelatableEntityTypeT,
      readonly type: 'update-target-type',
    }
  | DialogLinkOrderActionT
  | {
      readonly action: DialogLinkTypeActionT,
      readonly source: RelatableEntityT,
      readonly type: 'update-link-type',
    }
  | {
      readonly action: DialogAttributeActionT,
      readonly type: 'update-attribute',
    }
  | {
      readonly action: DateRangeFieldsetActionT,
      readonly type: 'update-date-period',
    };

export type DialogAttributeActionT =
  | {
      readonly action: DialogBooleanAttributeActionT,
      readonly rootKey: number,
      readonly type: 'update-boolean-attribute',
    }
  | {
      readonly action: DialogMultiselectAttributeActionT,
      readonly rootKey: number,
      readonly type: 'update-multiselect-attribute',
    }
  | {
      readonly action: DialogTextAttributeActionT,
      readonly rootKey: number,
      readonly type: 'update-text-attribute',
    };

export type DialogBooleanAttributeActionT =
  | {
      readonly enabled: boolean,
      readonly type: 'toggle',
    };

export type DialogLinkTypeActionT =
  | {
      readonly action: AutocompleteActionT<LinkTypeT>,
      readonly source: RelatableEntityT,
      readonly type: 'update-autocomplete',
    };

export type DialogMultiselectAttributeActionT =
  | MultiselectActionT<LinkAttrTypeT>
  | {
      readonly creditedAs: string,
      readonly type: 'set-value-credit',
      readonly valueKey: number,
    };

export type DialogTextAttributeActionT =
  | {
      readonly textValue: string,
      readonly type: 'set-text-value',
    };

export type UpdateRelationshipActionT =
  | {
      readonly batchSelectionCount: number | void,
      readonly creditsToChangeForSource: CreditChangeOptionT,
      readonly creditsToChangeForTarget: CreditChangeOptionT,
      readonly newRelationshipState: RelationshipStateT,
      readonly oldRelationshipState: RelationshipStateT | null,
      readonly sourceEntity: RelatableEntityT,
      readonly type: 'update-relationship-state',
  };

export type RelationshipEditorActionT =
  | {
      readonly relationship: RelationshipStateT,
      readonly type: 'remove-relationship',
    }
  | {
      readonly relationship: RelationshipStateT,
      readonly source: RelatableEntityT,
      readonly type: 'move-relationship-down',
    }
  | {
      readonly relationship: RelationshipStateT,
      readonly source: RelatableEntityT,
      readonly type: 'move-relationship-up',
    }
  | {
      readonly hasOrdering: boolean,
      readonly linkPhraseGroup: RelationshipPhraseGroupT,
      readonly source: RelatableEntityT,
      readonly type: 'toggle-ordering',
    }
  | {
      readonly location: RelationshipDialogLocationT | null,
      readonly type: 'update-dialog-location',
    }
  | {
      readonly changes: {readonly [property: string]: unknown},
      readonly entityType: RelatableEntityTypeT,
      readonly type: 'update-entity',
    }
  | UpdateRelationshipActionT;

export type UpdateTargetEntityAutocompleteActionT = {
  readonly action: AutocompleteActionT<NonUrlRelatableEntityT>,
  readonly linkType: ?LinkTypeT,
  readonly source: RelatableEntityT,
  readonly type: 'update-autocomplete',
};

export type DialogTargetEntityActionT =
  | UpdateTargetEntityAutocompleteActionT
  | {
      readonly action: DialogEntityCreditActionT,
      readonly type: 'update-credit',
    }
  | {
      readonly text: string,
      readonly type: 'update-url-text',
    };

/* Release relationship-editor actions */

export type BatchCreateWorksDialogActionT =
  | {
      action: DialogAttributeActionT,
      type: 'update-attribute',
    }
  | {
      readonly action: DateRangeFieldsetActionT,
      readonly type: 'update-date-period',
    }
  | {
      action: MultiselectActionT<LanguageT>,
      type: 'update-languages',
    }
  | {
      action: DialogLinkTypeActionT,
      source: RelatableEntityT,
      type: 'update-link-type',
    }
  | WorkTypeSelectActionT;

export type AcceptBatchCreateWorksDialogActionT = {
  readonly attributes: tree.ImmutableTree<LinkAttrT>,
  readonly begin_date: PartialDateT | null,
  readonly end_date: PartialDateT | null,
  readonly ended: boolean,
  readonly languages: ReadonlyArray<LanguageT>,
  readonly linkType: LinkTypeT,
  readonly type: 'accept-batch-create-works-dialog',
  readonly workType: number | null,
};

export type ReleaseRelationshipEditorActionT =
  | LazyReleaseActionT
  | RelationshipEditorActionT
  | AcceptBatchCreateWorksDialogActionT
  | {
      readonly languages: ReadonlyArray<LanguageT>,
      readonly name: string,
      readonly type: 'accept-edit-work-dialog',
      readonly work: WorkT,
      readonly workType: number | null,
    }
  | {
      readonly relationships: ReadonlyArray<RelationshipT>,
      readonly type: 'load-work-relationships',
      readonly work: WorkT,
    }
  | {
      readonly recording: RecordingT,
      readonly type: 'remove-work',
      readonly workState: MediumWorkStateT,
    }
  | {
      readonly isSelected: boolean,
      readonly type: 'toggle-select-all-recordings',
    }
  | {
      readonly isSelected: boolean,
      readonly type: 'toggle-select-all-works',
    }
  | {
      readonly isSelected: boolean,
      readonly recording: RecordingT,
      readonly type: 'toggle-select-recording',
    }
  | {
      readonly isSelected: boolean,
      readonly type: 'toggle-select-work',
      readonly work: WorkT,
    }
  | {
      readonly isSelected: boolean,
      readonly recordingStates: MediumRecordingStateTreeT,
      readonly type: 'toggle-select-medium-recordings',
    }
  | {
      readonly isSelected: boolean,
      readonly recordingStates: MediumRecordingStateTreeT,
      readonly type: 'toggle-select-medium-works',
    }
    | {
      readonly editNote: string,
      readonly type: 'update-edit-note',
    }
  | {
      readonly checked: boolean,
      readonly type: 'update-make-votable',
    }
  | {type: 'start-submission'}
  | {readonly error?: string, type: 'stop-submission'}
  | {
      readonly edits:
        | Array<[Array<RelationshipStateT>, WsJsEditRelationshipT]>
        | Array<[Array<RelationshipStateT>, WsJsEditWorkCreateT]>,
      readonly responseData: WsJsEditResponseT,
      readonly type: 'update-submitted-relationships',
    }
  | {
      readonly showLoginDialog: boolean,
      readonly type: 'toggle-login-dialog',
    };
