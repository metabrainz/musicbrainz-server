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
     +creditedAs: string,
     +type: 'set-credit',
    }
 | {
     +type: 'set-credits-to-change',
     +value: CreditChangeOptionT,
   };

export type DialogLinkOrderActionT = {
  +newLinkOrder: number,
  +type: 'update-link-order',
};

export type DialogActionT =
  | {
      +type: 'change-direction',
    }
  | {
      +attributes: $ReadOnlyArray<ExternalLinkAttrT>,
      +type: 'set-attributes',
    }
  | {+type: 'toggle-attributes-help'}
  | {
      +action: DialogEntityCreditActionT,
      +type: 'update-source-entity',
    }
  | {
      +action: DialogTargetEntityActionT,
      +source: CoreEntityT,
      +type: 'update-target-entity',
    }
  | {
      +source: CoreEntityT,
      +targetType: CoreEntityTypeT,
      +type: 'update-target-type',
    }
  | DialogLinkOrderActionT
  | {
      +action: DialogLinkTypeActionT,
      +source: CoreEntityT,
      +type: 'update-link-type',
    }
  | {
      +action: DialogAttributeActionT,
      +type: 'update-attribute',
    }
  | {
      +action: DateRangeFieldsetActionT,
      +type: 'update-date-period',
    };

export type DialogAttributeActionT =
  | {
      +action: DialogBooleanAttributeActionT,
      +rootKey: number,
      +type: 'update-boolean-attribute',
    }
  | {
      +action: DialogMultiselectAttributeActionT,
      +rootKey: number,
      +type: 'update-multiselect-attribute',
    }
  | {
      +action: DialogTextAttributeActionT,
      +rootKey: number,
      +type: 'update-text-attribute',
    };

export type DialogBooleanAttributeActionT =
  | {
      +enabled: boolean,
      +type: 'toggle',
    };

export type DialogLinkTypeActionT =
  | {
      +action: AutocompleteActionT<LinkTypeT>,
      +source: CoreEntityT,
      +type: 'update-autocomplete',
    };

export type DialogMultiselectAttributeActionT =
  | MultiselectActionT<LinkAttrTypeT>
  | {
      +creditedAs: string,
      +type: 'set-value-credit',
      +valueKey: number,
    };

export type DialogTextAttributeActionT =
  | {
      +textValue: string,
      +type: 'set-text-value',
    };

export type UpdateRelationshipActionT =
  | {
      +batchSelectionCount: number | void,
      +creditsToChangeForSource: CreditChangeOptionT,
      +creditsToChangeForTarget: CreditChangeOptionT,
      +newRelationshipState: RelationshipStateT,
      +oldRelationshipState: RelationshipStateT | null,
      +sourceEntity: CoreEntityT,
      +type: 'update-relationship-state',
  };

export type RelationshipEditorActionT =
  | {
      +relationship: RelationshipStateT,
      +type: 'remove-relationship',
    }
  | {
      +relationship: RelationshipStateT,
      +source: CoreEntityT,
      +type: 'move-relationship-down',
    }
  | {
      +relationship: RelationshipStateT,
      +source: CoreEntityT,
      +type: 'move-relationship-up',
    }
  | {
      +hasOrdering: boolean,
      +linkPhraseGroup: RelationshipPhraseGroupT,
      +source: CoreEntityT,
      +type: 'toggle-ordering',
    }
  | {
      +location: RelationshipDialogLocationT | null,
      +type: 'update-dialog-location',
    }
  | {
      +changes: {+[property: string]: mixed},
      +entityType: CoreEntityTypeT,
      +type: 'update-entity',
    }
  | UpdateRelationshipActionT;

export type UpdateTargetEntityAutocompleteActionT = {
  +action: AutocompleteActionT<NonUrlCoreEntityT>,
  +linkType: ?LinkTypeT,
  +source: CoreEntityT,
  +type: 'update-autocomplete',
};

export type DialogTargetEntityActionT =
  | UpdateTargetEntityAutocompleteActionT
  | {
      +action: DialogEntityCreditActionT,
      +type: 'update-credit',
    }
  | {
      +text: string,
      +type: 'update-url-text',
    };

/* Release relationship-editor actions */

export type BatchCreateWorksDialogActionT =
  | {
      action: DialogAttributeActionT,
      type: 'update-attribute',
    }
  | {
      action: MultiselectActionT<LanguageT>,
      type: 'update-languages',
    }
  | {
      action: DialogLinkTypeActionT,
      source: CoreEntityT,
      type: 'update-link-type',
    }
  | WorkTypeSelectActionT;

export type AcceptBatchCreateWorksDialogActionT = {
  +attributes: tree.ImmutableTree<LinkAttrT> | null,
  +languages: $ReadOnlyArray<LanguageT>,
  +linkType: LinkTypeT,
  +type: 'accept-batch-create-works-dialog',
  +workType: number | null,
};

export type ReleaseRelationshipEditorActionT =
  | LazyReleaseActionT
  | RelationshipEditorActionT
  | AcceptBatchCreateWorksDialogActionT
  | {
      +languages: $ReadOnlyArray<LanguageT>,
      +name: string,
      +type: 'accept-edit-work-dialog',
      +work: WorkT,
      +workType: number | null,
    }
  | {
      +relationships: $ReadOnlyArray<RelationshipT>,
      +type: 'load-work-relationships',
      +work: WorkT,
    }
  | {
      +recording: RecordingT,
      +type: 'remove-work',
      +workState: MediumWorkStateT,
    }
  | {
      +isSelected: boolean,
      +type: 'toggle-select-all-recordings',
    }
  | {
      +isSelected: boolean,
      +type: 'toggle-select-all-works',
    }
  | {
      +isSelected: boolean,
      +recording: RecordingT,
      +type: 'toggle-select-recording',
    }
  | {
      +isSelected: boolean,
      +type: 'toggle-select-work',
      +work: WorkT,
    }
  | {
      +isSelected: boolean,
      +recordingStates: MediumRecordingStateTreeT | null,
      +type: 'toggle-select-medium-recordings',
    }
  | {
      +isSelected: boolean,
      +recordingStates: MediumRecordingStateTreeT | null,
      +type: 'toggle-select-medium-works',
    }
    | {
      +editNote: string,
      +type: 'update-edit-note',
    }
  | {
      +checked: boolean,
      +type: 'update-make-votable',
    }
  | {type: 'start-submission'}
  | {+error?: string, type: 'stop-submission'}
  | {
      +edits:
        | Array<[Array<RelationshipStateT>, WsJsEditRelationshipT]>
        | Array<[Array<RelationshipStateT>, WsJsEditWorkCreateT]>,
      +responseData: WsJsEditResponseT,
      +type: 'update-submitted-relationships',
    };
