// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2017 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const _ = require('lodash');
const React = require('react');

const {artistBeginLabel, artistEndLabel} = require('../../artist/utils');
const {addColon, l} = require('../../static/scripts/common/i18n');
const commaOnlyList = require('../../static/scripts/common/i18n/commaOnlyList');
const formatBarcode = require('../../static/scripts/common/utility/formatBarcode');
const formatDate = require('../../static/scripts/common/utility/formatDate');
const formatTrackLength = require('../../static/scripts/common/utility/formatTrackLength');

function entityDescription(entity) {
  const desc = [];
  if (entity.comment) {
    desc.push(entity.comment);
  }
  if (entity.type) {
    desc.push(l('Type:') + ' ' + entity.type.name);
  }
  return desc;
}

function artistDescription(artist) {
  const desc = entityDescription(artist);
  const beginDate = formatDate(artist.begin_date);
  const endDate = formatDate(artist.end_date);
  if (artist.gender) {
    desc.push(l('Gender:') + ' ' + artist.gender.name);
  }
  if (beginDate || artist.begin_area) {
    desc.push(
      artistBeginLabel(artist.typeID) + ' ' +
      beginDate +
      (artist.begin_area ? ' in ' + artist.begin_area.name : '')
    );
  }
  if (endDate || artist.end_area) {
    desc.push(
      artistEndLabel(artist.typeID) + ' ' +
      endDate +
      (artist.end_area ? ' in ' + artist.end_area.name : '')
    );
  }
  if (artist.area) {
    desc.push(l('Area:') + ' ' + artist.area.name);
  }
  return desc;
}

function eventDescription(event) {
  const desc = entityDescription(event);
  const beginDate = formatDate(event.begin_date);
  const endDate = formatDate(event.end_date);
  if (beginDate) {
    desc.push(l('Start:') + ' ' + beginDate);
  }
  if (endDate) {
    desc.push(l('End:') + ' ' + endDate);
  }
  if (event.time) {
    desc.push(event.time);
  }
  return desc;
}

function instrumentDescription(instrument) {
  const desc = entityDescription(instrument);
  if (instrument.description) {
    desc.push(l('Description:') + ' ' + instrument.description);
  }
  return desc;
}

function labelDescription(label) {
  const desc = entityDescription(label);
  const beginDate = formatDate(label.begin_date);
  const endDate = formatDate(label.end_date);
  if (label.label_code) {
    desc.push(l('Label Code:') + ' ' + label.label_code);
  }
  if (beginDate) {
    desc.push(l('Founded:') + ' ' + beginDate);
  }
  if (endDate) {
    desc.push(l('Defunct:') + ' ' + endDate);
  }
  if (label.area) {
    desc.push(l('Area:') + ' ' + label.area.name);
  }
  return desc;
}

function placeDescription(place) {
  const desc = entityDescription(place);
  const beginDate = formatDate(place.begin_date);
  const endDate = formatDate(place.end_date);
  if (beginDate) {
    desc.push(l('Opened:') + ' ' + beginDate);
  }
  if (endDate) {
    desc.push(l('Closed:') + ' ' + endDate);
  }
  return desc;
}

function releaseDescription(release) {
  const desc = entityDescription(release);
  if (release.formats) {
    desc.push(l('Format:') + ' ' + release.formats);
  }
  let year;
  if (release.events && release.events.length) {
    year = release.events[0].date.year;
  }
  if (year) {
    desc.push(l('Year:') + ' ' + year);
  }
  if (release.labels && release.labels.length) {
    const labels = release.labels.map(function (rl) {
      return (
        (rl.label ? rl.label.name : '[unknown]') +
        (rl.catalogNumber ? (' (' + rl.catalogNumber + ')') : '')
      );
    });
    desc.push(
      (labels.length > 1 ? l('Labels:') : l('Label:')) + ' ' +
      commaOnlyList(labels)
    );
  }
  if (release.barcode) {
    desc.push(l('Barcode:') + ' ' + formatBarcode(release.barcode));
  }
  if (release.length) {
    desc.push(l('Length:') + ' ' + formatTrackLength(release.length));
  }
  return desc;
}

function workDescription(work) {
  const desc = entityDescription(work);
  if (work.languages.length) {
    desc.push(
      addColon(l('Lyrics Languages')) + ' ' +
      commaOnlyList(work.languages)
    );
  }
  if (work.writers) {
    desc.push(
      l('Writers:') + ' ' +
      commaOnlyList(_.map(work.writers, 'entity.name'))
    );
  }
  if (work.iswcs) {
    desc.push(
      l('ISWCs:') + ' ' + commaOnlyList(_.map(work.iswcs, 'iswc'))
    );
  }
  return desc;
}

const MetaDescription = ({entity}) => {
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
  if (desc && desc.length) {
    return <meta content={commaOnlyList(desc)} name="description" />;
  } else {
    return null;
  }
};

module.exports = MetaDescription;
