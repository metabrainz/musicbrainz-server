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
  +artist?: ArtistT | {+name?: string} | null,
  +joinPhrase: string,
  +name: string,
};

declare type ReleaseEditorSeededArtistCreditT = {
  +names: $ReadOnlyArray<ReleaseEditorSeededArtistCreditNameT | {}> | null,
};

declare type ReleaseEditorSeededTrackT = {
  +artistCredit?: ReleaseEditorSeededArtistCreditT | null,
  +length?: number,
  +name?: string,
  +number: StrOrNum,
  +position: number,
  +recording?: RecordingT,
};

declare type ReleaseEditorSeededMediumT = {
  +format_id?: number,
  +name?: string,
  +toc?: string,
  +tracks?: $ReadOnlyArray<ReleaseEditorSeededTrackT | {}> | null,
};

declare type ReleaseEditorSeededReleaseGroupT =
  | ReleaseGroupT
  | {
      +name: string,
      +secondaryTypeIDs?: $ReadOnlyArray<number>,
      +typeID?: number,
    };

declare type ReleaseEditorSeededReleaseEventT = {
  +country?: AreaT,
  +date?: {
    +day?: number,
    +month?: number,
    +year?: number,
  },
};

declare type ReleaseEditorSeededReleaseLabelT = {
  +catalogNumber: string,
  +label?: LabelT | {+name: string},
};

declare type ReleaseEditorSeededUrlRelationshipT = {
  +id: null,
  +linkTypeID?: number,
  +target: {
    +entityType: 'url',
    +name: string,
  },
};

declare type ReleaseEditorSeededReleaseT = {
  +annotation?: string,
  +artistCredit?: ReleaseEditorSeededArtistCreditT | null,
  +barcode?: string,
  +comment?: string,
  +events?: $ReadOnlyArray<ReleaseEditorSeededReleaseEventT | {}> | null,
  +labels?: $ReadOnlyArray<ReleaseEditorSeededReleaseLabelT | {}> | null,
  +languageID?: number,
  +mediums?: $ReadOnlyArray<ReleaseEditorSeededMediumT> | null,
  +name?: string,
  +packagingID?: number,
  +relationships?:
    $ReadOnlyArray<ReleaseEditorSeededUrlRelationshipT | {}> | null,
  +releaseGroup?: ReleaseEditorSeededReleaseGroupT | null,
  +scriptID?: number,
  +statusID?: number,
};

declare type ReleaseEditorSeedT = {
  +errors: $ReadOnlyArray<string>,
  +seed: ReleaseEditorSeededReleaseT,
};
