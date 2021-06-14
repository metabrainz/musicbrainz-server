/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare type IpiCodesRoleT = {
  +ipi_codes: $ReadOnlyArray<IpiCodeT>,
};

declare type IpiCodeT = {
  ...EditableRoleT,
  +ipi: string,
};

declare type IsniCodesRoleT = {
  +isni_codes: $ReadOnlyArray<IsniCodeT>,
};

declare type IsniCodeT = {
  ...EditableRoleT,
  +isni: string,
};

declare type IsrcT = {
  ...EditableRoleT,
  ...EntityRoleT<'isrc'>,
  +isrc: string,
  +recording_id: number,
};

declare type IswcT = {
  ...EditableRoleT,
  ...EntityRoleT<'iswc'>,
  +iswc: string,
  +work_id: number,
};
