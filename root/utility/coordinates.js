/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export function formatCoordinates(coordinates: ?CoordinatesT): string {
  if (!coordinates) {
    return '';
  }
  const {latitude, longitude} = coordinates;
  return (
    Math.abs(latitude) + '°' + (latitude > 0 ? 'N' : 'S') + ', ' +
    Math.abs(longitude) + '°' + (longitude > 0 ? 'E' : 'W')
  );
}

export function osmUrl(coordinates: CoordinatesT, zoom: number): string {
  const latitude = encodeURIComponent(String(coordinates.latitude));
  const longitude = encodeURIComponent(String(coordinates.longitude));
  return 'http://www.openstreetmap.org/' +
    `?mlat=${latitude}&mlon=${longitude}` +
    `#map=${zoom}/${latitude}/${longitude}`;
}
