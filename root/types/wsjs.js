/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

declare type WsJsRelationshipEntityT =
  | {
      readonly entityType: NonUrlRelatableEntityTypeT,
      readonly gid: string,
      readonly name: string,
    }
  | {
      readonly entityType: 'url',
      // We only use URL gids on the edit-url form.
      readonly gid?: string,
      readonly name: string,
    };

declare type WsJsRelationshipAttributeT = {
  readonly credited_as?: string,
  readonly removed?: boolean,
  readonly text_value?: string,
  readonly type: {readonly gid: string},
};

declare type WsJsRelationshipCommonT = {
  readonly attributes: ReadonlyArray<WsJsRelationshipAttributeT>,
  readonly begin_date?: PartialDateT,
  readonly end_date?: PartialDateT,
  readonly ended?: boolean,
  readonly enteredFrom?: WsJsRelationshipEntityT,
  readonly entities: [WsJsRelationshipEntityT, WsJsRelationshipEntityT],
  readonly entity0_credit: string,
  readonly entity1_credit: string,
};

declare type WsJsEditRelationshipCreateT = Readonly<{
  ...WsJsRelationshipCommonT,
  readonly edit_type: EDIT_RELATIONSHIP_CREATE_T,
  readonly linkOrder?: number,
  readonly linkTypeID: number,
}>;

declare type WsJsEditRelationshipEditT = Readonly<{
  ...Partial<WsJsRelationshipCommonT>,
  readonly edit_type: EDIT_RELATIONSHIP_EDIT_T,
  readonly id: number,
  readonly linkTypeID: number,
}>;

declare type WsJsEditRelationshipDeleteT = Readonly<{
  readonly edit_type: EDIT_RELATIONSHIP_DELETE_T,
  readonly enteredFrom?: WsJsRelationshipEntityT,
  readonly id: number,
  readonly linkTypeID: number,
}>;

declare type WsJsEditRelationshipT =
  | WsJsEditRelationshipCreateT
  | WsJsEditRelationshipEditT
  | WsJsEditRelationshipDeleteT
  | WsJsEditRelationshipsReorderT;

declare type WsJsEditRelationshipsReorderT = {
  readonly edit_type: EDIT_RELATIONSHIPS_REORDER_T,
  readonly enteredFrom?: WsJsRelationshipEntityT,
  readonly linkTypeID: number,
  readonly relationship_order: ReadonlyArray<{
    readonly link_order: number,
    readonly relationship_id: number,
  }>,
};

declare type WsJsEditWorkCreateT = {
  readonly comment: string,
  readonly edit_type: EDIT_WORK_CREATE_T,
  readonly languages: ReadonlyArray<number>,
  readonly name: string,
  readonly type_id: number | null,
};

declare type WS_EDIT_RESPONSE_OK_T = 1;
declare type WS_EDIT_RESPONSE_NO_CHANGES_T = 2;

declare type WsJsEditResponseT = {
  readonly edits: ReadonlyArray<
    | {
        readonly edit_type: EDIT_RELATIONSHIP_CREATE_T,
        readonly relationship_id: number | null,
        readonly response: WS_EDIT_RESPONSE_OK_T,
      }
    | {
        readonly edit_type: EDIT_RELEASE_CREATE_T,
        readonly entity: ReleaseT,
        readonly response: WS_EDIT_RESPONSE_OK_T,
      }
    | {
        readonly edit_type: EDIT_RELEASEGROUP_CREATE_T,
        readonly entity: ReleaseGroupT,
        readonly response: WS_EDIT_RESPONSE_OK_T,
      }
    | {
        readonly edit_type: EDIT_MEDIUM_CREATE_T,
        readonly entity: {readonly id: number, readonly position: number},
        readonly response: WS_EDIT_RESPONSE_OK_T,
      }
    | {
        readonly edit_type: EDIT_WORK_CREATE_T,
        readonly entity: WorkT,
        readonly response: WS_EDIT_RESPONSE_OK_T,
      }
    | {
        readonly edit_type: EDIT_RELEASE_ADDRELEASELABEL_T,
        readonly entity: {
          readonly catalogNumber: string | null,
          readonly id: number,
          readonly labelID: number | null,
        },
        readonly response: WS_EDIT_RESPONSE_OK_T,
      }
    | {
        readonly edit_type:
          | EDIT_MEDIUM_ADD_DISCID_T
          | EDIT_MEDIUM_DELETE_T
          | EDIT_MEDIUM_EDIT_T
          | EDIT_RECORDING_EDIT_T
          | EDIT_RELATIONSHIP_DELETE_T
          | EDIT_RELATIONSHIP_EDIT_T
          | EDIT_RELATIONSHIPS_REORDER_T
          | EDIT_RELEASE_ADD_ANNOTATION_T
          | EDIT_RELEASE_DELETERELEASELABEL_T
          | EDIT_RELEASE_EDIT_T
          | EDIT_RELEASE_EDITRELEASELABEL_T
          | EDIT_RELEASE_REORDER_MEDIUMS_T
          | EDIT_RELEASEGROUP_EDIT_T,
        readonly response: WS_EDIT_RESPONSE_OK_T,
      }
    | {readonly response: WS_EDIT_RESPONSE_NO_CHANGES_T}
  >,
};
