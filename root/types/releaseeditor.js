/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

/*
 * Global release editor types which are referenced from other global type
 * definitions under root/types/.
 *
 * NOTE-SEEDED-DATA-TYPES-1: These types are to be kept in sync with
 * the data format returned from `_seeded_data` in
 * lib/MusicBrainz/Server/Controller/ReleaseEditor.pm.
 */

declare type ReleaseEditorSeededArtistCreditNameT = {
  readonly artist?: ArtistT | {readonly name?: string} | null,
  readonly joinPhrase: string,
  readonly name: string,
};

declare type ReleaseEditorSeededArtistCreditT = {
  readonly names:
    ReadonlyArray<ReleaseEditorSeededArtistCreditNameT | {}> | null,
};

declare type ReleaseEditorSeededTrackT = {
  readonly artistCredit?: ReleaseEditorSeededArtistCreditT | null,
  readonly length?: number,
  readonly name?: string,
  readonly number: StrOrNum,
  readonly position: number,
  readonly recording?: RecordingT,
};

declare type ReleaseEditorSeededMediumT = {
  readonly format_id?: number,
  readonly name?: string,
  readonly toc?: string,
  readonly tracks?: ReadonlyArray<ReleaseEditorSeededTrackT | {}> | null,
};

declare type ReleaseEditorSeededReleaseGroupT =
  | ReleaseGroupT
  | {
      readonly name: string,
      readonly secondaryTypeIDs?: ReadonlyArray<number>,
      readonly typeID?: number,
    };

declare type ReleaseEditorSeededReleaseEventT = {
  readonly country?: AreaT,
  readonly date?: {
    readonly day?: number,
    readonly month?: number,
    readonly year?: number,
  },
};

declare type ReleaseEditorSeededReleaseLabelT = {
  readonly catalogNumber: string,
  readonly label?: LabelT | {readonly name: string},
};

declare type ReleaseEditorSeededUrlRelationshipT = {
  readonly id: null,
  readonly linkTypeID?: number,
  readonly target: {
    readonly entityType: 'url',
    readonly name: string,
  },
};

declare type ReleaseEditorSeededReleaseT = {
  readonly annotation?: string,
  readonly artistCredit?: ReleaseEditorSeededArtistCreditT | null,
  readonly barcode?: string,
  readonly comment?: string,
  readonly events?:
    ReadonlyArray<ReleaseEditorSeededReleaseEventT | {}> | null,
  readonly labels?:
    ReadonlyArray<ReleaseEditorSeededReleaseLabelT | {}> | null,
  readonly languageID?: number,
  readonly mediums?: ReadonlyArray<ReleaseEditorSeededMediumT> | null,
  readonly name?: string,
  readonly packagingID?: number,
  readonly relationships?:
    ReadonlyArray<ReleaseEditorSeededUrlRelationshipT | {}> | null,
  readonly releaseGroup?: ReleaseEditorSeededReleaseGroupT | null,
  readonly scriptID?: number,
  readonly statusID?: number,
};

declare type ReleaseEditorSeedT = {
  readonly errors: ReadonlyArray<string>,
  readonly seed: ReleaseEditorSeededReleaseT,
};
