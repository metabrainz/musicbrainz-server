/*
 * @flow strict
 * Copyright (C) 2011 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// Keep in sync with Server::Track::UnformatTrackLength
export default function unformatTrackLength(
  duration: string,
): number | null {
  if (!duration) {
    return null;
  }

  // ?:?? or just space are allowed to indicate unknown/empty
  if (duration.match(/^\s*\?:\?\?\s*$/) || duration.match(/^\s*$/)) {
    return null;
  }

  // Check for HH:MM:SS
  let match = duration.match(/^\s*(\d{1,3}):(\d{1,2}):(\d{1,2})\s*$/);
  if (match) {
    const seconds = parseInt(match[3], 10);
    const minutes = parseInt(match[2] || 0, 10);
    const hours = parseInt(match[1] || 0, 10);
    if (minutes < 60 && seconds < 60) {
      return ((hours * 3600) + (minutes * 60) + seconds) * 1000;
    }
    return NaN;
  }

  // Check for MM:SS
  match = duration.match(/^\s*(\d+):(\d{1,2})\s*$/);
  if (match) {
    const seconds = parseInt(match[2], 10);
    const minutes = parseInt(match[1] || 0, 10);
    if (seconds < 60) {
      return ((minutes * 60) + seconds) * 1000;
    }
    return NaN;
  }

  // Check for :SS
  match = duration.match(/^\s*:(\d{1,2})\s*$/);
  if (match) {
    const seconds = parseInt(match[1], 10);
    if (seconds < 60) {
      return seconds * 1000;
    }
    return NaN;
  }

  // Check for XX ms
  match = duration.match(/^\s*(\d+(\.\d+)?)?\s+ms\s*$/);
  if (match) {
    return parseInt(match[1], 10);
  }

  // Check for just a number of seconds
  match = duration.match(/^\s*(\d+)\s*$/);
  if (match) {
    return parseInt(match[1], 10) * 1000;
  }

  return NaN;
}
