/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare type QualityT = -1 | 0 | 1 | 2;

declare type ReleaseEventT = {
  +country: AreaT | null,
  +date: PartialDateT | null,
};

declare type ReleaseLabelT = {
  +catalogNumber: string | null,
  +label: LabelT | null,
  +label_id: number,
};

declare type ReleasePackagingT = OptionTreeT<'release_packaging'>;

declare type ReleaseStatusT = OptionTreeT<'release_status'>;

// MusicBrainz::Server::Entity::Release::TO_JSON
declare type ReleaseT = $ReadOnly<{
  ...AnnotationRoleT,
  ...ArtistCreditRoleT,
  ...CommentRoleT,
  ...RelatableEntityRoleT<'release'>,
  +barcode: string | null,
  +combined_format_name?: string,
  +combined_track_count?: string,
  +cover_art_presence: 'absent' | 'present' | 'darkened' | null,
  +events?: $ReadOnlyArray<ReleaseEventT>,
  +has_no_tracks: boolean,
  +labels?: $ReadOnlyArray<ReleaseLabelT>,
  +language: LanguageT | null,
  +languageID: number | null,
  +length?: number,
  +may_have_cover_art?: boolean,
  +may_have_discids?: boolean,
  +mediums?: $ReadOnlyArray<MediumT>,
  +packagingID: number | null,
  +primaryAlias?: string | null,
  +quality: QualityT,
  +releaseGroup?: ReleaseGroupT,
  +script: ScriptT | null,
  +scriptID: number | null,
  +status: ReleaseStatusT | null,
  +statusID: number | null,
}>;

declare type ReleaseWithMediumsT = $ReadOnly<{
  ...ReleaseT,
  +mediums: $ReadOnlyArray<MediumWithRecordingsT>,
}>;
