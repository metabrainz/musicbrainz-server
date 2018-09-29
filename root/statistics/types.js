/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {Node as ReactNode} from 'react';

export type CountriesStatsT = {|
  +$c: CatalystContextT,
  +countryStats: $ReadOnlyArray<CountryStatT>,
  +dateCollected: string,
|};

declare type CountryStatT = {|
  +artist_count: number,
  +entity: AreaT,
  +label_count: number,
  +release_count: number,
|};

export type FormatsStatsT = {|
  +$c: CatalystContextT,
  +dateCollected: string,
  +formatStats: $ReadOnlyArray<FormatStatT>,
  +stats: StatsT,
|};

declare type FormatStatT = {|
  +entity: MediumFormatT | null,
  +medium_count: number,
  +medium_stat: string,
  +release_count: number,
  +release_stat: string,
|};

export type LanguagesScriptsStatsT = {|
  +$c: CatalystContextT,
  +dateCollected: string,
  +languageStats: $ReadOnlyArray<LanguageStatT>,
  +scriptStats: $ReadOnlyArray<ScriptStatT>,
|};

declare type LanguageStatT = {|
  +entity: LanguageT | null,
  +releases: number,
  +total: number,
  +works: number,
|};

export type MainStatsT = {|
  +$c: CatalystContextT,
  +areaTypes: $ReadOnlyArray<AreaTypeT>,
  +dateCollected: string,
  +eventTypes: $ReadOnlyArray<EventTypeT>,
  +instrumentTypes: $ReadOnlyArray<InstrumentTypeT>,
  +labelTypes: $ReadOnlyArray<LabelTypeT>,
  +packagings: {[string]: ReleasePackagingT},
  +placeTypes: $ReadOnlyArray<PlaceTypeT>,
  +primaryTypes: {[string]: ReleaseGroupTypeT},
  +secondaryTypes: {[string]: ReleaseGroupSecondaryTypeT},
  +seriesTypes: $ReadOnlyArray<SeriesTypeT>,
  +stats: StatsT,
  +statuses: {[string]: ReleaseStatusT},
  +workAttributeTypes: $ReadOnlyArray<WorkAttributeTypeT>,
  +workTypes: $ReadOnlyArray<WorkTypeT>,
|};

export type StatisticsLayoutPropsT = {|
  +children: ReactNode,
  +fullWidth: boolean,
  +page: string,
  +title: string,
|};

declare type ScriptStatT = {|
  +count: number,
  +entity: ScriptT | null,
|};

declare type StatsT = {|
  +data: {[string]: number},
  +date_collected: string,
|}
