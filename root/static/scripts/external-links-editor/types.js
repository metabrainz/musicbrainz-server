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

type ErrorTargetT = Values<ERROR_TARGETS>;

export type ErrorT = {
  readonly blockMerge?: boolean,
  readonly message: React.Node,
  readonly target: ErrorTargetT,
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
  readonly creditField: FieldT<string | null>,
  readonly datePeriodField: DatePeriodFieldT,
};

/*
 * `LinkRelationshipStateT` represents a single relationship associated with
 * a URL. Most of the fields correspond to those on `RelationshipT`.
 */
export type LinkRelationshipStateT = {
  readonly beginDate: PartialDateT | null,
  /*
   * `dialogState` stores the `ExternalLinkRelationshipDialog` popover
   * state, if this relationship's attributes are being edited. It's created
   * in `toggle-link-relationship-dialog` whenever the dialog is opened.
   * If it's `null`, the relationship dialog is closed.
   */
  readonly dialogState: LinksEditorRelationshipDialogStateT | null,
  readonly editsPending: boolean,
  readonly endDate: PartialDateT | null,
  readonly ended: boolean,
  readonly entityCredit: string,
  readonly error: ErrorT | null,
  readonly id: number,
  readonly linkTypeID: number | null,
  /*
   * `originalState` stores the initial `LinkRelationshipStateT` for
   * existing relationships in order to diff the edit data for submission
   * later.
   *
   * If the relationship has no changes, then `x.originalState === x`.
   * If this is a new relationship, `originalState` is `null`.
   */
  readonly originalState: LinkRelationshipStateT | null,
  /*
   * Indicates whether an existing relationship is marked for removal.
   */
  readonly removed: boolean,
  /*
   * The `url` field should be identical to the parent `LinkStateT`'s `url`
   * field. It's stored here for convenience, since it allows dropping the
   * parent `LinkStateT` from function arguments when only the relationship
   * data is otherwise needed.
   */
  readonly url: string,
  readonly video: boolean,
};

export type LinkRelationshipStatusT = {
  readonly changes: {
    readonly beginDate?: CompT<PartialDateT | null>,
    readonly endDate?: CompT<PartialDateT | null>,
    readonly ended?: CompT<boolean>,
    readonly entityCredit?: CompT<string>,
    readonly linkTypeID?: CompT<number | null>,
    readonly url?: CompT<string>,
    readonly video?: CompT<boolean>,
  },
  readonly isNew: boolean,
  readonly removed: boolean,
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
  readonly duplicateOf: {
    readonly index: number,
    readonly link: LinkStateT,
   } | null,
  readonly error: ErrorT | null,
  /*
   * `isNew` indicates whether the link is new to this entity, or already
   * exists on this entity in the database. This could be determined by
   * looping over `relationships` and checking whether any have a database
   * row ID, but we store `isNew` as a static property for convenience.
   */
  readonly isNew: boolean,
  /*
   * Links which are still editable inline can be submitted (or merged) by
   * hitting enter or tabbing out of the field, assuming the link is a
   * valid URL. `isSubmitted` basically just means that the URL input has
   * been turned into a clickable link.
   */
  readonly isSubmitted: boolean,
  /*
   * The `key` is a client-side ID used to uniquely identify each link on the
   * page. (The `url` is not suitable for this purpose, since the user is
   * allowed to enter a duplicate URL before they are presented with an error
   * or merge option.)
   *
   * `LinksEditorStateT['links']` is sorted by this key, so reducer actions
   * generally use it to locate and update links in the state tree.
   */
  readonly key: number,
  /*
   * If this is an existing URL (`isNew` is false), we store the original
   * associated URL entity here (which is taken from any of the existing
   * relationships). This is used to show a pending edits warning, if
   * applicable, and to calculate edit data for submission.
   *
   * Editing the `url` does not change the `originalUrlEntity`.
   */
  readonly originalUrlEntity: UrlT | null,
  /*
   * The raw URL as entered by the user. This may differ from `url`, which
   * is the cleaned/normalized version used for validation and submission.
   */
  readonly rawUrl: string,
  /*
   * The relationships associated with this URL, whether new or existing.
   */
  readonly relationships: ReadonlyArray<LinkRelationshipStateT>,
  /*
   * The cleaned/normalized URL used for validation and submission.
   */
  readonly url: string,
  /*
   * If this link is being edited in a popover, we store its pending state
   * here. Once the popover is accepted, the main link state is updated
   * accordingly. If it's `null`, the popover is closed.
   */
  readonly urlPopoverLinkState: LinkStateT | null,
};

export type LinksEditorStateT = {
  readonly focus: string,
  readonly links: ImmutableTree<LinkStateT>,
  readonly source: RelatableEntityT,
};

/* eslint-disable ft-flow/sort-keys */
export type LinksEditorActionT =
  | {
      readonly type: 'add-relationship',
      readonly link: LinkStateT,
    }
  | {
      readonly type: 'set-focus',
      readonly focus: string,
    }
  | {
      readonly type: 'handle-url-change',
      readonly link: LinkStateT,
      readonly rawUrl: string,
    }
  | {
      readonly type: 'merge-link',
      readonly link: LinkStateT,
    }
  | {
      readonly type: 'open-url-input-popover',
      readonly link: LinkStateT,
    }
  | {
      readonly type: 'toggle-remove-link',
      readonly link: LinkStateT,
    }
  | {
      readonly type: 'toggle-remove-relationship',
      readonly link: LinkStateT,
      readonly relationship: LinkRelationshipStateT,
    }
  | {
      readonly type: 'set-type',
      readonly link: LinkStateT,
      readonly relationship: LinkRelationshipStateT,
      readonly linkTypeID: number | null,
    }
  | {
      readonly type: 'set-video',
      readonly link: LinkStateT,
      readonly relationship: LinkRelationshipStateT,
      readonly video: boolean,
    }
  | {
      readonly type: 'submit-link',
      readonly link: LinkStateT,
    }
  | {
      readonly type: 'update-url-input-popover-url',
      readonly link: LinkStateT,
      readonly rawUrl: string,
    }
  | {
      readonly type: 'accept-url-input-popover',
      readonly link: LinkStateT,
    }
  | {
      readonly type: 'cancel-url-input-popover',
      readonly link: LinkStateT,
    }
  | {
      readonly type: 'update-link-relationship-dialog',
      readonly action: LinksEditorRelationshipDialogActionT,
      readonly link: LinkStateT,
      readonly relationship: LinkRelationshipStateT,
    }
  | {
      readonly type: 'accept-link-relationship-dialog',
      readonly link: LinkStateT,
      readonly relationship: LinkRelationshipStateT,
    }
  | {
      readonly type: 'toggle-link-relationship-dialog',
      readonly link: LinkStateT,
      readonly open: boolean,
      readonly relationship: LinkRelationshipStateT,
    };

export type LinksEditorRelationshipDialogActionT =
  | {
      readonly action: DateRangeFieldsetActionT,
      readonly type: 'update-date-period',
    }
  | {readonly credit: string, readonly type: 'update-relationship-credit'}
  | {readonly type: 'show-all-pending-errors'};
/* eslint-enable ft-flow/sort-keys */
