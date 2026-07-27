/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

declare type IpiCodesRoleT = {
  readonly ipi_codes: ReadonlyArray<IpiCodeT>,
};

declare type IpiCodeT = {
  ...PendingEditsRoleT,
  readonly ipi: string,
};

declare type IsniCodesRoleT = {
  readonly isni_codes: ReadonlyArray<IsniCodeT>,
};

declare type IsniCodeT = {
  ...PendingEditsRoleT,
  readonly isni: string,
};

declare type IsrcT = {
  ...EntityRoleT<'isrc'>,
  ...PendingEditsRoleT,
  readonly isrc: string,
  readonly recording_id: number,
};

declare type IswcT = {
  ...EntityRoleT<'iswc'>,
  ...PendingEditsRoleT,
  readonly iswc: string,
  readonly work_id: number,
};
