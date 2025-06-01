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

export type LinksEditorRelationshipDialogStateT = {
  +creditField: FieldT<string | null>,
  +datePeriodField: DatePeriodFieldT,
};

/*
 * `LinkRelationshipStateT` represents a single relationship associated with
 * a URL. Most of the fields correspond to those on `RelationshipT`.
 */
export type LinkRelationshipStateT = {
  +beginDate: PartialDateT | null,
  /*
   * `dialogState` stores the `ExternalLinkRelationshipDialog` popover
   * state, if this relationship's attributes are being edited. It's created
   * in `toggle-link-relationship-dialog` whenever the dialog is opened.
   * If it's `null`, the relationship dialog is closed.
   */
  +dialogState: LinksEditorRelationshipDialogStateT | null,
  +editsPending: boolean,
  +endDate: PartialDateT | null,
  +ended: boolean,
  +entityCredit: string,
  +error: ErrorT | null,
  +id: number,
  +linkTypeID: number | null,
  /*
   * `originalState` stores the initial `LinkRelationshipStateT` for
   * existing relationships in order to diff the edit data for submission
   * later.
   *
   * If the relationship has no changes, then `x.originalState === x`.
   * If this is a new relationship, `originalState` is `null`.
   */
  +originalState: LinkRelationshipStateT | null,
  /*
   * Indicates whether an existing relationship is marked for removal.
   */
  +removed: boolean,
  /*
   * The `url` field should be identical to the parent `LinkStateT`'s `url`
   * field. It's stored here for convenience, since it allows dropping the
   * parent `LinkStateT` from function arguments when only the relationship
   * data is otherwise needed.
   */
  +url: string,
  +video: boolean,
};

export type LinkRelationshipStatusT = {
  +changes: {
    +beginDate?: CompT<PartialDateT | null>,
    +endDate?: CompT<PartialDateT | null>,
    +ended?: CompT<boolean>,
    +entityCredit?: CompT<string>,
    +linkTypeID?: CompT<number | null>,
    +url?: CompT<string>,
    +video?: CompT<boolean>,
  },
  +isNew: boolean,
  +removed: boolean,
};

/*
 * `LinkStateT` represents a single URL and its associated relationships,
 * whether new or existing.
 */
export type LinkStateT = {
  /*
   * If you add a new link or change an existing one, we check whether the
   * new link state duplicates another in `validateLink`. We use the
   * `duplicateOf` field to either show an error or provide a merge option.
   */
  +duplicateOf: {
    +index: number,
    +link: LinkStateT,
   } | null,
  +error: ErrorT | null,
  /*
   * `isNew` indicates whether the link is new to this entity, or already
   * exists on this entity in the database. This could be determined by
   * looping over `relationships` and checking whether any have a database
   * row ID, but we store `isNew` as a static property for convenience.
   */
  +isNew: boolean,
  /*
   * Links which are still editable inline can be submitted (or merged) by
   * hitting enter or tabbing out of the field, assuming the link is a
   * valid URL. `isSubmitted` basically just means that the URL input has
   * been turned into a clickable link.
   */
  +isSubmitted: boolean,
  /*
   * The `key` is a client-side ID used to uniquely identify each link on the
   * page. (The `url` is not suitable for this purpose, since the user is
   * allowed to enter a duplicate URL before they are presented with an error
   * or merge option.)
   *
   * `LinksEditorStateT['links']` is sorted by this key, so reducer actions
   * generally use it to locate and update links in the state tree.
   */
  +key: number,
  /*
   * If this is an existing URL (`isNew` is false), we store the original
   * associated URL entity here (which is taken from any of the existing
   * relationships). This is used to show a pending edits warning, if
   * applicable, and to calculate edit data for submission.
   *
   * Editing the `url` does not change the `originalUrlEntity`.
   */
  +originalUrlEntity: UrlT | null,
  /*
   * The raw URL as entered by the user. This may differ from `url`, which
   * is the cleaned/normalized version used for validation and submission.
   */
  +rawUrl: string,
  /*
   * The relationships associated with this URL, whether new or existing.
   */
  +relationships: $ReadOnlyArray<LinkRelationshipStateT>,
  /*
   * The cleaned/normalized URL used for validation and submission.
   */
  +url: string,
  /*
   * If this link is being edited in a popover, we store its pending state
   * here. Once the popover is accepted, the main link state is updated
   * accordingly. If it's `null`, the popover is closed.
   */
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
      +type: 'update-link-relationship-dialog',
      +action: LinksEditorRelationshipDialogActionT,
      +link: LinkStateT,
      +relationship: LinkRelationshipStateT,
    }
  | {
      +type: 'accept-link-relationship-dialog',
      +link: LinkStateT,
      +relationship: LinkRelationshipStateT,
    }
  | {
      +type: 'toggle-link-relationship-dialog',
      +link: LinkStateT,
      +open: boolean,
      +relationship: LinkRelationshipStateT,
    };

export type LinksEditorRelationshipDialogActionT =
  | {
      +action: DateRangeFieldsetActionT,
      +type: 'update-date-period',
    }
  | {+credit: string, +type: 'update-relationship-credit'}
  | {+type: 'show-all-pending-errors'};
/* eslint-enable ft-flow/sort-keys */
