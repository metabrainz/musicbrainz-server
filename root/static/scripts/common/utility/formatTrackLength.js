/*
 * @flow strict
 * Copyright (C) 2011 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function formatTrackLength(
  milliseconds: number | null,
  placeholder?: string = '?:??',
): string {
  if (milliseconds == null || milliseconds === 0) {
    return placeholder;
  }

  if (milliseconds < 1000) {
    return milliseconds + ' ms';
  }

  const oneMinute = 60;
  const oneHour = 60 * oneMinute;

  const seconds = Math.round(milliseconds / 1000.0);
  let remainingSeconds = seconds;
  const hours = Math.floor(remainingSeconds / oneHour);
  remainingSeconds %= oneHour;

  const minutes = Math.floor(remainingSeconds / oneMinute);
  remainingSeconds %= oneMinute;

  let result = ('00' + remainingSeconds).slice(-2);

  if (hours > 0) {
    result = hours + ':' + ('00' + minutes).slice(-2) + ':' + result;
  } else {
    result = minutes + ':' + result;
  }

  return result;
}
