/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {artistBeginLabel, artistEndLabel} from '../../artist/utils.js';
import formatBarcode
  from '../../static/scripts/common/utility/formatBarcode.js';
import formatDate from '../../static/scripts/common/utility/formatDate.js';
import formatTrackLength
  from '../../static/scripts/common/utility/formatTrackLength.js';

function entityDescription(entity: CoreEntityT) {
  const desc = [];
  if (nonEmpty(entity.comment)) {
    desc.push(entity.comment);
  }
  return desc;
}

function pushTypeName(desc: Array<string>, entity: CoreEntityT) {
  const typeName = entity.typeName;
  if (nonEmpty(typeName)) {
    desc.push('Type: ' + typeName);
  }
}

function artistDescription(artist: ArtistT) {
  const desc = entityDescription(artist);
  pushTypeName(desc, artist);
  const beginDate = formatDate(artist.begin_date);
  const endDate = formatDate(artist.end_date);
  const gender = artist.gender;
  if (gender) {
    desc.push('Gender: ' + gender.name);
  }
  if (beginDate || artist.begin_area) {
    desc.push(
      artistBeginLabel(artist.typeID) + ' ' +
      beginDate +
      (artist.begin_area ? ' in ' + artist.begin_area.name : ''),
    );
  }
  if (endDate || artist.end_area) {
    desc.push(
      artistEndLabel(artist.typeID) + ' ' +
      endDate +
      (artist.end_area ? ' in ' + artist.end_area.name : ''),
    );
  }
  const area = artist.area;
  if (area) {
    desc.push('Area: ' + area.name);
  }
  return desc;
}

function eventDescription(event: EventT) {
  const desc = entityDescription(event);
  pushTypeName(desc, event);
  const beginDate = formatDate(event.begin_date);
  const endDate = formatDate(event.end_date);
  if (beginDate) {
    desc.push('Start: ' + beginDate);
  }
  if (endDate) {
    desc.push('End: ' + endDate);
  }
  if (event.time) {
    desc.push(event.time);
  }
  return desc;
}

function instrumentDescription(instrument: InstrumentT) {
  const desc = entityDescription(instrument);
  pushTypeName(desc, instrument);
  if (instrument.description) {
    desc.push('Description: ' + instrument.description);
  }
  return desc;
}

function labelDescription(label: LabelT) {
  const desc = entityDescription(label);
  pushTypeName(desc, label);
  const beginDate = formatDate(label.begin_date);
  const endDate = formatDate(label.end_date);
  if (label.label_code) {
    desc.push('Label Code: ' + label.label_code);
  }
  if (beginDate) {
    desc.push('Founded: ' + beginDate);
  }
  if (endDate) {
    desc.push('Defunct: ' + endDate);
  }
  const area = label.area;
  if (area) {
    desc.push('Area: ' + area.name);
  }
  return desc;
}

function placeDescription(place: PlaceT) {
  const desc = entityDescription(place);
  pushTypeName(desc, place);
  const beginDate = formatDate(place.begin_date);
  const endDate = formatDate(place.end_date);
  if (beginDate) {
    desc.push('Opened: ' + beginDate);
  }
  if (endDate) {
    desc.push('Closed: ' + endDate);
  }
  return desc;
}

function releaseDescription(release: ReleaseT) {
  const desc = entityDescription(release);
  const combinedFormatName = release.combined_format_name;
  if (nonEmpty(combinedFormatName)) {
    desc.push('Format: ' + combinedFormatName);
  }
  let year;
  if (release.events?.length) {
    year = release.events[0].date?.year;
  }
  if (year != null) {
    desc.push('Year: ' + year);
  }
  if (release.labels?.length) {
    const labels = release.labels.map(function (rl) {
      return (
        (rl.label ? rl.label.name : '[unknown]') +
        (nonEmpty(rl.catalogNumber) ? (' (' + rl.catalogNumber + ')') : '')
      );
    });
    desc.push(
      (labels.length > 1 ? 'Labels:' : 'Label:') + ' ' +
      labels.join(', '),
    );
  }
  if (nonEmpty(release.barcode)) {
    desc.push('Barcode: ' + formatBarcode(release.barcode));
  }
  if (release.length != null) {
    desc.push('Length: ' + formatTrackLength(release.length));
  }
  return desc;
}

const getLanguageName = (wl: WorkLanguageT) => wl.language.name;

const getEntityName =
  (x: {+entity: CoreEntityT, ...}): string => x.entity.name;

const getIswc = (x: IswcT) => x.iswc;

function workDescription(work: WorkT) {
  const desc = entityDescription(work);
  pushTypeName(desc, work);
  if (work.languages.length) {
    desc.push(
      'Lyrics Languages: ' +
      work.languages.map(getLanguageName).join(', '),
    );
  }
  if (work.writers) {
    desc.push(
      'Writers: ' +
      work.writers.map(getEntityName).join(', '),
    );
  }
  if (work.iswcs) {
    desc.push(
      'ISWCs: ' + work.iswcs.map(getIswc).join(', '),
    );
  }
  return desc;
}

type Props = {
  +entity: ?CoreEntityT,
};

const MetaDescription = ({entity}: Props): React.Element<'meta'> | null => {
  if (!entity) {
    return null;
  }
  let desc;
  switch (entity.entityType) {
    case 'artist':
      desc = artistDescription(entity);
      break;
    case 'event':
      desc = eventDescription(entity);
      break;
    case 'instrument':
      desc = instrumentDescription(entity);
      break;
    case 'label':
      desc = labelDescription(entity);
      break;
    case 'place':
      desc = placeDescription(entity);
      break;
    case 'release':
      desc = releaseDescription(entity);
      break;
    case 'work':
      desc = workDescription(entity);
      break;
  }
  if (desc?.length) {
    return <meta content={desc.join(', ')} name="description" />;
  }
  return null;
};

export default MetaDescription;
