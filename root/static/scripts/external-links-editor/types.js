/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {ImmutableTree} from 'weight-balanced-tree';

import type {
  ActionT as DateRangeFieldsetActionT,
} from '../edit/components/DateRangeFieldset.js';
import typeof {ERROR_TARGETS} from '../edit/URLCleanup.js';

type ErrorTargetT = $Values<ERROR_TARGETS>;

export type ErrorT = {
  +blockMerge?: boolean,
  +message: React.Node,
  +target: ErrorTargetT,
};

export type HighlightT =
  | 'rel-add'
  | 'rel-edit'
  | ''
  | 'rel-remove';

export type LinkTypeOptionT = {
  data: LinkTypeT,
  disabled?: boolean,
  text: string,
  value: number,
};

export type LinksEditorAttributeDialogStateT = {
  +creditField: FieldT<string | null>,
  +datePeriodField: DatePeriodFieldT,
};

export type LinkRelationshipStateT = {
  +attributeDialogState: LinksEditorAttributeDialogStateT | null,
  +beginDate: PartialDateT | null,
  +editsPending: boolean,
  +endDate: PartialDateT | null,
  +ended: boolean,
  +entityCredit: string,
  +error: ErrorT | null,
  +id: number,
  +linkTypeID: number | null,
  +originalState: LinkRelationshipStateT | null,
  +removed: boolean,
  +url: string,
  +video: boolean,
};

export type LinkStateT = {
  +duplicateOf: {
    +index: number,
    +link: LinkStateT,
   } | null,
  +error: ErrorT | null,
  +isNew: boolean,
  /*
   * Links which are still editable inline can be submitted (or merged) by
   * hitting enter or tabbing out of the field, assuming the link is a
   * valid URL.
   */
  +isSubmitted: boolean,
  +key: number,
  +originalUrlEntity: UrlT | null,
  +rawUrl: string,
  +relationships: $ReadOnlyArray<LinkRelationshipStateT>,
  +url: string,
  +urlPopoverLinkState: LinkStateT | null,
};

export type LinksEditorStateT = {
  +focus: string,
  +links: ImmutableTree<LinkStateT>,
  +source: RelatableEntityT,
};

/* eslint-disable ft-flow/sort-keys */
export type LinksEditorActionT =
  | {
      +type: 'add-relationship',
      +link: LinkStateT,
    }
  | {
      +type: 'set-focus',
      +focus: string,
    }
  | {
      +type: 'handle-url-change',
      +link: LinkStateT,
      +rawUrl: string,
    }
  | {
      +type: 'merge-link',
      +link: LinkStateT,
    }
  | {
      +type: 'open-url-input-popover',
      +link: LinkStateT,
    }
  | {
      +type: 'toggle-remove-link',
      +link: LinkStateT,
    }
  | {
      +type: 'toggle-remove-relationship',
      +link: LinkStateT,
      +relationship: LinkRelationshipStateT,
    }
  | {
      +type: 'set-type',
      +link: LinkStateT,
      +relationship: LinkRelationshipStateT,
      +linkTypeID: number | null,
    }
  | {
      +type: 'set-video',
      +link: LinkStateT,
      +relationship: LinkRelationshipStateT,
      +video: boolean,
    }
  | {
      +type: 'submit-link',
      +link: LinkStateT,
    }
  | {
      +type: 'update-url-input-popover-url',
      +link: LinkStateT,
      +rawUrl: string,
    }
  | {
      +type: 'accept-url-input-popover',
      +link: LinkStateT,
    }
  | {
      +type: 'cancel-url-input-popover',
      +link: LinkStateT,
    }
  | {
      +type: 'update-attribute-dialog',
      +action: LinksEditorAttributeDialogActionT,
      +link: LinkStateT,
      +relationship: LinkRelationshipStateT,
    }
  | {
      +type: 'accept-attribute-dialog',
      +link: LinkStateT,
      +relationship: LinkRelationshipStateT,
    }
  | {
      +type: 'toggle-attribute-dialog',
      +link: LinkStateT,
      +open: boolean,
      +relationship: LinkRelationshipStateT,
    };

export type LinksEditorAttributeDialogActionT =
  | {
      +action: DateRangeFieldsetActionT,
      +type: 'update-date-period',
    }
  | {+credit: string, +type: 'update-relationship-credit'}
  | {+type: 'show-all-pending-errors'};
/* eslint-enable ft-flow/sort-keys */
