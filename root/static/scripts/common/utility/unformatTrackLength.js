/*
 * @flow strict
 * Copyright (C) 2011 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function unformatTrackLength(
  duration: string,
): number | null {
  if (!duration) {
    return null;
  }

  if (duration.slice(-2) === 'ms') {
    return parseInt(duration, 10);
  }

  const parts = duration.replace(/[:.]/, ':').split(':');
  if (parts[0] === '?' || parts[0] === '??' || duration === '') {
    return null;
  }

  const seconds = parseInt(parts.pop(), 10);
  const minutes = parseInt(parts.pop() || 0, 10) * 60;
  const hours = parseInt(parts.pop() || 0, 10) * 3600;

  return (hours + minutes + seconds) * 1000;
}
