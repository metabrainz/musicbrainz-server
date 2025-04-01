/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type RelationshipAttributeTypeEditFormT = FormT<{
  +child_order: FieldT<string>,
  +creditable: FieldT<boolean>,
  +description: FieldT<string>,
  +edit_note: FieldT<string>,
  +free_text: FieldT<boolean>,
  +name: FieldT<string>,
  +parent_id: FieldT<string>,
}>;
