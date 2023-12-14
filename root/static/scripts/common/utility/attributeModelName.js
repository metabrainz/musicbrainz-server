/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

function attributeModelName(model: string): string {
  switch (model) {
    case 'AreaType':
      return l('Area types');
    case 'AreaAliasType':
      return l('Area alias types');
    case 'ArtistType':
      return l('Artist types');
    case 'ArtistAliasType':
      return l('Artist alias types');
    case 'CollectionType':
      return l('Collection types');
    case 'CoverArtType':
      return l('Cover art types');
    case 'EventType':
      return l('Event types');
    case 'EventAliasType':
      return l('Event alias types');
    case 'Gender':
      return l('Genders');
    case 'GenreAliasType':
      return l('Genre alias types');
    case 'InstrumentType':
      return l('Instrument types');
    case 'InstrumentAliasType':
      return l('Instrument alias types');
    case 'LabelType':
      return l('Label types');
    case 'LabelAliasType':
      return l('Label alias types');
    case 'Language':
      return l('Languages');
    case 'MediumFormat':
      return l('Medium formats');
    case 'PlaceType':
      return l('Place types');
    case 'PlaceAliasType':
      return l('Place alias types');
    case 'RecordingAliasType':
      return l('Recording alias types');
    case 'ReleaseAliasType':
      return l('Release alias types');
    case 'ReleaseGroupSecondaryType':
      return l('Release group secondary types');
    case 'ReleaseGroupType':
      return l('Release group primary types');
    case 'ReleaseGroupAliasType':
      return l('Release group alias types');
    case 'ReleasePackaging':
      return l('Release packagings');
    case 'ReleaseStatus':
      return l('Release statuses');
    case 'Script':
      return l('Scripts');
    case 'SeriesType':
      return l('Series types');
    case 'SeriesAliasType':
      return l('Series alias types');
    case 'WorkAttributeType':
      return l('Work attribute types');
    case 'WorkType':
      return l('Work types');
    case 'WorkAliasType':
      return l('Work alias types');
    default:
      return model;
  }
}

export default attributeModelName;
