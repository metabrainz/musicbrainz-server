/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// MusicBrainz::Server::Entity::Alias::TO_JSON
declare type AliasT<+T> = $ReadOnly<{
  ...DatePeriodRoleT,
  ...EntityRoleT<'alias'>,
  ...PendingEditsRoleT,
  ...TypeRoleT<T>,
  +locale: string | null,
  +name: string,
  +primary_for_locale: boolean,
  +sort_name: string,
}>;

declare type AreaAliasTypeT = OptionTreeT<'area_alias_type'>;

declare type AreaAliasT = AliasT<AreaAliasTypeT>;

declare type ArtistAliasTypeT = OptionTreeT<'artist_alias_type'>;

declare type ArtistAliasT = AliasT<ArtistAliasTypeT>;

declare type EventAliasTypeT = OptionTreeT<'event_alias_type'>;

declare type EventAliasT = AliasT<EventAliasTypeT>;

declare type GenreAliasTypeT = OptionTreeT<'genre_alias_type'>;

declare type GenreAliasT = AliasT<GenreAliasTypeT>;

declare type InstrumentAliasTypeT = OptionTreeT<'instrument_alias_type'>;

declare type InstrumentAliasT = AliasT<InstrumentAliasTypeT>;

declare type LabelAliasTypeT = OptionTreeT<'label_alias_type'>;

declare type LabelAliasT = AliasT<LabelAliasTypeT>;

declare type PlaceAliasTypeT = OptionTreeT<'place_alias_type'>;

declare type PlaceAliasT = AliasT<PlaceAliasTypeT>;

declare type RecordingAliasTypeT = OptionTreeT<'recording_alias_type'>;

declare type RecordingAliasT = AliasT<RecordingAliasTypeT>;

declare type ReleaseAliasTypeT = OptionTreeT<'release_alias_type'>;

declare type ReleaseAliasT = AliasT<ReleaseAliasTypeT>;

declare type ReleaseGroupAliasTypeT = OptionTreeT<'releaseGroup_alias_type'>;

declare type ReleaseGroupAliasT = AliasT<ReleaseGroupAliasTypeT>;

declare type SeriesAliasTypeT = OptionTreeT<'series_alias_type'>;

declare type SeriesAliasT = AliasT<SeriesAliasTypeT>;

declare type WorkAliasTypeT = OptionTreeT<'work_alias_type'>;

declare type WorkAliasT = AliasT<WorkAliasTypeT>;

declare type AnyAiasT = AliasT<
 | AreaAliasTypeT
 | ArtistAliasTypeT
 | EventAliasTypeT
 | GenreAliasTypeT
 | InstrumentAliasTypeT
 | LabelAliasTypeT
 | PlaceAliasTypeT
 | RecordingAliasTypeT
 | ReleaseAliasTypeT
 | ReleaseGroupAliasTypeT
 | SeriesAliasTypeT
 | WorkAliasTypeT
>;
