/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare type WsJsRelationshipEntityT =
  | {
      +entityType: NonUrlCoreEntityTypeT,
      +gid: string,
      +name: string,
    }
  | {
      +entityType: 'url',
      // We only use URL gids on the edit-url form.
      +gid?: string,
      +name: string,
    };

declare type WsJsRelationshipAttributeT = {
  +credited_as?: string,
  +removed?: boolean,
  +text_value?: string,
  +type: {+gid: string},
};

declare type WsJsRelationshipCommonT = {
  +attributes: $ReadOnlyArray<WsJsRelationshipAttributeT>,
  +begin_date?: PartialDateT,
  +end_date?: PartialDateT,
  +ended?: boolean,
  +entities: [WsJsRelationshipEntityT, WsJsRelationshipEntityT],
  +entity0_credit: string,
  +entity1_credit: string,
};

declare type WsJsEditRelationshipCreateT = $ReadOnly<{
  ...WsJsRelationshipCommonT,
  +edit_type: EDIT_RELATIONSHIP_CREATE_T,
  +linkOrder?: number,
  +linkTypeID: number,
}>;

declare type WsJsEditRelationshipEditT = $ReadOnly<{
  ...$Partial<WsJsRelationshipCommonT>,
  +edit_type: EDIT_RELATIONSHIP_EDIT_T,
  +id: number,
  +linkTypeID: number,
}>;

declare type WsJsEditRelationshipDeleteT = $ReadOnly<{
  +edit_type: EDIT_RELATIONSHIP_DELETE_T,
  +id: number,
  +linkTypeID: number,
}>;

declare type WsJsEditRelationshipT =
  | WsJsEditRelationshipCreateT
  | WsJsEditRelationshipEditT
  | WsJsEditRelationshipDeleteT
  | WsJsEditRelationshipsReorderT;

declare type WsJsEditRelationshipsReorderT = {
  +edit_type: EDIT_RELATIONSHIPS_REORDER_T,
  +linkTypeID: number,
  +relationship_order: $ReadOnlyArray<{
    +link_order: number,
    +relationship_id: number,
  }>,
};

declare type WsJsEditWorkCreateT = {
  +comment: string,
  +edit_type: EDIT_WORK_CREATE_T,
  +languages: $ReadOnlyArray<number>,
  +name: string,
  +type_id: number | null,
};

declare type WS_EDIT_RESPONSE_OK_T = 1;
declare type WS_EDIT_RESPONSE_NO_CHANGES_T = 2;

declare type WsJsEditResponseT = {
  +edits: $ReadOnlyArray<
    | {
        +edit_type: EDIT_RELATIONSHIP_CREATE_T,
        +relationship_id: number | null,
        +response: WS_EDIT_RESPONSE_OK_T,
      }
    | {
        +edit_type: EDIT_RELEASE_CREATE_T,
        +entity: ReleaseT,
        +response: WS_EDIT_RESPONSE_OK_T,
      }
    | {
        +edit_type: EDIT_RELEASEGROUP_CREATE_T,
        +entity: ReleaseGroupT,
        +response: WS_EDIT_RESPONSE_OK_T,
      }
    | {
        +edit_type: EDIT_MEDIUM_CREATE_T,
        +entity: {+id: number, +position: number},
        +response: WS_EDIT_RESPONSE_OK_T,
      }
    | {
        +edit_type: EDIT_WORK_CREATE_T,
        +entity: WorkT,
        +response: WS_EDIT_RESPONSE_OK_T,
      }
    | {
        +edit_type: EDIT_RELEASE_ADDRELEASELABEL_T,
        +entity: {
          +catalogNumber: string | null,
          +id: number,
          +labelID: number | null,
        },
        +response: WS_EDIT_RESPONSE_OK_T,
      }
    | {
        +edit_type:
          | EDIT_MEDIUM_ADD_DISCID_T
          | EDIT_MEDIUM_DELETE_T
          | EDIT_MEDIUM_EDIT_T
          | EDIT_RECORDING_EDIT_T
          | EDIT_RELATIONSHIP_DELETE_T
          | EDIT_RELATIONSHIP_EDIT_T
          | EDIT_RELEASE_ADD_ANNOTATION_T
          | EDIT_RELEASE_DELETERELEASELABEL_T
          | EDIT_RELEASE_EDIT_T
          | EDIT_RELEASE_EDITRELEASELABEL_T
          | EDIT_RELEASE_REORDER_MEDIUMS_T
          | EDIT_RELEASEGROUP_EDIT_T,
        +response: WS_EDIT_RESPONSE_OK_T,
      }
    | {+response: WS_EDIT_RESPONSE_NO_CHANGES_T}
  >,
};
